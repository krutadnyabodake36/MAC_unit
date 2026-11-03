[CmdletBinding()]
param (
    [string]$Port = "COM17",
    [string[]]$Designs = @("baseline", "oi", "cg", "zs", "zs_oi", "zs_cg", "oi_cg", "combined", "static_sobel"),
    [string[]]$Images = @("image1.jpg", "image2.jpg", "image3.jpg", "image4.jpg"),
    [string]$TreeDir = "",
    [switch]$DryRun,
    [switch]$Sim,
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Get-Item $PSScriptRoot\..).FullName

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "    INVENT LOGICS EDGE SPARTAN-7 - MASTER HARDWARE EXECUTION SUITE (L3)" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "Target Board     : Invent Logics EDGE Spartan-7 (XC7S15-1FTGB196C at 50 MHz)"
Write-Host "Target COM Port  : $Port (Baud: 115200 8-N-1)"
Write-Host "Execution Mode   : $(if ($Sim) { 'SIMULATED STUB (--sim)' } elseif ($DryRun) { 'DRY RUN (No Hardware)' } else { 'PHYSICAL HARDWARE [UNTESTED ON HARDWARE]' })"
Write-Host "Designs to Run   : $($Designs -join ', ')"
Write-Host "Images to Run    : $($Images -join ', ')"
Write-Host "--------------------------------------------------------------------------------"

# 1. Initialize or resolve results tree
if (-not $TreeDir) {
    $ts = Get-Date -Format "yyyyMMdd_HHmm"
    $TreeDir = Join-Path $ProjectRoot "board_results_$ts"
}

Write-Host "[SETUP] Initializing Results Tree: $TreeDir" -ForegroundColor Yellow
& python "$ProjectRoot\scripts\setup_board_results_tree.py" "$TreeDir"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] Could not initialize results tree." -ForegroundColor Red
    exit 1
}

$ManifestPath = "$ProjectRoot\results\final_run_20261030_1056\bitstreams\MANIFEST.sha256"
$RunLogPath = "$TreeDir\logs\board_run_log.csv"

# 2. Main Design Execution Loop
foreach ($design in $Designs) {
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Magenta
    Write-Host ">>> DESIGN: $design" -ForegroundColor Magenta
    Write-Host "================================================================================" -ForegroundColor Magenta

    # Interactive Prompt (L3)
    if (-not $NonInteractive -and -not $DryRun) {
        $prompt = Read-Host "[PROMPT] Press [Enter] to configure and test '$design', [S] to skip, [Q] to quit"
        if ($prompt -match "^[Qq]") {
            Write-Host "[ABORT] User cancelled execution." -ForegroundColor Yellow
            exit 0
        }
        if ($prompt -match "^[Ss]") {
            Write-Host "[SKIP] Skipping design '$design'." -ForegroundColor DarkYellow
            continue
        }
    }

    $bitFile = "$ProjectRoot\results\final_run_20261030_1056\bitstreams\conv2d_benchmark_$design.bit"
    if (-not (Test-Path $bitFile)) {
        Write-Host "[FAIL] Bitstream not found: $bitFile" -ForegroundColor Red
        exit 1
    }

    # Verify bitstream SHA-256 against manifest
    $bitHash = (Get-FileHash -Path $bitFile -Algorithm SHA256).Hash.ToLower()
    $expectedMatch = Select-String -Path $ManifestPath -Pattern "conv2d_benchmark_$design\.bit" | Select-Object -First 1
    if ($expectedMatch) {
        $expectedHash = ($expectedMatch.Line.Trim() -split '\s+')[0].ToLower()
        if ($bitHash -ne $expectedHash) {
            Write-Host "[FAIL] Bitstream hash mismatch for $design!" -ForegroundColor Red
            Write-Host "  Calculated: $bitHash" -ForegroundColor Red
            Write-Host "  Manifest  : $expectedHash" -ForegroundColor Red
            exit 1
        }
        Write-Host "[PASS] Bitstream hash verified ($bitHash)." -ForegroundColor Green
    }

    # Program FPGA (unless DryRun or Sim)
    if (-not $DryRun -and -not $Sim) {
        Write-Host "[JTAG] Programming FPGA with $bitFile..." -ForegroundColor Cyan
        $tclScript = "$ProjectRoot\scripts\program_fpga_checked.tcl"
        $vivadoBat = "C:\AMDDesignTools\2026.1\Vivado\bin\vivado.bat"
        $progLog = "$TreeDir\logs\program_$design.log"

        & $vivadoBat -mode batch -source $tclScript -tclargs $bitFile | Tee-Object -FilePath $progLog
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[FAIL] Programming failed for $design (Exit Code: $LASTEXITCODE). Halting." -ForegroundColor Red
            exit 1
        }
        Write-Host "[PASS] FPGA successfully configured (DONE LED Verified)." -ForegroundColor Green
    } elseif ($DryRun) {
        Write-Host "[DRY-RUN] Simulating FPGA configuration check." -ForegroundColor Gray
    }

    # Run each image
    foreach ($imgFile in $Images) {
        $imgStem = [System.IO.Path]::GetFileNameWithoutExtension($imgFile)
        $imgFullPath = "$ProjectRoot\$imgFile"
        $imgHash = (Get-FileHash -Path $imgFullPath -Algorithm SHA256).Hash.ToLower()

        $outDir = "$TreeDir\$imgStem\$design"
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null

        Write-Host ""
        Write-Host "  --- Running Image: $imgFile on $design ---" -ForegroundColor White
        $tStartIso = (Get-Date).ToUniversalTime().ToString("o")

        $profilerArgs = @(
            "$ProjectRoot\fpga_vision_profiler.py",
            $imgFullPath,
            "--design", $design,
            "--port", $Port,
            "--baud", "115200",
            "--output-dir", $outDir,
            "--metadata", "$TreeDir\run_metadata.json"
        )
        if ($Sim -or $DryRun) {
            $profilerArgs += "--sim"
        }

        $consoleLog = "$outDir\console.log"
        $execSuccess = $false

        try {
            & python @profilerArgs | Tee-Object -FilePath $consoleLog
            if ($LASTEXITCODE -eq 0) {
                $execSuccess = $true
            }
        } catch {
            Write-Host "[ERROR] Exception during execution: $_" -ForegroundColor Red
            $execSuccess = $false
        }

        $tEndIso = (Get-Date).ToUniversalTime().ToString("o")

        # Check compare.json for strict verification
        $compareJson = "$outDir\compare.json"
        $statusStr = "FAIL"
        $patchCount = 0

        if ($execSuccess -and (Test-Path $compareJson)) {
            $compData = Get-Content $compareJson | ConvertFrom-Json
            $patchCount = $compData.patches
            if ($compData.status -eq "PASS") {
                $statusStr = "PASS"
                Write-Host "  [PASS] $design on $imgFile verified bit-exact against simulation!" -ForegroundColor Green
            } else {
                Write-Host "  [FAIL] $design on $imgFile reported mismatches!" -ForegroundColor Red
            }
        }

        # Log entry
        $logLine = "$tStartIso,$tEndIso,$design,$bitHash,$imgFile,$imgHash,$patchCount,$Port,$LASTEXITCODE,$statusStr"
        Add-Content -Path $RunLogPath -Value $logLine

        # If run failed: quarantine partial files into interrupted_<time>/
        if ($statusStr -ne "PASS") {
            $interruptedDir = Join-Path $outDir ("interrupted_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
            New-Item -ItemType Directory -Force -Path $interruptedDir | Out-Null
            Write-Host "  [QUARANTINE] Moving partial failure files to $interruptedDir" -ForegroundColor Yellow
            Get-ChildItem -Path $outDir -Exclude ("interrupted_*") | Move-Item -Destination $interruptedDir -Force
            Write-Host "[STRICT STOP] Execution halted due to failure." -ForegroundColor Red
            exit 1
        }
    }
}

# 3. Post-Run Summaries
Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ">>> GENERATING AGGREGATE SUMMARY TABLES AND CONSISTENCY AUDIT" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
& python "$ProjectRoot\scripts\generate_board_summaries.py" "$TreeDir"

# Generate SHA-256 Manifest of tree
Write-Host "[MANIFEST] Generating manifest.sha256 for all deliverables..." -ForegroundColor Yellow
$manifestFile = "$TreeDir\manifest.sha256"
$allFiles = Get-ChildItem -Path $TreeDir -Recurse -File | Where-Object { $_.FullName -ne $manifestFile }
$manifestLines = @()
foreach ($f in $allFiles) {
    $rel = $f.FullName.Substring($TreeDir.Length + 1).Replace("\", "/")
    $h = (Get-FileHash -Path $f.FullName -Algorithm SHA256).Hash.ToLower()
    $manifestLines += "$h  $rel"
}
$manifestLines | Out-File -FilePath $manifestFile -Encoding utf8

Write-Host ""
Write-Host "[COMPLETE] All operations finished successfully in: $TreeDir" -ForegroundColor Green

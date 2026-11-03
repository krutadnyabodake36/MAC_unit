# =============================================================================
# scripts/run_board_design.ps1
# Automated Single-Command Board Evaluation Script for Invent Logics EDGE Spartan-7
# Usage:
#   .\scripts\run_board_design.ps1 -Design baseline -Port COM17
#   .\scripts\run_board_design.ps1 -Design static_sobel -Port COM17 -DryRun
# Parameters:
#   -Design: One of baseline, oi, cg, zs, combined, zs_oi, zs_cg, oi_cg, static_sobel
#   -Port: USB-UART COM port (e.g. COM17)
#   -DryRun: Runs software simulation mode without requiring physical hardware
#   -SkipPowerCycle: Bypasses manual power-cycle confirmation prompt
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("baseline", "oi", "cg", "zs", "combined", "zs_oi", "zs_cg", "oi_cg", "static_sobel")]
    [string]$Design,

    [Parameter(Mandatory=$false)]
    [string]$Port = "COM17",

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [switch]$SkipPowerCycle
)

$ErrorActionPreference = "Stop"

$ProjectRoot = (Get-Item $PSScriptRoot).Parent.FullName
Set-Location $ProjectRoot

$BitstreamDir = Join-Path $ProjectRoot "results\final_run_20261030_1056\bitstreams"
$ManifestFile = Join-Path $ProjectRoot "results\final_run_20261030_1056\FROZEN_SIM_RESULTS_v2.sha256"
$LogDir       = Join-Path $ProjectRoot "logs\board"
$RunLogCsv    = Join-Path $LogDir "board_run_log.csv"

if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

if (!(Test-Path $RunLogCsv)) {
    "timestamp,design,bitstream_file,bitstream_sha256,image,port,exit_code" | Out-File -FilePath $RunLogCsv -Encoding utf8
}

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host " >>> BOARD RUN EXECUTION: DESIGN = $Design | PORT = $Port <<<" -ForegroundColor Cyan
Write-Host " Mode: $(if ($DryRun) { 'DRY RUN (SIMULATION)' } else { 'PHYSICAL HARDWARE' })" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# 1. Locate and Verify Bitstream
$BitFile = Join-Path $BitstreamDir "conv2d_benchmark_${Design}.bit"
if (!(Test-Path $BitFile)) {
    Write-Error "[FAIL] Bitstream file not found: $BitFile"
    exit 1
}

$CurrentSha256 = (Get-FileHash -Path $BitFile -Algorithm SHA256).Hash.ToLower()
Write-Host "[CHECK] Bitstream: $(Split-Path $BitFile -Leaf)"
Write-Host "[CHECK] SHA-256  : $CurrentSha256"

# Check against manifest
if (Test-Path $ManifestFile) {
    $ManifestMatch = Select-String -Path $ManifestFile -Pattern "bitstreams/$(Split-Path $BitFile -Leaf)" -SimpleMatch
    if ($ManifestMatch) {
        $ExpectedSha256 = ($ManifestMatch.Line -split '\s+')[0].ToLower()
        if ($CurrentSha256 -ne $ExpectedSha256) {
            Write-Error "[FAIL] Bitstream hash ($CurrentSha256) does not match manifest ($ExpectedSha256)!"
            exit 1
        }
        Write-Host "[CHECK] Bitstream integrity confirmed against frozen manifest." -ForegroundColor Green
    }
}

# 2. Program Hardware (Skipped in DryRun)
if (!$DryRun) {
    Write-Host "`n[STEP 1] Programming Spartan-7 FPGA via Hardware Manager..." -ForegroundColor Yellow
    $VivadoBin = "C:\AMDDesignTools\2026.1\Vivado\bin\vivado.bat"
    $ProgScript = Join-Path $ProjectRoot "scripts\program_fpga_checked.tcl"
    
    $progProc = Start-Process -FilePath $VivadoBin -ArgumentList "-mode batch -notrace -source `"$ProgScript`" -tclargs `"$BitFile`"" -Wait -NoNewWindow -PassThru
    if ($progProc.ExitCode -ne 0) {
        Write-Error "[FAIL] FPGA Programming failed with exit code $($progProc.ExitCode). Halting execution."
        exit 1
    }

    if (!$SkipPowerCycle) {
        Write-Host "`n[ACTION REQUIRED] Power-cycle board now: toggle switch SW1 OFF -> wait 3s -> ON." -ForegroundColor Magenta
        Write-Host "Press ENTER after power-cycle is complete to proceed..." -ForegroundColor Magenta
        [void][System.Console]::ReadLine()
    }
} else {
    Write-Host "`n[DRY RUN] Skipping physical programming step." -ForegroundColor DarkGray
}

# 3. Sanity Run (32x32 image)
Write-Host "`n[STEP 2] Executing Sanity Check (32x32 crop)..." -ForegroundColor Yellow
$SanitySession = "sanity_${Design}"
$SanityArgs = @("image1.jpg", "--size", "32", "--design", $Design, "--session", $SanitySession)
if ($DryRun) { $SanityArgs += "--sim" } else { $SanityArgs += @("--port", $Port) }

$sanityProc = Start-Process -FilePath "python" -ArgumentList (@("fpga_vision_profiler.py") + $SanityArgs) -Wait -NoNewWindow -PassThru
if ($sanityProc.ExitCode -ne 0) {
    Write-Error "[FAIL] Sanity execution failed. Halting execution."
    exit 1
}

$SanityProfile = Join-Path $ProjectRoot "results\$SanitySession\profile_${Design}.json"
if (!(Test-Path $SanityProfile)) {
    Write-Error "[FAIL] Expected sanity profile was not produced: $SanityProfile"
    exit 1
}
Write-Host "[PASS] Sanity execution completed successfully." -ForegroundColor Green

# 4. Full Workload Execution across 4 W1 Images
$Images = @("image1.jpg", "image2.jpg", "image3.jpg", "image4.jpg")

foreach ($img in $Images) {
    $imgBase = [System.IO.Path]::GetFileNameWithoutExtension($img)
    $SessionName = "hil_${Design}_${imgBase}"
    $LogFile = Join-Path $LogDir "${Design}_${imgBase}.log"
    $Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    Write-Host "`n------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host " >>> Running $Design on $img (Session: $SessionName) <<<" -ForegroundColor Cyan
    Write-Host " Log Destination: $LogFile" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------------" -ForegroundColor Cyan

    $RunArgs = @($img, "--design", $Design, "--session", $SessionName)
    if ($DryRun) { $RunArgs += "--sim" } else { $RunArgs += @("--port", $Port) }

    # Execute and tee console output to log
    $cmd = "python fpga_vision_profiler.py " + ($RunArgs -join " ")
    Write-Host "Command: $cmd" -ForegroundColor Gray

    $output = Invoke-Expression "$cmd 2>&1"
    $exitCode = $LASTEXITCODE

    $output | Out-File -FilePath $LogFile -Encoding utf8
    $output | ForEach-Object { Write-Host $_ }

    # Log to CSV
    "$Timestamp,$Design,$BitFile,$CurrentSha256,$img,$Port,$exitCode" | Out-File -FilePath $RunLogCsv -Append -Encoding utf8

    if ($exitCode -ne 0) {
        Write-Error "[FAIL] Execution of $img on $Design failed with code $exitCode! Check log: $LogFile"
        exit $exitCode
    }

    $ExpectedProfile = Join-Path $ProjectRoot "results\$SessionName\profile_${Design}.json"
    $ExpectedImage   = Join-Path $ProjectRoot "results\$SessionName\${Design}_edge.png"
    if (!(Test-Path $ExpectedProfile) -or !(Test-Path $ExpectedImage)) {
        Write-Error "[FAIL] Output artifacts missing for $SessionName!"
        exit 1
    }

    Write-Host "[PASS] $img completed successfully." -ForegroundColor Green
}

Write-Host "`n==================================================================" -ForegroundColor Green
Write-Host " [SUCCESS] All 4 images processed successfully for design '$Design'." -ForegroundColor Green
Write-Host " Execution logged to: $RunLogCsv" -ForegroundColor Green
Write-Host " Next step: Run scripts/collect_board_results.py to package all artifacts." -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green


$vivado_bin = "C:\AMDDesignTools\2026.1\Vivado\bin"
$out_file = "results\final_run_20261030_1056\uart_board_check\uart_board_check_all9.log"

"================================================================================" | Out-File -FilePath $out_file -Encoding utf8
"G2 UART BOARD PATH CHECK: ALL 9 ARCHITECTURAL VARIANTS (300 PATCHES)" | Out-File -Append -FilePath $out_file -Encoding utf8
"Stimulus: results/final_run_20261030_1056/vectors/image1.vec" | Out-File -Append -FilePath $out_file -Encoding utf8
"UART Configuration: 18-byte request frames, 6-byte reply frames" | Out-File -Append -FilePath $out_file -Encoding utf8
"Baud Divider: CLKS_PER_BIT = 16 (Parameterized UART RTL Simulation)" | Out-File -Append -FilePath $out_file -Encoding utf8
"================================================================================`n" | Out-File -Append -FilePath $out_file -Encoding utf8

$names = @{
    0 = "baseline"
    1 = "oi"
    2 = "cg"
    3 = "zs"
    4 = "combined"
    5 = "zs_oi"
    6 = "zs_cg"
    7 = "oi_cg"
    8 = "static_sobel"
}

0..8 | ForEach-Object {
    $sel = $_
    $name = $names[$sel]
    $top = "tb_uart_sel_$sel"
    $snap = "snap_uart_sel_$sel"
    
    Write-Host ">>> Elaborating $top ($name)..."
    & "$vivado_bin\xelab.bat" -top $top -s $snap -debug typical
    
    Write-Host ">>> Simulating $top ($name)..."
    $out = & "$vivado_bin\xsim.bat" $snap -R
    $out | Out-String | Write-Host
    
    "--- Variant $sel : $name ---" | Out-File -Append -FilePath $out_file -Encoding utf8
    $out | Out-File -Append -FilePath $out_file -Encoding utf8
    "`n" | Out-File -Append -FilePath $out_file -Encoding utf8
}

Write-Host ">>> ALL 9 VARIANTS COMPLETED <<<"


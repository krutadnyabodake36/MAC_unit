@echo off
setlocal enabledelayedexpansion

echo ==================================================================
echo  --- VIVADO ABLATION SIMULATION SUITE ---
echo  Testing All 5 Architectures:
echo    1. Baseline (Standard MAC / Modulo Conv2D)
echo    2. Only Operand Isolation (OI)
echo    3. Only Clock Gating (CG)
echo    4. Only Zero-Skipping (ZS)
echo    5. Combined Full Architecture (OI + CG + ZS)
echo ==================================================================

:: Detect Vivado Path
set VIVADO_BIN=
if exist "C:\AMDDesignTools\2026.1\Vivado\bin\xvlog.bat" (
    set "VIVADO_BIN=C:\AMDDesignTools\2026.1\Vivado\bin"
) else if exist "C:\Xilinx\Vivado\2026.1\bin\xvlog.bat" (
    set "VIVADO_BIN=C:\Xilinx\Vivado\2026.1\bin"
) else (
    where xvlog >nul 2>nul
    if %errorlevel% equ 0 (
        set "VIVADO_BIN="
    ) else (
        echo [ERROR] Vivado executables not found!
        echo Please ensure Vivado is installed at C:\AMDDesignTools\2026.1\Vivado\bin or on PATH.
        exit /b 1
    )
)

if not "%VIVADO_BIN%"=="" (
    set "PATH=%VIVADO_BIN%;%PATH%"
)

echo [INFO] Using Vivado binaries from: %VIVADO_BIN%
echo.

:: -----------------------------------------------------------------------------
:: Simulation 1: Single MAC Units Lockstep Verification (2,000 vectors)
:: -----------------------------------------------------------------------------
echo ==================================================================
echo [STEP 1/2] Running Single MAC Units Verification (tb_ablation_mac)
echo ==================================================================
call xvlog -sv src\mac_baseline.sv src\mac_oi.sv src\mac_cg.sv src\mac_zs.sv src\mac_combined.sv tb\tb_ablation_mac.sv
if %errorlevel% neq 0 (
    echo [ERROR] Compilation failed for tb_ablation_mac!
    exit /b %errorlevel%
)

call xelab -top tb_ablation_mac -s sim_mac
if %errorlevel% neq 0 (
    echo [ERROR] Elaboration failed for tb_ablation_mac!
    exit /b %errorlevel%
)

call xsim sim_mac -R
if %errorlevel% neq 0 (
    echo [ERROR] Simulation execution failed for tb_ablation_mac!
    exit /b %errorlevel%
)

echo.
:: -----------------------------------------------------------------------------
:: Simulation 2: 3x3 Conv2D Engines Lockstep Verification (100 patches / 900 ops)
:: -----------------------------------------------------------------------------
echo ==================================================================
echo [STEP 2/3] Running 3x3 Conv2D Engines Verification (tb_all_ablation_engines)
echo ==================================================================
call xvlog -sv src\conv2d_serial_baseline.sv src\conv2d_serial_oi.sv src\conv2d_serial_cg.sv src\conv2d_serial_zs.sv src\conv2d_serial_combined.sv tb\tb_all_ablation_engines.sv
if %errorlevel% neq 0 (
    echo [ERROR] Compilation failed for tb_all_ablation_engines!
    exit /b %errorlevel%
)

call xelab -top tb_all_ablation_engines -s sim_engines
if %errorlevel% neq 0 (
    echo [ERROR] Elaboration failed for tb_all_ablation_engines!
    exit /b %errorlevel%
)

call xsim sim_engines -R
if %errorlevel% neq 0 (
    echo [ERROR] Simulation execution failed for tb_all_ablation_engines!
    exit /b %errorlevel%
)

echo.
:: -----------------------------------------------------------------------------
:: Simulation 3: Master Rigorous Workload 1, 2, 3 Benchmark (2,700 real ops)
:: -----------------------------------------------------------------------------
echo ==================================================================
echo [STEP 3/3] Running Rigorous Datasets Workload 1, 2, 3 (tb_workload_rigorous)
echo ==================================================================
call xvlog -sv src\mac_baseline.sv src\mac_oi.sv src\mac_cg.sv src\mac_zs.sv src\mac_combined.sv src\conv2d_serial_baseline.sv src\conv2d_serial_oi.sv src\conv2d_serial_cg.sv src\conv2d_serial_zs.sv src\conv2d_serial_combined.sv tb\tb_workload_rigorous.sv
if %errorlevel% neq 0 (
    echo [ERROR] Compilation failed for tb_workload_rigorous!
    exit /b %errorlevel%
)

call xelab -top tb_workload_rigorous -s sim_workloads
if %errorlevel% neq 0 (
    echo [ERROR] Elaboration failed for tb_workload_rigorous!
    exit /b %errorlevel%
)

call xsim sim_workloads -R
if %errorlevel% neq 0 (
    echo [ERROR] Simulation execution failed for tb_workload_rigorous!
    exit /b %errorlevel%
)

echo.
echo ==================================================================
echo  --- ALL VIVADO SIMULATIONS COMPLETED SUCCESSFULLY! ---
echo ==================================================================
endlocal

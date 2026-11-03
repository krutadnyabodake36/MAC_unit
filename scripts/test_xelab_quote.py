import subprocess
cmd = [
    r"C:/AMDDesignTools/2026.1/Vivado/bin/xelab.bat",
    "-top", "tb_uart_board_path_check",
    "-s", "snap_uart_sel_3",
    "--generic_top", "DESIGN_SELECT=3",
    "--generic_top", "NUM_PATCHES=300",
    "-debug", "typical"
]
# Call the underlying xelab.exe directly to bypass batch file quoting issues!
exe_cmd = [
    r"C:/AMDDesignTools/2026.1/Vivado/bin/unwrapped/win64.o/xelab.exe",
    "-top", "tb_uart_board_path_check",
    "-s", "snap_uart_sel_3",
    "--generic_top", "DESIGN_SELECT=3",
    "--generic_top", "NUM_PATCHES=300",
    "-debug", "typical"
]
r = subprocess.run(exe_cmd, capture_output=True, text=True)
print("Returncode:", r.returncode)
if r.returncode != 0:
    print(r.stdout)
    print(r.stderr)
else:
    print("Snapshot built successfully!")


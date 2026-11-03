import os
import subprocess

tcl = """open_saif "test.saif"
log_saif [get_objects -r /tb_test_handshake/u_dut/*]
run 1005 ns
close_saif
exit
"""
with open("test_saif.tcl", "w") as f:
    f.write(tcl)

p = subprocess.run([r"C:\AMDDesignTools\2026.1\Vivado\bin\xsim.bat", "test_snap", "-t", "test_saif.tcl"], capture_output=True, text=True)
print("STDOUT:\n", p.stdout[-500:] if len(p.stdout) > 500 else p.stdout)
print("test.saif exists:", os.path.exists("test.saif"), "size:", os.path.getsize("test.saif") if os.path.exists("test.saif") else 0)

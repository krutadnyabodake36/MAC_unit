import time
import ctypes
import os

ES_CONTINUOUS = 0x80000000
ES_SYSTEM_REQUIRED = 0x00000001

pid = os.getpid()
pid_file = r"C:\Users\Krutadnye\Downloads\Projects\MAC\results\final_run_20261030_1056\saif\keep_awake.pid"
os.makedirs(os.path.dirname(pid_file), exist_ok=True)
with open(pid_file, "w", encoding="utf-8") as f:
    f.write(str(pid) + "\n")
    f.flush()

try:
    while True:
        ctypes.windll.kernel32.SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED)
        time.sleep(30)
except Exception:
    pass
finally:
    ctypes.windll.kernel32.SetThreadExecutionState(ES_CONTINUOUS)


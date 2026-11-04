import serial
import struct
import time
import sys

print(">>> LIVE FPGA HARDWARE PROBE (20 SECONDS) <<<")
print("Opening COM17 at 115200 baud...")

try:
    s = serial.Serial('COM17', 115200, timeout=0.08)
except Exception as e:
    print(f"Error opening COM17: {e}")
    sys.exit(1)

weights = [1, 0, -1, 2, 0, -2, 1, 0, -1]
pixels  = [10, 20, 30, 40, 50, 60, 70, 80, 90]
payload = struct.pack('<9b9b', *weights, *pixels)
# Expected: sum = -80, cycles = 9, skips = 0

start = time.time()
success = False
attempt = 0

print("Continuously streaming test frame. Press PB1 (SW14) on the board now...")
while time.time() - start < 15:
    attempt += 1
    s.reset_input_buffer()
    s.write(payload)
    resp = s.read(6)
    if len(resp) == 6:
        res, cyc, skp = struct.unpack('<ibb', resp)
        print(f"\n[RECEIVED 6 BYTES AT T+{time.time()-start:.2f}s] sum={res}, cyc={cyc}, skp={skp}")
        if res == -80 and cyc == 9 and skp == 0:
            print(">>> 100% BIT-EXACT MATCH! REAL CONVOLUTION ENGINE CONFIRMED! <<<")
            success = True
            break
        else:
            print(f">>> MISMATCH: Got sum={res}, cyc={cyc}, skp={skp} (Expected -80, 9, 0)")
    time.sleep(0.1)

s.close()
if not success:
    print("\nNo valid response within 15 seconds.")


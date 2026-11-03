with open("fpga_vision_profiler.py", "r", encoding="utf-8") as f:
    lines = f.readlines()

print("--- LINES 710-770 (print_summary) ---")
for i in range(710, min(770, len(lines))):
    print(f"{i+1}: {lines[i].rstrip()}")


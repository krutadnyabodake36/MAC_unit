with open("fpga_vision_profiler.py", "r", encoding="utf-8") as f:
    lines = f.readlines()

print("--- LINES 650-710 ---")
for i in range(650, min(710, len(lines))):
    print(f"{i+1}: {lines[i].rstrip()}")


with open("fpga_vision_profiler.py", "r", encoding="utf-8") as f:
    lines = f.readlines()

print("--- LINES 325-365 (analyze_patch metrics dict) ---")
for i in range(324, min(365, len(lines))):
    print(f"{i+1}: {lines[i].rstrip()}")

print("\n--- LINES 945-975 (compare print statements) ---")
for i in range(944, min(975, len(lines))):
    print(f"{i+1}: {lines[i].rstrip()}")

print("\n--- LINES 990-1025 (comp_report dict) ---")
for i in range(989, min(1025, len(lines))):
    print(f"{i+1}: {lines[i].rstrip()}")


with open("fpga_vision_profiler.py", "r", encoding="utf-8") as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")
for idx, line in enumerate(lines):
    l = line.lower()
    if any(k in l for k in ["energy", "power", "pj", "compare", ".json"]):
        print(f"{idx+1}: {line.rstrip()}")


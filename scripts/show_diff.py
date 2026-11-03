import difflib

with open('src/conv2d_benchmark_top_ablation.sv', 'r', encoding='utf-8') as f:
    f1 = [l.rstrip() + '\n' for l in f]

with open('src/conv2d_benchmark_top_static.sv', 'r', encoding='utf-8') as f:
    f2 = [l.rstrip() + '\n' for l in f]

diff = list(difflib.unified_diff(f1, f2, fromfile='src/conv2d_benchmark_top_ablation.sv', tofile='src/conv2d_benchmark_top_static.sv'))
with open('results/top_diff.patch', 'w', encoding='utf-8') as out:
    out.writelines(diff)

print(f"Diff lines count: {len(diff)}")
for line in diff[:50]:
    print(line.rstrip())
if len(diff) > 50:
    print(f"... ({len(diff)-50} more lines in results/top_diff.patch)")

import hashlib
import os

root_scripts = [
    'compare_all.py',
    'fpga_vision_profiler.py',
    'generate_ieee_paper_docx.py',
    'generate_ieee_paper_v2.py',
    'generate_journal_paper.py',
    'generate_test_data.py',
    'generate_workflow_diagram.py',
    'run_ablation_study.py',
    'run_benchmark.py',
    'run_workload_benchmark.py'
]

lines = ["# Root-level Python SHA-256 Manifest (Updated post-labeling in fpga_vision_profiler.py)"]
for f in root_scripts:
    if os.path.exists(f):
        h = hashlib.sha256(open(f, 'rb').read()).hexdigest()
        lines.append(f"{h}  {f}")

out_path = 'results/final_run_20261030_1056/manifest_root_python_sha256.txt'
with open(out_path, 'w') as fp:
    fp.write('\n'.join(lines) + '\n')
print(f"Updated {out_path} cleanly.")


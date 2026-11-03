import os
import json
import glob

base = 'results/final_run_20261030_1056/saif'
folders = sorted(glob.glob(f'{base}/*/*'))

print(f"{'Folder':32s} | {'Cycles':>8s} | {'Dyn(mW)':>8s} | {'u_core':>8s} | {'E/patch(nJ)':>11s} | {'Cov%':>5s} | {'Conf':>6s}")
print("-" * 90)

for f in folders:
    sum_file = os.path.join(f, 'run_summary.json')
    if os.path.exists(sum_file):
        d = json.load(open(sum_file))
        rel = os.path.relpath(f, base).replace('\\', '/')
        cyc = str(d.get('wall_cycles'))
        dyn_mw = f"{d.get('xml_total_dynamic_power_mw', 0.0):.4f}"
        core_w = d.get('text_core_dynamic_power_w')
        core_mw = f"{(core_w*1000.0):.4f}" if core_w is not None else "N/A"
        ep_nj = f"{d.get('energy_per_patch_nj', 0.0):.4f}"
        cov = f"{d.get('coverage_pct', 0)}%"
        conf = d.get('confidence', 'N/A')
        print(f"{rel:32s} | {cyc:>8s} | {dyn_mw:>8s} | {core_mw:>8s} | {ep_nj:>11s} | {cov:>5s} | {conf:>6s}")


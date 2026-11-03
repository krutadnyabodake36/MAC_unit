import glob
import re

print(f"{'Variant':20s} | {'Top LUTs':>8s} | {'Top FFs':>8s} | {'Engine Module':28s} | {'Eng LUTs':>8s} | {'Eng FFs':>8s}")
print('-' * 95)
for f in sorted(glob.glob('results/final_run_20261030_1056/reports/utilization_hierarchical_*.txt')):
    var = f.split('utilization_hierarchical_')[-1].replace('.txt', '')
    txt = open(f).read()
    table_lines = []
    in_table = False
    for line in txt.splitlines():
        if "1. Utilization by Hierarchy" in line:
            in_table = True
            continue
        if in_table and "|" in line and "Instance" not in line and "---" not in line and "Tool Version" not in line:
            table_lines.append(line.strip())
            
    top_line = table_lines[0] if len(table_lines) > 0 else ''
    eng_line = table_lines[2] if len(table_lines) > 2 else ''
    
    tp = [p.strip() for p in top_line.split('|') if p.strip()]
    ep = [p.strip() for p in eng_line.split('|') if p.strip()]
    
    top_luts = tp[2] if len(tp) > 2 else 'N/A'
    top_ffs  = tp[6] if len(tp) > 6 else 'N/A'
    
    eng_mod  = ep[1] if len(ep) > 1 else 'N/A'
    eng_luts = ep[2] if len(ep) > 2 else 'N/A'
    eng_ffs  = ep[6] if len(ep) > 6 else 'N/A'
    
    print(f"{var:20s} | {top_luts:>8s} | {top_ffs:>8s} | {eng_mod:28s} | {eng_luts:>8s} | {eng_ffs:>8s}")

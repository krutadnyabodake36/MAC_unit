import glob
import re

print(f"{'Variant':20s} | {'WNS (ns)':>10s} | {'TNS (ns)':>10s} | {'Fmax (MHz)':>10s} | {'Status':>8s}")
print('-' * 70)
for f in sorted(glob.glob('results/final_run_20261030_1056/reports/timing_benchmark_*.txt')):
    var = f.split('timing_benchmark_')[-1].replace('.txt', '')
    txt = open(f).read()
    
    # Look for the table row after WNS(ns) header
    lines = txt.splitlines()
    wns, tns = None, None
    for idx, line in enumerate(lines):
        if "WNS(ns)" in line and "TNS(ns)" in line:
            # Table data is typically 2 lines down (skip header and dashes)
            for sub_line in lines[idx+1:idx+5]:
                parts = sub_line.strip().split()
                if len(parts) >= 4:
                    try:
                        wns = float(parts[0])
                        tns = float(parts[1])
                        break
                    except ValueError:
                        pass
            if wns is not None:
                break
                
    fmax = 1000.0 / (20.0 - wns) if (wns is not None and wns < 20.0) else 0.0
    status = "MET" if (tns == 0.0 and wns is not None and wns >= 0.0) else "VIOLATED"
    wns_str = f"{wns:10.3f}" if wns is not None else "N/A"
    tns_str = f"{tns:10.3f}" if tns is not None else "N/A"
    fmax_str = f"{fmax:10.2f}" if fmax > 0 else "N/A"
    print(f"{var:20s} | {wns_str:>10s} | {tns_str:>10s} | {fmax_str:>10s} | {status:>8s}")

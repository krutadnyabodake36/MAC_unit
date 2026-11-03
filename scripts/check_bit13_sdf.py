with open('results/final_run_20261030_1056/netlists_v2/baseline/baseline_timesim.sdf', 'r') as f:
    text = f.read()

import re
m = re.search(r'\(CELL\s+\(CELLTYPE \"CARRY4\"\)\s+\(INSTANCE.*?accum1__85_carry__1.*?\)\s+\(DELAY.*?\)\s+\)', text, re.DOTALL)
if m:
    print(m.group(0))
else:
    print("Not found")

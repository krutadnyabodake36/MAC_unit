import xml.etree.ElementTree as ET

tree = ET.parse('results/final_run_20261030_1056/reports/power_saif_baseline_pilot.xml')
root = tree.getroot()

print("=" * 95)
print(f"{'Source Rail':<12} | {'Voltage (V)':<12} | {'Total (A)':<12} | {'Dynamic (A)':<12} | {'Static (A)':<12} | {'Dynamic Power (mW)':<18}")
print("-" * 95)
tot_dyn_mw = 0.0

for section in root.findall('.//section'):
    if section.attrib.get('title') == 'Power Supply Summary':
        for row in section.findall('.//tablerow'):
            cells = [c.attrib.get('contents', '').strip() for c in row.findall('.//tablecell')]
            if len(cells) >= 5:
                rail = cells[0]
                try:
                    v = float(cells[1])
                    tot_i = float(cells[2])
                    dyn_i = float(cells[3])
                    stat_i = float(cells[4])
                    p_dyn = v * dyn_i * 1000.0
                    tot_dyn_mw += p_dyn
                    print(f"{rail:<12} | {v:<12.3f} | {tot_i:<12.6f} | {dyn_i:<12.6f} | {stat_i:<12.6f} | {p_dyn:<18.4f}")
                except ValueError:
                    pass

print("-" * 95)
print(f"Total Dynamic Power (sum of all rails): {tot_dyn_mw:.4f} mW ({tot_dyn_mw/1000.0:.6f} W)")
print("=" * 95)


#!/usr/bin/env python3
import json
import os

def export_workload(json_path, dat_path):
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    patches = data['patches']
    with open(dat_path, 'w', encoding='utf-8') as out:
        for p in patches:
            w_str = " ".join(str(w) for w in p['weights'])
            px_str = " ".join(str(px) for px in p['pixels'])
            accum = p['expected_accum']
            skips = p['zero_skips']
            out.write(f"{w_str} {px_str} {accum} {skips}\n")
    print(f"Exported {len(patches)} patches to {dat_path}")

if __name__ == '__main__':
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    test_data_dir = os.path.join(base_dir, 'test_data')
    
    export_workload(
        os.path.join(test_data_dir, 'workload1_dense_early_layer.json'),
        os.path.join(test_data_dir, 'workload1.dat')
    )
    export_workload(
        os.path.join(test_data_dir, 'workload2_typical_mid_layer.json'),
        os.path.join(test_data_dir, 'workload2.dat')
    )
    export_workload(
        os.path.join(test_data_dir, 'workload3_sparse_deep_layer.json'),
        os.path.join(test_data_dir, 'workload3.dat')
    )


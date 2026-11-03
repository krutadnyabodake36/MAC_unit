import os

with open('tb/tb_conv2d_engine_saif_timesim_v2.sv', 'r', encoding='utf-8') as f:
    code = f.read()

# Replace module name
code = code.replace('module tb_conv2d_engine_saif_timesim_v2', 'module tb_baseline_sdf_audit')

# Replace mismatch printing logic to print all
old_mismatch = """                    if (conv_out !== golden) begin
                        total_mismatches++;
                        if (total_mismatches <= 10) begin
                            $display("[MISMATCH] Patch %0d: Expected=%0d, Got=%0d",
                                     total_patches_processed, golden, conv_out);
                        end
                    end"""

new_mismatch = """                    if (conv_out !== golden) begin
                        total_mismatches++;
                        $display("[MISMATCH] Patch %0d: Expected=%0d, Got=%0d, Diff=%0d",
                                 total_patches_processed, golden, conv_out, (conv_out - golden));
                    end"""

assert old_mismatch in code, 'old mismatch snippet not found'
code = code.replace(old_mismatch, new_mismatch)

with open('tb/tb_baseline_sdf_audit.sv', 'w', encoding='utf-8') as f:
    f.write(code)

print('Created tb/tb_baseline_sdf_audit.sv successfully')


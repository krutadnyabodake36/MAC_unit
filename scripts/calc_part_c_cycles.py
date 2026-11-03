import glob

files = [
    'results/final_run_20261030_1056/vectors/relu_r2/image1_gaussian.vec',
    'results/final_run_20261030_1056/vectors/relu_r2/image2_gaussian.vec',
    'results/final_run_20261030_1056/vectors/relu_r2/image3_gaussian.vec',
    'results/final_run_20261030_1056/vectors/relu_r2/image4_gaussian.vec',
]

# In conv2d_serial_zs:
# In S_IDLE: start -> S_LOAD (1 cycle)
# In S_LOAD: latches weights, pixels, computes non-zero mask.
#   nz_count = count of non-zero products (w_i != 0 and p_i != 0).
#   For dense gaussian, all w_i != 0. So nz_count = count of (p_i != 0).
# If nz_count == 0: compute_cycles = 1 (special fast exit or executes 1 step depending on RTL).
# Let's check conv2d_serial_zs.sv RTL!


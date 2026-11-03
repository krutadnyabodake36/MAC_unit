set variants [list \
    "baseline"     "results/final_run_20261030_1056/saif/natural_rerun/baseline/baseline_routed.dcp" \
    "cg"           "results/final_run_20261030_1056/saif/natural/cg/cg_routed.dcp" \
    "combined"     "results/final_run_20261030_1056/saif/natural/combined/combined_routed.dcp" \
    "oi"           "results/final_run_20261030_1056/saif/natural/oi/oi_routed.dcp" \
    "oi_cg"        "results/final_run_20261030_1056/saif/natural/oi_cg/oi_cg_routed.dcp" \
    "static_sobel" "results/final_run_20261030_1056/saif/natural/static_sobel/static_sobel_routed.dcp" \
    "zs"           "results/final_run_20261030_1056/saif/natural/zs/zs_routed.dcp" \
    "zs_cg"        "results/final_run_20261030_1056/saif/natural/zs_cg/zs_cg_routed.dcp" \
    "zs_oi"        "results/final_run_20261030_1056/saif/natural/zs_oi/zs_oi_routed.dcp" \
]

file mkdir "results/final_run_20261030_1056/funcsim"

foreach {var dcp} $variants {
    puts "=== Exporting funcsim for $var from $dcp ==="
    open_checkpoint $dcp
    set out_v "results/final_run_20261030_1056/funcsim/${var}_funcsim.v"
    write_verilog -mode funcsim -force $out_v
    puts "Wrote $out_v"
    close_project
}
puts "All 9 funcsim netlists exported successfully!"
exit


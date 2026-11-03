set objs [get_objects -r /tb_conv2d_engine_saif_timesim/*]
puts "TOTAL OBJECTS: [llength $objs]"
set dut_objs [get_objects -r /tb_conv2d_engine_saif_timesim/u_dut/*]
puts "DUT OBJECTS: [llength $dut_objs]"
foreach o [lrange $objs 0 20] {
    puts "  OBJ: $o"
}
exit


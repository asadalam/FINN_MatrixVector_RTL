create_clock -period 5.000 -name aclk -waveform {0.000 2.500} [get_ports aclk]
set _xlnx_shared_i0 [get_ports {s0_axis_tdata[*]}]
set_input_delay -clock [get_clocks aclk] -min 0.100 $_xlnx_shared_i0
set_input_delay -clock [get_clocks aclk] -max 0.200 $_xlnx_shared_i0
set_input_delay -clock [get_clocks aclk] -min 0.100 [get_ports aresetn]
set_input_delay -clock [get_clocks aclk] -max 0.200 [get_ports aresetn]
set_input_delay -clock [get_clocks aclk] -min 0.100 [get_ports m0_axis_tready]
set_input_delay -clock [get_clocks aclk] -max 0.200 [get_ports m0_axis_tready]
set_input_delay -clock [get_clocks aclk] -min 0.100 [get_ports s0_axis_tvalid]
set_input_delay -clock [get_clocks aclk] -max 0.200 [get_ports s0_axis_tvalid]
set _xlnx_shared_i1 [get_ports {m0_axis_tdata[*]}]
set_output_delay -clock [get_clocks aclk] -min 0.0100 $_xlnx_shared_i1
set_output_delay -clock [get_clocks aclk] -max 0.0100 $_xlnx_shared_i1
set_output_delay -clock [get_clocks aclk] -min 0.0100 [get_ports m0_axis_tvalid]
set_output_delay -clock [get_clocks aclk] -max 0.0100 [get_ports m0_axis_tvalid]
set_output_delay -clock [get_clocks aclk] -min 0.0100 [get_ports s0_axis_tready]
set_output_delay -clock [get_clocks aclk] -max 0.0100 [get_ports s0_axis_tready]

#!/bin/bash
rm -rf mvau_timesim_tb_v3.wdb
make clean
xvlog --sv mvau_timesim_tb_v3.sv
xvlog mvau_timesim.sv
xvlog $XILINX_VIVADO/data/verilog/src/glbl.v
DO_GUI="gui"
if [ "$1" == "$DO_GUI" ]; then
    xelab -debug all -maxdelay -L -secureip -L simprims_ver -transport_int_delays -pulse_r 0 -pulse_int_r 0 mvau_timesim_tb_v3 glbl -s run_mvau_timesim
    if [ $? -eq 0 ]; then
…    else
	echo "Post Synthesis simulation files compilation failed"
	exit 0
    fi
    xsim run_mvau_v3 -t mvau_xsim.tcl
fi
exit 1

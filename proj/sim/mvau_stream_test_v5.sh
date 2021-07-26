#!/bin/bash
rm -rf mvau_stream_tb_v5.wdb
make clean
DO_GUI="gui"
if [ "$1" == "$DO_GUI" ]; then
    xelab -prj mvau_stream_files.prj -s run_mvau_stream_v5 work.mvau_stream_tb_v5 --debug all
    if [ $? -eq 0 ]; then
	echo "RTL files compilation successfull"
    else
	echo "RTL files compilation failed"
	exit 0
    fi
    xsim run_mvau_stream_v5 -gui -wdb mvau_stream_tb_v5.wdb -t mvau_xsim_gui.tcl --sv_seed $RANDOM
else
    xelab -prj mvau_stream_files.prj -s run_mvau_stream_v5 work.mvau_stream_tb_v5
    if [ $? -eq 0 ]; then
	echo "RTL files compilation successfull"
    else
	echo "RTL files compilation failed"
	exit 0
    fi
    xsim run_mvau_stream_v5 -t mvau_xsim.tcl --sv_seed $RANDOM
fi
exit 1

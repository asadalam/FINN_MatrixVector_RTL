#!/bin/bash
rm -rf mvau_stream_tb_v4.wdb
make clean
DO_GUI="gui"
if [ "$1" == "$DO_GUI" ]; then
    xelab -prj mvau_stream_files.prj -s run_mvau_stream_v4 work.mvau_stream_tb_v4 --debug all
    if [ $? -eq 0 ]; then
	echo "RTL files compilation successfull"
    else
	echo "RTL files compilation failed"
	exit 0
    fi
    xsim run_mvau_stream_v4 -gui -wdb mvau_stream_tb_v4.wdb -t mvau_xsim_gui.tcl --sv_seed $RANDOM
else
    xelab -prj mvau_stream_files.prj -s run_mvau_stream_v4 work.mvau_stream_tb_v4
    if [ $? -eq 0 ]; then
	echo "RTL files compilation successfull"
    else
	echo "RTL files compilation failed"
	exit 0
    fi
    xsim run_mvau_stream_v4 -t mvau_xsim.tcl --sv_seed $RANDOM
fi
exit 1

#!/bin/bash
rm -rf mvau_tb_v3.wdb
make clean
DO_GUI="gui"
if [ "$1" == "$DO_GUI" ]; then
    xelab -prj mvau_files.prj -s run_mvau_v3 work.mvau_tb_v3 --debug all
    if [ $? -eq 0 ]; then
	echo "RTL files compilation successfull"
    else
	echo "RTL files compilation failed"
	exit 0
    fi
    xsim run_mvau_v3 -gui -wdb mvau_tb_v3.wdb -t mvau_xsim_gui.tcl --sv_seed $RANDOM
else
    xelab -prj mvau_files.prj -s run_mvau_v3 work.mvau_tb_v3
    if [ $? -eq 0 ]; then
	echo "RTL files compilation successfull"
    else
	echo "RTL files compilation failed"
	exit 0
    fi
    xsim run_mvau_v3 -t mvau_xsim.tcl --sv_seed $RANDOM
fi
exit 1

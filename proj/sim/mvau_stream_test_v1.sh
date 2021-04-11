#!/bin/bash
xelab -prj mvau_stream_files.prj -s run_mvau_stream work.mvau_stream_tb_v1 --debug all
DO_GUI="gui"
if [ "$1" == "$DO_GUI" ]; then
    xsim run_mvau_stream -gui -wdb mvau_stream_tb_v1.wdb -view mvau_stream_tb_v1.wcfg -t mvau_xsim.tcl
else
    xsim run_mvau_stream -wdb mvau_stream_tb_v1.wdb -view mvau_stream_tb_v1.wcfg -t mvau_xsim.tcl
fi

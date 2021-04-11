#!/bin/bash
rm -rf mvau_stream_tb_v3.wdb
xelab -prj mvau_stream_files.prj -s run_mvau_stream_v3 work.mvau_stream_tb_v3 --debug all
DO_GUI="gui"
if [ "$1" == "$DO_GUI" ]; then
    xsim run_mvau_stream_v3 -gui -wdb mvau_stream_tb_v3.wdb -t mvau_xsim.tcl
else
    xsim run_mvau_stream_v3 -wdb mvau_stream_tb_v3.wdb -t mvau_xsim.tcl
fi

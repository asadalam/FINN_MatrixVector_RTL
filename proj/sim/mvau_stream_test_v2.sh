#!/bin/bash
xelab -prj mvau_stream_files.prj -s run_mvau_stream work.mvau_stream_tb_v2 --debug all
xsim run_mvau_stream -wdb mvau_stream_tb_v2.wdb -view mvau_stream_tb_v1.wcfg -t mvau_xsim.tcl

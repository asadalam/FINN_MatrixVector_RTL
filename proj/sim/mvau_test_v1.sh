#!/bin/bash
xelab -prj mvau_files.prj -s run_mvau work.mvau_tb_v1 --debug all
xsim run_mvau -wdb mvau_tb_v1.wdb -view mvau_tb_v1.wcfg -t mvau_xsim.tcl

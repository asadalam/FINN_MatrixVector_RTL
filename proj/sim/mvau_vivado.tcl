exec xelab -prj mvau_files.prj -s run_mvau work.mvau_tb --debug all
exec xsim run_mvau -gui -wdb mvau_tb.wdb -view mvau_tb.wcfg -t mvau_xsim.tcl
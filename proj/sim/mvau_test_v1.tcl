exec xelab -prj mvau_files.prj -s run_mvau work.mvau_tb_v1 --debug all
exec xsim run_mvau -gui -wdb mvau_tb_v1.wdb -view mvau_tb_v1.wcfg -t mvau_xsim.tcl

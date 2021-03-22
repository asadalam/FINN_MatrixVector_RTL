exec xelab -prj mvau_stream_files.prj -s run_mvau_stream work.mvau_stream_tb --debug all
exec xsim run_mvau_stream -gui -wdb mvau_stream_tb.wdb -view mvau_stream_tb.wcfg -t mvau_xsim.tcl

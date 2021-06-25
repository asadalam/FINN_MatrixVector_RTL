##########################################################
# TCL: mvau_stream_synth.tcl
# 
# Author(s): Syed Asad Alam (syed.asad.alam@tcd.ie)
# 
# Tcl script for synthesizing the MVAU stream RTL design
##########################################################

#
# STEP#1: Initialize time
#
set t0 [clock clicks -milliseconds]

#
# STEP#2: define the output directory area.
#
set outputDir ./mvau_stream_project
file mkdir $outputDir

#
# STEP#3: setup design sources and constraints
#
read_verilog [ glob ../src/mvau_top/mvau_stream/mvau_stream_top.v ]
read_verilog -sv [ glob ../src/mvau_top/mvau_stream/*.sv ]
read_verilog -sv [ glob ../src/mvau_top/mvau_stream/mvu_pe/*.sv ]

read_xdc -mode out_of_context ./mvau_stream.xdc

#
# STEP#4: Run Synthesis
#
synth_design -top mvau_stream -part xczu3eg-sbva484-1-i -mode out_of_context -retiming
write_checkpoint -force $outputDir/post_synth.dcp

#
# STEP#5: Report summaries
#
#report_timing_summary -delay_type max -datasheet -file $outputDir/post_opt_timing_summary.rpt
#report_timing -delay_type max -path_type summary -file $outputDir/post_opt_timing.rpt
#report_utilization -file $outputDir/post_opt_util.rpt

#
# STEP#5: Optimize synthesis result
#
opt_design
write_checkpoint -force $outputDir/post_opt.dcp

#
# STEP#6: Report summaries
#
report_timing_summary -delay_type max -datasheet -file $outputDir/post_opt_timing_summary.rpt
report_timing -delay_type max -path_type summary -file $outputDir/post_opt_timing.rpt
report_utilization -file $outputDir/post_opt_util.rpt
puts "Synthesis done!"

#
# STEP#7: Calculate total time and write to file
set t1 [expr {([clock clicks -milliseconds] - $t0)/1000.}]
set outfile [open "rtl_exec.rpt" w]
puts $outfile $t1
close $outfile

# STEP#4: Creating a timing simulation netlist
# open_checkpoint $outputDir/post_opt.dcp
# write_verilog -mode timesim -sdf_anno true -force mvau_stream_timesim.sv
  
# Generating SDF delay file
write_sdf -force ../sim/mvau_stream_timesim.sdf


##########################################################
# TCL: mvau_stream_synth.tcl
# 
# Author(s): Syed Asad Alam (syed.asad.alam@tcd.ie)
# 
# Tcl script for synthesizing the MVAU stream RTL design
##########################################################

#
# STEP#1: define the output directory area.
#
set outputDir ./mvau_stream_project
file mkdir $outputDir


#
# STEP#2: setup design sources and constraints
#
#add_files -fileset sim_1 ../sim/mvau_stream_tb_v3.sv
read_verilog -sv [ glob ../src/mvau_top/mvau_defn.sv ]
read_verilog -sv [ glob ../src/mvau_top/mvau_stream/*.sv ]
read_verilog -sv [ glob ../src/mvau_top/mvau_stream/mvu_pe/*.sv ]
read_xdc -mode out_of_context ./mvau_stream.xdc
#-mode out_of_context
synth_design -top mvau_stream -part xczu3eg-sbva484-1-i -mode out_of_context -retiming
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -delay_type max -datasheet -file $outputDir/post_synth_timing_summary.rpt
report_timing -delay_type max -path_type summary -file $outputDir/post_synth_timing.rpt
report_utilization -file $outputDir/post_synth_util.rpt

report_utilization -file $outputDir/post_synth_util.rpt
opt_design
report_timing_summary -delay_type max -datasheet -file $outputDir/post_opt_timing_summary.rpt
report_timing -delay_type max -path_type summary -file $outputDir/post_opt_timing.rpt
report_utilization -file $outputDir/post_opt_util.rpt
puts "Synthesis done!"

# STEP#4: Creating a timing simulation netlist
## open_checkpoint mvau_stream_project/mvau_stream_project.runs/synth_1/mvau_stream.dcp
## write_verilog -mode timesim -sdf_anno true -force mvau_stream_timesim.sv
##  
## # Generating SDF delay file
## write_sdf -force mvau_stream_timesim.sdf


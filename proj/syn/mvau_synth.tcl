##########################################################
# TCL: mvau_synth.tcl
# 
# Author(s): Syed Asad Alam (syed.asad.alam@tcd.ie)
# 
# Tcl script for synthesizing the MVAU stream RTL design
##########################################################
#
# STEP#1: Check for input argument, number of PEs
if { $argc != 1 } {
    puts "The add.tcl script requires number of PEs to be inputed."
    puts "For example, vivado -mode batch -source mvau_synth.tcl 2."
    puts "Please try again."
} else {
    puts [expr [lindex $argv 0]]
}
set pe [lindex $argv 0]     
#
# STEP#2: Initialize time
#
set t0 [clock clicks -milliseconds]

#
# STEP#3: define the output directory area.
#
set outputDir ./mvau_project
file mkdir $outputDir

#
# STEP#4: setup design sources and constraints
#
read_verilog -sv [ glob ../src/mvau_top/*.sv ]
read_verilog -sv [ glob ../src/mvau_top/mvau_stream/*.sv ]
read_verilog -sv [ glob ../src/mvau_top/mvau_stream/mvu_pe/*.sv ]
for {set p 0} {$p < $pe} {incr p} {
    read_mem ../src/mvau_top/weight_mem$p.mem
}
read_xdc -mode out_of_context ./mvau.xdc

#
# STEP#5: Run Synthesis
#
synth_design -top mvau -part xczu3eg-sbva484-1-i -mode out_of_context -retiming
write_checkpoint -force $outputDir/post_synth.dcp


# report_timing_summary -delay_type max -datasheet -file $outputDir/post_synth_timing_summary.rpt
# report_timing -delay_type max -path_type summary -file $outputDir/post_synth_timing.rpt
# report_utilization -file $outputDir/post_synth_util.rpt

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
open_checkpoint $outputDir/post_opt.dcp
write_verilog -mode timesim -sdf_anno true -force ../sim/mvau_timesim.sv
 
# Generating SDF delay file
write_sdf -force ../sim/mvau_timesim.sdf


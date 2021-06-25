#!/bin/bash
# Copyright © 2020 Syed Asad Alam. All rights reserved.
# Running the test_mvau_binwgt_rtl.tcl using the following steps:
# 1) Generates parameter definition file
# 2) Runs RTL functional simulation
# 3) Runs RTL synthesis
echo "Generating parameter file"
cd $MVAU_RTL_ROOT/proj/src/mvau_top/
ifm_ch=${1:-4}
ifm_dim=${2:-4}
ofm_ch=${3:-4}
kdim=${4:-2}
inp_wl=${5:-8}
inp_bin=${6:-0}
wgt_wl=${7:-1}
wgt_bin=${8:-1}
out_wl=${9:-16}
simd=${10:-2}
pe=${11:-2}

echo "Generating Verilog Top-Level Wrapper"
python gen_mvau_top.py --ifm_ch ${ifm_ch} --ifm_dim ${ifm_dim} --ofm_ch ${ofm_ch} --kdim ${kdim} --inp_wl ${inp_wl} --inp_bin ${inp_bin} --wgt_wl ${wgt_wl} --wgt_bin ${wgt_bin} --out_wl ${out_wl} --simd ${simd} --pe ${pe}
if [ $? -eq 0 ]; then
    echo "Verilog top level wrapper file generation successfull"
else
    echo "Verilog top level wrapper file generation failed"
    exit 0
fi

echo "Generating MVAU weight files"
python gen_mvau_weight_mem_merged.py --pe ${pe}
if [ $? -eq 0 ]; then
    echo "Weight top level file generation successfull"
else
    echo "Weight top level file generation failed"
    exit 0
fi

rm mvau_weight_mem[0-9]*.sv
for((p=0; p<${pe}; p++))
do
    python gen_mvau_weight_mem.py --wmem_id ${p}
    if [ $? -eq 0 ]; then
	echo "Weight memories generation successfull"
    else
	echo "Weight memories failed"
	exit 0
    fi
done
cd $MVAU_RTL_ROOT/proj/sim
cut -c3- inp_act.mem > temp
cp temp inp_act.mem

python gen_mvau_defn.py --ifm_ch ${ifm_ch} --ifm_dim ${ifm_dim} --ofm_ch ${ofm_ch} --kdim ${kdim} --inp_wl ${inp_wl} --inp_bin ${inp_bin} --wgt_wl ${wgt_wl} --wgt_bin ${wgt_bin} --out_wl ${out_wl} --simd ${simd} --pe ${pe}
if [ $? -eq 0 ]; then
    echo "Parameter file generation successfull"
else
    echo "Parameter file generation failed"
    exit 0
fi

echo "Generating Project file for simulation"
python gen_mvau_files.py --pe ${pe}
if [ $? -eq 0 ]; then
    echo "Simulation project file generation successfull"
else
    echo "Simulation project file generation failed"
    exit 0
fi

echo "Running behavorial simulation of RTL"
bash mvau_test_v3.sh
if [ $? -eq 0 ]; then
    echo "RTL simulation failed"
    exit 0
elif grep -q "Data MisMatch" xsim.log; then
    echo "RTL simulation failed"
    exit 0
elif grep -q "failed" xsim.log; then
    echo "RTL simulation failed"
    exit 0
else
    echo "RTL simulation successful"
fi

echo "Running behavorial simulation of RTL with different input timing"
bash mvau_test_v4.sh
if [ $? -eq 0 ]; then
    echo "RTL simulation failed"
    exit 0
elif grep -q "Data MisMatch" xsim.log; then
    echo "RTL simulation failed"
    exit 0
elif grep -q "failed" xsim.log; then
    echo "RTL simulation failed"
    exit 0
else
    echo "RTL simulation successful"
fi

echo "Synthesizing MVAU Batch RTL"
cd $MVAU_RTL_ROOT/proj/syn
vivado -mode batch -source mvau_synth.tcl -tclargs ${pe}
if [ $? -eq 0 ]; then
    echo "RTL synthesis successfull"
else
    echo "RTL synthesis failed"
    exit 0
fi
# cd $MVAU_RTL_ROOT/proj/sim
# bash mvau_timesim_test.sh
# if grep -q "Data MisMatch" xsim.log; then
#     echo "RTL post synthesis simulation failed"
#     exit 0
# elif grep -q "failed" xsim.log; then
#     echo "RTL post synthesis simulation failed"
#     exit 0
# else
#     echo "Post synthesis simulation successful"
# fi
exit 1

#!/bin/bash
# Copyright © 2020 Syed Asad Alam. All rights reserved.
# Running the test_mvau_stream_xnor_rtl.tcl using the following steps:
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
python gen_mvau_defn.py --ifm_ch ${ifm_ch} --ifm_dim ${ifm_dim} --ofm_ch ${ofm_ch} --kdim ${kdim} --inp_wl ${inp_wl} --inp_bin ${inp_bin} --wgt_wl ${wgt_wl} --wgt_bin ${wgt_bin} --out_wl ${out_wl} --simd ${simd} --pe ${pe}
echo "Running behavorial simulation of RTL"
cd $MVAU_RTL_ROOT/proj/sim
cut -c3- inp_act.mem > temp
cp temp inp_act.mem
cut -c3- inp_wgt.mem > temp
cp temp inp_wgt.mem
bash mvau_stream_test_v3.sh
if grep -q "Data MisMatch" xsim.log; then
    echo "RTL simulation failed"
    exit 0
elif grep -q "failed" xsim.log; then
    echo "RTL simulation failed"
    exit 0
else
    echo "RTL simulation successful"
fi
echo "Synthesizing MVAU Stream RTL"
cd $MVAU_RTL_ROOT/proj/syn
vivado -mode batch -source mvau_stream_synth.tcl
if [$? -eq 0]; then
    echo "RTL synthesis successfull"
else
    echo "RTL synthesis failed"
    exit 0
fi
exit 1

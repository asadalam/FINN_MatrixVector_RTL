#!/bin/bash
rm -rf mvau_tb_v1.wdb
make clean

cd $MVAU_RTL_ROOT/proj/src/mvau_top/
ifm_ch=${2:-4}
ifm_dim=${3:-4}
ofm_ch=${4:-4}
kdim=${5:-2}
inp_wl=${6:-8}
inp_bin=${7:-0}
wgt_wl=${8:-1}
wgt_bin=${9:-1}
out_wl=${10:-16}
simd=${11:-2}
pe=${12:-2}
mmv=${13:-1}

echo "Generating Verilog Top-Level Wrapper"
python gen_mvau_top.py --ifm_ch ${ifm_ch} --ifm_dim ${ifm_dim} --ofm_ch ${ofm_ch} --kdim ${kdim} --inp_wl ${inp_wl} --inp_bin ${inp_bin} --wgt_wl ${wgt_wl} --wgt_bin ${wgt_bin} --out_wl ${out_wl} --simd ${simd} --pe ${pe} --mmv ${mmv}
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


cd $FINN_HLS_ROOT/tb
python gen_weights_fn.py --ifm_ch ${ifm_ch} --ifm_dim ${ifm_dim} --ofm_ch ${ofm_ch} --kdim ${kdim} --inp_wl ${inp_wl} --wgt_wl ${wgt_wl} --out_wl ${out_wl} --simd ${simd} --pe ${pe}
if [ $? -eq 0 ]; then
    echo "Weight generation successfull"
else
    echo "Weight generation failed"
    exit 0
fi


cd $MVAU_RTL_ROOT/proj/sim
echo "Generating parameter file"
python gen_mvau_defn.py --ifm_ch ${ifm_ch} --ifm_dim ${ifm_dim} --ofm_ch ${ofm_ch} --kdim ${kdim} --inp_wl ${inp_wl} --inp_bin ${inp_bin} --wgt_wl ${wgt_wl} --wgt_bin ${wgt_bin} --out_wl ${out_wl} --simd ${simd} --pe ${pe} --mmv ${mmv}
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
echo "Running simulation"
DO_GUI="gui"
if [ "$1" == "$DO_GUI" ]; then
    xelab -prj mvau_files.prj -s run_mvau_v1 work.mvau_tb_v1 --debug all
    if [ $? -eq 0 ]; then
	echo "RTL files compilation successfull"
    else
	echo "RTL files compilation failed"
	exit 0
    fi
    xsim run_mvau_v1 -gui -wdb mvau_tb_v1.wdb -t mvau_xsim_gui.tcl --sv_seed $RANDOM
else
    xelab -prj mvau_files.prj -s run_mvau_v1 work.mvau_tb_v1
    if [ $? -eq 0 ]; then
	echo "RTL files compilation successfull"
    else
	echo "RTL files compilation failed"
	exit 0
    fi
    xsim run_mvau_v1 -t mvau_xsim.tcl --sv_seed $RANDOM
fi
exit 1

#!/bin/bash
rm -rf mvau_tb_v1.wdb
make clean
echo "Generating parameter file"
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
python gen_mvau_defn.py --ifm_ch ${ifm_ch} --ifm_dim ${ifm_dim} --ofm_ch ${ofm_ch} --kdim ${kdim} --inp_wl ${inp_wl} --inp_bin ${inp_bin} --wgt_wl ${wgt_wl} --wgt_bin ${wgt_bin} --out_wl ${out_wl} --simd ${simd} --pe ${pe}
echo "Generating MVAU weight files"
python gen_mvau_weight_mem_merged.py --pe ${pe}
for((p=0; p<${pe}; p++))
do
    python gen_mvau_weight_mem.py --wmem_id ${p}
done
cd $MVAU_RTL_ROOT/proj/sim
echo "Generating Project file for simulation"
python gen_mvau_files.py --pe ${pe}
cd $FINN_HLS_ROOT/tb
echo "Generating weights"
python gen_weights_fn.py --ifm_ch ${ifm_ch} --ifm_dim ${ifm_dim} --ofm_ch ${ofm_ch} --kdim ${kdim} --inp_wl ${inp_wl} --wgt_wl ${wgt_wl} --out_wl ${out_wl} --simd ${simd} --pe ${pe}
echo "Running simulation"
cd $MVAU_RTL_ROOT/proj/sim
DO_GUI="gui"
if [ "$1" == "$DO_GUI" ]; then
    xelab -prj mvau_files.prj -s run_mvau_v1 work.mvau_tb_v1 --debug all
    if [ $? -eq 0 ]; then
	echo "RTL files compilation successfull"
    else
	echo "RTL files compilation failed"
	exit 0
    fi
    xsim run_mvau_v1 -gui -wdb mvau_tb_v1.wdb -view mvau_tb_v1.wcfg -t mvau_xsim.tcl
else
    xelab -prj mvau_files.prj -s run_mvau_v1 work.mvau_tb_v1
    if [ $? -eq 0 ]; then
	echo "RTL files compilation successfull"
    else
	echo "RTL files compilation failed"
	exit 0
    fi
    xsim run_mvau_v1 -t mvau_xsim.tcl 
fi
exit 1

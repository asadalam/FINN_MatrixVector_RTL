import numpy as np
import argparse
import os
import sys
import subprocess
import pandas as pd
import time
from openpyxl.utils import get_column_letter
import argparse
from signal import signal, SIGINT
from math import ceil, log2

### Class defining the handler to capture Ctrl+C
class MyHandler:
    def __init__(self, rpt_dict, rpt_col_names, config_dict, config_col_names, out_file):
        self.rpt_dict = rpt_dict
        self.rpt_col_names = rpt_col_names
        self.config_dict = config_dict
        self.config_col_names = config_col_names
        self.out_file = out_file
    def __call__(self, signo, frame):
        print('SIGINT or CTRL-C detected, exiting gracefully by writing to output')
        write_rpt_file(self.rpt_dict, self.rpt_col_names, self.config_dict,
                       self.config_col_names, self.out_file)
        exit(0)
        
def write_rpt_file(rpt_dict, rpt_col_names, config_dict, config_col_names, out_file):
    try:
        print("Writing the results to an Excel file")
        clen = len(rpt_col_names)//2
        for i in np.arange(clen):
            rpt_col_names.append("%")        
        writer = pd.ExcelWriter(out_file,mode='w')
        df=pd.DataFrame.from_dict(rpt_dict, orient='index', columns=rpt_col_names)        
        sheet_name = 'HLS v RTL'
        df.to_excel(writer, sheet_name=sheet_name)
        worksheet=writer.sheets[sheet_name]
        worksheet.column_dimensions['A'].width = 24
        for i,col in enumerate(df.columns[0:clen*2]):
            # find length of column i
            col_len = df[col].astype(str).str.len().max()
            # Setting the length if the column header is larger
            # than the max column value length
            col_len = max(col_len,len(col))+4
            col_let = get_column_letter(i+2)
            # set the column length
            worksheet.column_dimensions[col_let].width=col_len
        
        df=pd.DataFrame.from_dict(config_dict, orient='index', columns=config_col_names)
        sheet_name = "Config Set"
        df.to_excel(writer, sheet_name=sheet_name)
        writer.save()
    except:
        print("Cannot write to Excel output file")
        raise
    return 0


def extract_hls_data(log_file,param):
    block = []
    tp = 0
    try:
        print("Extracting data from HLS log file")
        ### Going through each parameter for which data to be captured
        with open(log_file) as log_line:
            for line in log_line:
                for p in param:
                    if p in line:
                        block.append(int(float(line.split()[1])))
                if "CP achieved post-synthesis" in line:
                    tp = round((float(line.split()[-1]))*10**3)/10**3                    

        return block, tp
    
    except:
        print("Cannot read the HLS reports file")
        raise
        exit(1)

def extract_rtl_block_data(log_file,param):
    block = []
    try:
        print("Extracting data from RTL utilization report")
        ### Going through each parameter for which data to be captured
        for p in param:
            with open(log_file) as log_line:
                for line in log_line:
                    line = line.rstrip()
                    if p in line:
                        if(len(line.split("|")) > 1):
                            block.append(int(float(line.split("|")[2])))

        return block
    
    except:
        print("Cannot read the RTL utilization report")
        raise
        exit(1)

def extract_rtl_timing_data(log_file, clk_per):
    tp = 0
    try:
        print("Extracting data from RTL timing report")

        with open(log_file) as log_line:
            tp = float(log_line.read().rsplit()[-1])

        return round((clk_per-tp)*10**3)/10**3
    except:
        print("Cannot read the RTL timing report")
        raise
    
def extract_hls_latency(log_file):
    lat = 0
    try:
        print("Extracting latency information from HLS run")
        with open(log_file) as log_line:
            for line in log_line:
                if "Verilog" in line:
                    lat = line.replace(' ', '').split("|")[7]
        return int(float(lat))
    except:
        print("Cannot read the HLS latency report file")
        raise

def extract_rtl_latency(log_file):
    lat = 0
    try:
        print("Extracting latency information from RTL run")
        with open(log_file) as log_line:
            for line in log_line:
                lat = int(float(line.replace(' ','')))
        return lat
    except:
        print("Cannot read the RTL latency report file")
        raise

def extract_rtl_exec(log_file):
    exec_time = 0
    try:
        print("Extracting execution time information from RTL run")
        with open(log_file) as log_line:
            for line in log_line:
                exec_time = float(line.replace(' ',''))
        return exec_time
    except:
        print("Cannot read the RTL synthesis execution time file")
        raise

def extract_hls_exec(log_file):
    exec_time = 0
    try:
        print("Extracting execution time information from HLS run")
        with open(log_file) as log_line:
            for line in log_line:
                exec_time = float(line.replace(' ',''))
        return exec_time
    except:
        print("Cannot read the HLS synthesis execution time file")
        raise

def calc_savings(hls_lst, rtl_lst):
    sv_lst = []
    for sv in zip(hls_lst,rtl_lst):
        if(sv[0] == 0 or sv[1] == 0):
            sv_lst.append(0)
        else:
            sv_lst.append(round(((sv[0] - sv[1])/sv[0]*100)*10**2)/10**2)
    return sv_lst

def extract_data(hls_run, rtl_run, clk_per, finn_tb, mvau_env):
    # Directory from where HLS reports to be read
    hls_syn_dir = hls_run.replace("_","-")
    hls_dir = finn_tb+"/hls-syn-"+hls_syn_dir+"/sol1/impl/report/verilog/"
    # Constructing HLS report filename
    hls_logfile = hls_dir+"Testbench_"+hls_run+"_export.rpt"
    # Constructing HLS latency report filename
    hls_latfile = finn_tb+"/hls-syn-"+hls_syn_dir+"/sol1/sim/report/Testbench_"+hls_run+"_cosim.rpt"
    hls_execfile = finn_tb+"/hls_exec.rpt"
    
    # Directory from where RTL reports to be read
    rtl_dir = mvau_env+"/proj/syn/"+rtl_run+"_project/"
    # Constructing RTL reports filename
    rtl_utilfile = rtl_dir+"post_opt_util.rpt"
    rtl_timefile = rtl_dir+"post_opt_timing.rpt"
    rtl_latfile = mvau_env+"/proj/sim/latency.txt"
    rtl_execfile = mvau_env+"/proj/syn/rtl_exec.rpt"
    
    # Parameters for which HLS data needs to be extracted
    hls_param = ["LUT","FF","DSP","BRAM"]
    # Extracting data from HLS report file (generated by RTL export)
    hls_block, hls_tp = extract_hls_data(hls_logfile,hls_param)
    # Extracting latency data from HLS
    hls_latency = extract_hls_latency(hls_latfile)
    # Extracting HLS execution time (only synthesis)
    hls_exec = extract_hls_exec(hls_execfile)

    # Parameters for which RTL data needs to be extracted
    rtl_param = ["CLB LUTs","CLB Registers","DSPs","Block RAM Tile"]
    # Extracting data from RTL utilization report file
    rtl_block = extract_rtl_block_data(rtl_utilfile,rtl_param)
    # Extracting data from RTL timing report file
    rtl_tp = extract_rtl_timing_data(rtl_timefile,clk_per)
    # Extractomg data from RTL latency report file
    rtl_latency = extract_rtl_latency(rtl_latfile)
    # Extracting RTL execution time (only synthesis)
    rtl_exec = extract_rtl_exec(rtl_execfile)

    ### Creating lists of performance data
    hls_lst = hls_block + [hls_tp] + [hls_latency] + [hls_exec]
    rtl_lst = rtl_block + [rtl_tp] + [rtl_latency] + [rtl_exec]
    sv_lst = calc_savings(hls_lst, rtl_lst)
    pd_lst = hls_lst + rtl_lst + sv_lst

    return pd_lst

def main(kdim_arr, ifm_ch_arr, ofm_ch_arr, ifm_dim_arr,
         inp_wl_arr, wgt_wl_arr, simd, pe,
         finn_tb, mvau_env, mvau_tb, out_file):
    config_col_names = ["IFM_Ch","IFM_Dim", "OFM_Ch", "KDim","Inp_Act","Wgt_Prec","Out_Act","SIMD","PE"]
    rpt_col_names = ["HLS LUT", "HLS FF", "HLS DSPs", "HLS BRAM", "HLS Time", "HLS Latency", "HLS Exec. Time",
                     "RTL LUT", "RTL FF", "RTL DSPs", "RTL BRAM", "RTL Time", "RTL Latency", "RTL Exec. Time"]
    config_set = 0
    config_dict = dict()
    rpt_dict = dict()
    success = 0 ### A non-zero value indicates at least one run is successful

    ### Handling Ctrl+C gracefully
    signal(SIGINT, MyHandler(rpt_dict, rpt_col_names, config_dict, config_col_names, out_file))                    
        
    for ifm_ch, ifm_dim, ofm_ch in zip(ifm_ch_arr, ifm_dim_arr, ofm_ch_arr):
        for kdim in kdim_arr:
            ### Skipping if kdim>ifm_dim
            if(kdim > ifm_dim):
                continue
            for inp_wl, wgt_wl in zip(inp_wl_arr, wgt_wl_arr):
                out_wl = min(16,inp_wl+wgt_wl+ceil(log2(kdim*kdim*ifm_ch)))
                for s,p in zip(simd, pe):
                    ### Skipping this config set when ifm channel is not an integer multiple of SIMD
                    if(ifm_ch%s!=0 or s>ifm_ch):
                        continue
                    ### Skipping this config set when ofm channel is not an integer multiple of PE
                    if(ofm_ch%p!=0 or p>ofm_ch):
                        continue                    
                    ### Preparing a dict to write to a file with config details
                    config_dict_key = str(config_set)
                    config_dict[config_dict_key] = [ifm_ch, ifm_dim, ofm_ch, kdim, inp_wl, wgt_wl, out_wl, s, p]
                    print("#######################################")
                    print(f'### MVAU Batch Configuration Set: {config_set}')
                    print(f'### IFM Channels: {ifm_ch}')
                    print(f'### IFM Dimensions: {ifm_dim}')
                    print(f'### OFM Channels: {ofm_ch}')
                    print(f'### Kernel Dimensions: {kdim}')
                    print(f'### Input precision: {inp_wl}')
                    print(f'### Weight precision: {wgt_wl}')
                    print(f'### Output precision: {out_wl}')
                    print(f'### SIMD: {s}')
                    print(f'### PE: {p}')                    
                    if(inp_wl == 1 and wgt_wl == 1): ### XNOR
                        print(f'### SIMD: XNOR')
                        print("#######################################")
                        ### Calling the HLS test script
                        sp = subprocess.call(['./test_mvau_xnor.sh',
                                              str(ifm_ch), str(ifm_dim), str(ofm_ch), str(kdim),
                                              str(inp_wl), str(wgt_wl), str(out_wl), str(s), str(p)],
                                             cwd = finn_tb)
                        if(sp!=1):
                            print("HLS XNOR Test Failed")
                            if(success==1):
                                write_rpt_file(rpt_dict, rpt_col_names, config_dict, config_col_names, out_file)
                            sys.exit(1)
                        ### Calling the RTL test script
                        sp = subprocess.call(['./test_mvau_xnor_rtl.sh',
                                              str(ifm_ch), str(ifm_dim), str(ofm_ch), str(kdim),
                                              str(inp_wl), str(1), str(wgt_wl), str(1), str(out_wl),
                                              str(s), str(p)],
                                             cwd = mvau_tb)                                            
                        if(sp!=1):
                            print("RTL XNOR Test Failed")
                            if(success==1):
                                write_rpt_file(rpt_dict, rpt_col_names, config_dict, config_col_names, out_file)
                            sys.exit(1)
                        success = 1 ### Run successfull
                        ### Extracting results    
                        rpt_dict_key = "Config set: "+str(config_set)+" (XNOR)"
                        rpt_lst = extract_data('mvau_xnor','mvau',
                                               5.0, finn_tb, mvau_env)
                        rpt_dict[rpt_dict_key] = rpt_lst
                    elif(wgt_wl == 1):
                        print(f'### SIMD: Binary Weights')
                        print("#######################################")
                        ### Calling the HLS test script
                        sp = subprocess.call(['./test_mvau_binwgt.sh',
                                              str(ifm_ch), str(ifm_dim), str(ofm_ch), str(kdim),
                                              str(inp_wl), str(wgt_wl), str(out_wl), str(s), str(p)],
                                             cwd = finn_tb)
                        if(sp!=1):
                            print("HLS Binary Weight Test Failed")
                            if(success==1):
                                write_rpt_file(rpt_dict, rpt_col_names, config_dict, config_col_names, out_file)
                            sys.exit(1)
                        ### Calling the RTL test script
                        sp = subprocess.call(['./test_mvau_binwgt_rtl.sh',
                                              str(ifm_ch), str(ifm_dim), str(ofm_ch), str(kdim),
                                              str(inp_wl), str(0), str(wgt_wl), str(1), str(out_wl),
                                              str(s), str(p)],
                                             cwd = mvau_tb)
                        if(sp!=1):
                            print("RTL Binary Weight Test Failed")
                            if(success==1):
                                write_rpt_file(rpt_dict, rpt_col_names, config_dict, config_col_names, out_file)
                            sys.exit(1)
                        success = 1 ### Run successfull
                        ### Extracting results
                        rpt_dict_key = "Config set: "+str(config_set)+" (BIN WGT)"
                        rpt_lst = extract_data('mvau_binwgt','mvau',
                                               5.0, finn_tb, mvau_env)
                        rpt_dict[rpt_dict_key] = rpt_lst
                    else:
                        print(f'### SIMD: Standard')
                        print("#######################################")
                        ### Calling the HLS test script
                        sp = subprocess.call(['./test_mvau_std.sh',
                                              str(ifm_ch), str(ifm_dim), str(ofm_ch), str(kdim),
                                              str(inp_wl), str(wgt_wl), str(out_wl), str(s), str(p)],
                                             cwd = finn_tb)
                        if(sp!=1):
                            print("HLS Standard Test Failed")
                            if(success==1):
                                write_rpt_file(rpt_dict, rpt_col_names, config_dict, config_col_names, out_file)
                            sys.exit(1)
                        ### Calling the RTL test script
                        sp = subprocess.call(['./test_mvau_std_rtl.sh',
                                              str(ifm_ch), str(ifm_dim), str(ofm_ch), str(kdim),
                                              str(inp_wl), str(0), str(wgt_wl), str(0), str(out_wl),
                                              str(s), str(p)],
                                             cwd = mvau_tb)
                        if(sp!=1):
                            print("RTL Standard Test Failed")
                            if(success==1):
                                write_rpt_file(rpt_dict, rpt_col_names, config_dict, config_col_names, out_file)
                            sys.exit(1)
                        success = 1 ### Run successfull
                        ### Extracting results
                        rpt_dict_key = "Config set: "+str(config_set)+" (STD)"
                        rpt_lst = extract_data('mvau_std','mvau',
                                               5.0, finn_tb, mvau_env)
                        rpt_dict[rpt_dict_key] = rpt_lst
                        
                    print(f'"RTL and Synthesis complete for config set: {config_set}"')
                    config_set = config_set + 1
                    
    write_rpt_file(rpt_dict, rpt_col_names, config_dict, config_col_names, out_file)
    return 0

def parser():
    parser = argparse.ArgumentParser(description='Python data script for regression test for FINN HLS and RTL implementation')
    parser.add_argument('-o','--out_file',default="mvau_report.xlsx",
			help="Output file")
    return parser

if __name__ == '__main__':

    kdim_arr    = np.array([4])
    ### Keep the length of the following three arrays same
    ifm_ch_arr  = np.array([4])
    ofm_ch_arr  = np.array([4])
    ifm_dim_arr = np.array([4])
    
    ### Keep the length of the following two arrays same
    inp_wl_arr  = np.array([4])
    wgt_wl_arr  = np.array([4])

    ### Keep the length of the following two arrays same
    simd = np.array([4])
    pe = np.array([4])
    
    args = parser().parse_args()
    out_file = args.out_file    
    
    mvau_env = os.environ.get('MVAU_RTL_ROOT')
    mvau_tb = mvau_env+'/proj/RegressionTests'
    finn_env = os.environ.get('FINN_HLS_ROOT')
    finn_tb = finn_env+'/tb/'

    main(kdim_arr, ifm_ch_arr, ofm_ch_arr, ifm_dim_arr, inp_wl_arr,
         wgt_wl_arr, simd, pe, finn_tb, mvau_env, mvau_tb, out_file)

    sys.exit(0)

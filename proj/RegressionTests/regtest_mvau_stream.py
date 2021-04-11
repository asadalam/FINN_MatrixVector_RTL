import numpy as np
import argparse
import os
import sys
import subprocess
import pandas as pd

def write_config_file(config_dict, col_names, fname):
    try:
        print("Writing the configuration set")
        df = pd.DataFrame.from_dict(config_dict, orient='index', columns=col_names)
        df.to_csv(fname,index=False)
    except:
        print("Cannot write the configuration set")
        raise
    return 0

def main(kdim_arr, ifm_ch_arr, ofm_ch_arr, ifm_dim_arr, inp_wl_arr, out_wl_arr, wgt_wl_arr, simd, pe, finn_tb):
    config_col_names = ["Parameter #", "IFM_Ch","IFM_Dim", "OFM_Ch", "KDim","Inp_Act","Wgt_Prec","Out_Act","SIMD","PE"]
    config_set = 0
    config_dict = dict()
    for ifm_ch in ifm_ch_arr:
        for ifm_dim in ifm_dim_arr:
            for ofm_ch in ofm_ch_arr:
                for kdim in kdim_arr:
                    for inp_wl in inp_wl_arr:
                        for wgt_wl in wgt_wl_arr:
                            for out_wl in out_wl_arr:
                                for s in simd:
                                    ### Skipping this config set when ifm channel is an integer multiple of SIMD
                                    if(ifm_ch%s!=0 or s>ifm_ch):
                                        continue
                                    for p in pe:
                                        ### Skipping this config set when ofm channel is an integer multiple of PE
                                        if(ofm_ch%p!=0 or p>ofm_ch):
                                            continue
                                        ### Preparing a dict to write to a file with config details
                                        dict_key = str(config_set)
                                        config_dict[dict_key] = [config_set, ifm_ch, ifm_dim, ofm_ch, kdim, inp_wl, wgt_wl, out_wl, s, p]
                                        print(config_dict[dict_key])
                                        config_set = config_set + 1
                                        ### Calling the test scripts in FINN_HLS_ROOT/tb directory
                                        # if(inp_wl == 1 and wgt_wl == 1):
                                        #     s = subprocess.call(['./test_mvau_stream-xnor.sh',
                                        #                          str(ifm_ch), str(ifm_dim), str(ofm_ch), str(kdim),
                                        #                          str(inp_wl), str(wgt_wl), str(out_wl), str(s), str(p)],
                                        #                         cwd = finn_tb)
                                        # elif(wgt_wl == 1):
                                        #     s = subprocess.call(['./test_mvau_stream-binwgt.sh',
                                        #                          str(ifm_ch), str(ifm_dim), str(ofm_ch), str(kdim),
                                        #                          str(inp_wl), str(wgt_wl), str(out_wl), str(s), str(p)],
                                        #                         cwd = finn_tb)
                                        # else:
                                        #     s = subprocess.call(['./test_mvau_stream-std.sh',
                                        #                          str(ifm_ch), str(ifm_dim), str(ofm_ch), str(kdim),
                                        #                          str(inp_wl), str(wgt_wl), str(out_wl), str(s), str(p)],
                                        #                         cwd = finn_tb)

    write_config_file(config_dict, config_col_names, "mvau_stream_configset.csv")

    return 0

if __name__ == '__main__':

    kdim_arr    = np.array(np.arange(2,3))#7))
    ifm_ch_arr  = np.array(np.arange(2,3))#7))
    ofm_ch_arr  = np.array(np.arange(2,3))#7))
    ifm_dim_arr = np.array(np.arange(2,3))#7))
    inp_wl_arr  = np.array(np.arange(1,2))#9))
    out_wl_arr  = np.array(np.arange(1,2))#17))
    wgt_wl_arr  = np.array(np.arange(1,2))#9))
    
    simd = np.array(np.arange(1,10))
    pe = np.array(np.arange(1,10))

    os.environ['MVAU_RTL_ROOT'] = '~/workspace/TCD_workspace/Xilinx_mvau/'
    mvau_env = os.environ.get('MVAU_RTL_ROOT')
    os.environ['FINN_HLS_ROOT'] = mvau_env+'proj/finn-hlslib/'
    finn_env = os.environ.get('FINN_HLS_ROOT')
    finn_tb = finn_env+'tb/'

    main(kdim_arr, ifm_ch_arr, ofm_ch_arr, ifm_dim_arr, inp_wl_arr, out_wl_arr, wgt_wl_arr, simd, pe, finn_tb)

    sys.exit(0)

                                        

    

﻿NDSummary.OnToolTipsLoaded("File4:regtest_mvau_batch2.py",{91:"<div class=\"NDToolTip TFile LPython\"><div class=\"TTSummary\">Author(s): Syed Asad Alam syed&#46;as<span style=\"display: none\">[xxx]</span>ad&#46;alam<span>&#64;</span>tcd<span style=\"display: none\">[xxx]</span>&#46;ie</div></div>",92:"<div class=\"NDToolTip TClass LPython\"><div class=\"TTSummary\">Handles unexpected termination or explicit termination by Ctrl+C by calling the write_rpt_file function to write whatever data has been extracted so far</div></div>",94:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype94\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> __init__(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">self,</td></tr><tr><td class=\"PName first last\">rpt_dict,</td></tr><tr><td class=\"PName first last\">rpt_col_names,</td></tr><tr><td class=\"PName first last\">config_dict,</td></tr><tr><td class=\"PName first last\">config_col_names,</td></tr><tr><td class=\"PName first last\">out_file</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">The construction initializes the attributes with corresponding input parameters</div></div>",95:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype95\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> __call__(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">self,</td></tr><tr><td class=\"PName first last\">signo,</td></tr><tr><td class=\"PName first last\">frame</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">This method is called when the unexpected termination takes place and calls the write_rpt_file function to dump all extracted data to an output file</div></div>",96:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype96\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> write_rpt_file(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">rpt_dict,</td></tr><tr><td class=\"PName first last\">rpt_col_names,</td></tr><tr><td class=\"PName first last\">config_dict,</td></tr><tr><td class=\"PName first last\">config_col_names,</td></tr><tr><td class=\"PName first last\">out_file</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">This function takes in the performance numbers as dictionary along with configurations as a dictionariy and writes to an excel file</div></div>",97:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype97\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> extract_hls_data(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">log_file,</td></tr><tr><td class=\"PName first last\">param</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">This function extracts performance data from HLS simulation and synthesis</div></div>",98:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype98\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> extract_rtl_block_data(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">log_file,</td></tr><tr><td class=\"PName first last\">param</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">This function extracts performance data from RTL simulation and synthesis</div></div>",99:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype99\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> extract_rtl_timing_data(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">log_file,</td></tr><tr><td class=\"PName first last\">clk_per</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">This function extracts timing information for RTL synthesis</div></div>",100:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype100\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> extract_hls_latency(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">log_file</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">This function extracts the latency of an HLS simulation</div></div>",101:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype101\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> extract_rtl_latency(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">log_file</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">This function extracts the latency of an RTL simulation</div></div>",102:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype102\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> extract_rtl_exec(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">log_file</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">This function extracts the total execution time of HLS simulation and synthesis</div></div>",103:"<div class=\"NDToolTip TFunction LPython\"><div class=\"TTSummary\">This function extracts the total execution time of RTL simulation and synthesis</div></div>",104:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype104\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> calc_savings(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">hls_lst,</td></tr><tr><td class=\"PName first last\">rtl_lst</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">This function calculates the difference between RTL and HLS performance measures</div></div>",105:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype105\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> extract_data(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">hls_run,</td></tr><tr><td class=\"PName first last\">rtl_run,</td></tr><tr><td class=\"PName first last\">clk_per,</td></tr><tr><td class=\"PName first last\">finn_tb,</td></tr><tr><td class=\"PName first last\">mvau_env</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">This function calls all of the above extraction function and combines them in one place for further processing. It defines all the paths where the various log files are present and defines the parameter against which the performance numbers are to be extracted</div></div>",106:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype106\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">def</span> main(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first last\">kdim_arr,</td></tr><tr><td class=\"PName first last\">ifm_ch_arr,</td></tr><tr><td class=\"PName first last\">ofm_ch_arr,</td></tr><tr><td class=\"PName first last\">ifm_dim_arr,</td></tr><tr><td class=\"PName first last\">inp_wl_arr,</td></tr><tr><td class=\"PName first last\">inp_wl_sgn,</td></tr><tr><td class=\"PName first last\">wgt_wl_arr,</td></tr><tr><td class=\"PName first last\">wgt_wl_sgn,</td></tr><tr><td class=\"PName first last\">simd,</td></tr><tr><td class=\"PName first last\">pe,</td></tr><tr><td class=\"PName first last\">finn_tb,</td></tr><tr><td class=\"PName first last\">mvau_env,</td></tr><tr><td class=\"PName first last\">mvau_tb,</td></tr><tr><td class=\"PName first last\">out_file</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">The main top level function which defines the parameters to be evaluated, configures the column names for the Excel output file, handles unexpected events, and runs the regression tests for various configuration parameters. After running HLS and RTL tests, it calls the extract_data function to do the main data extraction and then calls a function to write to the output Excel file</div></div>",107:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype107\" class=\"NDPrototype\"><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">def</span> parser()</div></div><div class=\"TTSummary\">This function defines an ArgumentParser object for command line arguments</div></div>",108:"<div class=\"NDToolTip TFunction LPython\"><div id=\"NDPrototype108\" class=\"NDPrototype\"><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">if</span> __name__ == <span class=\"SHString\">\'__main__\'</span></div></div><div class=\"TTSummary\">Entry point of the file, retrieves the command line argument, defines different parameters and environment variables and calls the main function to run the regression tests</div></div>"});
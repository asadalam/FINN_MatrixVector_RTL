# Matrix Vector Activation Unit 

Repository for the RTL implementation of matrix-vector activation unit in collaboration with Xilinx research labs in Dublin, Ireland.

The repository is organized as follows:
### Document Folder (Doc):
  - This folder contains documentation related to the project
  - To fetch GitHub pages which hosts the automatic documentation generated by Natural Docs, run
  ```
  git clone https://github.com/asadalam/Xilinx_mvau.git -b gh-pages
  ```
  - The web page containing documentation is available at
  ```
  https://asadalam.github.io/FINN_MatrixVector_RTL/
  ```
### Project Folder (proj):
Project folder, contains the following sub-folders
  - Source Folder (`src`): All source code
  - Simulation Folder (`sim`): Files related to simulation like test benches
  - Synthesis Folder (`syn`) - Files related to synthesis
  - FINN HLS Library Folder (`finn-hlslib`) - Forked repository of Xilinx HLS Library added as a submodule
  - IP Repository Folder (`ip_repo`) - Folder to keep all files related to IP
  - Regression Test Folder (`RegressionTests`) - Files to run automated regression test including functional simulation and synthesis of RTL and HLS along with data gathering

## Environmental Variables
In order to run simulation and synthesis, set the following two environmental variables
  - `FINN_HLS_ROOT`: `Xilinx_mvau/proj/finn-hlslib`
  - `MVAU_RTL_ROOT`: `Xilinx_mvau`

## Cloning the Repo and Adding FINN HLSLIB as Sub-Module
To clone the repository, say:
```
git clone https://github.com/asadalam/Xilinx_mvau.git
```

The Xilinx FINN HLS library has been forked separately and added as a sub-module to this repository. When the repo is cloned, the FINN repository is empty. To populate it say:
```
git submodule update --init
```
to populate Xilinx_mvau/proj/finn-hlslib directory

### Updating Sub-Module after edits
If any change is made in the FINN HLS library, the changes are reflected in the main fork and the local repository but the submodule itself is not updated. To update the submodule so that changes are visible to others say (assuming one is in the FINN HLS directory):
```
cd ../
git submodule update
cd finn-hlslib
git checkout master
cd ../
git commit -am 'submodule updated'
git push
```
This will update the submodule and changes visible to others

## Building RTL and HLS Hardware Design and Analysis
In order to rebuild the hardware designs and compare outputs of RTL and HLS designs, the repo should be cloned to a machine with Vivado Design Suite installed (tested with 2020.1). Follow the following steps:
1. Clone the repository: `git clone https://github.com/asadalam/Xilinx_mvau.git`
2. Populate the FINN HLS library folder (as it is a submodule): `git submodule update --init`
3. Set the environment variables: FINN_HLS_ROOT and MVAU_RTL_ROOT
4. Preferably work in a virtual environment and install python dependencies by saying: `pip install -r requirements.txt` (Verified on Python 3.9.5)
5. Move to `MVAU_RTL_ROOT/proj/RegresssionTests`
6. For testing the MVAU batch unit, open the file `regtest_mvau.py` or for testing the MVAU Stream Unit, open the file `regtest_mvau_stream.py`
7. Make sure that the FPGA being used are same for both RTL and HLS, for consistency purposes. For RTL, the FPGA is defined in `MVAU_RTL_ROOT/proj/syn/mvau_synth.tcl` file, where the synthesis command of `synth_design` is executed with the `-part` argument. For HLS, the FPGA is defined, depending on the type of implementation, in the following three files, where files with `std`, `binwgt` and `xnor` suffix indicates design with >1 bit, 1 bit weight and 1 bit input activation and weight resolution, respectively:
   1. `FINN_HLS_ROOT/tb/test_mvau_std.tcl`
   2. `FINN_HLS_ROOT/tb/test_mvau_binwgt.tcl`
   3. `FINN_HLS_ROOT/tb/test_mvau_xnor.tcl`
9. Define the following parameters in the python script
   1. Kernel dimension (`kdim_arr`)
   2. Number of input feature map channels (`ifm_ch_arr`)
   3. Number of output feature map channels (`ofm_ch_arr`)
   4. Input feature map dimension (`ifm_dim_arr`)
   5. Input activation (`inp_wl_arr`) and weights precision (`wgt_wl_arr`)
   6. Number of PEs (`pe`) and number of SIMD elements per PEs (`simd`)
 7. All parameters are defined as arrays to test for multiple organizations
 8. Arrays definining input feature map channels, output feature map channels and input feature dimensions should preferably have the same length
 9. Arrays defining input and output word length should preferably have the same length
 10. Arrays defining SIMD and PE should preferably have the same length
 11. Run the python script as: `python regtest_mvau.py -o <result_filename>.xlsx` (The same can be done with `regtest_mvau_stream.py`
 12. The excel spreadsheet will list down all configurations run and synthesis results for HLS and RTL for each configuration

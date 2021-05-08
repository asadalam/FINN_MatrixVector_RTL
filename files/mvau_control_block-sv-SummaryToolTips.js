﻿NDSummary.OnToolTipsLoaded("File:mvau_control_block.sv",{245:"<div class=\"NDToolTip TModule LSystemVerilog\"><div class=\"TTSummary\">Author(s): Syed Asad Alam</div></div>",247:"<div class=\"NDToolTip TParameter LSystemVerilog\"><div class=\"TTSummary\">Word length of the NF counter to control reading and writing from the input buffer</div></div>",248:"<div class=\"NDToolTip TParameter LSystemVerilog\"><div class=\"TTSummary\">Address word length of the buffer</div></div>",250:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">To allow reading of weight memory when computation taking place</div></div>",251:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">To enable reading of weight memory when the input buffer is being re-used</div></div>",252:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Control signal for resetting the accumulator and a one bit control signal to indicate when sf_cnt == SF-1</div></div>",253:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Counter to check when a whole weight matrix row has been processed</div></div>",254:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Signal to reset the nf_cnt counter Only used when multiple output channel</div></div>",255:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">A counter to keep track how many weight channels have been processed Only used when multiple output channels</div></div>",257:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">A one bit control signal to indicate when nf_cnt == NF</div></div>",258:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">A counter to keep track when we are done writing to the input buffer so that it can be reused again Similar to the variable nf in mvau.hpp Only used when multiple output channels</div></div>",259:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">A one bit control signal to indicate when sf_cnt == SF-1</div></div>",260:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">A sequential \'always\' block for a counter which keeps track when one row of weight matrix is accessed Only runs when do_mvau is asserted A counter similar to sf in mvau.hpp Only used when multiple output channels</div></div>",261:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Control Logic for generating address for the weight memory</div></div>"});
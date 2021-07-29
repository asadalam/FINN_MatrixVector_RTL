﻿NDSummary.OnToolTipsLoaded("File:mvau_stream/mvau_stream_control_block.sv",{339:"<div class=\"NDToolTip TModule LSystemVerilog\"><div class=\"TTSummary\">Author(s): Syed Asad Alam syed&#46;as<span style=\"display: none\">[xxx]</span>ad&#46;alam<span>&#64;</span>tcd<span style=\"display: none\">[xxx]</span>&#46;ie</div></div>",341:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Internal signal to indicate when input data is active Asserted when input valid and output ready asserted</div></div>",342:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Internal signal to indicate when to perform all computations</div></div>",343:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Internal signal to indicate if sf_cnt has gone full</div></div>",344:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Internal signal to indicate when to start computations after reset</div></div>",345:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Internal signal to halt the computations in case of missing input ready</div></div>",347:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">A sequential \'always\' block for a counter which keeps track when the input buffer is full.&nbsp; Only runs when do_mvau_stream is asserted A counter similar to sf in mvau.hpp</div></div>",348:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Delaying the wait ready signal by one clock signal If the wait_rready signal is asserted for two consecutive clock cycles, need to halt computation</div></div>",350:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Three states: a) IDLE: When no input available or when computation is halted b) WRITE: When writing to the input buffer c) READ: When reading from the input buffer</div></div>",351:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Signal to reset the nf_cnt counter Only used when multiple output channel</div></div>",352:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Signal to indicate when nf_cnt equals zero</div></div>",353:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">A counter to keep track how many weight channels have been processed Only used when multiple output channels</div></div>",354:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Signal to indicate the the nf_cnt has saturated along with sf_cnt</div></div>",356:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Always block to assign the pres_state signal</div></div>",358:"<div class=\"NDToolTip TAlwaysCOMB LSystemVerilog\"><div class=\"TTSummary\">Computing the next state</div></div>",359:"<div class=\"NDToolTip TAlwaysCOMB LSystemVerilog\"><div class=\"TTSummary\">Computing the outputs of the state machine</div></div>",361:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">A one bit control signal to indicate when nf_cnt == NF</div></div>",362:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Remains one when the input buffer is being filled Resets to Zero the input buffer is filled and ready to be reused</div></div>",363:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">A counter to keep track when we are done writing to the input buffer so that it can be reused again Similar to the variable nf in mvau.hpp Only used when multiple output channels</div></div>",364:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">A sequential \'always\' block for a counter which keeps track when the input buffer is full.&nbsp; Only runs when do_mvau_stream is asserted A counter similar to sf in mvau.hpp</div></div>",365:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Always block for indicating when the system comes out of reset</div></div>",366:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">A one bit control signal to indicate when sf_cnt == SF-1</div></div>"});
﻿NDSummary.OnToolTipsLoaded("File:mvau_stream/mvau_stream.sv",{542:"<div class=\"NDToolTip TModule LSystemVerilog\"><div class=\"TTSummary\">Author(s): Syed Asad Alam syed&#46;as<span style=\"display: none\">[xxx]</span>ad&#46;alam<span>&#64;</span>tcd<span style=\"display: none\">[xxx]</span>&#46;ie</div></div>",544:"<div class=\"NDToolTip TParameter LSystemVerilog\"><div class=\"TTSummary\">Number of vertical matrix chunks to be processed in parallel by one PE</div></div>",545:"<div class=\"NDToolTip TParameter LSystemVerilog\"><div class=\"TTSummary\">Number of horizontal matrix chunks to be processed by PEs in parallel</div></div>",546:"<div class=\"NDToolTip TParameter LSystemVerilog\"><div class=\"TTSummary\">Address word length of the buffer</div></div>",547:"<div class=\"NDToolTip TParameter LSystemVerilog\"><div class=\"TTSummary\">Word length of the NF counter to control reading and writing from the input buffer</div></div>",549:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Input activation stream synchronized to clock</div></div>",550:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Streaming weight tile synchronized to clock</div></div>",551:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Read enable for the input buffer</div></div>",552:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Resets the accumulator as well the sf_cnt</div></div>",553:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Holds the output from parallel PEs</div></div>",554:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Output valid signal from each PE</div></div>",555:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Controls how long the MVAU operation continues Case 1: NF=1 =&gt; do_mvau_stream = in_v (input buffer not reused) Case 2: NF&gt;1 =&gt; do_mvau_stream = in_v | (~(nf_clr&amp;sf_clr)) (input buffer reused)</div></div>",556:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Copy of input weight stream with packed and&nbsp; unpacked dimension</div></div>",557:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Indicates that the design is waiting for ready after valid is asserted</div></div>",559:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Registered signal indicating when to perform the Matrix vector multiplication Dependent on valids and readys</div></div>",560:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Register the input weight stream Only when the stream unit is the top level unit</div></div>",561:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Indicates if after assertion of output valid, input ready is not asserted to read the output Helps in pausing all computations until the output is consumed</div></div>",563:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Counter keeping track of SF and also address to input buffer One bit in case SF=1 log2(SF) bits otherwise</div></div>",565:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Saving the 2nd PE valid if it comes before previous output consumed by the slave interface</div></div>",566:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Saving the 2nd PE output if it comes before previous output consumed by the slave interface</div></div>",567:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Registering the output activation stream Three cases a) Hold output if input ready not asserted b) Read PE output c) Read the saved PE output</div></div>",568:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Registering the output activation stream valid signal Asserted when either there is an ouptut asserted by the PEs or an output held due to non-consumption When output is consumed, as shown by an asserted ready input signal, output valid is deasserted</div></div>"});
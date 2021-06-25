﻿NDSummary.OnToolTipsLoaded("File:mvau_stream/mvau_stream.sv",{255:"<div class=\"NDToolTip TModule LSystemVerilog\"><div class=\"TTSummary\">Author(s): Syed Asad Alam syed&#46;as<span style=\"display: none\">[xxx]</span>ad&#46;alam<span>&#64;</span>tcd<span style=\"display: none\">[xxx]</span>&#46;ie</div></div>",257:"<div class=\"NDToolTip TParameter LSystemVerilog\"><div class=\"TTSummary\">Number of vertical matrix chunks to be processed in parallel by one PE</div></div>",258:"<div class=\"NDToolTip TParameter LSystemVerilog\"><div class=\"TTSummary\">Number of horizontal matrix chunks to be processed by PEs in parallel</div></div>",259:"<div class=\"NDToolTip TParameter LSystemVerilog\"><div class=\"TTSummary\">Address word length of the buffer</div></div>",261:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Input valid synchronized to clock</div></div>",262:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Input activation stream synchronized to clock</div></div>",263:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Streaming weight tile synchronized to clock</div></div>",264:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Read enable for the input buffer</div></div>",265:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Resets the accumulator as well the sf_cnt</div></div>",266:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Counter keeping track of SF and also address to input buffer</div></div>",267:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Holds the output from parallel PEs</div></div>",268:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Output valid signal from each PE</div></div>",269:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Controls how long the MVAU operation continues Case 1: NF=1 =&gt; do_mvau_stream = in_v (input buffer not reused) Case 2: NF&gt;1 =&gt; do_mvau_stream = in_v | (~(nf_clr&amp;sf_clr)) (input buffer reused)</div></div>",270:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">Copy of input weight stream with packed and&nbsp; unpacked dimension</div></div>",273:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Registered signal indicating when to perform the Matrix vector multiplication Dependent on valids and readys</div></div>",274:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Register the input weight stream</div></div>",275:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Registering the output activation stream</div></div>",276:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Registering the output activation stream valid signal</div></div>"});
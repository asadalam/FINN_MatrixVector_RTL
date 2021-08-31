﻿NDSummary.OnToolTipsLoaded("File:mvau_stream/mvu_pe/mvu_pe_acc.sv",{419:"<div class=\"NDToolTip TModule LSystemVerilog\"><div class=\"TTSummary\">Author(s): Syed Asad Alam syed&#46;as<span style=\"display: none\">[xxx]</span>ad&#46;alam<span>&#64;</span>tcd<span style=\"display: none\">[xxx]</span>&#46;ie</div></div>",421:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">A two bit signal to delay the sf_clr input by two clock cycles</div></div>",422:"<div class=\"NDToolTip TSignal LSystemVerilog\"><div class=\"TTSummary\">One bit signal to delay a control input by one clock cycle</div></div>",424:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">out_acc_v is a copy of the sf_clr_dly[1] because that is the time we reach the last cycle of accumulation</div></div>",425:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Registering the do_mvau_stream_reg signal</div></div>",426:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Sequential \'always\' block to delay sf_clr for two clock cycles to match the two pipelines one after SIMD\'s and one after the adders</div></div>",427:"<div class=\"NDToolTip TAlwaysFF LSystemVerilog\"><div class=\"TTSummary\">Sequential \'always\' block to perform accumulation The accumulator is cleared the sf_clr_dly[1] is asserted</div></div>"});
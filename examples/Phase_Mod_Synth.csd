<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 --midi-velocity=5
</CsOptions>
<CsInstruments>

; Make sure CsOptions are not ignored in the preferences,
; Otherwise Realtime MIDI input will not work.

sr = 44100
ksmps = 256
nchnls = 2
0dbfs = 1

instr 1
;icps cpsmidi
icps = p4

kop7amp invalue "op7amp"
kop7ratio invalue "op7ratio"

kop7att invalue "op7att"
kop7dec invalue "op7dec"
kop7sus invalue "op7sus"
kop7rel invalue "op7rel"

kop6amp invalue "op6amp"
kop6ratio invalue "op6ratio"

kop6att invalue "op6att"
kop6dec invalue "op6dec"
kop6sus invalue "op6sus"
kop6rel invalue "op6rel"

kop5amp invalue "op5amp"
kop5ratio invalue "op5ratio"

kop5att invalue "op5att"
kop5dec invalue "op5dec"
kop5sus invalue "op5sus"
kop5rel invalue "op5rel"

kop4amp invalue "op4amp"
kop4ratio invalue "op4ratio"

kop4att invalue "op4att"
kop4dec invalue "op4dec"
kop4sus invalue "op4sus"
kop4rel invalue "op4rel"

kop3amp invalue "op3amp"
kop3ratio invalue "op3ratio"

kop3att invalue "op3att"
kop3dec invalue "op3dec"
kop3sus invalue "op3sus"
kop3rel invalue "op3rel"

kop2amp invalue "op2amp"
kop2ratio invalue "op2ratio"

kop2att invalue "op2att"
kop2dec invalue "op2dec"
kop2sus invalue "op2sus"
kop2rel invalue "op2rel"

kop1amp invalue "op1amp"
kop1ratio invalue "op1ratio"

kop1att invalue "op1att"
kop1dec invalue "op1dec"
kop1sus invalue "op1sus"
kop1rel invalue "op1rel"

afase7 phasor icps*kop7ratio
aop7 table3 afase7, 1, 1, 0, 1
kenv7 madsr i(kop7att), i(kop7dec), i(kop7sus), i(kop7rel)

afase6 phasor icps*kop6ratio
aop6 table3 afase6+(aop7*kop7amp*kenv7), 1, 1, 0, 1
kenv6 madsr i(kop6att), i(kop6dec), i(kop6sus), i(kop6rel)

afase5 phasor icps*kop5ratio
aop5 table3 afase5, 1, 1, 0, 1
kenv5 madsr i(kop5att), i(kop5dec), i(kop5sus), i(kop5rel)

afase4 phasor icps*kop4ratio
aop4 table3 afase4+(aop5*kop5amp*kenv5), 1, 1, 0, 1
kenv4 madsr i(kop4att), i(kop4dec), i(kop4sus), i(kop4rel)

afase3 phasor icps*kop3ratio
aop3 table3 afase3, 1, 1, 0, 1
kenv3 madsr i(kop3att), i(kop3dec), i(kop3sus), i(kop3rel)

afase2 phasor icps*kop2ratio
aop2 table3 afase2+(aop3*kop3amp*kenv3), 1, 1, 0, 1
kenv2 madsr i(kop2att), i(kop2dec), i(kop2sus), i(kop2rel)

afase1 phasor icps*kop1ratio
aop1 table3 afase1+(aop2*kop2amp*kenv2)+(aop4*kop4amp*kenv4), 1, 1, 0, 1
kenv1 madsr i(kop1att), i(kop1dec), i(kop1sus), i(kop1rel)

outs (aop1*kop1amp*kenv1) + (aop6*kop6amp*kenv6), (aop1*kop1amp*kenv1) + (aop6*kop6amp*kenv6)
endin

instr 99 ; randomize harmonic
krand random 0, 1
outvalue "op7amp", krand
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
outvalue "op7ratio", krand

krand random 0.01, 2
outvalue "op7att",krand
krand random 0.01, 1
outvalue "op7dec",krand
krand random 0.01, 1
outvalue "op7sus",krand
krand random 0.01, 2
outvalue "op7rel",krand

krand random 0, 1
outvalue "op6amp",krand
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
outvalue "op6ratio",krand

krand random 0.01, 2
outvalue "op6att",krand
krand random 0.01, 1
outvalue "op6dec",krand
krand random 0.01, 1
outvalue "op6sus",krand
krand random 0.01, 2
outvalue "op6rel",krand

krand random 0, 1
outvalue "op5amp",krand
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
outvalue "op5ratio",krand

krand random 0.01, 2
outvalue "op5att",krand
krand random 0.01, 1
outvalue "op5dec",krand
krand random 0.01, 1
outvalue "op5sus",krand
krand random 0.01, 2
outvalue "op5rel",krand

krand random 0, 1
outvalue "op4amp",krand
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
outvalue "op4ratio",krand

krand random 0.01, 2
outvalue "op4att",krand
outvalue "op4dec",krand
outvalue "op4sus",krand
krand random 0.01, 2
outvalue "op4rel",krand

krand random 0, 1
outvalue "op3amp",krand
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
outvalue "op3ratio",krand

krand random 0.01, 2
outvalue "op3att",krand
krand random 0.01, 1
outvalue "op3dec",krand
krand random 0.01, 1
outvalue "op3sus",krand
krand random 0.01, 2
outvalue "op3rel",krand

krand random 0, 1
outvalue "op2amp",krand
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
outvalue "op2ratio",krand

krand random 0.01, 2
outvalue "op2att",krand
krand random 0.01, 1
outvalue "op2dec",krand
krand random 0.01, 1
outvalue "op2sus",krand
krand random 0.01, 2
outvalue "op2rel",krand

krand random 0, 1
outvalue "op1amp",krand
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
outvalue "op1ratio",krand

krand random 0.01, 2
outvalue "op1att",krand
krand random 0.01, 1
outvalue "op1dec",krand
krand random 0.01, 1
outvalue "op1sus",krand
krand random 0.01, 2
outvalue "op1rel",krand

turnoff
endin

instr 100 ; randomize
krand random 0, 1
outvalue "op7amp", krand
krand random 0.1, 6
outvalue "op7ratio", krand

krand random 0.01, 2
outvalue "op7att",krand
krand random 0.01, 1
outvalue "op7dec",krand
krand random 0.01, 1
outvalue "op7sus",krand
krand random 0.01, 2
outvalue "op7rel",krand

krand random 0, 1
outvalue "op6amp",krand
krand random 0.1, 6
outvalue "op6ratio",krand

krand random 0.01, 2
outvalue "op6att",krand
krand random 0.01, 1
outvalue "op6dec",krand
krand random 0.01, 1
outvalue "op6sus",krand
krand random 0.01, 2
outvalue "op6rel",krand

krand random 0, 1
outvalue "op5amp",krand
krand random 0.1, 6
outvalue "op5ratio",krand

krand random 0.01, 2
outvalue "op5att",krand
krand random 0.01, 1
outvalue "op5dec",krand
krand random 0.01, 1
outvalue "op5sus",krand
krand random 0.01, 2
outvalue "op5rel",krand

krand random 0, 1
outvalue "op4amp",krand
krand random 0.1, 6
outvalue "op4ratio",krand

krand random 0.01, 2
outvalue "op4att",krand
outvalue "op4dec",krand
outvalue "op4sus",krand
krand random 0.01, 2
outvalue "op4rel",krand

krand random 0, 1
outvalue "op3amp",krand
krand random -6, 6
outvalue "op3ratio",krand

krand random 0.01, 2
outvalue "op3att",krand
krand random 0.01, 1
outvalue "op3dec",krand
krand random 0.01, 1
outvalue "op3sus",krand
krand random 0.01, 2
outvalue "op3rel",krand

krand random 0, 1
outvalue "op2amp",krand
krand random 0.1, 6
outvalue "op2ratio",krand

krand random 0.01, 2
outvalue "op2att",krand
krand random 0.01, 1
outvalue "op2dec",krand
krand random 0.01, 1
outvalue "op2sus",krand
krand random 0.01, 2
outvalue "op2rel",krand

krand random 0, 1
outvalue "op1amp",krand
krand random 0.1, 6
outvalue "op1ratio",krand

krand random 0.01, 2
outvalue "op1att",krand
krand random 0.01, 1
outvalue "op1dec",krand
krand random 0.01, 1
outvalue "op1sus",krand
krand random 0.01, 2
outvalue "op1rel",krand

turnoff
endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1
f 0 3600
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 274 127 689 623
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {32125, 41634, 41120}
ioText {22, 5} {653, 64} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {45056, 44544, 32512} background noborder Phase ModulationSynth
ioText {118, 229} {20, 36} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background noborder 
ioText {342, 228} {20, 36} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background noborder 
ioText {23, 77} {207, 157} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background border OP3
ioSlider {35, 102} {20, 100} 0.000000 1.000000 0.600000 op3amp
ioSlider {130, 100} {20, 100} 0.000001 3.000000 0.870001 op3att
ioSlider {154, 99} {20, 100} 0.000001 2.000000 0.685323 op3dec
ioSlider {177, 100} {20, 100} 0.000000 1.000000 0.870000 op3sus
ioSlider {201, 100} {20, 100} 0.000001 4.000000 0.240001 op3rel
ioText {57, 134} {67, 25} editnum 3.000000 0.001000 "op3ratio" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3.000000
ioText {251, 78} {205, 154} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background border OP5
ioSlider {265, 102} {20, 100} 0.000000 1.000000 0.710000 op5amp
ioSlider {357, 100} {20, 100} 0.000001 3.000000 1.500000 op5att
ioSlider {380, 100} {20, 100} 0.000001 2.000000 0.760001 op5dec
ioSlider {403, 100} {20, 100} 0.000000 1.000000 0.270000 op5sus
ioSlider {428, 100} {20, 100} 0.000001 4.000000 0.600001 op5rel
ioText {288, 130} {66, 25} editnum 0.200000 0.001000 "op5ratio" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.200000
ioText {129, 201} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {154, 200} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {177, 201} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {201, 201} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {30, 206} {41, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {57, 160} {69, 24} display 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Ratio
ioText {357, 201} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {381, 201} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {404, 201} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {429, 201} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {258, 201} {41, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {287, 155} {69, 24} display 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Ratio
ioText {105, 414} {20, 36} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background noborder 
ioText {346, 414} {20, 36} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background noborder 
ioText {227, 441} {20, 36} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background noborder 
ioText {105, 434} {262, 16} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background noborder 
ioText {23, 262} {204, 157} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background border OP2
ioSlider {35, 285} {20, 100} 0.000000 1.000000 0.820000 op2amp
ioText {56, 316} {67, 26} editnum 1.000000 0.001000 "op2ratio" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioSlider {127, 284} {20, 100} 0.000001 3.000000 1.920000 op2att
ioSlider {150, 284} {20, 100} 0.000001 2.000000 0.200001 op2dec
ioSlider {174, 284} {20, 100} 0.000000 1.000000 0.910000 op2sus
ioSlider {197, 284} {20, 100} 0.000001 4.000000 1.440001 op2rel
ioText {130, 471} {207, 148} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background border OP1
ioSlider {145, 490} {20, 100} 0.000000 1.000000 0.410000 op1amp
ioText {167, 523} {67, 25} editnum 2.000000 0.001000 "op1ratio" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioSlider {237, 487} {20, 100} 0.000001 3.000000 0.240001 op1att
ioSlider {260, 487} {20, 100} 0.000001 2.000000 0.320001 op1dec
ioSlider {283, 487} {20, 100} 0.000000 1.000000 0.260000 op1sus
ioSlider {308, 487} {20, 100} 0.000001 4.000000 1.760001 op1rel
ioText {252, 263} {206, 155} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background border OP4
ioSlider {265, 286} {20, 100} 0.000000 1.000000 0.020000 op4amp
ioText {289, 320} {66, 25} editnum 1.000000 0.001000 "op4ratio" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioSlider {359, 285} {20, 100} 0.000001 3.000000 1.830000 op4att
ioSlider {382, 285} {20, 100} 0.000001 2.000000 1.840000 op4dec
ioSlider {405, 285} {20, 100} 0.000000 1.000000 1.000000 op4sus
ioSlider {429, 285} {20, 100} 0.000001 4.000000 0.800001 op4rel
ioText {126, 385} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {150, 385} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {174, 385} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {197, 385} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {30, 388} {41, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {55, 342} {69, 24} display 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Ratio
ioText {359, 387} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {383, 387} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {406, 388} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {430, 387} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {261, 390} {41, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {289, 345} {69, 24} display 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Ratio
ioText {236, 588} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {260, 588} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {283, 588} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {307, 588} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {138, 591} {41, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {166, 546} {69, 24} display 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Ratio
ioText {560, 391} {19, 76} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background noborder 
ioText {470, 264} {205, 154} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background border OP7
ioSlider {484, 288} {20, 100} 0.000000 1.000000 0.880000 op7amp
ioSlider {576, 286} {20, 100} 0.000001 3.000000 1.830000 op7att
ioSlider {599, 286} {20, 100} 0.000001 2.000000 0.120001 op7dec
ioSlider {622, 286} {20, 100} 0.000000 1.000000 0.010000 op7sus
ioSlider {647, 286} {20, 100} 0.000001 4.000000 1.000001 op7rel
ioText {507, 316} {66, 25} editnum 0.500000 0.001000 "op7ratio" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.500000
ioText {576, 387} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {600, 387} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {623, 387} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {648, 387} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {477, 387} {41, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {506, 341} {69, 24} display 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Ratio
ioText {464, 458} {206, 155} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {13056, 42752, 32000} background border OP6
ioSlider {477, 481} {20, 100} 0.000000 1.000000 0.610000 op6amp
ioText {501, 515} {66, 25} editnum 4.000000 0.001000 "op6ratio" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4.000000
ioSlider {571, 480} {20, 100} 0.000001 3.000000 1.770000 op6att
ioSlider {594, 480} {20, 100} 0.000001 2.000000 0.560001 op6dec
ioSlider {617, 480} {20, 100} 0.000000 1.000000 0.700000 op6sus
ioSlider {641, 480} {20, 100} 0.000001 4.000000 0.880001 op6rel
ioText {571, 582} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {595, 582} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {618, 583} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {642, 582} {20, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {473, 585} {41, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {501, 540} {69, 24} display 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Ratio
ioText {470, 78} {205, 154} label 0.000000 0.00100 "" center "Lucida Grande" 8 {0, 0, 0} {15872, 42240, 42752} background border Control
ioButton {478, 100} {190, 28} event 1.000000 "" "Randomize harmonic" "/" i 99 0 1
ioButton {478, 129} {190, 28} event 1.000000 "" "Randomize" "/" i 100 0 1
</MacGUI>


<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1 ; MIDI note
kcps cpsmidib 2
outvalue "freq", kcps
endin

instr 50 ; Additive Synth

kamp1  invalue  "amp1"
kamp2  invalue  "amp2"
kamp3  invalue  "amp3"
kamp4  invalue  "amp4"
kamp5  invalue  "amp5"
kamp6  invalue  "amp6"
kamp7  invalue  "amp7"
kamp8  invalue  "amp8"
kamp9  invalue  "amp9"
kamp10  invalue  "amp10"
kamp11  invalue  "amp11"
kamp12  invalue  "amp12"

kfactor1  invalue  "fac1"
kfactor2  invalue  "fac2"
kfactor3  invalue  "fac3"
kfactor4  invalue  "fac4"
kfactor5  invalue  "fac5"
kfactor6  invalue  "fac6"
kfactor7  invalue  "fac7"
kfactor8  invalue  "fac8"
kfactor9  invalue  "fac9"
kfactor10  invalue  "fac10"
kfactor11  invalue  "fac11"
kfactor12  invalue  "fac12"

kfreq invalue "freq"
kfreq portk kfreq, 0.02, i(kfreq) ; Smooth frequency values

kfreq1 = kfreq * kfactor1
kfreq2 = kfreq * kfactor2
kfreq3 = kfreq * kfactor3
kfreq4 = kfreq * kfactor4
kfreq5 = kfreq * kfactor5
kfreq6 = kfreq * kfactor6
kfreq7 = kfreq * kfactor7
kfreq8 = kfreq * kfactor8
kfreq9 = kfreq * kfactor9
kfreq10 = kfreq * kfactor10
kfreq11 = kfreq * kfactor11
kfreq12 = kfreq * kfactor12

aosc1 poscil3 kamp1, kfreq1, 1
aosc2 poscil3 kamp2, kfreq2, 1
aosc3 poscil3 kamp3, kfreq3, 1
aosc4 poscil3 kamp4, kfreq4, 1
aosc5 poscil3 kamp5, kfreq5, 1
aosc6 poscil3 kamp6, kfreq6, 1
aosc7 poscil3 kamp7, kfreq7, 1
aosc8 poscil3 kamp8, kfreq8, 1
aosc9 poscil3 kamp9, kfreq9, 1
aosc10 poscil3 kamp10, kfreq10, 1
aosc11 poscil3 kamp11, kfreq11, 1
aosc12 poscil3 kamp12, kfreq12, 1

outvalue "freq1", kfreq1
outvalue "freq2", kfreq2
outvalue "freq3", kfreq3
outvalue "freq4", kfreq4
outvalue "freq5", kfreq5
outvalue "freq6", kfreq6
outvalue "freq7", kfreq7
outvalue "freq8", kfreq8
outvalue "freq9", kfreq9
outvalue "freq10", kfreq10
outvalue "freq11", kfreq11
outvalue "freq12", kfreq12

asig = aosc1 + aosc2 + aosc3 + aosc4 + aosc5 + aosc6 + aosc7 + aosc8 + aosc9 + aosc10 + aosc11 + aosc12

kon invalue "on"
klevel invalue "level"
outs asig*kon*klevel, asig*kon*klevel
endin

instr 98
turnoff2 50, 0, 0
event "i", 50, 0, 3600
turnoff
endin

instr 99
krel invalue "rel"
ktrig invalue "load"

printk2 ktrig

if ktrig == 0 then
	kgoto nochange
endif
if (krel == 0) then
	outvalue "fac1", 1
	outvalue "fac2", 2
	outvalue "fac3", 3
	outvalue "fac4", 4
	outvalue "fac5", 5
	outvalue "fac6", 6
	outvalue "fac7", 7
	outvalue "fac8", 8
	outvalue "fac9", 9
	outvalue "fac10", 10
	outvalue "fac11", 11
	outvalue "fac12", 12
elseif (krel == 1) then
	outvalue "fac1", 1
	outvalue "fac2", 3
	outvalue "fac3", 5
	outvalue "fac4", 7
	outvalue "fac5", 9
	outvalue "fac6", 11
	outvalue "fac7", 13
	outvalue "fac8", 15
	outvalue "fac9", 17
	outvalue "fac10", 19
	outvalue "fac11", 21
	outvalue "fac12", 23
elseif (krel == 2) then
	outvalue "fac1", 1
	outvalue "fac2", 1.22
	outvalue "fac3", 1.3
	outvalue "fac4", 1.35
	outvalue "fac5", 1.45
	outvalue "fac6", 1.64
	outvalue "fac7", 1.7
	outvalue "fac8", 1.78
	outvalue "fac9", 1.79
	outvalue "fac10", 1.81
	outvalue "fac11", 1.91
	outvalue "fac12", 1.98
elseif (krel == 3) then
	outvalue "fac1", 1
	outvalue "fac2", 2.22
	outvalue "fac3", 3.3
	outvalue "fac4", 4.35
	outvalue "fac5", 5.45
	outvalue "fac6", 6.64
	outvalue "fac7", 7.7
	outvalue "fac8", 8.78
	outvalue "fac9", 9.79
	outvalue "fac10", 10.81
	outvalue "fac11", 11.91
	outvalue "fac12", 12.98
elseif (krel == 4) then
	outvalue "fac1", 1.02
	outvalue "fac2", 1.05
	outvalue "fac3", 1.12
	outvalue "fac4", 1.14
	outvalue "fac5", 1.19
	outvalue "fac6", 1.21
	outvalue "fac7", 1.26
	outvalue "fac8", 1.29
	outvalue "fac9", 1.32
	outvalue "fac10", 1.35
	outvalue "fac11", 1.36
	outvalue "fac12", 1.39
endif
nochange:
endin

instr 100 ; Set amplitude to 1 over partial number
outvalue "amp1", 1/1
outvalue "amp2", 1/2
outvalue "amp3", 1/3
outvalue "amp4", 1/4
outvalue "amp5", 1/5
outvalue "amp6", 1/6
outvalue "amp7", 1/7
outvalue "amp8", 1/8
outvalue "amp9", 1/9
outvalue "amp10", 1/10
outvalue "amp11", 1/11
outvalue "amp12", 1/12
turnoff
endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1
i 50 0 3600
i 99 0 3600
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 495 196 717 561
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41634, 31611, 34438}
ioSlider {26, 55} {229, 22} 0.000000 1.000000 1.000000 amp1
ioSlider {26, 80} {229, 22} 0.000000 1.000000 0.500000 amp2
ioSlider {26, 105} {229, 22} 0.000000 1.000000 0.333333 amp3
ioSlider {26, 130} {229, 22} 0.000000 1.000000 0.250000 amp4
ioSlider {27, 155} {229, 22} 0.000000 1.000000 0.200000 amp5
ioSlider {27, 180} {229, 22} 0.000000 1.000000 0.166667 amp6
ioSlider {27, 205} {229, 22} 0.000000 1.000000 0.142857 amp7
ioSlider {27, 230} {229, 22} 0.000000 1.000000 0.125000 amp8
ioSlider {27, 254} {229, 22} 0.000000 1.000000 0.111111 amp9
ioSlider {27, 279} {229, 22} 0.000000 1.000000 0.100000 amp10
ioSlider {27, 304} {229, 22} 0.000000 1.000000 0.090909 amp11
ioSlider {27, 329} {229, 22} 0.000000 1.000000 0.083333 amp12
ioText {8, 54} {17, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1
ioText {8, 78} {17, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2
ioText {8, 103} {17, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3
ioText {8, 131} {17, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4
ioText {9, 156} {17, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 5
ioText {9, 180} {17, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 6
ioText {9, 202} {17, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 7
ioText {9, 226} {17, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 8
ioText {9, 251} {17, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 9
ioText {4, 278} {24, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 10
ioText {5, 303} {24, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 11
ioText {5, 327} {24, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 12
ioKnob {532, 71} {80, 80} 100.000000 1500.000000 0.010000 340.404040 freq
ioText {532, 150} {80, 25} display 340.404040 0.00100 "freq" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 340.4040
ioText {531, 53} {80, 25} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Base Freq
ioCheckbox {622, 56} {20, 20} off on
ioText {641, 54} {35, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder On
ioGraph {4, 358} {692, 157} scope 2.000000 -1.000000 
ioText {449, 37} {80, 316} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Freq. (Hz)
ioText {455, 54} {68, 25} display 340.404053 0.00100 "freq1" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 340.4041
ioText {454, 77} {68, 25} display 680.808105 0.00100 "freq2" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 680.8081
ioText {454, 103} {68, 25} display 1021.212158 0.00100 "freq3" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1021.2122
ioText {456, 130} {68, 25} display 1361.616211 0.00100 "freq4" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1361.6162
ioText {456, 155} {68, 25} display 1702.020264 0.00100 "freq5" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1702.0203
ioText {456, 179} {68, 25} display 2042.424316 0.00100 "freq6" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2042.4243
ioText {454, 204} {68, 25} display 2382.828369 0.00100 "freq7" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2382.8284
ioText {455, 229} {68, 25} display 2723.232422 0.00100 "freq8" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2723.2324
ioText {454, 254} {68, 25} display 3063.636475 0.00100 "freq9" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3063.6365
ioText {455, 278} {68, 25} display 3404.040527 0.00100 "freq10" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3404.0405
ioText {454, 304} {68, 25} display 3744.444580 0.00100 "freq11" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3744.4446
ioText {452, 328} {68, 25} display 4084.848633 0.00100 "freq12" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4084.8486
ioKnob {618, 93} {66, 60} 0.000000 0.500000 0.010000 0.186869 level
ioText {619, 150} {64, 25} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
ioText {7, 5} {248, 43} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {65280, 65280, 65280} {8448, 8704, 9216} background noborder Additive syntheziser
ioText {531, 184} {166, 92} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Partial relationship:
ioText {349, 37} {96, 316} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Freq. Factor
ioText {356, 54} {80, 25} editnum 1.000000 0.001000 "fac1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {356, 79} {80, 25} editnum 2.000000 0.001000 "fac2" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioText {356, 104} {80, 25} editnum 3.000000 0.001000 "fac3" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3.000000
ioText {356, 127} {80, 25} editnum 4.000000 0.001000 "fac4" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4.000000
ioText {356, 153} {80, 25} editnum 5.000000 0.001000 "fac5" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 5.000000
ioText {356, 180} {80, 25} editnum 6.000000 0.001000 "fac6" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 6.000000
ioText {356, 206} {80, 25} editnum 7.000000 0.001000 "fac7" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 7.000000
ioText {356, 230} {80, 25} editnum 8.000000 0.001000 "fac8" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 8.000000
ioText {356, 254} {80, 25} editnum 9.000000 0.001000 "fac9" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 9.000000
ioText {356, 278} {80, 25} editnum 10.000000 0.001000 "fac10" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 10.000000
ioText {356, 301} {80, 25} editnum 11.000000 0.001000 "fac11" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 11.000000
ioText {356, 327} {80, 25} editnum 12.000000 0.001000 "fac12" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 12.000000
ioButton {535, 286} {157, 30} event 1.000000 "reset" "Reset Phase" "/" i98 0 10
ioText {263, 54} {80, 25} editnum 1.000000 0.000100 "amp1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {263, 79} {80, 26} editnum 0.500000 0.000100 "amp2" center "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.500000
ioText {263, 104} {80, 26} editnum 0.333300 0.000100 "amp3" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.333300
ioText {263, 129} {80, 25} editnum 0.250000 0.000100 "amp4" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.250000
ioText {263, 154} {80, 26} editnum 0.200000 0.000100 "amp5" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.200000
ioText {263, 179} {80, 26} editnum 0.166700 0.000100 "amp6" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.166700
ioText {263, 203} {80, 25} editnum 0.142900 0.000100 "amp7" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.142900
ioText {263, 228} {80, 26} editnum 0.125000 0.000100 "amp8" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.125000
ioText {263, 253} {80, 26} editnum 0.111100 0.000100 "amp9" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.111100
ioText {263, 276} {80, 25} editnum 0.100000 0.000100 "amp10" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.100000
ioText {263, 301} {80, 26} editnum 0.090900 0.000100 "amp11" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.090900
ioText {263, 326} {80, 26} editnum 0.083300 0.000100 "amp12" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.083300
ioButton {535, 320} {158, 31} event 1.000000 "reset" "Amp = 1/n" "/" i100 0 1
ioMenu {537, 204} {155, 30} 0 303 "all harmonics,even harmonics,inharmonic1,inharmonic2,inharmonic3" rel
ioButton {561, 237} {100, 30} value 1.000000 "load" "Load rel." "/" i1 0 10
</MacGUI>


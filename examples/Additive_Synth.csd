<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1 ; Additive Synth

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
kfreq portk kfreq, 0.02 ; Smooth frequency values

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

aosc1 oscil3 kamp1, kfreq1, 1
aosc2 oscil3 kamp2, kfreq2, 1
aosc3 oscil3 kamp3, kfreq3, 1
aosc4 oscil3 kamp4, kfreq4, 1
aosc5 oscil3 kamp5, kfreq5, 1
aosc6 oscil3 kamp6, kfreq6, 1
aosc7 oscil3 kamp7, kfreq7, 1
aosc8 oscil3 kamp8, kfreq8, 1
aosc9 oscil3 kamp9, kfreq9, 1
aosc10 oscil3 kamp10, kfreq10, 1
aosc11 oscil3 kamp11, kfreq11, 1
aosc12 oscil3 kamp12, kfreq12, 1

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
turnoff2 1, 0, 0
event "i", 1, 0, 3600
turnoff
endin

instr 99
krel invalue "rel"
ktrig changed krel

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

</CsInstruments>
<CsScore>
f 1 0 4096 10 1
i 1 0 3600
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
WindowBounds: 469 263 704 551
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41634, 31611, 34438}
ioSlider {26, 55} {243, 22} 0.000000 1.000000 1.000000 amp1
ioSlider {26, 80} {243, 22} 0.000000 1.000000 0.580247 amp2
ioSlider {26, 105} {243, 22} 0.000000 1.000000 0.325103 amp3
ioSlider {26, 130} {243, 22} 0.000000 1.000000 0.251029 amp4
ioSlider {27, 155} {243, 22} 0.000000 1.000000 0.160494 amp5
ioSlider {27, 180} {243, 22} 0.000000 1.000000 0.106996 amp6
ioSlider {27, 205} {243, 22} 0.000000 1.000000 0.069959 amp7
ioSlider {27, 230} {243, 22} 0.000000 1.000000 0.053498 amp8
ioSlider {27, 254} {243, 22} 0.000000 1.000000 0.032922 amp9
ioSlider {27, 279} {243, 22} 0.000000 1.000000 0.016461 amp10
ioSlider {27, 304} {243, 22} 0.000000 1.000000 0.000000 amp11
ioSlider {27, 329} {243, 22} 0.000000 1.000000 0.000000 amp12
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
ioText {270, 53} {50, 25} display 0.000000 0.00100 "amp1" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.0000
ioText {270, 79} {50, 25} display 0.000000 0.00100 "amp2" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.5802
ioText {270, 104} {50, 25} display 0.000000 0.00100 "amp3" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.3251
ioText {270, 130} {50, 25} display 0.000000 0.00100 "amp4" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.2510
ioText {270, 154} {50, 25} display 0.000000 0.00100 "amp5" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.1687
ioText {270, 180} {50, 25} display 0.000000 0.00100 "amp6" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.1152
ioText {270, 205} {50, 25} display 0.000000 0.00100 "amp7" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0700
ioText {270, 231} {50, 25} display 0.000000 0.00100 "amp8" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0576
ioText {270, 252} {50, 25} display 0.000000 0.00100 "amp9" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0329
ioText {270, 278} {50, 25} display 0.000000 0.00100 "amp10" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0206
ioText {270, 303} {50, 25} display 0.000000 0.00100 "amp11" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0082
ioText {270, 329} {50, 25} display 0.000000 0.00100 "amp12" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0041
ioKnob {516, 70} {80, 80} 100.000000 1500.000000 0.010000 255.555556 freq
ioText {516, 149} {80, 25} display 0.000000 0.00100 "freq" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 255.5556
ioText {515, 52} {80, 25} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Base Freq
ioCheckbox {511, 244} {20, 20} on on
ioText {530, 242} {93, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder On
ioGraph {4, 358} {692, 157} scope 2.000000 -1.000000 
ioMenu {515, 203} {161, 30} 0 303 "all harmonics,even harmonics,inharmonic1,inharmonic2,inharmonic3" rel
ioText {417, 38} {80, 316} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Freq. (Hz)
ioText {423, 55} {80, 25} display 0.000000 0.00100 "freq1" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 255.5555
ioText {422, 78} {80, 25} display 0.000000 0.00100 "freq2" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 511.1110
ioText {422, 104} {80, 25} display 0.000000 0.00100 "freq3" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 766.6664
ioText {424, 131} {80, 25} display 0.000000 0.00100 "freq4" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1022.2219
ioText {424, 156} {80, 25} display 0.000000 0.00100 "freq5" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1277.7773
ioText {424, 180} {80, 25} display 0.000000 0.00100 "freq6" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1533.3329
ioText {422, 205} {80, 25} display 0.000000 0.00100 "freq7" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1788.8884
ioText {423, 230} {80, 25} display 0.000000 0.00100 "freq8" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2044.4438
ioText {422, 255} {80, 25} display 0.000000 0.00100 "freq9" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2299.9993
ioText {423, 279} {80, 25} display 0.000000 0.00100 "freq10" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2555.5547
ioText {422, 305} {80, 25} display 0.000000 0.00100 "freq11" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2811.1104
ioText {420, 329} {80, 25} display 0.000000 0.00100 "freq12" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3066.6658
ioKnob {602, 92} {66, 60} 0.000000 0.500000 0.010000 0.166667 level
ioText {603, 149} {64, 25} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
ioText {7, 5} {277, 43} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {65280, 65280, 65280} {8448, 8704, 9216} background noborder Additive syntheziser
ioText {515, 180} {140, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Partial relationship:
ioText {317, 38} {96, 316} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Freq. Factor
ioText {324, 55} {80, 25} editnum 1.000000 0.001000 "fac1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {324, 80} {80, 25} editnum 2.000000 0.001000 "fac2" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioText {324, 105} {80, 25} editnum 3.000000 0.001000 "fac3" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3.000000
ioText {324, 128} {80, 25} editnum 4.000000 0.001000 "fac4" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4.000000
ioText {324, 154} {80, 25} editnum 5.000000 0.001000 "fac5" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 5.000000
ioText {324, 181} {80, 25} editnum 6.000000 0.001000 "fac6" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 6.000000
ioText {324, 207} {80, 25} editnum 7.000000 0.001000 "fac7" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 7.000000
ioText {324, 231} {80, 25} editnum 8.000000 0.001000 "fac8" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 8.000000
ioText {324, 255} {80, 25} editnum 9.000000 0.001000 "fac9" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 9.000000
ioText {324, 279} {80, 25} editnum 10.000000 0.001000 "fac10" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 10.000000
ioText {324, 302} {80, 25} editnum 11.000000 0.001000 "fac11" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 11.000000
ioText {324, 328} {80, 25} editnum 12.000000 0.001000 "fac12" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 12.000000
ioButton {538, 272} {99, 83} event 1.000000 "reset" "Reset Phase" "/" i98 0 10
</MacGUI>


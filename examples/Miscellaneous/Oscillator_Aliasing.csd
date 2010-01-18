<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
kfreq invalue "freq" 
klvl invalue "lvl" 
kfamily invalue "family"
ktype invalue "type"
ktable invalue "table"
ktable init 1
ktrig changed ktable
if ktrig == 1 then
	ktable = ktable + 1
	reinit contin
endif

contin:
if kfamily == 0 then
	itable = i(ktable)
	if ktype == 0 then
		aout oscil klvl, kfreq, itable
	elseif ktype == 1 then
		aout oscili klvl, kfreq, itable
	elseif ktype == 2 then
		aout oscil3 klvl, kfreq, itable
	endif
elseif kfamily == 1 then
	aout vco2 klvl, kfreq
endif
rireturn

dispfft  aout*3, 0.3, 4096
outs aout, aout
endin

</CsInstruments>
<CsScore>
f 1 0 128 10 1
f 2 0 256 10 1
f 3 0 512 10 1
f 4 0 1024 10 1
f 5 0 2048 10 1
f 6 0 128 7 1 64 1 0 -1 64 -1
f 7 0 2048 7 1 1024 1 0 -1 1024 -1
f 8 0 128 7 1 128 -1
f 9 0 2048 7 1 2048 -1
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 525 192 653 715
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {32125, 41634, 41120}
ioKnob {23, 17} {77, 64} 40.000000 6000.000000 0.010000 341.010101 freq
ioText {22, 79} {80, 25} display 0.000000 0.00100 "freq" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 401.2121
ioGraph {10, 124} {614, 392} table 0.000000 1.000000 
ioMenu {225, 44} {124, 24} 0 303 "oscil,vco2" family
ioText {362, 18} {132, 98} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {40192, 46336, 41472} background border Oscil family
ioMenu {368, 40} {114, 25} 1 303 "no interp,linear,cubic" type
ioMenu {369, 78} {114, 25} 7 303 "sine 128 pts,sine 256 pts,sine 512 pts,sine 1024 pts,sine 2048 pts,square 128,square 2048,saw 128,saw 2048" table
ioText {501, 19} {122, 97} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {40192, 46336, 41472} background border Vco2 family
ioMenu {510, 42} {97, 25} 0 303 "saw, square" vco2type
ioText {224, 17} {124, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Oscillator family
ioMenu {225, 44} {124, 24} 0 303 "oscil,vco2" family
ioText {225, 71} {126, 47} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Oscil are table oscillators. Vco2 are bandlimited oscillators
ioGraph {11, 522} {613, 150} scope 2.000000 -1.000000 
ioText {22, 96} {80, 25} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Freq
ioKnob {116, 18} {77, 64} 0.000000 1.000000 0.010000 0.555556 lvl
ioText {115, 80} {80, 25} display 0.000000 0.00100 "lvl" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.5556
ioText {115, 97} {80, 25} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
</MacGUI>


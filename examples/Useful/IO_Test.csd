<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

massign 0, 2

instr 1
; Signal generator
ksignal invalue "signal"
klevel invalue "level"
kon1 invalue "on1"
kon2 invalue "on2"

klevel = ampdbfs(klevel)
asig = 0
if ksignal == 1 then
	asig oscil klevel, 1000, 1
elseif ksignal == 2 then
	asig rand klevel
endif

outs asig*kon1, asig*kon2

; Measure inputs

irange = 48
imin = ampdbfs(-irange)
ain1 inch 1
ain2 inch 2

ktrig metro 15

k1 max_k ain1, ktrig, 1
k2 max_k ain1, ktrig, 1

if ktrig == 1 then
	outvalue "in1", (irange + dbfsamp(k1))/irange
	outvalue "in2", (irange + dbfsamp(k2))/irange
	outvalue "indb1", dbfsamp(k1)
	outvalue "indb2", dbfsamp(k2)
endif

endin

instr 2  ; midi note input
xtratim 0.1
kflag release
outvalue "notein", (kflag * -1)+ 1
endin

instr 3
noteondur 1, 60, 100, p3
endin


</CsInstruments>
<CsScore>
f 1 0 1024 10 1
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
WindowBounds: 623 286 401 294
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {33924, 32639, 22873}
ioText {2, 4} {386, 32} label 0.000000 0.00100 "" center "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} background border I/O Test
ioText {115, 40} {134, 216} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {43520, 43520, 32512} background border Audio Output
ioText {122, 82} {120, 165} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Signal generator
ioText {1, 40} {107, 216} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {43520, 43520, 32512} background border Audio Input
ioMeter {68, 65} {17, 132} {39168, 47104, 59904} "in2" 0.000000 "hor2" 0.235294 fill 1 0 mouse
ioMeter {20, 65} {17, 132} {39168, 47104, 59904} "in1" 0.000000 "hor2" 0.235294 fill 1 0 mouse
ioText {18, 195} {23, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1
ioText {69, 195} {23, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2
ioText {8, 221} {41, 25} scroll -52.578922 0.100000 "indb1" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} background border -52.6
ioText {59, 221} {41, 25} scroll -52.578922 0.100000 "indb2" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} background border -52.6
ioText {253, 39} {134, 216} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {43520, 43520, 32512} background border MIDI note IO
ioText {290, 63} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Note in
ioButton {260, 98} {120, 30} event 1.000000 "button1" "Generate note" "/" i3 0 0.5
ioMeter {269, 65} {19, 19} {0, 59904, 0} "notein" 0.000000 "hor21" 0.000000 fill 1 0 mouse
ioMenu {131, 106} {106, 28} 2 303 "none,sine,noise" signal
ioText {140, 167} {23, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1
ioText {191, 167} {23, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2
ioCheckbox {141, 145} {20, 20} off on1
ioCheckbox {191, 146} {20, 20} off on2
ioText {193, 204} {39, 25} scroll -20.000000 0.100000 "level" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} background border -20.0
ioText {133, 204} {61, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
</MacGUI>


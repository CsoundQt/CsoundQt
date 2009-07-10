<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

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
WindowBounds: 523 282 270 305
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41634, 40092, 28270}
ioText {91, 6} {87, 32} label 0.000000 0.00100 "" left "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder I/O Test
ioText {115, 40} {134, 216} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Output
ioMenu {122, 107} {106, 28} 1 303 "none,sine,noise" signal
ioText {122, 79} {122, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Signal generator
ioText {1, 40} {107, 216} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Input
ioMeter {68, 65} {17, 132} {39168, 47104, 59904} "in2" 0.953873 "hor2" 0.000000 fill 1 0 mouse
ioMeter {20, 65} {17, 132} {39168, 47104, 59904} "in1" 0.953873 "hor2" 0.000000 fill 1 0 mouse
ioText {18, 195} {23, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1
ioText {69, 195} {23, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2
ioText {8, 221} {41, 25} scroll -2.200000 0.100000 "indb1" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} background border -2.2
ioText {59, 221} {41, 25} scroll -2.200000 0.100000 "indb2" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} background border -2.2
ioText {137, 168} {23, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1
ioText {188, 168} {23, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2
ioCheckbox {138, 146} {20, 20} off on1
ioCheckbox {188, 147} {20, 20} off on2
ioText {183, 206} {39, 25} scroll -20.000000 0.100000 "level" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} background border -20.0
ioText {122, 206} {61, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
</MacGUI>


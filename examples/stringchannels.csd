<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 128
nchnls = 2
0dbfs = 1

;declare "textset" channel as string channel
chn_S "textset", 2
;outvalue/invalue don't need channel declaration

instr 1
	event_i "i", 2, 0, 1
	event_i "i", 3, 2, 1
	event_i "i", 4, 4, 1
endin

instr 2
; Notice that channel name and value are inverted
; in outvalue and chnset!
	outvalue "text", "hello"
	chnset "hello", "textset"
	turnoff
endin

instr 3
	outvalue "text", "world!"
	chnset "world!", "textset"
	turnoff
endin

instr 4
	outvalue "text", ""
	chnset "", "textset"
	turnoff
endin

</CsInstruments>
<CsScore>
f 0 3600
i 1 1 1

</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 53 584 441 337
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {20, 20} {120, 60} label 0.000000 0.00100 "text" left "DejaVu Sans" 24 {0, 0, 0} {56576, 55808, 47360} background border 
ioText {300, 20} {120, 60} label 0.000000 0.00100 "textset" left "DejaVu Sans" 24 {0, 0, 0} {65280, 52480, 43264} background border 
ioText {20, 90} {190, 50} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border The label above will change if invalue/outvalue are enabled
ioText {230, 90} {190, 50} label 0.000000 0.00100 "" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border The label above will change if chnget/chnset are enabled
ioButton {20, 150} {100, 40} event 0.000000 "button1" "Do it again!" "/" i1 0 1
ioText {20, 200} {400, 90} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border To enable chnget/chnset or invalue/outvalue go to Configuration->General->Widgets. It is not recommended to use both simultaneously as it will degrade performance.
</MacGUI>


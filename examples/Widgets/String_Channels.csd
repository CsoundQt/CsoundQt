<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
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
i 1 0 1

</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 501 374 202 199
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {38, 24} {120, 60} label 0.000000 0.00100 "text" left "DejaVu Sans" 24 {0, 0, 0} {56576, 55808, 47360} background border 
ioButton {45, 94} {100, 40} event 0.000000 "button1" "Do it again!" "/" i1 0 1
</MacGUI>


<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; This example shows the usage of sense key to use the ascii keyboard
; as a keyboard to play notes. It uses an always on instrument (1), which
; listens to key events and turns on and off notes.
; It is important to give focus to the main Csound Output Console (giving focus
; to a console widget will not work!).
; Note that key press auto-repeats are discarded!


; This table calculates the pitch values for the ascii key codes
; Using shift or caps lock will raise 2 octaves (except for the numbers)

giascii ftgen 0, 0, 256, -17, 0,0, \
	48, 9.03, 49, 0, 50, 8.01, 51, 8.03, 52, 0, 53, 8.06, 54, 8.08, \
	55, 8.10, 56,0, 57, 9.01, \
	65, 0, 66, 9.07, 67, 9.04, 68, 9.03, 69, 10.04, 70, 0, 71, 9.06, 72, 9.08, \
	73, 11.00, 74, 9.10, 75, 0, 76, 0, 77, 9.11, 78, 9.09, 79, 11.02, 80, 11.04, \
	81, 10.00, 82, 10.05, 83, 9.01, 84, 10.07, 85, 10.11, 86, 9.05, 87, 10.02, \
	88, 9.02, 89, 10.09, 90, 9.00, \
	97, 0, 98, 7.07, 99, 7.04, 100, 7.03, 101, 8.04, 102, 0, 103, 7.06, 104, 7.08, \
	105, 9.00, 106, 7.10, 107, 0, 108, 0, 109, 7.11, 110, 7.09, 111, 9.02, 112, 9.04, \
	113, 8.00, 114, 8.05, 115, 7.01, 116, 8.07, 117, 8.11, 118, 7.05, 119, 8.02, \
	120, 7.02, 121, 8.09, 122, 7.00

instr 1 ;always on, sensing key events
kres,kkeydown sensekey

kpch table kres, giascii
if kkeydown == 1 then
	Smessage sprintfk "Key pressed. Code = %i", kres
	outvalue "data", Smessage
	event "i", 2 + (kpch/100), 0, -5, kpch 
elseif (kkeydown == 0 && kres != -1) then
	turnoff2 2 + (kpch/100), 4, 1
	Smessage sprintfk "Key released. Code = %i", kres
	outvalue "data", Smessage
endif
endin

instr 2  ;actual synth. Put anything here
iamp = 0.2
iatt = 0.03
idec = 0.01
irel = 1.3
ifreq = cpspch(p4)
print ifreq
if ifreq < 20 then
	turnoff
endif
kenv madsr iatt, idec, 0.6, irel
asig vco2 kenv*iamp, ifreq
asig moogladder asig, ifreq*2, 0.8
outs asig, asig
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 638 369 322 293
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {21845, 43690, 32639}
ioText {5, 52} {289, 104} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground border The sensekey opcode can be used to receive keyboard action. It is VERY  IMPORTANT to click on the Dock Console or the Widget Panel to give it focus, otherwise key events will NOT be passed to Csound.
ioText {6, 11} {287, 37} label 0.000000 0.00100 "" center "DejaVu Sans" 20 {0, 0, 0} {24832, 49664, 36864} background noborder Keyboard control
ioText {46, 163} {198, 26} display 0.000000 0.00100 "data" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} background border Key released. Code = 113
</MacGUI>


<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; Adapted from Richard Boulanger's toots
sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
;            amp,freq,f-table   
	a1 oscil 0.2, 440, 1
	outs	a1, a1
endin

</CsInstruments>
<CsScore>
; number  time   size  GEN  p1
f   1         0       4096	10	 1	; use GEN10 to compute a sine wave

;ins	strt	dur
i 1	0	4
e ; indicates the end of the score
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 656 282 390 298
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {14, 12} {100, 29} label 0.000000 0.00100 "" left "DejaVu Sans" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Toot 1
ioText {14, 43} {346, 63} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder This first toot, contains a single instrument which uses an oscil unit to play a 440Hz sine wave (defined by f1 in the score) at an amplitude of 0.2.
ioGraph {14, 114} {346, 141} scope 2.000000 -1.000000 
</MacGUI>


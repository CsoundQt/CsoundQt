<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; Adapted from Richard Boulanger's toots
sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 2

	a1 oscil p4, p5, 1    ; p4=amp
	                      ; p5=freq
	outs a1, a1

endin

</CsInstruments>
<CsScore>
; number  time   size  GEN  p1
f   1         0       4096	10	 1	; use GEN10 to compute a sine wave

;ins strt dur  amp(p4)   freq(p5)

i2   0    1    0.02       880

i2   1.5  1    0.05      440

i2   3    1    0.1      220

i2   4.5  1    0.3     110

i2   6    1    0.6     55
e ; indicates the end of the score
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 682 272 397 486
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {14, 12} {100, 29} label 0.000000 0.00100 "" left "DejaVu Sans" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Toot 2
ioText {14, 43} {365, 137} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder The first instrument was not interesting because it could play only one note at one amplitude level. We can make things more interesting by allowing the pitch and amplitude to be defined by parameters in the score. Each column in the score constitutes a parameter field, numbered from the left. The first three parameter fields of the i statement have a reserved function:
ioGraph {53, 351} {292, 96} scope 2.000000 -1.000000 
ioText {81, 179} {178, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder p1 = instrument number
ioText {11, 248} {367, 102} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder All other parameter fields are determined by the way the sound designer defines his instrument. In the instrument below, the oscillator's amplitude argument is replaced by p4 and the frequency argument by p5. Now we can change these values at i-time, i.e. with each note in the score. 
ioText {81, 202} {178, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder p2 = start time
ioText {80, 225} {178, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder p3 = duration
</MacGUI>


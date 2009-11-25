<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; Adapted from Richard Boulanger's toots
sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 3             
                                  ; p3=duration of note
	k1 linen p4, p6, p3, p7      ; p4=amp
	a1 oscil k1, p5, 1           ; p5=freq
	outs a1, a1                  ; p6=attack time
	                             ; p7=release time
endin
</CsInstruments>
<CsScore>
; number  time   size  GEN  p1
f   1         0       4096	10	 1	; use GEN10 to compute a sine wave

;ins strt dur  amp(p4)   freq(p5)  attack(p6)     release(p7)
i3   0    1    0.2       440       0.5            0.7

i3   1.5  1    0.2       440       0.9            0.1

i3   3    1    0.1       880       0.02           0.99

i3   4.5  1    0.1       880       0.7            0.01

i3   6    2    0.3       220       0.5            0.5
e ; indicates the end of the score
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 765 441 397 458
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {14, 12} {100, 29} label 0.000000 0.00100 "" left "DejaVu Sans" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Toot 3
ioText {14, 43} {364, 98} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Although in the second instrument we could control and vary the overall amplitude from note to note, it would be more musical if we could contour the loudness during the course of each note. To do this we'll need to employ an additional unit generator linen.
ioGraph {50, 313} {292, 96} scope 2.000000 -1.000000 
ioText {13, 147} {364, 161} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder linen is a signal modifier, capable of computing its output at either control or audio rates. Since we plan to use it to modify the amplitude envelope of the oscillator, we'll choose the latter version. Three of linen's arguments expect i-rate variables. The fourth expects in one instance a k-rate variable (or anything slower), and in the other an x-variable (meaning a-rate or anything slower). Our linen we will get its amp from p4. 
</MacGUI>


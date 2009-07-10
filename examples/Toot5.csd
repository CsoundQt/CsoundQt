<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; Adapted from Richard Boulanger's toots
sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 5
	irel = 0.01                  ; set vibrato release time
	idel1 = p3 * p10             ; calculate initial delay (% of dur)
	isus = p3 - (idel1 + irel)   ; calculate remaining duration
	
	iamp = ampdbfs(p4)
	iscale = iamp * .333                                   ; p4=amp
	inote = cpspch(p5)                                     ; p5=freq
	
	k3        linseg    0, idel1, p9, isus, p9, irel, 0    ; p6=attack time
	k2        oscil     k3, p8, 1                          ; p7=release time
	k1        linen     iscale, p6, p3, p7                 ; p8=vib rate
	
	a3        oscil     k1, inote*.995+k2, 1               ; p9=vib depth
	a2        oscil     k1, inote*1.005+k2, 1              ; p10=vib delay (0-1)
	a1        oscil     k1, inote+k2, 1
	
	outs a1+a2+a3, a1+a2+a3

endin
</CsInstruments>
<CsScore>
; number  time   size  GEN  p1
f   1         0       4096	10	 1	; use GEN10 to compute a sine wave

;ins strt dur  amp  freq      atk  rel  vibrt     vbdpt     vbdel
i5   0    3    -10   10.00     0.1  0.7  7         6         .4

i5   4    3    -10   10.02     1    0.2  6         6         .4

i5   8    4    -10   10.04     2    1    5         6         .4
e ; indicates the end of the score
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 502 301 413 440
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {14, 12} {100, 29} label 0.000000 0.00100 "" left "DejaVu Sans" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Toot 5
ioText {14, 43} {365, 114} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder To add some delayed vibrato to our chorusing instrument we use another oscillator for the vibrato and a line segment generator, linseg, as a means of controlling the delay. linseg is a k-rate or a-rate signal generator which traces a series of straight line segments between any number of specified points.
ioGraph {50, 276} {292, 96} scope 2.000000 -1.000000 
ioText {14, 162} {365, 102} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Since we intend to use this to slowly scale the amount of signal coming from our vibrato oscillator, we'll choose the k-rate version. The i-rate variables: ia, ib, ic, etc., are the values for the points. The i-rate variables: idur1, idur2, idur3, etc., set the duration, in seconds, between segments.
</MacGUI>


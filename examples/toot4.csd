<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; Adapted from Richard Boulanger's toots
sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 4
	iamp = ampdbfs(p4)         ; convert dB FS to linear amp
	iscale = iamp * .333       ; scale the amp at initialization
	inote = cpspch(p5)         ; convert octave.pitch to cps
	
	k1 linen iscale, p6, p3, p7  ; p4=amp
	
	a3 oscil k1, inote*.996, 1   ; p5=freq
	a2 oscil k1, inote*1.004, 1  ; p6=attack time
	a1 oscil k1, inote, 1        ; p7=release time
	
	a1 = a1+a2+a3
	outs a1, a1

endin
</CsInstruments>
<CsScore>
; number  time   size  GEN  p1
f   1         0       4096	10	 1	; use GEN10 to compute a sine wave

;ins strt dur  amp   freq      attack    release
i4   0    1    -20   8.04      0.1       0.7

i4   1    1    -15   8.02      0.07      0.6

i4   2    1    -20   8.00      0.05      0.5

i4   3    1    -30   8.02      0.05      0.4

i4   4    1    -15   8.04      0.1       0.5

i4   5    1    -10   8.04      0.05      0.5

i4   6    2    -10   8.04      0.03      1.
e ; indicates the end of the score
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 514 418 400 411
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {14, 12} {100, 29} label 0.000000 0.00100 "" left "DejaVu Sans" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Toot 4
ioText {14, 43} {365, 114} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Next we'll animate the basic sound by mixing it with two slightly de-tuned copies of itself. We'll employ Csound's cpspch value converter which will allow us to specify the pitches by octave and pitch-class rather than by frequency, and we'll use the ampdbfs converter to specify loudness in dB FS rather than linearly.
ioGraph {50, 276} {292, 96} scope 2.000000 -1.000000 
ioText {14, 162} {365, 102} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Since we are adding the outputs of three oscillators, each with the same amplitude envelope, we'll scale the amplitude before we mix them. Both iscale and inote are arbitrary names to make the design a bit easier to read. Each is an i-rate variable, evaluated when the instrument is initialized.
</MacGUI>


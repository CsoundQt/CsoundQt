/*Getting started.. 1.6 Instrument Control

This first instrument provides two control possibilities to a sine oscillator. 
Pitch and Volume can be modulated from the score. Therefore a fourth and fifth p-argument (p4, p5) are used in the instrument definition.

p1, p2 & p3 are automatically generated arguments for each instrument, so we don't create them manually.

p1 - instrument number
p2 - start trigger
p3 - stop trigger
---
p4 - amplitude (0-1)
p5 - frequency (Hz)

*/
 
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
aSine poscil3 p4, p5, 1 		; Here, a different oscillator type is used, which has more flexibility and higher precision.
	outs aSine, aSine
endin

</CsInstruments>

<CsScore>
f 1 0 1024 10 1
;ins strt dur  amp  freq  
i1 	0 	2 	0.8 	440		; loud
i1 	3 	2	0.1	554.365	; quiet
i1 	6 	2	0.4	659.255	

i1 	9 	3	0.1	440  		; you can layer more instances of the same instrument easily
i1 	9.5 	3.5	0.2	554.365
i1 	10 	3	0.1	659.255
i1 	10.2 	2.5	0.15	783.991
i1 	10.8 	2	0.3	932.328
e
; Keep in mind, that in "realtime mode", the number of layers is limited by your machines CPU power.
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Nov. 2009) - Incontri HMT-Hannover
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 552 190 307 465
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41120, 40606, 41634}
ioGraph {30, 281} {255, 150} scope 2.000000 -1.000000 
ioText {30, 229} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {29, 81} {251, 109} table 0.000000 1.000000 
ioText {29, 21} {251, 61} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The pure waveform used by the oscillator is visable in the Graph display.
ioGraph {30, 281} {255, 150} scope 2.000000 -1.000000 
ioText {30, 229} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {29, 81} {251, 109} table 0.000000 1.000000 
ioText {29, 21} {251, 61} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The pure waveform used by the oscillator is visable in the Graph display.
ioGraph {30, 281} {255, 150} scope 2.000000 -1.000000 
ioText {30, 229} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {29, 81} {251, 109} table 0.000000 1.000000 
ioText {29, 21} {251, 61} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The pure waveform used by the oscillator is visable in the Graph display.
ioGraph {30, 281} {255, 150} scope 2.000000 -1.000000 
ioText {30, 229} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {29, 81} {251, 109} table 0.000000 1.000000 
ioText {29, 21} {251, 61} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The pure waveform used by the oscillator is visable in the Graph display.
</MacGUI>


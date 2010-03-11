/*Getting started.. 1.6 Instrument Control from the Score

Instrument no. 1 provides two control possibilities for a sine oscillator. 
Volume and pitch can be determined from the score. The different values for a score instruction are called parameter-fields. For example the score below uses 5 p-fields:
i1 	0 	2 	0.8 	440

When used inside an instrument, the values from the score are referenced using a 'p' and the number of the p-field.
p1, p2 & p3 are required arguments for each instrument, and they have fixed meaning. All values after that can be freely assigned.

p1 - instrument number
p2 - start time
p3 - duration
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
i 1 	0 	2 	0.8 	440		; loud
i 1 	3 	2	0.1	554.365	; quiet
i 1 	6 	2	0.4	659.255	

i 1 	9 	3	0.1	440  		; you can layer more instances of the same instrument easily
i 1 	9.5 	3.5	0.2	554.365
i 1 	10 	3	0.1	659.255
i 1 	10.2 	2.5	0.15	783.991
i 1 	10.8 	2	0.3	932.328
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
WindowBounds: 883 62 400 483
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41120, 40606, 41634}
ioGraph {30, 281} {255, 150} scope 2.000000 -1.000000 
ioText {30, 229} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {29, 81} {251, 109} table 0.000000 1.000000 
ioGraph {30, 281} {255, 150} scope 2.000000 -1.000000 
ioText {30, 229} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {29, 81} {251, 109} table 0.000000 1.000000 
ioGraph {30, 281} {255, 150} scope 2.000000 -1.000000 
ioText {30, 229} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {29, 81} {251, 109} table 0.000000 1.000000 
ioGraph {30, 281} {255, 150} scope 2.000000 -1.000000 
ioText {30, 229} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {29, 81} {251, 109} table 0.000000 1.000000 
ioText {29, 21} {251, 61} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The pure waveform used by the oscillator is displayed in this Graph widget.
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322"> 








</EventPanel>
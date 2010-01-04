/*Getting started.. Basic Elements: Constants and Variables

Variables are named 'cells' or 'slots' which contain data. They may be updated at one of the available update rates: i, k and a, which stand for initialization, control and audio.
The type of variable is determined by the first letter of its name (i,k,a). The names can be easier to read, if you start new words with big letters.

For example:
aMyAudioVariable
kMyControlVariable
iThisIsTheInitVariable

Numeric Value types: (From: An Overview of Csound Variable Types by Andres Cabrera (Csound Journal Issue 10 on www.csounds.com)) 
	a-type: These variables hold audio samples, or control signals that are 
		calculated and updated every audio sample.

	k-type: These variables hold scalar values which are updated only 
		once per control period. 

	i-type: Initialization variables are only updated on every note's 
		initialization pass.

More detailed information can be found here:
-Constants and Variables (Menu: Help->Csound Manual->1. Overview - Syntax of the orchestra->Constants and Variables)
-An Overview of Csound Variable Types by Andres Cabrera (Csound Journal Issue 10 on www.csounds.com)
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 2
kFreq expon 100, 5, 1000 	; kFreq is used to carry the 'expon' output as k-type
aOut  oscili 0.2, kFreq, 1 	; aOut carries the 'oscil' output as a-type 
	outvalue "freqsweep", kFreq  ; k-type values can be displayed on widgets
	outs aOut, aOut 			; a-type values can be played by the computers audio output
endin


</CsInstruments>
<CsScore>
f 1 0 1024 10 1 			; this function table contains the sine information
i 2 0 5 				; the instrument is called and plays for 5 seconds
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Nov. 2009) - Incontri HMT-Hannover 
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 832 162 310 570
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41634, 36751, 38807}
ioText {108, 37} {144, 29} display 0.000000 0.00100 "freqsweep" center "Helvetica" 16 {0, 0, 0} {46592, 27904, 0} background border 999.1507
ioGraph {22, 365} {255, 150} scope 2.000000 -1.000000 
ioText {21, 7} {248, 71} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This label displays the current frequency:
ioText {22, 313} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {21, 165} {251, 109} table 0.000000 1.000000 
ioText {21, 105} {251, 61} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The pure waveform used by the oscillator is visable in the Graph display.
ioText {108, 37} {144, 29} display 0.000000 0.00100 "freqsweep" center "Helvetica" 16 {0, 0, 0} {46592, 27904, 0} background border 999.1507
ioGraph {22, 365} {255, 150} scope 2.000000 -1.000000 
ioText {21, 7} {248, 71} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This label displays the current frequency:
ioText {22, 313} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {21, 165} {251, 109} table 0.000000 1.000000 
ioText {21, 105} {251, 61} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The pure waveform used by the oscillator is visable in the Graph display.
</MacGUI>


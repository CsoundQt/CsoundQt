/*Getting started.. 1.3 Basic Elements: Opcodes

The fundamental building blocks of a Csound instrument is the opcode. 
Each opcode can be seen as little program itself, that does a specific task. Opcodes get a bold-blue highlightning in the QuteCsound editor. In this example 'line', 'expon', 'oscil', 'outvalue' and 'outs', are the opcodes used.

The names of opcodes are usually a short form of their functionality.
'line' -  generates a linear changing value between specified points
'expon' - generates a exponential curve between two points
'oscil' - is a tone generator (an oscillator)
'outvalue' - sends a value to a user defined channel, in this case to the widget display
'outs' - writes stereo audio data to an external audio device

It is important to remember that opcodes receive their input arguments on the right and output their results on the left, like this:

output Opcode input1, input2

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
kFreq line 100, 5, 1000 		; 'line' generates a linear ramp, from 100-1000 Hz, taking 5 seconds
aOut  oscili 0.2, kFreq, 1	; an oscillator whose frequency is taken from the value produced by 'line'
	outvalue "freqsweep", kFreq   ; show the value from 'line' in a widget
     outs aOut, aOut			 ; send the oscillator's audio to the audio ouput
endin


instr 2
kFreq expon 100, 5, 1000 		; the 'expon' exponential curve is more useful when working with frequencies
aOut  oscili 0.2, kFreq, 1
	outvalue "freqsweep", kFreq
	outs aOut, aOut
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1 				; the basic sine waveform for the oscillator is generated here 
i 1 0 5
i 2 5 5					; the exponential curve goes more even thought the octaves
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
WindowBounds: 883 62 400 483
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41120, 40606, 41634}
ioText {108, 37} {144, 29} display 0.000000 0.00100 "freqsweep" center "Helvetica" 16 {0, 0, 0} {46592, 27904, 0} background border 997.7670
ioGraph {22, 365} {255, 150} scope 2.000000 -1.000000 
ioText {21, 7} {248, 71} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This label displays the current frequency:
ioText {22, 313} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {21, 165} {251, 109} table 0.000000 1.000000 
ioText {21, 105} {251, 61} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The pure waveform used by the oscillator is visable in the Graph display.
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322"> 








</EventPanel>
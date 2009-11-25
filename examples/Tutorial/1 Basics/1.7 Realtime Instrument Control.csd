/*Getting started.. 1.7 Realtime Instrument Control

This second instrument provides two control possibilities to a sine oscillator with realtime adjustment from the graphical user interface (GUI). 

Open the widget window, and move the sliders!
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
kFreq	invalue "freq" 	; userdefined channel: freq
kAmp invalue "amp" 	; userdefined channel: amp
kAmp port kAmp, .1 	; this smoothes the incoming slider values
kFreq port kFreq, .1
aSine poscil3 kAmp, kFreq, 1
outs aSine, aSine
endin

</CsInstruments>

<CsScore>
f 1 0 1024 10 1
i 1 0 3600 			;calls the instrument, and plays for 3600 seconds
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
WindowBounds: 480 183 305 486
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41120, 40606, 41634}
ioGraph {16, 234} {266, 147} scope 2.000000 -1.000000 
ioSlider {35, 55} {146, -6} 0.000000 1.000000 0.000000 slider1
ioSlider {16, 48} {257, 38} 200.000000 1000.000000 579.766537 freq
ioSlider {15, 154} {267, 43} 0.000000 1.000000 0.067416 amp
ioText {16, 12} {231, 31} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frequency: 200-1000 Hz
ioText {16, 118} {231, 31} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amplitude: 0-1
</MacGUI>


<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
	kfreq invalue "freq"
	kamp invalue "amp"
	asig oscil kamp, kfreq, 1
	outs asig, asig
endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1 ;Sine wave
i 1 0 1000
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 594 258 429 344
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {116, 4} {160, 34} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Slider Widget
ioText {7, 45} {377, 56} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder Sliders are used to send and receive data from the running Csound using channels. If a slider's width is greater than its height it becomes a horizontal slider. You can set a slider's range in it's properties.
ioSlider {41, 109} {20, 100} 0.000000 1.000000 0.220000 amp
ioSlider {67, 109} {313, 23} 100.000000 1000.000000 456.549521 freq
ioText {140, 125} {163, 43} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frequency (from 100 to 1000 transmitting on channel 'freq'
ioText {10, 214} {86, 84} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amplitude (transmitting from 0 to 1 on channel 'amp'
ioGraph {139, 171} {241, 110} scope 2.000000 -1.000000 
</MacGUI>


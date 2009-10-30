<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
	kfreq invalue "freq" ; Quotes are needed here
	asig oscil 0.1, kfreq, 1
	outs asig, asig
endin
</CsInstruments>
<CsScore>
f 1 0 1024 10 1 ;Sine wave for table 1
i 1 0 30 ; Play for 30 seconds
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 541 244 401 416
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {14, 12} {203, 30} label 0.000000 0.00100 "" left "DejaVu Sans" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Using Widgets
ioText {12, 44} {367, 78} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder You can receive Widget values in the Csound orchestra using "channels". You use channel names to identify them, and you must set the channel name in the Widget and in the orchestra's invalue opcode.
ioText {10, 259} {367, 45} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground border Now run Csound, and notice how the widget is controlling the frequency of the oscillator
ioText {11, 154} {367, 99} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground border Enter the slider's properties by right-clicking (or control-clicking) and selecting "Properties". This will open the Widget Properties dialog, which will allow you to set the Widget's channel name. Set the channel name to "freq" (without the quotes).
ioSlider {12, 123} {363, 21} 300.000000 1000.000000 300.000000 slider
ioText {10, 310} {367, 45} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {61696, 61696, 61696} {65280, 65280, 65280} nobackground border You can change a slider's range in its preferences dialog, if you want a broader or smaller range
</MacGUI>


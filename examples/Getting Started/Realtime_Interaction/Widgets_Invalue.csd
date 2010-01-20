/* Getting Started .. Realtime Interaction: Widgets 2

Make the Widgets-panel visible, by clicking the Widgets symbol in the menu or pressing (Alt+1).

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
	kfreq invalue "freq" ; Quotes are needed here
	asig oscil 0.1, kfreq, 1
	outs asig, asig
endin
</CsInstruments>
<CsScore>
f 1 0 1024 10 1 		;Sine wave for table 1
i 1 0 300 			; Play for 300 seconds
e
</CsScore>
</CsoundSynthesizer>
; written by Andres Cabrera





<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 474 147 447 480
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {14, 12} {209, 38} label 0.000000 0.00100 "" left "Helvetica" 24 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder Using Widgets
ioText {14, 50} {363, 94} label 0.000000 0.00100 "" left "Helvetica" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground noborder You can receive Widget values in the Csound orchestra using "channels". You use channel names to identify them, and you must set the channel name in the Widget and in the orchestra's invalue opcode.
ioText {15, 320} {364, 49} label 0.000000 0.00100 "" left "Helvetica" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground border Now run Csound, and notice how the widget is controlling the frequency of the oscillator!
ioText {12, 184} {368, 101} label 0.000000 0.00100 "" left "Helvetica" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground border Enter the slider's properties by right-clicking (or control-clicking) and selecting "Properties". This will open the Widget Properties dialog, which will allow you to set the Widget's channel name. Set the channel name to "freq" (without the quotes).
ioSlider {13, 160} {366, 21} 300.000000 1000.000000 300.000000 slider
ioText {12, 409} {372, 51} label 0.000000 0.00100 "" left "Helvetica" 16 {61696, 61696, 61696} {65280, 65280, 65280} nobackground border You can change a slider's range in its properties dialog, if you want a broader or smaller range.
</MacGUI>

<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" name="Events" x="320" y="218" width="513" height="322"> 
 
 
 
 
 
 
 
 
 
 
 
 </EventPanel>
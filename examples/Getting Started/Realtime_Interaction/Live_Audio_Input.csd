/*Getting started.. Realtime Interaction: Live Audio Input

Two very common live-electronic uscases are modifying an incoming signal in realtime, or analysing it. 
To avoid acoustic feedbacks, this example, does not output the input-signal!

Here, the input's frequency and amplitude are analysed in realtime and displayed on the Widget-Panel. 
The second instrument can be started, which uses these information to control an oscillator.
(If this is using to much CPU power and does crackle, increase the buffersize in the Preferences Menu(->Run->Buffer Size). 
A good startingpoint is 1024.)
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 1
0dbfs = 1

instr 1
aInput inch 1							; read audiohardware channel 1
ifftsize = 1024							; set the buffersize for later fft-analysis
iwtype = 1   							; hanning window
fsig pvsanal   aInput, ifftsize, ifftsize/4, ifftsize, iwtype	; generate an fsig from the mono audio source
gkFreq, gkAmp pvspitch fsig, 0.01				; pitch and amplitude analysis tool
outvalue "pitch", gkFreq					; send pitch-values to Widget
outvalue "amp", gkAmp					; send amplitude-values to Widget
endin



instr 2
aSrc oscili gkAmp, gkFreq, 1					; instrument 1 uses global k-Variables, so they can be read-out here..
kFeedback=0.6						; feedback-amount for the delay
aDelay delayr 1						
aWet	deltapi 0.2
	delayw aSrc+(aWet*kFeedback)
aOut = aSrc+(aWet*0.3)					; mixing the oscillator with the delay
out aOut
endin

</CsInstruments>
<CsScore>
f 1 0 256 7 0 128 1 0 -1 128 0
i 1 0 3600							; instrument 1 runs for one hour				
e					
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 




<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 608 193 572 424
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {33924, 41634, 2056}
ioText {22, 81} {80, 25} scroll 0.000000 1.000000 "pitch" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background border 0
ioText {23, 45} {135, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Input Pitch Detection in Hz
ioButton {24, 257} {100, 30} event 1.000000 "button1" "Play Synth" "/" i2 0 20
ioText {190, 81} {80, 25} scroll 0.005510 0.000010 "amp" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background border 0.00551
ioText {188, 45} {135, 23} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amplitude Detection (0-1)
ioText {23, 162} {151, 31} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Instrument 2
ioText {23, 7} {151, 31} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Instrument 1
ioText {21, 196} {156, 61} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This button plays a synth for 20 seconds, which gets the frequency, form the input-analysis.
</MacGUI>

<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" name="Events" x="320" y="218" width="513" height="322"> 
 
 
 
 
 
 
 
 
 
 </EventPanel>
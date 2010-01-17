/* Getting Started .. Realtime Interaction: Widgets

Rember to open the Widget Panel. 

The last example demonstrated how an instrument receives values from the Widget Panel.
It's also possible to send values to the Widgets, by using 'outvalue' opcode in the instrument. 

Now, you can display values, automate faders and much more..
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 1
0dbfs = 1

instr 1 							; Move Fader
kMoveUp linseg 0, 3, 1, 1, 1, 0.5, 0
outvalue "movefader", kMoveUp
endin

</CsInstruments>
<CsScore>
i 1 0 5
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
WindowBounds: 725 155 269 480
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {28, 9} {205, 42} label 0.000000 0.00100 "" left "Lucida Grande" 20 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder 2. Run Csound !
ioSlider {42, 59} {19, 151} 0.000000 1.000000 0.417219 movefader
ioText {39, 236} {80, 25} display 0.000000 0.00100 "movefader" left "Lucida Grande" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground border 0.4172
ioText {82, 68} {122, 135} label 0.000000 0.00100 "" left "Lucida Grande" 12 {65280, 65280, 65280} {65280, 65280, 65280} nobackground border If you hover over a widget, a tooltip will appear displaying the channel, the widget is using.
ioText {37, 263} {163, 152} label 0.000000 0.00100 "" left "Lucida Grande" 12 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Widgets with the same channel, alter each other! This can be used, to display the faders value, or make exact adjustments in a scrollnumber box with the mouse.
ioText {118, 388} {80, 25} scroll 0.417200 0.000100 "movefader" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background border 0.4172
ioText {38, 216} {112, 21} label 0.000000 0.00100 "" left "Lucida Grande" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Display the value:
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" name="" x="261" y="207" width="513" height="322"> 
 
 
 
 
 
 
 
 
 
 
 
 </EventPanel>
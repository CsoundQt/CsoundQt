/* Getting Started .. Realtime Interaction: Widgets

This example concentrates on different button-types. 

Buttons send momentary values (0 or 1) to a channel. There are some reserved Channel names in QuteCsound, which enable to control QuteCsound from the Widgets Panel. In this example we use Channel "_Play", to run Csound. The button has to be in "value" mode! 
Read more about reserved channel in: (Examples-> Widgets->Reserved Channels)

The "Move Fader!" button is in "event" mode, so it sends a "scoreline-event", when pressed.

1. Open the Widgets-Panel. 
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 1
0dbfs = 1

instr 1 		; Move Fader
kMoveUp linseg 0, 3, 1, 1, 1, 0.5, 0
outvalue "movefader", kMoveUp
endin

</CsInstruments>
<CsScore>
e 3600
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 








<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 672 159 377 499
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {34, 3} {312, 32} label 0.000000 0.00100 "" left "Lucida Grande" 16 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder 2. Run Csound with the button below!
ioSlider {37, 78} {25, 136} 0.000000 1.000000 0.000000 movefader
ioText {33, 235} {80, 25} display 0.000000 0.00100 "movefader" left "Lucida Grande" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground border 0.0000
ioText {32, 215} {112, 21} label 0.000000 0.00100 "" left "Lucida Grande" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Display Values:
ioButton {35, 37} {100, 30} value 1.000000 "_Play" "Run Csound" "/" i1 0 10
ioText {135, 37} {201, 184} display 0.000000 0.00100 "" left "Lucida Grande" 12 {65280, 65280, 65280} {65280, 65280, 65280} nobackground border Look into the buttons properties: "Channel name: _Play"
ioButton {33, 282} {100, 30} event 1.000000 "" "Move Fader!" "/" i1 0 5
ioText {138, 282} {198, 113} display 0.000000 0.00100 "" left "Lucida Grande" 12 {65280, 65280, 65280} {65280, 65280, 65280} nobackground border This button is in event mode. When pressed, it sends a score line. Here it starts instrument 1."i1 0 5"
ioButton {33, 410} {100, 30} value 1.000000 "_Stop" "Stop Csound" "/" i1 0 10
ioText {144, 409} {182, 31} display 0.000000 0.00100 "" left "Lucida Grande" 12 {65280, 65280, 65280} {65280, 65280, 65280} nobackground border Reserved Channel: _Stop
ioText {135, 117} {203, 117} label 0.000000 0.00100 "" left "Lucida Grande" 12 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder _Play is a reserved channel to control QuteCsound functionality. (Run Csound) The button has to be in value mode, to send this message. 
</MacGUI>


<EventPanel name="" tempo="60.00000000" loop="8.00000000" name="" x="261" y="207" width="513" height="322"> 
 
 
 
 
 
 
 
 
 
 
 
 </EventPanel>

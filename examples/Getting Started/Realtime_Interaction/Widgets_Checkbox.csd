/* Getting Started .. Realtime Interaction: Widgets-Checkbox

Open the Widgets-Panel. 

It contains an arrangement of checkboxes and a controller-window.

The controller window is a two dimensional fader, so it sends values on two different channels.

Checkboxes work similar to buttons, but keep their last state. They work very well, to turn on/off parts of an instrument. 
The checkbox condition can be verified while the instrument runs. This is made with the "if .. then .. endif" construct.
The "if" part checks the condition. If it is <true>, then the "then" part will be executed, if it is <false>, it jumps directly to the endif.

To find out more about the possibilities and usage of widgets, have a look into the widgets reference. (Examples->Widgets) 
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
; read checkboxes
kRead invalue "read"
kSound invalue "sound"
kDance invalue "dance"


if kRead == 1 then
	; Read Point values
	kpoint_x invalue "point_x"
	kpoint_y invalue "point_y"
	printks "(x: %f, y: %f)%n", 0.2, kpoint_x, kpoint_y
endif

if kSound == 1 then
	; Sound Point
	kpoint_x invalue "point_x"
	kpoint_y invalue "point_y"
	aOut oscili kpoint_y, kpoint_x*1000, 1
	out aOut
endif

if kDance == 1 then
	; Dance Point
	knew_x unirand 1
	knew_y unirand 1
	outvalue "point_x", knew_x
	outvalue "point_y", knew_y
endif
endin


</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600
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
WindowBounds: 498 209 597 485
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {33924, 41634, 2056}
ioMeter {36, 168} {318, 253} {0, 59904, 0} "point_x" 0.865439 "point_y" 0.409289 point 7 0 mouse
ioText {37, 2} {134, 30} label 0.000000 0.00100 "" left "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1. Run Csound
ioText {37, 93} {135, 73} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Read out the point position and print it to the console.
ioText {367, 93} {120, 70} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Send random position data to the point.
ioText {188, 94} {161, 64} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Use point position data to control an oscils amplitude and frequency.
ioListing {367, 165} {183, 252}
ioText {36, 36} {514, 39} label 0.000000 0.00100 "" left "DejaVu Sans" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2. Press one of these three buttons and move the point.
ioButton {179, 2} {100, 30} value 1.000000 "_Play" "Run Csound" "/" i1 0 10
ioCheckbox {36, 73} {20, 20} on read
ioCheckbox {189, 73} {20, 20} off sound
ioCheckbox {366, 75} {20, 20} off dance
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" name="" x="320" y="218" width="513" height="322"> 
 
 
 
 
 
 
 
 
 
 
 
 </EventPanel>
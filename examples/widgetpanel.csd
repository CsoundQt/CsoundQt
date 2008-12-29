<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
; Nothing here...
endin

</CsInstruments>
<CsScore>
f 0 3600
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 648 88 458 529
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {56026, 56026, 41891}
ioSlider {17, 219} {17, 128} 0.000000 1.000000 0.383838 slider1
ioText {16, 55} {273, 155} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground border The widget panel contains widgets which can interact with Csound. It has two modes: an action mode and an edit mode. In the action mode widgets are used to send and receive values from Csound channels and can be modified using the mouse or the keyboard. In edit mode the widgets can be moved resized copied dupicated and pasted.
ioText {162, 218} {243, 126} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground border The modes are toggled using Ctrl+E or Command+E. When in edit mode red frames appear around every widget. Using these frames widgets can be moved and resized. You can also copy paste and duplicate widgets.
ioKnob {297, 49} {51, 53} 0.000000 1.000000 0.010000 0.434343 knob3
ioText {298, 109} {80, 25} editnum 4502.005000 0.001000 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4502.005000
ioButton {298, 140} {100, 30} event 1.000000 "button1" "New Button" "/" i1 0 10
ioMenu {298, 176} {80, 30} 0 303 "item1,item2,item3" menu6
ioText {42, 219} {105, 43} scroll 53.000000 1.000000 "" center "Courier New" 28 {65280, 65280, 65280} {10240, 20224, 12544} background noborder 53
ioMeter {41, 269} {107, 73} {0, 59904, 0} "vert8" 0.643836 "hor8" 0.672897 crosshair 1 0 mouse
ioText {16, 358} {291, 111} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground border Widget properties can be accessed by right clicking on the widget and selecting 'Properties'. This works on both modes. Properties are different for every widget. If you right click where there are no widgets, you can set the Widget Panel's background color.
ioCheckbox {321, 362} {20, 20} on checkbox10
ioText {319, 387} {87, 25} edit 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Type here
ioText {16, 475} {388, 41} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Note that none of the widgets shown here have effect since their channels are not being used by Csound.
ioText {75, 4} {237, 38} label 0.000000 0.00100 "" center "DejaVu Sans" 20 {0, 0, 0} {43520, 43520, 32512} background noborder The Widget Panel
</MacGUI>


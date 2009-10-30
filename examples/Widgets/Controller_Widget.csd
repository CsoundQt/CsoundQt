<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
;Nothing here...
; Widgets transmit values between themselves
; even when Csound is not running
endin

</CsInstruments>
<CsScore>
f 0 3600
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 678 180 372 672
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {53, 5} {265, 34} label 0.000000 0.00100 "" left "DejaVu Sans" 20 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Controller Widget
ioText {6, 45} {339, 81} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {48896, 52224, 59904} background noborder Controller widgets are widgets that can be used to produce data from mouse movements. Some controllers can send only one value but others can send horizontal and vertical values. All controllers have a range from 0 to 1 in both the vertical and horizontal axis.
ioText {8, 134} {160, 168} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 'fill' controller
ioMeter {18, 157} {22, 136} {46336, 59904, 38912} "fillvert" 0.485294 "hor12" 0.000000 fill 1 0 mouse
ioMeter {45, 158} {114, 25} {30720, 59904, 47872} "vert3" 0.560000 "fillhor" 0.605263 fill 1 0 mouse
ioText {47, 186} {111, 46} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Fill controllers are just like sliders.
ioText {46, 236} {112, 26} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Horizontal
ioText {103, 237} {52, 22} display 0.000000 0.00100 "fillhor" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.6053
ioText {46, 266} {112, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Vertical
ioText {98, 267} {53, 23} display 0.000000 0.00100 "fillvert" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.4853
ioText {184, 135} {160, 168} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 'llif' controller
ioMeter {191, 159} {22, 136} {41472, 50944, 59904} "llifvert" 0.757353 "hor12" 0.000000 llif 1 0 mouse
ioMeter {218, 160} {113, 17} {14336, 59904, 58368} "vert3" 0.560000 "llifhor" 0.513274 llif 1 0 mouse
ioText {218, 179} {115, 55} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Llif controllers are inverted fill controllers
ioText {219, 238} {112, 26} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Horizontal
ioText {276, 239} {52, 22} display 0.000000 0.00100 "llifhor" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.5133
ioText {220, 269} {112, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Vertical
ioText {271, 270} {53, 23} display 0.000000 0.00100 "llifvert" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.7574
ioText {10, 307} {158, 111} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 'line' controller
ioMeter {14, 329} {49, 80} {65280, 21760, 0} "linevert" 0.600000 "hor19" 0.734694 line 1 0 mouse
ioText {65, 330} {97, 50} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Line controllers are unfilled.
ioText {65, 384} {93, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Vertical
ioText {110, 385} {53, 23} display 0.000000 0.00100 "linevert" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.6000
ioText {174, 308} {173, 203} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 'crosshair' controller
ioMeter {178, 329} {164, 116} {43520, 21760, 65280} "crossy" 0.836207 "crossx" 0.554878 crosshair 1 0 mouse
ioText {183, 450} {83, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border X =
ioText {209, 451} {52, 22} display 0.000000 0.00100 "crossx" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.5549
ioText {183, 480} {88, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Y =
ioText {208, 481} {53, 23} display 0.000000 0.00100 "crossy" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.8362
ioText {12, 424} {158, 206} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 'point' controller
ioMeter {16, 445} {148, 105} {65280, 65280, 65280} "pointy" 0.714286 "pointx" 0.328947 point 4 0 mouse
ioText {47, 556} {83, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border X =
ioText {72, 557} {52, 22} display 0.000000 0.00100 "pointx" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.3289
ioText {44, 585} {88, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Y =
ioText {69, 586} {53, 23} display 0.000000 0.00100 "pointy" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.7143
ioText {176, 516} {172, 114} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Receiving
ioMeter {184, 543} {76, 77} {65280, 65280, 65280} "pointy" 0.714286 "pointx" 0.328947 point 4 0 mouse
ioMeter {265, 542} {76, 78} {43520, 21760, 65280} "crossy" 0.836207 "crossx" 0.554878 crosshair 1 0 mouse
</MacGUI>


<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; This table maps menu values to vco2 oscillator modes
giwavemodes ftgen 0, 0, 8, -2, 0, 10, 12

instr 1 ;read widgets
; When values from sliders are to be used on the init pass,
; they must be read outside the instrument, because
; they are not read during the init pass
gkwave invalue "wave"
gkfreq invalue "freq"
endin

instr 10
kenv adsr p3/5, p3/5, 0.6, p3/2
imode tab_i i(gkwave), giwavemodes
aout  vco2  0.1, i(gkfreq), imode
outs aout*kenv, aout*kenv
endin

</CsInstruments>
<CsScore>
i 1 0 3600
f 0 3600
</CsScore>
</CsoundSynthesizer>
















<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 207 334 373 293
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioMenu {25, 30} {120, 30} 1 303 "saw,square,triangle" wave
ioText {150, 31} {202, 26} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 8 {65280, 65280, 65280} {8192, 8192, 8192} background noborder Select waveform from this menu
ioSlider {25, 70} {180, 20} 200.000000 800.000000 703.030303 freq
ioText {220, 65} {130, 25} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Frequency
ioButton {26, 98} {180, 40} event 1.000000 "button1" "Generate note" "/" i10 0 5
ioText {208, 100} {130, 36} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Push this button to generate notes
ioText {28, 148} {308, 101} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {43264, 48896, 30720} background noborder 
ioText {42, 180} {277, 66} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Values for waveform and frequency are only applied during the init pass so they remain constant for every note. Changes only apply for new notes
ioText {118, 153} {105, 24} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 14 {20992, 28416, 16128} {65280, 65280, 65280} nobackground noborder No Reinit
</MacGUI>


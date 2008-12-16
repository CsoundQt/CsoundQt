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

instr 1  ;read widgets
; When values from sliders are to be used on the init pass,
; they must be read outside the instrument, because
; they are not read during the init pass
	gkwave invalue "wave"
	gkfreq invalue "freq"
	gkfreq portk gkfreq, 0.05 ;smooth frequency values
endin

instr 10
	ktrig  changed  gkwave
	if ktrig = 1 then
		; forces a new init pass from label newwaveform
		; this makes waveform change even if a note is already on
		reinit newwaveform
	endif

;The envelope is outside the reinit loop, otherwise it is reinitialized
	kenv adsr p3/5, p3/5, 0.6, p3/2

newwaveform:
	prints "instr 1-init"
	imode tab_i i(gkwave), giwavemodes ;This line is only run every init pass
	aout  vco2  0.3, gkfreq, imode ;This line must be within the reinit section
	rireturn ;End of reinit section

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
WindowBounds: 375 245 361 291
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioMenu {11, 8} {120, 30} 1 303 "saw,square,triangle" wave
ioText {137, 8} {205, 26} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 8 {65280, 65280, 65280} {8192, 8192, 8192} background noborder Select waveform from this menu
ioSlider {11, 44} {180, 20} 200.000000 800.000000 406.060606 freq
ioText {207, 39} {130, 25} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Frequency
ioButton {11, 71} {180, 40} event 1.000000 "button1" "Generate note" "/" i10 0 5
ioText {196, 69} {148, 44} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Push this button to generate notes
ioText {10, 117} {332, 131} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {39168, 40448, 25600} background noborder 
ioText {121, 130} {91, 26} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 14 {33536, 16640, 12288} {65280, 65280, 65280} nobackground noborder Reinit
ioText {18, 160} {313, 73} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 8 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder Using a reinit pass values for vco2 waveform (which is i-rate) are changed. Values for frequency are no longer used with i() so they change whenever the slider changes
</MacGUI>


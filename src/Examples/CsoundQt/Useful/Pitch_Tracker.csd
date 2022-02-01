<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1


gSnotes = "CcDdEFfGgAaB"

instr 1
kth invalue "th"
ka3 invalue "a3"

asig inch 1

kcps, kamp  ptrack  asig, 4096
kcps portk kcps, 0.02

if kamp > kth then
	knote = 69 + (12 *( log(kcps/440) / log(2) ) )
	kpchclass = int( knote% 12 )
	kfrac = frac(knote)
	if kfrac > 0.5 then
		kfrac = kfrac - 1
		kpchclass = kpchclass + 1
	endif
	kcents = kfrac * 100
	kcents portk kcents, 0.02
	Sname strsubk gSnotes, kpchclass, kpchclass + 1
	kchr strchark Sname
	if kchr > 95 then
		Sname strupperk Sname
		Sname strcatk Sname, "#"
	endif
	outvalue "cents", kcents
	outvalue "note", Sname
	outvalue "midinote", knote
	outvalue "freq", kcps
endif
endin


</CsInstruments>
<CsScore>
i 1 0 3000
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 731 205 372 403
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35209, 28784, 9252}
ioText {43, 85} {115, 35} display 62.607059 0.00100 "freq" left "Heiti SC Light" 20 {0, 0, 0} {65280, 65280, 65280} background border 62.6071
ioSlider {246, 58} {29, 165} -40.000000 0.000000 -26.909091 th
ioText {224, 225} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Threshold (dB)
ioText {224, 250} {80, 25} display -26.909091 0.00100 "th" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border -26.9091
ioText {218, 307} {94, 27} editnum 440.000000 0.001000 "a3" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 440.000000
ioText {218, 282} {94, 27} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A3 (Hz)
ioText {44, 151} {122, 34} display 35.242725 0.00100 "midinote" left "Heiti SC Light" 20 {0, 0, 0} {65280, 65280, 65280} background border 35.2427
ioText {43, 60} {94, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frequency (Hz)
ioText {44, 126} {94, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder MIDI note
ioText {45, 216} {122, 34} display 0.000000 0.00100 "note" left "Heiti SC Light" 20 {0, 0, 0} {65280, 65280, 65280} background border B
ioText {45, 191} {94, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Note
ioText {8, 260} {193, 79} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Cents
ioSlider {13, 281} {183, 22} -50.000000 50.000000 23.770492 cents
ioText {66, 306} {80, 25} display 23.770492 0.00100 "cents" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 23.7705
ioText {13, 8} {334, 36} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65024, 54784} background noborder Pitch Tracker
</MacGUI>


<CsoundSynthesizer>
<CsOptions>
;--env:SADIR=
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

#define FILE1 #"/Library/Frameworks/CsoundLib.framework/Resources/samples/hrtf-44100-left.dat"#
#define FILE2 #"/Library/Frameworks/CsoundLib.framework/Resources/samples/hrtf-44100-right.dat"#

#define HRTFCOMPACT #"/Library/Frameworks/CsoundLib.framework/Resources/Manual/Examples/HRTFCompact"#
#define FOX #"/Library/Frameworks/CsoundLib.framework/Resources/Manual/Examples/fox.wav"#


instr 1
ksource invalue "source"
kamp invalue "amp"
kpfreq invalue "pfreq"

if ksource == 0 then
	asig noise kamp, 0

elseif ksource == 1 then
	asig pinkish kamp * 0.7

elseif ksource == 2 then
	asig vco2 kamp, kpfreq, 

elseif ksource == 3 then
	kphs phasor 1
	asig noise kamp * ( kphs > 0.1 ? 0 : 1 ), 0

elseif ksource == 4 then
	asig diskin2 $FOX, 1, 0, 1
endif

kx invalue "x"
ky invalue "y"
kz invalue "z"

kx = 0.5 - kx
ky = ky - 0.5
kz = 0.5 - kz

if kz > 0 then
	kAz = 360 * taninv( kx/kz ) / (2 * $M_PI.)
elseif kz < 0 then
	if kx > 0 then
		kAz = 180 + (360 * taninv( kx/kz ) / (2 * $M_PI.))
	else
		kAz = (360 * taninv( kx/kz ) / (2 * $M_PI.)) - 180
	endif
endif
kAz = kAz + 180

kEl = 360 * taninv( ky/sqrt(kx^2 + kz^2) ) / (2 * $M_PI.)

outvalue "az", kAz
outvalue "el", kEl

kmethod invalue "hrtfmethod"
if kmethod == 0 then
	aleft, aright  hrtfer  asig * 200, kAz, kEl, $HRTFCOMPACT
elseif kmethod == 1 then
	aleft, aright  hrtfmove2  asig, kAz, kEl, $FILE1, $FILE2 ;[,ioverlap, iradius, isr]
elseif kmethod == 2 then
	aleft, aright  pan2  asig * 0.6, -kx + 0.5
endif

outs aleft, aright
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>

<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 327 201 715 488
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {40606, 52428, 62451}
ioMeter {399, 35} {231, 218} {0, 59904, 0} "y" 0.518349 "z" 0.963303 point 3 0 mouse
ioMeter {59, 35} {231, 218} {0, 59904, 0} "z" 0.963303 "x" 0.484848 point 3 0 mouse
ioText {357, 128} {43, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Back
ioText {500, 6} {43, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Up
ioText {496, 260} {43, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Down
ioText {150, 5} {61, 27} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Front
ioText {161, 265} {31, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Back
ioText {296, 129} {43, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Right
ioText {13, 126} {43, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Left
ioMenu {14, 392} {115, 25} 4 303 "white noise,pink noise,pulse,noise bursts,voice" source
ioKnob {185, 320} {83, 81} 0.000000 600.000000 0.010000 200.000000 pfreq
ioText {188, 402} {80, 25} display 0.000000 0.00100 "pfreq" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 212.1212
ioSlider {147, 301} {20, 100} 0.000000 0.300000 0.063000 amp
ioText {307, 185} {80, 25} display 0.000000 0.00100 "az" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 358.1269
ioText {309, 238} {80, 25} display 0.000000 0.00100 "el" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 2.2667
ioKnob {490, 118} {45, 42} 0.000000 1.000000 0.010000 0.797980 knob19
ioSlider {503, 150} {20, 63} 0.000000 1.000000 0.444444 slider21
ioSlider {144, 126} {65, 27} 0.000000 1.000000 0.446154 slider21
ioKnob {154, 119} {45, 42} 0.000000 1.000000 0.010000 0.515152 knob20
ioText {309, 161} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Azimuth
ioText {309, 214} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Elevation
ioMenu {14, 341} {111, 26} 1 303 "hrtfer,hrtfmove2,amp pan" hrtfmethod
ioButton {280, 317} {147, 30} value 1.000000 "_Play" "Start" "/" 
ioButton {280, 346} {147, 29} value 1.000000 "_Stop" "Stop" "/" 
ioText {14, 316} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Method
ioText {14, 368} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Signal
ioText {441, 316} {187, 117} label 0.000000 0.00100 "" center "Lucida Grande" 28 {0, 0, 0} {39168, 60672, 65280} background noborder Binaural panning
ioText {140, 402} {42, 26} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
ioText {497, 396} {77, 36} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Listen on headphones!
ioText {632, 126} {57, 29} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Front
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>
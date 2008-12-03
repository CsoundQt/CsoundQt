<CsoundSynthesizer>
<CsOptions>
;-+rtaudio=jack -idac -odac -+jack_client=Csound
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 128
nchnls = 1
0dbfs = 1

turnon 1
fsig2  pvsinit   1024, 256, 1024, 0

instr 1
klearning init 0
ifftsize = 1024
ioverlap = 256
iwinsize = 1024
iwintype = 0

kratio invalue "ratio"
kgain invalue "gain"
klearn invalue "learn"
kbypass invalue "bypass"

ain inch 1

if kbypass == 1 then
	aout = ain
else
	fsig  pvsanal  ain, ifftsize, ioverlap, iwinsize, iwintype
	ffilt pvstencil fsig, kratio, kgain, 1
	aout  pvsynth  ffilt
endif
	
out aout

if klearn == 1 then
	krms rms ain
	if krms > 0.00000001 then
		klearning = klearning + 1
		kflag pvsftw fsig, 2
		vaddv  1, 2, 1024
	endif
elseif klearning > 0 then
	vmult 1, 1/klearning, 1024
	klearning = 0
endif

outvalue  "learning", (klearning == 0 ? 0:1)
endin

instr 2 ;clear mask table
	gin  ftgen  1, 0, 1024, 2, 0
	turnoff
endin

instr 3 ;mask white noise
	gin  ftgen  1, 0, 1024, -7, 0.006, 1024, 0.006
	turnoff
endin

</CsInstruments>
<CsScore>
f 1 0 1024 -7 0.006 1024 0.006
f 2 0 1024 2 0 ;temp amp table
f 0 3600
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 72 179 850 930
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioSlider {5, 5} {20, 200} 0.000000 1.000000 0.000000 ratio
ioSlider {45, 5} {20, 200} 0.000000 0.100000 0.100000 gain
ioText {1, 200} {45, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ratio
ioText {40, 200} {50, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Gain
ioCheckbox {75, 180} {30, 30} off learn
ioText {90, 183} {60, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {37632, 13312, 3584} {65280, 65280, 65280} nobackground noborder Learn
ioButton {75, 180} {100, 25} event 1.000000 "button1" "Clear mask" "/" i2 0 1
ioCheckbox {75, 130} {30, 30} on 
ioText {90, 135} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Bypass
ioText {75, 5} {160, 125} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {32512, 28672, 24064} {49664, 49664, 49664} background border This noise reduction unit can sample a noise print and then remove it through spectral masking. First clear the mask then activate the learn while the noise is playing. Deactivate the learn button and the noise will be removed.
ioCheckbox {158, 195} {30, 30} off learning
ioButton {190, 180} {110, 25} event 1.000000 "white" "Mask white noise" "/" i3 0 1
</MacGUI>


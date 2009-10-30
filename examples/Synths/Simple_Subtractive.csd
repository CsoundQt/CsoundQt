<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 --midi-velocity=5
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; Make sure CsOptions are not ignored in the preferences,
; Otherwise Realtime MIDI input will not work.

giatttimemax = 2
gidectimemax = 2
gireltimemax = 4

instr 1  ;Subtractive synth
kosctype invalue "osctype"

kftype invalue "ftype"
kffreq invalue "ffreq"
kffreq portk kffreq, 0.02 ;smooth signal
kfres invalue "fres"
kfres portk kfres, 0.02 ;smooth signal
kfatt invalue "fatt"
kfdec invalue "fdec"
kfsus invalue "fsus"
kfrel invalue "frel"
kfenvamt invalue "fenvamt"

kaatt invalue "aatt"
kadec invalue "adec"
kasus invalue "asus"
karel invalue "arel"

klvl invalue "lvl"

ifreq = p4  ;in cps
iamp = (p5/127) ;MIDI velocity to linear amp

itype = i(kosctype)

if (itype == 0) then
	aosc oscil iamp, ifreq, 1
elseif (itype == 1) then
	aosc oscil iamp, ifreq, 2
elseif (itype == 2) then
	aosc vco2 iamp, ifreq
elseif (itype == 3) then
	aosc vco2 iamp, ifreq, 2, 0.5
endif

kfenv madsr giatttimemax*i(kfatt), gidectimemax*i(kfdec), i(kfsus), gireltimemax*i(kfrel)
kfenv = (kfenv*kfenvamt) + 1

if (kftype == 0) then
	aosc moogladder aosc, kffreq*kfenv, kfres
elseif (kftype == 1) then
	aosc moogvcf2 aosc, kffreq*kfenv, kfres
elseif (kftype == 2) then
	aosc rezzy aosc, kffreq*kfenv, kfres*100
elseif (kftype == 3) then
	aosc lowresx aosc, kffreq*kfenv, kfres/3
endif

aenv madsr giatttimemax*i(kaatt), gidectimemax*i(kadec), i(kasus), gireltimemax*i(karel)

outs aosc*aenv*klvl, aosc*aenv*klvl
endin

instr 98 ; Play note
	koscfreq invalue "oscfreq"
	event "i", 1, 0, 3, i(koscfreq), 100
	turnoff
endin

instr 99 ; Always on

kcont invalue "cont"
koscfreq invalue "oscfreq"

if kcont == 1 then
	ktrig metro 0.5
	schedkwhen ktrig, 0.1, 10, 1, 0, 1, koscfreq, 100
endif
endin


</CsInstruments>
<CsScore>
f 1 0 1024 7 -1 1024 1 ;Saw wave
f 2 0 1024 7 1 512 1 0 -1 512 -1 ;Square wave

i 99 0 3600
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 502 235 613 433
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {32125, 41634, 41120}
ioText {216, 38} {243, 189} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Filter
ioKnob {228, 46} {56, 49} 100.000000 5000.000000 0.010000 495.959596 ffreq
ioText {232, 89} {58, 26} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Cut Freq
ioKnob {230, 111} {55, 48} 0.000000 1.000000 0.010000 0.424242 fres
ioText {220, 154} {77, 24} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Resonance
ioMenu {339, 61} {110, 25} 1 303 "moogladder, moogvcf2, rezzy, lowresx" ftype
ioText {292, 63} {53, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Opcode 
ioSlider {331, 94} {20, 100} 0.000001 1.000000 0.270001 fatt
ioSlider {358, 94} {20, 100} 0.000001 1.000000 0.240001 fdec
ioSlider {383, 94} {20, 100} 0.000000 1.000000 0.280000 fsus
ioSlider {410, 94} {20, 100} 0.000001 1.000000 0.020001 frel
ioText {331, 194} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {359, 194} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {384, 194} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {410, 193} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {465, 38} {124, 189} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Amp Env
ioText {9, 38} {200, 189} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Oscillator
ioMenu {18, 64} {154, 24} 2 303 "Saw,Square,Band-Lim. Saw,Band-lim Square" osctype
ioSlider {479, 59} {20, 100} 0.000001 1.000000 0.000001 aatt
ioSlider {506, 59} {20, 100} 0.000001 1.000000 0.000001 adec
ioSlider {531, 59} {20, 100} 0.000000 1.000000 0.520000 asus
ioSlider {558, 59} {20, 100} 0.000001 1.000000 0.100001 arel
ioText {480, 158} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {508, 158} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {533, 158} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {559, 157} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {7, 1} {583, 29} label 0.000000 0.00100 "" center "DejaVu Sans" 12 {0, 0, 0} {49152, 59136, 65280} background noborder Simple subtractive synth
ioButton {19, 118} {93, 28} event 1.000000 "" "Note" "/" i98 0 3
ioKnob {111, 104} {83, 50} 110.000000 880.000000 0.010000 366.666667 oscfreq
ioText {160, 154} {35, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Hz
ioKnob {529, 177} {56, 50} 0.000000 1.000000 0.010000 0.575758 lvl
ioText {485, 192} {45, 26} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
ioText {112, 159} {49, 23} scroll 374.400000 0.100000 "oscfreq" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 374.4
ioGraph {9, 235} {580, 148} scope 2.000000 1.000000 
ioKnob {284, 182} {47, 38} 0.000000 4.000000 0.010000 4.000000 fenvamt
ioText {219, 190} {77, 24} label 0.000000 0.00100 "" center "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Env Amount
ioCheckbox {23, 186} {20, 20} off cont
ioText {36, 185} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Continuous notes
</MacGUI>


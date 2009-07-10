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

instr 1 ; Simple three operator FM synth
; The operators are chained like this:
; mod1 -> mod2 -> carrier

ifreq = p4  ; From p4 in the score or cps from MIDI note

; Mod1 envelope 
kmod1att invalue "mod1att"
kmod1dec invalue "mod1dec"
kmod1sus invalue "mod1sus"
kmod1rel invalue "mod1rel"
amod1env madsr i(kmod1att), i(kmod1dec), i(kmod1sus), i(kmod1rel)

kmod1index invalue "mod1index"
kmod1factor invalue "mod1factor"
kmod2factor invalue "mod2factor"
; Modulator 1
; modamp = modenv * modindex * carrierfreq
amod1 poscil amod1env*kmod1index*ifreq*kmod2factor, kmod1factor*ifreq, 1

; Mod 2 envelope
kmod2att invalue "mod2att"
kmod2dec invalue "mod2dec"
kmod2sus invalue "mod2sus"
kmod2rel invalue "mod2rel"
amod2env madsr i(kmod2att), i(kmod2dec), i(kmod2sus), i(kmod2rel)

; Modulator 2
kmod2index invalue "mod2index"
amod2 poscil amod2env*kmod2index*ifreq, (kmod2factor*ifreq)+amod1, 1

;Carrier amp envelope
kaatt invalue "aatt"
kadec invalue "adec"
kasus invalue "asus"
karel invalue "arel"
aenv madsr i(kaatt), i(kadec), i(kasus), i(karel)

; Carrier
aout poscil aenv, ifreq+amod2, 1

; Output
klevel invalue "level"
outs aout*klevel, aout*klevel
endin

instr 98 ; Trigger instrument from button
kfreq invalue "freq"
event "i", 1, 0, p3, kfreq
turnoff
endin

instr 99 ;Always on instrument
; This instrument updates the modulator's frequencies
; which depend on the base frequency and the freq.
; factors.
kfreq invalue "freq"
kmod1factor invalue "mod1factor"
kmod2factor invalue "mod2factor"

outvalue "mod1freq", kfreq*kmod1factor
outvalue "mod2freq", kfreq*kmod2factor
endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1
i 99 0 3600
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 470 219 445 612
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {38550, 41634, 35209}
ioText {303, 57} {124, 189} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Carrier Amp Env
ioSlider {317, 78} {20, 100} 0.000001 1.000000 0.200001 aatt
ioSlider {344, 78} {20, 100} 0.000001 1.000000 0.230001 adec
ioSlider {369, 78} {20, 100} 0.000000 1.000000 0.680000 asus
ioSlider {396, 78} {20, 100} 0.000001 1.000000 0.460001 arel
ioText {319, 177} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {347, 177} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {372, 177} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {397, 176} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioKnob {367, 196} {56, 50} 0.000000 1.000000 0.010000 0.262626 level
ioText {323, 211} {45, 26} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
ioButton {316, 254} {93, 28} event 1.000000 "" "Note" "/" i98 0 3
ioKnob {322, 293} {83, 50} 110.000000 880.000000 0.010000 180.000000 freq
ioText {372, 342} {35, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Hz
ioText {322, 348} {49, 23} scroll 180.000000 0.100000 "freq" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 180.0
ioText {2, 4} {365, 44} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 20 {65280, 65280, 65280} {21760, 21760, 0} background noborder Simple FM Synth
ioText {4, 57} {291, 154} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Modulator 1
ioSlider {18, 78} {20, 100} 0.000001 1.000000 0.700000 mod1att
ioSlider {45, 78} {20, 100} 0.000001 1.000000 0.720000 mod1dec
ioSlider {70, 78} {20, 100} 0.000000 1.000000 0.400000 mod1sus
ioSlider {97, 78} {20, 100} 0.000001 1.000000 0.140001 mod1rel
ioText {20, 178} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {48, 178} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {73, 178} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {98, 177} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {206, 77} {78, 25} editnum 0.250000 0.010000 "mod1factor" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.250000
ioText {124, 78} {82, 24} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Freq factor
ioText {124, 107} {82, 25} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder FrequencyÂ¬Â¬hfghdÂ¬Â¬dhfghd
ioText {204, 107} {81, 26} display 0.000000 0.00100 "mod1freq" left "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 45.0000
ioText {4, 222} {291, 155} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Modulator 2
ioSlider {18, 243} {20, 100} 0.000001 1.000000 0.490001 mod2att
ioSlider {45, 243} {20, 100} 0.000001 1.000000 0.710000 mod2dec
ioSlider {70, 243} {20, 100} 0.000000 1.000000 0.640000 mod2sus
ioSlider {97, 243} {20, 100} 0.000001 1.000000 0.750000 mod2rel
ioText {20, 343} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {48, 343} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {73, 343} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {98, 342} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {206, 242} {78, 25} editnum 2.000000 0.010000 "mod2factor" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioText {124, 243} {82, 24} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Freq factor
ioText {124, 272} {80, 25} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frequency
ioText {204, 272} {81, 26} display 0.000000 0.00100 "mod2freq" left "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 360.0000
ioKnob {134, 136} {52, 51} 0.000000 1.000000 0.010000 0.939394 mod1index
ioText {122, 185} {80, 25} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Mod index
ioKnob {134, 298} {52, 51} 0.000000 1.000000 0.010000 0.898990 mod2index
ioText {122, 347} {80, 25} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Mod index
ioGraph {3, 383} {422, 186} scope 4.000000 1.000000 
</MacGUI>


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

instr 1 ; Simple two operator FM synth

ifreq = p4  ; From p4 in the score or cps from MIDI note

kmodfactor invalue "modfactor"
kmodindex invalue "modindex"
; Mod envelope 
kmodatt invalue "modatt"
kmoddec invalue "moddec"
kmodsus invalue "modsus"
kmodrel invalue "modrel"
amodenv madsr i(kmodatt), i(kmoddec), i(kmodsus), i(kmodrel)

kmodfreq = kmodfactor*ifreq
; Index = Am * fc/fm
kmodamp = kmodindex*kmodfactor*ifreq
; Modulator 2
amod poscil amodenv*kmodamp, kmodfreq, 1

;Carrier amp envelope
kaatt invalue "aatt"
kadec invalue "adec"
kasus invalue "asus"
karel invalue "arel"
aenv madsr i(kaatt), i(kadec), i(kasus), i(karel)

; Carrier
aout poscil aenv, ifreq+amod, 1

; Output
klevel invalue "level"
outvalue "index", kmodindex

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
kmodfactor invalue "modfactor"
outvalue "mod1freq", kfreq*kmodfactor

; Display spectrum
aoutl, aoutr monitor
dispfft aoutl, 0.2, 4096

;Turn on or off according to checkbox

kon invalue "on"
ktrig changed kon

if ktrig == 1 then
	if kon == 1 then
		event "i", 1, 0, -1, kfreq
	elseif kon == 0 then
		turnoff2 1, 0, 1
	endif
endif

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
WindowBounds: 743 25 448 539
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {38550, 41634, 35209}
ioText {303, 57} {124, 189} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Carrier Amp Env
ioSlider {317, 78} {20, 100} 0.000001 1.000000 0.050001 aatt
ioSlider {344, 78} {20, 100} 0.000001 1.000000 0.110001 adec
ioSlider {369, 78} {20, 100} 0.000000 1.000000 0.680000 asus
ioSlider {396, 78} {20, 100} 0.000001 1.000000 0.460001 arel
ioText {319, 177} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {347, 177} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {372, 177} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {397, 176} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioKnob {367, 196} {56, 50} 0.000000 1.000000 0.010000 0.232323 level
ioText {323, 211} {45, 26} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
ioButton {326, 255} {93, 28} event 1.000000 "" "Note" "/" i98 0 3
ioKnob {326, 288} {48, 49} 110.000000 880.000000 0.010000 358.888889 freq
ioText {360, 336} {35, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Hz
ioText {310, 341} {49, 23} scroll 358.900000 0.100000 "freq" right "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 358.9
ioText {7, 3} {421, 46} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 20 {65280, 65280, 65280} {21760, 21760, 0} background noborder Simple FM Synth
ioText {7, 57} {291, 189} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border Modulator
ioSlider {18, 91} {20, 100} 0.000001 1.000000 0.120001 modatt
ioSlider {45, 91} {20, 100} 0.000001 1.000000 0.620000 moddec
ioSlider {70, 91} {20, 100} 0.000000 1.000000 1.000000 modsus
ioSlider {97, 91} {20, 100} 0.000001 1.000000 0.000001 modrel
ioText {20, 191} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder A
ioText {48, 191} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder D
ioText {73, 191} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder S
ioText {98, 190} {18, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder R
ioText {209, 71} {78, 25} editnum 0.500000 0.010000 "modfactor" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.500000
ioText {127, 72} {82, 24} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Freq factor
ioText {127, 101} {82, 25} label 0.000000 0.00100 "" left "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frequency
ioText {207, 101} {81, 26} display 179.444443 0.00100 "mod1freq" left "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 179.4444
ioKnob {136, 151} {52, 51} 0.000000 5.000000 0.010000 2.929293 modindex
ioText {124, 201} {80, 25} label 0.000000 0.00100 "" center "Bitstream Vera Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Index
ioGraph {6, 256} {312, 107} scope 4.000000 1.000000 
ioGraph {7, 367} {411, 122} table 0.000000 5.000000 
ioText {187, 162} {80, 25} display 2.929293 0.00100 "index" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.9293
ioCheckbox {378, 292} {20, 20} off on
ioText {394, 291} {28, 24} label 0.000000 0.00100 "" left "DejaVu Sans" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder On
</MacGUI>


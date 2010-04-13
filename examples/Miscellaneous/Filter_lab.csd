<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; This file implements as UDOs the basic parametric equalizers from
; Zoelzer's DAFX book (Chapter 2).
; They are a set of calculations for biquad filter coefficients to
; produce controllable second order filters.

opcode lpf2pole, a, ak
ain,kfc xin
kvalue = tan($M_PI * kfc / sr)

ktrig changed kvalue
if ktrig == 1 then
	kdenom = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
	knumb0 = (kvalue^2)
	kb0 = knumb0/kdenom
	knumb1 = 2 * (kvalue^2)
	kb1 = knumb1/kdenom
	knumb2 = (kvalue^2)
	kb2 = knumb2/kdenom
	knuma1 = 2 *((kvalue^2) - 1)
	ka1 = knuma1/kdenom
	knuma2 = 1 - ($M_SQRT2 * kvalue) + (kvalue^2)
	ka2 = knuma2/kdenom
	Sdisp sprintfk "b0=%.3f      b1=%.3f      b2=%.3f\n\na1=%.3f      a2=%.3f", kb0, kb1, kb2, ka1, ka2
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, kb2, 1, ka1, ka2 
xout afilt
endop

opcode hpf2pole, a, ak
ain,kfc xin
kvalue = tan($M_PI * kfc / sr)

ktrig changed kvalue
if ktrig == 1 then
	kdenom = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
	knum0 = 1
	kb0 = knum0/kdenom
	knumb1 = -2
	kb1 = knumb1/kdenom
	knumb2 = 1
	kb2 = knumb2/kdenom
	knuma1 = 2 *((kvalue^2) - 1)
	ka1 = knuma1/kdenom
	knuma2 = 1 - ($M_SQRT2 * kvalue) + (kvalue^2)
	ka2 = knuma2/kdenom
	Sdisp sprintfk "b0=%.3f      b1=%.3f      b2=%.3f\n\na1=%.3f      a2=%.3f", kb0, kb1, kb2, ka1, ka2
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, kb2, 1, ka1, ka2 
xout afilt
endop

opcode loshelf, a, akk
ain,kfc, kgain xin
kvalue = tan($M_PI * kfc / sr)

ktrig changed kvalue, kgain
if ktrig == 1 then
	if kgain >= 0 then
		kV0 = 10^(kgain/20)
		kdenom = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
		knumb0 = 1 + (sqrt(2*kV0) * kvalue) + (kV0 * kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kV0 * kvalue^2) - 1)
		kb1 = knumb1/kdenom
		knumb2 = 1 - (sqrt(2*kV0) * kvalue) + (kV0 * kvalue^2)
		kb2 = knumb2/kdenom
		knuma1 = 2 *((kvalue^2) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - ($M_SQRT2 * kvalue) + (kvalue^2)
		ka2 = knuma2/kdenom
	else
		kV0 = 10^(-kgain/20)
		kdenom = 1 + (sqrt(2*kV0) * kvalue) + (kV0 * kvalue^2)
		knumb0 = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kvalue^2) - 1 )
		kb1 = knumb1/kdenom
		knumb2 = 1 - (sqrt(2*kV0) * kvalue) + (kvalue^2)
		kb2 = knumb2/kdenom
		knuma1 = 2 *((kV0 * kvalue^2) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - (sqrt(2*kV0) * kvalue) + (kV0 * kvalue^2)
		ka2 = knuma2/kdenom

	endif
	Sdisp sprintfk "b0=%.3f      b1=%.3f      b2=%.3f\n\na1=%.3f      a2=%.3f", kb0, kb1, kb2, ka1, ka2
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, kb2, 1, ka1, ka2 
xout afilt
endop

opcode hishelf, a, akk
ain,kfc, kgain xin
kvalue = tan($M_PI * kfc / sr)
kV0 = 10^(kgain/20)

ktrig changed kvalue, kgain
if ktrig == 1 then
	if kgain >= 0 then
		kV0 = 10^(kgain/20)
		kdenom = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
		knumb0 = kV0 + (sqrt(2*kV0) * kvalue) + (kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kvalue^2) - kV0)
		kb1 = knumb1/kdenom
		knumb2 = kV0 - (sqrt(2*kV0) * kvalue) + (kvalue^2)
		kb2 = knumb2/kdenom
		knuma1 = 2 *((kvalue^2) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - ($M_SQRT2 * kvalue) + (kvalue^2)
		ka2 = knuma2/kdenom
	else
		kV0 = 10^(-kgain/20)
		kdenom = kV0 + (sqrt(2*kV0) * kvalue) + (kvalue^2)
		knumb0 = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kvalue^2) - 1 )
		kb1 = knumb1/kdenom
		knumb2 = 1 - ($M_SQRT2 * kvalue) + (kvalue^2)
		kb2 = knumb2/kdenom
		kdenom = 1 + (sqrt(2/kV0) * kvalue) + ((kvalue^2)/ kV0)
		knuma1 = 2 *(((kvalue^2)/ kV0) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - (sqrt(2/kV0) * kvalue) + ((kvalue^2)/ kV0)
		ka2 = knuma2/kdenom

	endif
	Sdisp sprintfk "b0=%.3f      b1=%.3f      b2=%.3f\n\na1=%.3f      a2=%.3f", kb0, kb1, kb2, ka1, ka2
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, kb2, 1, ka1, ka2 
xout afilt
endop

opcode eq2pole, a, akkk
ain,kfc, kgain, kQ xin
kvalue = tan($M_PI * kfc / sr)
kV0 = 10^(kgain/20)

ktrig changed kvalue, kV0, kQ
if ktrig == 1 then
	if kgain >= 0 then
		kV0 = 10^(kgain/20)
		kdenom = 1 + (kvalue / kQ) + (kvalue^2)
		knumb0 = 1 + (kV0 * kvalue / kQ) + (kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kvalue^2) - 1)
		kb1 = knumb1/kdenom
		knumb2 = 1 - (kV0 * kvalue / kQ) + (kvalue^2)
		kb2 = knumb2/kdenom
		knuma1 = 2 *((kvalue^2) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - (kvalue / kQ) + (kvalue^2)
		ka2 = knuma2/kdenom
	else
		kV0 = 10^(-kgain/20)
		kdenom = 1 + (kV0 * kvalue / kQ) + (kvalue^2)
		knumb0 = 1 + (kvalue / kQ) + (kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kvalue^2) - 1)
		kb1 = knumb1/kdenom
		knumb2 = 1 - (kvalue / kQ) + (kvalue^2)
		kb2 = knumb2/kdenom
		knuma1 = 2 *((kvalue^2) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - (kV0 * kvalue / kQ) + (kvalue^2)
		ka2 = knuma2/kdenom

	endif
	Sdisp sprintfk "b0=%.3f      b1=%.3f      b2=%.3f\n\na1=%.3f      a2=%.3f", kb0, kb1, kb2, ka1, ka2
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, kb2, 1, ka1, ka2 
xout afilt
endop


instr 1
anoise noise 1, 0
ktype invalue "type"
kfreq invalue "freq"
kgain invalue "gain"
kQ invalue "Q"

if ktype == 0 then
	afilt lpf2pole anoise, kfreq
elseif ktype == 1 then
	afilt hpf2pole anoise, kfreq
elseif ktype == 2 then
	afilt loshelf anoise, kfreq, kgain
elseif ktype == 3 then
	afilt hishelf anoise, kfreq, kgain
elseif ktype == 4 then
	afilt eq2pole anoise, kfreq, kgain, kQ
else
	afilt = anoise
endif

dispfft afilt, 0.5, 4096
aout = afilt*0.02
aout clip aout, 0, 0.3 ; For ear and speaker protection from unstable filters
outs aout, aout
endin


</CsInstruments>
<CsScore>
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
WindowBounds: 669 200 737 495
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {52428, 52428, 52428}
ioSlider {9, 205} {709, 35} 1.000000 22050.000000 3701.748942 freq
ioGraph {8, 263} {713, 213} table 0.000000 1.000000 
ioText {393, 234} {41, 24} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} background noborder Hz
ioText {327, 234} {69, 24} display 3701.748942 0.00100 "freq" right "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} background noborder 3701.7489
ioText {410, 95} {312, 74} display 0.000000 0.00100 "coef" left "Courier New" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border b0=0.516      b1=-0.658      b2=-0.028Â¬Â¬a1=-0.238      a2=0.182
ioText {411, 67} {130, 25} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Biquad Coefficients
ioMenu {213, 121} {176, 25} 2 303 "2nd order low-pass,2nd order hi-pass,2nd order low shelving,2nd order high shelving,Parametric eq,Bypass" type
ioKnob {12, 87} {80, 80} -20.000000 20.000000 0.010000 -19.191919 gain
ioText {14, 59} {80, 25} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Gain
ioText {18, 171} {69, 24} display -19.191919 0.00100 "gain" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} background noborder -19.1919
ioText {341, 180} {80, 25} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frequency
ioKnob {102, 88} {80, 80} 0.100000 10.000000 0.010000 0.700000 Q
ioText {104, 60} {80, 25} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Q
ioText {108, 172} {69, 24} display 0.700000 0.00100 "Q" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} background noborder 0.7000
ioText {213, 94} {130, 25} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Filter type
ioText {13, 5} {709, 49} label 0.000000 0.00100 "" left "Lucida Grande" 28 {0, 0, 0} {45824, 45824, 45824} background noborder Biquad Filter Lab
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="557" y="270" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>
<CsoundSynthesizer>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

; simple damped nonlinear resonator
opcode nonlin_reson, a, akki
setksmps 1
avel 	init 0			;velocity
adef 	init 0			;deflection
ain,kc,kdamp,ifn xin
aacel 	tablei 	adef, ifn, 1, .5 ;acceleration = -c1*f1(def)
aacel 	= 	-kc*aacel
avel 	= 	avel+aacel+ain	;vel += acel + excitation
avel 	= 	avel*(1-kdamp)
adef 	= 	adef+avel
	xout 	adef
endop

instr 1
kenv 	oscil 		p4,.5,1
aexc 	rand 		kenv
aout 	nonlin_reson 	aexc,p5,p6,p7
	out 		aout
endin

</CsInstruments>
<CsScore>
f1 0 1024 10 1
f2 0 1024 7 -1 510 .15 4 -.15 510 1
f3 0 1024 7 -1 350 .1 100 -.3 100 .2 100 -.1 354 1
; 		p4 		p5 	p6 	p7
;   		excitation  	c1    	damping ifn
i1 0 20   	.0001      	.01   	.00001   3
;i1 0 20  	.0001      	.01   	.00001   2
</CsScore>
</CsoundSynthesizer>
;example by martin neukom

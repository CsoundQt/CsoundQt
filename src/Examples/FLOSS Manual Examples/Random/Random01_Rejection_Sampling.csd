<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -odac
</CsOptions>
<CsInstruments>
;example by martin neukom
sr = 44100
ksmps = 10
nchnls = 1
0dbfs = 1

; random number generator to a given density function
; kout	random number; k_minimum,k_maximum,i_fn for a density function

opcode	rand_density, k, kki		

kmin,kmax,ifn	xin
loop:
krnd1		random		0,1
krnd2		random		0,1
k2		table		krnd1,ifn,1	
		if	krnd2 > k2	kgoto loop			
		xout		kmin+krnd1*(kmax-kmin)
endop

; random number generator to a given probability function
; kout	random number
; in: i_nr number of possible values
; i_fn1 function for random values
; i_fn2 probability function

opcode	rand_probability, k, iii		

inr,ifn1,ifn2	xin
loop:
krnd1		random		0,inr
krnd2		random		0,1
k2		table		int(krnd1),ifn2,0	
		if	krnd2 > k2	kgoto loop	
kout		table		krnd1,ifn1,0		
		xout		kout
endop

instr 1

krnd		rand_density	400,800,2
aout		poscil		.1,krnd,1
		out		aout

endin

instr 2

krnd		rand_probability p4,p5,p6
aout		poscil		.1,krnd,1
		out		aout

endin

</CsInstruments>
<CsScore>
;sine
f1 0 32768 10 1
;density function
f2 0 1024 6 1 112 0 800 0 112 1
;random values and their relative probability (two dice)
f3 0 16 -2 2 3 4 5 6 7 8 9 10 11 12
f4 0 16  2 1 2 3 4 5 6 5 4  3  2  1
;random values and their relative probability
f5 0 8 -2 400 500 600 800
f6 0 8  2 .3  .8  .3  .1

i1	0 10		

;i2 0 10 4 5 6
</CsScore>
</CsoundSynthesizer>

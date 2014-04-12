<CsoundSynthesizer>
<CsInstruments>

sr      =  44100
ksmps   =  32
nchnls  =  4
0dbfs 	 = 1

opcode	ambi2D_encode_n, k, aik		
asnd,iorder,kaz	xin
kaz = $M_PI*kaz/180
kk =	iorder
c1:
   	zawm	cos(kk*kaz)*asnd,2*kk-1
   	zawm	sin(kk*kaz)*asnd,2*kk
kk =		kk-1

if	kk > 0 goto c1
	zawm	asnd,0	
	xout	0
endop

;in-phase-decoding
opcode	ambi2D_dec_inph, a, ii	
; weights and norms up to 12th order
iNorm2D[] array 1,0.75,0.625,0.546875,0.492188,0.451172,0.418945,
					0.392761,0.370941,0.352394,0.336376,0.322360
iWeight2D[][] init   12,12
iWeight2D     array  0.5,0,0,0,0,0,0,0,0,0,0,0,
	0.666667,0.166667,0,0,0,0,0,0,0,0,0,0,
	0.75,0.3,0.05,0,0,0,0,0,0,0,0,0,
	0.8,0.4,0.114286,0.0142857,0,0,0,0,0,0,0,0,
	0.833333,0.47619,0.178571,0.0396825,0.00396825,0,0,0,0,0,0,0,
	0.857143,0.535714,0.238095,0.0714286,0.012987,0.00108225,0,0,0,0,0,0,
	0.875,0.583333,0.291667,0.1060601,0.0265152,0.00407925,0.000291375,0,0,0,0,0,
	0.888889,0.622222,0.339394,0.141414,0.043512,0.009324,0.0012432,
	0.0000777,0,0,0,0,
	0.9,0.654545,0.381818,0.176224,0.0629371,0.0167832,0.00314685,
	0.000370218,0.0000205677,0,0,0,
	0.909091,0.681818,0.41958,0.20979,0.0839161,0.0262238,0.0061703,
	0.00102838,0.000108251,0.00000541254,0,0,
	0.916667,0.705128,0.453297,0.241758,0.105769,0.0373303,0.0103695,
	0.00218306,0.000327459,0.0000311866,0.00000141757,0,
	0.923077,0.725275,0.483516,0.271978,0.12799,0.0497738,0.015718,
	0.00392951,0.000748478,0.000102065,0.00000887523,0.000000369801

iorder,iaz1	xin
iaz1 = $M_PI*iaz1/180
kk =	iorder
a1	=	.5*zar(0)
c1:
a1 +=	cos(kk*iaz1)*iWeight2D[iorder-1][kk-1]*zar(2*kk-1)
a1 +=	sin(kk*iaz1)*iWeight2D[iorder-1][kk-1]*zar(2*kk)
kk =		kk-1
if	kk > 0 goto c1
		xout			iNorm2D[iorder-1]*a1
endop

zakinit 7, 1		

instr 1
asnd	rand		p4
ares 	reson		asnd,p5,p6,1
kaz   	line		0,p3,p7*360		;turns around p7 times in p3 seconds
k0		ambi2D_encode_n		asnd,3,kaz
endin

instr 11		

a1 		ambi2D_dec_inph 	3,0
a2 		ambi2D_dec_inph 	3,90
a3 		ambi2D_dec_inph 	3,180
a4 		ambi2D_dec_inph 	3,270
		outc	a1,a2,a3,a4
		zacl 	0,6		; clear the za variables
endin

</CsInstruments>
<CsScore>
;			amp	 cf 	bw		turns
i1 0 3 	.1 	 1500 	12 		1
i11 0 3
</CsScore>
</CsoundSynthesizer>
;example by martin neukom

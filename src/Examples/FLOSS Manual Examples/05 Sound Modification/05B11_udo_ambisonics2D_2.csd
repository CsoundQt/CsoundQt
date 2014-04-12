<CsoundSynthesizer>
<CsInstruments>

sr      =  44100
ksmps   =  32
nchnls  =  4
0dbfs 	 = 1

; ambisonics2D encoding fifth order
; decoding for 8 speakers symmetrically positioned on a circle
; all instruments write the B-format into a buffer (zak space)
; instr 10 decodes

; zak space with the 21 channels of the B-format up to 10th order
zakinit 21, 1	

;explicit encoding third order
opcode	ambi2D_encode_3, k, ak	
asnd,kaz	xin	

kaz = $M_PI*kaz/180

		zawm		asnd,0
		zawm		cos(kaz)*asnd,1		;a11
		zawm		sin(kaz)*asnd,2		;a12
		zawm		cos(2*kaz)*asnd,3	;a21
		zawm		sin(2*kaz)*asnd,4	;a22
		zawm		cos(3*kaz)*asnd,5	;a31
		zawm		sin(3*kaz)*asnd,6	;a32
		xout		0
endop

; encoding arbitrary order n(zakinit 2*n+1, 1)
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

; basic decoding for arbitrary order n for 1 speaker
opcode	ambi2D_decode_basic, a, ii		
iorder,iaz	xin
iaz = $M_PI*iaz/180
igain	=	2/(2*iorder+1)
kk =	iorder
a1	=	.5*zar(0)
c1:
a1 +=	cos(kk*iaz)*zar(2*kk-1)
a1 +=	sin(kk*iaz)*zar(2*kk)
kk =		kk-1
if	kk > 0 goto c1
		xout			igain*a1
endop

; decoding for 2 speakers
opcode	ambi2D_decode_basic, aa, iii	
iorder,iaz1,iaz2	xin
iaz1 = $M_PI*iaz1/180
iaz2 = $M_PI*iaz2/180
igain	=	2/(2*iorder+1)
kk =	iorder
a1	=	.5*zar(0)
c1:
a1 +=	cos(kk*iaz1)*zar(2*kk-1)
a1 +=	sin(kk*iaz1)*zar(2*kk)
kk =		kk-1
if	kk > 0 goto c1

kk =	iorder
a2	=	.5*zar(0)
c2:
a2 +=	cos(kk*iaz2)*zar(2*kk-1)
a2 +=	sin(kk*iaz2)*zar(2*kk)
kk =		kk-1
if	kk > 0 goto c2
		xout			igain*a1,igain*a2
endop

instr 1
asnd	rand		p4
ares 	reson		asnd,p5,p6,1
kaz   	line		0,p3,p7*360		;turns around p7 times in p3 seconds
k0 		ambi2D_encode_n	asnd,10,kaz
endin

instr 2
asnd	oscil		p4,p5,1
kaz   	line		0,p3,p7*360		;turns around p7 times in p3 seconds
k0 		ambi2D_encode_n	asnd,10,kaz
endin

instr 10	;decode all insruments (the first 4 speakers of a 18 speaker setup)
a1,a2		ambi2D_decode_basic 	10,0,20
a3,a4		ambi2D_decode_basic 	10,40,60
		outc	a1,a2,a3,a4			
		zacl 	0,20		; clear the za variables
endin


</CsInstruments>
<CsScore>
f1 0 32768 10 1
;			amp	 cf 	bw		turns
i1 0 3 	.7 	 1500 	12 		1
i1 2 18 	.1  2234 	34 		-8
;			amp		fr	0	turns
i2 0 3   .1	 	440	0	2
i10 0 3
</CsScore>
</CsoundSynthesizer>
;example by martin neukom

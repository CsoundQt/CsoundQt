<CsoundSynthesizer>
<CsInstruments>

sr      =  44100
ksmps   =  32
nchnls  =  8
0dbfs 	 = 1

#include "ambisonics2D_udos.txt"

; distance encoding
; with any distance (includes zero and negative distance)

opcode	ambi2D_enc_dist_n, k, aikk		
asnd,iorder,kaz,kdist	xin
kaz = $M_PI*kaz/180
kaz	=			(kdist < 0 ? kaz + $M_PI : kaz)
kdist =		abs(kdist)+0.0001
kgainW	=		taninv(kdist*1.5707963) / (kdist*1.5708)		;pi/2
kgainHO =	(1 - exp(-kdist)) ;*kgainW
kk =	iorder
asndW	=	kgainW*asnd
asndHO	=	kgainHO*asndW
c1:
   	zawm	cos(kk*kaz)*asndHO,2*kk-1
   	zawm	sin(kk*kaz)*asndHO,2*kk
kk =		kk-1

if	kk > 0 goto c1
	zawm	asndW,0	
	xout	0
endop

zakinit 17, 1		

instr 1
asnd	rand		p4
;asnd	soundin	"/Users/user/csound/ambisonic/violine.aiff"
kaz   	line		0,p3,p5*360		;turns around p5 times in p3 seconds
kdist	line		p6,p3,p7			
k0		ambi2D_enc_dist_n		asnd,8,kaz,kdist
endin

instr 10		
a1,a2,a3,a4,
a5,a6,a7,a8 		ambi2D_decode		8,0,45,90,135,180,225,270,315
		outc	a1,a2,a3,a4,a5,a6,a7,a8
		zacl 	0,16		
endin

</CsInstruments>
<CsScore>
f1 0 32768 10 1
;        amp turns dist1 dist2
i1 0 4   1   0     2     -2
;i1 0 4  1   1     1     1
i10 0 4
</CsScore>
</CsoundSynthesizer>
;example by martin neukom

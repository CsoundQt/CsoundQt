<CsoundSynthesizer>
<CsInstruments>
sr      =  44100
ksmps   =  32
nchnls  =  8
0dbfs 	 = 1

#include "ambisonics2D_udos.txt"
#include "ambisonics_utilities.txt" ;opcodes Absorb and Doppler

/* these opcodes are included in "ambisonics2D_udos.txt"
opcode xy_to_ad, kk, kk
kx,ky		xin
kdist =	sqrt(kx*kx+ky*ky)
kaz 		taninv2	ky,kx
			xout		180*kaz/$M_PI, kdist
endop

opcode Absorb, a, ak
asnd,kdist	xin
aabs 		tone 		5*asnd,20000*exp(-.1*kdist)	
			xout 		aabs
endop

opcode Doppler, a, ak
asnd,kdist	xin
abuf		delayr 	.5
adop		deltapi	interp(kdist)*0.0029137529 + .01 ; 1/343.2
			delayw 	asnd 	
			xout		adop
endop
*/
opcode	write_ambi2D_2, k,	S		
Sname			xin
fout 	Sname,12,zar(0),zar(1),zar(2),zar(3),zar(4)
				xout	0
endop

zakinit 17, 1		; zak space with the 17 channels of the B-format

instr 1
asnd    buzz     p4,p5,50,1
;asnd   soundin  "/Users/user/csound/ambisonic/violine.aiff"
kx      line     p7,p3,p8		
ky      line     p9,p3,p10		
kaz,kdist xy_to_ad kx,ky
aabs    absorb   asnd,kdist
adop    Doppler  .2*aabs,kdist
k0      ambi2D_enc_dist adop,5,kaz,kdist
endin

instr 10		;decode all insruments
a1,a2,a3,a4,
a5,a6,a7,a8     ambi2D_dec_inph 5,0,45,90,135,180,225,270,315
                outc            a1,a2,a3,a4,a5,a6,a7,a8
;               fout "B_format2D.wav",12,zar(0),zar(1),zar(2),zar(3),zar(4),
;                                zar(5),zar(6),zar(7),zar(8),zar(9),zar(10)
k0              write_ambi2D_2  "ambi_ex5.wav"	
                zacl            0,16 ; clear the za variables
endin

</CsInstruments>
<CsScore>
f1 0 32768 10 1
;			amp	 	f 		0		x1	x2	y1	y2
i1 0 5 	.8  200 		0 		40	-20	1	.1
i10 0 5
</CsScore>
</CsoundSynthesizer>
;example by martin neukom

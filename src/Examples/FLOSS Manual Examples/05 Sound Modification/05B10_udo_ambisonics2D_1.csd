<CsoundSynthesizer>
<CsInstruments>
sr      =  44100
ksmps   =  100
nchnls  =  8
0dbfs 	 = 1

; ambisonics2D first order without distance encoding
; decoding for 8 speakers symmetrically positioned on a circle

; produces the 3 channels 1st order; input: asound, kazimuth
opcode	ambi2D_encode_1a, aaa, ak	
asnd,kaz	xin
kaz = $M_PI*kaz/180
a0	=	asnd
a11	=	cos(kaz)*asnd
a12	=	sin(kaz)*asnd
		xout		a0,a11,a12
endop

; decodes 1st order to a setup of 8 speakers at angles i1, i2, ...
opcode	ambi2D_decode_1_8, aaaaaaaa, aaaiiiiiiii		
a0,a11,a12,i1,i2,i3,i4,i5,i6,i7,i8	xin
i1 = $M_PI*i1/180
i2 = $M_PI*i2/180
i3 = $M_PI*i3/180
i4 = $M_PI*i4/180
i5 = $M_PI*i5/180
i6 = $M_PI*i6/180
i7 = $M_PI*i7/180
i8 = $M_PI*i8/180
a1	=	(.5*a0 + cos(i1)*a11 + sin(i1)*a12)*2/3			
a2	=	(.5*a0 + cos(i2)*a11 + sin(i2)*a12)*2/3	
a3	=	(.5*a0 + cos(i3)*a11 + sin(i3)*a12)*2/3	
a4	=	(.5*a0 + cos(i4)*a11 + sin(i4)*a12)*2/3	
a5	=	(.5*a0 + cos(i5)*a11 + sin(i5)*a12)*2/3	
a6	=	(.5*a0 + cos(i6)*a11 + sin(i6)*a12)*2/3	
a7	=	(.5*a0 + cos(i7)*a11 + sin(i7)*a12)*2/3	
a8	=	(.5*a0 + cos(i8)*a11 + sin(i8)*a12)*2/3				
		xout			a1,a2,a3,a4,a5,a6,a7,a8
endop

instr 1
asnd	rand	.05
kaz   	line	0,p3,3*360 ;turns around 3 times in p3 seconds
a0,a11,a12 ambi2D_encode_1a asnd,kaz
a1,a2,a3,a4,a5,a6,a7,a8 \
        ambi2D_decode_1_8  a0,a11,a12,
                           0,45,90,135,180,225,270,315
        outc    a1,a2,a3,a4,a5,a6,a7,a8
endin

</CsInstruments>
<CsScore>
i1 0 40
</CsScore>
</CsoundSynthesizer>
;example by martin neukom

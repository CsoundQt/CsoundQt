<CsoundSynthesizer>
<CsOptions>
--env:INCDIR+=../SourceMaterials 
</CsOptions>
<CsInstruments>
sr      =  44100
ksmps   =  32
nchnls  =  4
0dbfs 	 = 1

;#include "ambisonics_udos.txt"

; opcode AEP1 is the same as in udo_AEP_xyz.csd

opcode	AEP1, a, akiiiikkkkkk ; soundin, order, ixs, iys, izs, idsmax, kx, ky, kz
ain,korder,ixs,iys,izs,idsmax,kx,ky,kz,kdist,kfade,kgain	xin
idists =		sqrt(ixs*ixs+iys*iys+izs*izs)
kpan =			kgain*((1-kfade+kfade*(kx*ixs+ky*iys+kz*izs)/(kdist*idists))^korder)
		xout	ain*kpan*idists/idsmax
endop

; opcode AEP calculates ambisonics equivalent panning for n speaker
; the number n of output channels defines the number of speakers (overloaded function)
; inputs: sound ain, order korder (any real number >= 1)
; ifn = number of the function containing the speaker positions
; position and distance of the sound source kaz,kel,kdist in degrees

opcode AEP, aaaa, akikkk
ain,korder,ifn,kaz,kel,kdist	xin
kaz = $M_PI*kaz/180
kel = $M_PI*kel/180
kx = kdist*cos(kel)*cos(kaz)
ky = kdist*cos(kel)*sin(kaz)
kz = kdist*sin(kel)
ispeaker[] array 0,
  table(3,ifn)*cos(($M_PI/180)*table(2,ifn))*cos(($M_PI/180)*table(1,ifn)),
  table(3,ifn)*cos(($M_PI/180)*table(2,ifn))*sin(($M_PI/180)*table(1,ifn)),
  table(3,ifn)*sin(($M_PI/180)*table(2,ifn)),
  table(6,ifn)*cos(($M_PI/180)*table(5,ifn))*cos(($M_PI/180)*table(4,ifn)),
  table(6,ifn)*cos(($M_PI/180)*table(5,ifn))*sin(($M_PI/180)*table(4,ifn)),
  table(6,ifn)*sin(($M_PI/180)*table(5,ifn)),
  table(9,ifn)*cos(($M_PI/180)*table(8,ifn))*cos(($M_PI/180)*table(7,ifn)),
  table(9,ifn)*cos(($M_PI/180)*table(8,ifn))*sin(($M_PI/180)*table(7,ifn)),
  table(9,ifn)*sin(($M_PI/180)*table(8,ifn)),
  table(12,ifn)*cos(($M_PI/180)*table(11,ifn))*cos(($M_PI/180)*table(10,ifn)),
  table(12,ifn)*cos(($M_PI/180)*table(11,ifn))*sin(($M_PI/180)*table(10,ifn)),
  table(12,ifn)*sin(($M_PI/180)*table(11,ifn))

idsmax   table   0,ifn
kdist    =       kdist+0.000001
kfade    =       .5*(1 - exp(-abs(kdist)))
kgain    =       taninv(kdist*1.5708)/(kdist*1.5708)

a1       AEP1    ain,korder,ispeaker[1],ispeaker[2],ispeaker[3],
                   idsmax,kx,ky,kz,kdist,kfade,kgain
a2       AEP1    ain,korder,ispeaker[4],ispeaker[5],ispeaker[6],
                   idsmax,kx,ky,kz,kdist,kfade,kgain
a3       AEP1    ain,korder,ispeaker[7],ispeaker[8],ispeaker[9],
                   idsmax,kx,ky,kz,kdist,kfade,kgain
a4       AEP1    ain,korder,ispeaker[10],ispeaker[11],ispeaker[12],
                   idsmax,kx,ky,kz,kdist,kfade,kgain	
         xout    a1,a2,a3,a4
endop

instr 1
ain      rand    1
;ain		soundin	"/Users/user/csound/ambisonic/violine.aiff"
kt       line    0,p3,360
korder   init    24
;kdist 	Dist kx, ky, kz	
a1,a2,a3,a4 AEP  ain,korder,17,kt,0,1
         outc    a1,a2,a3,a4
endin

</CsInstruments>
<CsScore>

;fuction for speaker positions
; GEN -2, parameters: max_speaker_distance, xs1,ys1,zs1,xs2,ys2,zs2,...
;octahedron
;f17 0 32 -2 1 1 0 0  -1 0 0  0 1 0  0 -1 0  0 0 1  0 0 -1
;cube
;f17 0 32 -2 1,732 1 1 1  1 1 -1  1 -1 1  -1 1 1
;octagon
;f17 0 32 -2 1 0.924 -0.383 0 0.924 0.383 0 0.383 0.924 0 -0.383 0.924 0 -0.924 0.383 0 -0.924 -0.383 0 -0.383 -0.924 0 0.383 -0.924 0
;f17 0 32 -2 1  0 0 1  45 0 1  90 0 1  135 0 1  180 0 1  225 0 1  270 0 1  315 0 1
;f17 0 32 -2 1  0 -90 1  0 -70 1  0 -50 1  0 -30 1  0 -10 1  0 10 1  0 30 1  0 50 1
f17 0 32 -2 1   -45 0 1   45 0 1   135 0 1  225 0 1
i1 0 2

</CsScore>
</CsoundSynthesizer>
;example by martin neukom

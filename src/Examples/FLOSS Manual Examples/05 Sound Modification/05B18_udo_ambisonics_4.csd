<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials -odac -m0
</CsOptions>
<CsInstruments>
sr      =  44100
ksmps   =  32
nchnls  =  8
0dbfs      = 1

zakinit 16, 1

#include "../../SourceMaterials/ambisonics_udos.txt"
#include "../../SourceMaterials/ambisonics_utilities.txt"

instr 1
asnd    buzz    p4,p5,p6,1
kt      line    0,p3,p3
kaz,kel,kdist xyz_to_aed 10*sin(kt),10*sin(.78*kt),10*sin(.43*kt)
adop Doppler asnd,kdist
        ambi_enc_dist adop,3,kaz,kel,kdist
a1,a2,a3,a4,a5,a6,a7,a8 ambi_decode 3,17
;k0        ambi_write_B    "B_form.wav",8,14
        outc    a1,a2,a3,a4,a5,a6,a7,a8
        zacl    0,15
endin

</CsInstruments>
<CsScore>
f1 0 32768 10 1
f17 0 64 -2 0 -45 35.2644  45 35.2644  135 35.2644  225 35.2644  \
   -45 -35.2644  .7854 -35.2644  135 -35.2644  225 -35.2644
i1 0 40 .5 300 40
</CsScore>
</CsoundSynthesizer>
;example by martin neukom

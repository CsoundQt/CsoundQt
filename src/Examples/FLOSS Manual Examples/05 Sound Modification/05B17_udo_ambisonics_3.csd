<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -odac -m0
</CsOptions>
<CsInstruments>
sr      =  44100
ksmps   =  32
nchnls  =  2
0dbfs      = 1

zakinit 81, 1        ; zak space with the 11 channels of the B-format

#include "../SourceMaterials/ambisonics_udos.txt"

opcode    ambi3D_enc_dist1, 0, aikkk
asnd,iorder,kaz,kel,kdist    xin
kaz = $M_PI*kaz/180
kel = $M_PI*kel/180
kaz    =        (kdist < 0 ? kaz + $M_PI : kaz)
kel    =        (kdist < 0 ? -kel : kel)
kdist =    abs(kdist)+0.00001
kgainW    =    taninv(kdist*1.5708) / (kdist*1.5708)
kgainHO =    (1 - exp(-kdist)) ;*kgainW
    outvalue "kgainHO", kgainHO
    outvalue "kgainW", kgainW
kcos_el = cos(kel)
ksin_el = sin(kel)
kcos_az = cos(kaz)
ksin_az = sin(kaz)
asnd =        kgainW*asnd
    zawm    asnd,0                            ; W
asnd =     kgainHO*asnd
    zawm    kcos_el*ksin_az*asnd,1        ; Y     = Y(1,-1)
    zawm    ksin_el*asnd,2                 ; Z     = Y(1,0)
    zawm    kcos_el*kcos_az*asnd,3        ; X     = Y(1,1)
    if        iorder < 2 goto    end
/*
...
*/
end:

endop

instr 1
asnd    init      1
kaz     invalue "az"
kel     invalue "el"
kdist   invalue "dist"
        ambi_enc_dist asnd,5,kaz,kel,kdist
ao1,ao2,ao3,ao4 ambi_decode 5,17
        outvalue "sp1", downsamp(ao1)
        outvalue "sp2", downsamp(ao2)
        outvalue "sp3", downsamp(ao3)
        outvalue "sp4", downsamp(ao4)
        outc      0*ao1,0*ao2;,2*ao3,2*ao4
        zacl      0,80
endin
</CsInstruments>
<CsScore>
f17 0 64 -2 0  0 0  90 0   180 0      0 90  0 0    0 0
i1 0 100
</CsScore>
</CsoundSynthesizer>
;example by martin neukom
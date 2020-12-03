<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

instr 1
iamp =  p4/4            ;amplitude scaler
ifreq = p5              ;frequency scaler
itab =  p6              ;audio table
ip1 =   p7              ;first partial to be synthesized
ip2 =   p8              ;second partial to be synthesized
ip3 =   p9              ;third partial to be synthesized
ip4 =   p10             ;fourth partial to be synthesized
iatsfile = p11          ;atsfile

ipars   ATSinfo iatsfile, 3     ;get how many partials
idur    ATSinfo iatsfile, 7     ;get duration

ktime   line    0, p3, idur     ;time pointer

        ATSbufread ktime, ifreq, iatsfile, ipars ;reads an ATS buffer

kf1,ka1 ATSpartialtap ip1 ;get the amp values according each partial number
af1     interp kf1
aa1     interp ka1
kf2,ka2 ATSpartialtap ip2       ;ditto
af2     interp kf2
aa2     interp ka2
kf3,ka3 ATSpartialtap ip3       ;ditto
af3     interp kf3
aa3     interp ka3
kf4,ka4 ATSpartialtap ip4       ;ditto
af4     interp kf4
aa4     interp ka4

a1      oscil3  aa1, af1*ifreq, itab    ;synthesize each partial
a2      oscil3  aa2, af2*ifreq, itab    ;ditto
a3      oscil3  aa3, af3*ifreq, itab    ;ditto
a4      oscil3  aa4, af4*ifreq, itab    ;ditto

        out (a1+a2+a3+a4)*iamp
endin

</CsInstruments>
<CsScore>
; sine wave table
f 1 0 16384 10 1
#define atsfile #"oboe-A5.ats"#

;   start dur amp freq atab part#1 part#2 part#3 part#4 atsfile
i1  0     3   10  1    1    1      5      11     13     $atsfile
i1  +     3   7   1    1    1      6      14     17     $atsfile
i1  +     3   400 1    1    15     16     17     18     $atsfile

e
</CsScore>
</CsoundSynthesizer>
;example by Oscar Pablo Di Liscia

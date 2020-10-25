<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

;Some macros
#define ATS_NP # 3 #    ;number of Partials
#define ATS_DU # 7 #    ;duration

instr 1

/*read some ATS data from the file header*/
iatsfile = p11
i_number_of_partials    ATSinfo iatsfile,  $ATS_NP
i_duration              ATSinfo iatsfile,  $ATS_DU

iamp     =      p4              ;amplitude scaler
ifreqdev =      2^(p5/12)       ;frequency deviation (p5=semitones up or down)
itable   =      p6              ;audio table

/*here we deal with number of partials, offset and increment issues*/
inpars  = (p7 < 1 ? i_number_of_partials : p7) ;inpars can not be <=0
ipofst  =       (p8 < 0 ? 0 : p8)      ;partial offset can not be < 0
ipincr  =       (p9 < 1 ? 1 : p9)      ;partial increment can not be <= 0
imax    =       ipofst + inpars*ipincr  ;max. partials allowed

if imax <= i_number_of_partials igoto OK
;if we are here, something is wrong!
;set npars to zero, so as the output will be zero and the user knows
print imax, i_number_of_partials
inpars  = 0
ipofst  = 0
ipincr  = 1
OK: ;data is OK
/********************************************************************/
igatefn =      p10               ;amplitude scaling table

ktime   linseg 0, p3, i_duration
asig ATSadd ktime, ifreqdev, iatsfile, itable, inpars, ipofst, ipincr, igatefn

 out    asig*iamp
endin

</CsInstruments>
<CsScore>

;change to put any ATS file you like
#define ats_file #"basoon-C4.ats"#

;audio table (sine)
f1      0       16384   10      1
;some tables to test amplitude gating
;f2 reduce progressively partials with amplitudes from 0.5 to 1
;and eliminate partials with amplitudes below 0.5 (-6dBFs)
f2      0       1024     7      0 512 0 512 1
;f3 boost partials with amplitudes from 0 to 0.125 (-12dBFs)
;and attenuate partials with amplitudes from 0.125 to 1 (-12dBFs to 0dBFs)
f3      0       1024     -5     8 128 8 896 .001

;   start dur  amp  freq atable npars offset pincr gatefn atsfile
i1  0     2.82 1    0    1      0     0      1     0      $ats_file
i1  +     .    1    0    1      0     0      1     2      $ats_file
i1  +     .    .8   0    1      0     0      1     3      $ats_file

e
</CsScore>
</CsoundSynthesizer>
;example by Oscar Pablo Di Liscia
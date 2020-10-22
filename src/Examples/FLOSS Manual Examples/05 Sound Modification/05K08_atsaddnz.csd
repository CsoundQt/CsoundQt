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
#define NB      # 25 #  ;number noise bands
#define ATS_DU  # 7 #   ;duration

instr 1
/*read some ATS data from the file header*/
iatsfile = p8
i_duration ATSinfo iatsfile, $ATS_DU

iamp    =       p4                ;amplitude scaler

/*here we deal with number of partials, offset and increment issues*/
inb     =       (p5 < 1 ? $NB : p5)     ;inb can not be <=0
ibofst  =       (p6 < 0 ? 0 : p6)       ;band offset cannot be < 0
ibincr  =       (p7 < 1 ? 1 : p7)       ;band increment cannot be <= 0
imax    =       ibofst + inb*ibincr     ;max. bands allowed

if imax <= $NB igoto OK
;if we are here, something is wrong!
;set nb to zero, so as the output will be zero and the user knows
print imax, $NB
inb  = 0
ibofst  = 0
ibincr  = 1
OK: ;data is OK
/********************************************************************/
ktime   linseg   0, p3, i_duration
asig    ATSaddnz ktime, iatsfile, inb, ibofst, ibincr

        out      asig*iamp
endin

</CsInstruments>
<CsScore>

;change to put any ATS file you like
#define ats_file #"female-speech.ats"#

;   start dur  amp nbands bands_offset bands_incr atsfile
i1  0     7.32 1   25     0            1       $ats_file ;all bands
i1  +     .    .   15     10           1       $ats_file ;from 10 to 25 step 1
i1  +     .    .   8      1            3       $ats_file ;from 1 to 24 step 3
i1  +     .    .   5      15           1       $ats_file ;from 15 to 20 step 1

e
</CsScore>
</CsoundSynthesizer>
;example by Oscar Pablo Di Liscia
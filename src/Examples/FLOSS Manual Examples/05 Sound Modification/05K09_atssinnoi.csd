<CsoundSynthesizer>
<CsOptions>
--env:SADIR+=../SourceMaterials -o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

;Some macros
#define ATS_NP  # 3 #   ;number of Partials
#define ATS_DU  # 7 #   ;duration

instr 1	
iatsfile = p11
/*read some ATS data from the file header*/
i_number_of_partials    ATSinfo iatsfile, $ATS_NP
i_duration              ATSinfo iatsfile, $ATS_DU
print i_number_of_partials

iamp     =      p4              ;amplitude scaler
ifreqdev =      2^(p5/12)       ;frequency deviation (p5=semitones up or down)
isinlev  =      p6              ;deterministic part gain
inoislev =      p7              ;residual part gain

/*here we deal with number of partials, offset and increment issues*/
inpars   =      (p8 < 1 ? i_number_of_partials : p8) ;inpars can not be <=0
ipofst   =      (p9 < 0 ? 0 : p9)                    ;partial offset can not be < 0
ipincr   =      (p10 < 1 ? 1 : p10)                  ;partial increment can not be <= 0
imax     =      ipofst + inpars*ipincr               ;max. partials allowed

if imax <= i_number_of_partials igoto OK 	
;if we are here, something is wrong!
;set npars to zero, so as the output will be zero and the user knows
prints "wrong number of partials requested", imax, i_number_of_partials
inpars  = 0
ipofst	= 0
ipincr	= 1
OK: ;data is OK
/********************************************************************/

ktime   linseg     0, p3, i_duration
asig    ATSsinnoi  ktime, isinlev, inoislev, ifreqdev, iatsfile, inpars, ipofst, ipincr

        out        asig*iamp
endin

</CsInstruments>
<CsScore>
;change to put any ATS file you like
#define ats_file #"female-speech.ats"#

;       start   dur     amp     freqdev sinlev  noislev npars   offset  pincr   atsfile	
i1      0       3.66    .79     0       1       0       0       0       1       $ats_file
;deterministic only
i1      +       3.66    .79     0       0       1       0       0       1       $ats_file	
;residual only
i1      +       3.66    .79     0       1       1       0       0       1       $ats_file	
;deterministic and residual
;       start   dur     amp     freqdev sinlev  noislev npars   offset  pincr   atsfile	
i1      +       3.66    2.5     0       1       0       80      60      1       $ats_file
;from partial 60 to partial 140, deterministic only
i1      +       3.66    2.5     0       0       1       80      60      1       $ats_file
;from partial 60 to partial 140, residual only
i1      +       3.66    2.5     0       1       1       80      60      1       $ats_file
;from partial 60 to partial 140, deterministic and residual
e
</CsScore>
</CsoundSynthesizer>
;example by Oscar Pablo Di Liscia 
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>

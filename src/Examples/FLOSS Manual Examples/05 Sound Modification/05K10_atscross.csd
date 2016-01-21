<CsoundSynthesizer>
<CsOptions>
--env:SADIR+=../SourceMaterials --env:SSDIR+=../SourceMaterials -o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

;ATS files
#define ats1 #"flute-A5.ats"#
#define ats2 #"oboe-A5.ats"#


instr 1	
iamp    = p4            ;general amplitude scaler

ilev1   = p5            ;level of iats1 partials
ifd1    = 2^(p6/12)     ;frequency deviation for iats1 partials

ilev2   = p7            ;level of ats2 partials
ifd2    = 2^(p8/12)     ;frequency deviation for iats2 partials	

itau    = p9            ;audio table

/*get ats file data*/
inp1  ATSinfo $ats1, 3
inp2  ATSinfo $ats2, 3
idur1 ATSinfo $ats1, 7
idur2 ATSinfo $ats2, 7

ktime   line    0, p3, idur1
ktime2  line    0, p3, idur2

        ATSbufread ktime,  ifd1, $ats1, inp1
aout    ATScross   ktime2, ifd2, $ats2, itau, ilev2, ilev1, inp2

        out        aout*iamp

endin

</CsInstruments>
<CsScore>

; sine wave for the audio table
f1 	0 	16384 	10 	1

;  start dur amp lev1 f1  lev2 f2 table
i1 0     2.3 .75 0    0   1    0  1     ;original oboe	
i1 +     .   .   0.25 .   .75  .  .     ;oboe 75%, flute 25%
i1 +     .   .   0.5  .   0.5  .  .     ;oboe 50%, flute 50%
i1 +     .   .   .75  .   .25  .  .     ;oboe 25%, flute 75%
i1 +     .   .   1    .   0    .  .     ;oboe partials with flute's amplitudes

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

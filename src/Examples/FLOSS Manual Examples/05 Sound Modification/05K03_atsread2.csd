<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -o dac
</CsOptions>
<CsInstruments>
sr      = 44100
ksmps   = 32
nchnls  = 1
0dbfs   = 1

gS_ATS_file =         "../ats-files/flute-A5.ats" ;ats file
giSine     ftgen      0, 0, 16384, 10, 1 ; sine wave table


instr Master ;call instr "Play" for each partial
iNumParts  =          p4 ;how many partials to synthesize
idur       ATSinfo    gS_ATS_file, 7 ;get ats file duration

iAmps[]    array      1, .1 ;array for even and odd partials
iParts[]   genarray   1,iNumParts ;creates array [1, 2, ..., iNumParts]

indx       =          0 ;initialize index
 ;loop for number of elements in iParts array
until indx == iNumParts do
  ;call an instance of instr "Play" for each partial
           event_i    "i", "Play", 0, p3, iAmps[indx%2], iParts[indx], idur
indx       +=         1 ;increment index
od ;end of do ... od block

           turnoff ;turn this instrument off as job has been done
endin

instr Play
iamp       =          p4 ;amplitude scaler
ipar       =          p5 ;partial required
idur       =          p6 ;ats file duration

ktime      line       0, p3, idur ;time pointer

kfreq, kamp ATSread   ktime, gS_ATS_file, ipar ;get frequency and amplitude values
aamp       interp     kamp ;interpolate amplitude values
afreq      interp     kfreq ;interpolate frequency values
aout       oscil3     aamp*iamp, afreq, giSine ;synthesize with amp scaling

           out        aout
endin
</CsInstruments>
<CsScore>
;           strt dur number of partials
i "Master"  0    3   1
i .         +    .   3
i .         +    .   10
</CsScore>
</CsoundSynthesizer>
;example by Oscar Pablo Di Liscia and Joachim Heintz
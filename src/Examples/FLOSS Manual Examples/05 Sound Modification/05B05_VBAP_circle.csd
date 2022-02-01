<CsoundSynthesizer>
<CsOptions>
-odac
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
0dbfs = 1
nchnls = 8 ;only channels 1-7 used

vbaplsinit 2, 7, -40, 40, 70, 140, 180, -110, -70

  instr 1
Sfile      =          "ClassGuit.wav"
p3         filelen    Sfile
aSnd[]     diskin     Sfile
kAzim      line       0, p3, -360 ;counterclockwise
aVbap[]    vbap       aSnd[0], kAzim
           out        aVbap ;7 channel output via array
  endin
</CsInstruments>
<CsScore>
i 1 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

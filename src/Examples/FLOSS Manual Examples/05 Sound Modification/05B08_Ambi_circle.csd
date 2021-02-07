<CsoundSynthesizer>
<CsOptions>
-odac
--env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
0dbfs = 1
nchnls = 8

  instr 1
Sfile      =          "ClassGuit.wav"
p3         filelen    Sfile
aSnd[]     diskin     Sfile
kAzim      line       0, p3, 360 ;counterclockwise (!)
iSetup     =          4 ;octogon
aw, ax, ay, az bformenc1 aSnd[0], kAzim, 0
a1, a2, a3, a4, a5, a6, a7, a8 bformdec1 iSetup, aw, ax, ay, az
           out        a1, a2, a3, a4, a5, a6, a7, a8
  endin
</CsInstruments>
<CsScore>
i 1 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

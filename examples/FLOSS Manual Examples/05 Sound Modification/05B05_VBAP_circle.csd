<CsoundSynthesizer>
<CsOptions>
-odac -d ;for the next line, change to your folder
--env:SSDIR+=/home/jh/Joachim/Csound/FLOSS/audio
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32	
0dbfs = 1
nchnls = 7

vbaplsinit 2, 7, -40, 40, 70, 140, 180, -110, -70

  instr 1
Sfile      =          "ClassGuit.wav"
iFilLen    filelen    Sfile
p3         =          iFilLen
aSnd, a0   soundin    Sfile
kAzim      line       0, p3, -360 ;counterclockwise
a1, a2, a3, a4, a5, a6, a7, a8 vbap8 aSnd, kAzim
outch 1, a1, 2, a2, 3, a3, 4, a4, 5, a5, 6, a6, 7, a7
  endin
</CsInstruments>
<CsScore>
i 1 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

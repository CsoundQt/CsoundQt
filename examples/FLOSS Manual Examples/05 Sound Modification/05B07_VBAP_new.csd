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

vbaplsinit 2.01, 7, -40, 40, 70, 140, 180, -110, -70
vbaplsinit 2.02, 2, -40, 40
vbaplsinit 2.03, 3, -70, 180, 70

  instr 1
aSnd, a0   soundin    "ClassGuit.wav"
kAzim      line       0, p3, -360
a1, a2, a3, a4, a5, a6, a7 vbap aSnd, kAzim, 0, 0, 1
outch 1, a1, 2, a2, 3, a3, 4, a4, 5, a5, 6, a6, 7, a7
  endin

  instr 2
aSnd, a0   soundin    "ClassGuit.wav"
kAzim      line       0, p3, -360
a1, a2     vbap       aSnd, kAzim, 0, 0, 2
           outch      1, a1, 2, a2
  endin

  instr 3
aSnd, a0   soundin    "ClassGuit.wav"
kAzim      line       0, p3, -360
a1, a2, a3 vbap       aSnd, kAzim, 0, 0, 3
           outch      7, a1, 3, a2, 5, a3
  endin

</CsInstruments>
<CsScore>
i 1 0 6
i 2 6 6
i 3 12 6
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

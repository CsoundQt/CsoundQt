<CsoundSynthesizer>
<CsOptions>
-odac -d ;for the next line, change to your folder
--env:SSDIR+=/home/jh/Joachim/Csound/FLOSS/Release01/Csound_Floss_Release01/audio
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32	
0dbfs = 1
nchnls = 8

  instr 1
Sfile      =          "ClassGuit.wav"
iFilLen    filelen    Sfile
p3         =          iFilLen
aSnd, a0   soundin    Sfile
kAzim      line       0, p3, 360 ;counterclockwise (!)
iSetup     =          4 ;octogon
aw, ax, ay, az bformenc1 aSnd, kAzim, 0
a1, a2, a3, a4, a5, a6, a7, a8 bformdec1 iSetup, aw, ax, ay, az
outch 1, a1, 2, a2, 3, a3, 4, a4, 5, a5, 6, a6, 7, a7, 8, a8
  endin
</CsInstruments>
<CsScore>
i 1 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

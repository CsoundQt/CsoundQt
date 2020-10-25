<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

  instr 1
Sfile     =          "ClassGuit.wav"
ifilchnls filenchnls Sfile
 if ifilchnls == 1 goto mono
  goto stereo
mono:
aL        soundin    Sfile
aR        =          aL
          goto      continue
stereo:
aL, aR    soundin    Sfile
continue:
          outs       aL, aR
  endin

</CsInstruments>
<CsScore>
i 1 0 5
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
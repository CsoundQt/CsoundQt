<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr LoudestBin
 aSig diskin "fox.wav"
 fSig pvsanal aSig, 1024, 256, 1024, 1
 fTrace, kBins[] pvstrace fSig, 1, 1
 kAmp, kFreq pvsbin fSig, kBins[0]
 aLoudestBin poscil port(kAmp,.01), kFreq
 out aLoudestBin, aLoudestBin
endin

</CsInstruments>
<CsScore>
i "LoudestBin" 0 3
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

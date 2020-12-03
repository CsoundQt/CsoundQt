<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr Powershape
 iAmp = 0.2
 iFreq = 300
 aIn poscil iAmp, iFreq
 ifullscale = iAmp
 kShapeAmount linseg 1, 1.5, 1, .5, p4, 1.5, p4, .5, p5
 aOut powershape aIn, kShapeAmount, ifullscale
 out aOut, aOut
endin
</CsInstruments>
<CsScore>
i "Powershape" 0 6 2.5 50
i "Powershape" 7 6 0.5 0.1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

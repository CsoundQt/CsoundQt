<CsoundSynthesizer>
<CsOptions>
-odac ; activates real time sound output
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giLFOShape  ftgen   0, 0, 2^12, 19, 0.5, 1, 180, 1

  instr 1
aSig    pinkish  0.1

aMod    poscil   0.005, 0.05, giLFOShape
iOffset =        ksmps/sr
kFdback linseg   0.8,(p3/2)-0.5,0.95,1,-0.95

aDelay  init     0
aDelay  vdelayx  aSig+aDelay*kFdback, aMod+iOffset, 0.5, 128

aOut    linen    (aSig+aDelay)/2, .1, p3, 1
        out      aOut, aOut
  endin

</CsInstruments>
<CsScore>
i 1 0 25
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy and joachim heintz

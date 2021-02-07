<Cabbage>
form caption("Untitled") size(400, 300), \
  colour(58, 110, 182), \
  pluginID("def1")
keyboard bounds(8, 158, 381, 95)
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>
<CsInstruments>
; Initialize the global variables.
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

;instrument will be triggered by keyboard widget
instr 1
 iFreq = p4
 iAmp = p5
 iAtt = 0.1
 iDec = 0.4
 iSus = 0.6
 iRel = 0.7
 kEnv madsr iAtt, iDec, iSus, iRel
 aOut vco2 iAmp, iFreq
 outs aOut*kEnv, aOut*kEnv
endin

</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...
f0 z
</CsScore>
</CsoundSynthesizer>

<Cabbage>
form caption("Simple Synth") size(310, 310), \
  colour(58, 110, 182), \
  pluginID("def1")
keyboard bounds(12, 164, 281, 95)
rslider bounds(12, 14, 70, 70), \
  channel("att"), \
  range(0, 1, 0.01, 1, .01), \
  text("Attack")
rslider bounds(82, 14, 70, 70), \
  channel("dec"), \
  range(0, 1, 0.5, 1, .01), \
  text("Decay")
rslider bounds(152, 14, 70, 70), \
  channel("sus"), \
  range(0, 1, 0.5, 1, .01), \
  text("Sustain")
rslider bounds(222, 14, 70, 70), \
  channel("rel"), \
  range(0, 1, 0.7, 1, .01), \
  text("Release")
rslider bounds(12, 84, 70, 70), \
  channel("cutoff"), \
  range(0, 22000, 2000, .5, .01), \
  text("Cut-Off")
rslider bounds(82, 84, 70, 70), \
  channel("res"), \
  range(0, 1, 0.7, 1, .01), \
  text("Resonance")
rslider bounds(152, 84, 70, 70), \
  channel("LFOFreq"), \
  range(0, 10, 0, 1, .01), \
  text("LFO Freq")
rslider bounds(222, 84, 70, 70), \
  channel("amp"), \
  range(0, 1, 0.7, 1, .01), \
  text("Amp")
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

 iAtt chnget "att"
 iDec chnget "dec"
 iSus chnget "sus"
 iRel chnget "rel"
 kRes chnget "res"
 kCutOff chnget "cutoff"
 kLFOFreq chnget "LFOFreq"
 kAmp chnget "amp"

 kEnv madsr iAtt, iDec, iSus, iRel
 aOut vco2 iAmp, iFreq
 kLFO lfo 1, kLFOFreq
 aLP moogladder aOut, kLFO*kCutOff, kRes
 outs kAmp*(aLP*kEnv), kAmp*(aLP*kEnv)
endin

</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...
f0 z
</CsScore>
</CsoundSynthesizer>

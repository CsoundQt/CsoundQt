<Cabbage>
form size(280, 160), \
  caption("Simple Reverb"), \
  pluginID("plu1")
groupbox bounds(20, 12, 233, 112), text("groupbox")
rslider bounds(32, 40, 68, 70), \
  channel("size"), \
  range(0, 1, .2, 1, 0.001), \
  text("Size"), \
  colour(2, 132, 0, 255),
rslider bounds(102, 40, 68, 70), \
  channel("fco"), \
  range(1, 22000, 10000, 1, 0.001), \
  text("Cut-Off"), \
  colour(2, 132, 0, 255),
rslider bounds(172, 40, 68, 70), \
  channel("gain"), \
  range(0, 1, .5, 1, 0.001), \
  text("Gain"), \
  colour(2, 132, 0, 255),
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 64
nchnls = 2
0dbfs=1

instr 1
 kFdBack chnget "size"
 kFco chnget "fco"
 kGain chnget "gain"
 aInL inch 1
 aInR inch 2
 aOutL, aOutR reverbsc aInL, aInR, kFdBack, kFco
 outs aOutL*kGain, aOutR*kGain
endin

</CsInstruments>
<CsScore>
f1 0 1024 10 1
i1 0 z
</CsScore>
</CsoundSynthesizer>

; Csound Haiku V
; Iain McCurdy 2011
; small code modifcations by joachim heintz 2024

<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

gisine = ftgen(0,0,4096,10,1)
gasendL init 0
gasendR init 0

instr start_sequences
  iBaseRate = random:i(1,2.5)
  indx = 0
  while (indx < 4) do
    schedule("sound_instr",indx/4*iBaseRate,3600*24*7,iBaseRate,0.9,0.03,0.06,7,0.5,1)
    indx += 1
  od
  ktrig1 = metro(iBaseRate/64)
  schedkwhennamed(ktrig1,0,0,"sound_instr",1/iBaseRate,64/iBaseRate,iBaseRate/16,0.996,0.003,0.01,3,0.7,1)
  schedkwhennamed(ktrig1,0,0,"sound_instr",2/iBaseRate,64/iBaseRate,iBaseRate/16,0.996,0.003,0.01,4,0.7,1)
  ktrig2 = metro(iBaseRate/72)
  schedkwhennamed(ktrig2,0,0,"sound_instr",3/iBaseRate,72/iBaseRate,iBaseRate/20,0.996,0.003,0.01,5,0.7,1)
  schedkwhennamed(ktrig2,0,0,"sound_instr",4/iBaseRate,72/iBaseRate,iBaseRate/20,0.996,0.003,0.01,6,0.7,1)
endin
schedule("start_sequences",0,-1)

instr sound_instr
  if (metro(p4) == 1) then
    reinit PULSE
  endif
  PULSE:
  icps = cpsoct(random:i(7.3,10.5))
  aptr = linseg:a(0,1/icps,1)
    rireturn
  a1 = tablei:a(aptr,gisine,1)
  kamp = rspline:k(0.2,0.7,0.1,0.8)
  a1 *= kamp^3
  kphsoct = rspline:k(6,10,p6,p7)
  isep = random:i(0.5,0.75)
  ksep = transeg:k(isep+1,0.02,-50,isep)
  kfeedback = rspline:k(0.85,0.99,0.01,0.1)
  aphs2 = phaser2(a1,cpsoct(kphsoct),0.3,p8,p10,isep,p5)
  iChoRate = random:i(0.5,2)
  aDlyMod = oscili:a(0.0005,iChoRate,gisine)
  acho = vdelay3(aphs2+a1,(aDlyMod+0.0005+0.0001)*1000,100)
  aphs2 = sum(aphs2,acho)
  aphs2 = butlp(aphs2,1000)
  kenv = linseg:k(1,p3-4,1,4,0)
  kpan = rspline:k(0,1,0.1,0.8)
  kattrel = linsegr:k(1,1,0)
  a1,a2 pan2 aphs2*kenv*p9*kattrel,kpan
  a1 = delay(a1,rnd(0.01)+0.0001)
  a2 = delay(a2,rnd(0.01)+0.0001)
  ksend = rspline:k(0.2,0.7,0.05,0.1) ^ 2
  out(a1*(1-ksend),a2*(1-ksend))
  gasendL += a1*ksend
  gasendR += a2*ksend
endin

instr reverb
  aL,aR reverbsc gasendL,gasendR,0.85,5000
  out(aL,aR)
  clear(gasendL,gasendR)
endin
schedule("reverb",0,-1)

</CsInstruments>
<CsScore>
e 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>

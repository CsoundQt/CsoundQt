; Csound Haiku I
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

gicos = ftgen(0,0,131072,11,1)
gasendL,gasendR init 0
                                 
indx = 0
while (indx < 6) do
  schedule("trombone",indx,99999)
  indx += 1
od

instr trombone
  inote = random:i(54,66)
  knote init int(inote)
  if (metro(0.015) == 1) then
    reinit retrig
  endif
  retrig:
  inote1 init i(knote)
  inote2 = random:i(54,66)
  inote2 = int(inote2)
  inotemid = inote1 + (inote2-inote1)/2
  idur = random:i(22.5,27.5)
  timout(0,idur,skip)
  knote = transeg:k(inote1,idur/2,2,inotemid,idur/2,-2,inote2)
  skip: rireturn
  kenv = linseg:k(0,25,0.05,p3-50,0.05,25,0)
  kdtn = jspline:k(0.05,0.4,0.8)
  kmul = rspline:k(0.3,0.82,0.04,0.2)
  kamp = rspline:k(0.02,3,0.05,0.1)
  a1 = gbuzz(kenv*kamp,mtof:k(knote)*semitone(kdtn),75,1,kmul^1.75,gicos)
  kpan = rspline:k(0,1,0.1,1)
  a1,a2 pan2 a1,kpan
  out(a1,a2)
  gasendL += a1
  gasendR += a2
endin

instr reverb
  aL,aR reverbsc gasendL,gasendR,0.85,10000
  out(aL,aR)
  clear(gasendL,gasendR)
endin
schedule("reverb",0,-1)
          
</CsInstruments>
<CsScore>
e 99999
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

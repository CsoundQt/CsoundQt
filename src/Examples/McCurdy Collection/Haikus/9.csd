; Csound Haiku IX
; Iain McCurdy 2011
; small code modifcations by joachim heintz 2024

<CsoundSynthesizer>
<CsOptions>
-odac -dm0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

giwave = ftgen(0, 0, 128, 10, 1, 1/4, 1/16, 1/64)
giampscl1 = ftgen(0, 0, 20000, -16, 1, 20, 0, 1, 19980, -20, 0.01)
gasendL init 0
gasendR init 0 

instr trigger_arpeggio
  krate = randomh:k(0.0005,0.2,0.04,3)
  schedkwhennamed(metro(krate),0,0,"arpeggio",0,25)
endin
schedule("trigger_arpeggio",0,-1)

instr arpeggio
  ibas = mtof:i((int(random:i(0,24))*3)+24)
  ktrig = metro(rspline:k(0.1,3,0.3,0.7))
  kharm1 = rspline:k(1,14,0.4,0.8)
  kharm2 = random:k(-3,3)
  kharm = mirror:k(kharm1+kharm2,1,23)
  kamp = rspline:k(0,0.05,0.1,0.2)
  schedkwhen(ktrig,0,0,"note",0,4,ibas*int(kharm),kamp)
endin

instr note
  aenv = linsegr:a(0,p3/2,1,p3/2,0,p3/2,0)
  iampscl = table:i(p4,giampscl1)
  asig = oscili:a(p5*aenv*iampscl,p4,giwave)
  adlt = rspline:a(0.01,0.1,0.2,0.3)
  adelsig = vdelay:a(asig,adlt*1000,0.1*1000)
  aL,aR pan2 asig+adelsig,rnd(1)
  out(aL,aR)
  gasendL += aL
  gasendR += aR
endin

instr reverb
  aL, aR reverbsc gasendL, gasendR, 0.88, 10000
  out(aL,aR)
  clear(gasendL,gasendR)
endin
schedule("reverb",0,-1)

</CsInstruments>
<CsScore>
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

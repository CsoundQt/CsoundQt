; Csound Haiku VII
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

giampscl = ftgen(0,0,20000, -16, 1,20,0, 1,19980,-30, 0.1)
giwave = ftgen(0,0,4097, 9, 3,1,0, 10,1/10,0, 18,1/14,0, 26,1/18,0, 34,1/22,0, 42,1/26,0, 50,1/30,0, 58,1/34,0)
gicos = ftgen(0, 0, 131072, 11, 1)
giseq = ftgen(0, 0, 12, -2, 3/2, 2, 3, 1, 1, 3/2, 1/2, 3/4, 5/2, 2/3, 2, 1)
gasendL init 0
gasendR init 0

instr trigger_sequence
  schedkwhennamed(metro(0.2),0,0,"trigger_notes",0,30)
  kcrossfade = rspline:k(0,1,0.01,0.1)
  gkcrossfade = kcrossfade^3
endin
schedule("trigger_sequence",0,-1)

instr trigger_notes
  itime_unit = random:i(2,10)
  istart = random:i(0,6)
  iloop = random:i(6,13)
  ktrig_out = seqtime(int(itime_unit),int(istart),int(iloop),0,giseq)
  idur = random:i(8,15)
  inote = int(random:i(0,48)) + 36
  kSemiDrop = line:k(rnd(2),p3,-rnd(2))
  kcps = mtof:k(inote+int(kSemiDrop))
  ipan = random:i(0,1)
  isend = random:i(0.05,0.2)
  kflam = random:k(0,0.02)
  kamp = rspline:k(0.008,0.4,0.05,0.2)
  ioffset = random:i(-0.2,0.2)
  kattlim = rspline:k(0,1,0.01,0.1)
  schedkwhennamed(ktrig_out,0,0,"long_bell",kflam,idur,kcps*semitone(ioffset),ipan,isend,kamp)
  schedule("gbuzz_long_note",0,30,mtof:i(inote+19))
endin

instr long_bell
  acps = transeg:a(1,p3,3,0.95)
  iattrnd       random           0, 1
  iatt = (random:i(0,1) > p8^1.5) ? 0.002 : p3/2
  aenv = expsega(0.001,iatt,1,p3-0.2-iatt,0.002,0.2,0.001)
  aperc = expseg:a(10000,0.003,p4,1,p4)
  iampscl = table:i(p4,giampscl)
  ijit = random:i(0.5,1)
  a1 = oscili:a(p7*aenv*iampscl*ijit*(1-gkcrossfade),acps*aperc/2,giwave)
  a2 = oscili:a(p7*aenv*iampscl*ijit*(1-gkcrossfade),acps*aperc*semitone(rnd(.02))/2,giwave)
  adlt = rspline:a(1,5,0.4,0.8)
  acho = vdelay(a1,adlt,40)
  a1 -= acho
  acho = vdelay(a2,adlt,40)
  a2 -= acho
  icf = random:i(0,1.75)
  icf = p4 + p4*icf^3
  kcfenv = expseg:k(icf,0.3,icf,p3-0.3,20)
  a1 = butlp(a1,kcfenv)
  a2 = butlp(a2,kcfenv)
  a1 = butlp(a1,kcfenv)
  a2 = butlp(a2,kcfenv)
  out(a1,a2)
  gasendL += a1*p6
  gasendR += a2*p6
endin

instr gbuzz_long_note
  kenv = expseg:k(0.001,3,1,p3-3,0.001)
  kmul = rspline:k(0.01,0.1,0.1,1)
  kNseDep = rspline:k(0,1,0.2,0.4)
  kNse = jspline:k(kNseDep,50,100)
  agbuzz = gbuzz(gkcrossfade/80,p4/2*semitone(kNse),5,1,kmul*kenv,gicos)
  a1 = delay(agbuzz,rnd(0.08)+0.001)
  a2 = delay(agbuzz,rnd(0.08)+0.001)
  gasendL += a1*kenv
  gasendR += a2*kenv
endin

instr reverb
  aL,aR reverbsc gasendL,gasendR,0.95,10000
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

; Csound Haiku III
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

giImpulseWave = ftgen(0,0,4097,10,1,1/2,1/4,1/8)
gitims = ftgen(0,0,128,-7,1,100,0.1)
gamixL,gamixR,gasendL,gasendR init 0    
     
instr start_sequences
  krate = rspline:k(0,1,0.1,2)
  krate = scale(krate^2,10,0.3)
  koct = rspline:k(4.3,9.5,0.1,1)
  kcps = cpsoct(koct)
  kpan = rspline:k(0.1,4,0.1,1)
  kamp = rspline:k(0.1,1,0.25,2)
  kwgoct1 = rspline:k(6,9,0.05,1)
  kwgoct2 = rspline:k(6,9,0.05,1)
  schedkwhennamed(metro(krate),0,0,"wguide2_note",0,4,kcps,kwgoct1,kwgoct2,kamp,kpan)
endin
schedule("start_sequences",0,-1)

instr wguide2_note
  aenv = expon:a(1,10/p4,0.001)
  aimpulse = poscil:a(aenv-0.001,p4,giImpulseWave)
  ioct1 = random:i(5,11)
  ioct2 = random:i(5,11)
  aplk1 = transeg:a(1+rnd(0.2),0.1,-15,1)
  aplk2 = transeg:a(1+rnd(0.2),0.1,-15,1)
  idmptim = random:i(0.1,3)
  kcutoff = expseg:k(20000,p3-idmptim,20000,idmptim,200,1,200)
  awg2 = wguide2(aimpulse,cpsoct(p5)*aplk1,cpsoct(p6)*aplk2,kcutoff,kcutoff,0.27,0.23)
  awg2 = dcblock2(awg2)
  arel = linseg:a(1,p3-idmptim,1,idmptim,0)
  awg2 *= arel
  awg2 /= rnd(4)+3
  aL,aR pan2 awg2,p8
  gasendL += aL*0.05
  gasendR += aR*0.05
  gamixL += aL
  gamixR += aR
endin

instr spatialise
  adlytim1 = rspline:a(0.1,5,0.1,0.4)
  adlytim2 = rspline:a(0.1,5,0.1,0.4)
  aL = vdelay(gamixL,adlytim1,50)
  aR = vdelay(gamixR,adlytim2,50)
  out(aL,aR)
  gasendL += aL*0.05
  gasendR += aR*0.05
  clear(gamixL,gamixR)
endin
schedule("spatialise",0,-1)

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

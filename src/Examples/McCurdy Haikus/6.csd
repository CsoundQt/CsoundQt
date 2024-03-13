; Csound Haiku V
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

gasendL init 0
gasendR init 0
          
instr trigger_6_notes_and_plucks
  inotes[] = fillarray(40,45,50,55,59,64)
  indx = 0
  while (indx < lenarray(inotes)) do
    schedule("string",0,1,inotes[indx])
    indx += 1
  od
  if (metro(rspline:k(0.005,0.15,0.1,0.2)) == 1) then
    schedulek("pluck",0,2)
  endif
endin
schedule("trigger_6_notes_and_plucks",0,-1)

instr pluck
  aenv = expseg:a(0.0001,0.02,1,0.2,0.0001,1,0.0001)
  apluck = pinkish(aenv)
  koct = randomi:k(5,10,2,3)
  gapluck = butlp(apluck,cpsoct(koct))
endin

instr string
  p3 = 3600*24*7 // :)
  adlt = rspline(50,250,0.03,0.06)
  apluck = vdelay3(gapluck,adlt,500)
  adtn = jspline(15,0.002,0.02)
  astring = wguide1(apluck,mtof:i(p4)*semitone(adtn),5000,0.9995)
  astring = dcblock(astring)
  kpan = rspline:k(0,1,0.1,0.2)
  astrL,astrR pan2 astring,kpan
  out(astrL,astrR)
  gasendL += astrL*0.6
  gasendR += astrR*0.6
endin

instr reverb
  aL,aR reverbsc gasendL,gasendR,0.85,10000
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

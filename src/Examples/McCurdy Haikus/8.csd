; Csound Haiku VIII
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

gigaps = ftgen(0, 0, 100, -17, 0,32, 5,2, 45,1/2, 70,1/8, 90,2/9)
gidurs = ftgen(0, 0, 100, -17, 0,0.4, 85,4)
giwave = ftgen(0, 0, 131072, 10, 1, 0, 0, 0, 0.05)
gisine = ftgen(0, 0, 4096, 10, 1)
gasendL init 0
gasendR init 0

instr start_layers
  indx = 0
  while (indx < 3) do
    schedule("layer",0,3600*24*7)
    indx += 1
  od
endin
schedule("start_layers",0,0)

instr layer
  kndx = randomh:k(0,1,1,3)
  kgap = table:k(kndx,gigaps,1)
  knote = randomh:k(0,12,0.1,3)
  kamp = rspline:k(0,0.1,1,2)
  kpan = rspline:k(0.1,0.9,0.1,1)
  kmul = rspline:k(0.1,0.9,0.1,0.3)
  schedkwhen(metro(1/kgap),0,0,"note",rnd:k(0.1),0.01,int(knote)*3,kamp,kpan,kmul)
endin

instr note
  iratio = int(rnd:i(20))+1
  p3 = table:i(rnd:i(1),gidurs,1)
  aenv = expseg:a(1,p3,0.001)
  aperc = expseg:a(5,0.001,1,1,1)
  if (random:i(0,1) <= 0.1) then
    abend = linseg:a(1,p3,semitone(random:i(-8,4)))
    aperc *= abend
  endif
  kmul = expon:k(abs(p7),p3,0.0001)
  a1 = gbuzz(p5*aenv,mtof:i(p4)*iratio*aperc,int(rnd(500))+1,rnd(12)+1,kmul,giwave)
  if (random:i(0,1) <= 0.2) && (p3 > 1) then
    kfshift = transeg:k(0,p3,-15,rnd(200)-100)
    ar,ai hilbert a1
    asin = oscili:a(1,kfshift,gisine,0)
    acos = oscili:a(1,kfshift,gisine,0.25)
    amod1 = ar*acos
    amod2 = ai*asin
    a1 = ((amod1-amod2)/3)+a1
  endif
  a1 = butlp(a1,cpsoct(rnd(8)+4))
  a1,a2 pan2 a1,p6
  a1 = delay(a1,rnd(0.03)+0.001)
  a2 = delay(a2,rnd(0.03)+0.001)
  out(a1,a2)
  gasendL += a1*0.3
  gasendR += a2*0.3
endin

instr reverb
  aL,aR reverbsc gasendL,gasendR,0.75,10000
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

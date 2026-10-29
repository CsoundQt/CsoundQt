; Csound Haiku IV
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
gioctfn = ftgen(0,0,4096,-19,1,0.5,270,0.5)
gasendL,gasendR init 0
ginotes = ftgen(0,0,100,-17,0,8.00,10,8.03,15,8.04,25,8.05,50,8.07,60,8.08,73,8.09,82,8.11)

instr trigger_notes
  ktrig = metro(rspline:k(0.05,0.12,0.05,0.1))
  gktrans = semitone(trandom(ktrig,-1,1))
  idur = 15
  schedkwhen(ktrig,0,0,"hboscil_note",rnd(2),idur)
  schedkwhen(ktrig,0,0,"hboscil_note",rnd(2),idur)
  schedkwhen(ktrig,0,0,"hboscil_note",rnd(2),idur)
  schedkwhen(ktrig,0,0,"hboscil_note",rnd(2),idur)
endin
schedule("trigger_notes",0,-1)

instr hboscil_note
  ipch = table:i(int(rnd(100)),ginotes)
  icps = cpspch(ipch)*i(gktrans)*semitone(rnd(0.5)-0.25)
  kamp = expseg:k(0.001,0.02,0.2,p3-0.01,0.001)
  ktonemoddep = jspline:k(0.01,0.05,0.2)
  ktonemodrte = jspline:k(6,0.1,0.2)
  ktone = oscil:a(ktonemoddep,ktonemodrte,gisine)
  kbrite = rspline:k(-2,3,0.0002,3)
  ibasfreq init icps
  ioctcnt init 2
  iphs init 0
  a1 = hsboscil:a(kamp,ktone,kbrite,ibasfreq,gisine,gioctfn,ioctcnt,iphs)
  amod = oscil:a(1,ibasfreq*3.47,gisine)
  arm = a1*amod
  kmix = expseg:k(0.001,0.01,rnd(1),rnd(3)+0.3,0.001)
  a1 = ntrpol:a(a1,arm,kmix)
  a1 = pareq:a(a1/10,400,15,0.707)
  a1 = tone(a1,500)
  kpanrte = jspline:k(5,0.05,0.1)
  kpandep = jspline:k(0.9,0.2,0.4)
  kpan = oscil:k(kpandep,kpanrte,gisine)
  a1,a2 pan2 a1,kpan
  a1 = delay(a1,rnd(0.1))
  a2 = delay(a2,rnd(0.1))
  kenv = linsegr:k(1,1,0)
  a1 *= kenv
  a2 *= kenv
  out(a1,a2)
  gasendL += a1/6
  gasendR += a2/6
endin

instr reverb
  aL,aR  reverbsc gasendL,gasendR,0.95,10000
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

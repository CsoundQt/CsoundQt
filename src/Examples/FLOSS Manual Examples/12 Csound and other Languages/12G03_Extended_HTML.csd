<CsoundSynthesizer>
; Example about using CSS in html section of CSD
; By Michael Gogins 2016
; Reformatted for flossmanual by Hlödver Sigurdsson

<CsOptions>
-odac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2

iampdbfs init 32768
prints "Default amplitude at 0 dBFS:  %9.4f\n", iampdbfs
idbafs init dbamp(iampdbfs)
prints "dbA at 0 dBFS:                 %9.4f\n", idbafs
iheadroom init 6
prints "Headroom (dB):                 %9.4f\n", iheadroom
idbaheadroom init idbafs - iheadroom
prints "dbA at headroom:               %9.4f\n", idbaheadroom
iampheadroom init ampdb(idbaheadroom)
prints "Amplitude at headroom:        %9.4f\n", iampheadroom
prints "Balance so the overall amps at the end of performance -6 dbfs.\n"

connect "ModerateFM", "outleft", "Reverberation", "inleft"
connect "ModerateFM", "outright", "Reverberation", "inright"
connect "Reverberation", "outleft", "MasterOutput", "inleft"
connect "Reverberation", "outright", "MasterOutput", "inright"

alwayson "Reverberation"
alwayson "MasterOutput"
alwayson "Controls"

gk_FmIndex init 0.5
gk_FmCarrier init 1

//////////////////////////////////////////////
// By Michael Gogins.
//////////////////////////////////////////////
instr ModerateFM
  i_instrument = p1
  i_time = p2
  i_duration = p3
  i_midikey = p4
  i_midivelocity = p5
  i_phase = p6
  i_pan = p7
  i_depth = p8
  i_height = p9
  i_pitchclassset = p10
  i_homogeneity = p11
  iattack = 0.002
  isustain = p3
  idecay = 8
  irelease = 0.05
  iHz = cpsmidinn(i_midikey)
  idB = i_midivelocity
  iamplitude = ampdb(idB) * 4.0
  kcarrier = gk_FmCarrier
  imodulator = 0.5
  ifmamplitude = 0.25
  kindex = gk_FmIndex * 20
  ifrequencyb = iHz * 1.003
  kcarrierb = kcarrier * 1.004
  aindenv transeg 0.0, iattack, -11.0, 1.0, idecay, -7.0, 0.025, isustain, \
                  0.0, 0.025, irelease, -7.0, 0.0
  aindex = aindenv * kindex * ifmamplitude
  isinetable ftgenonce 0, 0, 65536, 10, 1, 0, .02

  ; ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
  aouta  foscili 1.0, iHz, kcarrier, imodulator, kindex / 4., isinetable
  aoutb  foscili 1.0, ifrequencyb, kcarrierb, imodulator, kindex, isinetable

  ; Plus amplitude correction.
  asignal = (aouta + aoutb) * aindenv
  adeclick linsegr 0, iattack, 1, isustain, 1, irelease, 0
  asignal = asignal * iamplitude
  aoutleft, aoutright pan2 asignal * adeclick, i_pan
  outleta "outleft",  aoutleft
  outleta "outright", aoutright
  prints "instr %4d t %9.4f d %9.4f k %9.4f v %9.4f p %9.4f\n", \
          p1, p2, p3, p4, p5, p7
endin

gkReverberationWet init .5
gk_ReverberationDelay init .6

instr Reverberation
  ainleft inleta "inleft"
  ainright inleta "inright"
  aoutleft = ainleft
  aoutright = ainright
  kdry = 1.0 - gkReverberationWet
  awetleft, awetright reverbsc ainleft, ainright, gk_ReverberationDelay, 18000
  aoutleft = ainleft *  kdry + awetleft  * gkReverberationWet
  aoutright = ainright * kdry + awetright * gkReverberationWet
  outleta "outleft", aoutleft
  outleta "outright", aoutright
  prints "instr %4d t %9.4f d %9.4f k %9.4f v %9.4f p %9.4f\n", \
          p1, p2, p3, p4, p5, p7
endin

gk_MasterLevel init 1

instr MasterOutput
  ainleft inleta "inleft"
  ainright inleta "inright"
  aoutleft = gk_MasterLevel * ainleft
  aoutright = gk_MasterLevel * ainright
  outs aoutleft, aoutright
  prints "instr %4d t %9.4f d %9.4f k %9.4f v %9.4f p %9.4f\n", \
          p1, p2, p3, p4, p5, p7
endin

instr Controls
  gk_FmIndex_ chnget "gk_FmIndex"
  if gk_FmIndex_  != 0 then
   gk_FmIndex = gk_FmIndex_
  endif

  gk_FmCarrier_ chnget "gk_FmCarrier"
  if gk_FmCarrier_  != 0 then
   gk_FmCarrier = gk_FmCarrier_
  endif

  gk_ReverberationDelay_ chnget "gk_ReverberationDelay"
  if gk_ReverberationDelay_  != 0 then
   gk_ReverberationDelay = gk_ReverberationDelay_
  endif

  gk_MasterLevel_ chnget "gk_MasterLevel"
  if gk_MasterLevel_  != 0 then
   gk_MasterLevel = gk_MasterLevel_
  endif
endin

</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>

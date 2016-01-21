<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -dnm128 -odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
0dbfs = 1
nchnls = 2
seed 1 ;change to zero for always changing results

;****SETTINGS FOR PITCHES****
 ;define the pitch street in octave notation
giLowestPitch =     7
giHighestPitch =    9
 ;set pitch startpoint, deviation range and the first direction
giStartPitch =      8
gkPitchDev init     0.2 ;random range for next pitch
gkPitchDir init     0.1 ;positive = upwards

;****SETTINGS FOR DENSITY****
 ;define the maximum and minimum density (notes per second)
giLowestDens =      1
giHighestDens =     8
 ;set first density
giStartDens =       3
 ;set possible deviation in range 0..1
 ;0 = no deviation at all
 ;1 = possible deviation is between half and twice the current density
gkDensDev init      0.5
 ;set direction in the same range 0..1
 ;(positive = more dense, shorter notes)
gkDensDir init      0.1

;****INSTRUMENT FOR RANDOM WALK****
  instr walk
 ;set initial values
kPitch    init      giStartPitch
kDens     init      giStartDens
 ;trigger impulses according to density
kTrig     metro     kDens
 ;if the metro ticks
 if kTrig == 1 then
  ;1) play current note
          event     "i", "play", 0, 1.5/kDens, kPitch
  ;2) calculate next pitch
   ;define boundaries according to direction
kLowPchBound =      gkPitchDir < 0 ? -gkPitchDev+gkPitchDir : -gkPitchDev
kHighPchBound =     gkPitchDir > 0 ? gkPitchDev+gkPitchDir : gkPitchDev
   ;get random value in these boundaries
kPchRnd   random    kLowPchBound, kHighPchBound
   ;add to current pitch
kPitch += kPchRnd
  ;change direction if maxima are crossed, and report
  if kPitch > giHighestPitch && gkPitchDir > 0 then
gkPitchDir =        -gkPitchDir
          printks   " Pitch touched maximum - now moving down.\n", 0
  elseif kPitch < giLowestPitch && gkPitchDir < 0 then
gkPitchDir =        -gkPitchDir
          printks   "Pitch touched minimum - now moving up.\n", 0
  endif
  ;3) calculate next density (= metro frequency)
   ;define boundaries according to direction
kLowDensBound =     gkDensDir < 0 ? -gkDensDev+gkDensDir : -gkDensDev
kHighDensBound =    gkDensDir > 0 ? gkDensDev+gkDensDir : gkDensDev
   ;get random value in these boundaries
kDensRnd  random    kLowDensBound, kHighDensBound
   ;get multiplier (so that kDensRnd=1 yields to 2, and kDens=-1 to 1/2)
kDensMult =         2 ^ kDensRnd
   ;multiply with current duration
kDens *= kDensMult
   ;avoid too high values and too low values
kDens     =         kDens > giHighestDens*1.5 ? giHighestDens*1.5 : kDens
kDens     =         kDens < giLowestDens/1.5 ? giLowestDens/1.5 : kDens
   ;change direction if maxima are crossed
  if (kDens > giHighestDens && gkDensDir > 0) || (kDens < giLowestDens && gkDensDir < 0) then
gkDensDir =         -gkDensDir
   if kDens > giHighestDens then
          printks   " Density touched upper border - now becoming less dense.\n", 0
          else
          printks   " Density touched lower border - now becoming more dense.\n", 0
   endif
  endif
 endif
  endin

;****INSTRUMENT TO PLAY ONE NOTE****
  instr play
 ;get note as octave and calculate frequency and panning
iOct       =          p4
iFreq      =          cpsoct(iOct)
iPan       ntrpol     0, 1, iOct, giLowestPitch, giHighestPitch
 ;calculate mode filter quality according to duration
iQ         ntrpol     10, 400, p3, .15, 1.5
 ;generate tone and throw out
aImp       mpulse     1, p3
aMode      mode       aImp, iFreq, iQ
aOut       linen      aMode, 0, p3, p3/4
aL, aR     pan2       aOut, iPan
           outs       aL, aR
  endin

</CsInstruments>
<CsScore>
i "walk" 0 999
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz 

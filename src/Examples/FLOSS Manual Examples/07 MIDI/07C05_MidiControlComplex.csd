<CsoundSynthesizer>
<CsOptions>
-Ma -odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giCos   ftgen    0,0,2^12,11,1 ; a cosine wave
         initc7   1,1,1        ; initialize controller to its maximum level

  instr 1
iNum      notnum                   ; read in midi note number
iAmp      ampmidi 0.1              ; read in note velocity - range 0 to 0.2
kVol      ctrl7   1,1,0,1          ; read in CC 1, chn 1. Re-range from 0 to 1
kPortTime linseg 0,0.001,0.01   ; create a value that quickly ramps up to 0.01
kVol      portk   kVol, kPortTime  ; create filtered version of kVol
aVol      interp  kVol             ; create an a-rate version of kVol.
iRange    =       2                ; pitch bend range in semitones
iMin      =       0                ; equilibrium position
kPchBnd   pchbend iMin, 2*iRange   ; pitch bend in semitones (range -2 to 2)
kPchBnd   portk   kPchBnd,kPortTime; create a filtered version of kPchBnd
aEnv      linsegr 0,0.005,1,0.1,0  ; amplitude envelope with release stage
kMul      aftouch 0.4,0.85         ; read in aftertouch
kMul      portk   kMul,kPortTime   ; create a filtered version of kMul
; create an audio signal using the 'gbuzz' additive synthesis opcode
aSig      gbuzz   iAmp*aVol*aEnv,cpsmidinn(iNum+kPchBnd),70,0,kMul,giCos
          out     aSig             ; audio to output
  endin

</CsInstruments>

<CsScore>
</CsScore>
<CsoundSynthesizer>
;example by Iain McCurdy

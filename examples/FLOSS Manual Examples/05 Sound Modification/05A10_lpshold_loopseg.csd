<CsoundSynthesizer>
<CsOptions>
-odac ;activates real time sound output
</CsOptions>
<CsInstruments>
; Example by Iain McCurdy

sr = 44100
ksmps = 4
nchnls = 1
0dbfs = 1

seed 0; seed random number generators from system clock

  instr 1; Bassline instrument
kTempo    =            90          ; tempo in beats per minute
kCfBase   randomi      1,4, 0.2    ; base filter frequency (oct format)
kCfEnv    randomi      0,4,0.2     ; filter envelope depth
kRes      randomi      0.5,0.9,0.2 ; filter resonance
kVol      =            0.5         ; volume control
kDecay    randomi      -10,10,0.2  ; decay shape of the filter.
kWaveform =            0           ; oscillator waveform. 0=sawtooth 2=square
kDist     randomi      0,1,0.1     ; amount of distortion
kPhFreq   =            kTempo/240  ; freq. to repeat the entire phrase
kBtFreq   =            (kTempo)/15 ; frequency of each 1/16th note
; -- Envelopes with held segments  --
; The first value of each pair defines the relative duration of that segment,
; the second, the value itself.
; Note numbers (kNum) are defined as MIDI note numbers.
; Note On/Off (kOn) and hold (kHold) are defined as on/off switches, 1 or zero
;                    note:1      2     3     4     5     6     7     8
;                         9     10    11    12    13    14    15    16    0
kNum  lpshold kPhFreq, 0, 0,40,  1,42, 1,50, 1,49, 1,60, 1,54, 1,39, 1,40, \
                       1,46, 1,36, 1,40, 1,46, 1,50, 1,56, 1,44, 1,47,1
kOn   lpshold kPhFreq, 0, 0,1,   1,1,  1,1,  1,1,  1,1,  1,1,  1,0,  1,1,  \
                       1,1,  1,1,  1,1,  1,1,  1,1,  1,1,  1,0,  1,1,  1
kHold lpshold kPhFreq, 0, 0,0,   1,1,  1,1,  1,0,  1,0,  1,0,  1,0,  1,1,  \
                       1,0,  1,0,  1,1,  1,1,  1,1,  1,1,  1,0,  1,0,  1
kHold     vdel_k       kHold, 1/kBtFreq, 1 ; offset hold by 1/2 note duration
kNum      portk        kNum, (0.01*kHold)  ; apply portamento to pitch changes
                                           ; if note is not held: no portamento
kCps      =            cpsmidinn(kNum)     ; convert note number to cps
kOct      =            octcps(kCps)        ; convert cps to oct format
; amplitude envelope                  attack    sustain       decay  gap
kAmpEnv   loopseg      kBtFreq, 0, 0, 0,0.1, 1, 55/kTempo, 1, 0.1,0, 5/kTempo,0,0
kAmpEnv   =            (kHold=0?kAmpEnv:1)  ; if a held note, ignore envelope
kAmpEnv   port         kAmpEnv,0.001

; filter envelope
kCfOct    looptseg      kBtFreq,0,0,kCfBase+kCfEnv+kOct,kDecay,1,kCfBase+kOct
; if hold is off, use filter envelope, otherwise use steady state value:
kCfOct    =             (kHold=0?kCfOct:kCfBase+kOct)
kCfOct    limit        kCfOct, 4, 14 ; limit the cutoff frequency (oct format)
aSig      vco2         0.4, kCps, i(kWaveform)*2, 0.5 ; VCO-style oscillator
aFilt      lpf18        aSig, cpsoct(kCfOct), kRes, (kDist^2)*10 ; filter audio
aSig      balance       aFilt,aSig             ; balance levels
kOn       port         kOn, 0.006              ; smooth on/off switching
; audio sent to output, apply amp. envelope,
; volume control and note On/Off status
aAmpEnv   interp       kAmpEnv*kOn*kVol
          out          aSig * aAmpEnv
  endin

</CsInstruments>
<CsScore>
i 1 0 3600 ; instr 1 plays for 1 hour
e
</CsScore>
</CsoundSynthesizer>

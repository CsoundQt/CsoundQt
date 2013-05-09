<CsoundSynthesizer>

<CsOptions>
-odac ; activates real time sound output
</CsOptions>

<CsInstruments>
; Example by Iain McCurdy

sr =  44100
ksmps = 32
nchnls = 2
0dbfs = 1

; initialize zak space  - one a-rate and one k-rate variable.
; We will only be using the a-rate variable.
             zakinit   1, 1

  instr 1 ; sound generating instrument - sparse noise bursts
kEnv         loopseg   0.5,0, 0,1,0.003,1,0.0001,0,0.9969,0,0; amp. env.
aSig         pinkish   kEnv       ; pink noise pulses
             outs      aSig, aSig ; send audio to outputs
iRvbSendAmt  =         0.8        ; reverb send amount (0 - 1)
; write to zak audio channel 1 with mixing
             zawm      aSig*iRvbSendAmt, 1
  endin

  instr 5 ; reverb - always on
aInSig       zar       1    ; read first zak audio channel
kFblvl       init      0.88 ; feedback level - i.e. reverb time
kFco         init      8000 ; cutoff freq. of a filter within the reverb
; create reverberated version of input signal (note stereo input and output)
aRvbL,aRvbR  reverbsc  aInSig, aInSig, kFblvl, kFco
             outs      aRvbL, aRvbR ; send audio to outputs
             zacl      0, 1         ; clear zak audio channels
  endin

</CsInstruments>

<CsScore>
i 1 0 10 ; noise pulses (input sound)
i 5 0 12 ; start reverb
e
</CsScore>

</CsoundSynthesizer>

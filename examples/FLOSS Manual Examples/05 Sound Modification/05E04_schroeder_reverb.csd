<CsoundSynthesizer>

<CsOptions>
-odac -m0
; activate real time sound output and suppress note printing
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

sr =  44100
ksmps = 1
nchnls = 2
0dbfs = 1

giSine       ftgen       0, 0, 2^12, 10, 1 ; a sine wave
gaRvbSend    init        0                 ; global audio variable initialized
giRvbSendAmt init        0.4               ; reverb send amount (range 0 - 1)

  instr 1 ; trigger drum hits
ktrigger    metro       5                  ; rate of drum strikes
kdrum       random      2, 4.999           ; randomly choose which drum to hit
            schedkwhen  ktrigger, 0, 0, kdrum, 0, 0.1 ; strike a drum
  endin

  instr 2 ; sound 1 - bass drum
iamp        random      0, 0.5               ; amplitude randomly chosen
p3          =           0.2                  ; define duration for this sound
aenv        line        1,p3,0.001           ; amplitude envelope (percussive)
icps        exprand     30                   ; cycles-per-second offset
kcps        expon       icps+120,p3,20       ; pitch glissando
aSig        oscil       aenv*0.5*iamp,kcps,giSine  ; oscillator
            outs        aSig, aSig           ; send audio to outputs
gaRvbSend   =           gaRvbSend + (aSig * giRvbSendAmt) ; add to send
  endin

  instr 3 ; sound 3 - snare
iAmp        random      0, 0.5                   ; amplitude randomly chosen
p3          =           0.3                      ; define duration
aEnv        expon       1, p3, 0.001             ; amp. envelope (percussive)
aNse        noise       1, 0                     ; create noise component
iCps        exprand     20                       ; cps offset
kCps        expon       250 + iCps, p3, 200+iCps ; create tone component gliss.
aJit        randomi     0.2, 1.8, 10000          ; jitter on freq.
aTne        oscil       aEnv, kCps*aJit, giSine  ; create tone component
aSig        sum         aNse*0.1, aTne           ; mix noise and tone components
aRes        comb        aSig, 0.02, 0.0035       ; comb creates a 'ring'
aSig        =           aRes * aEnv * iAmp       ; apply env. and amp. factor
            outs        aSig, aSig               ; send audio to outputs
gaRvbSend   =           gaRvbSend + (aSig * giRvbSendAmt); add to send
  endin

  instr 4 ; sound 4 - closed hi-hat
iAmp        random      0, 1.5               ; amplitude randomly chosen
p3          =           0.1                  ; define duration for this sound
aEnv        expon       1,p3,0.001           ; amplitude envelope (percussive)
aSig        noise       aEnv, 0              ; create sound for closed hi-hat
aSig        buthp       aSig*0.5*iAmp, 12000 ; highpass filter sound
aSig        buthp       aSig,          12000 ; -and again to sharpen cutoff
            outs        aSig, aSig           ; send audio to outputs
gaRvbSend   =           gaRvbSend + (aSig * giRvbSendAmt) ; add to send
  endin


  instr 5 ; schroeder reverb - always on
; read in variables from the score
kRvt        =           p4
kMix        =           p5

; print some information about current settings gleaned from the score
            prints      "Type:"
            prints      p6
            prints      "\\nReverb Time:%2.1f\\nDry/Wet Mix:%2.1f\\n\\n",p4,p5

; four parallel comb filters
a1          comb        gaRvbSend, kRvt, 0.0297; comb filter 1
a2          comb        gaRvbSend, kRvt, 0.0371; comb filter 2
a3          comb        gaRvbSend, kRvt, 0.0411; comb filter 3
a4          comb        gaRvbSend, kRvt, 0.0437; comb filter 4
asum        sum         a1,a2,a3,a4 ; sum (mix) the outputs of all comb filters

; two allpass filters in series
a5          alpass      asum, 0.1, 0.005 ; send mix through first allpass filter
aOut        alpass      a5, 0.1, 0.02291 ; send 1st allpass through 2nd allpass

amix        ntrpol      gaRvbSend, aOut, kMix  ; create a dry/wet mix
            outs        amix, amix             ; send audio to outputs
            clear       gaRvbSend              ; clear global audio variable
  endin

</CsInstruments>

<CsScore>
; room reverb
i 1  0 10                     ; start drum machine trigger instr
i 5  0 11 1 0.5 "Room Reverb" ; start reverb

; tight ambience
i 1 11 10                          ; start drum machine trigger instr
i 5 11 11 0.3 0.9 "Tight Ambience" ; start reverb

; long reverb (low in the mix)
i 1 22 10                                      ; start drum machine
i 5 22 15 5 0.1 "Long Reverb (Low In the Mix)" ; start reverb

; very long reverb (high in the mix)
i 1 37 10                                            ; start drum machine
i 5 37 25 8 0.9 "Very Long Reverb (High in the Mix)" ; start reverb
e
</CsScore>

</CsoundSynthesizer>

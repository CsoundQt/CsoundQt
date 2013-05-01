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

  instr 1 ; sound generating instrument - sparse noise bursts
kEnv         loopseg   0.5,0, 0,1,0.003,1,0.0001,0,0.9969,0,0 ; amp. envelope
aSig         pinkish   kEnv                                 ; noise pulses
             outs      aSig, aSig                           ; audio to outs
iRvbSendAmt  =         0.4                        ; reverb send amount (0 - 1)
;write audio into the named software channel:
             chnmix    aSig*iRvbSendAmt, "ReverbSend"
  endin

  instr 5 ; reverb (always on)
aInSig       chnget    "ReverbSend"   ; read audio from the named channel
kTime        init      4              ; reverb time
kHDif        init      0.5            ; 'high frequency diffusion' (0 - 1)
aRvb         nreverb   aInSig, kTime, kHDif ; create reverb signal
outs         aRvb, aRvb               ; send audio to outputs
             chnclear  "ReverbSend"   ; clear the named channel
endin

</CsInstruments>

<CsScore>
i 1 0 10 ; noise pulses (input sound)
i 5 0 12 ; start reverb
e
</CsScore>

</CsoundSynthesizer>

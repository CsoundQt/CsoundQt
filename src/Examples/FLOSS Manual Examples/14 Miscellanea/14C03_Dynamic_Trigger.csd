<CsoundSynthesizer>
<CsOptions>
-dm0 -iadc -odac
</CsOptions>
<CsInstruments>
sr     =  44100
ksmps  =  32
nchnls =  2
0dbfs  =  1

instr   1
 iThresh  =       0.1                ; change threshold
 aSig     inch    1                  ; live audio in
 iWait    =       1000              ; prevent repeats wait time (in samples)
 kTimer   init    1001               ; initial timer value
 kRms     rms     aSig, 20           ; track amplitude
 iSampTim =       0.01    ; time across which change in RMS will be measured
 kRmsPrev delayk  kRms, iSampTim     ; delayed RMS (previous)
 kChange  =       kRms - kRmsPrev    ; change
 if(kTimer>iWait) then               ; if we are beyond the wait time...
  kTrig   =       kChange > iThresh ? 1 : 0 ; trigger if threshold exceeded
  kTimer  =  kTrig == 1 ? 0 : kTimer ; reset timer when a trigger generated
 else                     ; otherwise (we are within the wait time buffer)
  kTimer  +=      ksmps              ; increment timer
  kTrig   =       0                  ; cancel trigger
 endif
          schedkwhen kTrig,0,0,2,0,0.1 ; trigger a note event
endin

instr   2
 aEnv     transeg   0.2, p3, -4, 0     ; decay envelope
 aSig     poscil    aEnv, 400          ; 'ping' sound indicator
          out       aSig               ; send audio to output
endin

</CsInstruments>
<CsScore>
i 1 0 [3600*24*7]
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy

<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

  instr 1
aEnv     linseg   0, p3*0.5, .2, p3*0.5, 0 ; rising then falling envelope
aSig     poscil   aEnv, 500
         out      aSig, aSig
  endin

</CsInstruments>

<CsScore>
; 3 notes of different durations are played
i 1 0   1
i 1 2 0.1
i 1 3   5
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy

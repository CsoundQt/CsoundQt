<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

  instr 1 ; linseg envelope
aEnv     linseg   0.2, 2, 0      ; linseg holds its last value
aSig     poscil   aEnv, 500
         out      aSig, aSig
  endin

  instr 2 ; line envelope
aEnv     line     0.2, 2, 0      ; line continues its trajectory
aSig     poscil   aEnv, 500
         out      aSig
  endin

</CsInstruments>
<CsScore>
i 1 0 4 ; linseg envelope
i 2 5 4 ; line envelope
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy and joachim heintz

<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

  instr 1 ; line envelope
aEnv     line     1, p3, 0
aSig     poscil   aEnv, 500
         out      aSig, aSig
  endin

  instr 2 ; expon envelope
aEnv     expon    1, p3, 0.0001
aSig     poscil   aEnv, 500
         out      aSig, aSig
  endin

</CsInstruments>
<CsScore>
i 1 0 2 ; line envelope
i 2 2 1 ; expon envelope
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy
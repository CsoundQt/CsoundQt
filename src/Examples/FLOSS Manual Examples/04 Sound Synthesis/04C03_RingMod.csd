<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr Carrier
 aPartial_1 poscil .2, 400
 aPartial_2 poscil .2, 800
 aPartial_3 poscil .2, 1200
 gaCarrier sum aPartial_1, aPartial_2, aPartial_3
 ;only output this signal if RM is not playing
 if (active:k("RM") == 0) then
  out gaCarrier, gaCarrier
 endif
endin

instr RM
 iModFreq = p4
 aRM = gaCarrier * poscil:a(1,iModFreq)
 out aRM, aRM
endin

</CsInstruments>
<CsScore>
i "Carrier" 0 14
i "RM" 3 3 100
i "RM" 9 3 50
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
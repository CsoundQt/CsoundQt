<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr AM1
 aDC_Offset linseg 0.2, 1, 0.2, 5, 0.4, 3, 0
 aModulator poscil 0.4, 40
 aCarrier poscil aDC_Offset+aModulator, 440
 out aCarrier, aCarrier
endin


instr AM2
 aDC_Offset linseg 0.2, 1, 0.2, 5, 0.4, 3, 0
 aModulator poscil 0.4, 40
 aCarrier poscil 1, 440
 aAM = aCarrier * (aModulator+aDC_Offset)
 out aAM, aAM
endin

</CsInstruments>
<CsScore>
i "AM1" 0 10
i "AM2" 11 10
</CsScore>
</CsoundSynthesizer>
; example by Alex Hofmann and joachim heintz

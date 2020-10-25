<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
 aRaise expseg 2, 20, 100
 aModulator poscil 0.3, aRaise
 iDCOffset = 0.3
 aCarrier poscil iDCOffset+aModulator, 440
 out aCarrier, aCarrier
endin

</CsInstruments>
<CsScore>
i 1 0 25
</CsScore>
</CsoundSynthesizer>
; example by Alex Hofmann and joachim heintz
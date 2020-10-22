<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr Ratio
 kRatio = p4
 kCarFreq = 400
 kModFreq = kCarFreq/kRatio
 aModulator poscil 500, kModFreq
 aCarrier poscil 0.3, kCarFreq + aModulator
 aOut linen aCarrier, .1, p3, 1
 out aOut, aOut
endin

</CsInstruments>
<CsScore>
i 1 0 5 2
i . + . 2.1
</CsScore>
</CsoundSynthesizer>
;example written by marijana janevska
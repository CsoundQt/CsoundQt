<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr Rising_index
 kModAmp = 400
 kIndex linseg 3, p3, 8
 kModFreq = kModAmp/kIndex
 aModulator poscil kModAmp, kModFreq
 aCarrier poscil 0.3, 400 + aModulator
 aOut linen aCarrier, .1, p3, 1
 out aOut, aOut
endin

</CsInstruments>
<CsScore>
i "Rising_index" 0 10
</CsScore>
</CsoundSynthesizer>
;example by marijana janevska and joachim heintz

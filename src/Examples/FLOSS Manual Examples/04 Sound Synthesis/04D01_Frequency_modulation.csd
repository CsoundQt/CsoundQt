<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr FM_vibr ;vibrato as the modulator is in the sub-audio range
 kModFreq randomi 5, 10, 1
 kCarAmp linen 0.5, 0.1, p3, 0.5
 aModulator poscil 20, kModFreq
 aCarrier poscil kCarAmp, 400 + aModulator
 out aCarrier, aCarrier
endin

instr FM_timbr ;timbre change as the modulator is in the audio range
 kModAmp linseg 0, p3/2, 212, p3/2, 50
 kModFreq line 25, p3, 300
 kCarAmp linen 0.5, 0.1, p3, 0.5
 aModulator poscil kModAmp, kModFreq
 aCarrier poscil kCarAmp, 400 + aModulator
 out aCarrier, aCarrier
endin

</CsInstruments>
<CsScore>
i "FM_vibr" 0 10
i "FM_timbr" 10 10
</CsScore>
</CsoundSynthesizer>
;example by marijana janevska
<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 8192, 10, 1

instr PM
 kCarFreq = 200
 kModFreq = 280
 kModFactor = kCarFreq/kModFreq
 kIndex = 12/6.28   ;  12/2pi to convert from radians to norm. table index
 aEnv expseg .001, 0.001, 1, 0.3, 0.5, 8.5, .001
 aModulator poscil kIndex*aEnv, kModFreq
 aPhase phasor kCarFreq
 aCarrier tablei aPhase+aModulator, giSine, 1, 0, 1
 out aCarrier*aEnv, aCarrier*aEnv
endin

</CsInstruments>
<CsScore>
i "PM" 0 9
</CsScore>
</CsoundSynthesizer>
;example by Alex Hofmann

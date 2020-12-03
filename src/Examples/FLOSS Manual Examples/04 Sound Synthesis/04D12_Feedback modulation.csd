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

instr feedback_PM
 kCarFreq = 200
 kFeedbackAmountEnv linseg 0, 2, 0.2, 0.1, 0.3, 0.8, 0.2, 1.5, 0
 aAmpEnv expseg .001, 0.001, 1, 0.3, 0.5, 8.5, .001
 aPhase phasor kCarFreq
 aCarrier init 0 ; init for feedback
 aCarrier tablei aPhase+(aCarrier*kFeedbackAmountEnv), giSine, 1, 0, 1
 outs aCarrier*aAmpEnv, aCarrier*aAmpEnv
endin

</CsInstruments>
<CsScore>
i "feedback_PM" 0 9
</CsScore>
</CsoundSynthesizer>
;example by Alex Hofmann

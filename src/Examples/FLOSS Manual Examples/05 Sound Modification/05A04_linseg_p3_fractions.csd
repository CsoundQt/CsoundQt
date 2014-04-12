<CsoundSynthesizer>

<CsOptions>
--env:SSDIR+=../SourceMaterials -odac ;activates real time sound output
</CsOptions>

<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giSine   ftgen    0, 0, 2^12, 10, 1 ; a sine wave

  instr 1
aEnv     linseg   0, p3*0.5, 1, p3*0.5, 0 ; rising then falling envelope
aSig     poscil   aEnv, 500, giSine
         out      aSig
  endin

</CsInstruments>

<CsScore>
; 3 notes of different durations are played
i 1 0   1
i 1 2 0.1
i 1 3   5
e
</CsScore>

</CsoundSynthesizer>

<CsoundSynthesizer>
<CsOptions>
-o dac  --env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr RM_static
aMod     poscil     1, p4
aCar     diskin    "fox.wav"
aRM      =         aMod * aCar
         out       aRM, aRM
endin

instr RM_moving
aMod     poscil     1, randomi:k(400,1000,p4,3)
aCar     diskin    "fox.wav"
aRM      =         aMod * aCar
         out       aRM, aRM
endin

</CsInstruments>
<CsScore>
i "RM_static" 0 3 400
i .           + . 800
i .           + . 1600
i "RM_moving" 10 3 1
i .           + .  10
i .           + .  100
</CsScore>
</CsoundSynthesizer>
;written by Alex Hofmann and joachim heintz

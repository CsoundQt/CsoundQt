<CsoundSynthesizer>
<CsOptions>
-o dac -m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giEnv ftgen 0, 0, 8192, 9, 1/2, 1, 0 ;half sine as envelope

instr EnvFreq
 printf "   Envelope frequency rising from %d to %d Hz\n", 1, p4, p5
 gkEnvFreq expseg p4, 3, p4, 2, p5
endin

instr GrainGenSync
 puts "\nSYNCHRONOUS GRANULAR SYNTHESIS", 1
 aEnv poscil .2, gkEnvFreq, giEnv
 aOsc poscil aEnv, 400
 aOut linen aOsc, .1, p3, .5
 out aOut, aOut
endin

instr GrainGenAsync
 puts "\nA-SYNCHRONOUS GRANULAR SYNTHESIS", 1
 aEnv poscil .2, gkEnvFreq+randomi:k(0,gkEnvFreq,gkEnvFreq), giEnv
 aOsc poscil aEnv, 400
 aOut linen aOsc, .1, p3, .5
 out aOut, aOut
endin

</CsInstruments>
<CsScore>
i "GrainGenSync" 0 30
i "EnvFreq" 0 5 1 10
i . + . 10 20
i . + . 20 50
i . + . 50 100
i . + . 100 300
b 31
i "GrainGenAsync" 0 30
i "EnvFreq" 0 5 1 10
i . + . 10 20
i . + . 20 50
i . + . 50 100
i . + . 100 300
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

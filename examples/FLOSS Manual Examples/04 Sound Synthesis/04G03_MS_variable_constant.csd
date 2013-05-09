<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 1
nchnls = 2
0dbfs = 1

instr MassSpring
;initial values
a0        init      0
a1        init      0.05
kc        randomi   .001, .05, 8, 3
;calculation of the next value
a2        =         a1+(a1-a0) - kc*a1
          outs      a0, a0
;actualize values for the next step
a0        =         a1
a1        =         a2
endin
</CsInstruments>
<CsScore>
i "MassSpring" 0 10
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

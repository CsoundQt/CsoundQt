<CsoundSynthesizer>
<CsOptions>
-odac -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr TimeLoop
 //set desired time for time loop
 kLoopTime = 1/2
 //set kTime to zero at start
 kTime init 0
 //trigger event if zero has reached ...
 if kTime <= 0 then
  event "i", "Play", 0, .3
  //... and reset time
  kTime = kLoopTime
 endif
 //subtract time for each control cycle
 kTime -= 1/kr
endin

instr Play
 aEnv transeg 1, p3, -10, 0
 aSig poscil .2*aEnv, 400
 out aSig, aSig
endin

</CsInstruments>
<CsScore>
i "TimeLoop" 0 10
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

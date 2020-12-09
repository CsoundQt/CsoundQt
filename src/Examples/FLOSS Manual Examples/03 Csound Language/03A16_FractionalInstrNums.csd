<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
sr = 44100
nchnls = 2
0dbfs = 1
ksmps = 32
seed 0

giArr[] fillarray 60, 68, 67, 66, 65, 64, 63

instr 1
 iMidiNote = p4
 iFreq mtof iMidiNote
 aPluck pluck .1, iFreq, iFreq, 0, 1
 aOut linenr aPluck, 0, 1, .01
 out aOut, aOut
endin

instr Trigger
 index = 0
 while index < lenarray(giArr) do
  iInstrNum = nstrnum("Play")+index/10
  schedule(iInstrNum,index+random:i(0,.5),5)
  index += 1
 od
endin

instr Play
 iIndx = frac(p1)*10 //index is fractional part of instr number
 iFreq = mtof:i(giArr[round(iIndx)])
 aPluck pluck .1, iFreq, iFreq, 0, 1
 aOut linenr aPluck, 0, 1, .01
 out aOut, aOut
endin

</CsInstruments>
<CsScore>
//traditional score
t 0 90
i 1.0 0 -1 60
i 1.1 1 -1 65
i 1.2 2 -1 55
i 1.3 3 -1 70
i 1.4 4 -1 50
i 1.5 5 -1 75

i -1.4 7 1 0
i -1.1 8 1 0
i -1.5 9 1 0
i -1.0 10 1 0
i -1.3 11 1 0
i -1.2 12 1 0

//event generating instrument
i "Trigger" 15 10
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

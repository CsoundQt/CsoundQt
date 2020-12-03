<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
sr = 44100
nchnls = 2
0dbfs = 1
ksmps = 32

gi_Arr_1[] fillarray 1, 2, 3, 4, 5
gi_Arr_2[] fillarray 5, 4, 3, 2, 1

instr Select
 if p4==1 then
  iArr[] = gi_Arr_1
 else
  iArr[] = gi_Arr_2
 endif
 index = 0
 while index < lenarray(iArr) do
  schedule("Play",index/2,1,iArr[index])
  index += 1
 od
endin

instr Play
 aImp mpulse 1, p3
 iFreq = mtof:i(60 + (p4-1)*2)
 aTone mode aImp,iFreq,100
 out aTone, aTone
endin

</CsInstruments>
<CsScore>
i "Select" 0 4 1
i "Select" + . 2
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

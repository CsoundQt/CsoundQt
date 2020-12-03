<CsoundSynthesizer>
<CsOptions>
-o dac -m128
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
A4 = 457

instr LetPlay

 iMidiKeys[] fillarray 69, 69, 69, 68, 67, 66, 65, 64
 iDurations[] fillarray 2, 1, 1, 1, 1, 1, 1, 4
 iIndex = 0
 iStart = 0
 while iIndex < lenarray(iMidiKeys) do
  schedule "Play", iStart, iDurations[iIndex]*3/2, iMidiKeys[iIndex]
  iStart += iDurations[iIndex]
  iIndex += 1
 od

endin

instr Play

 iMidiKey = p4
 iFreq mtof iMidiKey
 S_name mton iMidiKey
 printf_i "Midi Note = %d, Frequency = %f, Note name = %s\n",
          1, iMidiKey, iFreq, S_name
 aPluck pluck .2, iFreq, iFreq, 0, 1
 aOut linen aPluck, 0, p3, p3/2
 aL, aR pan2 aOut, (iMidiKey-61)/10
 out aL, aR

endin

</CsInstruments>
<CsScore>
i "LetPlay" 0 1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1


instr SimpleTest

 iFac = p4 ;multiplier for each audio sample

 aSinus poscil 0.1, 500

 kIndx = 0
 while kIndx < ksmps do
  aSinus[kIndx] = aSinus[kIndx] * iFac + aSinus[kIndx]
  kIndx += 1
 od

 out aSinus, aSinus

endin

instr PrintSampleIf

 aRnd rnd31 1, 0, 1

 kBlkCnt init 0
 kSmpCnt init 0

 kIndx = 0
 while kIndx < ksmps do
  if aRnd[kIndx] > 0.99 then
   printf "Block = %2d, Sample = %4d, Value = %f\n", 
          kSmpCnt, kBlkCnt, kSmpCnt, aRnd[kIndx]
  endif
  kIndx += 1
  kSmpCnt += 1
 od

 kBlkCnt += 1

endin

instr PlaySampleIf

 aRnd rnd31 1, 0, 1
 aOut init 0

 kBlkCnt init 0
 kSmpCnt init 0

 kIndx = 0
 while kIndx < ksmps do
  if aRnd[kIndx] > 0 && aRnd[kIndx] < 1/10000 then
   aOut[kIndx] = aRnd[kIndx] * 10000
  else
   aOut[kIndx] = 0
  endif
  kIndx += 1
 od

 out aOut, aOut

endin


</CsInstruments>
<CsScore>
i "SimpleTest" 0 1 1
i "SimpleTest" 2 1 3
i "SimpleTest" 4 1 -1
i "PrintSampleIf" 6 .033
i "PlaySampleIf" 8 10
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

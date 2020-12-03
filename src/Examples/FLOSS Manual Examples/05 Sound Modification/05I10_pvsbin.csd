<CsoundSynthesizer>
<CsOptions>
-odac  -m128
</CsOptions>
<CsInstruments>

sr	= 44100
ksmps = 32
nchnls	= 2
0dbfs	= 1

instr SingleBin
 iBin = p4 //bin number
 aSig diskin "fox.wav"
 fSig pvsanal aSig, 1024, 256, 1024, 1
 kAmp, kFreq pvsbin fSig, iBin
 aBin poscil port(kAmp,.01), kFreq
 aBin *= iBin/10
 out aBin, aBin
endin

instr FourBins
 iCount = 1
 while iCount < 5 do
  schedule("SingleBin",0,3,iCount*10)
  iCount += 1
 od
endin

instr SlidingBins
 kBin randomi 1,50,200,3
 aSig diskin "fox.wav"
 fSig pvsanal aSig, 1024, 256, 1024, 1
 kAmp, kFreq pvsbin fSig, int(kBin)
 aBin poscil port(kAmp,.01), kFreq
 aBin *= kBin/10
 out aBin, aBin
endin

</CsInstruments>
<CsScore>
i "SingleBin" 0 3 10
i . + . 20
i . + . 30
i . + . 40
i "FourBins" 13 3
i "SlidingBins" 17 3
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

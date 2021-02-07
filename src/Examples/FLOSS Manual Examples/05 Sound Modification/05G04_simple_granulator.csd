<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

//load sample to table and create half sine envelope
giSample ftgen 0, 0, 0, -1, "fox.wav", 0, 0, 1
giHalfSine ftgen 0, 0, 1024, 9, .5, 1, 0

instr Granulator
 //input parameters as described in text
 iSndTab = giSample ;table with sample
 iSampleLen = ftlen(iSndTab)/sr
 kPointer = linseg:k(0,iSampleLen,iSampleLen)
 iGrainDur = 30 ;milliseconds
 iTranspos = -100 ;cent
 iVolume = -6 ;dB
 iEnv = giHalfSine ;table with envelope
 iPan = .5 ;panning 0-1
 iDensity = 50 ;Hz (grains per second)
 iDistribution = .5 ;0-1
 //perform: call grains over time
 kTrig = metro(iDensity)
 if kTrig==1 then
  kOffset = random:k(0,iDistribution/iDensity)
  schedulek("Grain", kOffset, iGrainDur/1000, iSndTab, iSampleLen,
            kPointer, cent(iTranspos), iVolume, iEnv, iPan)
 endif
endin

instr Grain
 //input parameters
 iSndTab = p4
 iSampleLen = p5
 iStart = p6
 iSpeed = p7
 iVolume = p8 ;dB
 iEnvTab = p9
 iPan = p10
 //perform
 aEnv = poscil3:a(ampdb(iVolume),1/p3,iEnvTab)
 aSound = poscil3:a(aEnv,iSpeed/iSampleLen,iSndTab,iStart/iSampleLen)
 aL, aR pan2 aSound, iPan
 out(aL,aR)
endin

</CsInstruments>
<CsScore>
i "Granulator" 0 3
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

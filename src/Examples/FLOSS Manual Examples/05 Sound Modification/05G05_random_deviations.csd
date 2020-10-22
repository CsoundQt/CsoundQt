<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giSample ftgen 0, 0, 0, -1, "fox.wav", 0, 0, 1
giHalfSine ftgen 0, 0, 1024, 9, .5, 1, 0

instr Granulator
 //standard input parameter
 iSndTab = giSample
 iSampleLen = ftlen(iSndTab)/sr
 iStart = 0 ;sec
 kPointerSpeed = 2/3
 iGrainDur = 30 ;milliseconds
 iTranspos = -100 ;cent
 iVolume = -6 ;dB
 iEnv = giHalfSine ;table with envelope
 iPan = .5 ;panning 0-1
 iDensity = 50 ;Hz (grains per second)
 iDistribution = .5 ;0-1
 //random deviations (for demonstration set to p-fields)
 iPointerRndDev = p4 ;sec
 iGrainDurRndDev = p5 ;percent
 iTransposRndDev = p6 ;cent
 iVolumeRndDev = p7 ;dB
 iPanRndDev = p8 ;as in iPan
 //perform
 kPhasor = phasor:k(kPointerSpeed/iSampleLen,iStart/iSampleLen)
 kTrig = metro(iDensity)
 if kTrig==1 then
  kPointer = kPhasor*iSampleLen + rnd31:k(iPointerRndDev,0)
  kOffset = random:k(0,iDistribution/iDensity)
  kGrainDurDiff = rnd31:k(iGrainDurRndDev,0) ;percent
  kGrainDur = iGrainDur*2^(kGrainDurDiff/100) ;ms
  kTranspos = cent(iTranspos+rnd31:k(iTransposRndDev,0))
  kVol = iVolume+rnd31:k(iVolumeRndDev,0)
  kPan = iPan+rnd31:k(iPanRndDev,0)
  schedulek("Grain",kOffset,kGrainDur/1000,iSndTab,
            iSampleLen,kPointer,kTranspos,kVol,iEnv,kPan)
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
t 0 40
; Random Deviations: Pointer GrainDur Transp Vol Pan
;RANDOM POINTER DEVIATIONS
i "Granulator" 0 2.7   0       0        0      0   0 ;normal pointer
i .            3 .     0.1     0        0      0   0 ;slight trembling
i .            6 .     1       0        0      0   0 ;chaotic jumps
;RANDOM GRAIN DURATION DEVIATIONS
i .           10 .     0       0        0      0   0 ;no deviation
i .           13 .     0     100        0      0   0 ;100%
i .           16 .     0     200        0      0   0 ;200%
;RANDOM TRANSPOSITION DEVIATIONS
i .           20 .     0       0        0      0   0 ;no deviation
i .           23 .     0       0      300      0   0 ;±300 cent maximum
i .           26 .     0       0     1200      0   0 ;±1200 cent maximum
;RANDOM VOLUME DEVIATIONS
i .           30 .     0       0        0      0   0 ;no deviation
i .           33 .     0       0        0      6   0 ;±6 dB maximum
i .           36 .     0       0        0     12   0 ;±12 dB maximum
;RANDOM PAN DEVIATIONS
i .           40 .     0       0        0      0   0 ;no deviation
i .           43 .     0       0        0      0  .1 ;±0.1 maximum
i .           46 .     0       0        0      0  .5 ;±0.5 maximum
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
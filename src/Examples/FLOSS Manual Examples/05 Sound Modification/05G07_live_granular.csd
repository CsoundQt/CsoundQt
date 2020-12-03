<CsoundSynthesizer>
<CsOptions>
-odac -iadc -m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giTable ftgen 0, 0, sr, 2, 0 ;for one second of recording
giHalfSine ftgen 0, 0, 1024, 9, .5, 1, 0
giDelay = 1 ;ms

instr Record
 aIn = inch(1)
 gaWritePointer = phasor(1)
 tablew(aIn,gaWritePointer,giTable,1)
endin
schedule("Record",0,-1)

instr Granulator
 kGrainDur = 30 ;milliseconds
 kTranspos = -300 ;cent
 kDensity = 50 ;Hz (grains per second)
 kDistribution = .5 ;0-1
 kTrig = metro(kDensity)
 if kTrig==1 then
  kPointer = k(gaWritePointer)-giDelay/1000
  kOffset = random:k(0,kDistribution/kDensity)
  schedulek("Grain",kOffset,kGrainDur/1000,kPointer,cent(kTranspos))
 endif
endin
schedule("Granulator",giDelay/1000,-1)

instr Grain
 iStart = p4
 iSpeed = p5
 aOut = poscil3:a(poscil3:a(.3,1/p3,giHalfSine),iSpeed,giTable,iStart)
 out(aOut,aOut)
endin

</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

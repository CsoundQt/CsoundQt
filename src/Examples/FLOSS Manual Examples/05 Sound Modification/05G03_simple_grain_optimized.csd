<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

//load sample to table and create triangular shape
giSample ftgen 0, 0, 0, -1, "fox.wav", 0, 0, 1
giEnv ftgen 0, 0, 8192, 20, 3, 1
giSampleLen = ftlen(giSample)/sr

instr Grain
 //input parameters
 iStart = p4 ;position in sec to read the sound
 iSpeed = p5
 iVolume = -3 ;dB
 iPan = .5 ;0=left, 1=right
 //perform
 aEnv = poscil3:a(ampdb(iVolume),1/p3,giEnv)
 aSound = poscil3:a(aEnv,iSpeed/giSampleLen,giSample,iStart/giSampleLen)
 aL, aR pan2 aSound, iPan
 out(aL,aR)
endin

</CsInstruments>
<CsScore>
;              start speed
i "Grain" 0 .05 .05    1
i .       1 .   .2     .
i .       2 .   .42    .
i .       3 .   .78    .
i .       4 .   1.2    .
i .       6 .   .2     1
i .       7 .   .      2
i .       8 .   .      0.5
i .       9 .   .      10
i .      10 .   .25    -1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

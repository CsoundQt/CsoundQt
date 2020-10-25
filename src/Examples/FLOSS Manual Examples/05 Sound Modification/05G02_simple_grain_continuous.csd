<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr Grain
 //input parameters
 Sound = "fox.wav"
 iStart = p4 ;position in sec to read the sound
 iSpeed = 1
 iVolume = -3 ;dB
 iPan = .5 ;0=left, 1=right
 //perform
 aSound = diskin:a(Sound,iSpeed,iStart,1)
 aOut = linen:a(aSound,p3/2,p3,p3/2)
 aL, aR pan2 aOut*ampdb(iVolume), iPan
 out(aL,aR)
 //call next grain until sound file has reached its end
 if iStart < filelen(Sound) then
  schedule("Grain",p3,p3,iStart+p3)
 endif
endin
schedule("Grain",0,50/1000,0)

</CsInstruments>
<CsScore>
e 5 ;stops performance after 5 seconds
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs  = 1

gifil ftgen 0, 0, 0, 1, "fox.wav", 0, 0, 1

instr FFT_HighPass
 ifftsize = 2048 ;fft size set to pvstanal default
 fsrc pvstanal 1, 1, 1, gifil ;create fsig stream from function table
 kArr[] init ifftsize+2 ;create array for bin data
 kflag pvs2array kArr, fsrc ;export data to array

 ;if kflag has reported a new write action ...
 if changed(kflag) == 1 then
  ; ... set amplitude of first 40 bins to zero:
  kndx = 0
  while kndx <= 80 do
   kArr[kndx] = 0
   kndx += 2 ;change only even array index = bin amplitude
  od
 endif

 fres pvsfromarray kArr ;read modified data back to fres
 aout pvsynth fres ;and resynth
 out aout, aout

endin
</CsInstruments>
<CsScore>
i "FFT_HighPass" 0 2.7
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs  = 1

gifil    ftgen     0, 0, 0, 1, "fox.wav", 0, 0, 1

instr 1
ifftsize =         2048 ;fft size set to pvstanal default
fsrc     pvstanal  1, 1, 1, gifil ;create fsig stream from function table
kArr[]   init      ifftsize+2 ;create array for bin data
kflag    pvs2array kArr, fsrc ;export data to array	

;if kflag has reported a new write action ...
knewflag changed   kflag
if knewflag == 1 then
 ; ... set amplitude of first 40 bins to zero:
kndx     =         0 ;even array index = bin amplitude
kstep    =         2 ;change only even indices
kmax     =         80
loop:
kArr[kndx] =       0
         loop_le   kndx, kstep, kmax, loop
endif

fres     pvsfromarray kArr ;read modified data back to fres
aout     pvsynth   fres	;and resynth
         outs      aout, aout

endin
</CsInstruments>
<CsScore>
i 1 0 2.7
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

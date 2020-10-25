<CsoundSynthesizer>
<CsOptions>
-o dac  --env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

opcode FileToPvsBuf, iik, kSooop
 ;writes an audio file to a fft-buffer if trigger is 1
 kTrig, Sfile, iFFTsize, iOverlap, iWinsize, iWinshape xin
  ;default values
 iFFTsize = (iFFTsize == 0) ? 1024 : iFFTsize
 iOverlap = (iOverlap == 0) ? 256 : iOverlap
 iWinsize = (iWinsize == 0) ? iFFTsize : iWinsize
  ;fill buffer
 if kTrig == 1 then
  ilen  filelen Sfile
  kNumCycles    = ilen * kr
  kcycle        init        0
  while kcycle < kNumCycles do
   ain soundin Sfile
   fftin pvsanal ain, iFFTsize, iOverlap, iWinsize, iWinshape
   ibuf, ktim pvsbuffer fftin, ilen + (iFFTsize / sr)
   kcycle += 1
  od
 endif
 xout ibuf, ilen, ktim
endop

instr simple_time_stretch
 gibuffer, gilen, k0 FileToPvsBuf timeinstk(), "fox.wav"
 ktmpnt linseg 1.6, p3, gilen
 fread pvsbufread ktmpnt, gibuffer
 aout pvsynth fread
 out aout, aout
endin

instr tremor_time_stretch
 ktmpnt = linseg:k(0,p3,gilen) + randi:k(1/5,10)
 fread pvsbufread ktmpnt, gibuffer
 aout pvsynth fread
 out aout, aout
endin

</CsInstruments>
<CsScore>
i 1 0 10
i 2 11 20
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
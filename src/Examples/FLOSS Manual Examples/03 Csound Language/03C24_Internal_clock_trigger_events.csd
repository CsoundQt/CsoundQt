<CsoundSynthesizer>
<CsOptions>
-odac -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

instr TimeLoop
 kTime init 0
 if kTime <= 0 then
  event "i", "Play", 0, random:k(1,5)
  kTime random .3, 1.5
 endif
 kTime -= 1/kr
endin

instr Play
ifreq1    random    600, 1000; starting frequency
idiff     random    100, 300; difference to final frequency
ifreq2    =         ifreq1 - idiff; final frequency
kFreq     expseg    ifreq1, p3, ifreq2; glissando
iMaxdb    random    -18, -6; peak randomly between -12 and 0 dB
kAmp      transeg   ampdb(iMaxdb), p3, -10, 0; envelope
aTone     poscil    kAmp, kFreq
          out       aTone, aTone
endin

</CsInstruments>
<CsScore>
i "TimeLoop" 0 30
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

instr Play
ifreq1    random    600, 1000; starting frequency
idiff     random    100, 300; difference to final frequency
ifreq2    =         ifreq1 - idiff; final frequency
kFreq     expseg    ifreq1, p3, ifreq2; glissando
iMaxdb    random    -18, -6; peak randomly between -12 and 0 dB
kAmp      transeg   ampdb(iMaxdb), p3, -10, 0; envelope
aTone     poscil    kAmp, kFreq
          out       aTone, aTone
if p4 > 0 then
 schedule("Play",random:i(.3,1.5),random:i(1,5), p4-1)
endif
endin

</CsInstruments>
<CsScore>
i "Play" 0 3 20
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

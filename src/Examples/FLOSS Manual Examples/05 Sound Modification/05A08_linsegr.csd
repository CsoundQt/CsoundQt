<CsoundSynthesizer>
<CsOptions>
-odac -+rtmidi=virtual -M0
; activate real time audio and MIDI (virtual midi device)
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

  instr 1
icps     cpsmidi
;                 attack-|sustain-|-release
aEnv     linsegr  0, 0.01,  0.1,    0.5,0; envelope that senses note releases
aSig     poscil   aEnv, icps             ; audio oscillator
         out      aSig, aSig             ; audio sent to output
  endin

</CsInstruments>
<CsScore>
e 240 ; csound performance for 4 minutes
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy
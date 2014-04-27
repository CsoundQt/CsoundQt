<CsoundSynthesizer>

<CsOptions>
--env:SSDIR+=../SourceMaterials -odac -+rtmidi=virtual -M0
; activate real time audio and MIDI (virtual midi device)
</CsOptions>

<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giSine   ftgen    0, 0, 2^12, 10, 1        ; a sine wave

  instr 1
icps     cpsmidi
;                 attack-|sustain-|-release
aEnv     linsegr  0, 0.01,  0.1,     0.5,0 ; envelope that senses note releases
aSig     poscil   aEnv, icps, giSine       ; audio oscillator
         out      aSig                     ; audio sent to output
  endin

</CsInstruments>

<CsScore>
f 0 240 ; csound performance for 4 minutes
e
</CsScore>

</CsoundSynthesizer>

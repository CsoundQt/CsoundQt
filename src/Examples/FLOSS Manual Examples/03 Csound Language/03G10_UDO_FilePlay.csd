<CsoundSynthesizer>
<CsOptions>
-odac --env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

  opcode FilePlay, a, SKoo
;gives mono output (if file is stereo, just the first channel is used)
Sfil, kspeed, iskip, iloop xin
 if filenchnls(Sfil) == 1 then
aout      diskin   Sfil, kspeed, iskip, iloop
 else
aout, a0  diskin   Sfil, kspeed, iskip, iloop
 endif
          xout      aout
  endop

  opcode FilePlay, aa, SKoo
;gives stereo output (if file is mono, the channel is duplicated)
Sfil, kspeed, iskip, iloop xin
ichn      filenchnls Sfil
 if filenchnls(Sfil) == 1 then
aL        diskin    Sfil, kspeed, iskip, iloop
aR        =          aL
 else
aL, aR      diskin    Sfil, kspeed, iskip, iloop
 endif
          xout       aL, aR
  endop

  instr 1
aMono     FilePlay  "fox.wav", 1
          outs       aMono, aMono
  endin

  instr 2
aL, aR    FilePlay  "fox.wav", 1
          outs       aL, aR
  endin

</CsInstruments>
<CsScore>
i 1 0 4
i 2 4 4
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

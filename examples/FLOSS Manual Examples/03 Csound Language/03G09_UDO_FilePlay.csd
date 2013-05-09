<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
;Example by Joachim Heintz
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

  opcode FilePlay1, a, Skoooooo
;gives mono output regardless your soundfile is mono or stereo
;(if stereo, just the first channel is used)
;see diskin2 page of the csound manual for information about the input arguments
Sfil, kspeed, iskip, iloop, iformat, iwsize, ibufsize, iskipinit xin
ichn      filenchnls Sfil
 if ichn == 1 then
aout      diskin2   Sfil, kspeed, iskip, iloop, iformat, iwsize,\
                    ibufsize, iskipinit
 else
aout, a0  diskin2   Sfil, kspeed, iskip, iloop, iformat, iwsize,\
                    ibufsize, iskipinit
 endif
          xout      aout
  endop

  opcode FilePlay2, aa, Skoooooo
;gives stereo output regardless your soundfile is mono or stereo
;see diskin2 page of the csound manual for information about the input arguments
Sfil, kspeed, iskip, iloop, iformat, iwsize, ibufsize, iskipinit xin
ichn      filenchnls Sfil
 if ichn == 1 then
aL        diskin2    Sfil, kspeed, iskip, iloop, iformat, iwsize,\
                     ibufsize, iskipinit
aR        =          aL
 else
aL, aR	    diskin2    Sfil, kspeed, iskip, iloop, iformat, iwsize,\
                      ibufsize, iskipinit
 endif
          xout       aL, aR
  endop

  instr 1
aMono     FilePlay1  "fox.wav", 1
          outs       aMono, aMono
  endin

  instr 2
aL, aR    FilePlay2  "fox.wav", 1
          outs       aL, aR
  endin

</CsInstruments>
<CsScore>
i 1 0 4
i 2 4 4
</CsScore>
</CsoundSynthesizer>

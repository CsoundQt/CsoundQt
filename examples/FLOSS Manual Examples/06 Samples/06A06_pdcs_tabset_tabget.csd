<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 8
nchnls = 1
0dbfs = 1

giCopy ftgen 1, 0, -88200, 2, 0 ;"empty" table
giFox  ftgen 2, 0, 0, 1, "fox.wav", 0, 0, 1

  opcode BufPlay1, a, ipop
ifn, ispeed, iskip, ivol xin
icps      =         ispeed / (ftlen(ifn) / sr)
iphs      =         iskip / (ftlen(ifn) / sr)
asig      poscil3   ivol, icps, ifn, iphs
          xout      asig
  endop

  instr 1
itable    =         p4
aout      BufPlay1  itable
          out       aout
  endin

</CsInstruments>
<CsScore>
f 0 99999
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

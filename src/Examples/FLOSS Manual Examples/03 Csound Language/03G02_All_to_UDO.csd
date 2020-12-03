<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giSine    ftgen     0, 0, 2^10, 10, 1
          seed      0

  opcode FiltFb, 0, 0
aDel init 0; initialize delay signal
iFb = .7; feedback multiplier
aSnd rand .2; white noise
kdB randomi -18, -6, .4; random movement between -18 and -6
aSnd = aSnd * ampdb(kdB); applied as dB to noise
kFiltFq randomi 100, 1000, 1; random movement between 100 and 1000
aFilt reson aSnd, kFiltFq, kFiltFq/5; applied as filter center frequency
aFilt balance aFilt, aSnd; bring aFilt to the volume of aSnd
aDelTm randomi .1, .8, .2; random movement between .1 and .8 as delay time
aDel vdelayx aFilt + iFb*aDel, aDelTm, 1, 128; variable delay
kdbFilt randomi -12, 0, 1; two random movements between -12 and 0 (dB) ...
kdbDel randomi -12, 0, 1; ... for the filtered and the delayed signal
aOut = aFilt*ampdb(kdbFilt) + aDel*ampdb(kdbDel); mix it
out aOut, aOut
  endop

instr 1
          FiltFb
endin

</CsInstruments>
<CsScore>
i 1 0 60
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

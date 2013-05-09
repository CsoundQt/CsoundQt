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

          seed      0
giTone    ftgen     0, 0, 2^10, 10, 1, .5, .3, .1

  instr 1
kGate     randomi   0, 1, 3; moves between 0 and 1 (3 new values per second)
kFreq     randomi   300, 800, 1; moves between 300 and 800 hz
                               ;(1 new value per sec)
kdB       randomi   -12, 0, 5; moves between -12 and 0 dB
                             ;(5 new values per sec)
aSig      oscil3    1, kFreq, giTone
kVol      init      0
kVol      =         (kGate > 0.5 ? ampdb(kdB) : 0); short form of condition
kVol      port      kVol, .02; smooth volume curve to avoid clicks
aOut      =         aSig * kVol
          outs      aOut, aOut
  endin

</CsInstruments>
<CsScore>
i 1 0 20
</CsScore>
</CsoundSynthesizer>

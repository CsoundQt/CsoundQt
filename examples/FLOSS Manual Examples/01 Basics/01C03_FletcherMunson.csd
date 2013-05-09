<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giSine    ftgen     0, 0, 2^10, 10, 1 ;table with a sine wave

instr 1
kfreq     expseg    p4, p3, p5
          printk    1, kfreq ;prints the frequencies once a second
asin      poscil    .2, kfreq, giSine
aout      linen     asin, .01, p3, .01
          outs      aout, aout
endin
</CsInstruments>
<CsScore>
i 1 0 5 1000 1000
i 1 6 20 20  20000
</CsScore>
</CsoundSynthesizer>

<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr=44100
kr=4410
ksmps=10
nchnls=2
0dbfs=1

instr 1
andx phasor 440
a1 table andx*8192, 1
outs a1*.2, a1*.2
endin
</code><code><code><code><code></CsInstruments></code></code>
<CsScore></code>

f1 0 8192 10 1
i 1 0 4
</CsScore>
</CsoundSynthesizer>

</code>
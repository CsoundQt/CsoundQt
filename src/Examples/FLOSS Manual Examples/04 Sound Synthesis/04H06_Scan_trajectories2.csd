<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -o dac
</CsOptions>
<CsInstruments>
sr=44100
kr=4410
ksmps=10
nchnls=2 ; STEREO
0dbfs=1
instr 1
andx phasor 440
andx table andx*8192, 1  ; read the table out of order!
a1   table andx*8192, 1
outs a1*.2, a1*.2
endin
</CsInstruments>
<CsScore>

f1 0 8192 10 1
f2 0 8192 -5 .001 8192 1;
i 1 0 4
</CsScore>
</CsoundSynthesizer>
;Example by Christopher Saunders

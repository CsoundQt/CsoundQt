<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -o Render.wav
</CsOptions>
<CsInstruments>
;Example by Alex Hofmann
instr 1
aSin      poscil    0dbfs/4, 440
          out       aSin
endin
</CsInstruments>
<CsScore>
i 1 0 1
e
</CsScore>
</CsoundSynthesizer>
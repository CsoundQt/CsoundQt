<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
nchnls = 2
sr = 44100
ksmps = 32
0dbfs = 1

gipos ftgen 1, 0, 128, 10, 1 ;position of the masses (initially: sine)
gimass ftgen 2, 0, 128, -7, 1, 128, 1 ;masses: constant value 1
gistiff ftgen 3, 0, 128, -7, 0, 64, 100, 64, 0 ;stiffness; triangle 0->100->0
gidamp ftgen 4, 0, 128, -7, 1, 128, 1 ;damping; constant value 1
givel ftgen 5, 0, 128, -2, 0 ;velocity; initially 0

instr 1
 iamp = .2
 ifrq = 440
 a0 scantable 0, 0, gipos, gimass, gistiff, gidamp, givel
 aScan poscil iamp, ifrq, gipos
 aOut linen aScan, 1, p3, 1
 out aOut, aOut
endin

</CsInstruments>
<CsScore>
i 1 0 19
</CsScore>
</CsoundSynthesizer>
;example by Christopher Saunders and joachim heintz

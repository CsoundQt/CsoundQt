<CsoundSynthesizer>

<CsOptions>
--env:SSDIR+=../SourceMaterials -dm0 -odac
</CsOptions>

<CsInstruments>

sr = 44100
ksmps =32
nchnls = 1
0dbfs =    1

giSine    ftgen    1,0,1025,10,1
giTanh    ftgen   2,0,257,"tanh",-10,10,0

instr 1
 kAmt  line     0, p3, 1                 ; rising distortion amount
 aSig  poscil   1, 200, giSine           ; a sine
 aSig2 poscil   kAmt*0.8,400,giSine      ; a sine an octave above
 aDst  distort  aSig+aSig2, kAmt, giTanh ; distort a mixture of the two sines
       out      aDst*0.1
endin

</CsInstruments>

<CsScore>
i 1 0 4
</CsScore>
</CsoundSynthesizer>
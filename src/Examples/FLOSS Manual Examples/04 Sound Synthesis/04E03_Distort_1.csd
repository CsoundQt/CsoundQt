<CsoundSynthesizer>
<CsOptions>
-dm0 -odac
</CsOptions>

<CsInstruments>

sr = 44100
ksmps =32
nchnls = 1
0dbfs = 1

giSine  ftgen   1,0,1025,10,1           ; sine function
giTanh  ftgen   2,0,257,"tanh",-10,10,0 ; tanh function

instr 1
 aSig  poscil   1, 200, giSine          ; a sine wave
 kAmt  line     0, p3, 1                ; rising distortion amount
 aDst  distort  aSig, kAmt, giTanh      ; distort the sine tone
       out      aDst*0.1
endin

</CsInstruments>
<CsScore>
i 1 0 4
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy
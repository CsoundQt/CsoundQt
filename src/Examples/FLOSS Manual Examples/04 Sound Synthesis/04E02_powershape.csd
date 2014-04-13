<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -odac -dm0
</CsOptions>
<CsInstruments>
sr     = 44100
ksmps  = 1
0dbfs  = 1
nchnls = 1

 instr  1
koct   rspline    5,8,0.1,1      ; random pitch
aSig   poscil     1,cpsoct(koct) ; create a sine wave
kshape rspline    1,500,0.3,3    ; random shape amount
aSig   powershape aSig,kshape    ; 'powershape' distort the sine wave
       out        aSig
 endin

</CsInstruments>

<CsScore>
i 1 0 120
e
</CsScore>
</CsoundSynthesizer>

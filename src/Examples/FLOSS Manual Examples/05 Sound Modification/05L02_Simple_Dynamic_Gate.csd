<CsoundSynthesizer>

<CsOptions>  
--env:SSDIR+=../SourceMaterials -dm0 -odac
</CsOptions>

<CsInstruments>

ksmps = 32
0dbfs = 1 
; this is a necessary definition,
;         otherwise amplitude will be -32768 to 32767

instr    1
 aSig    diskin  "fox.wav", 1        ; read sound file
 kRms    rms     aSig                ; scan rms
 iThreshold =    0.1                 ; rms threshold
 kGate   =       kRms > iThreshold ? 1 : 0  ; gate either 1 or zero
 aGate   interp  kGate   ; interpolate to create smoother on->off->on switching
 aSig    =       aSig * aGate        ; multiply signal by gate
         out     aSig                ; send to output
endin

</CsInstruments>

<CsScore>
i 1 0 10
</CsScore>

</CsoundSynthesizer>

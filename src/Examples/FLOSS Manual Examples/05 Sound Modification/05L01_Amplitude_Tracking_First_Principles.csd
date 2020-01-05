<CsoundSynthesizer>

<CsOptions>
--env:SSDIR+=../SourceMaterials -dm0 -odac
</CsOptions>

<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 1
0dbfs = 1

; a rich waveform
giwave ftgen 1,0, 512, 10, 1,1/2,1/3,1/4,1/5

instr   1
 ; create an audio signal
 aenv    linseg     0,p3/2,1,p3/2,0  ; triangle shaped envelope
 aSig    poscil     aenv,300,giwave  ; audio oscillator
         out        aSig             ; send audio to output

 ; track amplitude
 kArr[]   init  500 / ksmps     ; initialise an array
 kNdx     init  0               ; initialise index for writing to array
 kSig     downsamp        aSig  ; create k-rate version of audio signal
 kSq      =     kSig ^ 2        ; square it (negatives become positive)
 kRoot    =     kSq ^ 0.5       ; square root it (restore absolute values)
 kArr[kNdx] =   kRoot           ; write result to array
 kMean      =   sumarray(kArr) / lenarray(kArr) ; calculate mean of array
                printk  0.1,kMean   ; print mean to console
; increment index and wrap-around if end of the array is met
 kNdx           wrap    kNdx+1, 0, lenarray(kArr)
endin

</CsInstruments>

<CsScore>
i 1 0 5
</CsScore>

</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>

<CsoundSynthesizer>

<CsOptions>
--env:SSDIR+=../SourceMaterials -odac
</CsOptions>

<CsInstruments>

0dbfs = 1

giSine    ftgen  0, 0, 2^10, 10, 1
; hanning window
giWindow  ftgen  0, 0, 1024, -19, 1, 0.5, 270, 0.5
; a complex pseudo inharmonic waveform (partials scaled up X 100)
giWave    ftgen  0, 0, 262144, 9, 100,1.000,0, 278,0.500,0, 518,0.250,0, \ 816,0.125,0, 1166,0.062,0, 1564,0.031,0, 1910,0.016,0

  instr 1 ; demonstration of hsboscil
kAmp     =        0.3
kTone    rspline  -1,1,0.05,0.2 ; randomly shift spectrum up and down
kBrite   rspline  -1,3,0.4,2    ; randomly shift masking window up and down
iBasFreq =        200           ; base frequency
iOctCnt  =        3             ; width of masking window
aSig     hsboscil kAmp, kTone, kBrite, iBasFreq, giSine, giWindow, iOctCnt
         out      aSig
  endin

  instr 2 ; frequency shifting added
kAmp     =        0.3
kTone    =        0          ; spectrum remains static this time
kBrite   rspline  -2,5,0.4,2 ; randomly shift masking window up and down
iBasFreq =        75         ; base frequency
iOctCnt  =        6          ; width of masking window
aSig     hsboscil kAmp, kTone, kBrite, iBasFreq, giSine, giWindow, iOctCnt
 ; frequency shift the sound
kfshift   =       -357       ; amount to shift the frequency
areal,aimag hilbert aSig     ; hilbert filtering
asin     poscil   1, kfshift, giSine, 0    ; modulating signals
acos     poscil   1, kfshift, giSine, 0.25	
aSig	=         (areal*acos) - (aimag*asin)  ; frequency shifted signal
        out       aSig
  endin

  instr 3 ; hsboscil using a complex waveform
kAmp     =        0.3
kTone    rspline  -1,1,0.05,0.2 ; randomly shift spectrum up and down
kBrite   rspline  -3,3,0.1,1    ; randomly shift masking window
iBasFreq =        200
aSig     hsboscil kAmp, kTone, kBrite, iBasFreq/100, giWave, giWindow
aSig2    hsboscil kAmp,kTone, kBrite, (iBasFreq*1.001)/100, giWave, giWindow
       out        aSig+aSig2 ; mix signal with 'detuned' version
  endin

</CsInstruments>

<CsScore>
i 1 0  14
i 2 15 14
i 3 30 14
e
</CsScore>

</CsoundSynthesizer>
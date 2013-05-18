<CsoundSynthesizer>

<CsOptions>
-odac ; activates real time sound output
</CsOptions>

<CsInstruments>
; Example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

  instr 1
        prints       "reson%n"          ; indicate filter type in console
aSig    vco2         0.5, 150           ; input signal: sawtooth waveform
kcf     expon        20,p3,10000        ; rising cutoff frequency
aSig    reson        aSig,kcf,kcf*0.1,1 ; filter audio signal
        out          aSig               ; send filtered audio to output
  endin

  instr 2
        prints       "butbp%n"          ; indicate filter type in console
aSig    vco2         0.5, 150           ; input signal: sawtooth waveform
kcf     expon        20,p3,10000        ; rising cutoff frequency
aSig    butbp        aSig, kcf, kcf*0.1 ; filter audio signal
        out          aSig               ; send filtered audio to output
  endin

  instr 3
        prints       "reson%n"          ; indicate filter type in console
aSig    pinkish      0.5                ; input signal: pink noise
kbw     expon        10000,p3,8         ; contracting bandwidth
aSig    reson        aSig, 5000, kbw, 2 ; filter audio signal
        out          aSig               ; send filtered audio to output
  endin

  instr 4
        prints       "butbp%n"          ; indicate filter type in console
aSig    pinkish      0.5                ; input signal: pink noise
kbw     expon        10000,p3,8         ; contracting bandwidth
aSig    butbp        aSig, 5000, kbw    ; filter audio signal
        out          aSig               ; send filtered audio to output
  endin

</CsInstruments>

<CsScore>
i 1 0  3 ; reson - cutoff frequency rising
i 2 4  3 ; butbp - cutoff frequency rising
i 3 8  6 ; reson - bandwidth increasing
i 4 15 6 ; butbp - bandwidth increasing
e
</CsScore>

</CsoundSynthesizer>

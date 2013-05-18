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
        prints       "atone%n"     ; indicate filter type in console
aSig    vco2         0.2, 150      ; input signal is a sawtooth waveform
kcf     expon        20, p3, 20000 ; define envelope for cutoff frequency
aSig    atone        aSig, kcf     ; filter audio signal
        out          aSig          ; filtered audio sent to output
  endin

  instr 2
        prints       "buthp%n"     ; indicate filter type in console
aSig    vco2         0.2, 150      ; input signal is a sawtooth waveform
kcf     expon        20, p3, 20000 ; define envelope for cutoff frequency
aSig    buthp        aSig, kcf     ; filter audio signal
        out          aSig          ; filtered audio sent to output
  endin

  instr 3
        prints       "bqrez(mode:1)%n" ; indicate filter type in console
aSig    vco2         0.03, 150         ; input signal is a sawtooth waveform
kcf     expon        20, p3, 20000     ; define envelope for cutoff frequency
aSig    bqrez        aSig, kcf, 30, 1  ; filter audio signal
        out          aSig              ; filtered audio sent to output
  endin

</CsInstruments>

<CsScore>
; 3 notes to demonstrate each filter in turn
i 1 0  3 ; atone
i 2 5  3 ; buthp
i 3 10 3 ; bqrez(mode 1)
e
</CsScore>

</CsoundSynthesizer>

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
        prints       "tone%n"    ; indicate filter type in console
aSig    vco2         0.5, 150    ; input signal is a sawtooth waveform
kcf     expon        10000,p3,20 ; descending cutoff frequency
aSig    tone         aSig, kcf   ; filter audio signal
        out          aSig        ; filtered audio sent to output
  endin

  instr 2
        prints       "butlp%n"   ; indicate filter type in console
aSig    vco2         0.5, 150    ; input signal is a sawtooth waveform
kcf     expon        10000,p3,20 ; descending cutoff frequency
aSig    butlp        aSig, kcf   ; filter audio signal
        out          aSig        ; filtered audio sent to output
  endin

  instr 3
        prints       "moogladder%n" ; indicate filter type in console
aSig    vco2         0.5, 150       ; input signal is a sawtooth waveform
kcf     expon        10000,p3,20    ; descending cutoff frequency
aSig    moogladder   aSig, kcf, 0.9 ; filter audio signal
        out          aSig           ; filtered audio sent to output
  endin

</CsInstruments>

<CsScore>
; 3 notes to demonstrate each filter in turn
i 1 0  3; tone
i 2 4  3; butlp
i 3 8  3; moogladder
e
</CsScore>

</CsoundSynthesizer>

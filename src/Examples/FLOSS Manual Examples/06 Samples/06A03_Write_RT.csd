<CsoundSynthesizer>
<CsOptions>
-odac ; activate real-time audio output
</CsOptions>
<CsInstruments>
sr      =       44100
ksmps   =       32
nchnls  =       1
0dbfs   =       1

gaSig   init   0; set initial value for global audio variable (silence)

  instr 1 ; a simple tone generator
aEnv    expon    0.2, p3, 0.001              ; percussive amplitude envelope
aSig    poscil   aEnv, cpsmidinn(p4)         ; audio oscillator
        out      aSig
  endin

  instr 2 ; write to a file (always on in order to record everything)
aSig    monitor                              ; read audio from output bus
        fout "WriteToDisk2.wav",4,aSig   ; write audio to file (16bit mono)
  endin

</CsInstruments>
<CsScore>
; activate recording instrument to encapsulate the entire performance
i 2 0 8.3

; two chords
i 1   0 5 60
i 1 0.1 5 65
i 1 0.2 5 67
i 1 0.3 5 71

i 1   3 5 65
i 1 3.1 5 67
i 1 3.2 5 73
i 1 3.3 5 78
</CsScore>
</CsoundSynthesizer>
;example written by Iain McCurdy

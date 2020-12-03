<CsoundSynthesizer>     ; START OF CSOUND FILE

<CsOptions>             ; START OF CSOUND CONFIGURATION
 -odac ; realtime audio output
</CsOptions>            ; END OF CSOUND CONFIGURATION

<CsInstruments>         ; START OF INSTRUMENT DEFINITIONS

sr = 44100 ; set audio sample rate to 44100 Hz
ksmps = 64 ; set audio vector size to 64 samples
nchnls = 2 ; set number of channels to 2 (stereo)
0dbfs = 1  ; set zero dB full scale as 1

instr 1 ; play a 440 Hz Sine Wave
 aSin  poscil  0dbfs/4, 440
       out  aSin
endin

</CsInstruments>        ; END OF INSTRUMENT DEFINITIONS

<CsScore>               ; START OF SCORE EVENTS
i 1 0 1 ; start instrument 1 at time 0 for 1 second
</CsScore>

</CsoundSynthesizer>    ; END OF THE CSOUND FILE

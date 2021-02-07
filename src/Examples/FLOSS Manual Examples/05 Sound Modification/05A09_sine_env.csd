<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giEnv    ftgen    0, 0, 2^12, 9, 0.5, 1, 0 ; envelope shape: a half sine

  instr 1
; read the envelope once during the note's duration:
aEnv     poscil   .5, 1/p3, giEnv
aSig     poscil   aEnv, 500                ; audio oscillator
         out      aSig, aSig               ; audio sent to output
  endin

</CsInstruments>
<CsScore>
; 7 notes, increasingly short
i 1 0 2
i 1 2 1
i 1 3 0.5
i 1 4 0.25
i 1 5 0.125
i 1 6 0.0625
i 1 7 0.03125
e 7.1
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy

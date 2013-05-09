<CsoundSynthesizer>

<CsOptions>
; amend device number accordingly
-Q999
</CsOptions>

<CsInstruments>
; Example by Iain McCurdy

ksmps = 32 ;no audio so sr and nchnls omitted

seed 0; random number generators seeded by system clock

  instr 1
; read value in from p-field
kchn    =         p4
knum    random    48,72.99  ; note numbers chosen randomly across a 2 octaves
kvel    random    40, 115   ; velocities are chosen randomly
kdur    random    0.2, 1    ; note durations chosen randomly from 0.2 to 1
kpause  random    0, 0.4    ; pauses betw. notes chosen randomly from 0 to 0.4
        moscil    kchn, knum, kvel, kdur, kpause ; send a stream of midi notes
  endin

</CsInstruments>

<CsScore>
;p1 p2 p3 p4
i 1 0  20 1
f 0 21 ; extending performance time prevents final note-off from being lost
</CsScore>

</CsoundSynthesizer>

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
kfreq line 300, abs(p3), 1000
aout oscil 0.2, kfreq, 1
outs aout, aout
endin

instr 2 ; Same as above but with envelope
kfreq line 300, abs(p3), 1000
kenv linenr 0.2, 1, 1, 0.01
aout oscil kenv, kfreq, 1
outs aout, aout
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1

i 1 0 -30  ; Turn on held note

i -1 ^+1 1  ;Turn it off

i 1.1 ^+1 -20  ;Turn on note 1.1
i 1.2 ^+2 -20  ;Turn on note 1.2

i -1.2 ^+0.5 1  ;Turn off 1.2
i -1.1 ^+1 1  ;Turn off 1.1

i 2 ^+1 -20  ;Turn on instr 2
i -2 ^+3 1  ;Turn off instr 2

; For information on Score processing (e.g the ^character
; stand on the i character and press Shift+F1
; or stand on the i and go to Help->Show Opcode Entry
e
</CsScore>
</CsoundSynthesizer>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" name="" x="0" y="0" width="596" height="322"> 








</EventPanel>

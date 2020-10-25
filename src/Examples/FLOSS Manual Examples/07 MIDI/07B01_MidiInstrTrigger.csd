<CsoundSynthesizer>
<CsOptions>
-Ma -odac -m128
;activates all midi devices, real time sound output, suppress note printings
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

gisine ftgen 0,0,2^12,10,1

  instr 1 ; 1 impulse (midi channel 1)
prints "instrument/midi channel: %d%n",p1 ;print instrument number to terminal
reset:                                    ;label 'reset'
     timout 0, 1, impulse                 ;jump to 'impulse' for 1 second
     reinit reset                         ;reninitialise pass from 'reset'
impulse:                                  ;label 'impulse'
aenv expon     1, 0.3, 0.0001             ;a short percussive envelope
aSig poscil    aenv, 500, gisine          ;audio oscillator
     out       aSig                       ;audio to output
  endin

  instr 2 ; 2 impulses (midi channel 2)
prints "instrument/midi channel: %d%n",p1
reset:
     timout 0, 1, impulse
     reinit reset
impulse:
aenv expon     1, 0.3, 0.0001
aSig poscil    aenv, 500, gisine
a2   delay     aSig, 0.15                 ; short delay adds another impulse
     out       aSig+a2                    ; mix two impulses at output
  endin

  instr 3 ; 3 impulses (midi channel 3)
prints "instrument/midi channel: %d%n",p1
reset:
     timout 0, 1, impulse
     reinit reset
impulse:
aenv expon     1, 0.3, 0.0001
aSig poscil    aenv, 500, gisine
a2   delay     aSig, 0.15                 ; delay adds a 2nd impulse
a3   delay     a2, 0.15                   ; delay adds a 3rd impulse
     out       aSig+a2+a3                 ; mix the three impulses at output
  endin

</CsInstruments>
<CsScore>
f 0 300
</CsScore>
<CsoundSynthesizer>
;example by Iain McCurdy
<CsoundSynthesizer>
<CsOptions>
-Ma -odac -m128
; activate all midi devices, real time sound output, suppress note printing
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

gisine ftgen 0,0,2^12,10,1

massign 1,3  ; channel 1 notes directed to instr 3
massign 2,1  ; channel 2 notes directed to instr 1
massign 3,2  ; channel 3 notes directed to instr 2

  instr 1 ; 1 impulse (midi channel 1)
iChn midichn                                  ; discern what midi channel
prints "channel:%d%tinstrument: %d%n",iChn,p1 ; print instr and midi channel
reset:                                        ; label 'reset'
     timout 0, 1, impulse                     ; jump to 'impulse' for 1 second
     reinit reset                             ; reinitialize pass from 'reset'
impulse:                                      ; label 'impulse'
aenv expon     1, 0.3, 0.0001                 ; a short percussive envelope
aSig poscil    aenv, 500, gisine              ; audio oscillator
     out       aSig                           ; send audio to output
  endin

  instr 2 ; 2 impulses (midi channel 2)
iChn midichn
prints "channel:%d%tinstrument: %d%n",iChn,p1
reset:
     timout 0, 1, impulse
     reinit reset
impulse:
aenv expon     1, 0.3, 0.0001
aSig poscil    aenv, 500, gisine
a2   delay     aSig, 0.15                    ; delay generates a 2nd impulse
     out       aSig+a2                       ; mix two impulses at the output
  endin

  instr 3 ; 3 impulses (midi channel 3)
iChn midichn
prints "channel:%d%tinstrument: %d%n",iChn,p1
reset:
     timout 0, 1, impulse
     reinit reset
impulse:
aenv expon     1, 0.3, 0.0001
aSig poscil    aenv, 500, gisine
a2   delay     aSig, 0.15                      ; delay generates a 2nd impulse
a3   delay     a2, 0.15                        ; delay generates a 3rd impulse
     out       aSig+a2+a3                      ; mix three impulses at output
  endin

</CsInstruments>

<CsScore>
f 0 300
</CsScore>
<CsoundSynthesizer>
;example by Iain McCurdy

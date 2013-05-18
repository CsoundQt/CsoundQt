<CsoundSynthesizer>

<CsOptions>
-odac ; activates real time sound output
</CsOptions>

<CsInstruments>
; Example by Iain McCurdy<br>sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giSine   ftgen    0, 0, 2^12, 10, 1 ; a sine wave

  instr 1 ; linseg envelope
aCps     linseg   300, 1, 600       ; linseg holds its last value
aSig     poscil   0.2, aCps, giSine
         out      aSig
  endin

  instr 2 ; line envelope
aCps     line     300, 1, 600       ; line continues its trajectory
aSig     poscil   0.2, aCps, giSine
         out      aSig
  endin

</CsInstruments>

<CsScore>
i 1 0 5 ; linseg envelope
i 2 6 5 ; line envelope
e
</CsScore>

</CsoundSynthesizer> 
<br>

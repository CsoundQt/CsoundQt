see http://booki.flossmanuals.net/csound/

<CsoundSynthesizer>

<CsOptions>
-odac
</CsOptions>

<CsInstruments>
;example written by Iain McCurdy

sr      =       44100
ksmps   =       32
nchnls  =       1	
0dbfs   =       1

giSine  ftgen  0, 0, 4096, 10, 1 ; a sine wave
gaSig   init   0; set initial value for global audio variable (silence)

  instr	1; a simple tone generator
aEnv    expon    0.2, p3, 0.001; percussive amplitude envelope
aSig    poscil   aEnv, cpsmidinn(p4), giSine; audio oscillator
gaSig   =        gaSig + aSig; accumulate this note with the global audio variable
  endin

  instr 2; write to a file (always on)
; USE FOUT TO WRITE TO A FILE ON DISK
; FORMAT 4 RESULTS IN A 16BIT WAV
; NUMBER OF CHANNELS IS DETERMINED BY THE NUMBER OF AUDIO VARIABLES SUPPLIED TO fout
        fout     "WriteToDisk2.wav", 4, gaSig
        out      gaSig; send audio for all notes combined to the output
        clear    gaSig; clear global audio variable to prevent run away accumulation
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
e
</CsScore>

</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>630</x>
 <y>260</y>
 <width>380</width>
 <height>205</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>230</r>
  <g>140</g>
  <b>36</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {59110, 35980, 9252}
</MacGUI>

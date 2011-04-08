see http://www.flossmanuals.net/csound/ch037_g-granular-synthesis

<CsoundSynthesizer>

<CsOptions>
-odevaudio -b1024 -dm0
</CsOptions>

<CsInstruments>
;example by Iain McCurdy

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

;the name of the sound file used is defined as a string variable -
;- as it will be used twice in the code.
;The simplifies the task of adapting the orchestra -
;to use a different sound file
gSfile = "ClassicalGuitar.wav"

;waveform used for granulation
giSound  ftgen 1,0,2097152,1,gSfile,0,0,0

;window function - used as an amplitude envelope for each grain
;(first half of a sine wave)
giWFn   ftgen 2,0,16384,9,0.5,1,0

seed 0; seed the random generators from the system clock
gaSendL init 0
gaSendR init 0

instr 1 ; triggers instrument 2
  ktrigger  metro   0.08         ;metronome of triggers. One every 12.5s
  schedkwhen ktrigger,0,0,2,0,40 ;trigger instr. 2 for 40s
endin

instr 2 ; generates granular synthesis textures
  ;define the input variables
  ifn1        =          giSound
  ilen        =          nsamp(ifn1)/sr
  iPtrStart   random     1,ilen-1
  iPtrTrav    random     -1,1
  ktimewarp   line       iPtrStart,p3,iPtrStart+iPtrTrav
  kamp        linseg     0,p3/2,0.2,p3/2,0
  iresample   random     -24,24.99
  iresample   =          semitone(int(iresample))
  ifn2        =          giWFn
  ibeg        =          0
  iwsize      random     400,10000
  irandw      =          iwsize/3
  ioverlap    =          50
  itimemode   =          1
  ;create a stereo granular synthesis texture using sndwarp
  aSigL,aSigR sndwarpst  kamp,ktimewarp,iresample,ifn1,ibeg,\
                              iwsize,irandw,ioverlap,ifn2,itimemode
  ;envelope the signal with a lowpass filter
  kcf         expseg     50,p3/2,12000,p3/2,50
  aSigL       moogvcf2    aSigL, kcf, 0.5
  aSigR       moogvcf2    aSigR, kcf, 0.5
  ; add a little of out audio signals to the global send variables
  ; these will be sent to the reverb instrument (2)
  gaSendL     =          gaSendL+(aSigL*0.4)
  gaSendR     =          gaSendR+(aSigR*0.4)
              outs       aSigL,aSigR
endin

instr 3 ; global reverb instrument (always on)
  ; use Sean Costello's high quality reverbsc opcode for creating reverb signal
  aRvbL,aRvbR reverbsc   gaSendL,gaSendR,0.85,8000
              outs       aRvbL,aRvbR
  ;clear variables to prevent out of control accumulation
              clear      gaSendL,gaSendR
endin

</CsInstruments>

<CsScore>
; p1 p2 p3
i 1  0  3600 ; triggers instr 2
i 3  0  3600 ; reverb instrument
e
</CsScore>

</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
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
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 72 179 400 200
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView background {59110, 35980, 9252}
</MacGUI>

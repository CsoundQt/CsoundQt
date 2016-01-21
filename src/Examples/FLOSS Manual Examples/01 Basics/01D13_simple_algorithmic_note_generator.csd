<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -odac -dm0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giNotes	ftgen	0,0,-100,-17,0,48, 15,53, 30,55, 40,60, 50,63, 60,65, 79,67, 85,70, 90,72, 96,75
giDurs	ftgen	0,0,-100,-17,0,2, 30,0.5, 75,1, 90,1.5

  instr 1
kDur  init        0.5             ; initial rhythmic duration
kTrig metro       2/kDur          ; metronome freq. 2 times inverse of duration
kNdx  trandom     kTrig,0,1       ; create a random index upon each metro 'click'
kDur  table       kNdx,giDurs,1   ; read a note duration value
      schedkwhen  kTrig,0,0,2,0,1 ; trigger a note!
  endin

  instr 2
iNote table     rnd(1),giNotes,1                 ; read a random value from the function table
aEnv  linsegr	0, 0.005, 1, p3-0.105, 1, 0.1, 0 ; amplitude envelope
iPlk  random	0.1, 0.3                         ; point at which to pluck the string
iDtn  random    -0.05, 0.05                      ; random detune
aSig  wgpluck2  0.98, 0.2, cpsmidinn(iNote+iDtn), iPlk, 0.06
      out       aSig * aEnv
  endin
</CsInstruments>

<CsScore>
i 1 0    300  ; start 3 long notes close after one another
i 1 0.01 300
i 1 0.02 300
e
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy

see http://en.flossmanuals.net/bin/view/Csound/READINGMIDIFILES

<CsoundSynthesizer>
<CsOptions>
;'-F' flag reads in a midi file
-F AnyMIDIfile.mid
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

sr = 44100
ksmps = 32
nchnls = 2

giEngine     fluidEngine; start fluidsynth engine
iSfNum1      fluidLoad          "ASoundfont.sf2", giEngine, 1; load a soundfont
iSfNum2      fluidLoad          "ADifferentSoundfont.sf2", giEngine, 1; load a different soundfont
             fluidProgramSelect giEngine, 1, iSfNum1, 0, 0; direct each midi channel to a particular soundfont
             fluidProgramSelect giEngine, 3, iSfNum1, 0, 0
             fluidProgramSelect giEngine, 5, iSfNum1, 0, 0
             fluidProgramSelect giEngine, 7, iSfNum1, 0, 0
             fluidProgramSelect giEngine, 9, iSfNum1, 0, 0
             fluidProgramSelect giEngine, 11, iSfNum1, 0, 0
             fluidProgramSelect giEngine, 13, iSfNum1, 0, 0
             fluidProgramSelect giEngine, 15, iSfNum1, 0, 0
             fluidProgramSelect giEngine, 2, iSfNum2, 0, 0
             fluidProgramSelect giEngine, 4, iSfNum2, 0, 0
             fluidProgramSelect giEngine, 6, iSfNum2, 0, 0
             fluidProgramSelect giEngine, 8, iSfNum2, 0, 0
             fluidProgramSelect giEngine, 10, iSfNum2, 0, 0
             fluidProgramSelect giEngine, 12, iSfNum2, 0, 0
             fluidProgramSelect giEngine, 14, iSfNum2, 0, 0
             fluidProgramSelect giEngine, 16, iSfNum2, 0, 0

  instr 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 ;fluid synths for midi channels 1-16
iKey         notnum; read in midi note number
iVel         ampmidi            127; read in key velocity
             fluidNote          giEngine, p1, iKey, iVel; apply note to relevant soundfont
  endin

  instr 99; gathering of fluidsynth audio and audio output
aSigL, aSigR fluidOut           giEngine; read all audio from the given soundfont
             outs               aSigL, aSigR; send audio to outputs
  endin
</CsInstruments>
<CsScore>
i 99 0 3600; audio output instrument also keeps performance going
e
</CsScore>
<CsoundSynthesizer>


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
ioView background {59117, 36032, 9346}
</MacGUI>

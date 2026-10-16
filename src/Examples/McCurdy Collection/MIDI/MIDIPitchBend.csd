; Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add Semitone Bend Range widget


; my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps = 64    ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


instr 1  ; Simple sine tone synthesizer with pitch bend
  ioct octmidi
  iamp ampmidi 0.2

  ; Pitch bend information is read
  ; Pitch bend range in semitones (will be defined further later)
  kSemitoneBendRange invalue "BendRange"
  imin = 0                                 ; Equilibrium position
  imax = i(kSemitoneBendRange) * .0833333  ; Max pitch displacement (in oct format)
  kbend pchbend imin, imax                 ; Pitch bend variable (in oct format)

  ; Initial_level | attack_time | attack_level | decay_time | sustain_level | release_time
  ; | release_level
  aenv linsegr 0, (.01), 1, (.1), .5, (.2), 0

  ; Output opcode amplitude |     frequency      | function_table
  asig oscili iamp*aenv, cpsoct(ioct+kbend), 1
  outs asig, asig  ; Send audio output of oscillator to the speakers
endin
</CsInstruments>
<CsScore>
f 1 0 129 10 1  ; Sine wave
; This line functions as a dummy score event and allows realtime MIDI playing for 10
; minutes
f 0 600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>848</x>
 <y>238</y>
 <width>584</width>
 <height>374</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>170</r>
  <g>170</g>
  <b>170</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>578</width>
  <height>368</height>
  <uuid>{c37e13f6-7642-465f-9b2a-f059eef7bce8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pchbend - Scanning MIDI Pitch Bend </label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>6</x>
  <y>28</y>
  <width>569</width>
  <height>291</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------------------------
This example demonstrates how to scan the MIDI pitch bend wheel/joystick of a connected MIDI keyboard and to use the incoming data to implement the traditional pitch bend functionality.
Building upon the simple sine tone synthesizer of previous examples the opcode 'pchbend' is employed to allow the player to bend the pitch up or down by semitones.
Some additional mathematics and use of 'oct' format pitches are employed in the implementation of pitch bend in this example but I would recommend that you study the code for further information.
There is nothing to say that the pitch bend wheel must be used to drive the pitch of something in Csound - it could also be used to control panning, sample playback speed and many other parameters in Csound. The crucial element in the design of the pitch bend wheel is in its used of a central spring loaded equilibrium position and ideally this feature should be capitalised upon when it is used in Csound.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>6</x>
  <y>315</y>
  <width>216</width>
  <height>50</height>
  <uuid>{b143f42f-2cbc-4532-8df7-4ba643c60b37}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>326</y>
  <width>158</width>
  <height>35</height>
  <uuid>{4dc3e62f-8cd7-48cb-8f7f-25878ba3b97e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Semitone Bend Range:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>BendRange</objectName>
  <x>169</x>
  <y>322</y>
  <width>46</width>
  <height>35</height>
  <uuid>{ab5f68dc-b46a-4605-884c-0d87dcdb2801}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>24</maximum>
  <randomizable group="0">false</randomizable>
  <value>12</value>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

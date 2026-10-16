; Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:


; my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps = 64    ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


; Initialise global variables
gkcps       init 0
gkNumInstr1 init 0
gkvib       init 0


instr 1
  icps cpsmidi  ; Read values for frequency from a MIDI keyboard
  gkcps = icps  ; Create a k-rate global variable from MIDI freq. Values

  ; Create a vibrato function - this envelope will be triggered with each new new that is
  ; pressed whether legato or not
  ivibamp      = .1
  ivibdelayTim = .3
  ivibRiseTim  = 1
  kvibenv expseg .001, (ivibdelayTim), .001, (ivibRiseTim), ivibamp, (1), ivibamp
  kvibfreq = 6
  ivibwave = 1
  kvib oscil kvibenv, kvibfreq, ivibwave
  gkvib = kvib+1

  ; Instr 2 is instructed to play a very long note - only one note at a time is allowed
  ; Ktrigger, kmintim, kmaxnum, kinsnum, kwhen, kdur
  schedkwhen 1, 0, 1, 2, 0, 3600
endin

instr 2

  kporttime_gui invalue "Portamento"

  kreleaseflag release
  gkNumInstr1 active 1  ; Sense the number of notes are being played by instr 1
  ; If instr 1 is playing at least one note then instr 2 mustn't turn itself off
  if gkNumInstr1 != 0||kreleaseflag = 1 kgoto KEEP_PLAYING
  ; I.e. Skip the next line...
  turnoff      ; Instr 2 turns itself off
KEEP_PLAYING:  ; Skip to here if instr 1 is still playing

  ; Create portamento on pitch parameter
  kporttime linseg 0, .01, 1, 1, 1
  kporttime = kporttime * kporttime_gui
  kcps portk gkcps, kporttime

  ; Create an osillator using the vco opcode
  iwave = 1
  kpw   = .5
  ifn   = 1
  imaxd = 1
  ileak = 0
  inyx  = .5
  asig vco 0.3, kcps*gkvib, iwave, kpw, ifn, imaxd, ileak, inyx

  ; Filter envelope - all levels are given in oct format
  iFAttTim = .1    ; Attack time
  iFAttLev = 7     ; Attack level
  iFDecTim = .1    ; Decay time
  iFSusLev = 5     ; Sustain level
  iFRelTim = 0.01  ; Release time
  ; Create an envelope with a MIDI release segment to influence the filter cutoff
  kFEnv linsegr 0, iFAttTim, iFAttLev, iFDecTim, iFSusLev, iFRelTim, 0
  kCFOct = 6  ; Base level of the filter (before the envelope is added)
  ; Final filter cutoff value (in cps) incorporating the filter envelope and the filter
  ; base level
  kCFcps = cpsoct(kCFOct+kFEnv)
  kres   = .5  ; Resosnance
  iscale = 1
  ; Create a filtered version of the oscillator signal
  aFilt moogvcf asig, kCFcps, kres, iscale
  ; Send filtered signal to output
  aenv linsegr 0, 0.001, 1, 0.01, 0  ; Anti click envelope
  outs aFilt * aenv, aFilt * aenv
endin
</CsInstruments>
<CsScore>
f 1 0 131072 10 1  ; A sine wave - used by both the vibrato and the vco
f 0 3600           ; Dummy score event - real time performance for 1 hour
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>661</x>
 <y>241</y>
 <width>718</width>
 <height>352</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>170</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>711</width>
  <height>345</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Basic Monophonic MIDI Synthesizer</label>
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
  <x>7</x>
  <y>21</y>
  <width>702</width>
  <height>259</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------
You will need to have a midi keyboard connected to the computer for this to work. Monosynths can be implemented using 2 separate instruments and the schedkwhen opcode. The instrument containing the schedkwhen is midi triggered the schedkwhen opcode triggers a second instrument which is the one that actually produces the sound. Crucially the imaxnum parameter (maximum number of simultaneous notes allowed) in the schedkwhen opcode line is set to 1. The active opcode is used (in instr 2) to sense how many notes instr 1 is playing. If instr 1 isn't playing any notes then instr 2 turns itself off. Pitch variables are passed from the first instrument to the second using global variables. Portamento (portk) is used to implement glisandi between overlapping notes.
There are two ways in which envelopes can be triggered in monophonic synths:
1 - triggered only once, at the beginning of a sequence of overlapping notes.
2 - triggered with each new new that is pressed whether overlapping or not.
Two different envelopes which illustrate these two situations have been implemented in this example:
1 - a filter envelope is put in instrument 2 so that it will only trigger with the first of a series of overlapping notes.
2 - a vibrato function (with an vibrato depth envelope) is placed in instr 1 so that it will trigger each time a new note is is pressed whether legato or not.</label>
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
  <x>10</x>
  <y>288</y>
  <width>695</width>
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
  <x>12</x>
  <y>310</y>
  <width>180</width>
  <height>30</height>
  <uuid>{2e52a7a7-dc13-405e-896d-db2a7431d8dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Portamento Time</label>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Portamento</objectName>
  <x>12</x>
  <y>292</y>
  <width>689</width>
  <height>26</height>
  <uuid>{6ab84e0f-82a7-4b9c-af23-35bd7d9b7fa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.06095791</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Portamento</objectName>
  <x>641</x>
  <y>310</y>
  <width>60</width>
  <height>30</height>
  <uuid>{99d6bf8b-3c85-4911-a29a-7dd678a940ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.061</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

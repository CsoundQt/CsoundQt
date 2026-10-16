; Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Number of MIDI activated instrument display

; my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 128    ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


instr 1  ; Simple beep instrument - can be activated via a connected MIDI keyboard
  turnon 2
  ; Output opcode amplitude | frequency | function_table
  asig oscili 0.2, 440, 1

  outs asig, asig  ; Send audio output of oscillator to the speakers
endin

instr 2  ; show Active instr
  kinstr active 1

  Sinstr sprintfk "%01d", kinstr
  outvalue "Active", Sinstr
endin
</CsInstruments>
<CsScore>
f 1 0 1024 10 1  ; Sine wave
; This line functions as a dummy score event and allows realtime MIDI playing for 10
; minutes
f 0 600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>645</x>
 <y>352</y>
 <width>580</width>
 <height>353</height>
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
  <width>574</width>
  <height>347</height>
  <uuid>{c37e13f6-7642-465f-9b2a-f059eef7bce8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>   Activating an Instrument Through Realtime MIDI Control    </label>
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
  <x>5</x>
  <y>27</y>
  <width>567</width>
  <height>268</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------------------------------
Basic activation of csound instruments through the use of a connected MIDI keyboard is transparent to the user. The only requirement is that a Csound flag for live MIDI input is given so that Csound knows to expect MIDI information. 
For that, QuteCsound Configuration have to be settled to activate realtime MIDI.
The number after the M flag selects which of your computer's MIDI input devices to use.
If you are not sure use the 'all available devices' value 'a'.  This example is very basic and merely produces a beep each time a note is played on your MIDI keyboard. Note duration corresponds with how long you hold the note for. Csound regards MIDI notes as held notes so there is no point in trying to use 'p3' in, for example envelopes, in the instrument code for a MIDI activated instrument. Polyphony is possible although it is rather difficult to hear in this example as all beeps are the same pitch. If an orchestra contains more that one instrument, MIDI notes on MIDI channel 1 will be directed to instrument 1, channel 2 will be directed to instrument 2 and so on. Modification to this default arrangement is possible using the 'massign' opcode.</label>
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
  <x>34</x>
  <y>292</y>
  <width>336</width>
  <height>49</height>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Active</objectName>
  <x>301</x>
  <y>299</y>
  <width>57</width>
  <height>33</height>
  <uuid>{c187dde0-d186-4ba8-a859-d88073b31b19}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
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
  <x>36</x>
  <y>300</y>
  <width>262</width>
  <height>31</height>
  <uuid>{a1ec3ab8-544e-4940-abf9-3c6fa212e12a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number of Midi activated instrument:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
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

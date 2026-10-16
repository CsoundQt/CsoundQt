; Writen by Iain McCurdy, 2008

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:


; my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 16     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)


gkTime   init 1  ; Initialise variable for time gap between key presses
gkDlyTim init 1  ; Initialise delay time variable used in the delay effect in instr 4


instr 1                                   ; MIDI triggered instrument - receives 'taps'
  event_i "i", p1+2, 0, 0.001, i(gkTime)  ; Trigger tempo calculating instrument
  ; Start 'timer' instrument (-1 duration indicates a monphonic held note)
  event_i "i", p1+1, 0, -1
  ; Send current delay time value to the on-screen valuator box
  outvalue "Delay_Time", i(gkDlyTim)
  turnoff  ; Turnoff this instrument immediately
endin

instr 2  ; Timer to measure time gap between key presses
  ; Timeinsts outputs the time since the start of the this note being triggered
  gkTime timeinsts
endin

instr 3  ; Calculate current tempo based on time gap between the last two key presses
  ; Set delay time (for delay effect in instr 4) to current time gap value
  gkDlyTim init p4
  iTempo = 60/p4            ; Derive tempo from time gap
  outvalue "Tempo", iTempo  ; Send current delay time value to the on-screen valuator box
endin

; Delay instrument - takes live audio in as its input
instr 4
  iMaxDlyTim init 10                         ; Initialise variable for maximum delay time
  kDlyTim limit gkDlyTim, 0.001, iMaxDlyTim  ; Limit delay time to prevent crashes

  ain1 inch 1                ; Read audio from live input channel 1
  aFeedback init 0           ; Initialise feedback signal for first k pass
  aBuffer delayr iMaxDlyTim  ; Define audio buffer for delay
  aTap deltap3 kDlyTim       ; Read audio from a delay tap from within this buffer
  ; Write audio into the delay buffer (mixture of live in and feedback loop)
  delayw ain1+(aFeedback)
  ; Define the audio feedback signal for the next k pass
  aFeedback = aTap*.5
  outs (aTap+ain1)*.5, (aTap+ain1)*.5  ; Send audio to outputs (and attenuate)
endin
</CsInstruments>
<CsScore>
i 1 0 0.001  ; Instr 1 (short note)
i 4 0 3600   ; Instr 4 (delay) plays for 1 hour
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>915</x>
 <y>239</y>
 <width>519</width>
 <height>225</height>
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
  <width>513</width>
  <height>217</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI Tap Tempo</label>
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
  <width>506</width>
  <height>125</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------------
The example demonstrate a method for defining a tempo by tapping notes on a MIDI keyboard. The time difference between consecutive MIDI note-ons is recorded and used to derive a tempo value. In this example this value is used to define the delay time of a simple delay effect that is applied to the live audio input of the computer.</label>
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
  <y>153</y>
  <width>505</width>
  <height>60</height>
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
  <x>217</x>
  <y>166</y>
  <width>93</width>
  <height>30</height>
  <uuid>{a3c622cc-d6a0-4f7c-b9b8-5179d6261036}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Time</label>
  <alignment>right</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>18</x>
  <y>166</y>
  <width>93</width>
  <height>30</height>
  <uuid>{830ca56f-fafc-4c8c-b8b0-8ac877fd49ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tempo</label>
  <alignment>right</alignment>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Tempo</objectName>
  <x>110</x>
  <y>166</y>
  <width>80</width>
  <height>30</height>
  <uuid>{0c475a5a-d0aa-4fcd-9caa-a95cbaf1ad9d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>60.000</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Delay_Time</objectName>
  <x>309</x>
  <y>166</y>
  <width>80</width>
  <height>30</height>
  <uuid>{d39e4f0b-318a-4a5b-b29d-5972c1cf8789}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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

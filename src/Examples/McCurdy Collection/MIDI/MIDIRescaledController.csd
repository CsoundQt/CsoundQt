; Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add koct display


; my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 2      ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


; Beep instrument - activated by a score note - frequency variable using controller 1
instr 1

  ; Output opcode channel | ctrlnumber | minimum | maximum |
  ; f.n._used_to_rescale_slider_values
  ; Read controller information from continuous controller number 1 on MIDI channel 1,
  ; rescale to be within the range 0 - 1 then rescale again according to function table
  ; no. 2
  koct ctrl7 1, 1, 0, 1, 2

  outvalue "ctrl1", koct

  ; Output opcode amplitude |    freq.    | f.n.
  ; Frequency is converted from 'oct' format into 'cps' (cycles per second) format as
  ; oscili expects
  asig oscili 0.2, cpsoct(koct), 1
  outs asig, asig  ; Send audio signal to the outputs
endin
</CsInstruments>
<CsScore>
f 1 0 129 10 1  ; Sine wave
; Rescaling function (note: un-normalized function - the use of a minus sign in the gen
; routine number). Refer to csound manual regarding gen 07 for more information
f 2 0 129 -7 8 64 9 64 7
i 1 0 3600  ; Instrument 1 plays a note for 1 hour
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>791</x>
 <y>321</y>
 <width>585</width>
 <height>373</height>
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
  <label>Rescaling a ctrl7 derived variable using a function table</label>
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
Move controller 1 on MIDI channel 1 (or the modulation wheel on a keyboard set to channel 1). This pitch of the oscillator rises up one octave and then falls by two octaves. Ctrl7 includes an optional argument which can be used to reference a function table which will be used to rescale the range of values already defined for the controller derived varable. This feature can be used to create a non-linear mapping of values as the controller is moved. In this example a function table has been created using GEN 7 (straight line segments) as follows:
;________GEN_VAL_DUR_VAL_DUR_VAL
f_2_129___-7____8___64____9___64___7

A minus sign is placed in front of the the GEN routine number to ensure that the values will not be normalised. When the controller is rescaled using this table its output will rise from 8 to 9 for the first half of the controller's movement at which point it will change direction and descend to a final value of 7. These values are used as 'oct' format values for the oscillators frequency paramenter. Another common use of this feature is to remap logarithmic parameters such as frequency so that the MIDI slider controlling them give a more useful response.</label>
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
  <width>188</width>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>ctrl1</objectName>
  <x>91</x>
  <y>327</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f8119d82-f052-4a86-8790-440c42c5d41d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.000</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>19</x>
  <y>324</y>
  <width>73</width>
  <height>31</height>
  <uuid>{4dc3e62f-8cd7-48cb-8f7f-25878ba3b97e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>koct:</label>
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

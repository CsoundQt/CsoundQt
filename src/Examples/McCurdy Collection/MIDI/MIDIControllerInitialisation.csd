; Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add kvolume display


; my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 2      ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


; The opcode 'initc7' initialises a continuous controller to a specified location between
; its minimum and maximum value.

; This initialisation value is expressed as a propotion of how far along its path from
; minimum to maximum it should begin and is therefore always a number in the range 0-1.
; A value of 0 would imply that the slider begins at its lowest setting.
; A value of 1 would imply that the slider begins at its highest setting.
; A value of .5 would imply that the slider begins halfway along its track.

; If you require a midi controlled variable to begin at a specific value the required
; initialisation value can be calculated using the formula shown below.
; Initialisation defaults to 0 so if you require a controller to begin at minimum it is
; not necessary to initialise it.

; Note that once a slider is physically moved its corresponding csound variable
; immediately jumps to that new value

; Note also that this initialisation statement is placed between the header statements and
; the first instrument definition (known as the instr 0 definition)
; - This means that the controller will be initialised upon beginning the csound session
; *only*
; If the initialisation statement is placed within the instrument code itself it will
; reinitialise each time a new note is played

; Midichannel | ctrlnumber | value(0-1)
initc7 1, 1, 1

; **************************************************************************************
; *                                                                                    *
; *                              Desired_Controller_Value    -    Controller_Minimum   *
; *      Initial__Value    =    _____________________________________________________  *
; *                                                                                    *
; *                              Controller_Maximum          -    Controller_Minimum   *
; *                                                                                    *
; **************************************************************************************


instr 1  ; Simple beep instrument - can be activated via a connected MIDI keyboard
  icps cpsmidi
  iamp ampmidi 0.2

  ; Output opcode channel | ctrlnumber | minimum | maximum
  ; Read controller information from continuous controller number 1 on MIDI channel 1 and
  ; rescale to be within the range 0 - 1
  kvolume ctrl7 1, 1, 0, 1

  ; Create a ramping up function that will be used for portamento time - this will prevent
  ; portamento-ed variables from gliding up to their desired values at note onsets
  kporttime linseg 0, .001, .01, 1, .01
  kvolume portk kvolume, kporttime  ; Apply portamento to kvolume to smooth its movement

  outvalue "ctrl1", kvolume

  ; Initial_level | attack_time | attack_level | decay_time | sustain_level | release_time
  ; | release_level
  aenv linsegr 0, (.01), 1, (.1), .7, (.05), 0

  asig oscili iamp, icps, 1
  outs asig * aenv * kvolume, asig * aenv * kvolume
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
 <x>726</x>
 <y>332</y>
 <width>612</width>
 <height>371</height>
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
  <width>760</width>
  <height>369</height>
  <uuid>{c37e13f6-7642-465f-9b2a-f059eef7bce8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>initc7 - Setting an Initial Value for a Continuous Controller</label>
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
  <x>3</x>
  <y>24</y>
  <width>600</width>
  <height>290</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------------------------------------
This example builds upon the previous example in that it demonstrates how to set the initial value of a continuous controller used in a csound orchestra. If no initial value is defined then then a ctrl7's output defaults to its minimum value. The opcode initc7 is used to set an initial value for ctrl7. Initc7 is normally placed in the instrument 0 part of the orchestra (after the orchestra header and before the first instrument) so that the controller is initialised only when the orchestra is started. If it is placed within an instrument then it will be initialised each time that instrument is activated - it is unlikely that this will be the desired behaviour. Giving initc7 an intialisation value is not entirely straightforward. We cannot give initc7 the actual value we desire as because initc7 appears before ctrl7 csound does not yet know the range of the controller. Instead, initc7 expects a value within the range 0 - 1, with a value of 0 representing the controller's minimum setting and a value of 1 representing the controller's maximum setting. Csound will subsequently adjust this value when it encounters the ctrl7 line of code. Normally we are more concerned with the precise value of ctrl7's output therefore it is useful to use the formula given in the csd to calculate the corresponding value to give initc7.
In this example the volume controller is initialised to its maximum setting and initc7 is therefore given the value '1' for an initial state.</label>
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
  <x>8</x>
  <y>314</y>
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
  <x>89</x>
  <y>326</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f8119d82-f052-4a86-8790-440c42c5d41d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
  <label>kvolume:</label>
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

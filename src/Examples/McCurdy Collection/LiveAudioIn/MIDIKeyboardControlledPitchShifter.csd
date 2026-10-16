; Written by Iain McCurdy, 2006

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Use midi controller 1 on channel 1 to control Grain_Size slider
; Plays midi on channel 1

; Notes on modifications from original csd:
; Add table(s) for exp slider


; my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 16     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


giExp10 ftgen 0, 0, 129, -25, 0, 0.001, 128, 10.0  ; Table for exp slider


instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then

    gkdlt      invalue "Grain_Size"
    gkfeedback invalue "Feedback"
    kdry       invalue "Dry"
    gkwet      invalue "Wet"
    katt       invalue "Attack"
    gkatt tablei katt, giExp10, 1
    outvalue "Attack_Value", gkatt
    krel invalue "Release"
    gkrel tablei krel, giExp10, 1
    outvalue "Release_Value", gkrel
    gkamp invalue "Amplitude"
  endif

  ; Audio input
  gasigL, gasigR ins
  outs gasigL * kdry, gasigR * kdry
endin

instr 1  ; Pitch shifter
  ioct octmidi

  ; Pitch
  ; bend===========================================================================================================================================================
  ; Pitch bend range in semitones (will be defined further later) - suggestion - this
  ; could be controlled by an FLTK counter
  iSemitoneBendRange = 2
  imin               = 0  ; Equilibrium position
  ; Max pitch displacement (in oct format)
  imax = iSemitoneBendRange * .0833333
  ; Pitch bend variable (in oct format)
  kbend pchbend imin, imax
  koct = ioct + kbend
  ; =====================================================================================================================================================================

  ; MIDI
  ; input============================================================================================================================================================
  ; Output        opcode  channel | cc.number | min | max
  kdlt ctrl7 1, 1, 0, 1  ; Read in MIDI controller
  ktrig changed kdlt     ; If the variable 'kptr' changes from its previous value,
  ; I.e. If the MIDI slider is moved then the variable ktrig will assume the value '1',
  ; otherwise it will be zero.
  kdlt scale kdlt, 1, 0.001  ; Rescale variable

  if ktrig = 1 then
    outvalue "Grain_Size", kdlt  ; Update widget when a trigger is received
  endif
  ; ======================================================================================================================================================================

  ; Set up function to modulate delay time variable and enveloping
  ; function===============================================================================================
  iporttime = 0.1  ; Portamento time
  ; Create a ramping up function that will be used for portamento time
  kporttime linseg 0, 0.001, iporttime, 1, iporttime
  kdlt portk gkdlt, kporttime  ; Apply portamento
  adlt interp kdlt             ; Create an interolated a-rate version of k-rate variable
  ; Ratio of new freq to a declared base frequency (middle c)
  kratio = cpsoct(koct)/cpsoct(8)
  krate  = (kratio-1)/kdlt  ; Subtract 1/1 speed
  aphase1 phasor -krate     ; Moving phase 1-0
  ; Moving phase 1-0 - phase offset by 180 degrees (.5 radians)
  aphase2 phasor -krate, 0.5
  agate1 tablei aphase1, 1, 1, 0, 1  ; Window func =half sine
  agate2 tablei aphase2, 1, 1, 0, 1  ; Window func =half sine
  ; ======================================================================================================================================================================

  ; Left
  ; channel===========================================================================================================================================================
  aignore delayr 1                 ; Alloc delay line
  adelsig1 deltap3 aphase1 * adlt  ; Variable tap
  aGatedSig1 = adelsig1 * agate1   ; Gate 1st signal
  ; Write audio to the beginning of the delay buffer
  delayw gasigL + (aGatedSig1 * gkfeedback)

  aignore delayr 1                 ; Alloc delay line
  adelsig2 deltap3 aphase2 * adlt  ; Variable tap
  aGatedSig2 = adelsig2 * agate2   ; Gate 2nd signal
  ; Write audio to the beginning of the delay buffer
  delayw gasigL + (aGatedSig2 * gkfeedback)

  aGatedMixL = (aGatedSig1 + aGatedSig2) * .5  ; Mix and attenuate
  ; =======================================================================================================================================================================

  ; Right
  ; channel==========================================================================================================================================================
  aignore delayr 1                 ; Alloc delay line
  adelsig3 deltap3 aphase1 * adlt  ; Variable tap
  aGatedSig3 = adelsig3 * agate1   ; Gate 1st signal
  ; Write audio to the beginning of the delay buffer
  delayw gasigR + (aGatedSig3 * gkfeedback)

  aignore delayr 1                 ; Alloc delay line
  adelsig4 deltap3 aphase2 * adlt  ; Variable tap
  aGatedSig4 = adelsig4 * agate2   ; Gate 2nd signal
  ; Write audio to the beginning of the delay buffer
  delayw gasigR + (aGatedSig4 * gkfeedback)

  aGatedMixR = (aGatedSig3 + aGatedSig4) * .5  ; Mix and attenuate
  ; =======================================================================================================================================================================

  ; Convert attack and release controls to i-rate and make available at i-time by using
  ; init
  iatt init i(gkatt)
  ; Convert attack and release controls to i-rate and make available at i-time by using
  ; init
  irel init i(gkrel)

  kenv expsegr 0.001, iatt, 1, irel, 0.001  ; Amplitude envelope is created
  outs aGatedMixL * kenv * gkwet * gkamp, aGatedMixR * kenv *gkwet * gkamp
endin
</CsInstruments>
<CsScore>
f 1 0 1025 9 0.5 1 0  ; Half sine  window function used for amplitude enveloping

; Instr | start | duration
i 10 0 3600  ; GUI and audio inputs
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>323</x>
 <y>380</y>
 <width>940</width>
 <height>328</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>514</width>
  <height>326</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI Keyboard Controlled Pitch Shifter</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>158</r>
   <g>220</g>
   <b>158</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>519</x>
  <y>2</y>
  <width>421</width>
  <height>326</height>
  <uuid>{cebe7e5c-304d-4db6-8da2-0e27c0616bab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI Keyboard Controlled Pitch Shifter</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>158</r>
   <g>220</g>
   <b>158</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>521</x>
  <y>35</y>
  <width>414</width>
  <height>287</height>
  <uuid>{c24a85f3-363e-476e-81da-37729ad65bb7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------
This example implements a pitch shifter effect based on the algorithm introduced previously under 'Delay Effects'.
The innovation in this example is that the pitch shifter effect is applied to a live input signal and that the interval of pitch shift is determined by notes played on a MIDI keyboard (middle C represents no pitch shift).
The number of pitch shifter voices is dynamic therefore harmony chords are possible.
The number of voices possible is restricted only by available CPU.
Attack and release controls are included to allow voices to enter and leave according to a user defined amplitude envelope.
Stereo input and output.
The pitch bend wheel can be used to bend the pitch up or down by 2 semitones.
The Modulation wheel can be used to modulate 'Grain Size'.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>65</r>
   <g>65</g>
   <b>65</b>
  </color>
  <bgcolor mode="nobackground">
   <r>158</r>
   <g>220</g>
   <b>158</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>180</y>
  <width>150</width>
  <height>30</height>
  <uuid>{63ab529c-3f14-4886-8215-fd6e8f1a37ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Wet Signal Level</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Wet</objectName>
  <x>8</x>
  <y>163</y>
  <width>500</width>
  <height>27</height>
  <uuid>{a7c37920-a18a-446b-8b66-6a1119503da0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Wet</objectName>
  <x>448</x>
  <y>180</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b453c0e4-809f-4074-94fd-506ebb68f3b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>216</y>
  <width>150</width>
  <height>30</height>
  <uuid>{760945fc-2052-4408-8344-abdb00ead7b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack Time</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Attack</objectName>
  <x>8</x>
  <y>199</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d5b42e3d-c45f-4288-bb9c-16eb365124bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Attack_Value</objectName>
  <x>448</x>
  <y>216</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3837993c-b043-4b23-a36f-83ea6a2f2d2b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>252</y>
  <width>150</width>
  <height>30</height>
  <uuid>{7e59b44f-2b3b-4941-9e17-c56369f9316a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release Time</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Release</objectName>
  <x>8</x>
  <y>235</y>
  <width>500</width>
  <height>27</height>
  <uuid>{84d39e8a-7044-4434-92fd-919cc03f9d01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Release_Value</objectName>
  <x>448</x>
  <y>252</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a4a174c2-d21c-4f3b-a485-d396bc7e9495}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>73</y>
  <width>300</width>
  <height>30</height>
  <uuid>{93cc32a5-c161-4212-baeb-c28b120f89a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Size in Seconds (Used by Pitch Shifter)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Grain_Size</objectName>
  <x>8</x>
  <y>56</y>
  <width>500</width>
  <height>27</height>
  <uuid>{107836e5-a726-4a83-83b5-c368481d9a48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.39430708</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Grain_Size</objectName>
  <x>448</x>
  <y>73</y>
  <width>60</width>
  <height>30</height>
  <uuid>{71f0e6eb-f79d-4cd7-80f7-a22cc355e64f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.394</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>109</y>
  <width>150</width>
  <height>30</height>
  <uuid>{e193ffd3-920b-40d4-9eaa-bd11dad75bff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feedback</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Feedback</objectName>
  <x>8</x>
  <y>92</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e4aa4e7b-5b74-4a61-8bd7-4beea2c0bb93}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.38600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Feedback</objectName>
  <x>448</x>
  <y>109</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dc879380-3a9e-4939-b482-a0b4ee46dac5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.386</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>145</y>
  <width>150</width>
  <height>30</height>
  <uuid>{866a933e-0c0d-493a-84af-29f3557f8e4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry Signal Level</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Dry</objectName>
  <x>8</x>
  <y>128</y>
  <width>500</width>
  <height>27</height>
  <uuid>{fbbd0dd3-c206-4214-aa5e-10d42b909252}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Dry</objectName>
  <x>448</x>
  <y>145</y>
  <width>60</width>
  <height>30</height>
  <uuid>{31c3cb1b-308f-47cd-9396-c81d85a1c30a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>288</y>
  <width>150</width>
  <height>30</height>
  <uuid>{79ce92b4-456d-4a0a-aa5d-813238d5011c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Amplitude</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>271</y>
  <width>500</width>
  <height>27</height>
  <uuid>{012823fb-e024-44a5-9eb4-a410da52002b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>288</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d1263e0c-e9f9-4f7c-9ca5-77d2bf37a5d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

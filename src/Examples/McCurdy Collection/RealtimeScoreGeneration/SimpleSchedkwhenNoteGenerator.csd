; Written by Iain McCurdy, 2006

; Modified for QuteCsound by René, March 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps = 64    ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    gkTrigFreqMin invalue "TrigFreqMin"
    gkTrigFreqMax invalue "TrigFreqMax"
    gkscale       invalue "Scale"
  endif
endin

; This instrument triggers notes in instrument 2 with a minimum time gap between notes of
; kmintim seconds
instr 1
  ; Trigger frequency - defined randomly within the given range - frequency of new random
  ; number output=5hz
  kTrigFreq randomi gkTrigFreqMin, gkTrigFreqMax, 5
  ; Create a trigger signal (momentary '1' impulses) according to the fluctuating variable
  ; 'ktrigfreq'
  ktrigger metro kTrigFreq
  ; Note durations will be defined randomly:
  ; Min | max | frequency
  kdur randomh .1, 2, 5  ; Sample-and-hold random number generator
  ; Trigger | mintim | maxnum | insnum | when | kdur
  schedkwhen ktrigger, 0, 0, 2, 0, kdur
endin

instr 2  ; This is the sound producing instrument - a simple sine wave 'ping'
  ; Amplitudes will be random values between 1000 (very quiet) and 10000 (loud)
  iamp random 0.03, 0.5
  ; Pan values will be random values between 0 (left speaker) and 1 (right speaker)
  ipan    random 0, 1
  ipchndx random 0, 13  ; A random index value is defined for each new note.
  ; This index will be used to select values from the 'scale' function table.
  ; The maximum possible value should not exceed the number of values (notes) defined in
  ; the corresponding function table (scale).
  ; The variable ipch will be selected from the ipchndx value in function table 2
  ipch table ipchndx, 2+i(gkscale)
  aenv expseg 1, (p3), .001  ; Percussive-type amplitude envelope
  ; Generate an audio signal according to the waveform in function table 1 - use the
  ; selected pch value and apply the amplitude envelope and random amplitude value
  asig oscil iamp * aenv, cpspch(ipch), 1
  outs asig * ipan, asig * (1-ipan)  ; Send audio to outputs and apply simple panning
endin
</CsInstruments>
<CsScore>
f 1 0 4096 10 1  ; Sine wave

; Table_no.|init_time|size|gen_number|values.1.. 2 3 4 5 6 7 8 9 10 11 12 13
f 2 0 64 -2 7 7.03 7.05 7.07 7.10 8 8.03 8.05 8.07 8.10 9  ; Pentatonic scale - 2 octaves
; Whole tone scale - 2 octaves
f 3 0 64 -2 7 7.02 7.04 7.06 7.08 7.10 8.00 8.02 8.04 8.06 8.08 8.10 9.00
; Gen 2 offers us a means to store discrete values, defined value by value - in this case
; these values will be interpreted in the orchestra as pch format values
; If the gen routine number is given as a negative number then values won't be normalized
; (rescaled within the range -1 to 1)

i 10 0 3600  ; GUI
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1160</x>
 <y>149</y>
 <width>519</width>
 <height>488</height>
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
  <width>510</width>
  <height>482</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>schedkwhen - Simple Algorithmic Note Generator</label>
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
   <r>244</r>
   <g>248</g>
   <b>200</b>
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
  <x>6</x>
  <y>127</y>
  <width>501</width>
  <height>355</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------
This example demonstrates how the opcode 'schedkwhen' can be used to implement a simple algorithmic note generator. 'Algorithmic' refers to the fact that the pitches of notes generated will be indeterminate but not completely random. Pitches will be chosen at random from a set of notes defined in a function table. Schedkwhen allows one instrument to generate multiple notes that will be played by another instrument. Schedkwhen is activated by a trigger signal which could be pulsed, rhythmical or unpulsed/rhymically aleatoric. Schedkwhen also allows the user to define start time, note duration and any number of additional p-fields at k-rate. (The called instrument will receive these values as i-rate p-values. With these capabilties the possiblities for algorithmically generating notes are immense. In this very simple example the user can vary the random value limits for the trigger frequency. Setting these two controls to the same value will create metered note generation. The user can also choose between two different scale types (stored in two separate GEN-02 function tables). Each time a note is generated its duration will be a randomly chosen value between .1 and 2 (seconds). The amplitude of each note will also be random. Each note will occupy a randomly chosen location between the left and right speakers. This example employs very simple and uniform random number generators. Csound offers a wide variety of more powerful random number generators portraying a variety of distributions.</label>
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
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b9137</objectName>
  <x>8</x>
  <y>44</y>
  <width>80</width>
  <height>26</height>
  <uuid>{04d44ebe-12eb-4bb0-a3f5-9e4fd3e7830e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On / Off</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
  <flatStyle>true</flatStyle>
  <color>
   <r>203</r>
   <g>206</g>
   <b>255</b>
  </color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>109</x>
  <y>45</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7c945fd6-92be-427f-bceb-ab7630e97198}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Scale</label>
  <alignment>right</alignment>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Scale</objectName>
  <x>195</x>
  <y>44</y>
  <width>120</width>
  <height>26</height>
  <uuid>{2940aaee-8fb3-46d5-bb2c-a70e3e47e5cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Pentatonic</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Whole Tone</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>TrigFreqMin</objectName>
  <x>7</x>
  <y>83</y>
  <width>500</width>
  <height>12</height>
  <uuid>{4e625263-998b-44d3-aa3d-30623c5a9616}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.01000000</xMin>
  <xMax>20.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>5.00750000</xValue>
  <yValue>0.25000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>255</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>TrigFreqMax</objectName>
  <x>7</x>
  <y>99</y>
  <width>500</width>
  <height>12</height>
  <uuid>{5f320247-5c85-42cc-b569-5d88268b1c6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.01000000</xMin>
  <xMax>20.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>5.00750000</xValue>
  <yValue>0.25000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>255</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>177</x>
  <y>110</y>
  <width>160</width>
  <height>26</height>
  <uuid>{c0e508d9-0147-47a9-8441-51028c427718}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Trigger Frequency: min / max</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>TrigFreqMax</objectName>
  <x>447</x>
  <y>110</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f7047b7a-3e79-47a8-8711-b538657cc78f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.008</label>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>TrigFreqMin</objectName>
  <x>7</x>
  <y>110</y>
  <width>60</width>
  <height>30</height>
  <uuid>{11206a4a-c384-42c7-b034-19e06c2d1d6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.008</label>
  <alignment>left</alignment>
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

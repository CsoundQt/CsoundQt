; Written by Iain McCurdy, 2008

; Modified for QuteCsound by René, March 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 1      ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


; Initial index value (from where in the giscale table we will begin reading from)
giindex init 5

; Table storing pch values used in the drunk walk
; 0   1    2    3    4    5    6    7    8    9    10   11   12   13   14   15
giscale ftgen 0, 0, 32, -2, 6.00, 6.03, 6.05, 6.07, 6.10, 7.00, 7.03, 7.05, 7.07, 7.10, 8.00, 8.03, 8.05, 8.07, 8.10, 9.00


instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    gkBoundary invalue "Boundary"
    gkTrigFreq invalue "SpeedWalk"
    gkoutgain  invalue "OutGain"
  endif
endin

instr 1                      ; Note triggering instrument
  ktrigger metro gkTrigFreq  ; Create a metronome of momentary '1's

  ; Trigger | mintim | maxnum | insnum | when | kdur
  schedkwhen ktrigger, 0, 0, p1+1, 0, 0.01  ; Trigger next instrument metronomically
endin

instr 2                      ; Process drunk walk
  istep random 0, 2          ; Step value set to random float between 0 and 2
  istep  = (int(istep)*2)-1  ; Istep will be either 1 or -1
  iindex = giindex + istep   ; Add random value to old index value

  if gkBoundary != 1 goto SKIP1  ; If boundary mode is set to 'bounce'
  if iindex == -1 then           ; If index pushes below boundary...
    iindex = 1                   ; ...Set to one above minimum
  elseif iindex == 16 then       ; If index pushes beyond boundary...
    iindex = 14                  ; ...Bounce to one below boundary
  endif                          ; End of conditional branching
  goto SKIP2                     ; Goto label
SKIP1:
  ; Limit index value within table limits
  iindex limit iindex, 0, 15
  if iindex == giindex&&gkBoundary == 2 goto SKIP3  ; No repeats
SKIP2:                                              ; Label
  ; Turnoff 'old' note to prevent polyphony
  turnoff2 3, 1, 1
  ; i   strt  dur   p4
  event_i "i", p1+1, 0.01, 8, giindex  ; Play a note using next instrument
SKIP3:                                 ; Label
  ; Global index (used as the 'old' index value for comparison in next performance pass)
  giindex = iindex
  outvalue "Step", istep     ; Write step value to fl text box
  outvalue "Index", giindex  ; Write index value to fl text box
  turnoff                    ; Turn this instrument off
endin

instr 3
  ipch table p4, giscale                          ; Read pch value from table using index
  aenv linsegr 0, 0.005, 1, p3-0.105, 1, 0.1, 0   ; Amplitude envelop with release stage
  iplk random 0.1, 0.3                            ; Slightly randomize pluck position
  asig wgpluck2 0.98, 1, cpspch(ipch), iplk, 0.6  ; Plucked string physical model
  ; Scale audio signal using amplitude envelope and output gain slider
  asig = asig * aenv * gkoutgain
  outs asig, asig  ; Send audio to outputs
endin
</CsInstruments>
<CsScore>
i 10 0 3600  ; GUI
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1159</x>
 <y>92</y>
 <width>520</width>
 <height>519</height>
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
  <height>510</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Drunk Walk</label>
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
  <x>8</x>
  <y>112</y>
  <width>220</width>
  <height>30</height>
  <uuid>{640b50b7-7200-4f81-8394-89d9843ae939}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Speed of Walk (Hz)</label>
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
  <objectName>SpeedWalk</objectName>
  <x>8</x>
  <y>90</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>20.00000000</maximum>
  <value>2.01040000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>SpeedWalk</objectName>
  <x>448</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b731b52e-e14a-476a-a583-f3b2bd885539}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2.010</label>
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
  <y>173</y>
  <width>500</width>
  <height>335</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------
The Drunk Walk is a common concept of data generation in algorithmic composition. The metaphor is of a drunk person walking home - the person does not walk forward in a straight line, instead randomly taking a step either to the left or to the right. In this example this concept is applied to the generation of note data. Data for two octaves of a pentatonic scale is stored in a GEN 2 function table. A metronome rhythmically triggers notes. Each time a new note is triggered a random choice is made to either take a step up or down this sequence.
Whenever the walk attempts to cross the upper or lower boundary one of three responses is taken depending on which 'Boundary Rule' has been chosen by the user:
If 'None' has been chosen the boundary limit value is repeated.
If 'Bounce' has been chosen the walker 'bounces' off the boundary and a step is taken in the opposite direction.
If 'No Repeats' has been chosen the walker holds the boundary limit location but does not play a note.
Valuator boxes indicate for the user whether the walker is taking a step up or down the scale and where the walker is within the scale (index). The index value will range from zero to 10.</label>
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
  <objectName>b1103</objectName>
  <x>8</x>
  <y>10</y>
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
  <x>1</x>
  <y>56</y>
  <width>100</width>
  <height>25</height>
  <uuid>{7c945fd6-92be-427f-bceb-ab7630e97198}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Boundary Rule</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>217</x>
  <y>52</y>
  <width>60</width>
  <height>26</height>
  <uuid>{d604a2a6-123b-4883-9e29-bf844e323419}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Step</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>158</y>
  <width>220</width>
  <height>30</height>
  <uuid>{a79e966a-f875-4240-9f22-44a0a2fde9ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Gain</label>
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
  <objectName>OutGain</objectName>
  <x>8</x>
  <y>136</y>
  <width>500</width>
  <height>27</height>
  <uuid>{774f68ec-19bc-4a55-9a46-523c4f691bc3}</uuid>
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
  <objectName>OutGain</objectName>
  <x>448</x>
  <y>158</y>
  <width>60</width>
  <height>30</height>
  <uuid>{374358b4-4923-4722-a810-00f8348a4757}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Boundary</objectName>
  <x>105</x>
  <y>52</y>
  <width>116</width>
  <height>30</height>
  <uuid>{2940aaee-8fb3-46d5-bb2c-a70e3e47e5cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>None</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Bounce</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>No Repeats</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>364</x>
  <y>52</y>
  <width>60</width>
  <height>26</height>
  <uuid>{7d62f3ed-2a79-4f34-90a9-81caedc2fcdb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Index</label>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Step</objectName>
  <x>277</x>
  <y>52</y>
  <width>60</width>
  <height>25</height>
  <uuid>{45bbc5fc-efb7-4c01-aa9a-c2022e615b89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>6</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Index</objectName>
  <x>423</x>
  <y>52</y>
  <width>60</width>
  <height>25</height>
  <uuid>{0129cc6e-3de1-44fa-a5cf-26287a71e589}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>11.000</label>
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
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>6</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

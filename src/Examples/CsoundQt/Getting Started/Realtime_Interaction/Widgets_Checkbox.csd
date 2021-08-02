/* Getting Started .. Realtime Interaction: Widgets-Checkbox

Open the Widgets-Panel. 

It contains an arrangement of checkboxes and a controller-window.

The controller window is a two dimensional fader, so it sends values on two different channels.

Checkboxes work similar to buttons, but keep their last state. They work very well, to turn on/off parts of an instrument. 
The checkbox condition can be verified while the instrument runs. This is made with the "if .. then .. endif" construct.
The "if" part checks the condition. If it is <true>, then the "then" part will be executed, if it is <false>, it jumps directly to the endif.

To find out more about the possibilities and usage of widgets, have a look into the widgets reference. (Examples->Widgets) 
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 1
0dbfs = 1

instr 1 
; read checkboxes
kRead invalue "read"
kSound invalue "sound"
kDance invalue "dance"


if kRead == 1 then
	; Read Point values
	kpoint_x invalue "point_x"
	kpoint_y invalue "point_y"
	printks "(x: %f, y: %f)%n", 0.2, kpoint_x, kpoint_y
endif

if kSound == 1 then
	; Sound Point
	kpoint_x invalue "point_x"
	kpoint_y invalue "point_y"
	apoint_x interp  kpoint_x			; casts both k-signals ...
	apoint_y interp  kpoint_y			; ... to audiorate
	aOut oscili apoint_y, apoint_x*1000, 1
	out aOut
endif

if kDance == 1 then
	; Dance Point
	knew_x randomh 0, 1, 15
	knew_y randomh 0, 1, 15
	outvalue "point_x", knew_x
	outvalue "point_y", knew_y
endif
endin


</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 






<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1013</x>
 <y>279</y>
 <width>563</width>
 <height>397</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>132</r>
  <g>162</g>
  <b>8</b>
 </bgcolor>
 <bsbObject version="2" type="BSBController">
  <objectName>point_y</objectName>
  <x>30</x>
  <y>195</y>
  <width>318</width>
  <height>253</height>
  <uuid>{7b88d65c-1539-4552-8c37-0c566fb3c631}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>point_x</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.61348438</xValue>
  <yValue>0.47489458</yValue>
  <type>point</type>
  <pointsize>7</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>31</x>
  <y>32</y>
  <width>134</width>
  <height>30</height>
  <uuid>{5d76e7c2-5c54-4aa6-b637-344e10818acd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1. Run Csound</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>31</x>
  <y>123</y>
  <width>135</width>
  <height>73</height>
  <uuid>{a61ce639-4796-4143-9d31-67e36f6ce9d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Read out the point position and print it to the console.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>361</x>
  <y>123</y>
  <width>120</width>
  <height>70</height>
  <uuid>{85a10aea-c364-4c4e-a872-505d4d0c0776}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Send random position data to the point.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>182</x>
  <y>124</y>
  <width>161</width>
  <height>64</height>
  <uuid>{224f540f-525e-43d3-98b1-f5367dd76d89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Use point position data to control an oscils amplitude and frequency.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBConsole">
  <objectName/>
  <x>361</x>
  <y>195</y>
  <width>183</width>
  <height>252</height>
  <uuid>{a75f9ef6-a277-4f6b-bcf7-4b3d0ddfc6fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <font>Courier</font>
  <fontsize>8</fontsize>
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
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>30</x>
  <y>66</y>
  <width>514</width>
  <height>39</height>
  <uuid>{5e3f1106-b2bd-4a74-98a1-2023743bda81}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2. Press one of these three buttons and move the point.</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>173</x>
  <y>32</y>
  <width>100</width>
  <height>30</height>
  <uuid>{b8851d94-4074-488b-95f4-9cfb9d01a4aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Run Csound</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>read</objectName>
  <x>30</x>
  <y>103</y>
  <width>20</width>
  <height>20</height>
  <uuid>{15e01f48-48f0-4107-8a0d-ca8e9a9c2b5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>sound</objectName>
  <x>183</x>
  <y>103</y>
  <width>20</width>
  <height>20</height>
  <uuid>{cfba4b21-f2fd-4235-bd00-2d1078632488}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>dance</objectName>
  <x>360</x>
  <y>105</y>
  <width>20</width>
  <height>20</height>
  <uuid>{281f87bc-d138-4dbf-b70e-fc8ca1ed78ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="604" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

/* Getting Started .. Realtime Interaction: Widgets

Rember to open the Widget Panel. 

The last example demonstrated how an instrument receives values from the Widget Panel.
It's also possible to send values to the Widgets, by using 'outvalue' opcode in the instrument. 

Now, you can display values, automate faders and much more..
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr     = 44100
ksmps  = 64
nchnls = 1
0dbfs  = 1

instr 1  ; Move Fader
  kMoveUp = linseg(0, 3, 1, 1, 1, 0.5, 0)
  chnset(kMoveUp, "movefader")
endin

</CsInstruments>
<CsScore>
i 1 0 5
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 











<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="261" y="207" width="513" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>


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
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>28</x>
  <y>9</y>
  <width>205</width>
  <height>42</height>
  <uuid>{f6df122b-8c0c-4881-9ab1-8231ce732408}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>2. Run Csound !</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>84</r>
   <g>84</g>
   <b>84</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>movefader</objectName>
  <x>42</x>
  <y>59</y>
  <width>19</width>
  <height>151</height>
  <uuid>{97473a58-3afe-41e6-89b5-32fee930e624}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>movefader</objectName>
  <x>39</x>
  <y>236</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f9e76a39-a96a-4123-8d85-aeae35f1042b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>0</r>
   <g>170</g>
   <b>255</b>
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
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>82</x>
  <y>68</y>
  <width>122</width>
  <height>135</height>
  <uuid>{48e54cb9-ee21-4ae8-a4c1-7cce9b13b5c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>If you hover over a widget, a tooltip will appear displaying the channel, the widget is using.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>108</r>
   <g>108</g>
   <b>108</b>
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
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>37</x>
  <y>263</y>
  <width>163</width>
  <height>152</height>
  <uuid>{2a904b93-45cb-42af-9b9a-018f5eddd2d1}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Widgets with the same channel, alter each other! This can be used, to display the faders value, or make exact adjustments in a scrollnumber box with the mouse.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>94</r>
   <g>94</g>
   <b>94</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>movefader</objectName>
  <x>118</x>
  <y>388</y>
  <width>80</width>
  <height>25</height>
  <uuid>{01d6f97a-d9ea-4064-9d3f-ee588e34d384}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <value>0.00000000</value>
  <resolution>0.00010000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>999999999999.00000000</maximum>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>38</x>
  <y>216</y>
  <width>112</width>
  <height>21</height>
  <uuid>{9c8a2bf9-a45c-452d-bc3f-73b0a8ee5bb3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Display the value:</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>100</r>
   <g>100</g>
   <b>100</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

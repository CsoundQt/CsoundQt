<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; GoOSC is a sofware to send receive OSC data
; It is written in Qt so it runs on Symbian and Meego phones
; sourceforge.net/projects/goosc

giosc OSCinit 9002


opcode connectWidget, 0, SSi
Sname, Shost, iport xin
kval invalue Sname
ktrig changed kval

Spath sprintf "/%s", Sname
OSCsend ktrig, Shost, iport, Spath, "f", kval

kans OSClisten giosc,Spath, "f", kval
if (kans == 1) then
	outvalue Sname, kval
endif
endop

instr 1
Stext = {{ OSCSlider{x:50;y:350; width:250;height:60; min:0;max:1; val:0.5; channel:"/slider"; widgetColor:"#ffff00"; centered:false; defaultValue:0; showValue:false; displayDecimals:1; widgetid: "csound1";}
}}

OSCsend 1, "192.168.0.5", 9001, "/goosc/create", "s", Stext
turnoff
endin

instr 2

OSCsend 1, "192.168.0.5", 9001, "/goosc/delete", "s", "csound1"
turnoff
endin

instr 100 ; receive data
Sin = ""
kans OSClisten giosc, "/goosc/create", "s", Sin

if kans == 1 then
	outvalue "oscin", Sin
endif

Shost = "192.168.0.5"
iport = 9001

connectWidget "slider", Shost, iport
connectWidget "slider1", Shost, iport
connectWidget "slider2", Shost, iport
connectWidget "slider3", Shost, iport
connectWidget "button1", Shost, iport

endin

</CsInstruments>
<CsScore>
i 100 0 3600
</CsScore>
</CsoundSynthesizer>







<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>80</y>
 <width>398</width>
 <height>591</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>231</r>
  <g>46</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>slider1</objectName>
  <x>16</x>
  <y>408</y>
  <width>24</width>
  <height>125</height>
  <uuid>{e2b8a0f6-a4e8-497f-9796-31b14ed4e952}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.83999997</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>65</x>
  <y>18</y>
  <width>100</width>
  <height>30</height>
  <uuid>{bc763353-fcc0-4a50-98c9-63c2532f9560}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Create Slider</text>
  <image>/</image>
  <eventLine>i1 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>66</x>
  <y>56</y>
  <width>100</width>
  <height>30</height>
  <uuid>{8fdf09e9-52a5-4a2c-a2fe-2b354e8dde87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Delete Slider</text>
  <image>/</image>
  <eventLine>i2 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>oscin</objectName>
  <x>12</x>
  <y>161</y>
  <width>363</width>
  <height>238</height>
  <uuid>{dbed8d2a-49d5-44ba-862e-99f0552f32fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>OSCSlider{x:20;y:20; width:50;height:250; min:0;max:1; val:0.8399999737739563; channel:"/slider1"; widgetColor:"#ffff00"; centered:false; defaultValue:0; showValue:false; displayDecimals:1; }
</label>
  <alignment>left</alignment>
  <font>Inconsolata</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>slider</objectName>
  <x>17</x>
  <y>9</y>
  <width>20</width>
  <height>100</height>
  <uuid>{de68aa4f-9a56-4c91-bbe2-f12d8040d968}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.74800003</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>slider2</objectName>
  <x>47</x>
  <y>408</y>
  <width>24</width>
  <height>159</height>
  <uuid>{165b143b-c2c6-4da4-b4f5-0deb4bad4645}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.65625000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>slider3</objectName>
  <x>76</x>
  <y>408</y>
  <width>24</width>
  <height>187</height>
  <uuid>{32ff5537-1ad8-4ff1-9994-0eedc85d607e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.56216216</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>105</x>
  <y>407</y>
  <width>62</width>
  <height>57</height>
  <uuid>{7aa377e4-0dff-4014-96c1-1946eec2971b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Button</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>179</x>
  <y>18</y>
  <width>168</width>
  <height>69</height>
  <uuid>{9709bbcb-57e4-429a-b65b-fc7e38ad75e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1. You can create and delete widgets from the mobile device</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>9</x>
  <y>117</y>
  <width>364</width>
  <height>42</height>
  <uuid>{3f790bc7-b572-49e1-8ec7-2989da3c7fa0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2. You can receive the widget text from the mobile device</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>179</x>
  <y>409</y>
  <width>184</width>
  <height>152</height>
  <uuid>{d4da9390-87f8-4c5d-b011-14f3a9ca38c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3. Enter edit mode, select the widgets and run the python script to send them to the mobile device. The widgets will be automatically connected to the device.</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

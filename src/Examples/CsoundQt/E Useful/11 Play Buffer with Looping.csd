<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

/*****Playing a soundfile from a buffer for looping*****/
;written by joachim heintz and andrés cabrera
;mar 2009 / aug 2025

chn_S("_Browse",1)
chn_k("skip",1)
chn_k("loop",1)
chn_k("loop-start",1)
chn_k("loop-end",1)
chn_k("speed",1)
chn_k("dB",1)

instr Copy_file_to_table

	file:S = chnget("_Browse")  ;GUI input
	filelength@global:i = filelen(file)
	filenumchnls@global:i = filenchnls(file)
	// make sure that file exists
	if (filevalid(file) == 1) then
	  tablenum@global:i = ftgen(0,0,0,-1,file,0,0,0)
	else
	  puts("File does not exist!",1)
	endif

endin
schedule(Copy_file_to_table,0,0)

instr Play

  loopstart:k = chnget:k("loop-start") * filelength
  loopend:k = chnget:k("loop-end") * filelength
  speed:k = chnget("speed")
  amp:k = ampdb(chnget:k("dB"))
  // as flooper2 expects start < end we care for it
  // and allow the user to do anything
  startl:k = (loopstart < loopend) ? loopstart : loopend
  endl:k = (loopstart < loopend) ? loopend : loopstart
  // we also avoid to have start = end
  endl = (abs(startl-endl) < 1/16) ? endl+1/16 : endl
  // ensure mono or stereo both to work
  if (filenumchnls == 1) then
    aL = flooper2(amp,speed,startl,endl,.01,tablenum)
    aR = aL
  else
    aL,aR = flooper2(amp,speed,startl,endl,.01,tablenum)
  endif
  out(aL,aR)
  
endin

instr Stop

  turnoff2_i("Play",0,1)

endin
</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>409</x>
 <y>235</y>
 <width>460</width>
 <height>418</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>127</r>
  <g>170</g>
  <b>134</b>
 </bgcolor>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse</objectName>
  <x>15</x>
  <y>55</y>
  <width>298</width>
  <height>29</height>
  <uuid>{4b9ff4d6-f93b-471c-8d3b-8f94f2c6f948}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>ClassicalGuitar.wav</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse</objectName>
  <x>315</x>
  <y>55</y>
  <width>100</width>
  <height>30</height>
  <uuid>{0bec8b20-55d0-4e86-b558-e8464ce6530a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>ClassicalGuitar.wav</stringvalue>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b6499</objectName>
  <x>25</x>
  <y>100</y>
  <width>80</width>
  <height>30</height>
  <uuid>{25ac6f50-68b3-4f53-8b60-66f6a60801a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine>i "Play" 0 99999</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b3659</objectName>
  <x>24</x>
  <y>140</y>
  <width>80</width>
  <height>30</height>
  <uuid>{bf4f12d5-4d8b-471a-a52d-d37135249573}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine>i "Stop" 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>125</x>
  <y>95</y>
  <width>80</width>
  <height>29</height>
  <uuid>{c4ddb6ad-ce7a-4624-9959-0d8475b121ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>loop start</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>10</y>
  <width>430</width>
  <height>43</height>
  <uuid>{d51eabbc-9ac1-4400-bdce-abffa14335ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>PLAY SOUNDFILE FROM BUFFER: LOOPING</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>20</fontsize>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>20</x>
  <y>190</y>
  <width>397</width>
  <height>89</height>
  <uuid>{75ecdfe7-0ac2-433a-b89b-cc2270259ddb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>1.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>20</x>
  <y>275</y>
  <width>397</width>
  <height>89</height>
  <uuid>{440fb58b-dbb2-42db-9f4e-4f15331f5a18}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>2.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>210</x>
  <y>95</y>
  <width>80</width>
  <height>29</height>
  <uuid>{6933af53-e042-4083-917f-02e8d2560e60}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>loop end</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>loop-start</objectName>
  <x>120</x>
  <y>125</y>
  <width>80</width>
  <height>60</height>
  <uuid>{b31c9a3a-b30e-4a7a-b539-3dc9d4011256}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.16620000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>loop-end</objectName>
  <x>210</x>
  <y>125</y>
  <width>80</width>
  <height>60</height>
  <uuid>{b576d7a8-a881-4355-b188-f11b1ea7808d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.19990000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>295</x>
  <y>95</y>
  <width>80</width>
  <height>29</height>
  <uuid>{5af10635-b34b-43a2-b8fd-69d4a38efcab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>speed</description>
  <label>speed</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>speed</objectName>
  <x>295</x>
  <y>125</y>
  <width>80</width>
  <height>60</height>
  <uuid>{d876e2b4-2d8d-449d-af0d-4f57da448e54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.89960000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>380</x>
  <y>95</y>
  <width>40</width>
  <height>29</height>
  <uuid>{57044115-8a42-410c-919e-7f6d429b3846}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>speed</description>
  <label>dB</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>dB</objectName>
  <x>380</x>
  <y>125</y>
  <width>38</width>
  <height>33</height>
  <uuid>{d1eb6a83-81ce-45e5-a74e-2ee9a7538708}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>-40.00000000</minimum>
  <maximum>6.00000000</maximum>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act="continuous"/>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>

sr     = 44100
ksmps  = 128
nchnls = 2
0dbfs  = 1

/*****pvstencil simple*****/
; example for CsoundQt
; written by joachim heintz
; mai 2009

gifftsize = 1024
gitab ftgen 0, 0, gifftsize, 7, 1, gifftsize, 1  ; ftable just filled with 1

opcode TakeAll, a, Si
  ; don't care whether your sound is mono or stereo
  Sfil, iloop xin
  ichn filenchnls Sfil
  if ichn == 1 then
    aout diskin2 Sfil, 1, 0, iloop
  else  ; if stereo, just the first channel is taken
    aout, ano diskin2 Sfil, 1, 0, iloop
  endif
  xout aout
endop

instr 1
  Sfile invalue "_Browse1"
  asig TakeAll Sfile, 1  ; 1=loop, 0=no loop
  fsig pvsanal asig, gifftsize, gifftsize/4, gifftsize, 0
  klevel invalue "leveldb"
  fstencil pvstencil fsig, 0, ampdb(klevel), gitab
  aout pvsynth fstencil
  outs aout, aout
endin


</CsInstruments>
<CsScore>
i 1 0 999
e
</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>608</x>
 <y>212</y>
 <width>442</width>
 <height>354</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>188</r>
  <g>177</g>
  <b>148</b>
 </bgcolor>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse1</objectName>
  <x>13</x>
  <y>50</y>
  <width>295</width>
  <height>24</height>
  <uuid>{3ef56546-3859-4d35-9a8e-e49afa43c980}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.000</label>
  <instant>true</instant>
  <alignment>left</alignment>
  <font>Noto Sans</font>
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
  <background>nobackground</background>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse1</objectName>
  <x>313</x>
  <y>47</y>
  <width>100</width>
  <height>30</height>
  <uuid>{f65a18f9-f166-4be0-abc7-869a050cafdc}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>BratscheMono.wav</stringvalue>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>188</r>
   <g>177</g>
   <b>148</b>
  </color>
  <pressedColor/>
  <borderColor>#7d7663</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>18</x>
  <y>89</y>
  <width>384</width>
  <height>231</height>
  <uuid>{9679894d-ad89-4220-b5ee-cf5c5f5e746b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>        dB-limit for Binamps to pass</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>147</x>
  <y>137</y>
  <width>248</width>
  <height>155</height>
  <uuid>{3b712f67-5ab1-42fc-b918-20ec414d60e0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The opcode pvstencil offers many opportunities to mask the result of a fft-analysis before resynthesizing. In this simple case, you can select amplitudes of the fft-bins which are beyond a certain threshold.Â
For another application, see the Noise Reduction example.</label>
  <alignment>left</alignment>
  <valignment>bottom</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>14</x>
  <y>9</y>
  <width>398</width>
  <height>35</height>
  <uuid>{4df7df4d-05c2-4648-988f-11f640ee4779}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>pvstencil simple example</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>leveldb</objectName>
  <x>21</x>
  <y>97</y>
  <width>25</width>
  <height>210</height>
  <uuid>{3ca11a62-cebd-437a-9ed2-7d12be82426e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-100.00000000</minimum>
  <maximum>0.00000000</maximum>
  <value>-18.09523810</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>leveldb</objectName>
  <x>56</x>
  <y>118</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2f6de60d-3f52-4185-83a2-82d0c8a55dbe}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
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
  <resolution>0.10000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>0</maximum>
  <randomizable group="0">false</randomizable>
  <value>-18.0952</value>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;example for csoundqt
;joachim heintz nov 2011

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1


  opcode LpPhsr, a, kkkki
  ;see description at http://www.csounds.com/udo/displayOpcode.php?opcode_id=158

kloopstart, kloopend, kspeed, kdir, irefdur xin

kstart01   =            kloopstart/irefdur ;start in 0-1 range
kend01	    =	          kloopend/irefdur ;end in 0-1 range
ifqbas	    =	          1 / irefdur ;phasor frequency for the whole irefdur range
kfqrel	    =            ifqbas / (kend01-kstart01) * kspeed ;phasor frequency for the selected section
andxrel    phasor       kfqrel*kdir ;phasor 0-1 
atimpt     =	          andxrel * (kloopend-kloopstart) + kloopstart ;adjusted to start and end

           xout         atimpt
  
  endop


  instr 1
 ;receive the widget values
kloopstart invalue     "loopstart"
kloopend   invalue     "loopend"
kback      invalue     "back" ;1 = backwards
kspeed     invalue     "speed" ; 1 = normal
kpitch     invalue     "pitch" ; in semitones
kdb        invalue     "db" ;volume in db
klock      invalue     "lock" ;phase locking on/off
Snd        invalue     "_Browse" ;soundfile


 ;set general values
iftsnd     ftgen       0, 0, 0, 1, Snd, 0, 0, 1
isndlen    filelen     Snd
isndsr = ftsr(iftsnd)

chnset iftsnd, "wave"

kdir       =           (kback == 1 ? -1 : 1)
  ;set kloopend to isndlen if 0 or larger than isndlen
kloopend   =           (kloopend == 0 || kloopend > isndlen ? isndlen : kloopend)

atimpt     LpPhsr      kloopstart, kloopend, kspeed, kdir, isndlen

if metro(30) == 1 then
  kpos = k(atimpt)
  chnset k(atimpt) * isndsr, "wavecursor"
endif

 ;calculate audio and output result
asnd       mincer      atimpt, ampdb(kdb), semitone(kpitch), iftsnd, klock
           out         asnd
  endin


</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#aebfd1</bgcolor>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>loopstart</objectName>
  <x>15</x>
  <y>148</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3c04d57e-8f9a-4cb2-b045-3d9c288b1199}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>#000000</color>
  <bgcolor mode="background">#ffffff</bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.5</value>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>loopend</objectName>
  <x>116</x>
  <y>148</y>
  <width>80</width>
  <height>25</height>
  <uuid>{196f2bff-845d-4d87-b301-3f53f8c272ca}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>#000000</color>
  <bgcolor mode="background">#ffffff</bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>4</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>111</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5adeed74-95fd-4ed2-936f-911efaabe12a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>loop start</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>115</x>
  <y>111</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ad9c8d7d-9bbb-466a-86fb-38fbec6537bd}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>loop end</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>back</objectName>
  <x>243</x>
  <y>148</y>
  <width>20</width>
  <height>20</height>
  <uuid>{90e7e012-32e4-4423-8dc1-6143f35e2918}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <color>#c0d4e7</color>
  <borderColor>#6c7782</borderColor>
  <textColor>#31363b</textColor>
  <borderWidth>1</borderWidth>
  <borderRadius>0</borderRadius>
  <padding>5</padding>
  <checkstyle>x</checkstyle>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>213</x>
  <y>111</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5ba23af8-e23c-4c23-b63d-b2fd73f97ad3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>backwards</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>speed</objectName>
  <x>133</x>
  <y>188</y>
  <width>200</width>
  <height>28</height>
  <uuid>{9629f5cd-f9f3-427d-80ed-a655e0b45b14}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>4.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>speed</objectName>
  <x>335</x>
  <y>189</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b9cbc924-e76e-45b8-9f9b-da47c3a0e902}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>#000000</color>
  <bgcolor mode="background">#ffffff</bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.2</value>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>pitch</objectName>
  <x>133</x>
  <y>224</y>
  <width>200</width>
  <height>28</height>
  <uuid>{cd230787-9b99-48bf-af84-b0b7dafb12d6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-24.00000000</minimum>
  <maximum>24.00000000</maximum>
  <value>-2.64000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>pitch</objectName>
  <x>335</x>
  <y>224</y>
  <width>80</width>
  <height>25</height>
  <uuid>{40522c26-35ea-4584-a9ab-493849b0e2d0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>#000000</color>
  <bgcolor mode="background">#ffffff</bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>-2.64</value>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>db</objectName>
  <x>133</x>
  <y>262</y>
  <width>200</width>
  <height>26</height>
  <uuid>{06d78383-e5a1-4edd-8ce7-a3e0f030e99d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-24.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>-3.12000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>db</objectName>
  <x>335</x>
  <y>261</y>
  <width>80</width>
  <height>25</height>
  <uuid>{846d6d51-4a7f-4baa-89e6-e8b3ab82988d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>#000000</color>
  <bgcolor mode="background">#ffffff</bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>-3.12</value>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>lock</objectName>
  <x>357</x>
  <y>148</y>
  <width>20</width>
  <height>20</height>
  <uuid>{7a28f302-916e-4246-a512-a38404dc7ea2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <color>#c0d4e7</color>
  <borderColor>#6c7782</borderColor>
  <textColor>#31363b</textColor>
  <borderWidth>1</borderWidth>
  <borderRadius>0</borderRadius>
  <padding>5</padding>
  <checkstyle>x</checkstyle>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>332</x>
  <y>111</y>
  <width>80</width>
  <height>25</height>
  <uuid>{505cc402-7701-4e89-8f6e-f56bb80d73f0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>phase lock</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>14</y>
  <width>399</width>
  <height>36</height>
  <uuid>{6a409679-366b-43ea-8021-31cd74a0b944}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>LOOPING WITH MINCER</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse</objectName>
  <x>15</x>
  <y>61</y>
  <width>396</width>
  <height>32</height>
  <uuid>{50508683-2963-48bd-a067-ea2d824403f2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/em/Lib/snd/samples/speech/colours-german-male-1.flac</stringvalue>
  <text>Browse Soundfile First!</text>
  <image>../../../../../../../../../</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <font>Liberation Sans</font>
  <flatStyle>true</flatStyle>
  <color>#c0d4e7</color>
  <pressedColor>#31363b</pressedColor>
  <borderColor>#83919e</borderColor>
  <textColor>#31363b</textColor>
  <pressedTextColor>#ffffff</pressedTextColor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>188</y>
  <width>120</width>
  <height>27</height>
  <uuid>{423a136a-eb64-4cb7-88ba-44a85c811ec2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>speed</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>224</y>
  <width>120</width>
  <height>29</height>
  <uuid>{400f5c3f-9f72-452e-87b5-69da3b0f0534}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>transposition (semitones)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>262</y>
  <width>120</width>
  <height>29</height>
  <uuid>{38c02e0e-3f48-4494-8245-a0464ea9f2d0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>volume</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBWaveform" version="2">
  <objectName>wave</objectName>
  <x>15</x>
  <y>315</y>
  <width>800</width>
  <height>160</height>
  <uuid>{2490dcb8-ef75-415d-9596-e73e89aa3020}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>101</value>
  <objectName2>wavecursor</objectName2>
  <cursor>47628</cursor>
  <color>#50c8ff</color>
  <bgcolor>#181818</bgcolor>
  <bgcolormode>true</bgcolormode>
  <cursorcolor>#ff9600</cursorcolor>
  <showGrid>false</showGrid>
  <showAxes>true</showAxes>
  <autoRange>true</autoRange>
  <channels>0</channels>
  <range>1.000000</range>
  <zoom>1.000000</zoom>
  <offset>0</offset>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

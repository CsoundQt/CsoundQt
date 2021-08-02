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
kdir       =           (kback == 1 ? -1 : 1)
  ;set kloopend to isndlen if 0 or larger than isndlen
kloopend   =           (kloopend == 0 || kloopend > isndlen ? isndlen : kloopend)

atimpt     LpPhsr      kloopstart, kloopend, kspeed, kdir, isndlen

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
 <bgcolor mode="nobackground">
  <r>220</r>
  <g>214</g>
  <b>207</b>
 </bgcolor>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>loopstart</objectName>
  <x>49</x>
  <y>149</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3c04d57e-8f9a-4cb2-b045-3d9c288b1199}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>loopend</objectName>
  <x>147</x>
  <y>149</y>
  <width>80</width>
  <height>25</height>
  <uuid>{196f2bff-845d-4d87-b301-3f53f8c272ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>48</x>
  <y>112</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5adeed74-95fd-4ed2-936f-911efaabe12a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>loop start</label>
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
  <x>146</x>
  <y>112</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ad9c8d7d-9bbb-466a-86fb-38fbec6537bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>loop end</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>back</objectName>
  <x>274</x>
  <y>149</y>
  <width>20</width>
  <height>20</height>
  <uuid>{90e7e012-32e4-4423-8dc1-6143f35e2918}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>244</x>
  <y>112</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5ba23af8-e23c-4c23-b63d-b2fd73f97ad3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>backwards</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>speed</objectName>
  <x>94</x>
  <y>189</y>
  <width>269</width>
  <height>28</height>
  <uuid>{9629f5cd-f9f3-427d-80ed-a655e0b45b14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>4.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>speed</objectName>
  <x>362</x>
  <y>190</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b9cbc924-e76e-45b8-9f9b-da47c3a0e902}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>pitch</objectName>
  <x>204</x>
  <y>225</y>
  <width>159</width>
  <height>28</height>
  <uuid>{cd230787-9b99-48bf-af84-b0b7dafb12d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-24.00000000</minimum>
  <maximum>24.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>pitch</objectName>
  <x>362</x>
  <y>225</y>
  <width>80</width>
  <height>25</height>
  <uuid>{40522c26-35ea-4584-a9ab-493849b0e2d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>db</objectName>
  <x>103</x>
  <y>263</y>
  <width>260</width>
  <height>26</height>
  <uuid>{06d78383-e5a1-4edd-8ce7-a3e0f030e99d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-24.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>-3.92565056</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>db</objectName>
  <x>362</x>
  <y>262</y>
  <width>80</width>
  <height>25</height>
  <uuid>{846d6d51-4a7f-4baa-89e6-e8b3ab82988d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>-3.92565</value>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>lock</objectName>
  <x>388</x>
  <y>149</y>
  <width>20</width>
  <height>20</height>
  <uuid>{7a28f302-916e-4246-a512-a38404dc7ea2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>363</x>
  <y>112</y>
  <width>80</width>
  <height>25</height>
  <uuid>{505cc402-7701-4e89-8f6e-f56bb80d73f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>phase lock</label>
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
  <x>47</x>
  <y>15</y>
  <width>399</width>
  <height>36</height>
  <uuid>{6a409679-366b-43ea-8021-31cd74a0b944}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LOOPING WITH MINCER</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>24</fontsize>
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
  <objectName>_Browse</objectName>
  <x>48</x>
  <y>62</y>
  <width>396</width>
  <height>32</height>
  <uuid>{50508683-2963-48bd-a067-ea2d824403f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Joachim/Csound/Hui/fox.wav</stringvalue>
  <text>Browse Soundfile First!</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>46</x>
  <y>189</y>
  <width>50</width>
  <height>27</height>
  <uuid>{423a136a-eb64-4cb7-88ba-44a85c811ec2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>speed</label>
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
  <x>46</x>
  <y>225</y>
  <width>160</width>
  <height>29</height>
  <uuid>{400f5c3f-9f72-452e-87b5-69da3b0f0534}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>transposition (semitones)</label>
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
  <x>46</x>
  <y>263</y>
  <width>57</width>
  <height>29</height>
  <uuid>{38c02e0e-3f48-4494-8245-a0464ea9f2d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>volume</label>
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

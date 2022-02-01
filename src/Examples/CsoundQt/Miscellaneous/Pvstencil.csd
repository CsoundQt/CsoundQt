<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

/*****pvstencil simple*****/
;example for CsoundQt
;written by joachim heintz
;mai 2009

gifftsize	=		1024
gitab		ftgen		0, 0, gifftsize, 7, 1, gifftsize, 1; ftable just filled with 1

  opcode TakeAll, a, Si
;don't care whether your sound is mono or stereo
Sfil, iloop	xin
ichn		filenchnls	Sfil
if ichn == 1 then
aout		diskin2	Sfil, 1, 0, iloop
else ;if stereo, just the first channel is taken
aout, ano	diskin2	Sfil, 1, 0, iloop
endif
		xout		aout
  endop

instr 1
Sfile		invalue	"_Browse1"
asig		TakeAll	Sfile, 1; 1=loop, 0=no loop
fsig		pvsanal	asig, gifftsize, gifftsize/4, gifftsize, 0
klevel		invalue	"level"
fstencil	pvstencil	fsig, 0, klevel, gitab
aout		pvsynth	fstencil
		outs		aout, aout
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>13</x>
  <y>50</y>
  <width>295</width>
  <height>24</height>
  <uuid>{3ef56546-3859-4d35-9a8e-e49afa43c980}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <font>Noto Sans</font>
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
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>313</x>
  <y>47</y>
  <width>100</width>
  <height>30</height>
  <uuid>{f65a18f9-f166-4be0-abc7-869a050cafdc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>18</x>
  <y>89</y>
  <width>213</width>
  <height>224</height>
  <uuid>{9679894d-ad89-4220-b5ee-cf5c5f5e746b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Limit for Binamps to pass</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>248</x>
  <y>93</y>
  <width>166</width>
  <height>201</height>
  <uuid>{3b712f67-5ab1-42fc-b918-20ec414d60e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The opcode pvstencil gives you many opportunities to mask the result of a fft-analysis before resynthesizing. In this simple case, you can select amplitudes of the fft-bins which are beyond a certain threshold.Â
For another application, see the Noise Reduction example.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>9</y>
  <width>398</width>
  <height>35</height>
  <uuid>{4df7df4d-05c2-4648-988f-11f640ee4779}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>pvstencil simple example</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>22</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>level</objectName>
  <x>24</x>
  <y>96</y>
  <width>25</width>
  <height>210</height>
  <uuid>{3ca11a62-cebd-437a-9ed2-7d12be82426e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.30000000</maximum>
  <value>0.02142900</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>level</objectName>
  <x>62</x>
  <y>273</y>
  <width>57</width>
  <height>26</height>
  <uuid>{ea408eaa-c537-4dba-be96-c41a3f989077}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.0223</label>
  <alignment>right</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>57</x>
  <y>121</y>
  <width>160</width>
  <height>118</height>
  <uuid>{b2f7b491-6ae9-49e8-9383-9653bd75aaf4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>(According to your sound you may want to change the upper limit in the Properties dialog)</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

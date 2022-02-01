<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2	
0dbfs = 1

/*****Simple convolution*****/
;example for CsoundQt
;written by joachim heintz
;apr 2009 / jan 2022
;using the code from matt ingalls (manual for pconvolve)
;please send bug reports and suggestions
;to jh at joachimheintz.de

//output display in CsoundQt
opcode CsQtMeter, 0, SSak
 S_chan_sig, S_chan_over, aSig, kTrig	xin
 iDbRange = 60 ;shows 60 dB
 iHoldTim = 1 ;seconds to "hold the red light"
 kOn init 0
 kTim init 0
 kStart init 0
 kEnd init 0
 kMax max_k aSig, kTrig, 1
 if kTrig == 1 then
  chnset (iDbRange + dbfsamp(kMax)) / iDbRange, S_chan_sig
  if kOn == 0 && kMax > 1 then
   kTim = 0
   kEnd = iHoldTim
   chnset k(1), S_chan_over
   kOn = 1
  endif
  if kOn == 1 && kTim > kEnd then
   chnset k(0), S_chan_over
   kOn =	0
  endif
 endif
 kTim += ksmps/sr
endop

;declare software channels
chn_k "outL", 2
chn_k "outL_clip", 2
chn_k "outR", 2
chn_k "outR_clip", 2
chn_S "_Browse1", 1
chn_S "_Browse2", 1
chn_k "wdmix", 1
chn_k "gaindb", 1


instr 1
Sfile		chnget	"_Browse1"
Simpulse	chnget	"_Browse2"
kwdmix		chnget	"wdmix"
kgaindb		chnget	"gaindb"
ilenfil	filelen	Sfile
ilenimp	filelen	Simpulse
inchnfil	filenchnls	Sfile
inchnimp	filenchnls	Simpulse
ipart		=		2048; partitionsize (see manual page for pconvolve)

kwet		=		kwdmix
kdry		=		1 - kwdmix
idur		=		ilenfil + ilenimp; overall duration
p3		=		idur
kgain = ampdb(kgaindb)

  ; for the following see the example from matt ingalls in the csound manual (pconvolve)
idel		=		(ksmps < ipart ? ipart + ksmps : ipart) / sr; delay introduced by pconvolve
kcount		init		idel * kr
loop:
  if inchnfil == 1 then	;soundfile mono
a1		soundin	Sfile
a2		=		a1
  else				;soundfile stereo
a1, a2		soundin	Sfile
  endif
  if inchnimp == 1 then	;impulsefile mono
awetL	  	pconvolve  	kwet * a1, Simpulse, ipart, 1
awetR	  	pconvolve  	kwet * a2, Simpulse, ipart, 1
  else				;impulsefile stereo
awetL	  	pconvolve  	kwet * a1, Simpulse, ipart, 1
awetR	  	pconvolve  	kwet * a2, Simpulse, ipart, 2
  endif

adryL		delay		kdry * a1, idel
adryR		delay		kdry * a2, idel

kcount		-=		1
  if kcount > 0 kgoto loop

  aL = (awetL + adryL) * kgain
  aR = (awetR + adryR) * kgain
		outs		aL, aR
		
	kTrigDisp metro 10
 CsQtMeter "outL", "outL_over", aL, kTrigDisp
 CsQtMeter "outR", "outR_over", aR, kTrigDisp

endin

</CsInstruments>
<CsScore>
i 1 0 1; plays the whole soundfile
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>669</x>
 <y>224</y>
 <width>460</width>
 <height>389</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>13</x>
  <y>107</y>
  <width>387</width>
  <height>25</height>
  <uuid>{bdb69a5f-4670-41f7-b175-539bc300af19}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>fox.wav</label>
  <alignment>left</alignment>
  <font>Bitstream Vera Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>239</r>
   <g>239</g>
   <b>239</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>98</x>
  <y>73</y>
  <width>226</width>
  <height>29</height>
  <uuid>{ea11a81d-0041-46eb-8d6c-cb10f732f6ff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>fox.wav</stringvalue>
  <text>Browse Soundfile</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>17</x>
  <y>19</y>
  <width>398</width>
  <height>43</height>
  <uuid>{612a67ea-cd5d-4277-a43a-5528190eca4d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>SIMPLE CONVOLUTION</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>26</fontsize>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse2</objectName>
  <x>14</x>
  <y>178</y>
  <width>387</width>
  <height>25</height>
  <uuid>{1fc9a97c-9593-4cc3-92d9-53cc3eaa15d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>impulse_big_hall.wav</label>
  <alignment>left</alignment>
  <font>Bitstream Vera Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>239</r>
   <g>239</g>
   <b>239</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse2</objectName>
  <x>99</x>
  <y>140</y>
  <width>229</width>
  <height>31</height>
  <uuid>{9024b704-1968-4308-a103-455699b9ffb6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>impulse_big_hall.wav</stringvalue>
  <text>Browse Impulse Response File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>wdmix</objectName>
  <x>67</x>
  <y>253</y>
  <width>282</width>
  <height>29</height>
  <uuid>{70d19d35-4ef8-49be-834d-610194e347bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.39007092</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>145</x>
  <y>215</y>
  <width>130</width>
  <height>30</height>
  <uuid>{7826f399-c364-4e8f-9adc-e86168c42052}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Wet-Dry Mix</label>
  <alignment>center</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>27</x>
  <y>253</y>
  <width>34</width>
  <height>27</height>
  <uuid>{173448ab-eeab-471d-b461-fbb89d17b4ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Dry</label>
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
  <x>356</x>
  <y>254</y>
  <width>34</width>
  <height>27</height>
  <uuid>{9e0638ae-57cf-415f-8cf2-de5b6dfd4eb5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Wet</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>outL</objectName>
  <x>2</x>
  <y>289</y>
  <width>225</width>
  <height>20</height>
  <uuid>{56692e84-8339-4713-bedf-b81a5d5dea6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>outL</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.87634494</xValue>
  <yValue>0.87634494</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>outL_clip</objectName>
  <x>221</x>
  <y>289</y>
  <width>25</width>
  <height>20</height>
  <uuid>{9dbc1525-61ed-4dcc-aeb3-650eb87744db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>outL_clip</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>outR</objectName>
  <x>2</x>
  <y>315</y>
  <width>225</width>
  <height>20</height>
  <uuid>{09a3dabb-c32b-4652-b07c-a5149e90b11b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>outR</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.80310404</xValue>
  <yValue>0.80310404</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>outR_clip</objectName>
  <x>221</x>
  <y>315</y>
  <width>25</width>
  <height>20</height>
  <uuid>{d515ef65-7c19-46c4-a888-c5cbc4e5653c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>outR_clip</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>gaindb</objectName>
  <x>258</x>
  <y>313</y>
  <width>176</width>
  <height>24</height>
  <uuid>{4d42ff3b-ba28-463f-aaf0-ef8905f4facc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-30.00000000</minimum>
  <maximum>0.00000000</maximum>
  <value>-8.35227273</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>258</x>
  <y>286</y>
  <width>45</width>
  <height>26</height>
  <uuid>{eccfbfa8-ba49-4ac2-94c3-9d70d1db6028}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Gain</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>388</x>
  <y>285</y>
  <width>45</width>
  <height>26</height>
  <uuid>{8b5b92dc-f58e-406e-8262-b117e1a70803}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>gaindb</objectName>
  <x>305</x>
  <y>286</y>
  <width>80</width>
  <height>25</height>
  <uuid>{126c55f6-ba72-4d42-a3f5-7bf36e0a8269}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>-8.352</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

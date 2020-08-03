<CsoundSynthesizer>
<CsOptions>
-m128
</CsOptions>
<CsInstruments>

/*
IMPULSE RESPONSE GENERATOR
written by joachim heintz, august 2020
based on code of Steven Yi
*/

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

chn_S "_Browse", 1
chn_k "play", 1
chn_k "voldb", 1
chn_k "wdmix", 1
chn_k "dur", 1
chn_k "curve", 1
chn_k "beta", 1
chn_k "q", 1
chn_k "outL", 2
chn_k "outR", 2
chn_k "clipL", 2
chn_k "clipR", 2

opcode CreateIR, aa, SSS
 SBeta, SCurve, SQ xin
 aNoiseL = noise(1, chnget:k(SBeta))
 aNoiseR = noise(1, chnget:k(SBeta))
 iCurve = chnget:i(SCurve)
 kEnv = transeg:k(ampdb(-18), p3, iCurve, 0)
 iFreqMin = 20
 iFreqMax = 12000
 kMidiLine line ftom:i(iFreqMax), p3, ftom:i(iFreqMin)
 aL zdf_2pole aNoiseL*kEnv, mtof(kMidiLine), chnget:k(SQ)
 aR zdf_2pole aNoiseR*kEnv, mtof(kMidiLine), chnget:k(SQ)
 xout aL, aR 
endop

opcode PlaySnd, aa, S
 Sfile xin
 if filenchnls(Sfile)==2 then
  aL, aR diskin Sfile, 1, 0, 1
 else
  aL diskin Sfile, 1, 0, 1
  aR = aL
 endif
 xout aL, aR
endop

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

giSineQuart ftgen 0, 0, 8193, 9, 1/4, 1, 0

instr Listen
 p3 = chnget:i("dur")
 aL, aR CreateIR "beta", "curve", "q"
 out aL*6, aR*6
endin

instr WriteOut
 S_outname = sprintf("%s/imp.wav", pwd())
 p3 = chnget:i("dur")
 kIndx = 0
 while kIndx < p3*kr do
  aL, aR CreateIR "beta", "curve", "q"
  fout S_outname, 16, aL, aR
  kIndx += 1
 od
 printf "New Impulse Response written.\n", 1
 turnoff
endin

instr Playback
 Sfile = chnget:S("_Browse")
 aDryL, aDryR PlaySnd Sfile
 aWetL pconvolve aDryL, "imp.wav", 1024, 1
 aWetR pconvolve aDryR, "imp.wav", 1024, 2
 kWdMix = chnget:k("wdmix")
 kVol = ampdb(chnget:k("voldb"))
 kDry = table:k(1-kWdMix,giSineQuart,1) * kVol
 kWet = table:k(kWdMix,giSineQuart,1) * kVol
 aL = aDryL*kDry + aWetL*kWet
 aR = aDryR*kDry + aWetR*kWet
 out aL, aR
endin

instr Run
 kPlay chnget "play"
 if changed(kPlay)==1 then
  if kPlay==1 then
   schedulek("Playback",0,-1)
  else
   schedulek(-nstrnum("Playback"),0,0)
  endif
 endif
 kTrig metro 10
 aL, aR monitor
 CsQtMeter("outL", "clipL", aL, kTrig)
 CsQtMeter("outR", "clipR", aR, kTrig)
endin
schedule("Run",0,-1)


</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1040</x>
 <y>192</y>
 <width>652</width>
 <height>432</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>233</r>
  <g>185</g>
  <b>110</b>
 </bgcolor>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse</objectName>
  <x>415</x>
  <y>129</y>
  <width>124</width>
  <height>33</height>
  <uuid>{b8ccf304-3502-4897-953e-401266caaa47}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/media/jh/Daten/Joachim/Csound/Hui/fox.wav</stringvalue>
  <text>Open File</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>51</x>
  <y>79</y>
  <width>220</width>
  <height>36</height>
  <uuid>{78d6f7f8-43d3-469c-97b8-a86fe9144d8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Generate IR</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>65</x>
  <y>124</y>
  <width>82</width>
  <height>33</height>
  <uuid>{62bb7b54-093d-4892-a684-65c92556f17d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Duration</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
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
  <x>63</x>
  <y>162</y>
  <width>106</width>
  <height>31</height>
  <uuid>{805a8d92-e4a5-425c-85f4-84df0d507493}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Curve</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
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
  <x>62</x>
  <y>242</y>
  <width>106</width>
  <height>31</height>
  <uuid>{4f34fa28-fabb-4ac5-b0e1-8fed507fbfc0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Filter Q</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
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
 <bsbObject type="BSBButton" version="2">
  <objectName/>
  <x>65</x>
  <y>290</y>
  <width>186</width>
  <height>37</height>
  <uuid>{64071d2c-d862-4ce2-b173-dabe53fdc340}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Listen</text>
  <image>/</image>
  <eventLine>i "Listen" 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName/>
  <x>65</x>
  <y>337</y>
  <width>186</width>
  <height>37</height>
  <uuid>{a01472f5-024e-46b4-9dff-bbe5e7f8b260}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Write Out</text>
  <image>/</image>
  <eventLine>i "WriteOut" 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>358</x>
  <y>80</y>
  <width>222</width>
  <height>37</height>
  <uuid>{282c3345-b0a6-455f-a61e-4ba708a87fea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Apply to Sound</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>play</objectName>
  <x>382</x>
  <y>170</y>
  <width>186</width>
  <height>37</height>
  <uuid>{7c67d121-2e99-4cb9-beb8-9713ca130e3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Start / Stop</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
  <fontsize>14</fontsize>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>dur</objectName>
  <x>162</x>
  <y>125</y>
  <width>91</width>
  <height>29</height>
  <uuid>{42b969dd-827f-4d4c-b8fc-4dbec755bfb4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
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
  <minimum>0.001</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>curve</objectName>
  <x>163</x>
  <y>164</y>
  <width>91</width>
  <height>29</height>
  <uuid>{0c9a6bce-e4ab-404a-ba52-5fbbbde09167}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
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
  <resolution>0.10000000</resolution>
  <minimum>-10</minimum>
  <maximum>10</maximum>
  <randomizable group="0">false</randomizable>
  <value>-6</value>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>q</objectName>
  <x>162</x>
  <y>243</y>
  <width>91</width>
  <height>29</height>
  <uuid>{02bf057b-f5e2-4536-9ffe-7667da55d6ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
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
  <resolution>0.10000000</resolution>
  <minimum>0.1</minimum>
  <maximum>10</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.3</value>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>voldb</objectName>
  <x>448</x>
  <y>222</y>
  <width>129</width>
  <height>33</height>
  <uuid>{562d5625-5f10-47cf-8cfd-c4ca8feb2cba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-50.00000000</minimum>
  <maximum>0.00000000</maximum>
  <value>-17.44186047</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>359</x>
  <y>221</y>
  <width>82</width>
  <height>33</height>
  <uuid>{f9e2fa9c-23a7-471f-aca5-cfc7d3e777c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Volume</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>wdmix</objectName>
  <x>447</x>
  <y>261</y>
  <width>129</width>
  <height>33</height>
  <uuid>{9ab09a6f-0459-4efd-aa47-79f8fdc500f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.12403101</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>338</x>
  <y>261</y>
  <width>105</width>
  <height>30</height>
  <uuid>{f282be56-b4a1-41aa-ba33-392d5cd3c307}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Dry/Wet Mix</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
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
  <x>51</x>
  <y>10</y>
  <width>535</width>
  <height>55</height>
  <uuid>{42c556c3-9814-4d23-bc8e-beda3d7be18a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Impulse Response Generator</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>30</fontsize>
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
 <bsbObject type="BSBController" version="2">
  <objectName>outL</objectName>
  <x>325</x>
  <y>301</y>
  <width>239</width>
  <height>19</height>
  <uuid>{133bd5e9-655f-4ba7-895d-45c9c8e54eb3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>outL</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.65805605</xValue>
  <yValue>0.65805605</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
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
 <bsbObject type="BSBController" version="2">
  <objectName>clipL</objectName>
  <x>560</x>
  <y>301</y>
  <width>27</width>
  <height>19</height>
  <uuid>{dc5f0c73-a680-4e93-9855-6706fbd5180d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>clipL</objectName2>
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
 <bsbObject type="BSBController" version="2">
  <objectName>outR</objectName>
  <x>325</x>
  <y>328</y>
  <width>239</width>
  <height>19</height>
  <uuid>{c9df7174-1b36-402f-b019-2ace9894d188}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>outR</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.62888056</xValue>
  <yValue>0.62888056</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
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
 <bsbObject type="BSBController" version="2">
  <objectName>clipR</objectName>
  <x>560</x>
  <y>328</y>
  <width>27</width>
  <height>19</height>
  <uuid>{4f920b21-ea12-4ece-a4e5-01d922fccc89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>clipR</objectName2>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>beta</objectName>
  <x>160</x>
  <y>201</y>
  <width>91</width>
  <height>29</height>
  <uuid>{393a2fcd-5942-4be0-945e-63b2d447dbfe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
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
  <resolution>0.01000000</resolution>
  <minimum>0</minimum>
  <maximum>0.99</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.8</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>61</x>
  <y>201</y>
  <width>109</width>
  <height>31</height>
  <uuid>{6cc3ac03-1544-406b-b980-f3151b991a6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Noise Color</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1


; Note that wdgets transmit values between themselves
; even when Csound is not running

instr 1
kfreq invalue "freq"
kamp invalue "amp"
kx oscil 0.4*kamp, kfreq*2, 1
ky oscil 0.4*kamp, kfreq*2, 1, 0.25
outvalue "x", kx + 0.5
outvalue "y", ky + 0.5
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600
</CsScore>
</CsoundSynthesizer>













<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>326</x>
 <y>108</y>
 <width>736</width>
 <height>639</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>353</x>
  <y>373</y>
  <width>369</width>
  <height>257</height>
  <uuid>{8310d23a-8657-4223-9efb-b2c9b1f46b03}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input and output</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>53</x>
  <y>3</y>
  <width>265</width>
  <height>42</height>
  <uuid>{5bdc92b0-c72c-4fcb-9fc6-2b26d6b5cdf2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Controller Widget</label>
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
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>40</y>
  <width>339</width>
  <height>85</height>
  <uuid>{8033ef83-4eaf-440b-9584-cf062a5923a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Controller widgets are widgets that can be used to produce data from mouse movements. Some controllers can send only one value but others can send horizontal and vertical values. You can set the range of the controller in the preferences.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>134</y>
  <width>160</width>
  <height>168</height>
  <uuid>{d215665b-e569-4b9e-9fc7-3708a0dbeb14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>'fill' controller</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>18</x>
  <y>157</y>
  <width>22</width>
  <height>136</height>
  <uuid>{d6699db1-0924-45c7-a175-b8dc3e3cffd6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>fillvert</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.52941176</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>181</r>
   <g>234</g>
   <b>152</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>fillhor</objectName>
  <x>45</x>
  <y>158</y>
  <width>114</width>
  <height>25</height>
  <uuid>{ec82338a-a697-4290-8a72-714db2f81c79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55263158</xValue>
  <yValue>0.71052632</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>120</r>
   <g>234</g>
   <b>187</b>
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
  <x>47</x>
  <y>186</y>
  <width>111</width>
  <height>46</height>
  <uuid>{96c39df8-15e3-4aef-9591-6802dae9b50e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Fill controllers are just like sliders.</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>46</x>
  <y>235</y>
  <width>112</width>
  <height>26</height>
  <uuid>{422f6796-2317-4846-8a8b-13ca3d6006b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Horizontal</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>fillhor</objectName>
  <x>103</x>
  <y>236</y>
  <width>52</width>
  <height>22</height>
  <uuid>{0e6de40f-0aae-4d04-ba09-f2618f28e029}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.553</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>46</x>
  <y>266</y>
  <width>112</width>
  <height>25</height>
  <uuid>{96187497-6e0c-4c3b-87b5-273e316c14b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Vertical</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>fillvert</objectName>
  <x>98</x>
  <y>267</y>
  <width>53</width>
  <height>23</height>
  <uuid>{36536070-7005-41ad-9918-7651aed51dd3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.500</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>184</x>
  <y>135</y>
  <width>160</width>
  <height>168</height>
  <uuid>{d757dd66-9956-49e3-a9b3-a6553f6d0aa4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>'llif' controller</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>191</x>
  <y>159</y>
  <width>22</width>
  <height>136</height>
  <uuid>{33be0854-e529-4a59-baee-f49249bdd580}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>llifvert</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.37500000</xValue>
  <yValue>0.40441176</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>162</r>
   <g>199</g>
   <b>234</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>llifhor</objectName>
  <x>218</x>
  <y>160</y>
  <width>113</width>
  <height>17</height>
  <uuid>{a0f7059d-bd95-4908-9b2e-a828dab6427e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.46017699</xValue>
  <yValue>0.39823009</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>56</r>
   <g>234</g>
   <b>228</b>
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
  <x>218</x>
  <y>179</y>
  <width>115</width>
  <height>55</height>
  <uuid>{d776d5b3-f81b-44be-a7c3-7dd42fbac5f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Llif controllers are inverted fill controllers</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>219</x>
  <y>238</y>
  <width>112</width>
  <height>26</height>
  <uuid>{ba2e6d94-ea2b-4d0b-86e2-32bb309f7e8d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Horizontal</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>llifhor</objectName>
  <x>276</x>
  <y>239</y>
  <width>52</width>
  <height>22</height>
  <uuid>{9ec5b748-459d-4a59-a9c0-2eb0f2a152c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.460</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>220</x>
  <y>269</y>
  <width>112</width>
  <height>25</height>
  <uuid>{95d58265-3539-4595-917d-6c7d35772666}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Vertical</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>llifvert</objectName>
  <x>271</x>
  <y>270</y>
  <width>53</width>
  <height>23</height>
  <uuid>{b291988b-552f-40ac-8827-f5abe43c383b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.404</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>10</x>
  <y>307</y>
  <width>158</width>
  <height>111</height>
  <uuid>{5312b9e8-b39f-4e23-a7b7-59cb9892d9e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>'line' controller</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>14</x>
  <y>329</y>
  <width>49</width>
  <height>80</height>
  <uuid>{68007db4-c113-4952-8e22-0dba146ee98c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>linevert</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.62500000</xValue>
  <yValue>0.50000000</yValue>
  <type>line</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
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
  <x>65</x>
  <y>330</y>
  <width>97</width>
  <height>50</height>
  <uuid>{3d0b86b6-7100-4e5d-af42-0eedca472ec2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Line controllers are unfilled.</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>65</x>
  <y>384</y>
  <width>93</width>
  <height>25</height>
  <uuid>{c03753be-1e49-41fe-84e9-513855ffff27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Vertical</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>linevert</objectName>
  <x>110</x>
  <y>385</y>
  <width>53</width>
  <height>23</height>
  <uuid>{4aa45c29-93bb-49bf-94d3-9c96fdeb91ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.500</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>174</x>
  <y>308</y>
  <width>173</width>
  <height>203</height>
  <uuid>{682a0860-0092-4407-b3af-1d7136c5fc4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>'crosshair' controller</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>crossx</objectName>
  <x>178</x>
  <y>329</y>
  <width>164</width>
  <height>116</height>
  <uuid>{1f10b659-18f2-4fee-be18-07e821cbd826}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>crossy</objectName2>
  <xMin>-1.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>-1.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.56097561</xValue>
  <yValue>0.53448276</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>170</r>
   <g>85</g>
   <b>255</b>
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
  <x>183</x>
  <y>450</y>
  <width>83</width>
  <height>25</height>
  <uuid>{38db9e15-fa6f-451c-a3ab-399a0a9b8700}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>X =</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>crossx</objectName>
  <x>209</x>
  <y>451</y>
  <width>52</width>
  <height>22</height>
  <uuid>{8962fe20-2486-4c54-96d2-6d6de8434e87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.561</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>183</x>
  <y>480</y>
  <width>88</width>
  <height>25</height>
  <uuid>{377df814-9d21-46c6-9d08-ded5e14a1f1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Y =</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>crossy</objectName>
  <x>208</x>
  <y>481</y>
  <width>53</width>
  <height>23</height>
  <uuid>{049ca916-c918-4693-86aa-c09ec3a3a4e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.534</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>12</x>
  <y>424</y>
  <width>158</width>
  <height>206</height>
  <uuid>{15021657-80aa-4691-ac05-02328cad5949}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>'point' controller</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>pointx</objectName>
  <x>16</x>
  <y>445</y>
  <width>148</width>
  <height>105</height>
  <uuid>{37ce3594-1408-4256-b55b-4ee0e24265f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>pointy</objectName2>
  <xMin>-1.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>-1.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45945946</xValue>
  <yValue>0.52380952</yValue>
  <type>point</type>
  <pointsize>4</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>47</x>
  <y>556</y>
  <width>83</width>
  <height>25</height>
  <uuid>{ae97e997-3bcb-4e22-97d2-db289b9ac36d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>X =</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>pointx</objectName>
  <x>72</x>
  <y>557</y>
  <width>52</width>
  <height>22</height>
  <uuid>{f5f70eb4-1d78-4f1b-8e91-e4813770201c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.459</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>44</x>
  <y>585</y>
  <width>88</width>
  <height>25</height>
  <uuid>{0d2e674d-5803-42f4-a7a2-402061e0f0c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Y =</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>pointy</objectName>
  <x>69</x>
  <y>586</y>
  <width>53</width>
  <height>23</height>
  <uuid>{be45a44f-f849-4869-b904-b0bf72817da3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.524</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>176</x>
  <y>516</y>
  <width>172</width>
  <height>114</height>
  <uuid>{65e379b2-7595-46aa-a7aa-846aee578c5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Receiving</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>pointx</objectName>
  <x>184</x>
  <y>543</y>
  <width>76</width>
  <height>77</height>
  <uuid>{3bb77afd-be1c-45c0-9f6d-dc4105d3da95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>pointy</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45945946</xValue>
  <yValue>0.52380952</yValue>
  <type>point</type>
  <pointsize>8</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>crossx</objectName>
  <x>265</x>
  <y>542</y>
  <width>76</width>
  <height>78</height>
  <uuid>{99d423bf-2781-46be-9e1f-8b4513d1e7fd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>crossy</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.56097561</xValue>
  <yValue>0.53448276</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>255</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>y</objectName>
  <x>540</x>
  <y>463</y>
  <width>150</width>
  <height>150</height>
  <uuid>{6a83a789-228c-44f1-8a26-6558d2e760d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>x</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.32973509</xValue>
  <yValue>0.51994034</yValue>
  <type>point</type>
  <pointsize>10</pointsize>
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
  <x>406</x>
  <y>604</y>
  <width>35</width>
  <height>25</height>
  <uuid>{fb601758-0de8-440e-ae38-2bd4127c6ec4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Freq</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>freq</objectName>
  <x>397</x>
  <y>474</y>
  <width>136</width>
  <height>133</height>
  <uuid>{8fa2948b-cd3c-4e06-9e00-aa68396a8a7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>amp</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.18382353</xValue>
  <yValue>0.42857143</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>234</r>
   <g>82</g>
   <b>65</b>
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
  <x>369</x>
  <y>574</y>
  <width>35</width>
  <height>25</height>
  <uuid>{577c7acd-d16e-4c30-bfab-15bb6fd2f56b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amp</label>
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
  <x>377</x>
  <y>395</y>
  <width>328</width>
  <height>58</height>
  <uuid>{5e45d9fe-26ef-4c9d-a133-bc289c41fd30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Run the csd to generate circular movement. The controller on the left will determine the frequency and amplitude of rotation.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 72 179 400 200
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView background {35466, 38293, 40092}
ioText {353, 373} {369, 257} label 0.000000 0.00100 "" center "Liberation Sans" 12 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Input and output
ioText {53, 3} {265, 42} label 0.000000 0.00100 "" center "Arial" 24 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Controller Widget
ioText {6, 40} {339, 85} label 0.000000 0.00100 "" left "Liberation Sans" 12 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Controller widgets are widgets that can be used to produce data from mouse movements. Some controllers can send only one value but others can send horizontal and vertical values. You can set the range of the controller in the preferences.
ioText {8, 134} {160, 168} label 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 'fill' controller
ioMeter {18, 157} {22, 136} {46336, 59904, 38912} "" 0.529412 "fillvert" 0.500000 fill 1 0 mouse
ioMeter {45, 158} {114, 25} {30720, 59904, 47872} "fillhor" 0.552632 "" 0.710526 fill 1 0 mouse
ioText {47, 186} {111, 46} label 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Fill controllers are just like sliders.
ioText {46, 235} {112, 26} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Horizontal
ioText {103, 236} {52, 22} label 0.553000 0.00100 "fillhor" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 0.553
ioText {46, 266} {112, 25} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Vertical
ioText {98, 267} {53, 23} label 0.500000 0.00100 "fillvert" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 0.500
ioText {184, 135} {160, 168} label 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 'llif' controller
ioMeter {191, 159} {22, 136} {41472, 50944, 59904} "" 0.375000 "llifvert" 0.404412 llif 1 0 mouse
ioMeter {218, 160} {113, 17} {14336, 59904, 58368} "llifhor" 0.460177 "" 0.398230 llif 1 0 mouse
ioText {218, 179} {115, 55} label 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Llif controllers are inverted fill controllers
ioText {219, 238} {112, 26} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Horizontal
ioText {276, 239} {52, 22} label 0.460000 0.00100 "llifhor" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 0.460
ioText {220, 269} {112, 25} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Vertical
ioText {271, 270} {53, 23} label 0.404000 0.00100 "llifvert" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 0.404
ioText {10, 307} {158, 111} label 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 'line' controller
ioMeter {14, 329} {49, 80} {65280, 21760, 0} "" 0.625000 "linevert" 0.500000 line 1 0 mouse
ioText {65, 330} {97, 50} label 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Line controllers are unfilled.
ioText {65, 384} {93, 25} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Vertical
ioText {110, 385} {53, 23} label 0.500000 0.00100 "linevert" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 0.500
ioText {174, 308} {173, 203} label 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 'crosshair' controller
ioMeter {178, 329} {164, 116} {43520, 21760, 65280} "crossx" 0.560976 "crossy" 0.534483 crosshair 1 0 mouse
ioText {183, 450} {83, 25} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder X =
ioText {209, 451} {52, 22} label 0.561000 0.00100 "crossx" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 0.561
ioText {183, 480} {88, 25} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Y =
ioText {208, 481} {53, 23} label 0.534000 0.00100 "crossy" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 0.534
ioText {12, 424} {158, 206} label 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 'point' controller
ioMeter {16, 445} {148, 105} {65280, 65280, 65280} "pointx" 0.459459 "pointy" 0.523810 point 4 0 mouse
ioText {47, 556} {83, 25} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder X =
ioText {72, 557} {52, 22} label 0.459000 0.00100 "pointx" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 0.459
ioText {44, 585} {88, 25} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Y =
ioText {69, 586} {53, 23} label 0.524000 0.00100 "pointy" left "Arial" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder 0.524
ioText {176, 516} {172, 114} label 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Receiving
ioMeter {184, 543} {76, 77} {65280, 0, 0} "pointx" 0.459459 "pointy" 0.523810 point 8 0 mouse
ioMeter {265, 542} {76, 78} {21760, 65280, 65280} "crossx" 0.560976 "crossy" 0.534483 crosshair 1 0 mouse
ioMeter {540, 463} {150, 150} {0, 59904, 0} "y" 0.329735 "x" 0.519940 point 10 0 mouse
ioText {406, 604} {35, 25} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Freq
ioMeter {397, 474} {136, 133} {59904, 20992, 16640} "freq" 0.183824 "amp" 0.428571 crosshair 1 0 mouse
ioText {369, 574} {35, 25} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {61952, 61696, 61440} nobackground noborder Amp
ioText {377, 395} {328, 58} label 0.000000 0.00100 "" left "Liberation Sans" 12 {0, 0, 0} {48896, 52224, 59904} nobackground noborder Run the csd to generate circular movement. The controller on the left will determine the frequency and amplitude of rotation.
</MacGUI>

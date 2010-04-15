<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
;Nothing here...
; Widgets transmit values between themselves
; even when Csound is not running
endin

</CsInstruments>
<CsScore>
f 0 3600
</CsScore>
</CsoundSynthesizer>






<bsbPanel>
 <bgcolor mode="background" >
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>53</x>
  <y>3</y>
  <width>265</width>
  <height>42</height>
  <uuid>{5bdc92b0-c72c-4fcb-9fc6-2b26d6b5cdf2}</uuid>
  <label>Controller Widget</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>6</x>
  <y>45</y>
  <width>339</width>
  <height>81</height>
  <uuid>{8033ef83-4eaf-440b-9584-cf062a5923a4}</uuid>
  <label>Controller widgets are widgets that can be used to produce data from mouse movements. Some controllers can send only one value but others can send horizontal and vertical values. All controllers have a range from 0 to 1 in both the vertical and horizontal axis.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>8</x>
  <y>134</y>
  <width>160</width>
  <height>168</height>
  <uuid>{d215665b-e569-4b9e-9fc7-3708a0dbeb14}</uuid>
  <label>'fill' controller</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>fillvert</objectName>
  <x>18</x>
  <y>157</y>
  <width>22</width>
  <height>136</height>
  <uuid>{d6699db1-0924-45c7-a175-b8dc3e3cffd6}</uuid>
  <objectName2>hor12</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.52941176</xValue>
  <yValue>0.27272727</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>181</r>
   <g>234</g>
   <b>152</b>
  </color>
  <randomizable mode="both" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>vert3</objectName>
  <x>45</x>
  <y>158</y>
  <width>114</width>
  <height>25</height>
  <uuid>{ec82338a-a697-4290-8a72-714db2f81c79}</uuid>
  <objectName2>fillhor</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.41176471</xValue>
  <yValue>0.71052632</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>120</r>
   <g>234</g>
   <b>187</b>
  </color>
  <randomizable mode="both" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>47</x>
  <y>186</y>
  <width>111</width>
  <height>46</height>
  <uuid>{96c39df8-15e3-4aef-9591-6802dae9b50e}</uuid>
  <label>Fill controllers are just like sliders.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>46</x>
  <y>236</y>
  <width>112</width>
  <height>26</height>
  <uuid>{422f6796-2317-4846-8a8b-13ca3d6006b8}</uuid>
  <label>Horizontal</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>fillhor</objectName>
  <x>103</x>
  <y>237</y>
  <width>52</width>
  <height>22</height>
  <uuid>{0e6de40f-0aae-4d04-ba09-f2618f28e029}</uuid>
  <label>0.711</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>46</x>
  <y>266</y>
  <width>112</width>
  <height>25</height>
  <uuid>{96187497-6e0c-4c3b-87b5-273e316c14b6}</uuid>
  <label>Vertical</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>fillvert</objectName>
  <x>98</x>
  <y>267</y>
  <width>53</width>
  <height>23</height>
  <uuid>{36536070-7005-41ad-9918-7651aed51dd3}</uuid>
  <label>0.529</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>184</x>
  <y>135</y>
  <width>160</width>
  <height>168</height>
  <uuid>{d757dd66-9956-49e3-a9b3-a6553f6d0aa4}</uuid>
  <label>'llif' controller</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>llifvert</objectName>
  <x>191</x>
  <y>159</y>
  <width>22</width>
  <height>136</height>
  <uuid>{33be0854-e529-4a59-baee-f49249bdd580}</uuid>
  <objectName2>hor12</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.37500000</xValue>
  <yValue>0.27272727</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>162</r>
   <g>199</g>
   <b>234</b>
  </color>
  <randomizable mode="both" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>vert3</objectName>
  <x>218</x>
  <y>160</y>
  <width>113</width>
  <height>17</height>
  <uuid>{a0f7059d-bd95-4908-9b2e-a828dab6427e}</uuid>
  <objectName2>llifhor</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.41176471</xValue>
  <yValue>0.39823009</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>56</r>
   <g>234</g>
   <b>228</b>
  </color>
  <randomizable mode="both" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>218</x>
  <y>179</y>
  <width>115</width>
  <height>55</height>
  <uuid>{d776d5b3-f81b-44be-a7c3-7dd42fbac5f5}</uuid>
  <label>Llif controllers are inverted fill controllers</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>219</x>
  <y>238</y>
  <width>112</width>
  <height>26</height>
  <uuid>{ba2e6d94-ea2b-4d0b-86e2-32bb309f7e8d}</uuid>
  <label>Horizontal</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>llifhor</objectName>
  <x>276</x>
  <y>239</y>
  <width>52</width>
  <height>22</height>
  <uuid>{9ec5b748-459d-4a59-a9c0-2eb0f2a152c0}</uuid>
  <label>0.398</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>220</x>
  <y>269</y>
  <width>112</width>
  <height>25</height>
  <uuid>{95d58265-3539-4595-917d-6c7d35772666}</uuid>
  <label>Vertical</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>llifvert</objectName>
  <x>271</x>
  <y>270</y>
  <width>53</width>
  <height>23</height>
  <uuid>{b291988b-552f-40ac-8827-f5abe43c383b}</uuid>
  <label>0.375</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>10</x>
  <y>307</y>
  <width>158</width>
  <height>111</height>
  <uuid>{5312b9e8-b39f-4e23-a7b7-59cb9892d9e8}</uuid>
  <label>'line' controller</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>linevert</objectName>
  <x>14</x>
  <y>329</y>
  <width>49</width>
  <height>80</height>
  <uuid>{68007db4-c113-4952-8e22-0dba146ee98c}</uuid>
  <objectName2>hor19</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.62500000</xValue>
  <yValue>0.53061224</yValue>
  <type>line</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable mode="both" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>65</x>
  <y>330</y>
  <width>97</width>
  <height>50</height>
  <uuid>{3d0b86b6-7100-4e5d-af42-0eedca472ec2}</uuid>
  <label>Line controllers are unfilled.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>65</x>
  <y>384</y>
  <width>93</width>
  <height>25</height>
  <uuid>{c03753be-1e49-41fe-84e9-513855ffff27}</uuid>
  <label>Vertical</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>linevert</objectName>
  <x>110</x>
  <y>385</y>
  <width>53</width>
  <height>23</height>
  <uuid>{4aa45c29-93bb-49bf-94d3-9c96fdeb91ea}</uuid>
  <label>0.625</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>174</x>
  <y>308</y>
  <width>173</width>
  <height>203</height>
  <uuid>{682a0860-0092-4407-b3af-1d7136c5fc4a}</uuid>
  <label>'crosshair' controller</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>crossy</objectName>
  <x>178</x>
  <y>329</y>
  <width>164</width>
  <height>116</height>
  <uuid>{1f10b659-18f2-4fee-be18-07e821cbd826}</uuid>
  <objectName2>crossx</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.46551724</xValue>
  <yValue>0.37804878</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>170</r>
   <g>85</g>
   <b>255</b>
  </color>
  <randomizable mode="both" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>183</x>
  <y>450</y>
  <width>83</width>
  <height>25</height>
  <uuid>{38db9e15-fa6f-451c-a3ab-399a0a9b8700}</uuid>
  <label>X =</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>crossx</objectName>
  <x>209</x>
  <y>451</y>
  <width>52</width>
  <height>22</height>
  <uuid>{8962fe20-2486-4c54-96d2-6d6de8434e87}</uuid>
  <label>0.378</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>183</x>
  <y>480</y>
  <width>88</width>
  <height>25</height>
  <uuid>{377df814-9d21-46c6-9d08-ded5e14a1f1f}</uuid>
  <label>Y =</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>crossy</objectName>
  <x>208</x>
  <y>481</y>
  <width>53</width>
  <height>23</height>
  <uuid>{049ca916-c918-4693-86aa-c09ec3a3a4e8}</uuid>
  <label>0.466</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>12</x>
  <y>424</y>
  <width>158</width>
  <height>206</height>
  <uuid>{15021657-80aa-4691-ac05-02328cad5949}</uuid>
  <label>'point' controller</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>pointy</objectName>
  <x>16</x>
  <y>445</y>
  <width>148</width>
  <height>105</height>
  <uuid>{37ce3594-1408-4256-b55b-4ee0e24265f3}</uuid>
  <objectName2>pointx</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.61904762</xValue>
  <yValue>0.61486486</yValue>
  <type>point</type>
  <pointsize>4</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <randomizable mode="both" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>47</x>
  <y>556</y>
  <width>83</width>
  <height>25</height>
  <uuid>{ae97e997-3bcb-4e22-97d2-db289b9ac36d}</uuid>
  <label>X =</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>pointx</objectName>
  <x>72</x>
  <y>557</y>
  <width>52</width>
  <height>22</height>
  <uuid>{f5f70eb4-1d78-4f1b-8e91-e4813770201c}</uuid>
  <label>0.615</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>44</x>
  <y>585</y>
  <width>88</width>
  <height>25</height>
  <uuid>{0d2e674d-5803-42f4-a7a2-402061e0f0c6}</uuid>
  <label>Y =</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName>pointy</objectName>
  <x>69</x>
  <y>586</y>
  <width>53</width>
  <height>23</height>
  <uuid>{be45a44f-f849-4869-b904-b0bf72817da3}</uuid>
  <label>0.619</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>176</x>
  <y>516</y>
  <width>172</width>
  <height>114</height>
  <uuid>{65e379b2-7595-46aa-a7aa-846aee578c5b}</uuid>
  <label>Receiving</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>6</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>pointy</objectName>
  <x>184</x>
  <y>543</y>
  <width>76</width>
  <height>77</height>
  <uuid>{3bb77afd-be1c-45c0-9f6d-dc4105d3da95}</uuid>
  <objectName2>pointx</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.61904762</xValue>
  <yValue>0.61486486</yValue>
  <type>point</type>
  <pointsize>4</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <randomizable mode="both" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>crossy</objectName>
  <x>265</x>
  <y>542</y>
  <width>76</width>
  <height>78</height>
  <uuid>{99d423bf-2781-46be-9e1f-8b4513d1e7fd}</uuid>
  <objectName2>crossx</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.46551724</xValue>
  <yValue>0.37804878</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>170</r>
   <g>85</g>
   <b>255</b>
  </color>
  <randomizable mode="both" >false</randomizable>
 </bsbObject>
 <objectName/>
 <x>510</x>
 <y>45</y>
 <width>372</width>
 <height>672</height>
 <visible>true</visible>
</bsbPanel>

<bsbPresets>
</bsbPresets>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="0" y="0" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>
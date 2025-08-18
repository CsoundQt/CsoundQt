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

chn_k "x", "w"
chn_k "y", "w"

instr 1
  kfreq invalue "freq"
  kamp invalue "amp"
  kx oscil 0.4*kamp, kfreq*2, 1
  ky oscil 0.4*kamp, kfreq*2, 1, 0.25
  
  ; update the gui
  if metro(30) == 1 then
    chnset kx+0.5, "x"
    chnset ky+0.5, "y"
  endif
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
  <r>207</r>
  <g>218</g>
  <b>225</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>340</x>
  <y>380</y>
  <width>365</width>
  <height>260</height>
  <uuid>{8310d23a-8657-4223-9efb-b2c9b1f46b03}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Input and output</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </color>
  <bgcolor mode="nobackground">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>45</x>
  <y>5</y>
  <width>265</width>
  <height>42</height>
  <uuid>{5bdc92b0-c72c-4fcb-9fc6-2b26d6b5cdf2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Controller Widget</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>50</y>
  <width>330</width>
  <height>85</height>
  <uuid>{8033ef83-4eaf-440b-9584-cf062a5923a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Controller widgets are widgets that can be used to produce data from mouse movements. Some controllers can send only one value but others can send horizontal and vertical values. You can set the range of the controller in the preferences.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>166</r>
   <g>176</g>
   <b>180</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>145</y>
  <width>160</width>
  <height>168</height>
  <uuid>{d215665b-e569-4b9e-9fc7-3708a0dbeb14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>'fill' controller</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>80</r>
   <g>80</g>
   <b>80</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>fillhor</objectName>
  <x>45</x>
  <y>170</y>
  <width>116</width>
  <height>25</height>
  <uuid>{ec82338a-a697-4290-8a72-714db2f81c79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.54310345</xValue>
  <yValue>0.71052632</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>border</bordermode>
  <borderColor>#5cb490</borderColor>
  <color>
   <r>120</r>
   <g>234</g>
   <b>187</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>41</r>
   <g>80</g>
   <b>64</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>45</x>
  <y>200</y>
  <width>116</width>
  <height>46</height>
  <uuid>{96c39df8-15e3-4aef-9591-6802dae9b50e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Fill controllers are just like sliders.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>10</r>
   <g>10</g>
   <b>10</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>45</x>
  <y>250</y>
  <width>116</width>
  <height>26</height>
  <uuid>{422f6796-2317-4846-8a8b-13ca3d6006b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Horizontal</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName>fillhor</objectName>
  <x>105</x>
  <y>250</y>
  <width>52</width>
  <height>22</height>
  <uuid>{0e6de40f-0aae-4d04-ba09-f2618f28e029}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.543</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>45</x>
  <y>280</y>
  <width>116</width>
  <height>25</height>
  <uuid>{96187497-6e0c-4c3b-87b5-273e316c14b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Vertical</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName>fillvert</objectName>
  <x>105</x>
  <y>280</y>
  <width>53</width>
  <height>23</height>
  <uuid>{36536070-7005-41ad-9918-7651aed51dd3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.618</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>175</x>
  <y>145</y>
  <width>160</width>
  <height>168</height>
  <uuid>{d757dd66-9956-49e3-a9b3-a6553f6d0aa4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>'llif' controller</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>80</r>
   <g>80</g>
   <b>80</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>180</x>
  <y>170</y>
  <width>22</width>
  <height>136</height>
  <uuid>{33be0854-e529-4a59-baee-f49249bdd580}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>llifvert</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.37500000</xValue>
  <yValue>0.61764706</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>border</bordermode>
  <borderColor>#1e1e1e</borderColor>
  <color>
   <r>162</r>
   <g>199</g>
   <b>234</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>llifhor</objectName>
  <x>210</x>
  <y>170</y>
  <width>116</width>
  <height>17</height>
  <uuid>{a0f7059d-bd95-4908-9b2e-a828dab6427e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.50000000</xValue>
  <yValue>0.39823009</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>border</bordermode>
  <borderColor>#1e1e1e</borderColor>
  <color>
   <r>56</r>
   <g>234</g>
   <b>228</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>210</x>
  <y>190</y>
  <width>116</width>
  <height>55</height>
  <uuid>{d776d5b3-f81b-44be-a7c3-7dd42fbac5f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Llif controllers are inverted fill controllers</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>10</r>
   <g>10</g>
   <b>10</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>210</x>
  <y>250</y>
  <width>116</width>
  <height>26</height>
  <uuid>{ba2e6d94-ea2b-4d0b-86e2-32bb309f7e8d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Horizontal</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName>llifhor</objectName>
  <x>265</x>
  <y>250</y>
  <width>52</width>
  <height>22</height>
  <uuid>{9ec5b748-459d-4a59-a9c0-2eb0f2a152c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.500</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>210</x>
  <y>280</y>
  <width>116</width>
  <height>25</height>
  <uuid>{95d58265-3539-4595-917d-6c7d35772666}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Vertical</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName>llifvert</objectName>
  <x>265</x>
  <y>280</y>
  <width>53</width>
  <height>23</height>
  <uuid>{b291988b-552f-40ac-8827-f5abe43c383b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.618</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>320</y>
  <width>160</width>
  <height>111</height>
  <uuid>{5312b9e8-b39f-4e23-a7b7-59cb9892d9e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>'line' controller</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>80</r>
   <g>80</g>
   <b>80</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>20</x>
  <y>345</y>
  <width>22</width>
  <height>80</height>
  <uuid>{68007db4-c113-4952-8e22-0dba146ee98c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>linevert</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.62500000</xValue>
  <yValue>0.43750000</yValue>
  <type>line</type>
  <pointsize>2</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>45</x>
  <y>345</y>
  <width>116</width>
  <height>48</height>
  <uuid>{3d0b86b6-7100-4e5d-af42-0eedca472ec2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Line controllers are unfilled.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>45</x>
  <y>400</y>
  <width>116</width>
  <height>25</height>
  <uuid>{c03753be-1e49-41fe-84e9-513855ffff27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Vertical</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName>linevert</objectName>
  <x>110</x>
  <y>400</y>
  <width>53</width>
  <height>23</height>
  <uuid>{4aa45c29-93bb-49bf-94d3-9c96fdeb91ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.438</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>175</x>
  <y>320</y>
  <width>160</width>
  <height>206</height>
  <uuid>{682a0860-0092-4407-b3af-1d7136c5fc4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>'crosshair' controller</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>80</r>
   <g>80</g>
   <b>80</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>crossx</objectName>
  <x>180</x>
  <y>345</y>
  <width>150</width>
  <height>116</height>
  <uuid>{1f10b659-18f2-4fee-be18-07e821cbd826}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>crossy</objectName2>
  <xMin>-1.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>-1.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-0.18666667</xValue>
  <yValue>0.65517241</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>170</r>
   <g>85</g>
   <b>255</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>205</x>
  <y>465</y>
  <width>80</width>
  <height>25</height>
  <uuid>{38db9e15-fa6f-451c-a3ab-399a0a9b8700}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>X =</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName>crossx</objectName>
  <x>230</x>
  <y>470</y>
  <width>52</width>
  <height>22</height>
  <uuid>{8962fe20-2486-4c54-96d2-6d6de8434e87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-0.187</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>205</x>
  <y>495</y>
  <width>80</width>
  <height>25</height>
  <uuid>{377df814-9d21-46c6-9d08-ded5e14a1f1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Y =</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName>crossy</objectName>
  <x>230</x>
  <y>495</y>
  <width>53</width>
  <height>23</height>
  <uuid>{049ca916-c918-4693-86aa-c09ec3a3a4e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.655</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>440</y>
  <width>160</width>
  <height>200</height>
  <uuid>{15021657-80aa-4691-ac05-02328cad5949}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>'point' controller</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>80</r>
   <g>80</g>
   <b>80</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>pointx</objectName>
  <x>15</x>
  <y>465</y>
  <width>148</width>
  <height>105</height>
  <uuid>{37ce3594-1408-4256-b55b-4ee0e24265f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>pointy</objectName2>
  <xMin>-1.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>-1.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.05405405</xValue>
  <yValue>0.54285714</yValue>
  <type>point</type>
  <pointsize>4</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>50</x>
  <y>580</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ae97e997-3bcb-4e22-97d2-db289b9ac36d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>X =</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName>pointx</objectName>
  <x>75</x>
  <y>580</y>
  <width>52</width>
  <height>22</height>
  <uuid>{f5f70eb4-1d78-4f1b-8e91-e4813770201c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.054</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>50</x>
  <y>610</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0d2e674d-5803-42f4-a7a2-402061e0f0c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Y =</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>184</r>
   <g>195</g>
   <b>200</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName>pointy</objectName>
  <x>75</x>
  <y>610</y>
  <width>53</width>
  <height>23</height>
  <uuid>{be45a44f-f849-4869-b904-b0bf72817da3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.543</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>175</x>
  <y>530</y>
  <width>160</width>
  <height>110</height>
  <uuid>{65e379b2-7595-46aa-a7aa-846aee578c5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Receiving</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>80</r>
   <g>80</g>
   <b>80</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>pointx</objectName>
  <x>180</x>
  <y>555</y>
  <width>70</width>
  <height>70</height>
  <uuid>{3bb77afd-be1c-45c0-9f6d-dc4105d3da95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>pointy</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.05405405</xValue>
  <yValue>0.54285714</yValue>
  <type>point</type>
  <pointsize>8</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>crossx</objectName>
  <x>255</x>
  <y>555</y>
  <width>70</width>
  <height>70</height>
  <uuid>{99d423bf-2781-46be-9e1f-8b4513d1e7fd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>crossy</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-0.18666667</xValue>
  <yValue>0.65517241</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>108</r>
   <g>240</g>
   <b>240</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>y</objectName>
  <x>525</x>
  <y>470</y>
  <width>150</width>
  <height>150</height>
  <uuid>{6a83a789-228c-44f1-8a26-6558d2e760d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>x</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.22442529</xValue>
  <yValue>0.60051381</yValue>
  <type>point</type>
  <pointsize>10</pointsize>
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
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>430</x>
  <y>615</y>
  <width>35</width>
  <height>25</height>
  <uuid>{fb601758-0de8-440e-ae38-2bd4127c6ec4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Freq</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>340</x>
  <y>535</y>
  <width>35</width>
  <height>25</height>
  <uuid>{577c7acd-d16e-4c30-bfab-15bb6fd2f56b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>360</x>
  <y>405</y>
  <width>330</width>
  <height>60</height>
  <uuid>{5e45d9fe-26ef-4c9d-a133-bc289c41fd30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Run the csd to generate circular movement. The controller on the left will determine the frequency and amplitude of rotation.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>166</r>
   <g>176</g>
   <b>180</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>freq</objectName>
  <x>370</x>
  <y>470</y>
  <width>150</width>
  <height>150</height>
  <uuid>{8fa2948b-cd3c-4e06-9e00-aa68396a8a7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>amp</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000000</xValue>
  <yValue>0.73333333</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>234</r>
   <g>82</g>
   <b>65</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>20</x>
  <y>170</y>
  <width>22</width>
  <height>136</height>
  <uuid>{d6699db1-0924-45c7-a175-b8dc3e3cffd6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>fillvert</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.52941176</xValue>
  <yValue>0.61764706</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>border</bordermode>
  <borderColor>#8cb474</borderColor>
  <color>
   <r>181</r>
   <g>234</g>
   <b>152</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

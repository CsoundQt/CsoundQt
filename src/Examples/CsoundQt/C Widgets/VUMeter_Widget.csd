<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

; Drives the two VU meters with chnset. The meters are output only: they just
; follow the dB value written to their channel.

instr 1
  ; vertical meter, range -90 .. 0 dB
  kph1 = phasor(0.20)
  kdbv = -90 + 90 * (0.5 + 0.5 * sin(2 * 3.14159265 * kph1))
  chnset kdbv, "vudb_vert"

  ; horizontal meter, range -90 .. +6 dB
  kph2 = phasor(0.55)
  kdbh = -90 + 100 * (0.5 + 0.5 * sin(2 * 3.14159265 * kph2))
  chnset kdbh, "vudb_horiz"

  asig  = diskin2("../../SourceMaterials/ClassicalGuitar.wav", 1, 0, 200)
  kgain = chnget("gain")
  kdb   = dbamp(rms(asig)) + kgain
  chnset lagud(kdb, 0.01, 0.5), "vudb2"
  chnset lagud(kdb, 0, 200), "vudb2_cursor"
  out asig
endin

</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>497</width>
 <height>595</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>231</r>
  <g>231</g>
  <b>231</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>8</y>
  <width>450</width>
  <height>45</height>
  <uuid>{aaae8b01-3ff8-483b-9f79-63c55aa1804e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>VU Meter Widget</label>
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
   <r>230</r>
   <g>230</g>
   <b>230</b>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>50</y>
  <width>441</width>
  <height>76</height>
  <uuid>{693b9425-a8c0-4502-a99e-50594ba159ec}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The VU Meter is output only: it follows the dB value written to its channel with chnset (or outvalue). It always works in dB; min/max are configurable (default -90 to 0).  The bar can be vertical or horizontal, according to its width/height.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </color>
  <bgcolor mode="background">
   <r>185</r>
   <g>185</g>
   <b>185</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>vudb_vert</objectName>
  <x>27</x>
  <y>139</y>
  <width>36</width>
  <height>371</height>
  <uuid>{35353dda-5ced-4564-ae81-0319d4e322ea}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-60.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>full</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
  <exponent>0.50000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>128</r>
   <g>128</g>
   <b>128</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>vudb_horiz</objectName>
  <x>73</x>
  <y>145</y>
  <width>349</width>
  <height>36</height>
  <uuid>{07e60557-2eb3-46df-a978-29b8ca8ec59a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-90.00000000</minimum>
  <maximum>6.00000000</maximum>
  <objectName2/>
  <rulermode>full</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
  <exponent>0.50000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>128</r>
   <g>128</g>
   <b>128</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>vudb_vert</objectName>
  <x>78</x>
  <y>192</y>
  <width>36</width>
  <height>100</height>
  <uuid>{2f7b0285-44f9-4a06-a176-82bbdb51de38}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-60.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>full</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
  <exponent>0.50000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>128</r>
   <g>128</g>
   <b>128</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>125</x>
  <y>199</y>
  <width>174</width>
  <height>41</height>
  <uuid>{90725201-c304-4dfb-abe3-e52ace00da1e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The ruler is adapted to the size of the meter</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </color>
  <bgcolor mode="background">
   <r>213</r>
   <g>255</g>
   <b>206</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>78</x>
  <y>303</y>
  <width>333</width>
  <height>292</height>
  <uuid>{1ddec04f-aa8c-42b6-b1df-ec6425dfb86f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Inter</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>212</r>
   <g>212</g>
   <b>212</b>
  </color>
  <bgcolor mode="background">
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>vudb_vert</objectName>
  <x>118</x>
  <y>329</y>
  <width>36</width>
  <height>200</height>
  <uuid>{d00bc45e-f84f-4acb-8bf3-fb835fcfd0f3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-80.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>full</rulermode>
  <rulercolor>#d4d4d4</rulercolor>
  <exponent>0.30000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>212</r>
   <g>212</g>
   <b>212</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>vudb_vert</objectName>
  <x>196</x>
  <y>329</y>
  <width>36</width>
  <height>200</height>
  <uuid>{079f7a97-516f-4131-b4b3-6fb3e25c87f4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-80.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>full</rulermode>
  <rulercolor>#d4d4d4</rulercolor>
  <exponent>0.55000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>212</r>
   <g>212</g>
   <b>212</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>vudb_vert</objectName>
  <x>275</x>
  <y>329</y>
  <width>36</width>
  <height>200</height>
  <uuid>{4cee766b-b444-4b80-8232-fd5cd7844821}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-80.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>compact</rulermode>
  <rulercolor>#d4d4d4</rulercolor>
  <exponent>0.80000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>212</r>
   <g>212</g>
   <b>212</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>vudb_vert</objectName>
  <x>352</x>
  <y>336</y>
  <width>16</width>
  <height>185</height>
  <uuid>{586b75f6-bb76-460f-9286-534ff87278c1}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-80.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>hide</rulermode>
  <rulercolor>#d4d4d4</rulercolor>
  <exponent>0.80000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>212</r>
   <g>212</g>
   <b>212</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>88</x>
  <y>549</y>
  <width>310</width>
  <height>27</height>
  <uuid>{0b2ce519-8c47-4196-a469-d1571ec12951}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Different skew exponentials, low to high</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </color>
  <bgcolor mode="background">
   <r>213</r>
   <g>255</g>
   <b>206</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>vudb2</objectName>
  <x>461</x>
  <y>148</y>
  <width>42</width>
  <height>371</height>
  <uuid>{1a6e70d9-0028-41ec-9b37-032640ef5b50}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-120.00000000</minimum>
  <maximum>12.00000000</maximum>
  <objectName2>vudb2_cursor</objectName2>
  <rulermode>full</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
  <exponent>0.50000000</exponent>
  <cursorcolor>#ffffff</cursorcolor>
  <cursorwidth>2</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>128</r>
   <g>128</g>
   <b>128</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>gain</objectName>
  <x>447</x>
  <y>522</y>
  <width>48</width>
  <height>48</height>
  <uuid>{e80594ff-d3f5-46e2-ab30-56be434540a9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-24.00000000</minimum>
  <maximum>24.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>6.98400000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#653f19</textcolor>
  <border>1</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>445</x>
  <y>569</y>
  <width>53</width>
  <height>26</height>
  <uuid>{2c3d06db-367c-41bf-88e6-f1f91f281471}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>gain (dB)</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>74</r>
   <g>38</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1

	Sin invalue "instring"
	outvalue "display", Sin

	Sline invalue "lineedit"
	klevel invalue "level"
	kdur invalue "dur"
	kcomp strcmpk Sline, "-"
	; trigger notes only when line is not empty
	ktrig = (kcomp != 0? 1: 0)
	kchr strchark Sline, 1
	schedkwhen ktrig, 0.05, 10, 2, 0, kdur, kchr, klevel
	outvalue "lineedit", "-" ;empty line edit widget
endin

instr 2
	idur = p3
	ilevel = p5
	icps = 440 * 2^((p4 - 100)/12)
	aout oscils ilevel, icps, 0
	aenv adsr 0.2*idur, 0.2*idur, 0.7, 0.3*idur
	outs aout*aenv, aout*aenv
endin

</CsInstruments>
<CsScore>
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>






<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>284</width>
 <height>433</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>194</r>
  <g>204</g>
  <b>210</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>225</y>
  <width>276</width>
  <height>199</height>
  <uuid>{b37e9f05-df2d-4a31-ab50-f93173624086}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The Line Edit Widget can also be used to receive strings from Csound. Put the keyboard focus on the line edit widget below and type on the ASCII keyboard.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>42</r>
   <g>46</g>
   <b>50</b>
  </color>
  <bgcolor mode="background">
   <r>166</r>
   <g>176</g>
   <b>180</b>
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
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>lineedit</objectName>
  <x>205</x>
  <y>305</y>
  <width>25</width>
  <height>25</height>
  <uuid>{eca8b99c-5d0e-4bd0-adb5-199c226b5305}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-</label>
  <instant>true</instant>
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
   <r>232</r>
   <g>232</g>
   <b>232</b>
  </bgcolor>
  <background>nobackground</background>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>level</objectName>
  <x>50</x>
  <y>346</y>
  <width>50</width>
  <height>49</height>
  <uuid>{d6a1bbac-0b3f-49ba-b281-6a31c464d7b4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.05000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.23193500</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>1</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>44</x>
  <y>306</y>
  <width>156</width>
  <height>26</height>
  <uuid>{f9f54980-38ff-4721-97d6-8afa7a524711}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Put keyboard focus here >>></label>
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
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>51</x>
  <y>390</y>
  <width>49</width>
  <height>24</height>
  <uuid>{2cd5cd9d-6ca7-4350-b274-ef793f5dedce}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Level</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>dur</objectName>
  <x>128</x>
  <y>358</y>
  <width>109</width>
  <height>19</height>
  <uuid>{7b7e5745-622f-411c-97d8-b4136ee2b401}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.20000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.71926606</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>158</x>
  <y>376</y>
  <width>60</width>
  <height>22</height>
  <uuid>{0f74a0f5-f1a9-4ef5-962c-e1753a6e6cc5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>duration</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <x>8</x>
  <y>46</y>
  <width>276</width>
  <height>170</height>
  <uuid>{187b22e7-31c4-4f4c-bb47-168034be6765}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The Line Edit Widget can be used to pass strings from the widget panel to the csound program.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>28</r>
   <g>29</g>
   <b>30</b>
  </color>
  <bgcolor mode="background">
   <r>166</r>
   <g>176</g>
   <b>180</b>
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
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>instring</objectName>
  <x>15</x>
  <y>113</y>
  <width>260</width>
  <height>27</height>
  <uuid>{b3c2f590-724b-404e-8eac-a32bc9bf0185}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>bar</label>
  <instant>true</instant>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>232</r>
   <g>232</g>
   <b>232</b>
  </bgcolor>
  <background>nobackground</background>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>27</x>
  <y>8</y>
  <width>226</width>
  <height>38</height>
  <uuid>{f252e58c-f68b-4d35-a641-077bd7762802}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Line Edit Widget</label>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>display</objectName>
  <x>15</x>
  <y>146</y>
  <width>260</width>
  <height>64</height>
  <uuid>{f4a15331-9a2f-492b-bb12-214d41bf8bbf}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>bar</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>239</r>
   <g>240</g>
   <b>241</b>
  </color>
  <bgcolor mode="background">
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
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>305</x>
  <y>46</y>
  <width>276</width>
  <height>170</height>
  <uuid>{e75b038a-66dd-4b8b-a4fa-207c3a2e95ce}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>In "instant" mode, LineEdit updates its channel value with each keystroke. If instant is not checked, the text is only applied when the user presses Enter.  </label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>29</r>
   <g>29</g>
   <b>29</b>
  </color>
  <bgcolor mode="background">
   <r>166</r>
   <g>176</g>
   <b>180</b>
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
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>text</objectName>
  <x>312</x>
  <y>113</y>
  <width>260</width>
  <height>27</height>
  <uuid>{1275bf6b-7da8-4f01-8990-9b61c19fd5ea}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>delayed</label>
  <instant>false</instant>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>232</r>
   <g>232</g>
   <b>232</b>
  </bgcolor>
  <background>nobackground</background>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>text</objectName>
  <x>312</x>
  <y>146</y>
  <width>260</width>
  <height>64</height>
  <uuid>{323e60d9-d175-4ad2-bd4f-72676fe8d081}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>delayed</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>239</r>
   <g>240</g>
   <b>241</b>
  </color>
  <bgcolor mode="background">
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bgcolor>
  <bordercolor>
   <r>146</r>
   <g>148</g>
   <b>148</b>
  </bordercolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

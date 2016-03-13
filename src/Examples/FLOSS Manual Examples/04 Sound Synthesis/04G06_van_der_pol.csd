<CsoundSynthesizer>
<CsInstruments>

sr      =  44100
ksmps   =  32
nchnls  =  2
0dbfs 	 = 1

;Van der Pol Oscillator
;outputs a nonliniear oscillation
;inputs: a_excitation, k_frequency in Hz (of the linear part), nonlinearity (0 < mu < ca. 0.7)

opcode	v_d_p, a, akk		

		setksmps	1
av		init		0
ax		init		0
ain,kfr,kmu	xin	
kc		=			2-2*cos(kfr*2*$M_PI/sr)
aa 		= 			-kc*ax + kmu*(1-ax*ax)*av
av		=			av + aa
ax  	= 			ax + av + ain
		xout			ax 

endop

instr 1
kaex	invalue	"aex"
kfex	invalue	"fex"
kamp	invalue	"amp"
kf		invalue	"freq"
kmu		invalue	"mu"
a1		oscil		kaex,kfex,1		
aout	v_d_p		a1,kf,kmu
		out			kamp*aout,a1*100

endin

</CsInstruments>
<CsScore>
f1 0 32768 10 1
i1 0 95 

</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>898</x>
 <y>63</y>
 <width>648</width>
 <height>782</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>234</r>
  <g>255</g>
  <b>246</b>
 </bgcolor>
 <bsbObject version="2" type="BSBConsole">
  <objectName/>
  <x>380</x>
  <y>251</y>
  <width>473</width>
  <height>179</height>
  <uuid>{e88384a4-2632-40b6-b9b8-2f37a6724bd0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <font>Courier</font>
  <fontsize>8</fontsize>
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
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName/>
  <x>380</x>
  <y>22</y>
  <width>472</width>
  <height>230</height>
  <uuid>{9c418435-b1aa-42b1-8a5b-d7aa4ae9b704}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>auto</modex>
  <modey>auto</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>freq</objectName>
  <x>83</x>
  <y>31</y>
  <width>34</width>
  <height>184</height>
  <uuid>{82ad9ba6-60ef-4947-ada7-dd2c926b583e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>494.56521739</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>mu</objectName>
  <x>147</x>
  <y>33</y>
  <width>34</width>
  <height>184</height>
  <uuid>{f6b798e2-fa40-493a-9476-6637ecda0ea3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.45108696</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>fex</objectName>
  <x>236</x>
  <y>30</y>
  <width>34</width>
  <height>184</height>
  <uuid>{bdcf2f0d-08a1-47e1-be55-eef445dff23b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <value>1239.13043478</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>aex</objectName>
  <x>298</x>
  <y>31</y>
  <width>34</width>
  <height>184</height>
  <uuid>{3c51b2ca-89fa-4e86-a9e2-044e06c06d14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.01000000</maximum>
  <value>0.00266304</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>86</x>
  <y>224</y>
  <width>34</width>
  <height>25</height>
  <uuid>{4a678c44-9344-4282-91ef-436cecfe2ff6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>freq</label>
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
  <x>144</x>
  <y>223</y>
  <width>34</width>
  <height>25</height>
  <uuid>{19e6aca7-3e65-4106-8510-3153d2e69e13}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>mu</label>
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
  <x>237</x>
  <y>221</y>
  <width>34</width>
  <height>25</height>
  <uuid>{8a9d46a0-c7b0-4a6f-adb8-a40929739761}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>fexÂ
Â
</label>
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
  <x>294</x>
  <y>220</y>
  <width>34</width>
  <height>25</height>
  <uuid>{3d049cf0-a933-4f37-a421-0cf72b304bfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>aexÂ
</label>
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
  <x>252</x>
  <y>249</y>
  <width>68</width>
  <height>26</height>
  <uuid>{7e8b5e71-c3b2-4714-93fe-4d66ec718382}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>excitation</label>
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
  <x>67</x>
  <y>253</y>
  <width>68</width>
  <height>26</height>
  <uuid>{4fb5cccf-944d-4962-bf5e-4af66483f368}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>van der polÂ
</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>amp</objectName>
  <x>20</x>
  <y>34</y>
  <width>34</width>
  <height>184</height>
  <uuid>{a360ab07-3e47-4839-a571-0dac72cce072}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.09510900</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>21</x>
  <y>223</y>
  <width>34</width>
  <height>25</height>
  <uuid>{e01ad54d-5a7b-4239-83a1-24d3cd5d9ea6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>amp</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>amp</objectName>
  <x>8</x>
  <y>1</y>
  <width>56</width>
  <height>25</height>
  <uuid>{135c6137-0a20-4e01-943e-59a1909d6fa4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.0978</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>freq</objectName>
  <x>73</x>
  <y>1</y>
  <width>56</width>
  <height>25</height>
  <uuid>{2295d647-aea2-4933-84fd-0f796ed7fc3c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>494.565</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>mu</objectName>
  <x>135</x>
  <y>1</y>
  <width>56</width>
  <height>25</height>
  <uuid>{f10ba868-087b-4c91-b979-7f990f343d97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.451</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>aex</objectName>
  <x>287</x>
  <y>1</y>
  <width>56</width>
  <height>25</height>
  <uuid>{5e077898-1361-413c-8f90-931137066821}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.003</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>fex</objectName>
  <x>221</x>
  <y>1</y>
  <width>56</width>
  <height>25</height>
  <uuid>{6bced383-29e4-433f-abf4-830beb4d7f30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1239.130</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>10</x>
  <y>310</y>
  <width>346</width>
  <height>151</height>
  <uuid>{a2549209-2285-41df-8d36-5c68efb75e5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>1.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>7</x>
  <y>475</y>
  <width>350</width>
  <height>150</height>
  <uuid>{b252e380-e541-4071-9f61-679c0aac23f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>2.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="420" y="293" width="596" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

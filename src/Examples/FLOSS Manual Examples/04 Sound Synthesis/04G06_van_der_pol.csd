<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -odac
</CsOptions>
<CsInstruments>

sr      =  44100
ksmps   =  32
nchnls  =  2
0dbfs 	 = 1

;Van der Pol Oscillator
;outputs a nonliniear oscillation
;inputs: a_excitation, k_frequency in Hz (of the linear part), nonlinearity (0 < mu < ca. 0.7)

opcode	v_d_p, a, akk

        setksmps 1
av      init    0
ax      init    0
ain,kfr,kmu xin
kc      =       2-2*cos(kfr*2*$M_PI/sr)
aa      =       -kc*ax + kmu*(1-ax*ax)*av
av      =       av + aa
ax      =       ax + av + ain
        xout    ax

endop

instr 1
kaex    invalue "aex"
kfex    invalue "fex"
kamp    invalue "amp"
kf      invalue "freq"
kmu     invalue "mu"
a1      oscil   kaex,kfex,1
aout    v_d_p   a1,kf,kmu
        outs    kamp*aout,a1*100

endin
</CsInstruments>
<CsScore>
f1 0 32768 10 1
i1 0 95 

</CsScore>
</CsoundSynthesizer>
;example by martin neukom
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
  <uuid>{7ca21407-b7bd-499b-8f63-0dd8d20881da}</uuid>
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
  <uuid>{6f916395-2560-464d-b174-d8d29e343da9}</uuid>
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
  <uuid>{a9a9c39c-8ab3-409a-9cb1-917def558488}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>347.82608696</value>
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
  <uuid>{1dbeb129-3bd8-47d4-acf9-075245e9a0fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.54347826</value>
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
  <uuid>{feb36ec6-ab64-4532-a795-82ced939e1d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <value>782.60869565</value>
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
  <uuid>{323641a0-6fc5-467d-9605-12854b6d21b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.01000000</maximum>
  <value>0.00201087</value>
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
  <uuid>{e83b7e51-cdc7-4be4-ac8d-c5578fa6d8ad}</uuid>
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
  <uuid>{f45a1163-aabf-4b81-b088-16d326767bfd}</uuid>
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
  <uuid>{b710b25d-df8b-49e2-adf9-c39ef33e5e42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>fex

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
  <uuid>{6266a975-c3b6-4887-b908-a1df3428d50c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>aex
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
  <uuid>{4c0873d1-dcfc-402c-b16a-bb71a8fd720d}</uuid>
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
  <uuid>{ece7f592-e69c-4f1a-9e4d-88d54bd4490c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>van der pol
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
  <uuid>{cafb4894-868b-4539-ae2c-6ca4bf9d08eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.11141304</value>
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
  <uuid>{b7f47cef-1178-4bbf-b4ef-f49ef6051d5c}</uuid>
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
  <uuid>{18a816e1-379c-4adc-9999-1ba5bf1b4bf4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.111</label>
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
  <uuid>{58f75601-0f9e-42ce-8586-a6a43c80bc00}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>347.826</label>
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
  <uuid>{c7d24a1a-c476-4fc8-93df-4fcc61a07caf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.543</label>
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
  <uuid>{26d80db9-f5f0-4d67-85f7-97ffeee09005}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.002</label>
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
  <uuid>{53b89138-a6a6-48ea-bf6c-de5c1bff69ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>782.609</label>
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
  <uuid>{3d37aa10-7ee6-4d22-b026-4772dc3a7e42}</uuid>
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
  <uuid>{d231512d-030d-4a9d-8c2e-c5f0353f80b8}</uuid>
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

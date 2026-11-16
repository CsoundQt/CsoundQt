<CsoundSynthesizer>
<CsInstruments>


gitab = ftgen(0, 0, 10, 2, 0)

instr 1
  asig  = oscil(1, chnget:k("freq"), -1)
  asig *= interp(lag(chnget:k("amp"), 0.1))
  out(asig, asig)
endin

instr sliders
  if eventcycles() == 0 then
    chnset gitab, "plot"
  endif
  if metro(20) == 1 then
    for idx:k in [0 ... ftlen(gitab) - 1] do
      kval = chnget(sprintfk("v%d", idx))
      tabw kval, idx, gitab 
    od
    outvalue "plot/update", k(1)
  endif
endin

schedule(sliders, 0, -1)
schedule(1, 0, -1)

</CsInstruments>
</CsoundSynthesizer>
























<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>608</x>
 <y>211</y>
 <width>408</width>
 <height>357</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#eff0f1</bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>35</x>
  <y>373</y>
  <width>411</width>
  <height>456</height>
  <uuid>{78867b15-5b45-44c7-8d01-f9c321d1b1fc}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Flat Sliders</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>14</fontsize>
  <padding>12</padding>
  <locked>true</locked>
  <color>#1f2223</color>
  <bgcolor mode="background">#d8d8d8</bgcolor>
  <bordercolor>#e7aab3</bordercolor>
  <bordermode>true</bordermode>
  <borderradius>7</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>9</y>
  <width>178</width>
  <height>45</height>
  <uuid>{c5f4063e-4a46-4f9d-96db-839bea9a983f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Slider Widget</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>24</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#bfccea</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>59</y>
  <width>396</width>
  <height>87</height>
  <uuid>{7650f5b0-e83a-46a4-ba7f-45a47f71997e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Sliders are used to send and receive data from the running Csound using channels. If a slider's width is greater than its height it becomes a horizontal slider. You can set a slider's range in it's properties.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>12</fontsize>
  <padding>8</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="background">#cbd2ea</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>amp</objectName>
  <x>79</x>
  <y>209</y>
  <width>20</width>
  <height>150</height>
  <uuid>{a99d91b7-f92c-4044-a927-70a2943b968e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.34666667</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>false</flatStyle>
  <bgcolor>#f3f3f3</bgcolor>
  <foreground>#202020</foreground>
  <fillcolor/>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>12</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>freq</objectName>
  <x>104</x>
  <y>179</y>
  <width>300</width>
  <height>23</height>
  <uuid>{dfc109a0-ff5a-40e4-9a56-bb67e10acb6a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>100.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>256.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>false</flatStyle>
  <bgcolor>#f3f3f3</bgcolor>
  <foreground>#202020</foreground>
  <fillcolor/>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>12</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>87</x>
  <y>155</y>
  <width>331</width>
  <height>26</height>
  <uuid>{6b918bc4-f76f-460e-8f7b-5054495f2143}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Frequency - from 100 to 1000 on channel 'freq'</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>12</x>
  <y>234</y>
  <width>66</width>
  <height>111</height>
  <uuid>{baae2608-4500-4d99-99f3-941f5e2b5a84}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amplitude (from 0 to 0.5 on channel 'amp')</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>104</x>
  <y>209</y>
  <width>300</width>
  <height>150</height>
  <uuid>{9d18e25d-d310-4e60-9109-541fdad0d7df}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2/>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>TriggerUp</triggermode>
  <antialias>true</antialias>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>v0</objectName>
  <x>67</x>
  <y>504</y>
  <width>24</width>
  <height>150</height>
  <uuid>{83e2a3e1-f8fb-4e78-b94e-1ad2105d6414}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.76666667</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#efefef</bgcolor>
  <foreground>#3e3e3e</foreground>
  <fillcolor/>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>10</thumbWidth>
  <thumbPadding>1</thumbPadding>
  <thumbRadius>3</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>v1</objectName>
  <x>102</x>
  <y>504</y>
  <width>24</width>
  <height>150</height>
  <uuid>{7d445a12-9789-4a91-88d7-7d6845416677}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.54000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#efefef</bgcolor>
  <foreground>#747474</foreground>
  <fillcolor>#a8a8a8</fillcolor>
  <bordercolor>#8c8c8c</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>0</borderRadius>
  <thumbWidth>5</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>nudge</backgroundMode>
  <rulermode>hide</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBTableDisplay" version="2">
  <objectName>plot</objectName>
  <x>68</x>
  <y>665</y>
  <width>350</width>
  <height>150</height>
  <uuid>{7bfc5ae1-3306-40d0-90b6-9c40e7b64219}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <foreground>#ffc103</foreground>
  <background>#303030</background>
  <gridcolor>#48a0a0a0</gridcolor>
  <samplerate>1</samplerate>
  <range>0.00</range>
  <linewidth>1</linewidth>
  <plottype>filledline</plottype>
  <pointradius>3</pointradius>
  <zoom>1.000000</zoom>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>v2</objectName>
  <x>137</x>
  <y>504</y>
  <width>24</width>
  <height>150</height>
  <uuid>{adfd8ec9-34b3-431e-8ef1-68f69f7809b1}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.45333333</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#c77a73</bgcolor>
  <foreground>#ffc299</foreground>
  <fillcolor/>
  <bordercolor>#a86363</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>10</thumbWidth>
  <thumbPadding>1</thumbPadding>
  <thumbRadius>3</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>v3</objectName>
  <x>173</x>
  <y>504</y>
  <width>24</width>
  <height>150</height>
  <uuid>{4bf0700f-78c3-43eb-a487-713d9cce8e34}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.77333333</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#c77a73</bgcolor>
  <foreground>#ffc299</foreground>
  <fillcolor>#daa683</fillcolor>
  <bordercolor>#a86363</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>10</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>3</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>v4</objectName>
  <x>209</x>
  <y>504</y>
  <width>12</width>
  <height>150</height>
  <uuid>{2466397f-3167-4684-905a-665404779fdc}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.64000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#efefef</bgcolor>
  <foreground>#747474</foreground>
  <fillcolor>#a8a8a8</fillcolor>
  <bordercolor>#8c8c8c</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>0</borderRadius>
  <thumbWidth>10</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>6</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>nudge</backgroundMode>
  <rulermode>hide</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>v5</objectName>
  <x>233</x>
  <y>504</y>
  <width>12</width>
  <height>150</height>
  <uuid>{f7070ca2-64ea-4be9-953e-3160576b1b14}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.34666667</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#94d6ff</bgcolor>
  <foreground>#00aaff</foreground>
  <fillcolor>#0079b6</fillcolor>
  <bordercolor>#00aaff</bordercolor>
  <borderWidth>0</borderWidth>
  <borderRadius>0</borderRadius>
  <thumbWidth>12</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>5</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>nudge</backgroundMode>
  <rulermode>hide</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>v6</objectName>
  <x>257</x>
  <y>504</y>
  <width>12</width>
  <height>150</height>
  <uuid>{27f8e484-ebee-4b56-b6a8-b3fa0238a7bb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.53333333</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#94d6ff</bgcolor>
  <foreground>#00aaff</foreground>
  <fillcolor>#0079b6</fillcolor>
  <bordercolor>#00aaff</bordercolor>
  <borderWidth>0</borderWidth>
  <borderRadius>0</borderRadius>
  <thumbWidth>2</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>nudge</backgroundMode>
  <rulermode>hide</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>v7</objectName>
  <x>281</x>
  <y>499</y>
  <width>32</width>
  <height>161</height>
  <uuid>{9240c149-8862-45c2-bf22-bce27b082111}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.70807453</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#efefef</bgcolor>
  <foreground>#3e3e3e</foreground>
  <fillcolor/>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>0</borderRadius>
  <thumbWidth>2</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>compact</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>v8</objectName>
  <x>325</x>
  <y>396</y>
  <width>34</width>
  <height>264</height>
  <uuid>{abc09ac8-879d-439d-8757-e3afc5adf03c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.31818182</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#efefef</bgcolor>
  <foreground>#3e3e3e</foreground>
  <fillcolor/>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>0</borderRadius>
  <thumbWidth>2</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>full</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>v9</objectName>
  <x>371</x>
  <y>396</y>
  <width>34</width>
  <height>264</height>
  <uuid>{2185b81d-1c5d-448c-acb4-879fa17a7dee}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>2.00000000</exponent>
  <value>0.40015209</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#efefef</bgcolor>
  <foreground>#3e3e3e</foreground>
  <fillcolor/>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>1</borderWidth>
  <borderRadius>0</borderRadius>
  <thumbWidth>2</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>full</rulermode>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>44</x>
  <y>402</y>
  <width>273</width>
  <height>91</height>
  <uuid>{df505870-b5d9-4b6f-b17c-582264989c5b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>"flat" (native) sliders can be greatly customized: colors for each element, roundness, padding. There is an attached ruler with two modes, compact and full. You can customize what happens when you clik on the background</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#434343</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

<CsoundSynthesizer>
<CsOptions>
;--env:SADIR=
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; Change these files for your platform (Currently default installation on OS X)
#define FILE1 #"/Library/Frameworks/CsoundLib.framework/Resources/samples/hrtf-44100-left.dat"#
#define FILE2 #"/Library/Frameworks/CsoundLib.framework/Resources/samples/hrtf-44100-right.dat"#

#define HRTFCOMPACT #"/Library/Frameworks/CsoundLib.framework/Resources/Manual/Examples/HRTFCompact"#
#define FOX #"/Library/Frameworks/CsoundLib.framework/Resources/Manual/Examples/fox.wav"#

instr 1
ksource invalue "source"
kamp invalue "amp"
kpfreq invalue "pfreq"

if ksource == 0 then
	asig noise kamp, 0

elseif ksource == 1 then
	asig pinkish kamp * 0.7

elseif ksource == 2 then
	asig vco2 kamp, kpfreq, 

elseif ksource == 3 then
	kphs phasor 1
	asig noise kamp * ( kphs > 0.1 ? 0 : 1 ), 0

elseif ksource == 4 then
	asig diskin2 $FOX, 1, 0, 1
endif

kx invalue "x"
ky invalue "y"
kz invalue "z"

kx = -kx
kz = -kz
;kx = 0.5 - kx
;ky = ky - 0.5
;kz = 0.5 - kz

if kz > 0 then
	kAz = 360 * taninv( kx/kz ) / (2 * $M_PI.)
elseif kz < 0 then
	if kx > 0 then
		kAz = 180 + (360 * taninv( kx/kz ) / (2 * $M_PI.))
	else
		kAz = (360 * taninv( kx/kz ) / (2 * $M_PI.)) - 180
	endif
endif
kAz = kAz + 180

kEl = 360 * taninv( ky/sqrt(kx^2 + kz^2) ) / (2 * $M_PI.)

outvalue "az", kAz
outvalue "el", kEl

kmethod invalue "hrtfmethod"
if kmethod == 0 then
	aleft, aright  hrtfer  asig * 200, kAz, kEl, $HRTFCOMPACT
elseif kmethod == 1 then
	aleft, aright  hrtfmove2  asig, kAz, kEl, $FILE1, $FILE2 ;[,ioverlap, iradius, isr]
elseif kmethod == 2 then
	aleft, aright  pan2  asig * 0.6, 0.5 -(kx/2)
endif

outs aleft, aright
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>922</x>
 <y>327</y>
 <width>715</width>
 <height>488</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>158</r>
  <g>204</g>
  <b>243</b>
 </bgcolor>
 <bsbObject version="2" type="BSBController">
  <objectName>z</objectName>
  <x>399</x>
  <y>35</y>
  <width>231</width>
  <height>218</height>
  <uuid>{a8f462d3-4569-4f20-949d-e6d55d85a494}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>y</objectName2>
  <xMin>-1.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>-1.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.83486239</xValue>
  <yValue>0.10091743</yValue>
  <type>point</type>
  <pointsize>3</pointsize>
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
 <bsbObject version="2" type="BSBController">
  <objectName>x</objectName>
  <x>59</x>
  <y>34</y>
  <width>231</width>
  <height>218</height>
  <uuid>{3a09dfd9-6eaa-48a0-a41e-8f71083674a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>z</objectName2>
  <xMin>-1.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>-1.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-0.03030303</xValue>
  <yValue>0.83486239</yValue>
  <type>point</type>
  <pointsize>3</pointsize>
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
  <x>357</x>
  <y>128</y>
  <width>43</width>
  <height>25</height>
  <uuid>{cb7232c3-fc1d-4b58-92ec-1f51713c3761}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Back</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <x>500</x>
  <y>6</y>
  <width>43</width>
  <height>25</height>
  <uuid>{dea3c24c-08a8-44ad-b478-9372a6f606db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Up</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <x>496</x>
  <y>260</y>
  <width>43</width>
  <height>25</height>
  <uuid>{41d060df-9b3c-44e2-8e9b-eafc81acd2b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Down</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <x>140</x>
  <y>3</y>
  <width>74</width>
  <height>32</height>
  <uuid>{97ff510d-a356-472c-8c9c-86c72ba839fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Front</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>16</fontsize>
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
  <x>154</x>
  <y>260</y>
  <width>53</width>
  <height>25</height>
  <uuid>{e0b74218-0980-4905-893f-e3e2961285e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Back</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <x>296</x>
  <y>129</y>
  <width>43</width>
  <height>25</height>
  <uuid>{8088586c-a7ce-4326-8ba2-00a002040232}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Right</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <x>13</x>
  <y>126</y>
  <width>43</width>
  <height>25</height>
  <uuid>{48962620-4262-40b7-8464-bd9879947bc5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Left</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>source</objectName>
  <x>14</x>
  <y>392</y>
  <width>115</width>
  <height>25</height>
  <uuid>{7ee1af79-8fe8-47b1-9394-903753bc849b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>white noise</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>pink noise</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>pulse</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>noise bursts</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>voice</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>3</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>pfreq</objectName>
  <x>185</x>
  <y>320</y>
  <width>83</width>
  <height>81</height>
  <uuid>{66136768-361a-40ff-81af-e3bfb27092fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>600.00000000</maximum>
  <value>200.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>pfreq</objectName>
  <x>188</x>
  <y>402</y>
  <width>80</width>
  <height>25</height>
  <uuid>{45a52807-ce3e-4ff2-8492-bcd50788c53f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>212.1212</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>amp</objectName>
  <x>147</x>
  <y>301</y>
  <width>20</width>
  <height>100</height>
  <uuid>{f1cc4f20-d9a3-4af1-80a2-e7858bda0427}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.30000000</maximum>
  <value>0.19800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>az</objectName>
  <x>307</x>
  <y>185</y>
  <width>80</width>
  <height>25</height>
  <uuid>{d3639aa6-d628-42fe-81a9-01cec71ee712}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>357.921</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName>el</objectName>
  <x>307</x>
  <y>238</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7035393a-26b5-4bb3-82dc-71240d02ddd4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>6.888</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>slider21</objectName>
  <x>503</x>
  <y>150</y>
  <width>20</width>
  <height>63</height>
  <uuid>{b1e97c66-07c8-4c46-89ed-f160001c047a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.44444400</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>slider21</objectName>
  <x>144</x>
  <y>126</y>
  <width>65</width>
  <height>27</height>
  <uuid>{b9e7b21b-17dd-4154-9e70-8ed7d05fd2b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.44615400</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>309</x>
  <y>161</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0bd1fdd3-341b-46d1-814a-c34b2a79dc01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Azimuth</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <x>309</x>
  <y>214</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3d644e7a-6399-4d17-a7e8-648620fe0e9f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Elevation</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>hrtfmethod</objectName>
  <x>14</x>
  <y>341</y>
  <width>111</width>
  <height>26</height>
  <uuid>{17009160-f2d0-4b50-b393-7be0b527e888}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>hrtfer</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>hrtfmove2</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>amp pan</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>280</x>
  <y>317</y>
  <width>147</width>
  <height>30</height>
  <uuid>{a4548484-c709-4b76-80f9-69369e2be026}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue> </stringvalue>
  <text>Start</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Stop</objectName>
  <x>280</x>
  <y>346</y>
  <width>147</width>
  <height>29</height>
  <uuid>{d5e74313-bb18-41e2-9450-27a5d92213d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue> </stringvalue>
  <text>Stop</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>316</y>
  <width>80</width>
  <height>25</height>
  <uuid>{08d361e5-93de-45e9-a235-a912321a6b36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Method</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <x>14</x>
  <y>368</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8f20e3fd-04c9-4985-87aa-6db5bf168ae8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Signal</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <x>449</x>
  <y>316</y>
  <width>158</width>
  <height>119</height>
  <uuid>{377f370d-b852-417d-8d2a-c51c6402b4df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Binaural panning</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>28</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>153</r>
   <g>237</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>55</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>140</x>
  <y>402</y>
  <width>42</width>
  <height>26</height>
  <uuid>{d53f43ef-447e-4d45-aba3-cc3851bc28a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Level</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <x>483</x>
  <y>390</y>
  <width>97</width>
  <height>36</height>
  <uuid>{c8bd5b2d-335e-4f30-826d-47627f15ce20}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Listen on headphones!</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <x>632</x>
  <y>126</y>
  <width>71</width>
  <height>37</height>
  <uuid>{86cb397b-f790-444f-a258-d96236c92961}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Front</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>16</fontsize>
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
  <x>510</x>
  <y>130</y>
  <width>26</width>
  <height>11</height>
  <uuid>{20a0ab4c-12e0-46a8-aa2a-1f2a18d05874}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>28</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>153</r>
   <g>237</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>490</x>
  <y>116</y>
  <width>40</width>
  <height>40</height>
  <uuid>{1dc129c2-4b43-4922-8dee-388d9bb0e000}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>28</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>153</r>
   <g>237</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>170</x>
  <y>115</y>
  <width>12</width>
  <height>26</height>
  <uuid>{31f50bc1-7aa7-40bf-862b-38763d3a2617}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>28</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>153</r>
   <g>237</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>156</x>
  <y>120</y>
  <width>40</width>
  <height>40</height>
  <uuid>{8e66eab2-b53e-45cf-aa83-a1d5e1e9c856}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>153</r>
   <g>237</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>2</borderwidth>
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
WindowBounds: 922 327 715 488
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {40606, 52428, 62451}
ioMeter {399, 35} {231, 218} {0, 59904, 0} "z" 0.834862 "y" 0.100917 point 3 0 mouse
ioMeter {59, 34} {231, 218} {0, 59904, 0} "x" -0.030303 "z" 0.834862 point 3 0 mouse
ioText {357, 128} {43, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Back
ioText {500, 6} {43, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Up
ioText {496, 260} {43, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Down
ioText {140, 3} {74, 32} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Front
ioText {154, 260} {53, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Back
ioText {296, 129} {43, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Right
ioText {13, 126} {43, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Left
ioMenu {14, 392} {115, 25} 3 303 "white noise,pink noise,pulse,noise bursts,voice" source
ioKnob {185, 320} {83, 81} 600.000000 0.000000 0.010000 200.000000 pfreq
ioText {188, 402} {80, 25} label 212.121200 0.00100 "pfreq" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 212.1212
ioSlider {147, 301} {20, 100} 0.000000 0.300000 0.198000 amp
ioText {307, 185} {80, 25} label 357.921265 0.00100 "az" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 357.921
ioText {309, 238} {80, 25} label 6.887930 0.00100 "el" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 6.888
ioSlider {503, 150} {20, 63} 0.000000 1.000000 0.444444 slider21
ioSlider {144, 126} {65, 27} 0.000000 1.000000 0.446154 slider21
ioText {309, 161} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Azimuth
ioText {309, 214} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Elevation
ioMenu {14, 341} {111, 26} 1 303 "hrtfer,hrtfmove2,amp pan" hrtfmethod
ioButton {280, 317} {147, 30} value 1.000000 "_Play" "Start" "/" 
ioButton {280, 346} {147, 29} value 1.000000 "_Stop" "Stop" "/" 
ioText {14, 316} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Method
ioText {14, 368} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Signal
ioText {441, 316} {187, 117} label 0.000000 0.00100 "" center "Lucida Grande" 28 {0, 0, 0} {39168, 60672, 65280} nobackground noborder Binaural panning
ioText {140, 402} {42, 26} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Level
ioText {497, 396} {97, 36} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Listen on headphones!
ioText {632, 126} {71, 37} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Front
ioText {388, 272} {32, 30} label 0.000000 0.00100 "" center "Lucida Grande" 28 {0, 0, 0} {39168, 60672, 65280} nobackground noborder 
ioText {491, 120} {40, 40} label 0.000000 0.00100 "" center "Lucida Grande" 28 {0, 0, 0} {39168, 60672, 65280} nobackground noborder 
ioText {530, 150} {26, 11} label 0.000000 0.00100 "" center "Lucida Grande" 28 {0, 0, 0} {39168, 60672, 65280} nobackground noborder 
ioText {156, 120} {40, 40} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {39168, 60672, 65280} nobackground noborder 
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="622" y="48" width="604" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

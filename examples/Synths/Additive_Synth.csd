<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 --midi-velocity=5
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

maxalloc 1,1  ; Monophonic synth
massign 0, 1

instr 1 ; Additive Synth

kgoto skipinit
if p4 != 0 then
	outvalue "freq", p4
endif
skipinit:

kreset invalue "reset"
kresettrig changed kreset

if kresettrig == 1 then
	if kreset == 1 then
		reinit skipinit
	endif
endif

kamp1  invalue  "amp1"
kamp2  invalue  "amp2"
kamp3  invalue  "amp3"
kamp4  invalue  "amp4"
kamp5  invalue  "amp5"
kamp6  invalue  "amp6"
kamp7  invalue  "amp7"
kamp8  invalue  "amp8"
kamp9  invalue  "amp9"
kamp10  invalue  "amp10"
kamp11  invalue  "amp11"
kamp12  invalue  "amp12"

kfactor1  invalue  "fac1"
kfactor2  invalue  "fac2"
kfactor3  invalue  "fac3"
kfactor4  invalue  "fac4"
kfactor5  invalue  "fac5"
kfactor6  invalue  "fac6"
kfactor7  invalue  "fac7"
kfactor8  invalue  "fac8"
kfactor9  invalue  "fac9"
kfactor10  invalue  "fac10"
kfactor11  invalue  "fac11"
kfactor12  invalue  "fac12"

kfreq invalue "freq"
kfreq portk kfreq, 0.02, i(kfreq) ; Smooth frequency values

kfreq1 = kfreq * kfactor1
kfreq2 = kfreq * kfactor2
kfreq3 = kfreq * kfactor3
kfreq4 = kfreq * kfactor4
kfreq5 = kfreq * kfactor5
kfreq6 = kfreq * kfactor6
kfreq7 = kfreq * kfactor7
kfreq8 = kfreq * kfactor8
kfreq9 = kfreq * kfactor9
kfreq10 = kfreq * kfactor10
kfreq11 = kfreq * kfactor11
kfreq12 = kfreq * kfactor12

aosc1 poscil3 kamp1, kfreq1, 1, 0
aosc2 poscil3 kamp2, kfreq2, 1, 0
aosc3 poscil3 kamp3, kfreq3, 1, 0
aosc4 poscil3 kamp4, kfreq4, 1, 0
aosc5 poscil3 kamp5, kfreq5, 1, 0
aosc6 poscil3 kamp6, kfreq6, 1, 0
aosc7 poscil3 kamp7, kfreq7, 1, 0
aosc8 poscil3 kamp8, kfreq8, 1, 0
aosc9 poscil3 kamp9, kfreq9, 1, 0
aosc10 poscil3 kamp10, kfreq10, 1, 0
aosc11 poscil3 kamp11, kfreq11, 1, 0
aosc12 poscil3 kamp12, kfreq12, 1, 0

outvalue "freq1", kfreq1
outvalue "freq2", kfreq2
outvalue "freq3", kfreq3
outvalue "freq4", kfreq4
outvalue "freq5", kfreq5
outvalue "freq6", kfreq6
outvalue "freq7", kfreq7
outvalue "freq8", kfreq8
outvalue "freq9", kfreq9
outvalue "freq10", kfreq10
outvalue "freq11", kfreq11
outvalue "freq12", kfreq12

asig = aosc1 + aosc2 + aosc3 + aosc4 + aosc5 + aosc6 + aosc7 + aosc8 + aosc9 + aosc10 + aosc11 + aosc12

klevel invalue "level"
outs asig*klevel, asig*klevel
endin

instr 99 ; Always on
krel invalue "rel"
kfreq invalue "freq"

ktrig changed krel

if ktrig == 1 then
	if krel == 0 then
		outvalue "fac1", 1
		outvalue "fac2", 2
		outvalue "fac3", 3
		outvalue "fac4", 4
		outvalue "fac5", 5
		outvalue "fac6", 6
		outvalue "fac7", 7
		outvalue "fac8", 8
		outvalue "fac9", 9
		outvalue "fac10", 10
		outvalue "fac11", 11
		outvalue "fac12", 12
	elseif krel == 1 then
		outvalue "fac1", 1
		outvalue "fac2", 3
		outvalue "fac3", 5
		outvalue "fac4", 7
		outvalue "fac5", 9
		outvalue "fac6", 11
		outvalue "fac7", 13
		outvalue "fac8", 15
		outvalue "fac9", 17
		outvalue "fac10", 19
		outvalue "fac11", 21
		outvalue "fac12", 23
	elseif krel == 2 then
		outvalue "fac1", 1
		outvalue "fac2", 1.22
		outvalue "fac3", 1.3
		outvalue "fac4", 1.35
		outvalue "fac5", 1.45
		outvalue "fac6", 1.64
		outvalue "fac7", 1.7
		outvalue "fac8", 1.78
		outvalue "fac9", 1.79
		outvalue "fac10", 1.81
		outvalue "fac11", 1.91
		outvalue "fac12", 1.98
	elseif krel == 3 then
		outvalue "fac1", 1
		outvalue "fac2", 2.22
		outvalue "fac3", 3.3
		outvalue "fac4", 4.35
		outvalue "fac5", 5.45
		outvalue "fac6", 6.64
		outvalue "fac7", 7.7
		outvalue "fac8", 8.78
		outvalue "fac9", 9.79
		outvalue "fac10", 10.81
		outvalue "fac11", 11.91
		outvalue "fac12", 12.98
	elseif krel == 4 then
		outvalue "fac1", 1.02
		outvalue "fac2", 1.05
		outvalue "fac3", 1.12
		outvalue "fac4", 1.14
		outvalue "fac5", 1.19
		outvalue "fac6", 1.21
		outvalue "fac7", 1.26
		outvalue "fac8", 1.29
		outvalue "fac9", 1.32
		outvalue "fac10", 1.35
		outvalue "fac11", 1.36
		outvalue "fac12", 1.39
	endif
endif
endin

instr 100 ; Set amplitude to 1 over partial number
outvalue "amp1", 1/1
outvalue "amp2", 1/2
outvalue "amp3", 1/3
outvalue "amp4", 1/4
outvalue "amp5", 1/5
outvalue "amp6", 1/6
outvalue "amp7", 1/7
outvalue "amp8", 1/8
outvalue "amp9", 1/9
outvalue "amp10", 1/10
outvalue "amp11", 1/11
outvalue "amp12", 1/12
turnoff
endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1

i 99 0 3600
e
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>504</x>
 <y>215</y>
 <width>714</width>
 <height>556</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>162</r>
  <g>123</g>
  <b>134</b>
 </bgcolor>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp1</objectName>
  <x>26</x>
  <y>55</y>
  <width>229</width>
  <height>22</height>
  <uuid>{8f35311f-b1de-4102-a398-67c91ea07918}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp2</objectName>
  <x>26</x>
  <y>80</y>
  <width>229</width>
  <height>22</height>
  <uuid>{4bbb9e11-cb05-42f7-a339-f4465c9fbc79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp3</objectName>
  <x>26</x>
  <y>105</y>
  <width>229</width>
  <height>22</height>
  <uuid>{e6c9e267-123f-469c-b889-324d931b71cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.33333334</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp4</objectName>
  <x>26</x>
  <y>130</y>
  <width>229</width>
  <height>22</height>
  <uuid>{ba049c64-6ccc-4cd7-86df-d012b6de9f4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.25000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp5</objectName>
  <x>27</x>
  <y>155</y>
  <width>229</width>
  <height>22</height>
  <uuid>{e2d6aae7-7c67-4865-90b2-6a1ef277f47f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp6</objectName>
  <x>27</x>
  <y>180</y>
  <width>229</width>
  <height>22</height>
  <uuid>{6a3307ea-85c7-4597-b0ae-1aee30062f00}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.16666667</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp7</objectName>
  <x>27</x>
  <y>205</y>
  <width>229</width>
  <height>22</height>
  <uuid>{6d26eb03-7f21-42a6-a0ad-dc1f957a5600}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.14285715</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp8</objectName>
  <x>27</x>
  <y>230</y>
  <width>229</width>
  <height>22</height>
  <uuid>{c41bbbe5-12a4-4785-b5c5-6f99055faaa6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.12500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp9</objectName>
  <x>27</x>
  <y>254</y>
  <width>229</width>
  <height>22</height>
  <uuid>{ab8904df-94fb-4dd1-9f29-48309cecd4f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.11111111</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp10</objectName>
  <x>27</x>
  <y>279</y>
  <width>229</width>
  <height>22</height>
  <uuid>{6b86995c-17cf-48f8-aa4d-a15134227d3a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp11</objectName>
  <x>27</x>
  <y>304</y>
  <width>229</width>
  <height>22</height>
  <uuid>{ffde6462-4842-4e24-80c6-8faae296d8e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.09090909</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp12</objectName>
  <x>27</x>
  <y>329</y>
  <width>229</width>
  <height>22</height>
  <uuid>{403e9314-9975-4c33-a565-a34f7898ed8e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.08333334</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>54</y>
  <width>17</width>
  <height>25</height>
  <uuid>{07eb6f30-1f03-43e7-b925-79e5053285b7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <x>8</x>
  <y>78</y>
  <width>17</width>
  <height>25</height>
  <uuid>{5e117d91-9f84-4f95-b936-3d48500a4dd3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <x>8</x>
  <y>103</y>
  <width>17</width>
  <height>25</height>
  <uuid>{9d8778ad-930b-4b7d-bff2-dcb3618659a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <x>8</x>
  <y>131</y>
  <width>17</width>
  <height>25</height>
  <uuid>{9cd04718-25a8-4d67-bde2-186cf8b7d792}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <x>9</x>
  <y>156</y>
  <width>17</width>
  <height>25</height>
  <uuid>{d67cfa00-2de6-4d16-86c4-76e414588fbc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>5</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <x>9</x>
  <y>180</y>
  <width>17</width>
  <height>25</height>
  <uuid>{106ed3af-374e-4bfc-8589-33e86de5f4b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>6</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <x>9</x>
  <y>202</y>
  <width>17</width>
  <height>25</height>
  <uuid>{0489460d-74e3-4d2a-844e-3542fa726b01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>7</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <x>9</x>
  <y>226</y>
  <width>17</width>
  <height>25</height>
  <uuid>{0883fd1b-d7a4-4d93-a754-4d656cd6f6fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>8</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <x>9</x>
  <y>251</y>
  <width>17</width>
  <height>25</height>
  <uuid>{b5acc978-ed0d-4bfe-ae29-da13b18e5d40}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>9</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <x>4</x>
  <y>278</y>
  <width>24</width>
  <height>25</height>
  <uuid>{1109b2e0-0596-4098-b768-298873ce1a8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>10</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <x>5</x>
  <y>303</y>
  <width>24</width>
  <height>25</height>
  <uuid>{338aeaa8-1b32-45b3-b9ff-391c96768026}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>11</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <x>5</x>
  <y>327</y>
  <width>24</width>
  <height>25</height>
  <uuid>{f1bcd243-cfd1-4f4d-89ea-ad71bd14b9d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>12</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>freq</objectName>
  <x>532</x>
  <y>100</y>
  <width>80</width>
  <height>80</height>
  <uuid>{03fa01c0-7bdf-42e1-996d-1c1ac5e9693d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>100.00000000</minimum>
  <maximum>1500.00000000</maximum>
  <value>408.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>freq</objectName>
  <x>532</x>
  <y>179</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2e6d424a-28c3-4ff5-b4f5-933e48e824bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>408.000</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <x>531</x>
  <y>82</y>
  <width>80</width>
  <height>25</height>
  <uuid>{68d380a7-9761-47af-841d-4c481cb34a6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Base Freq</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>4</x>
  <y>358</y>
  <width>692</width>
  <height>157</height>
  <uuid>{7714a116-c33e-4c9f-a74a-08e2d755a9f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>449</x>
  <y>37</y>
  <width>80</width>
  <height>316</height>
  <uuid>{a31a3232-12d7-4578-8fd1-fc0c754a0ce7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Freq. (Hz)</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq1</objectName>
  <x>455</x>
  <y>54</y>
  <width>68</width>
  <height>25</height>
  <uuid>{b6aa56a6-0461-411a-99db-17de94745fc9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>408.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq2</objectName>
  <x>454</x>
  <y>77</y>
  <width>68</width>
  <height>25</height>
  <uuid>{28192961-7a26-4324-981e-0205f19c95cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1224.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq3</objectName>
  <x>454</x>
  <y>103</y>
  <width>68</width>
  <height>25</height>
  <uuid>{398aee6d-f36e-48e3-b78b-eb0805361e27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2040.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq4</objectName>
  <x>456</x>
  <y>130</y>
  <width>68</width>
  <height>25</height>
  <uuid>{a0c61571-aafd-41a4-803a-bd70885657f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2856.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq5</objectName>
  <x>456</x>
  <y>155</y>
  <width>68</width>
  <height>25</height>
  <uuid>{2f754830-8992-4644-9679-2bebead73f35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3672.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq6</objectName>
  <x>456</x>
  <y>179</y>
  <width>68</width>
  <height>25</height>
  <uuid>{fae95509-286a-4165-bccb-c776d8349915}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4488.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq7</objectName>
  <x>454</x>
  <y>204</y>
  <width>68</width>
  <height>25</height>
  <uuid>{044b4975-d3bb-478d-8cd4-b289bda3f972}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>5304.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq8</objectName>
  <x>455</x>
  <y>229</y>
  <width>68</width>
  <height>25</height>
  <uuid>{e05e508c-7d3a-4ebd-8074-0eba3dfdbd35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>6120.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq9</objectName>
  <x>454</x>
  <y>254</y>
  <width>68</width>
  <height>25</height>
  <uuid>{5fb1d580-d296-46fc-adb5-6f65bcdabbbb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>6936.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq10</objectName>
  <x>455</x>
  <y>278</y>
  <width>68</width>
  <height>25</height>
  <uuid>{b6d36a20-2bfa-41d0-82db-5059d674e3c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>7752.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq11</objectName>
  <x>454</x>
  <y>304</y>
  <width>68</width>
  <height>25</height>
  <uuid>{25c0d557-8a8e-4ad9-8e48-03fbe4c1c1c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>8568.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>freq12</objectName>
  <x>452</x>
  <y>328</y>
  <width>68</width>
  <height>25</height>
  <uuid>{204a05ab-aef7-4f2a-b7a0-716f7d5c927c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>9384.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>level</objectName>
  <x>618</x>
  <y>122</y>
  <width>66</width>
  <height>60</height>
  <uuid>{761327be-ffd2-4596-84ae-6143f39d71a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.09000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>619</x>
  <y>179</y>
  <width>64</width>
  <height>25</height>
  <uuid>{fa7684d0-943d-46e5-946e-3613d27c1e8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Level</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <x>7</x>
  <y>5</y>
  <width>248</width>
  <height>43</height>
  <uuid>{ac86ad3b-364f-4573-a40b-42b364b30ccd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Additive syntheziser</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>33</r>
   <g>34</g>
   <b>36</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>531</x>
  <y>213</y>
  <width>166</width>
  <height>68</height>
  <uuid>{5f2052f6-5d9b-4574-8de2-77d7309696e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Partial relationship:</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>349</x>
  <y>37</y>
  <width>96</width>
  <height>316</height>
  <uuid>{e0ec5012-31b1-44c7-847f-8e3b7642df02}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Freq. Factor</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac1</objectName>
  <x>356</x>
  <y>54</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2431c940-8c9c-4315-99a3-f14ab46c846b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac2</objectName>
  <x>356</x>
  <y>79</y>
  <width>80</width>
  <height>25</height>
  <uuid>{6717f449-f565-49c6-b835-04c9259330f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac3</objectName>
  <x>356</x>
  <y>104</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5b685294-a68e-4412-ab53-92f83dc42c4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac4</objectName>
  <x>356</x>
  <y>127</y>
  <width>80</width>
  <height>25</height>
  <uuid>{cec07fa4-8898-46e1-9548-73442ee56218}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>7</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac5</objectName>
  <x>356</x>
  <y>153</y>
  <width>80</width>
  <height>25</height>
  <uuid>{52945398-307e-48d0-b898-1be76664cf1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>9</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac6</objectName>
  <x>356</x>
  <y>180</y>
  <width>80</width>
  <height>25</height>
  <uuid>{63efcda9-ee38-4a60-b0ea-be120e80c35a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>11</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac7</objectName>
  <x>356</x>
  <y>206</y>
  <width>80</width>
  <height>25</height>
  <uuid>{93992aaf-af39-4dad-b71b-42998c10c74d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>13</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac8</objectName>
  <x>356</x>
  <y>230</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2e32cb9c-24f1-4e8a-9f31-9d9402abaaf2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>15</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac9</objectName>
  <x>356</x>
  <y>254</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e42d43ff-a34c-4ac5-9b76-0d0ecd8b5921}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>17</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac10</objectName>
  <x>356</x>
  <y>278</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f1895083-3731-49bd-b648-d72607a15b77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>19</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac11</objectName>
  <x>356</x>
  <y>301</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c629f96e-9103-449d-9a51-18c00695e7bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>21</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>fac12</objectName>
  <x>356</x>
  <y>327</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ada65122-2724-4e35-8a55-6922dab0245c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>23</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>reset</objectName>
  <x>535</x>
  <y>286</y>
  <width>157</width>
  <height>30</height>
  <uuid>{776bb69f-006d-4b56-a851-4026d3f6bc2a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Reset Phase</text>
  <image>/</image>
  <eventLine>i 50 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp1</objectName>
  <x>263</x>
  <y>54</y>
  <width>80</width>
  <height>25</height>
  <uuid>{9e6fabff-f6b7-4a47-b074-f25bf9145ff0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp2</objectName>
  <x>263</x>
  <y>79</y>
  <width>80</width>
  <height>26</height>
  <uuid>{f1a1dcf8-7555-4b5a-bb1b-76b3927320bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp3</objectName>
  <x>263</x>
  <y>104</y>
  <width>80</width>
  <height>26</height>
  <uuid>{bb9e395e-ab97-4856-bed0-74249f174f5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.333333</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp4</objectName>
  <x>263</x>
  <y>129</y>
  <width>80</width>
  <height>25</height>
  <uuid>{eabed39f-6f49-4cf1-8852-6dd65fc96336}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.25</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp5</objectName>
  <x>263</x>
  <y>154</y>
  <width>80</width>
  <height>26</height>
  <uuid>{b91deb45-4b32-4ead-888a-95c8cbfa33b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp6</objectName>
  <x>263</x>
  <y>179</y>
  <width>80</width>
  <height>26</height>
  <uuid>{d487fb77-7196-447c-849b-ec7918c6e3a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.166667</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp7</objectName>
  <x>263</x>
  <y>203</y>
  <width>80</width>
  <height>25</height>
  <uuid>{869da178-d2b5-4f72-a3ca-3c9139fc97c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.142857</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp8</objectName>
  <x>263</x>
  <y>228</y>
  <width>80</width>
  <height>26</height>
  <uuid>{5cc5b726-0749-4238-a496-dd845a27e8fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp9</objectName>
  <x>263</x>
  <y>253</y>
  <width>80</width>
  <height>26</height>
  <uuid>{500f3d7c-530b-4939-a4a9-25c3666d90e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.111111</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp10</objectName>
  <x>263</x>
  <y>276</y>
  <width>80</width>
  <height>25</height>
  <uuid>{6d436f11-af2f-428b-9ce9-fc5981b2c38e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp11</objectName>
  <x>263</x>
  <y>301</y>
  <width>80</width>
  <height>26</height>
  <uuid>{7d27a697-c0e4-461d-a05a-2e9f8f878d9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.0909091</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp12</objectName>
  <x>263</x>
  <y>326</y>
  <width>80</width>
  <height>26</height>
  <uuid>{abef815e-ebd5-4da9-a238-2a58ab28b4fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.0833333</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>reset</objectName>
  <x>535</x>
  <y>320</y>
  <width>158</width>
  <height>31</height>
  <uuid>{31bebdce-2caa-4c88-adf4-27e2b193da6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Amp = 1/n</text>
  <image>/</image>
  <eventLine>i100 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>rel</objectName>
  <x>537</x>
  <y>233</y>
  <width>155</width>
  <height>25</height>
  <uuid>{fa7b55f0-4387-47e0-ab2e-28dab55622d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>all harmonics</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>even harmonics</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>inharmonic1</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>inharmonic2</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>inharmonic3</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>536</x>
  <y>44</y>
  <width>156</width>
  <height>29</height>
  <uuid>{5b431f74-b61a-45bb-ac46-3ea16cad6cc3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Note</text>
  <image>/</image>
  <eventLine>i1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
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
ioView background {41634, 31611, 34438}
ioSlider {26, 55} {229, 22} 0.000000 1.000000 1.000000 amp1
ioSlider {26, 80} {229, 22} 0.000000 1.000000 0.500000 amp2
ioSlider {26, 105} {229, 22} 0.000000 1.000000 0.333333 amp3
ioSlider {26, 130} {229, 22} 0.000000 1.000000 0.250000 amp4
ioSlider {27, 155} {229, 22} 0.000000 1.000000 0.200000 amp5
ioSlider {27, 180} {229, 22} 0.000000 1.000000 0.166667 amp6
ioSlider {27, 205} {229, 22} 0.000000 1.000000 0.142857 amp7
ioSlider {27, 230} {229, 22} 0.000000 1.000000 0.125000 amp8
ioSlider {27, 254} {229, 22} 0.000000 1.000000 0.111111 amp9
ioSlider {27, 279} {229, 22} 0.000000 1.000000 0.100000 amp10
ioSlider {27, 304} {229, 22} 0.000000 1.000000 0.090909 amp11
ioSlider {27, 329} {229, 22} 0.000000 1.000000 0.083333 amp12
ioText {8, 54} {17, 25} label 1.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 1
ioText {8, 78} {17, 25} label 2.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 2
ioText {8, 103} {17, 25} label 3.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 3
ioText {8, 131} {17, 25} label 4.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 4
ioText {9, 156} {17, 25} label 5.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 5
ioText {9, 180} {17, 25} label 6.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 6
ioText {9, 202} {17, 25} label 7.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 7
ioText {9, 226} {17, 25} label 8.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 8
ioText {9, 251} {17, 25} label 9.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 9
ioText {4, 278} {24, 25} label 10.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 10
ioText {5, 303} {24, 25} label 11.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 11
ioText {5, 327} {24, 25} label 12.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 12
ioKnob {532, 100} {80, 80} 1500.000000 100.000000 0.010000 408.000000 freq
ioText {532, 179} {80, 25} display 408.000000 0.00100 "freq" center "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 408.000
ioText {531, 82} {80, 25} label 0.000000 0.00100 "" center "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Base Freq
ioGraph {4, 358} {692, 157} scope 2.000000 -255 
ioText {449, 37} {80, 316} label 0.000000 0.00100 "" center "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Freq. (Hz)
ioText {455, 54} {68, 25} display 408.000000 0.00100 "freq1" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 408.000
ioText {454, 77} {68, 25} display 1224.000000 0.00100 "freq2" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 1224.000
ioText {454, 103} {68, 25} display 2040.000000 0.00100 "freq3" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 2040.000
ioText {456, 130} {68, 25} display 2856.000000 0.00100 "freq4" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 2856.000
ioText {456, 155} {68, 25} display 3672.000000 0.00100 "freq5" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 3672.000
ioText {456, 179} {68, 25} display 4488.000000 0.00100 "freq6" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 4488.000
ioText {454, 204} {68, 25} display 5304.000000 0.00100 "freq7" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 5304.000
ioText {455, 229} {68, 25} display 6120.000000 0.00100 "freq8" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 6120.000
ioText {454, 254} {68, 25} display 6936.000000 0.00100 "freq9" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 6936.000
ioText {455, 278} {68, 25} display 7752.000000 0.00100 "freq10" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 7752.000
ioText {454, 304} {68, 25} display 8568.000000 0.00100 "freq11" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 8568.000
ioText {452, 328} {68, 25} display 9384.000000 0.00100 "freq12" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 9384.000
ioKnob {618, 122} {66, 60} 0.500000 0.000000 0.010000 0.090000 level
ioText {619, 179} {64, 25} label 0.000000 0.00100 "" center "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Level
ioText {7, 5} {248, 43} label 0.000000 0.00100 "" left "DejaVu Sans" 22 {65280, 65280, 65280} {8448, 8704, 9216} nobackground noborder Additive syntheziser
ioText {531, 213} {166, 68} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Partial relationship:
ioText {349, 37} {96, 316} label 0.000000 0.00100 "" center "DejaVu Sans" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Freq. Factor
ioText {356, 54} {80, 25} editnum 1.000000 0.001000 "fac1" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 1.000000
ioText {356, 79} {80, 25} editnum 3.000000 0.001000 "fac2" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 3.000000
ioText {356, 104} {80, 25} editnum 5.000000 0.001000 "fac3" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 5.000000
ioText {356, 127} {80, 25} editnum 7.000000 0.001000 "fac4" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 7.000000
ioText {356, 153} {80, 25} editnum 9.000000 0.001000 "fac5" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 9.000000
ioText {356, 180} {80, 25} editnum 11.000000 0.001000 "fac6" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 11.000000
ioText {356, 206} {80, 25} editnum 13.000000 0.001000 "fac7" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 13.000000
ioText {356, 230} {80, 25} editnum 15.000000 0.001000 "fac8" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 15.000000
ioText {356, 254} {80, 25} editnum 17.000000 0.001000 "fac9" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 17.000000
ioText {356, 278} {80, 25} editnum 19.000000 0.001000 "fac10" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 19.000000
ioText {356, 301} {80, 25} editnum 21.000000 0.001000 "fac11" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 21.000000
ioText {356, 327} {80, 25} editnum 23.000000 0.001000 "fac12" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 23.000000
ioButton {535, 286} {157, 30} value 1.000000 "reset" "Reset Phase" "/" i 50 0 1
ioText {263, 54} {80, 25} editnum 1.000000 0.000100 "amp1" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 1.000000
ioText {263, 79} {80, 26} editnum 0.500000 0.000100 "amp2" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.500000
ioText {263, 104} {80, 26} editnum 0.333300 0.000100 "amp3" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.333300
ioText {263, 129} {80, 25} editnum 0.250000 0.000100 "amp4" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.250000
ioText {263, 154} {80, 26} editnum 0.200000 0.000100 "amp5" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.200000
ioText {263, 179} {80, 26} editnum 0.166700 0.000100 "amp6" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.166700
ioText {263, 203} {80, 25} editnum 0.142900 0.000100 "amp7" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.142900
ioText {263, 228} {80, 26} editnum 0.125000 0.000100 "amp8" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.125000
ioText {263, 253} {80, 26} editnum 0.111100 0.000100 "amp9" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.111100
ioText {263, 276} {80, 25} editnum 0.100000 0.000100 "amp10" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.100000
ioText {263, 301} {80, 26} editnum 0.090900 0.000100 "amp11" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.090900
ioText {263, 326} {80, 26} editnum 0.083300 0.000100 "amp12" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.083300
ioButton {535, 320} {158, 31} event 1.000000 "reset" "Amp = 1/n" "/" i100 0 1
ioMenu {537, 233} {155, 25} 1 303 "all harmonics,even harmonics,inharmonic1,inharmonic2,inharmonic3" rel
ioButton {536, 44} {156, 29} event 1.000000 "button1" "Note" "/" i1 0 -1
</MacGUI>

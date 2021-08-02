<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

/*****Playing a soundfile 1b: play from a buffer*****/
;written by joachim heintz and andres cabrera
;mar 2009

instr 1; fill the buffer and play
	Sfile	invalue	"_Browse1"  ;GUI input
	
	gichn	filenchnls	Sfile; check if mono or stereo
	   ;reading the data in the buffers (function tables)
	giL		ftgen	0, 0, 0, 1, Sfile, 0, 0, 1
	if gichn == 2 then		
		giR		ftgen	0, 0, 0, 1, Sfile, 0, 0, 2
	endif
	turnon 2
endin

instr 2; read the buffer
   ;GUI input
kskip		invalue		"skip"
kloop		invalue		"loop"
iskip		=			i(kskip)
iloop		=			i(kloop)
   ;comparing the sample rates and reading the buffer
ilensmps	=			ftlen(giL)		
idur		=			ilensmps / sr; duration to read the buffer
ireadfreq	=			sr / ilensmps; frequency of reading the buffer
iphs		=			iskip / idur; starting point as phase
aL		poscil3		1, ireadfreq, giL, iphs
  if gichn == 2 then
aR		poscil3		1, ireadfreq, giR, iphs; right channel for stereo soundfile
  else
aR		=			aL; right channel for mono soundfile
  endif
   ;stop instr after playing the buffer if no loop
ktim		timeinsts		
  if iloop == 0 && ktim > idur-iskip then
		turnoff
  endif
		outs			aL, aR
endin

instr 3; turns off instr 2
		turnoff2		2, 0, 0
endin


</CsInstruments>
<CsScore>
f 0 36000; don't listen to music longer than 10 hours
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1</x>
 <y>27</y>
 <width>460</width>
 <height>602</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>127</r>
  <g>170</g>
  <b>134</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>27</x>
  <y>96</y>
  <width>295</width>
  <height>24</height>
  <uuid>{4b9ff4d6-f93b-471c-8d3b-8f94f2c6f948}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>327</x>
  <y>93</y>
  <width>100</width>
  <height>30</height>
  <uuid>{0bec8b20-55d0-4e86-b558-e8464ce6530a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>124</x>
  <y>139</y>
  <width>78</width>
  <height>26</height>
  <uuid>{25ac6f50-68b3-4f53-8b60-66f6a60801a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine>i 1 0 9999</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>225</x>
  <y>140</y>
  <width>80</width>
  <height>25</height>
  <uuid>{bf4f12d5-4d8b-471a-a52d-d37135249573}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine>i 3 0 .1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>skip</objectName>
  <x>156</x>
  <y>185</y>
  <width>87</width>
  <height>25</height>
  <uuid>{79dec561-416b-4808-bc96-71900361766c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
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
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>loop</objectName>
  <x>318</x>
  <y>188</y>
  <width>20</width>
  <height>20</height>
  <uuid>{388179e5-59be-49c1-859c-3c8ef59c5cb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>76</x>
  <y>184</y>
  <width>80</width>
  <height>28</height>
  <uuid>{2f88b481-1b38-42cd-a00f-aae03542db9f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>skiptime</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <x>267</x>
  <y>183</y>
  <width>52</width>
  <height>29</height>
  <uuid>{c4ddb6ad-ce7a-4624-9959-0d8475b121ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>loop</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <x>29</x>
  <y>10</y>
  <width>398</width>
  <height>43</height>
  <uuid>{d51eabbc-9ac1-4400-bdce-abffa14335ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>SIMPLE SOUNDFILE PLAYER</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>26</fontsize>
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
  <x>28</x>
  <y>52</y>
  <width>398</width>
  <height>43</height>
  <uuid>{cde28586-8a73-4794-ac1c-09f1d5af0a2c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>(playing from a buffer)</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>22</fontsize>
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
  <x>25</x>
  <y>410</y>
  <width>410</width>
  <height>182</height>
  <uuid>{d7bc07b9-a49e-44b3-b942-27546029fac0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>This simple example shows how a mono or stereo soundfile can be played in Csound from a memory buffer. The disadvantage of playing a soundfile in this way is that it takes some time to read the file in your RAM (and you must have enough RAM), but you have better performance and stability.
Note that the file's sample rate is NOT converted to the orchestra sample rate!</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
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
  <x>31</x>
  <y>228</y>
  <width>397</width>
  <height>89</height>
  <uuid>{75ecdfe7-0ac2-433a-b89b-cc2270259ddb}</uuid>
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
  <x>32</x>
  <y>314</y>
  <width>397</width>
  <height>89</height>
  <uuid>{440fb58b-dbb2-42db-9f4e-4f15331f5a18}</uuid>
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

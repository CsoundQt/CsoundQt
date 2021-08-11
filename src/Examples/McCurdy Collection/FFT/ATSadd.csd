;Written by Iain McCurdy 2011

;Modified for QuteCsound by René, May 2011
;Tested on Ubuntu 10.04 with csound-float (git csound5-3c6d155, May 31 2011) and QuteCsound svn rev 848
;-------------->>>>> DON'T WORK on Csound 5.13.0
;-------------->>>>> NOT STABLE on Csound git, QuteCsound freeze when changing gkpartials in realtime. (reinit)


;Notes on modifications from original csd:
;	Add table(s) for exp slider


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SADIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 32	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


gisine	ftgen	0,0,4096,10,1					;SINE
giExp1	ftgen	0, 0, 129, -25, 0, 0.25, 128, 4.0	;TABLE FOR EXP SLIDER


instr	1
	ktrig	metro	10
	if (ktrig == 1)	then
		;SLIDERS
		gkptr			invalue	"Pointer"
		kfmod			invalue	"PitchMod"
		gkfmod			tablei	kfmod, giExp1, 1
						outvalue	"PitchMod_Value", gkfmod
		gkspeed			invalue	"Speed"
		gkporttime		invalue	"PortTime"
		gkRvbAmt			invalue	"ReverbAmount"
		;COUNTERS
		gkpartials		invalue	"Partials"
		gkpartialoffset	invalue	"PartialsOffset"
		gkpartialincr		invalue	"PartialsIncr"
		;MENU
		gkptrmode			invalue	"PointerMode"
		
		gSfile			invalue	"_Browse"
	endif
endin

instr	2
	kporttime		linseg	0, 0.001, 1								;RAMPING UP FUNCTION CONTRIBUTING TO PORTAMENTO TIME VARIABLE
	ifilelen		filelen	gSfile									;READ FILE LENGTH OF INPUT ATS ANALYSIS FILE
	if gkptrmode=0 then												;IF POINTER MODE SELECTION IS TO 'Pointer'...
		kptr		portk	gkptr*ifilelen, kporttime*gkporttime			;DEFINE TIME POINTER VALUE AND APPLY PORTAMENTO SMOOTHING	
	else															;OTHERWISE... (SPEED MODE SELECTED)
		kptr		phasor	gkspeed/ifilelen							;POINTER CREATED USING A PHASOR
		kptr		=		kptr*ifilelen								;PHASOR (0-1) RESCALED ACCORDING TO LENGTH OF ORIGINAL FILE
	endif														;END OF THIS CONDITIONAL BRANCH
	kfmod		portk	gkfmod, kporttime*gkporttime					;APPLY PORTAMENTO SMOOTHING TO PITCH RATIO VARIABLE

	ktrig		changed	 gkpartialoffset, gkpartialincr, gkpartials		;IF ANY OF THE INPUT VARIABLES CHANGES GENERATE A MOMENTARY '1' AT THE OUTPUT
	if ktrig=1 then												;IF AN I-RATE SLIDER VARIABLE HAS BEEN CHANGED...
		reinit	UPDATE											;...BEGIN A RE-INITIALIZATION PASS FROM THE LABEL 'UPDATE'
	endif														;END OF THIS CONDITIONAL BRANCH

	UPDATE:														;LABEL 'UPDATE'
	asig			ATSadd	kptr, kfmod, gSfile, gisine, i(gkpartials), i(gkpartialoffset), i(gkpartialincr)		;PERFORM ATS RESYNTHESIS
				rireturn

				denorm	asig
	aRvbL, aRvbR	reverbsc	asig, asig, 0.9, 8000						;REVERB SIGNAL CREATED USING reverbsc
				outs		asig+aRvbL*gkRvbAmt, asig+aRvbR*gkRvbAmt
endin
instr	3
		outvalue	"Pointer"			, 0.5
		outvalue	"PitchMod"		, 0.25
		outvalue	"Partials"		, 15
		outvalue	"PartialsOffset"	, 8
		outvalue	"PartialsIncr"		, 7
		outvalue	"PointerMode"		, 1
		outvalue	"Speed"			, 0.1
		outvalue	"PortTime"		, 0.01
endin
</CsInstruments>
<CsScore>
i 1	0	3600		;GUI
i 3	0	0		;INIT
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>251</x>
 <y>157</y>
 <width>903</width>
 <height>512</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>241</r>
  <g>226</g>
  <b>185</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>514</width>
  <height>510</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ATSadd</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>517</x>
  <y>2</y>
  <width>386</width>
  <height>510</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ATSadd</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>519</x>
  <y>18</y>
  <width>383</width>
  <height>487</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>---------------------------------------------------------------------------------------------
ATSadd performs additive synthesis based on analysis data stored in a file that has been pre-analysed using Juan Pampin's ATS (Analysis - Transformation - Synthesis). The design of this opcode bears simularities to the pvadd opcode and the results are comparable.
'Partials' defines the number of partials that will be used in the resysnthesis. Reducing this value significantly will limit the number of higher frequencies that can be reproduced and will therefore function as a lowpass filter. 'P.Offset' raises a threshold below which partials will not be reproduced. This will have the effect of removing lower frequencies and the effect will be that of a highpass filter. The time domain of the resynthesis is controlled using a time pointer. In this implementation the user can choose between manual manipulation of the time pointer or control of the speed of an automated moving pointer. 'P.Incr' defines the counter increment between subsequent partials that will be resynthesized. In a straight resynthesis this value should be 1 so that all partials are included. Values greater than 1 will result in partials being omitted in the resynthesis.
The maximum partial number that can be with this example is 311. Certain combinations of 'Partials', 'P.Offset' and 'P.Incr' will demand partial numbers beyond this limit. These will not be reproduced so the user should anticipate this situation nby observing warnings given in the console output. Crashes can also occur if combinations of values are demanded that the opcode is not happy with.</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>8</y>
  <width>100</width>
  <height>30</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  ON / OFF</text>
  <image>/</image>
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>40</x>
  <y>221</y>
  <width>80</width>
  <height>30</height>
  <uuid>{5b8d26a2-2397-439e-b2ff-21072fb8f53f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>No of Partials</label>
  <alignment>right</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Partials</objectName>
  <x>120</x>
  <y>221</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6c726695-a184-4e03-9c9b-5a7defdb3984}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>15</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>PartialsOffset</objectName>
  <x>255</x>
  <y>221</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dab1b064-395c-483f-9944-a8311aba4438}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>200</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>179</x>
  <y>218</y>
  <width>76</width>
  <height>40</height>
  <uuid>{63c66be6-1d1f-4a44-8b22-8680f083e808}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Partials
Offset</label>
  <alignment>right</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>PartialsIncr</objectName>
  <x>389</x>
  <y>221</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3039dd4c-40c6-4553-b4be-9187ba630c04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>200</maximum>
  <randomizable group="0">false</randomizable>
  <value>7</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>314</x>
  <y>218</y>
  <width>76</width>
  <height>40</height>
  <uuid>{34bc6389-9909-465c-93aa-5f708194d623}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Partials
Increment</label>
  <alignment>right</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pointer</objectName>
  <x>448</x>
  <y>137</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Pointer</objectName>
  <x>8</x>
  <y>115</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>137</y>
  <width>150</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>177</x>
  <y>451</y>
  <width>330</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>AndItsAll.ats</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>177</x>
  <y>479</y>
  <width>330</width>
  <height>30</height>
  <uuid>{a63909ac-6fa4-41c8-a84b-ba08e76132ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Restart the instrument after changing the ATS file.</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>PointerMode</objectName>
  <x>190</x>
  <y>60</y>
  <width>120</width>
  <height>30</height>
  <uuid>{2a932bf5-a5c9-4ce2-8fe3-e00e4bd01291}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Pointer</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Speed</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>90</x>
  <y>60</y>
  <width>100</width>
  <height>30</height>
  <uuid>{bc692434-237b-47a7-a666-03108fcbbcb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer Mode :</label>
  <alignment>right</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PitchMod_Value</objectName>
  <x>448</x>
  <y>184</y>
  <width>60</width>
  <height>30</height>
  <uuid>{04c9dace-9480-4e55-898f-e0c00de2c1f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>PitchMod</objectName>
  <x>8</x>
  <y>162</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b47f6a17-4914-4c3a-9cc0-5f7b9299a578}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.25000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>184</y>
  <width>150</width>
  <height>30</height>
  <uuid>{7866f624-7937-48ac-8363-1bd5aa7b9625}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch Modulation</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Speed</objectName>
  <x>448</x>
  <y>283</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f940a4ca-6ca3-46fe-a5d6-f09fa405fe6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Speed</objectName>
  <x>8</x>
  <y>261</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5bff9d9f-6ed6-466d-a67e-e0e98bc000df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>283</y>
  <width>150</width>
  <height>30</height>
  <uuid>{c15a01f7-b70d-4251-aabe-9d7c2d312ea8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Speed</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PortTime</objectName>
  <x>448</x>
  <y>330</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4608f0e7-8c46-421e-98fd-de5d17d49010}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.010</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>PortTime</objectName>
  <x>8</x>
  <y>308</y>
  <width>500</width>
  <height>27</height>
  <uuid>{03089344-3d3c-48f2-939e-8d4f9635befc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.01000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>330</y>
  <width>150</width>
  <height>30</height>
  <uuid>{8d180fa4-046e-4636-8205-76cfb7d5c66c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Portamento Time</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ReverbAmount</objectName>
  <x>448</x>
  <y>377</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f4f9825b-2418-453e-8895-67974638267d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.926</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>ReverbAmount</objectName>
  <x>8</x>
  <y>355</y>
  <width>500</width>
  <height>27</height>
  <uuid>{4792157e-ea37-4d49-8cb4-341dd2e412e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.92600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>377</y>
  <width>150</width>
  <height>30</height>
  <uuid>{0da9e8e2-9088-41b3-b1c5-b292a65afe7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Amount</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>427</y>
  <width>150</width>
  <height>30</height>
  <uuid>{cc0c2a1c-5c88-41c0-9e2b-aae5d01c05af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Analysis File</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>450</y>
  <width>170</width>
  <height>30</height>
  <uuid>{8386ec82-9b74-48d0-b64b-e6bf1db6ae0b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>AndItsAll.ats</stringvalue>
  <text>Browse ATS File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

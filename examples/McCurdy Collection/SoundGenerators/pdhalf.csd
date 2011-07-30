;Written by Iain McCurdy, 2009


;Modified for QuteCsound by René, April 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table for exp slider
;	Add INIT instrument


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 64			;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


giwave1		ftgen 	1, 0, 131072, 9, 1, 1, 0, 1.7, 1, 0, 2.31, 1, 0, 2.56, 1, 0, 3.67, 1, 0	;COMPLEX WAVEFORM
giwave2		ftgen	2, 0, 131072, 10, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0				;ODD PARTIALS
giwave3		ftgen	3, 0, 131072, 9, 1, 1, 270										;INVERTED COSINE
giwave4		ftgen	4, 0, 131072, 7, 1, 65536, 1, 0, -1, 65537, -1						;SQUARE WAVE
giwave5		ftgen	5, 0, 131072, 11, 40, 1, 1.1										;BUZZ WAVEFORM
giwave6		ftgen	6, 0, 131072, 19, 3, 1, 0, 0, 7, 0.5, 0, 0, 13, 0.1, 0, 0				;SELECTED HARMONICS WAVEFORM

giExp1		ftgen	0, 0, 129, -25, 0, 20.0, 128, 2000.0								;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;SLIDERS
		gkamp		invalue	"Amplitude"
		kfreq		invalue	"Frequency"   
		gkfreq		tablei	kfreq, giExp1, 1
					outvalue	"Frequency_Value", gkfreq
		gkShapeAmount	invalue	"ShapeAmt"

		;KNOBS
		gkstrlevS		invalue	"StrLevS"
		gkatttimS		invalue	"AttTimS"
		gkattlevS		invalue	"AttLevS"
		gkdectimS		invalue	"DecTimS"
		gksuslevS		invalue	"SusLevS"
		gkreltimS		invalue	"RelTimS"
		gkrellevS		invalue	"RelLevS"
		gkvel		invalue	"Vel"

		gkstrlevA		invalue	"StrLevA"
		gkatttimA		invalue	"AttTimA"
		gkattlevA		invalue	"AttLevA"
		gkdectimA		invalue	"DecTimA"
		gksuslevA		invalue	"SusLevA"
		gkreltimA		invalue	"RelTimA"
		gkrellevA		invalue	"RelLevA"

		gkLFOdepS		invalue	"LFODepth"
		gkLFOratS		invalue	"LFORate"
		gkLFOdelS		invalue	"LFODelay"
		gkLFOrisS		invalue	"LFORise"
 
		;MENUS
		gkfn			invalue	"Waveform"
		gktype		invalue	"DistType"
	endif
endin

instr	11	;INIT
			outvalue	"Amplitude"	, 0.15
			outvalue	"Frequency"	, 0.65049
			outvalue	"ShapeAmt"	, 0.0
			outvalue	"StrLevS"		, 0.0
			outvalue	"AttTimS"		, .005
			outvalue	"AttLevS"		, 1.0
			outvalue	"DecTimS"		, 1.0
			outvalue	"SusLevS"		, 0.0
			outvalue	"RelTimS"		, .5
			outvalue	"RelLevS"		, 0.0
			outvalue	"StrLevA"		, 0.0
			outvalue	"AttTimA"		, .005
			outvalue	"AttLevA"		, 1.0
			outvalue	"DecTimA"		, 1.0
			outvalue	"SusLevA"		, 1.0
			outvalue	"RelTimA"		, .5
			outvalue	"RelLevA"		, 0.0
			outvalue	"LFODepth"	, 0.18
			outvalue	"LFORate"		, 1.0
			outvalue	"LFODelay"	, 0.0
			outvalue	"LFORise"		, 0.4
			outvalue	"Vel"		, 1.0
endin

instr	1	;MIDI ACTIVATED INSTRUMENT
	ktrig	changed	gkfn						;TEST WHETHER INPUT ARGUMENTS HAVE CHANGED. IF ANY OF THEM HAVE, OUTPUT A '1' OTHERWISE OUTPUT ZERO.
	if		ktrig=1	then						;IF 'ktrig' IS '1'...
			reinit	UPDATE					;BEGIN A REINITIALIZATION PASS AT LABEL 'UPDATE'
	endif									;END OF CONDITIONALIZATION PASS

	ibipolar		=	0						;UNIPOLAR/BIPOLAR SWITCH (0=UNIPOLAR 1=BIPOLAR)
	ifullscale	=	1						;FULLSCALE VALUE
	ioct			octmidi

	;PITCH BEND INFORMATION IS READ
	iSemitoneBendRange=		2													;PITCH BEND RANGE IN SEMITONES
	imin			=		0													;EQUILIBRIUM POSITION
	imax			=		iSemitoneBendRange * .0833333								;MAX PITCH DISPLACEMENT (IN oct FORMAT)
	kbend		pchbend	imin, imax											;PITCH BEND VARIABLE (IN oct FORMAT)
	kfreq		=		cpsoct(ioct+ kbend)
	aosc        	phasor	kfreq												;DEFINE A PHASOR
    	kShapeEnv		linsegr	i(gkstrlevS), i(gkatttimS), i(gkattlevS), i(gkdectimS), i(gksuslevS), i(gkreltimS), i(gkrellevS)	;ENVELOPE USED TO MODULATE 'SHAPE AMOUNT'
    	ivel			veloc	0,1
    	kShapeEnv		=		kShapeEnv * (gkvel * ivel)
    	kLFOenv		linseg	0,i(gkLFOdelS)+0.00001,0,i(gkLFOrisS)+0.00001,1,1,1
    	kShapeLFO		lfo		gkLFOdepS*kLFOenv, gkLFOratS, 1							;TRIANGLE WAVEFORM
    	kShapeAmount	limit	kShapeEnv+kShapeLFO, -1, 1
    	aAmpEnv		linsegr	i(gkstrlevA), i(gkatttimA), i(gkattlevA), i(gkdectimA), i(gksuslevA), i(gkreltimA), i(gkrellevA)	;ENVELOPE USED TO MODULATE AMPLITUDE
    	apd1         	pdhalf	aosc, kShapeAmount, ibipolar, ifullscale					;PHASE DISTORT THE PHASOR (aosc) CREATED 4 LINES ABOVE
    	apd2         	pdhalfy	aosc, kShapeAmount, ibipolar, ifullscale					;PHASE DISTORT THE PHASOR (aosc) CREATED 4 LINES ABOVE

	if		gktype=0	then
		apd	=	apd1
	elseif	gktype=1	then
		apd	=	apd2
	endif
	UPDATE:																	;LABEL FOR WHERE TO BEGIN REINITIALIZATION PASS
    	aout        	tablei	apd, i(gkfn)+1, 1										;READ WAVEFORM USING PHASE DISTORTED WAVEFORM
    				rireturn														;RETURN TO PERFORMANCE
				outs		aout * gkamp * aAmpEnv, aout * gkamp * aAmpEnv				;SEND AUDIO TO OUTPUTS
endin   

instr	2
	ktrig		changed	gkfn													;TEST WHETHER INPUT ARGUMENTS HAVE CHANGED. IF ANY OF THEM HAVE, OUTPUT A '1' OTHERWISE OUTPUT ZERO.
	if	ktrig=1	then															;IF 'ktrig' IS '1'...
		reinit	UPDATE														;BEGIN A REINITIALIZATION PASS AT LABEL 'UPDATE'
	endif																	;END OF CONDITIONALIZATION PASS

	ibipolar		=		0													;UNIPOLAR/BIPOLAR SWITCH (0=UNIPOLAR 1=BIPOLAR)
	ifullscale	=		1													;FULLSCALE VALUE
	aosc        	phasor	gkfreq												;DEFINE A PHASOR
    	kLFOenv		linseg	0, i(gkLFOdelS)+0.00001, 0, i(gkLFOrisS)+0.00001, 1, 1, 1
    	kShapeLFO		lfo		gkLFOdepS*kLFOenv, gkLFOratS, 1							;TRIANGLE WAVEFORM
    	kShapeAmount	limit	gkShapeAmount+kShapeLFO, -1, 1
    	apd1         	pdhalf	aosc, kShapeAmount, ibipolar, ifullscale					;PHASE DISTORT THE PHASOR (aosc) CREATED 4 LINES ABOVE
    	apd2         	pdhalfy	aosc, kShapeAmount, ibipolar, ifullscale					;PHASE DISTORT THE PHASOR (aosc) CREATED 4 LINES ABOVE

	if		gktype=0	then
		apd	=	apd1
	elseif	gktype=1	then
		apd	=	apd2
	endif
	UPDATE:																	;LABEL FOR WHERE TO BEGIN REINITIALIZATION PASS
    	aout        	tablei	apd, i(gkfn)+1, 1										;READ WAVEFORM USING PHASE DISTORTED WAVEFORM
   			 	rireturn														;RETURN TO PERFORMANCE
				outs		aout * gkamp, aout * gkamp								;SEND AUDIO TO OUTPUTS
endin   
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0.0	   3600	;GUI
i 11		0.0     0.01	;INIT
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>800</x>
 <y>167</y>
 <width>800</width>
 <height>595</height>
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
  <width>512</width>
  <height>590</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pdhalf</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>221</y>
  <width>500</width>
  <height>120</height>
  <uuid>{56796b55-f924-40e9-ac1e-20eb7186c3bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Shape Amount Envelope (MIDI mode)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>69</y>
  <width>160</width>
  <height>30</height>
  <uuid>{b066c36d-a132-4a1a-aee4-e421b02bca48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>69</y>
  <width>60</width>
  <height>30</height>
  <uuid>{262729b5-3e13-43d4-af01-99d1e8aabf34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.150</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>53</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f4910f7d-2341-46e1-aa20-a4d3db351c24}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.15000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>107</y>
  <width>160</width>
  <height>30</height>
  <uuid>{5a8c0afb-17da-4ca7-a331-f3ef38db1431}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency (GUI mode)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Frequency_Value</objectName>
  <x>448</x>
  <y>107</y>
  <width>60</width>
  <height>30</height>
  <uuid>{12d2c823-daba-4a56-9f0c-462a6c951992}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>400.003</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Frequency</objectName>
  <x>8</x>
  <y>91</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5442ecac-367f-413c-a49e-5f42a2727519}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.65048999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>146</y>
  <width>220</width>
  <height>30</height>
  <uuid>{d1ad1809-ed86-4ecd-b6c9-15b4c9686e35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Phase Distortion Amount (GUI mode)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>ShapeAmt</objectName>
  <x>448</x>
  <y>146</y>
  <width>60</width>
  <height>30</height>
  <uuid>{39d4f770-c1eb-4c2d-9b6d-41b78e8955f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>ShapeAmt</objectName>
  <x>8</x>
  <y>130</y>
  <width>500</width>
  <height>27</height>
  <uuid>{37911dd5-758c-4ec8-9871-ce3f5cd67670}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Waveform</objectName>
  <x>340</x>
  <y>184</y>
  <width>160</width>
  <height>26</height>
  <uuid>{fd321c7c-a7e3-49dd-9c35-b4d1a0054c73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Complex Waveform</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Odd Partials</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Inverted Cosine</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Square Wave</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Buzz</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Harms:3-7-13</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>5</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>10</x>
  <y>16</y>
  <width>120</width>
  <height>26</height>
  <uuid>{c4c1aae5-edb9-47d9-94a7-8d15578e0bf2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off - MIDI</text>
  <image>/</image>
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>39</x>
  <y>184</y>
  <width>80</width>
  <height>26</height>
  <uuid>{86841fd4-baff-4c80-bfdc-c165066052cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Distortion :</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>DistType</objectName>
  <x>119</x>
  <y>184</y>
  <width>100</width>
  <height>26</height>
  <uuid>{81b86aae-0ea8-4a71-bc13-0f6de4dbc254}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>X - Axis</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Y - Axis</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>260</x>
  <y>184</y>
  <width>80</width>
  <height>26</height>
  <uuid>{e192d1b0-4e18-4b7a-97cb-800767992d7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Waveform :</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>StrLevS</objectName>
  <x>26</x>
  <y>252</y>
  <width>50</width>
  <height>50</height>
  <uuid>{dd04e6b9-e006-4285-8fd2-72c9bd78f362}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>302</y>
  <width>60</width>
  <height>26</height>
  <uuid>{9c7c0b3e-69f4-4dbb-8e77-4f99a6e8576a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Level</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>StrLevS</objectName>
  <x>22</x>
  <y>315</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8f780deb-76cf-42f5-9487-938d015f2f50}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>AttTimS</objectName>
  <x>86</x>
  <y>252</y>
  <width>50</width>
  <height>50</height>
  <uuid>{034bc01e-e81b-4e15-8e08-c14461f55459}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>8.00000000</maximum>
  <value>0.00500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>82</x>
  <y>302</y>
  <width>60</width>
  <height>26</height>
  <uuid>{2134e2f3-a91d-46e1-aa02-25f91ddb96c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>AttTimS</objectName>
  <x>82</x>
  <y>315</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ee9c3348-96db-4140-9371-07814a2dc654}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.005</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>AttLevS</objectName>
  <x>146</x>
  <y>252</y>
  <width>50</width>
  <height>50</height>
  <uuid>{4cc579ba-981a-4ced-b962-bbcebb12b7bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>142</x>
  <y>302</y>
  <width>60</width>
  <height>26</height>
  <uuid>{f8ff7ea5-915e-45b6-86d1-8ef007ac30b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Level</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>AttLevS</objectName>
  <x>142</x>
  <y>315</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0c93fe27-64ec-436c-a9c5-ca1082270d69}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>DecTimS</objectName>
  <x>206</x>
  <y>252</y>
  <width>50</width>
  <height>50</height>
  <uuid>{7cf7c01d-feca-49e2-8f42-c3754199198b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>8.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>202</x>
  <y>302</y>
  <width>60</width>
  <height>26</height>
  <uuid>{9b4a8823-34bd-48f1-a34f-d78119371642}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>DecTimS</objectName>
  <x>202</x>
  <y>315</y>
  <width>60</width>
  <height>30</height>
  <uuid>{14f71d96-f649-4c60-95eb-4033a010f6b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>SusLevS</objectName>
  <x>266</x>
  <y>252</y>
  <width>50</width>
  <height>50</height>
  <uuid>{f3433f95-20b3-4c0f-8f1c-65a42a5f6f7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>262</x>
  <y>302</y>
  <width>60</width>
  <height>26</height>
  <uuid>{1b8fb0fb-9f01-4bab-80e5-730bcc354bc1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sustain</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>SusLevS</objectName>
  <x>262</x>
  <y>315</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4f083865-4df8-4b19-944c-e8ba5bc15594}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>RelTimS</objectName>
  <x>326</x>
  <y>252</y>
  <width>50</width>
  <height>50</height>
  <uuid>{ab239c31-101c-463e-b854-f8206d208e0c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>8.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>322</x>
  <y>302</y>
  <width>60</width>
  <height>26</height>
  <uuid>{2923a27c-d5b2-44b2-9a05-f547567f963a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>RelTimS</objectName>
  <x>322</x>
  <y>315</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9e550522-78c0-4a83-a75d-3a562bf843ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>RelLevS</objectName>
  <x>386</x>
  <y>252</y>
  <width>50</width>
  <height>50</height>
  <uuid>{bc0f91c1-dd0a-476e-8a62-0f8ec1ba7ee7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>382</x>
  <y>302</y>
  <width>60</width>
  <height>26</height>
  <uuid>{0f9605b6-ec16-4716-b214-b6cdaddcf1f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Level</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>RelLevS</objectName>
  <x>382</x>
  <y>315</y>
  <width>60</width>
  <height>30</height>
  <uuid>{02462a1d-8528-4180-8b80-8b8f458d9bd1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Vel</objectName>
  <x>446</x>
  <y>252</y>
  <width>50</width>
  <height>50</height>
  <uuid>{5968bfd4-9146-4a73-83a6-e7699de92c7d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>442</x>
  <y>302</y>
  <width>60</width>
  <height>26</height>
  <uuid>{36418b77-ef34-41ca-8687-1d8f8a187a6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Velocity</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Vel</objectName>
  <x>442</x>
  <y>315</y>
  <width>60</width>
  <height>30</height>
  <uuid>{964f4d64-8378-4324-812a-6bcda2424a1d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <y>343</y>
  <width>500</width>
  <height>120</height>
  <uuid>{dca7a4d6-cf7e-4e6b-84fe-24843b99f8f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude Envelope (MIDI mode)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>StrLevA</objectName>
  <x>26</x>
  <y>374</y>
  <width>50</width>
  <height>50</height>
  <uuid>{ad4992bf-a7cc-496e-acb8-57ffe82e6426}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>423</y>
  <width>60</width>
  <height>26</height>
  <uuid>{907d2242-c1f6-4578-8ba4-2aaef58051ff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Level</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>StrLevA</objectName>
  <x>22</x>
  <y>436</y>
  <width>60</width>
  <height>30</height>
  <uuid>{93751cba-0781-4e6c-8ec0-cfeef9b88b82}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>AttTimA</objectName>
  <x>86</x>
  <y>374</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9faf4745-57b3-4c1d-a312-943b4902e1b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>8.00000000</maximum>
  <value>0.00500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>82</x>
  <y>423</y>
  <width>60</width>
  <height>26</height>
  <uuid>{7a3462bf-9790-4234-b69d-ff2af8752207}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>AttTimA</objectName>
  <x>82</x>
  <y>436</y>
  <width>60</width>
  <height>30</height>
  <uuid>{449833c6-a5de-40bc-b564-15efdd3a247e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.005</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>AttLevA</objectName>
  <x>146</x>
  <y>374</y>
  <width>50</width>
  <height>50</height>
  <uuid>{fc097eb6-7321-4353-8c6f-53568c79bd8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>142</x>
  <y>423</y>
  <width>60</width>
  <height>26</height>
  <uuid>{79d207ad-d99f-41e9-a8ba-024b5a50a89d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Level</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>AttLevA</objectName>
  <x>142</x>
  <y>436</y>
  <width>60</width>
  <height>30</height>
  <uuid>{73669288-bd5c-4033-b650-87535ce7c123}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>DecTimA</objectName>
  <x>206</x>
  <y>374</y>
  <width>50</width>
  <height>50</height>
  <uuid>{f9f6e6e4-081e-4e18-a435-00926860da85}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>8.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>202</x>
  <y>423</y>
  <width>60</width>
  <height>26</height>
  <uuid>{facdc01c-9969-4750-9f6a-e7c412e3c4a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>DecTimA</objectName>
  <x>202</x>
  <y>436</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bf50e950-5683-43ca-92f4-7146af8847ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>SusLevA</objectName>
  <x>266</x>
  <y>374</y>
  <width>50</width>
  <height>50</height>
  <uuid>{ecc1255b-2270-4745-add8-0f8d54843bb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>262</x>
  <y>423</y>
  <width>60</width>
  <height>26</height>
  <uuid>{848a3adb-e1f6-4183-9a19-ec2ad7f26cca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sustain</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>SusLevA</objectName>
  <x>262</x>
  <y>436</y>
  <width>60</width>
  <height>30</height>
  <uuid>{63d2e42c-7f99-4e7c-88b8-7c4eccf6aa10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>RelTimA</objectName>
  <x>326</x>
  <y>374</y>
  <width>50</width>
  <height>50</height>
  <uuid>{440cf36c-cf9e-45d7-a3c3-e24188b0c7d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>8.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>322</x>
  <y>423</y>
  <width>60</width>
  <height>26</height>
  <uuid>{ba651e78-c00c-4b71-9830-9a6b204e9860}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>RelTimA</objectName>
  <x>322</x>
  <y>436</y>
  <width>60</width>
  <height>30</height>
  <uuid>{385332ec-38a5-4f29-9510-dacd6aefd47f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>RelLevA</objectName>
  <x>386</x>
  <y>374</y>
  <width>50</width>
  <height>50</height>
  <uuid>{0b19f226-1af0-4cb0-865c-f486f9b178f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>382</x>
  <y>423</y>
  <width>60</width>
  <height>26</height>
  <uuid>{dbf71d42-4632-4bfb-9923-465124c12185}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Level</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>RelLevA</objectName>
  <x>382</x>
  <y>436</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b043791e-9f6f-40b2-ba5c-17830042c168}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <y>465</y>
  <width>500</width>
  <height>120</height>
  <uuid>{226d388f-b5da-4b20-9162-98673361dffc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Shape Amount LFO</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>LFODepth</objectName>
  <x>206</x>
  <y>496</y>
  <width>50</width>
  <height>50</height>
  <uuid>{266cf62e-dcdc-4cbf-9a2d-ee4e355a1088}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.18000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>202</x>
  <y>545</y>
  <width>60</width>
  <height>26</height>
  <uuid>{8c0122dc-e02d-4d98-ab63-b1e63c342147}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Depth</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>LFODepth</objectName>
  <x>202</x>
  <y>558</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2a18c41a-5bca-40f4-9952-fcaa43bf2288}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.180</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>LFORate</objectName>
  <x>266</x>
  <y>496</y>
  <width>50</width>
  <height>50</height>
  <uuid>{a1e79a84-2277-46ad-9303-12ce1f1ae943}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>16.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>262</x>
  <y>545</y>
  <width>60</width>
  <height>26</height>
  <uuid>{70dc6e78-20ba-4a81-866e-501e666d2bef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>LFORate</objectName>
  <x>262</x>
  <y>558</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7010fc13-3cd7-4441-9ea3-00866bdfc37a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>LFODelay</objectName>
  <x>326</x>
  <y>496</y>
  <width>50</width>
  <height>50</height>
  <uuid>{551a0f31-5ad4-47c1-889c-668b4588afd3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>322</x>
  <y>545</y>
  <width>60</width>
  <height>26</height>
  <uuid>{b1176770-5875-44e8-b169-e1d0c8997ee2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>LFODelay</objectName>
  <x>322</x>
  <y>558</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7173c82d-2140-4760-8705-cb148a2f140c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>LFORise</objectName>
  <x>386</x>
  <y>496</y>
  <width>50</width>
  <height>50</height>
  <uuid>{5f74f884-9679-4715-b677-48b1de7256b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.40000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>382</x>
  <y>545</y>
  <width>60</width>
  <height>26</height>
  <uuid>{a06bbb52-9726-47c8-acbc-d91cdb7efeae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rise</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>LFORise</objectName>
  <x>382</x>
  <y>558</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b593d736-0c0b-494c-95e4-b9695580e85d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.400</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <x>515</x>
  <y>2</y>
  <width>280</width>
  <height>590</height>
  <uuid>{9798823d-b60e-424f-a3c4-1a43d5e0312d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pdhalf (pdhalfy)
Phase Distortion Synthesis </label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>49</y>
  <width>269</width>
  <height>539</height>
  <uuid>{66493881-548a-48d2-bdb6-08aad6d0fe91}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------
'pdhalf' (and 'pdhalfy') can be used to warp the movement of a phase pointer that can be then used to implement phase distortion synthesis as used in Casio's CZ series of synthsizers. For a description of exactly how this works I would direct the reader to Anthony Kozar's excellent decription of his opcodes in the entries in the Csound Manual for 'pdhalf' and 'pdhalfy'. The difference between 'pdhalf' and 'pdhalfy' is that the distortion node is defined on the x-axis or on the y-axis respectively. In this example the user can choose between these two opcodes using the two tick boxes in the upper right of the interface. 'Shape Amount' (the amount of phase distortion) is normally defined as a value between -1 and 1. A value of zero specifies no phase distortion. In this example 'Shape Amount' can be modulated be the dedicated slider, when activating the instrument using the on-screen switch, or via the 'Shape Amount Envelope' when a note has been triggered by a MIDI keyboard. 'Shape Amount' can also be modulated by the LFO in either mode. In this example a choice of 6 waveforms to be phase distorted are offered. The user is encouraged to explore the phase distortion of other waveforms.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

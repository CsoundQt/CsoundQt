;Written by Iain McCurdy, 2010


;Modified for QuteCsound by René, April 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Use of QuteCsound internal midi for X Centre (CC#1), Y Centre (CC#2), X Radius (CC#3) and Y Radius (CC#4)


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 16			;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


garvbL		init		0								;INITIALIZE GLOBAL AUDIO REVERB SEND SIGNALS
garvbR		init		0								;INITIALIZE GLOBAL AUDIO REVERB SEND SIGNALS

giKybdScaling	ftgen	0,0,128,5,1,32,1,96,0.4				;KEYBOARD SCALING WHICH WILL BE USED TO PREVENT EXCESSIVE SHRILLNESS IN THE UPPER REGISTER FOR MIDI TRIGGERED NOTES
giExp1		ftgen	0, 0, 129, -25, 0, 1.0, 128, 8000.0	;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;SLIDERS
		kfreq	invalue	"Freq"
		gkfreq	tablei	kfreq, giExp1, 1
				outvalue	"Freq_Value", gkfreq
		gkcx		invalue	"XCentre"
		gkcy		invalue	"YCentre"
		gkrx		invalue	"XRadius"
		gkry		invalue	"YRadius"
		gkamp	invalue	"Amplitude"
		gkAtt	invalue	"Attack"
		gkRel	invalue	"Release"
		gkRvbSnd	invalue	"Reverb"
		gkJitX	invalue	"XJitter"
		gkJitY	invalue	"YJitter"
		;X Wave
		gk1_1	invalue	"1_1"
		gk1_2	invalue	"1_2"
		gk1_3	invalue	"1_3"
		gk1_4	invalue	"1_4"
		gk1_5	invalue	"1_5"
		gk1_6	invalue	"1_6"
		gk1_7	invalue	"1_7"
		gk1_8	invalue	"1_8"
		gk1_9	invalue	"1_9"
		gk1_10	invalue	"1_10"
		gk1_11	invalue	"1_11"
		gk1_12	invalue	"1_12"
		;Y Wave
		gk2_1	invalue	"2_1"
		gk2_2	invalue	"2_2"
		gk2_3	invalue	"2_3"
		gk2_4	invalue	"2_4"
		gk2_5	invalue	"2_5"
		gk2_6	invalue	"2_6"
		gk2_7	invalue	"2_7"
		gk2_8	invalue	"2_8"
		gk2_9	invalue	"2_9"
		gk2_10	invalue	"2_10"
		gk2_11	invalue	"2_11"
		gk2_12	invalue	"2_12"
	endif
endin

instr	11	;INIT
	outvalue	"Freq"		, 0.666606
	outvalue	"XCentre"		, 0.2
	outvalue	"YCentre"		, 0.7
	outvalue	"XRadius"		, 0.3
	outvalue	"YRadius"		, 0.3
	outvalue	"Amplitude"	, 0.4
	outvalue	"Attack"		, 1.2
	outvalue	"Release"		, 5.0
	outvalue	"Reverb"		, 0.5
	outvalue	"XJitter"		, 0.05
	outvalue	"YJitter"		, 0.05
	;PARTIAL VALUES
	outvalue	"1_1"		, 1.0
	outvalue	"1_2"		, 0.0
	outvalue	"1_3"		, 0.33
	outvalue	"1_4"		, 0.0
	outvalue	"1_5"		, 0.2
	outvalue	"1_6"		, 0.0
	outvalue	"1_7"		, 0.14
	outvalue	"1_8"		, 0.0
	outvalue	"1_9"		, 0.11
	outvalue	"1_10"		, 0.0
	outvalue	"1_11"		, 0.0
	outvalue	"1_12"		, 0.0
	outvalue	"2_1"		, 1.0
	outvalue	"2_2"		, 0.0
	outvalue	"2_3"		, 0.0
	outvalue	"2_4"		, 0.0
	outvalue	"2_5"		, 0.0
	outvalue	"2_6"		, 0.0
	outvalue	"2_7"		, 0.0
	outvalue	"2_8"		, 0.0
	outvalue	"2_9"		, 0.0
	outvalue	"2_10"		, 0.0
	outvalue	"2_11"		, 0.0
	outvalue	"2_12"		, 0.0
endin

instr	2	;UPDATE WAVEFORMS
	ktrig	changed	gk1_1, gk1_2, gk1_3, gk1_4, gk1_5, gk1_6, gk1_7, gk1_8, gk1_9, gk1_10, gk1_11, gk1_12, gk2_1, gk2_2, gk2_3, gk2_4, gk2_5, gk2_6, gk2_7, gk2_8, gk2_9, gk2_10, gk2_11, gk2_12	;IF ANY OF THE INPUT VARIABLES CHANGE OUTPUT A MOMENTARY '1' (BANG)
	if ktrig=1 then											;IF ANY OF THE TABLE PARTIAL AMPLITUDE SLIDERS HAS BEEN CHANGED...
		reinit	UPDATE										;BEGIN A REINITIALIZATION PASS FROM LABEL 'UPDATE'
	endif													;END OPF THIS CONDITIONAL BRANCH
	UPDATE:													;A LABEL CALLED 'UPDATE'
	;DEFINE THE TWO GEN 10 FUNCTION TABLES THAT WILL BE USED ON THE WAVE TERRAIN SYNTHESIS
	giwave1	ftgen	1,0,8192,10,i(gk1_1),i(gk1_2),i(gk1_3),i(gk1_4),i(gk1_5),i(gk1_6),i(gk1_7),i(gk1_8),i(gk1_9),i(gk1_10),i(gk1_11),i(gk1_12)
	giwave2	ftgen	2,0,8192,10,i(gk2_1),i(gk2_2),i(gk2_3),i(gk2_4),i(gk2_5),i(gk2_6),i(gk2_7),i(gk2_8),i(gk2_9),i(gk2_10),i(gk2_11),i(gk2_12)
			rireturn											;RETURN FROM REINITIALIZATION PASS
endin

instr 	1
	iporttime			=		0.05								;CREATE A VARIABLE THAT WILL BE USED FOR PORTAMENTO TIME
	kporttime			linseg	0, 0.01, iporttime					;CREATE A VARIABLE THAT WILL BE USED FOR PORTAMENTO TIME

	iMIDIActiveValue	=		1								;IF MIDI ACTIVATED
	iMIDIflag			=		0								;IF GUI ACTIVATED
				mididefault	iMIDIActiveValue, iMIDIflag			;IF NOTE IS MIDI ACTIVATED REPLACE iMIDIflag WITH iMIDIActiveValue 

	if iMIDIflag=1 then											;IF THIS IS A MIDI ACTIVATED NOTE AND MIDI-TO-PITCH SWITCH IS ON...
		icps			cpsmidi									;READ MIDI PITCH VALUES - THIS VALUE CAN BE MAPPED TO GRAIN DENSITY AND/OR PITCH DEPENDING ON THE SETTING OF THE MIDI MAPPING SWITCHES
		inum			notnum									;READ IN MIDI NOTE NUMBER (0-127) - WILL BE USED IN KEYBOARD SCALING
		iamp			ampmidi	1								;READ MIDI AMPLITUDE VALUES
		kfreq		=		icps								;MAP TO MIDI NOTE VALUE TO PITCH (CONVERT TO RATIO: MIDDLE C IS POINT OF UNISON)
		iKybdScale	table	inum, giKybdScaling					;READ IN KEYBOARD SCALING VALUE FROM FUNCTION TABLE - INDEX IS DERIVED FROM MIDI NOTE NUMBER
		iamp			=		iamp * iKybdScale					;APPLY KEYBOARD SCALING TO AMPLITUDE VALUE - THIS IS DONE TO PREVERN EXCESSIVE SHRILLNESS IN THE UPPER REGISTER
	else														;OTHERWISE...
		kfreq		portk	gkfreq, kporttime					;USE THE GUI SLIDER VALUE
		iamp			=		1								;AS THERE IS NO MIDI AMPLITUDE IN AN GUI ACTUATED NOTE IT WILL IN THIS CASE BE JUST GIVEN A VALUE OF '1'
	endif													;END OF THIS CONDITIONAL BRANCH

	kRadEnv	linsegr	0, i(gkAtt), iamp, i(gkRel), 0				;RADIUS ENVELOPE
	
	kcx		portk	gkcx, kporttime							;APPLY PORTAMENTO SMOOTHING TO GUI SLIDER VARIABLE
	kcy		portk	gkcy, kporttime							;APPLY PORTAMENTO SMOOTHING TO GUI SLIDER VARIABLE
	krx		portk	gkrx, kporttime							;APPLY PORTAMENTO SMOOTHING TO GUI SLIDER VARIABLE
	kry		portk	gkry, kporttime							;APPLY PORTAMENTO SMOOTHING TO GUI SLIDER VARIABLE

	krxJit	jspline	gkJitX,1,10								;JITTER SIGNAL
	kryJit	jspline	gkJitY,1,10								;JITTER SIGNAL
	
	asigL	wterrain	gkamp,  kfreq, kcx, kcy, krx*kRadEnv*(1+krxJit), kry*kRadEnv*(1+kryJit), giwave1, giwave2
	asigR	wterrain	gkamp, -kfreq, kcx, kcy, krx*kRadEnv*(1+krxJit), kry*kRadEnv*(1+kryJit), giwave1, giwave2		;RIGHT CHANNEL FREQUENCY IS INVERTED TO CREAT A STEREO EFFECT
	asigL	dcblock	asigL									;BLOCK DC OFFSETS
	asigR	dcblock	asigR									;BLOCK DC OFFSETS

	aenv		expseg	0.001, 0.01, 1,1,1							;DECLICKING AMPLITUDE ENVELOPE
	asigL	=		asigL * aenv								;SCALE AUDIO SIGNAL WITH AMPLITUDE ENVELOPE
	asigR	=		asigR * aenv								;SCALE AUDIO SIGNAL WITH AMPLITUDE ENVELOPE
			outs		asigL, asigR								;SEND AUDIO TO OUTPUTS
	garvbL	=		garvbL + (asigL * gkRvbSnd)					;ADD TO GLOBAL AUDIO REVERB CHANNEL (LEFT)
	garvbR	=		garvbR + (asigR * gkRvbSnd)					;ADD TO GLOBAL AUDIO REVERB CHANNEL (RIGHT)
endin

instr	4	;REVERB
	asigL,asigR	reverbsc	garvbL, garvbR, 0.8, 7000
				outs		asigL, asigR
				clear	garvbL, garvbR							;CLEAR GLOBAL AUDIO VARIABLES
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0.0	   3600	;GUI
i 11		0.0     0.01	;INIT

i 2 0 3600			;UPDATE FUNCTION TABLES
i 4 0 3600			;REVERB
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>678</x>
 <y>170</y>
 <width>931</width>
 <height>586</height>
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
  <height>584</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wterrain</label>
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
  <y>174</y>
  <width>160</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>3</midicc>
  <label>X Radius (CC#3)</label>
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
  <objectName>XRadius</objectName>
  <x>448</x>
  <y>174</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.300</label>
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
  <objectName>XRadius</objectName>
  <x>8</x>
  <y>158</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2a8dc6e2-12f4-443d-af9b-59e4373cc24b}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.30000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>212</y>
  <width>150</width>
  <height>30</height>
  <uuid>{4fa545c6-e2f1-4387-8c9f-4a9dd388bb42}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>4</midicc>
  <label>Y Radius (CC#4)</label>
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
  <objectName>YRadius</objectName>
  <x>448</x>
  <y>212</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b0ad1916-b43e-44c2-be40-bca29f5cb1f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.300</label>
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
  <objectName>YRadius</objectName>
  <x>8</x>
  <y>196</y>
  <width>500</width>
  <height>27</height>
  <uuid>{9069e547-5638-4568-896f-980087c61de0}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>4</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.30000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>58</y>
  <width>160</width>
  <height>30</height>
  <uuid>{b066c36d-a132-4a1a-aee4-e421b02bca48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency</label>
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
  <objectName>Freq_Value</objectName>
  <x>448</x>
  <y>58</y>
  <width>60</width>
  <height>30</height>
  <uuid>{262729b5-3e13-43d4-af01-99d1e8aabf34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>400.002</label>
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
  <objectName>Freq</objectName>
  <x>8</x>
  <y>42</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f4910f7d-2341-46e1-aa20-a4d3db351c24}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.66660601</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>96</y>
  <width>160</width>
  <height>30</height>
  <uuid>{5a8c0afb-17da-4ca7-a331-f3ef38db1431}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <label>X Centre (CC#1)</label>
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
  <objectName>XCentre</objectName>
  <x>448</x>
  <y>96</y>
  <width>60</width>
  <height>30</height>
  <uuid>{12d2c823-daba-4a56-9f0c-462a6c951992}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.200</label>
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
  <objectName>XCentre</objectName>
  <x>8</x>
  <y>80</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5442ecac-367f-413c-a49e-5f42a2727519}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>135</y>
  <width>160</width>
  <height>30</height>
  <uuid>{d1ad1809-ed86-4ecd-b6c9-15b4c9686e35}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>2</midicc>
  <label>Y Centre (CC#2)</label>
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
  <objectName>YCentre</objectName>
  <x>448</x>
  <y>135</y>
  <width>60</width>
  <height>30</height>
  <uuid>{39d4f770-c1eb-4c2d-9b6d-41b78e8955f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.700</label>
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
  <objectName>YCentre</objectName>
  <x>8</x>
  <y>119</y>
  <width>500</width>
  <height>27</height>
  <uuid>{37911dd5-758c-4ec8-9871-ce3f5cd67670}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>2</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.69999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>10</x>
  <y>10</y>
  <width>120</width>
  <height>26</height>
  <uuid>{bb365f4a-6dbc-4ef6-b3f4-b623c7af324b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>251</y>
  <width>160</width>
  <height>30</height>
  <uuid>{f6eecd9b-9e04-4bc9-8f38-d5cdef0e1628}</uuid>
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
  <y>251</y>
  <width>60</width>
  <height>30</height>
  <uuid>{53e84345-464e-45f5-bdba-80119763a99e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.400</label>
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
  <y>235</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5348aae7-441e-4ca6-a685-db94cde77834}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.40000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>289</y>
  <width>160</width>
  <height>30</height>
  <uuid>{194590ce-4b68-4ab7-a669-167d987634ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack Time</label>
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
  <objectName>Attack</objectName>
  <x>448</x>
  <y>289</y>
  <width>60</width>
  <height>30</height>
  <uuid>{663f7507-ede2-46e5-9b1d-adcbbaf8de08}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.200</label>
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
  <objectName>Attack</objectName>
  <x>8</x>
  <y>273</y>
  <width>500</width>
  <height>27</height>
  <uuid>{1671df5f-df01-4402-a171-c6ddba540e83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01000000</minimum>
  <maximum>10.00000000</maximum>
  <value>1.20000005</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>328</y>
  <width>160</width>
  <height>30</height>
  <uuid>{22534f63-bbf9-40e1-961e-c46cdd6ebb93}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release Time</label>
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
  <objectName>Release</objectName>
  <x>448</x>
  <y>328</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1e05445f-2bc1-4869-97f0-020e2725a2ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.000</label>
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
  <objectName>Release</objectName>
  <x>8</x>
  <y>312</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3a045162-cb0c-4152-80a5-ba325e63a103}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01000000</minimum>
  <maximum>10.00000000</maximum>
  <value>5.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>258</x>
  <y>389</y>
  <width>250</width>
  <height>190</height>
  <uuid>{4287ed37-444f-4e6b-af0b-4ea806038bfe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Y Wave</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_1</objectName>
  <x>269</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{9fd2a26c-3bc1-4e82-80da-fa9765f313c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>269</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{d651f34e-5355-4c8a-91d8-19077f112481}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>01</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_2</objectName>
  <x>288</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{865e5dea-2ec1-4f19-bfd1-0ed71940968c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>288</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{6c0b700d-777a-4927-a685-0845b96f1805}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>02</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_3</objectName>
  <x>307</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{5fe7ab43-c4b4-4980-a4b5-60eaa4729bc2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>307</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{562c8cdb-cb65-4af3-9529-7cbcde34d358}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>03</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_4</objectName>
  <x>326</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{df1ea1e0-2242-4442-98a3-8a0c2c9ca697}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>326</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{a71d6720-71c0-4840-87e4-f687148cdf8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>04</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_5</objectName>
  <x>345</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{76636528-5c13-45d6-82b7-0638dbe93a7a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>345</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{b1661c45-8931-47be-a3d9-0a8285949869}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>05</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_6</objectName>
  <x>364</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{58561484-9ecf-44c6-8a17-5fa7d774cb18}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>364</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{079ed1b1-3462-4fcf-9227-2a45576da903}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>06</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_7</objectName>
  <x>383</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{f766d35b-ff1e-478b-99d9-edd44962eb61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>383</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{7c2f9ccd-95f9-46e3-bbed-d62bb3317da7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>07</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_8</objectName>
  <x>402</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{8615bd15-a1a8-44af-9629-5dfb5acb0d04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>402</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{2190af00-c89f-43ac-874c-93d0c1048fe3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>08</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_9</objectName>
  <x>421</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{f6e2f11b-ab15-429a-aa21-079530d1b5ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>421</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{4a5a15b3-eefc-4c6b-9d64-e18daa096a86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>09</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_10</objectName>
  <x>440</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{fc4e96d4-340c-47e6-bce2-85dcf494664d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>440</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{0903fa4d-27b9-47d2-a554-43fe945f991e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>10</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_11</objectName>
  <x>459</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{88d8c5a9-6137-4b0b-b588-634cce3fa391}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>459</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{30167e36-917c-4c40-883d-3bfca81d88fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>11</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>2_12</objectName>
  <x>478</x>
  <y>417</y>
  <width>19</width>
  <height>100</height>
  <uuid>{4f01a501-533c-4273-bc3b-0a1fe6e2eee8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>478</x>
  <y>517</y>
  <width>20</width>
  <height>22</height>
  <uuid>{d1f9bed7-4eee-4068-ad41-2ba20e6bb1a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>12</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
  <y>389</y>
  <width>250</width>
  <height>190</height>
  <uuid>{41494c45-26c5-44c7-b917-f44e64a3bcc1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>X Wave</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_1</objectName>
  <x>19</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{c145d997-7eb7-4a8a-bd7e-b54aed6ab077}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>19</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{923fe6dc-f878-487f-9538-bb9670a68f4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>01</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_2</objectName>
  <x>38</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{1062f3df-437f-4148-9f0e-5c106f34f075}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>38</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{3435882e-f0ff-43e6-b8c4-c9703105db71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>02</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_3</objectName>
  <x>57</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{11f92b16-b7ed-4b22-bc1c-714dbbf20b72}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.33000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>57</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{d9ea5ba4-2d00-4dc5-88da-a997d1e031e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>03</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_4</objectName>
  <x>76</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{d85098a5-feab-4e9a-bbc0-a61cf9b85efa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>76</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{f5ae74a6-c924-4c63-b097-d50577621716}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>04</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_5</objectName>
  <x>95</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{362169f3-3a60-4212-841d-7f5850b6635d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>95</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{3a01fe9a-ea13-466b-951d-d7f54a9f0e30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>05</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_6</objectName>
  <x>114</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{3dc3b469-85b4-4c39-8055-4c9beafdc5a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>114</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{199514eb-ac75-4246-a28f-28e274b47aa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>06</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_7</objectName>
  <x>133</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{41cf9d6e-074e-4362-9685-a0bfeeb2f02d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.14000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>133</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{46b7d6fe-34f2-467d-bc05-34851cd3fe1b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>07</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_8</objectName>
  <x>152</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{54ad466a-d9d8-4e3c-afcc-2de083f45ef8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>152</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{33fa643d-9c32-4978-8da4-a3596908fe0a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>08</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_9</objectName>
  <x>171</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{48e4c4c6-23f8-431b-b24f-26d7d2e99b57}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.11000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>171</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{93dce410-0add-41d2-bd8d-e1198481fb9d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>09</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_10</objectName>
  <x>190</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{b10e45e9-f857-489d-8825-3cbf04ae02da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>190</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{d8df6dde-959b-4612-b2df-674096578a43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>10</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_11</objectName>
  <x>209</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{df81e33c-859e-4526-987b-d1723f5c4e4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>209</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{3572210f-6514-4c93-97b9-c007c5ab2d2a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>11</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>1_12</objectName>
  <x>228</x>
  <y>416</y>
  <width>19</width>
  <height>100</height>
  <uuid>{66e7ba26-e273-4f45-8b67-880cac1fdac2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>228</x>
  <y>516</y>
  <width>20</width>
  <height>22</height>
  <uuid>{9c35250c-99f0-4bfd-913e-666a3a9f48c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>20</midicc>
  <label>12</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>8</fontsize>
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
  <y>367</y>
  <width>160</width>
  <height>30</height>
  <uuid>{99a7ec10-317f-4d8d-880b-c3e6730f2106}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Amount</label>
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
  <objectName>Reverb</objectName>
  <x>448</x>
  <y>367</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3f88953d-50d6-4aba-8b8a-d2a21d536e34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
  <objectName>Reverb</objectName>
  <x>8</x>
  <y>351</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0a3aa261-956a-465d-b784-031cbc4ece26}</uuid>
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
  <x>12</x>
  <y>553</y>
  <width>150</width>
  <height>30</height>
  <uuid>{920c9108-aa70-4f42-aabe-afab96e001f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>X Radius Jitter Amount</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>XJitter</objectName>
  <x>12</x>
  <y>537</y>
  <width>240</width>
  <height>27</height>
  <uuid>{0b37ee81-2cdc-4048-81fa-eb86aff81c73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>263</x>
  <y>553</y>
  <width>150</width>
  <height>30</height>
  <uuid>{c6213bd8-c765-403f-98fd-373fcd70c6b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Y Radius Jitter Amount</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>YJitter</objectName>
  <x>263</x>
  <y>537</y>
  <width>240</width>
  <height>27</height>
  <uuid>{af17f9d9-167d-41ce-8d8a-de417430c8f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>2</y>
  <width>410</width>
  <height>584</height>
  <uuid>{4eaa267f-4f93-4c19-b1d3-a11b1e5438ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wterrain</label>
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
  <x>523</x>
  <y>32</y>
  <width>398</width>
  <height>545</height>
  <uuid>{c99aefc5-2fb5-4324-ae25-e9e02945ea8f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------------
wterrain is an implementation of wave terrain synthesis. In wave terrain synthesis two single cycle waveforms are defined and a 3-dimensional 'wave terrain' is constructed by setting these at 90 degrees to wach other.
In this implemention elliptical movement through this wave terrain is defined by first defining the frequency of this movement, then the centre and amplitude (radius) of movement in the x axis and the centre and amplitude (radius) of movement in the y axis.
The two wave forms (shown below) can be modified using the banks of mini sliders. The 12 sliders represent the relative amplitudes of the first 12 partials of a harmonic waveform. The first function table (x axis) is rich in higher harmonics, the second is a sine wave.
A simple ASR envelope also modulates the radius values. The user can adjust the attack and release times of this envelope.
A user definable amount of jitter can be applied to the two paramters. This can be useful in preventing static sounding timbres. Some reverb can also be added in this example to further warm up the sound.
This example can also be played from a MIDI keyboard. In this mode MIDI pitch is translated to frequency of the elliptical movement. (GUI defined frequency will be ignored.) MIDI note velocity will also modulate the two radii parameters ised in forming the ellipse. Aurally this equates to 'brightness'. Some keyboard scaling is used in MIDI actuated notes. This is done in order to prevent excessive shrillness in the upper register with respect to how notes sound in the lower register. The two 'centre' and 'radius' paramters can also be modulated using MIDI controllers 1-4 as indicated in the GUI.</label>
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

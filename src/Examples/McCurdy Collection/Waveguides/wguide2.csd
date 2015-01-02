;Written by Iain McCurdy, 2010


;Modified for QuteCsound by René, April 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files


;Wguide2 implements 2 delays and first order lowpass filters with feedback in a single unit opcode.
;This arrangement is as shown below:
;
;              +-----<-----[FEEDBACK]<-------+
;              |                             |
;              |  +-----+  +--------------+  |
;              +->+DELAY+->+LOWPASS FILTER+->+
;                 +-----+  +--------------+
;                 |
;             IN->+------------------------------>OUT
;                 |
;                 +-----+  +--------------+
;              +->+DELAY+->+LOWPASS FILTER+->+
;              ^  +-----+  +--------------+  |
;              |                             |
;              +-----<-----[FEEDBACK]<-------+


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 32	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


;TABLES FOR EXP SLIDER
giExp1	ftgen	0, 0, 129, -25, 0, 20.0, 128, 10000.0
giExp2	ftgen	0, 0, 129, -25, 0, 20.0, 128, 20000.0


opcode FilePlay2, aa, Skoo		; Credit to Joachim Heintz
	;gives stereo output regardless your soundfile is mono or stereo
	Sfil, kspeed, iskip, iloop	xin
	ichn		filenchnls	Sfil
	if ichn == 1 then
		aL		diskin2	Sfil, kspeed, iskip, iloop
		aR		=		aL
	else
		aL, aR	diskin2	Sfil, kspeed, iskip, iloop
	endif
		xout		aL, aR
endop

instr	1	;GUI & INPUT
;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		kingain		invalue	"InputGain"
		kfreq1		invalue 	"Freq1"
		gkfreq1		tablei	kfreq1, giExp1, 1
					outvalue	"Freq1_Value", gkfreq1
		kfreq2		invalue 	"Freq2"
		gkfreq2		tablei	kfreq2, giExp1, 1
					outvalue	"Freq2_Value", gkfreq2
		kcutoff1		invalue 	"Cutoff1"
		gkcutoff1		tablei	kcutoff1, giExp2, 1
					outvalue	"Cutoff1_Value", gkcutoff1
		kcutoff2		invalue 	"Cutoff2"
		gkcutoff2		tablei	kcutoff2, giExp2, 1
					outvalue	"Cutoff2_Value", gkcutoff2
		gkfeedback1	invalue 	"Feedback1"
		gkfeedback2	invalue 	"Feedback2"
		gkamp		invalue 	"Amplitude"
		kinput		invalue	"Input"

		Sfile_new		strcpy	""							;INIT TO EMPTY STRING
		Sfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	Sfile
		kfile 		strcmpk	Sfile_new, Sfile_old
	endif
;INPUT
	if	kinput==0		then									;IF INPUT 'Audio File' IS SELECTED...
		kNew_file		changed	kfile						;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
		if	kNew_file=1	then								;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
			reinit	NEW_FILE								;BEGIN A REINITIALISATION PASS FROM LABEL 'NEW_FILE'
		endif
		NEW_FILE:
		gasigL, gasigR	FilePlay2	Sfile, 1, 0, 1					;GENERATE 2 AUDIO SIGNALS FROM A SOUND FILE	
					rireturn
	elseif	kinput==1	then									;IF INPUT 'Live' IS SELECTED...
		asigL, asigR	ins									;TAKE INPUT FROM COMPUTER'S AUDIO INPUT
		gasigL	=	asigL * kingain						;SCALE USING 'Input Gain' SLIDER
		gasigR	=	asigR * kingain						;SCALE USING 'Input Gain' SLIDER
	else													;OTHERWISE...
		kint		random	0.1,0.4							;INTERVAL BETWEEN IMPULSES IS RANDOMISED SLIGHTLY
		a1		mpulse	4,kint							;GENERATE IMPULSES
		kcfoct	randomi	6,12,2							;GENERATE RANDOM VALUES FOR FILTER CUTOFF FREQUENCY (OCT FORMAT)
		gasigL	butlp	a1, cpsoct(kcfoct)					;LOWPASS FILTER STREAM OF CLICKS
		gasigR	=		gasigL							;SET RIGHT CHANNEL SIGNAL TO THE SAME AS THE LEFT CHANNEL SIGNAL
	endif
endin

instr	2	;WGUIDE2 INSTRUMENT
	iporttime	=		0.1									;I-RATE VARIABLE DEFINITION OF PORTAMENTO TIME
	kporttime	linseg	0, 0.01, iporttime, 1, iporttime			;RAMPING UP FROM ZERO VERSION OF PORTAMENTO TIME VARIABLE
	kfreq1	portk	gkfreq1, kporttime						;SMOOTH VARIABLE CHANGES WITH PORTK
	afreq1	interp	kfreq1								;INTERPOLATE TO CREATE A-RATE VERSION OF K-RATE VARIABLE
	kfreq2	portk	gkfreq2, kporttime						;SMOOTH VARIABLE CHANGES WITH PORTK
	afreq2	interp	kfreq2								;INTERPOLATE TO CREATE A-RATE VERSION OF K-RATE VARIABLE

	;OUTPUT	OPCODE | INPUT  |    FREQ1&2    | LPF_CUTOFF_FREQ 1&2 | FEEDBACK_RATIO 1&2
	aresL	wguide2	gasigL, afreq1, afreq2, gkcutoff1, gkcutoff2, gkfeedback1, gkfeedback2
	aresR	wguide2	gasigR, afreq1, afreq2, gkcutoff1, gkcutoff2, gkfeedback1, gkfeedback2
	aresL	dcblock2	aresL								;BLOCK DC OFFSET
	aresR	dcblock2	aresR								;BLOCK DC OFFSET           
			outs		aresL * gkamp, aresR * gkamp				;SEND wguide2 OUTPUT TO THE AUDIO OUTPUTS AND SCALE USING THE GUI SLIDER VARIABLE gkamp
			clear	gasigL, gasigR							;CLEAR GLOBAL AUDIO VARIABLES
endin

instr	3	;INIT
			outvalue		"Freq1"		, 0.2786
			outvalue		"Cutoff1"		, 1.0
			outvalue		"Feedback1"	, 0.27
			outvalue		"Freq2"		, 0.4206
			outvalue		"Cutoff2"		, 1.0
			outvalue		"Feedback2"	, 0.23
			outvalue		"Amplitude"	, 0.7
endin
</CsInstruments>
<CsScore>
i 1 0 3600	;GUI
i 3 0 0.01	;INIT 
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1162</x>
 <y>142</y>
 <width>920</width>
 <height>486</height>
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
  <height>480</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wguide2</label>
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
   <r>170</r>
   <g>170</g>
   <b>170</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>78</y>
  <width>220</width>
  <height>30</height>
  <uuid>{640b50b7-7200-4f81-8394-89d9843ae939}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Live Input Gain</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>InputGain</objectName>
  <x>8</x>
  <y>56</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.58000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>20</y>
  <width>80</width>
  <height>26</height>
  <uuid>{04d44ebe-12eb-4bb0-a3f5-9e4fd3e7830e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off</text>
  <image>/</image>
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>2</y>
  <width>399</width>
  <height>480</height>
  <uuid>{cd1b9ee0-e607-49ed-9a8d-37ebb3d7fe8f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wguide2</label>
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
   <r>170</r>
   <g>170</g>
   <b>170</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>519</x>
  <y>18</y>
  <width>392</width>
  <height>350</height>
  <uuid>{16d3e28c-026e-45ef-b167-57f393c4e2d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------
Wguide2 implements 2 delays and first order lowpass filters with feedback in a single unit opcode.
This arrangement is as shown in the csd.
Wguide2 can imbue the resonant characteristics of a metal plate to an impulse signal.
In this implementation three options for the impulse (input) signal are provided:

(1) Sound file
(2) Live input
(3) a stream of click impulses.

As both feedback loops impact upon the feedback of the entire system care should be taken in adjusting them.
To prevent out of control resonance, the sum of both feedback parameters should not exceed 0.5.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>InputGain</objectName>
  <x>448</x>
  <y>78</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.502</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>178</x>
  <y>409</y>
  <width>120</width>
  <height>30</height>
  <uuid>{9b81a1f2-bcb8-4582-925b-9ae56def3865}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Audio File</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Live Input</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Impulses</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>96</x>
  <y>409</y>
  <width>80</width>
  <height>30</height>
  <uuid>{62eeb695-9b83-42da-81cd-8000c232d9b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>6</x>
  <y>447</y>
  <width>170</width>
  <height>30</height>
  <uuid>{9b992da1-8c0f-449e-af03-7913cc05efed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>Seashore.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>178</x>
  <y>448</y>
  <width>330</width>
  <height>28</height>
  <uuid>{15a8ec14-710f-43e6-be9e-f5dc8c8786cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Seashore.wav</label>
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
  <x>8</x>
  <y>123</y>
  <width>220</width>
  <height>30</height>
  <uuid>{1daeb2b9-bae2-4c0a-939b-62c3ea3ac853}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency 1</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Freq1</objectName>
  <x>8</x>
  <y>101</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b378cb0c-4cee-4f42-86ad-2a0d9524d355}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.27860001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Freq1_Value</objectName>
  <x>448</x>
  <y>123</y>
  <width>60</width>
  <height>30</height>
  <uuid>{cf1f320e-c59c-4b26-82b5-f405ba7194fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>113.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <objectName>Freq2</objectName>
  <x>8</x>
  <y>146</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2e1f3a23-2e04-44eb-98e7-edaed6ee7738}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.42060000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>298</y>
  <width>220</width>
  <height>30</height>
  <uuid>{e42ccc90-ebf9-46dd-8039-f576154182be}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feedback 1</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Feedback1</objectName>
  <x>8</x>
  <y>276</y>
  <width>500</width>
  <height>27</height>
  <uuid>{75cac143-6654-4010-8cb5-fc135e0c20a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.99900000</maximum>
  <value>0.27000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Feedback1</objectName>
  <x>448</x>
  <y>298</y>
  <width>60</width>
  <height>30</height>
  <uuid>{72854ca7-b440-493d-b677-f4a67a0ed75e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.270</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>165</y>
  <width>220</width>
  <height>30</height>
  <uuid>{9c2e23bf-ca72-4b2c-a99f-b6772ee736f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency 2</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <objectName>Freq2_Value</objectName>
  <x>448</x>
  <y>165</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f4bb4812-56d2-4d6a-b88f-ceaa5252764e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>273.078</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>253</y>
  <width>220</width>
  <height>30</height>
  <uuid>{fb4c2ea6-45d1-4cc2-ac15-251b3e6f8dd7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LPF Cutoff Frequency 2</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Cutoff2</objectName>
  <x>8</x>
  <y>231</y>
  <width>500</width>
  <height>27</height>
  <uuid>{cc1c5b49-3ee5-4c25-a2fb-10e67720328e}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Cutoff2_Value</objectName>
  <x>448</x>
  <y>253</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9f824988-e743-4a46-b6f8-f38443525daa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20000.010</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>342</y>
  <width>220</width>
  <height>30</height>
  <uuid>{49df84b0-d9df-41fd-86d9-fa4ca6e6ba9f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feedback 2</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Feedback2</objectName>
  <x>8</x>
  <y>320</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3b608fcd-c770-4a03-ae60-8d6f66b9299e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.99900000</maximum>
  <value>0.23000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Feedback2</objectName>
  <x>448</x>
  <y>342</y>
  <width>60</width>
  <height>30</height>
  <uuid>{007cedae-4a69-4555-8c57-ee7907b48b91}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.230</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>386</y>
  <width>220</width>
  <height>30</height>
  <uuid>{c16720de-0aff-42a2-bd77-7b55cfb98521}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Amplitude Scaling</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>364</y>
  <width>500</width>
  <height>27</height>
  <uuid>{c27cb3ac-ab29-4cdc-9d88-6dc7c3b31f32}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.69999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>386</y>
  <width>60</width>
  <height>30</height>
  <uuid>{64062023-ce9a-4aaa-8a53-28f1a67ce4e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.700</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>209</y>
  <width>220</width>
  <height>30</height>
  <uuid>{a256f411-1ec8-4ee5-a194-facf0001e20f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LPF Cutoff Frequency 1</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Cutoff1</objectName>
  <x>8</x>
  <y>187</y>
  <width>500</width>
  <height>27</height>
  <uuid>{95bdad02-3ae8-4877-be18-2ebd131fd9d0}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Cutoff1_Value</objectName>
  <x>448</x>
  <y>209</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7283d045-c7ee-421f-be9e-17eee7be8df9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20000.010</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

;Written by Iain McCurdy, 2009

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Macro SWITCH and modifications in instruments to get the same behaviour as FLTK button
;	Pause change to avoid high cpu load


;my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 --expression-opt -+rtmidi=null
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)


	giaudio		ftgen	0, 0, 1048576, -7, 0, 1048576, 0	;AUDIO DATA STORAGE

	gkrecdur		init		0


#define SWITCH(Name'Value'Instr_Led'Instr_Event)
#
	;To have a latched+event+value button *****************************************
				strset	$Value, "$Name_L"
	k$Name		init		0

	kButton		invalue	"$Name_B"
	kB_ON		trigger	kButton, 0.5, 0

	if (k$Name == 0) then
		schedkwhen	kB_ON, 0, 0, $Instr_Led, 0, 0, $Value, 1	;Led ON
		schedkwhen	kB_ON, 0, 0, $Instr_Event, 0, -1			;Start instr
	else
		schedkwhen	kB_ON, 0, 0, $Instr_Led, 0, 0, $Value, 0	;Led OFF
		schedkwhen	kB_ON, 0, 0, -$Instr_Event, 0, 1			;Stop instr
	endif
	k$Name		invalue	"$Name_L" 
	;******************************************************************************
#


instr	1	;GUI
	$SWITCH(Record'100'2'11)
	$SWITCH(PlayStop'200'2'13)

	gkPause		invalue	"Pause"
	gkSpeed		invalue	"Speed"
	gkLoopBeg		invalue	"LoopBeg"
	gkLoopEnd		invalue	"LoopEnd"
endin

instr	2	;LED ON/OFF
	Sp4		strget	p4
			outvalue	Sp4, p5
endin

instr	11	;RECORD
	if	gkPause = 1	then									;IF PAUSE BUTTON IS ACTIVATED...
		kgoto	END										;GOTO 'END' LABEL
	endif												;END OF CONDITIONAL BRANCHING

	itablelen	tableng	giaudio

	ain		inch		1									;READ AUDIO FROM LIVE INPUT CHANNEL 1
	andx		line		0, itablelen/sr, 1						;CREATE A POINTER FOR WRITING TO TABLE - FREQUENCY OF POINTER IS DEPENDENT UPON TABLE LENGTH AND SAMPLE RATE
	andx		=		andx * itablelen						;RESCALE POINTER ACCORDING TO LENGTH OF FUNCTION TABLE 
	gkrecdur	downsamp	andx									;CREATE A K-RATE GLOBAL VARIABLE THAT WILL BE USED BY THE 'PLAYBACK' INSTRUMENT TO DETERMINE THE LENGTH OF RECORDED DATA			

			;OPCODE  INPUT | INDEX | TABLE
			tablew	ain,   andx,  giaudio					;WRITE AUDIO TO AUDIO STORAGE TABLE

	if	gkrecdur >= itablelen	then							;IF MAXIMUM RECORD TIME IS REACHED...
		schedkwhen	1, 0, 0, 2, 0, 0, 100, 0					;Record Led OFF
		turnoff											;TURN OFF THIS INSTRUMENT IMMEDIATELY.
	endif												;END OF CONDITIONAL BRANCHING
	END:
endin
		
instr	12	;PLAYBACK LOOPED INSTRUMENT
	if	gkPause = 1	then									;IF PAUSE BUTTON IS ACTIVATED... 
		kgoto	END										;GOTO 'END' LABEL
	endif												;END OF CONDITIONAL BRANCHING

	iporttime	=		0.02
	kporttime	linseg	0,0.001,iporttime,1,iporttime
	kLoopBeg	portk	gkLoopBeg, kporttime
	kLoopEnd	portk	gkLoopEnd, kporttime
	
	kLoopBeg	=	kLoopBeg * gkrecdur							;RESCALE gkLoopBeg (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH. NEW OUTPUT VARIABLE kLoopBeg.
	kLoopEnd	=	kLoopEnd * gkrecdur							;RESCALE gkLoopEnd (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH. NEW OUTPUT VARIABLE kLoopEnd.
	kLoopLen	=	kLoopEnd - kLoopBeg							;DERIVE LOOP LENGTH FROM LOOP START AND END POINTS

	;        OPCODE 	NUMERATOR | DENOMINATOR | SUBSTUTION_VALUE_(IF_DENOMINATOR=0)
	kPhasFrq	divz		gkSpeed,   (kLoopLen/sr),   .00001			;SAFELY DIVIDE, PROVIDING ALTERNATIVE VALUE INCASE DENOMINATOR IS ZERO 
	andx		phasor	kPhasFrq								;DEFINE PHASOR POINTER FOR TABLE INDEX
	kLoopBeg	=	(kLoopBeg < kLoopEnd ? kLoopBeg : kLoopEnd)		;CHECK IF LOOP-BEGINNING AND LOOP-END SLIDERS HAVE BEEN REVERSED
	andx		=	(andx*abs(kLoopLen)) + kLoopBeg				;RESCALE INDEX POINTER ACCORDING TO LOOP LENGTH AND LOOP BEGINING

	;OUT 	OPCODE 	INDEX | FUNCTION_TABLE
	asig		tablei	andx,    giaudio						;READ AUDIO FROM AUDIO STORAGE FUNCTION TABLE
			outs		asig, asig							;SEND AUDIO TO OUTPUTS
	END:
endin

instr	13	;PLAY THEN STOP
	if	gkPause = 1	then									;IF PAUSE BUTTON IS ACTIVATED... 
		kgoto	END										;GOTO 'END' LABEL
	endif												;END OF CONDITIONAL BRANCHING

	kLoopBeg	=	gkLoopBeg * gkrecdur						;RESCALE gkLoopBeg (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH. NEW OUTPUT VARIABLE kLoopBeg.
	kLoopEnd	=	gkLoopEnd * gkrecdur						;RESCALE gkLoopEnd (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH. NEW OUTPUT VARIABLE kLoopEnd.

	if	kLoopEnd > kLoopBeg	then
		andx	line		0,1,1
		andx	=		(andx*gkSpeed*sr)+kLoopBeg
		kndx	downsamp	andx									;CREATE kndx, A K-RATE VERSION OF andx
		if	kndx > kLoopEnd	then							;IF END OF RECORDING IS REACHED...
			schedkwhen	1, 0, 0, 2, 0, 0, 200, 0				;PlayStop Led OFF
			turnoff										;TURN OFF THIS INSTRUMENT IMMEDIATELY.
		endif
	else
		andx	line	0,1,-1
		andx	=		(andx*gkSpeed*sr)+kLoopBeg
		kndx	downsamp	andx									;CREATE kndx, A K-RATE VERSION OF andx
		if	kndx < kLoopEnd	then							;IF END OF RECORDING IS REACHED...
			schedkwhen	1, 0, 0, 2, 0, 0, 200, 0				;PlayStop Led OFF
			turnoff										;TURN OFF THIS INSTRUMENT IMMEDIATELY.
		endif
	endif												;END OF CONDITIONAL BRANCHING

	;OUT 	OPCODE	INDEX | FUNCTION_TABLE
	asig		tablei	andx,    giaudio						;READ AUDIO FROM AUDIO STORAGE FUNCTION TABLE
			outs		asig, asig							;SEND AUDIO TO OUTPUTS
	END:
endin
</CsInstruments>
<CsScore>
i 1 0 3600	;GUI
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>202</r>
  <g>202</g>
  <b>202</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>512</width>
  <height>260</height>
  <uuid>{395a9956-93f5-441f-b0ef-3828f1b2da1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Record Audio to Function Table With Playback</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>Record_B</objectName>
  <x>8</x>
  <y>42</y>
  <width>80</width>
  <height>30</height>
  <uuid>{c54faf18-3b5b-4a78-b803-69b1c339890e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>       Rec</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Pause</objectName>
  <x>98</x>
  <y>42</y>
  <width>80</width>
  <height>30</height>
  <uuid>{63b09b32-866d-4b31-ba3c-fb6f456359dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    Pause</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>2</y>
  <width>480</width>
  <height>260</height>
  <uuid>{10e7ae72-c151-4c9d-9f49-e6b1585d8386}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Record Audio to Function Table With Playback</label>
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
  <y>17</y>
  <width>477</width>
  <height>244</height>
  <uuid>{97dfe67c-26c1-4af5-b858-e301d6886c2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>---------------------------------------------------------------------------------------------------------------------
This example records live audio to a function table which the user can then play back. A pause button pauses both record and playback.
If record is pressed for a second time the original recording is overwritten. Maximum record time is determined by function table size and sampling rate. In this example table size is 1048576 and sampling rate is 44100Hz therefore maximum record time is 1048576/44100 = 24 seconds (approx.) If maximum record time is reached, recording will cease and the record button is deactivated. Playback can be either 'one shot' (triangle + line button) or looped (triangle button). The recorded data is monophonic and live input is read from the first (left) input channel but this could easily be modified to record in stereo (or more). Included are controls for playback speed and for playback start and end points. If the start and end points are inverted playback will be reversed.</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>112</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2c897206-0dbc-47b5-ba68-915d83839ab6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Speed</label>
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
  <objectName>Speed</objectName>
  <x>8</x>
  <y>93</y>
  <width>500</width>
  <height>27</height>
  <uuid>{304e78d8-b320-453a-b28f-86b0ca872b86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00060000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Speed</objectName>
  <x>448</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{94c7e961-7981-4d21-942f-80bcc647daf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.001</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>187</x>
  <y>42</y>
  <width>80</width>
  <height>30</height>
  <uuid>{6fe53ee7-bd5d-4064-80fb-2ea628a7c5ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>      Play</text>
  <image>/</image>
  <eventLine>i 12 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>PlayStop_B</objectName>
  <x>279</x>
  <y>42</y>
  <width>82</width>
  <height>30</height>
  <uuid>{f0ca6175-5df0-4532-a841-7dc3313ac41d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    Play Stop</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>LoopBeg</objectName>
  <x>8</x>
  <y>153</y>
  <width>500</width>
  <height>14</height>
  <uuid>{8ecd7788-78c9-479b-8364-3c4fc256ea10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.20800000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
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
  <objectName>LoopEnd</objectName>
  <x>8</x>
  <y>176</y>
  <width>500</width>
  <height>14</height>
  <uuid>{5aab0f2a-2456-4053-a07d-5e70c1c3d0ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.87400000</xValue>
  <yValue>0.00000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
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
  <x>203</x>
  <y>189</y>
  <width>100</width>
  <height>30</height>
  <uuid>{995aad6e-4f08-434c-ab9b-1936b51e2b3a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop Points</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>15</x>
  <y>52</y>
  <width>10</width>
  <height>10</height>
  <uuid>{38085679-3d54-407a-ba33-8ccad19971ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Record_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.12389381</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
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
  <objectName/>
  <x>285</x>
  <y>52</y>
  <width>10</width>
  <height>10</height>
  <uuid>{5b3b05aa-35e7-4e25-ab6d-31fa61bf8b76}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PlayStop_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.12389381</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

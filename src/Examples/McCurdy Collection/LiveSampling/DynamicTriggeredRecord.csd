;Written by Iain McCurdy, 2008

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 January 2011 and QuteCsound svn rev 805


;Notes on modifications from original csd:
;	Macro SWITCH and modifications in instruments to get the same behaviour as FLTK button


;my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 --expression-opt -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)


	giaudio		ftgen	0, 0, 1048576, -7, 0, 1048576, 0	;AUDIO DATA STORAGE

	gkrecdur		init		0

				strset	400, "Record_Led"


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


instr	10	;GUI

	$SWITCH(RecReady'100'11'3)
	$SWITCH(PlayOnce'200'11'5)
	$SWITCH(LoopPlay'300'11'6)
		
	gkAutoPlayOnce		invalue	"Auto_Play_Once"
	gkAutoLoopPlay		invalue	"Auto_Play_Looped"
	gkResetRecReady	invalue	"Reset_Rec_Ready"

	gkOnThresh		invalue 	"On_Threshold"
	gkOffThresh		invalue 	"Off_Threshold"
	gkSpeed			invalue 	"Speed"
	gkGain			invalue 	"Gain"
endin

instr	11	;LED ON/OFF
	Sp4		strget	p4
			outvalue	Sp4, p5
endin

instr	1	;MIDI PLAYBACK
	icps		cpsmidi								;READ MIDI PITCH DATA FROM MIDI INPUT
	imlt		=		icps/cpsoct(8)					;MIDDLE C IS BASE FREQUENCY
	iamp		ampmidi	1
	andx		line		0,1,1						;INFINITELY RISING LINE USED AS STARTING POINT FOR FILE POINTER
	if	gkSpeed >= 0	then							;IF gkSpeed is POSITIVE (OR ZERO), I.E. FORWARDS PLAYBACK
		andx		=	andx*sr*imlt					;RESCALE POINTER ACCORDING TO SPEED
		kndx	downsamp	andx							;CREATE kndx, A K-RATE VERSION OF andx
		if	kndx >= gkrecdur	then					;IF END OF RECORDING IS REACHED...
			schedkwhen	1, 0, 0, 11, 0, 0, 200, 0	;TURN OFF PlayOnce Button Led &
			turnoff								;TURN OFF THIS INSTRUMENT IMMEDIATELY.
		endif
	else
		andx	=		(andx*sr*imlt)+i(gkrecdur)		;RESCALE POINTER ACCORDING TO SPEED
		kndx	downsamp	andx							;CREATE kndx, A K-RATE VERSION OF andx
		if	kndx < 0	then							;IF END OF RECORDING IS REACHED...
			schedkwhen	1, 0, 0, 11, 0, 0, 200, 0	;TURN OFF PlayOnce Button Led &
			turnoff								;TURN OFF THIS INSTRUMENT IMMEDIATELY.
		endif
	endif
	;OUT 	OPCODE 	INDEX | FUNCTION_TABLE
	asig		table3	andx,      giaudio				;READ AUDIO FROM AUDIO STORAGE FUNCTION TABLE
	aenv		linsegr	0,0.001,1,0.01,0
	asig		=		asig * gkGain * aenv * iamp
			outs		asig, asig
endin

instr	2	;READ RT AUDIO IN AND CREATE FOLLOW SIGNAL
	gasig 		inch		1						;READ CHANNEL 1 (LEFT CHANNEL IF STEREO)

	afollow 		follow2 	gasig, .1, .1				;CREATE A AMPLITUDE FOLLOWING UNIPOLAR SIGNAL
	gkfollow		downsamp	afollow					;DOWNSAMPLE TO CREATE A K-RATE VERSION OF THE AMPLITUDE FOLLOWING SIGNAL
	kmeter		downsamp	afollow					;CONVERT AMPLITUDE FOLLOWING SIGNAL TO K-RATE
	kmeter		portk	kmeter, .1				;SMOOTH THE MOVEMENT OF THE AMPLITUDE FOLLOWING SIGNAL - THIS WILL MAKE THE METERS EASIER TO VIEW
	kmetertrig	metro	30						;METRONOMIC TRIGGER
	if kmetertrig = 1 then
		outvalue	"Meter", kmeter					;UPDATE METER
	endif
endin

instr	3	;RECORD_READY
	if	gkfollow > gkOnThresh	then					;IF AMPLITUDE FOLLOWING SIGNAL IS ABOVE 'ON THRESHOLD'...
		schedkwhen	1, 0, 0, 11, 0, 0, 400, 1		;...TURN ON 'RECORDING' RED LIGHT...
		schedkwhen	1, 0, 0, 11, 0, 0, 100, 0		;...TURN OFF 'RECORD READY' BUTTON LIGHT
		;SCHEDKWHEN 	KTRIGGER, KMINTIM, KMAXNUM, KINSNUM, KWHEN, KDUR
		schedkwhen    	1, 	     0,       1,       4,      0,    -1		;AND TRIGGER RECORD
		turnoff									; AND TURN OFF THIS INSTRUMENT IMMEDIATELY (WE DON'T WANT TO RETRIGGER RECORDING UNTIL THE CURRENT ONE HAS COMPLETED) 
	endif										;END OF CONDITIONAL BRANCHING
endin

instr	4	;RECORD
	itablen	tableng	giaudio						;INTERROGATE FUNCTION TABLE USED FOR AUDIO RECORDING TO DETERMINE ITS LENGTH - THIS WILL BE USED TO CONTROL THE MOVEMENT OF THE WRITE POINTER
	andx		phasor	sr / itablen					;CREATE A WRITE POINTER USING phasor. FREQUENCY WILL BE DEPENDENT UPON SAMPLING RATE (sr) AND THE LENGTH OF THE TABLE USED FOR STORAGE
	andx		=		andx * itablen					;RESCALE THE SCOPE OF THE POINTER
	gkrecdur	downsamp	andx							;CREATE A GLOBAL K-RATE VERSION OF THE WRITE POINTER
	aenv		linsegr	0, .005, 1, .005, 0				;CREATE 'ANTI-CLICK' AMPLITUDE ENVELOPE FOR AUDIO THAT IS WRITTEN TO THE FUNCTION TABLE
	asig		=		gasig * aenv					;'ANTI-CLICK' AMPLITUDE ENVELOPE IS APPLIED TO AUDIO BEFORE IT IS WRITTEN TO THE TABLE
			tablew	asig, andx, giaudio				;WRITE AUDIO TO AUDIO STORAGE TABLE

	if	gkfollow < gkOffThresh	then					;IF OUR AMPLITUDE FOLLOWING VARIABLE HAS DROPPED BELOW THE 'OFF THRESHOLD'...
		schedkwhen	1, 0, 0, 11, 0, 0, 400, 0		;...TURN OFF 'RECORDING' RED LIGHT
		if	gkAutoLoopPlay = 1	then					;IF 'Auto Play Looped' IS ON...
			schedkwhen	1, 0, 0, 11, 0, 0, 300, 1	;TURN ON PLAY LOOPED BUTTON LIGHT
			schedkwhen	1, 0, 0, 6, 0, -1			;Start PLAY_LOOPED
		elseif	gkAutoPlayOnce = 1	then				;IF 'Auto Play Once' IS ON...
			schedkwhen	1, 0, 0, 11, 0, 0, 200, 1	;...TURN ON 'Play Once' BUTTON LIGHT
			schedkwhen	1, 0, 0, 5, 0, -1			;Start PLAY_ONCE
		endif									;END OF CURRENT CONDITIONAL BRANCH
		if	gkResetRecReady = 1	then					;IF 'Reset Rec. Ready' IS ON...
			schedkwhen	1, 0, 0, 11, 0, 0, 100, 1	;...TURN ON 'Rec. Ready' BUTTON LIGHT
			schedkwhen	1, 0, 0, 3, 0, -1			;Start RECORD_READY
		endif									;END OF CURRENT CONDITIONAL BRANCH
		turnoff									;TURNOFF THIS INSTRUMENT IMMEDIATELY
	endif										;END OF CONDITIONAL BRANCHING
endin

instr	5	;PLAY_ONCE
	andx		line		0, 1, 1						;INFINITELY RISING LINE USED AS STARTING POINT FOR FILE POINTER
	if	gkSpeed >= 0	then							;IF skSpeed is POSITIVE (OR ZERO), I.E. FORWARDS PLAYBACK
		andx	=		andx*sr*gkSpeed				;RESCALE POINTER ACCORDING TO SPEED
		kndx	downsamp	andx							;CREATE kndx, A K-RATE VERSION OF andx
		if	kndx >= gkrecdur	then					;IF END OF RECORDING IS REACHED...
			schedkwhen	1, 0, 0, 11, 0, 0, 200, 0	;...DEACTIVATE "PLAY ONCE" BUTTON &
			turnoff								;TURN OFF THIS INSTRUMENT IMMEDIATELY.
		endif
	else
		andx	=		(andx*sr*gkSpeed)+i(gkrecdur)		;RESCALE POINTER ACCORDING TO SPEED
		kndx	downsamp	andx							;CREATE kndx, A K-RATE VERSION OF andx
		if	kndx < 0	then							;IF END OF RECORDING IS REACHED...
			schedkwhen	1, 0, 0, 11, 0, 0, 200, 0	;...DEACTIVATE "PLAY ONCE" BUTTON &
			turnoff								;TURN OFF THIS INSTRUMENT IMMEDIATELY.
		endif
	endif
	;OUT 	OPCODE 	INDEX | FUNCTION_TABLE
	asig		table3	andx,      giaudio				;READ AUDIO FROM AUDIO STORAGE FUNCTION TABLE
			outs		asig*gkGain, asig*gkGain
endin

instr	6	;PLAY_LOOPED
	irecdur	=		i(gkrecdur)					;DEFINE irecdur, AN I-RATE VERSION OF THE MOST RECENT VALUE OF gkrecdur (RECORDING DURATION IN SAMPLE FRAMES / TABLE POINT VALUES)
	aptr		phasor	(sr * gkSpeed) / irecdur			;CREATE READ POINTER FREQUENCY DEPENDENT UPON SAMPLING RATE, 'Speed' SLIDER, AND irecdur 
	aptr		=		aptr * irecdur					;RESCALE READ POINTER ACCCORDING TO irecdur VALUE SO THAT THE ENTIRE DURATION OF THE LAST RECORDING WILL BE PLAYED
	asig		table3	aptr, giaudio					;READ AUDIO FROM FUNCTION TABLE USING table3 OPCODE
	aenv		linsegr	1, 3600, 1, .01, 0				;CREATE AN AMPLITUDE ENVELOPE RELEASE FADE OUT TO PREVENT CLICKS IF PLAYBACK IS TERMINATED
			outs		asig*aenv*gkGain, asig*aenv*gkGain
endin
</CsInstruments>
<CsScore>
i 10 0 3600	;GUI
i  2 0 3600	;READ RT AUDIO IN AND CREATE FOLLOW SIGNAL
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>498</x>
 <y>607</y>
 <width>995</width>
 <height>342</height>
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
  <width>510</width>
  <height>335</height>
  <uuid>{395a9956-93f5-441f-b0ef-3828f1b2da1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dynamic Triggered Recording</label>
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
  <objectName>RecReady_B</objectName>
  <x>8</x>
  <y>33</y>
  <width>120</width>
  <height>26</height>
  <uuid>{0a44e1b8-fab4-40c8-8fa1-f1d1d743c45c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>   Record Ready</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>PlayOnce_B</objectName>
  <x>194</x>
  <y>42</y>
  <width>120</width>
  <height>26</height>
  <uuid>{92fe2dde-2f95-4c3b-8088-27e8231c20f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>   Play Once</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>LoopPlay_B</objectName>
  <x>194</x>
  <y>80</y>
  <width>120</width>
  <height>26</height>
  <uuid>{5d0ee36e-ffdb-4662-8831-cab2fad8ffab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>       Play Looped </text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Reset_Rec_Ready</objectName>
  <x>9</x>
  <y>89</y>
  <width>120</width>
  <height>26</height>
  <uuid>{199ec560-95d2-407d-b90e-6dcbead11ec2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Reset Rec Ready</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Auto_Play_Once</objectName>
  <x>320</x>
  <y>42</y>
  <width>140</width>
  <height>26</height>
  <uuid>{c54faf18-3b5b-4a78-b803-69b1c339890e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>   Auto Play Once</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Auto_Play_Looped</objectName>
  <x>320</x>
  <y>80</y>
  <width>140</width>
  <height>26</height>
  <uuid>{63b09b32-866d-4b31-ba3c-fb6f456359dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    Auto Play Loop</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>515</x>
  <y>2</y>
  <width>480</width>
  <height>335</height>
  <uuid>{10e7ae72-c151-4c9d-9f49-e6b1585d8386}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dynamic Triggered Recording</label>
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
  <x>518</x>
  <y>26</y>
  <width>474</width>
  <height>308</height>
  <uuid>{97dfe67c-26c1-4af5-b858-e301d6886c2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------
This example tracks the dynamics of the live incoming audio and triggers a recording function (writing to a function table) when the signal rises above a user defined amplitude threshold. When the signal subsequently drops below another user defined threshold recording ceases. What is stored in he function table is a topped and tailed sound fragment without silence at the begging or end of the recording.
The 'Rec. Ready' button must be on to begin scanning the input signal amplitude for threshold crossing. The user then has the option of playing back the recording either once ('Play (Once)') or looped  ('Play (Looped)'). If 'Auto Play Once' is selected the recording begins playing immediately the recording process ceases. 'Auto Play Looped' acts in a similar fashion but on the 'Play (Looped)' function. If 'Reset Rec. Ready' is selected the 'Rec. Ready' button is automatically switched on again as soon as recording has completed. The user can also modulate the speed of playback. Negative values here result in reverse direction playback. Recorded material can also be played back via a MIDI keyboard. MIDI pitch and velocity are interpretted appropriately.</label>
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
  <y>266</y>
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
  <y>249</y>
  <width>500</width>
  <height>27</height>
  <uuid>{304e78d8-b320-453a-b28f-86b0ca872b86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Speed</objectName>
  <x>448</x>
  <y>266</y>
  <width>60</width>
  <height>30</height>
  <uuid>{94c7e961-7981-4d21-942f-80bcc647daf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
  <y>305</y>
  <width>100</width>
  <height>30</height>
  <uuid>{0609a258-bba4-43bb-849c-b8709a47f1ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Gain</label>
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
  <objectName>Gain</objectName>
  <x>8</x>
  <y>288</y>
  <width>500</width>
  <height>27</height>
  <uuid>{49415594-5e61-46ce-b9f8-3adcf2b957c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.70000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gain</objectName>
  <x>448</x>
  <y>305</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6a4ff02e-3d5e-4143-855e-95b4c2614157}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Meter</objectName>
  <x>8</x>
  <y>129</y>
  <width>500</width>
  <height>16</height>
  <uuid>{268666a1-c814-494e-af5c-fe2a391dee5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>5000.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>144</y>
  <width>80</width>
  <height>30</height>
  <uuid>{f04b1289-6b5e-4fe4-9d72-b77fcf39045b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Meter</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>177</y>
  <width>100</width>
  <height>30</height>
  <uuid>{feb05e56-b1b1-4494-8c71-ce9e40994fb9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On Threshold</label>
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
  <objectName>On_Threshold</objectName>
  <x>8</x>
  <y>160</y>
  <width>500</width>
  <height>27</height>
  <uuid>{88f53f0d-44d4-4847-8885-c15e934a8109}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>3910.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>On_Threshold</objectName>
  <x>448</x>
  <y>177</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dd0574f3-9876-4c0e-b747-f61dee837c94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3910.000</label>
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
  <y>216</y>
  <width>100</width>
  <height>30</height>
  <uuid>{bf3e8a57-4a8a-4a9d-b67d-9521542ae93d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Off Threshold</label>
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
  <objectName>Off_Threshold</objectName>
  <x>8</x>
  <y>199</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8ff8f945-02c5-4ac9-a2e7-f20a8a28a2a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>2410.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Off_Threshold</objectName>
  <x>448</x>
  <y>216</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4b684f89-629e-4f7a-974d-7dd7165f85a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2410.000</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Record_Led</objectName>
  <x>9</x>
  <y>63</y>
  <width>120</width>
  <height>22</height>
  <uuid>{176ac5c2-764e-4f67-a38d-a62f6bf6007b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
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
  <x>202</x>
  <y>50</y>
  <width>10</width>
  <height>10</height>
  <uuid>{0a052ce7-7ffd-491c-8eef-a839264c578a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PlayOnce_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
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
  <x>13</x>
  <y>41</y>
  <width>10</width>
  <height>10</height>
  <uuid>{7cb52cfd-3962-4238-906f-dcfd23cf02d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>RecReady_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
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
  <x>202</x>
  <y>87</y>
  <width>10</width>
  <height>10</height>
  <uuid>{7cc8023e-7a6a-4896-a4ef-f90c90ede07f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>LoopPlay_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>19</x>
  <y>64</y>
  <width>100</width>
  <height>22</height>
  <uuid>{2158640e-3fbe-4baa-89d4-444bcea8e421}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>RECORDING</label>
  <alignment>center</alignment>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

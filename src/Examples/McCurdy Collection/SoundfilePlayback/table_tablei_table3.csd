;Written by Iain McCurdy, 2006

;Modified for QuteCsound by René, April 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817


;Notes on modifications from original csd:
;	Add Browser for audio file


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 10		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;SLIDERS
		gkporttime	invalue	"Portamento"
		gkloopbegin	invalue	"LoopBegin"
		gkloopend		invalue	"LoopEnd"
		gkspeed		invalue	"Speed"
		gkgain		invalue	"Gain"
		;MENUS
		gkloopfn		invalue	"Loop"
		gktabletype	invalue	"TableType"
	endif
endin

instr	1
	Sfile_new		strcpy	""												;INIT TO EMPTY STRING
	Sfile		invalue	"_Browse"
	Sfile_old		strcpyk	Sfile_new
	Sfile_new		strcpyk	Sfile
	kfile 		strcmpk	Sfile_new, Sfile_old

	kSwitch		changed	gkloopfn, kfile									;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then														;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	UPDATE													;BEGIN A REINITIALISATION PASS FROM LABEL 'UPDATE'
	endif

	UPDATE:
	kporttime		linseg	0, .001, 1, 1, 1									;CREATE A RAMPING UP VARIBLE FOR PORTAMENTO TIME
	kporttime		=		kporttime * gkporttime								;MULTIPLY RAMPING UP VARIABLE FROM THE PREVIOUS LINE BY THE OUTPUT FROM THE 'PORTAMENTO TIME' SLIDER
	kloopbegin	lineto	gkloopbegin, kporttime								;APPLY PORTAMENTO TO THE NAMED VARIABLE
	kloopend		lineto	gkloopend, kporttime								;APPLY PORTAMENTO TO THE NAMED VARIABLE

	;tablei with phasor accept only (power of 2 + 1) table size
	ifnTemp	ftgentmp	0, 0, 0, 1, Sfile, 0, 0, 1								;Temporary table to get the audio file size
	iftlen	=		ftlen(ifnTemp)											;file size
	iftlen	pow		2, ceil(log(iftlen)/log(2))								;high nearest power of two table size

	ifn		ftgentmp	0, 0, 1+iftlen, 1, Sfile,0,0,1							;READ MONO OR STEREO AUDIO FILE CHANNEL 1

	ifilelen		=		nsamp(ifn)/sr										; LENGTH OF THE SAMPLE IN SECONDS
	kloopbegin	=		kloopbegin * ifilelen								;RESCALE gkloopbegin (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH. THIS ALLOW THE EASY INTERCHANGE OF SOUND FILES. NEW OUTPUT VARIABLE kloopbegin.
	kloopend		=		kloopend * ifilelen									;RESCALE gkloopend (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH. THIS ALLOW THE EASY INTERCHANGE OF SOUND FILES. NEW OUTPUT VARIABLE kloopend.
	klooplen		=		kloopend - kloopbegin								;DERIVE LOOP LENGTH FROM LOOP START AND END POINTS
	
	;					NUMERATOR|DENOMINATOR|SUBSTUTION_VALUE_(IF_DENOMINATOR=0)
	kphasFrq		divz		gkspeed,   klooplen,     .00001						; THE DIVZ OPCODE IS USED HERE TO PREVENT DIVISIONS BY ZERO (DIVISION BY ZERO MEANS CRASH!)
																		; IN SITUATIONS WHERE klooplen=0 (I.E. WHEN kloopend=kloopbegin)
																		; IN NORMAL OPERATION kphasFrq=gkspeed/klooplen
																		; BUT IF klooplen=0 THEN kphasFrq IS GIVEN THE VALUE SUBSITUTION VALUE .00001
					
	kptr			phasor	kphasFrq											; POINTER IS CREATED WITH FREQUENCY kphasFrq
	
	iloopfn		=		i(gkloopfn)+101									;FUNCTION TABLE THAT DEFINES THE LOOP POINTER MOVEMENT: 'FORWARD' OR 'FORWARD-BACKWARD'
	kphasFrq 		=		(iloopfn = 102 ? kphasFrq*.5 : kphasFrq)				;IF LOOP POINTER MOVEMENT IS 'FORWARD-BACKWARD' THEN POINTER FREQUENCY SHOULD BE HALVED
	
	;OUTPUT		OPCODE	AMPLITUDE | FREQUENCY | FUNCTION_TABLE
	kptr			oscili	1,           kphasFrq,     iloopfn						;CREATE POINTER MOVEMENT
	
	kinskip		=		(kloopbegin < kloopend ? kloopbegin : kloopend)			;A NEW VARIABLE IS CREATED THAT IS DEPENDENT UPON A CONDITIONAL STATEMENT
																		;IF kloopbegin < kloopend THEN kinskip=kloopbegin
																		;OTHERWISE kinskip=kloopend
																		;IN OTHER WORDS iinskip IS ALWAYS EQUAL TO WHICHEVER IS LESS BETWEEN iloopbegin AND iloopend.
																		;THE REASON FOR USING THIS CONDITIONAL IS TO CREATE A TRUE VALUE FOR THE 'NEAREST' LOOP POINT IN THE LOOP
																		;THE VARIABLE CREATED, iinskip, IS NEEDED IN THE NEXT LINE
	
	kptr			=		(kptr*abs(klooplen)) + kinskip						;kptr IS RESCALED TO MATCH THE LENGTH OF THE LOOP DEFINED BY iloopbegin AND iloopend 
																		;AND IS ALSO RESCALED TO COMPESATE FOR ANY 'inskip' INTO THE SOUNDFILE	
	
	aptr			interp	kptr												;a-rate VERSION OF kptr IS CREATED
	if		gktabletype==0	then												;THE NEXT LINE OF CODE CONDITIONALLY EXECUTED IF gktabletype==0 (GUI menu)
		asig		table	aptr*sr, ifn										;READ GEN01 FUNCTION TABLE USING table OPCODE
	elseif	gktabletype==1	then												;THE NEXT LINE OF CODE CONDITIONALLY EXECUTED IF gktabletype==1 (GUI menu)
		asig		tablei	aptr*sr, ifn										;READ GEN01 FUNCTION TABLE USING tablei OPCODE
	elseif	gktabletype==2	then												;THE NEXT LINE OF CODE CONDITIONALLY EXECUTED IF gktabletype==2 (GUI menu)
		asig		table3	aptr*sr, ifn										;READ GEN01 FUNCTION TABLE USING tabl3 OPCODE
	endif
				rireturn													;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
				outs		asig * gkgain, asig * gkgain
endin

instr	11	;INIT
		outvalue	"LoopBegin"	, 0.0
		outvalue	"LoopEnd"		, 1.0
		outvalue	"Speed"		, 1.0
		outvalue	"Loop"		, 0 
		outvalue	"Gain"		, 0.7
		outvalue	"Portamento"	, 0.0
endin
</CsInstruments>
<CsScore>
f 101	    0      129          -7       0 129 1	;STRAIGHT LINE - USED FOR POINTER NORMAL LOOPING
f 102	    0      129          -7       0 65 1 65 0	;TRIANGLE SHAPE - USED FOR POINTER FORWARD-BACKWARD LOOPING

i 10 0 3600	;GUI
i 11 0 0.01	;INIT
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
  <height>460</height>
  <uuid>{395a9956-93f5-441f-b0ef-3828f1b2da1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>table, tablei, table3</label>
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
  <objectName/>
  <x>8</x>
  <y>10</y>
  <width>100</width>
  <height>26</height>
  <uuid>{0a44e1b8-fab4-40c8-8fa1-f1d1d743c45c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    On / Off  </text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>518</x>
  <y>2</y>
  <width>420</width>
  <height>460</height>
  <uuid>{10e7ae72-c151-4c9d-9f49-e6b1585d8386}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>table, tablei, table3 - loop player</label>
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
  <x>521</x>
  <y>19</y>
  <width>414</width>
  <height>436</height>
  <uuid>{97dfe67c-26c1-4af5-b858-e301d6886c2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------------
The example demonstrates the use of the table family of opcodes to playback a sample stored in a GEN01 function table. It also demonstrates how to create a loop player that functions slightly differently to the flooper and flooper2 opcodes. Using table/tablei/table3 to play back audio data is initially slightly more awkward than using, for example, diskin or loscil, as we need to create a moving pointer ourselves which will used to read data from the function table but ultimately it will prove a more flexible and interesting method. As a case in point, this sound file loop player could not be implemented with the same functionality using diskin, loscil or flooper. Table, tablei and table3 operate in essentially the same way, the difference being in how they interpolate between values read from the table. Table does not interpolate at all, tablei implements linear interpolation and table3 implements cubic interpolation. This example allows the user to switch between table, tablei and table3 and observe the differences in sound quality. This will be most noticable when transposing downwards. Table is computationally fastest but offers the lowest audio quality, and table3 is computationally slowest but offers the audio highest quality. Increasing the 'Portamento Time' slider from its default setting of zero applies damping to the rate of change of values output by 'Loop Begin Point' and 'Loop End Point'. The upshot of this function is that pitch warping effects will ensue when portamento time is greater than zero while adjusting the 'Loop Begin Point' and 'Loop End Point' sliders.</label>
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
  <y>115</y>
  <width>150</width>
  <height>30</height>
  <uuid>{feb05e56-b1b1-4494-8c71-ce9e40994fb9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop Begin Point</label>
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
  <objectName>LoopBegin</objectName>
  <x>8</x>
  <y>98</y>
  <width>500</width>
  <height>27</height>
  <uuid>{88f53f0d-44d4-4847-8885-c15e934a8109}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>LoopBegin</objectName>
  <x>448</x>
  <y>115</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dd0574f3-9876-4c0e-b747-f61dee837c94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
  <y>162</y>
  <width>150</width>
  <height>30</height>
  <uuid>{bf3e8a57-4a8a-4a9d-b67d-9521542ae93d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop End Point</label>
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
  <objectName>LoopEnd</objectName>
  <x>8</x>
  <y>145</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8ff8f945-02c5-4ac9-a2e7-f20a8a28a2a5}</uuid>
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
  <objectName>LoopEnd</objectName>
  <x>448</x>
  <y>162</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4b684f89-629e-4f7a-974d-7dd7165f85a7}</uuid>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>180</x>
  <y>371</y>
  <width>326</width>
  <height>28</height>
  <uuid>{15a8ec14-710f-43e6-be9e-f5dc8c8786cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>808loopMono.wav</label>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>68</y>
  <width>150</width>
  <height>30</height>
  <uuid>{e13ea2b5-66c3-4eae-9c6c-91d9e035400b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Portamento Time</label>
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
  <objectName>Portamento</objectName>
  <x>8</x>
  <y>51</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0460f13f-efd6-4403-bc20-c0d21302e628}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Portamento</objectName>
  <x>448</x>
  <y>68</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7d2a46b9-3d13-4fc4-8081-50dbb35f8ff4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
  <width>150</width>
  <height>30</height>
  <uuid>{a842add9-35e8-4567-92ab-8061be1c10f7}</uuid>
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
  <y>192</y>
  <width>500</width>
  <height>27</height>
  <uuid>{67d5f50b-6ff1-43e9-90bc-2a4968903ba7}</uuid>
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
  <y>209</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8caaf76d-57ae-4684-8b3a-76e073bfd7d0}</uuid>
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
  <y>350</y>
  <width>100</width>
  <height>30</height>
  <uuid>{8de3ea13-9050-4b9d-8b34-9fec61fe4e48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input :</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>371</y>
  <width>170</width>
  <height>30</height>
  <uuid>{8c630a69-dc58-46a0-a696-60bc59cec1d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>808loopMono.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>321</y>
  <width>100</width>
  <height>30</height>
  <uuid>{ed7ec62d-067d-496b-9d76-51fc0bbe0bee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
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
  <y>304</y>
  <width>500</width>
  <height>27</height>
  <uuid>{7204111b-1356-4951-96a9-0dd786b34c6b}</uuid>
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
  <objectName>Gain</objectName>
  <x>448</x>
  <y>321</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0f7069a0-4c67-4cd1-8c7f-a6dabdc90c23}</uuid>
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
  <x>348</x>
  <y>239</y>
  <width>100</width>
  <height>30</height>
  <uuid>{15137bc2-52c6-4983-82ea-a224c3576267}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Table Type :</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>TableType</objectName>
  <x>348</x>
  <y>258</y>
  <width>150</width>
  <height>30</height>
  <uuid>{e9e2c36c-6e52-43fb-9475-8791a4778423}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>table</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>tablei</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>table3</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>21</x>
  <y>239</y>
  <width>100</width>
  <height>30</height>
  <uuid>{fd7776d2-44a3-4a50-9845-38865d795343}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop :</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Loop</objectName>
  <x>21</x>
  <y>258</y>
  <width>160</width>
  <height>30</height>
  <uuid>{fb5cadd5-8ae2-48a2-beab-2093685702a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Normal_Looping</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Fwd_Bwd_Looping</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

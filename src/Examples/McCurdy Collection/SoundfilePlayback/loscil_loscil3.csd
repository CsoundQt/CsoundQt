;Written by Iain McCurdy, 2006

;Modified for QuteCsound by René, April 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817


;Notes on modifications from original csd:
;	Add Browser for audio file


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
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
		gkbeg1		invalue	"LoopBeg1"
		gkend1		invalue	"LoopEnd1"
		gkbeg2		invalue	"LoopBeg2"
		gkend2		invalue	"LoopEnd2"
		gkspeed		invalue	"Speed"
		gkrelease		invalue	"Release"
		gkgain		invalue	"Gain"
		;MENUS
		gkmode1		invalue	"SusLoop"
		gkmode2		invalue	"RelLoop"
		gklosciltype	invalue	"OscType"
	endif
endin

instr	1
	Sfile_new		strcpy	""																;INIT TO EMPTY STRING
	Sfile		invalue	"_Browse"
	Sfile_old		strcpyk	Sfile_new
	Sfile_new		strcpyk	Sfile
	kfile 		strcmpk	Sfile_new, Sfile_old

	kSwitch		changed	gkbeg1, gkend1, gkbeg2, gkend2, gkrelease, gkmode1, gkmode2, kfile			;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then																		;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	UPDATE																	;BEGIN A REINITIALISATION PASS FROM LABEL 'UPDATE'
	endif
	UPDATE:
	ifn			ftgentmp	0, 0, 0, 1, Sfile,0,0,1												;READ MONO OR STEREO AUDIO FILE CHANNEL 1
	ifilelen		=	nsamp(ifn)															;LENGTH OF THE SAMPLE IN SAMPLES
	ibeg1		=	ifilelen * i(gkbeg1)
	iend1		=	ifilelen * i(gkend1)
	ibeg2		=	ifilelen * i(gkbeg2)
	iend2		=	ifilelen * i(gkend2)
	
	aenv			linsegr	0, (.01), 1, i(gkrelease), 0
	
	asigloscil	loscil	aenv, gkspeed, ifn, 1, i(gkmode1), ibeg1, iend1, i(gkmode2), ibeg2, iend2		;READ GEN01 FUNCTION TABLE USING loscil OPCODE
	asigloscil3	loscil3	aenv, gkspeed, ifn, 1, i(gkmode1), ibeg1, iend1, i(gkmode2), ibeg2, iend2		;READ GEN01 FUNCTION TABLE USING loscil3 OPCODE
				rireturn																	;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES

	if		gklosciltype==0	then							;THE NEXT LINE OF CODE CONDITIONALLY EXECUTED IF gklosciltype==0 (GUI MENU)
		asig		=	asigloscil							;ASSIGN THE AUDIO SIGNAL asigloscil TO THE AUDIO VARIABLE asig
	elseif	gklosciltype==1	then							;THE NEXT LINE OF CODE CONDITIONALLY EXECUTED IF gklosciltype==1 (GUI MENU)
		asig		=	asigloscil3							;ASSIGN THE AUDIO SIGNAL asigloscil3 TO THE AUDIO VARIABLE asig
	endif
				outs	asig*gkgain, asig*gkgain
endin

instr	11	;INIT
		outvalue	"Speed"		, 1.0
		outvalue	"LoopBeg1"	, .37
		outvalue	"LoopEnd1"	, .42
		outvalue	"RelLoop"		, 2
		outvalue	"LoopBeg2"	, .5
		outvalue	"LoopEnd2"	, .55
		outvalue	"Release"		, 10.0
		outvalue	"Gain"		, 0.7
		outvalue	"OscType"		, 0
		outvalue	"RelLoop"		, 2
		outvalue	"SusLoop"		, 1
endin
</CsInstruments>
<CsScore>
i 10 0 3600	;GUI
i 11 0 0.01	;INIT
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>520</x>
 <y>256</y>
 <width>845</width>
 <height>506</height>
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
  <height>500</height>
  <uuid>{395a9956-93f5-441f-b0ef-3828f1b2da1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>loscil, loscil3 </label>
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
  <x>516</x>
  <y>2</y>
  <width>323</width>
  <height>500</height>
  <uuid>{10e7ae72-c151-4c9d-9f49-e6b1585d8386}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>loscil, loscil3 </label>
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
  <y>18</y>
  <width>320</width>
  <height>480</height>
  <uuid>{97dfe67c-26c1-4af5-b858-e301d6886c2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------
This example demonstrates the use of loscil/loscil3 to playback a sample stored in a GEN01 function table. When designing a sampler type orchestra based upon the architecture of traditional hardware samplers then loscil/loscil3 is the best opcode to choose for this task. Loscil/loscil3 is capable of reading base pitch and sustain and release looping information stored in the sound file itself or this information can be passed to the opcode using optional input arguments (as in this example). Loscil/loscil3 enters the first loop during the sustain portion of the note and enters the second loop during the release stage of the note. In order to implement a release stage an envelope with release mechanism (such as linsegr) must be used in the same instrument as the loscil/loscil3. The nature of the sustain and release loops is determined by the two 3-way mode switches. Details of these modes is given in the interface. Loscil3 operates in a similar fashion to loscil with the difference that it performs cubic interpolation between samples. This example allows the user to switch between loscil and loscil3 and here the difference in sound quality that they offer. Loscil3 is computationally slower but offers a higher quality of sound, particularly when a sound is transposed downwards.</label>
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
  <y>157</y>
  <width>150</width>
  <height>30</height>
  <uuid>{2c897206-0dbc-47b5-ba68-915d83839ab6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop Beginning 2 (i-rate)</label>
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
  <objectName>LoopBeg2</objectName>
  <x>8</x>
  <y>140</y>
  <width>500</width>
  <height>27</height>
  <uuid>{304e78d8-b320-453a-b28f-86b0ca872b86}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>LoopBeg2</objectName>
  <x>448</x>
  <y>157</y>
  <width>60</width>
  <height>30</height>
  <uuid>{94c7e961-7981-4d21-942f-80bcc647daf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
  <y>204</y>
  <width>150</width>
  <height>30</height>
  <uuid>{0609a258-bba4-43bb-849c-b8709a47f1ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop End 2 (i-rate)</label>
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
  <objectName>LoopEnd2</objectName>
  <x>8</x>
  <y>187</y>
  <width>500</width>
  <height>27</height>
  <uuid>{49415594-5e61-46ce-b9f8-3adcf2b957c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.55000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>LoopEnd2</objectName>
  <x>448</x>
  <y>204</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6a4ff02e-3d5e-4143-855e-95b4c2614157}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.550</label>
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
  <y>63</y>
  <width>150</width>
  <height>30</height>
  <uuid>{feb05e56-b1b1-4494-8c71-ce9e40994fb9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop Beginning 1 (i-rate)</label>
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
  <objectName>LoopBeg1</objectName>
  <x>8</x>
  <y>46</y>
  <width>500</width>
  <height>27</height>
  <uuid>{88f53f0d-44d4-4847-8885-c15e934a8109}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.37000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>LoopBeg1</objectName>
  <x>448</x>
  <y>63</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dd0574f3-9876-4c0e-b747-f61dee837c94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.370</label>
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
  <y>110</y>
  <width>150</width>
  <height>30</height>
  <uuid>{bf3e8a57-4a8a-4a9d-b67d-9521542ae93d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop End 1 (i-rate)</label>
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
  <objectName>LoopEnd1</objectName>
  <x>8</x>
  <y>93</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8ff8f945-02c5-4ac9-a2e7-f20a8a28a2a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.41999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>LoopEnd1</objectName>
  <x>448</x>
  <y>110</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4b684f89-629e-4f7a-974d-7dd7165f85a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.420</label>
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
  <y>459</y>
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
  <y>298</y>
  <width>100</width>
  <height>30</height>
  <uuid>{e13ea2b5-66c3-4eae-9c6c-91d9e035400b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release Time</label>
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
  <objectName>Release</objectName>
  <x>8</x>
  <y>281</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0460f13f-efd6-4403-bc20-c0d21302e628}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>15.00000000</maximum>
  <value>10.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Release</objectName>
  <x>448</x>
  <y>298</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7d2a46b9-3d13-4fc4-8081-50dbb35f8ff4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10.000</label>
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
  <y>251</y>
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
  <y>234</y>
  <width>500</width>
  <height>27</height>
  <uuid>{67d5f50b-6ff1-43e9-90bc-2a4968903ba7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
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
  <y>251</y>
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
  <y>438</y>
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
  <y>459</y>
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
  <y>409</y>
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
  <y>392</y>
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
  <y>409</y>
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
  <x>180</x>
  <y>327</y>
  <width>100</width>
  <height>30</height>
  <uuid>{b57be1dd-771a-4401-af3f-c41b69f33392}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release Loop :</label>
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
  <objectName>RelLoop</objectName>
  <x>180</x>
  <y>346</y>
  <width>150</width>
  <height>30</height>
  <uuid>{5f758ab2-3d96-4ae6-b147-e6fa03240962}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>No Looping</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Fwd Looping</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Fwd-Bwd Looping</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>343</x>
  <y>327</y>
  <width>100</width>
  <height>30</height>
  <uuid>{15137bc2-52c6-4983-82ea-a224c3576267}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Oscil Type :</label>
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
  <objectName>OscType</objectName>
  <x>343</x>
  <y>346</y>
  <width>150</width>
  <height>30</height>
  <uuid>{e9e2c36c-6e52-43fb-9475-8791a4778423}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>loscil</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>loscil3</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>16</x>
  <y>327</y>
  <width>100</width>
  <height>30</height>
  <uuid>{fd7776d2-44a3-4a50-9845-38865d795343}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sustain Loop :</label>
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
  <objectName>SusLoop</objectName>
  <x>16</x>
  <y>346</y>
  <width>150</width>
  <height>30</height>
  <uuid>{fb5cadd5-8ae2-48a2-beab-2093685702a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>No Looping</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Fwd Looping</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Fwd-Bwd Looping</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

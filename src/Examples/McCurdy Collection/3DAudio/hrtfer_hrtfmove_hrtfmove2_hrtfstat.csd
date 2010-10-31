; Written by Iain McCurdy, 2006
; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733


;This csd use the files HRTFcompact, hrtf-44100-left.dat and hrtf-44100-right.dat, use the macro PATH_HRTF to define the path of these files.

;Notes on modifications from original csd:
;	Add Browser for audio file
;	I don't know why sometime when i start instrument 2 (hrtfer) i have a too high amplitude. (FLTK original is giving the same behaviour) ???

;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 64		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH

#define PATH_HRTF #/home/moi/Samples#

instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1) then
		gkOnOff		invalue	"On_Off"
		gkopcode		invalue	"Opcode"
		gkinput		invalue	"Input"
		gkAz			invalue	"Az"
		gkElev		invalue	"Elev"
		gkmode		invalue	"Mode"
		gkfade		invalue	"Fade"
		gkoverlap		invalue	"Overlap"
		gkoverlap		= int(gkoverlap)
					outvalue	"Overlap_value", gkoverlap
		gkradius		invalue	"Radius"
		gkradius_stat	invalue	"Radius_stat"
	endif
endin

instr	1	;CONTROL INSTRUMENT
	if	gkinput=0	then											;IF INPUT SELECTOR IS ON 'Bounce.wav'...
		Sfile		invalue	"_Browse1"		
		gasrc, asigR	diskin2	Sfile, 1,0,1						;READ AUDIO FILE FROM DISK (RIGHT CHANNEL WILL BE IGNORED)
	elseif	gkinput=1	then										;OR IF INPUT SELECTER IS ON 'LIVE INPUT'
		gasrc	inch	1										;READ LIVE AUDIO FROM THE COMPUTER'S FIRST (LEFT) AUDIO INPUT
	endif													;END OF CONDITIONAL BRANCHING
	if	gkopcode=0	then										;IF OPCODE SELECTER IS ON 'hrtfer'...
		;SCHEDKWHEN KTRIGGER, KMINTIM, KMAXNUM, KINSNUM, KWHEN, KDUR 
		schedkwhen     1,        0,       1,       2,       0,  -1 		;START INSTRUMENT 2 (hrtfer)
	endif													;END OF CONDITIONAL BRANCHING
	if	gkopcode=1	then										;IF OPCODE SELECTER IS ON 'hrtfmove'...
		;SCHEDKWHEN KTRIGGER, KMINTIM, KMAXNUM, KINSNUM, KWHEN, KDUR                                         
		schedkwhen     1,        0,       1,       3,       0,  -1		;START INSTRUMENT 3 (hrtfmove)         
	endif                                                          		;END OF CONDITIONAL BRANCHING        
	if	gkopcode=2	then										;IF OPCODE SELECTER IS ON 'hrtfmove2'...
		;SCHEDKWHEN KTRIGGER, KMINTIM, KMAXNUM, KINSNUM, KWHEN, KDUR                                         
		schedkwhen     1,        0,       1,       4,       0,  -1		;START INSTRUMENT 4 (hrtfmove2)         
	endif													;END OF CONDITIONAL BRANCHING        
	if	gkopcode=3	then										;IF OPCODE SELECTER IS ON 'hrtfstat'...
		;SCHEDKWHEN KTRIGGER, KMINTIM, KMAXNUM, KINSNUM, KWHEN, KDUR                                         
		schedkwhen     1,        0,       1,       5,       0, -1		;START INSTRUMENT 5 (hrtfstat)         
	endif													;END OF CONDITIONAL BRANCHING        
endin

instr	2	;hrtfer
	; SENSE GUI ON/OFF SWITCH
	if		gkOnOff=0	then										;IF ON/OFF SELECTER IS OFF
			turnoff											;TURN THIS INSTRUMENT OFF IMMEDIATELY
	endif													;END OF CONDITIONAL BRANCHING
	if		gkopcode!=0	then									;IF OPCODE SELECTER IS NOT ON 'hrtfer'... 
			turnoff											;TURN THIS INSTRUMENT OFF IMMEDIATELY
	endif													;END OF CONDITIONAL BRANCHING

	aleft, aright	hrtfer	gasrc, gkAz, gkElev, "$PATH_HRTF/HRTFcompact"	;APPLY hrtfer OPCODE TO AUDIO SOURCE FROM INSTR 1
				outs		aleft*100, aright*100						;SEND TO AUDIO OUTPUTS AND BOOST
endin

instr	3	;hrtfmove			
	if		gkOnOff=0	then          								;IF ON/OFF SELECTER IS OFF                    
			turnoff											;TURN THIS INSTRUMENT OFF IMMEDIATELY         
	endif													;END OF CONDITIONAL BRANCHING                 
	if		gkopcode!=1	then									;IF OPCODE SELECTER IS NOT ON 'hrtfmove'...
			turnoff											;TURN THIS INSTRUMENT OFF IMMEDIATELY         
	endif													;END OF CONDITIONAL BRANCHING                 
	ktrigger	changed	gkmode, gkfade								;IF gkmode OR gkfade CHANGE OUTPUT (ktrigger) A MOMENTARY 1 VALUE
	if	ktrigger=1	then										;IF ktrigger IS 1
			reinit	UPDATE									;BEGIN A RE-INITIALIZATION PASS FROM LABEL 'UPDATE'
	endif													;END OF CONDITIONAL BRANCHING
	UPDATE:													;LABEL 'UPDATE'
	aleft, aright	hrtfmove	gasrc, gkAz, gkElev, "$PATH_HRTF/hrtf-44100-left.dat","$PATH_HRTF/hrtf-44100-right.dat", i(gkmode), i(gkfade), sr		;APPLY hrtfmove OPCODE TO AUDIO SOURCE FROM INSTR 1
 				rireturn										;END OF RE-INITIALIZATION PASS - RETURN TO PERFORMANCE TIME
 				outs		aleft, aright							;SEND AUDIO TO OUTPUTS
endin

instr	4	;hrtfmove2
	if		gkOnOff=0	then										;IF ON/OFF SELECTER IS OFF                 
			turnoff											;TURN THIS INSTRUMENT OFF IMMEDIATELY      
	endif													;END OF CONDITIONAL BRANCHING              
	if		gkopcode!=2	then									;IF OPCODE SELECTER IS NOT ON 'hrtfmove2'...
			turnoff											;TURN THIS INSTRUMENT OFF IMMEDIATELY      
	endif													;END OF CONDITIONAL BRANCHING              

	ktrigger	changed	gkoverlap, gkradius							;IF gkmode OR gkfade CHANGE OUTPUT (ktrigger) A MOMENTARY 1 VALUE
	if	ktrigger=1	then										;IF ktrigger IS 1
			reinit	UPDATE									;BEGIN A RE-INITIALIZATION PASS FROM LABEL 'UPDATE'
	endif													;END OF CONDITIONAL BRANCHING
	UPDATE:													;LABEL 'UPDATE'
	aleft, aright	hrtfmove2	gasrc, gkAz, gkElev, "$PATH_HRTF/hrtf-44100-left.dat","$PATH_HRTF/hrtf-44100-right.dat", i(gkoverlap), i(gkradius), sr	;APPLY hrtfmove2 OPCODE TO AUDIO SOURCE FROM INSTR 1
 				rireturn
				outs		aleft, aright							;SEND AUDIO TO OUTPUTS
endin

instr	5	;hrtfstat
	if		gkOnOff=0	then										;IF ON/OFF SELECTER IS OFF                  
			turnoff											;TURN THIS INSTRUMENT OFF IMMEDIATELY       
	endif													;END OF CONDITIONAL BRANCHING               
	if		gkopcode!=3	then									;IF OPCODE SELECTER IS NOT ON 'hrtfstat'...
			turnoff											;TURN THIS INSTRUMENT OFF IMMEDIATELY      
	endif													;END OF CONDITIONAL BRANCHING              
	ktrigger	changed	gkAz, gkElev, gkradius_stat					;IF gkAz OR gkElev CHANGE OUTPUT (ktrigger) A MOMENTARY 1 VALUE
	if	ktrigger=1	then										;IF ktrigger=1, i.e. gkAz OR gkElev ARE CHANGED...
			reinit	UPDATE									;BEGIN A REINITIALIZATION PASS FROM LABEL 'UPDATE'
	endif													;END OF CONDITIONAL BRANCHING               
	UPDATE:													;BEGIN A RE-INITIALIZATION PASS FROM LABEL 'UPDATE'
	aleft, aright	hrtfstat	gasrc, i(gkAz), i(gkElev), "$PATH_HRTF/hrtf-44100-left.dat","$PATH_HRTF/hrtf-44100-right.dat", i(gkradius_stat), sr	;APPLY hrtfmove2 OPCODE TO AUDIO SOURCE FROM INSTR 1
				rireturn										;END OF RE-INITIALIZATION PASS - RETURN TO PERFORMANCE TIME
				outs		aleft, aright							;SEND AUDIO TO OUTPUTS
endin
</CsInstruments>
<CsScore>
i 10 0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>1</y>
 <width>1270</width>
 <height>740</height>
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
  <width>455</width>
  <height>390</height>
  <uuid>{9c04b1a4-d4b1-41e8-82d1-cebae3b4d95c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>hrtfer/hrtfmove/hrtfmove2/hrtfstat</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>On_Off</objectName>
  <x>15</x>
  <y>47</y>
  <width>110</width>
  <height>30</height>
  <uuid>{36fd663c-a4e5-447e-b28c-bc7858481b27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    On / Off</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Az</objectName>
  <x>356</x>
  <y>354</y>
  <width>50</width>
  <height>25</height>
  <uuid>{3595a6f9-0669-40d5-ba73-3c96bc3915ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>117.600</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Elev</objectName>
  <x>90</x>
  <y>252</y>
  <width>50</width>
  <height>25</height>
  <uuid>{a76e1ae7-0d83-490c-b569-025ad7e01ad1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-14.433</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>Az</objectName>
  <x>152</x>
  <y>47</y>
  <width>300</width>
  <height>300</height>
  <uuid>{9c6f10b1-e69e-4466-bca7-ad030a1590f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Elev</objectName2>
  <xMin>-360.00000000</xMin>
  <xMax>360.00000000</xMax>
  <yMin>-40.00000000</yMin>
  <yMax>90.00000000</yMax>
  <xValue>117.60000000</xValue>
  <yValue>-14.43333333</yValue>
  <type>crosshair</type>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>15</x>
  <y>117</y>
  <width>110</width>
  <height>30</height>
  <uuid>{8f2dc46a-0bca-49f3-a7ea-a3e275c5d7cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>File Input</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Live Input</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Opcode</objectName>
  <x>15</x>
  <y>82</y>
  <width>110</width>
  <height>30</height>
  <uuid>{6d89403a-f631-4bdb-a866-8cf25d5a44a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>hrtfer</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>hrtfmove</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>hrtfmove2</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>hrtfstat</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>457</x>
  <y>2</y>
  <width>345</width>
  <height>655</height>
  <uuid>{6d75ade4-31f2-430d-ad0a-c2e8c0bc52af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Instructions and Info</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>191</x>
  <y>354</y>
  <width>161</width>
  <height>29</height>
  <uuid>{b9711ab1-6a91-411b-8d64-e67285708e4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>X = Azimuth (Degrees)</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>54</x>
  <y>206</y>
  <width>87</width>
  <height>51</height>
  <uuid>{e151a192-2c90-49f4-9025-1292bf311020}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Y = Elevation
 (Degrees)</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>461</x>
  <y>31</y>
  <width>338</width>
  <height>538</height>
  <uuid>{6fe014be-11b0-4a2f-8dbd-652d7a5fb93d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------
This example demonstrates Csound's four opcodes for 3-d binaural spacialisation, these are the oldest hrtfer and the three newer opcodes, hftfmove, hrtfmove2 and hrtfstat. 
By presenting them in this fashion the user is able to easily compare them.
Each opcode requires a data file which basically contains information about how the human ears, head and body filter and delays frequencies before they reach each ear drum.
 The two crucial input parameters that each of these opcodes requires are elevation, basically vertical direction in degrees from which the sound emanates, and azimuth which 
determines from where on the horizontal plane the sound emanates from.                                               
To allow the user to explore dynamic gestures involving both of these parameters they are combined to be controlled from an X-Y panel.
Each of these opcodes expects a monophonic audio input and outputs binaural stereo audio meaning that the 3-d effect will really only work through stereo headphones.
The user can choose between either a sound file input (a bouncing ping-pong ball) or the computer's live audio input.
Azimuth and elevation are i-rate parameters in 'hrtfstat' therefore audio discontinuities are heard when modulating these parameters as the opcode is re-initialized.</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>392</y>
  <width>455</width>
  <height>90</height>
  <uuid>{77c9f998-bf7c-458a-b456-73af422d9736}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>hrtfmove</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>124</x>
  <y>400</y>
  <width>57</width>
  <height>27</height>
  <uuid>{b2eb2d6c-abbd-4f8f-aed6-ec62848e6346}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mode :</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Mode</objectName>
  <x>185</x>
  <y>398</y>
  <width>140</width>
  <height>30</height>
  <uuid>{8215b741-454f-4b1d-b74f-44fc4c76b045}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Phase truncation</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Minimum phase</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Fade</objectName>
  <x>17</x>
  <y>434</y>
  <width>415</width>
  <height>27</height>
  <uuid>{38ded017-9f4c-4909-a827-ce97ae4cca81}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>24.00000000</maximum>
  <value>8.98072289</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Fade</objectName>
  <x>382</x>
  <y>451</y>
  <width>50</width>
  <height>25</height>
  <uuid>{295f0427-4b8b-4716-86b7-dbd8411a73ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.981</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>17</x>
  <y>451</y>
  <width>100</width>
  <height>26</height>
  <uuid>{e63cb59e-c600-4b98-8683-14c03c1147eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fade</label>
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
  <x>2</x>
  <y>482</y>
  <width>455</width>
  <height>105</height>
  <uuid>{0dd758b1-23ff-4c52-9a2b-2965705aa11a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>hrtfmove2</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>587</y>
  <width>455</width>
  <height>70</height>
  <uuid>{eaa8967b-da38-4fed-a4bc-284627cb6644}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>hrtfstat</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>15</x>
  <y>524</y>
  <width>100</width>
  <height>27</height>
  <uuid>{ac3bfedb-36b5-4bf2-ab25-7202d2c50c06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Overlap</label>
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
  <objectName>Overlap_value</objectName>
  <x>382</x>
  <y>524</y>
  <width>50</width>
  <height>25</height>
  <uuid>{88fada12-78e5-4716-a734-d5baf77ebb75}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.000</label>
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
  <objectName>Overlap</objectName>
  <x>17</x>
  <y>507</y>
  <width>415</width>
  <height>27</height>
  <uuid>{9187d2f0-c826-4c32-92bd-219b357c8f64}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>24.00000000</maximum>
  <value>4.71325301</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>17</x>
  <y>560</y>
  <width>100</width>
  <height>27</height>
  <uuid>{903aad43-25fb-489e-9f11-d3d88c3b79a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Radius</label>
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
  <objectName>Radius</objectName>
  <x>382</x>
  <y>560</y>
  <width>50</width>
  <height>25</height>
  <uuid>{da7e387c-df6b-41ee-ab03-6951ea24f98e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>9.036</label>
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
  <objectName>Radius</objectName>
  <x>17</x>
  <y>543</y>
  <width>415</width>
  <height>27</height>
  <uuid>{79e3bb3a-1602-4755-90a5-8d109b0e5792}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>24.00000000</maximum>
  <value>9.03614458</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>17</x>
  <y>628</y>
  <width>100</width>
  <height>27</height>
  <uuid>{27e9db80-4ee2-495b-86e1-ec14f7d9bc91}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Radius</label>
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
  <objectName>Radius_stat</objectName>
  <x>382</x>
  <y>628</y>
  <width>50</width>
  <height>25</height>
  <uuid>{a6bffca6-42f1-4d02-98f7-11c8f2ca61a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>14.966</label>
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
  <objectName>Radius_stat</objectName>
  <x>17</x>
  <y>611</y>
  <width>415</width>
  <height>27</height>
  <uuid>{1ecd5f98-8744-4c32-93a1-8086e224e3ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>24.00000000</maximum>
  <value>14.96626506</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>479</x>
  <y>581</y>
  <width>170</width>
  <height>30</height>
  <uuid>{edb13338-bffc-43e2-977f-247fd2b834d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/moi/Samples/bounce.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>479</x>
  <y>615</y>
  <width>304</width>
  <height>32</height>
  <uuid>{a2231334-119c-4cc6-8bc0-1f54af7751a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/moi/Samples/bounce.wav</label>
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
   <r>247</r>
   <g>245</g>
   <b>242</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>287</x>
  <y>182</y>
  <width>30</width>
  <height>30</height>
  <uuid>{9507f946-7bd5-4bce-ae1a-33c0a7c9b8eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>14</borderradius>
  <borderwidth>1</borderwidth>
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
WindowBounds: 0 1 1270 740
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView background {61937, 58082, 47545}
ioText {2, 2} {455, 390} label 0.000000 0.00100 "" center "Arial Black" 18 {0, 0, 0} {62464, 63488, 51200} nobackground noborder hrtfer/hrtfmove/hrtfmove2/hrtfstat
ioButton {15, 47} {110, 30} event 1.000000 "On_Off" "    On / Off" "/" i 1 0 -1
ioText {356, 354} {50, 25} display 117.600000 0.00100 "Az" left "Arial" 9 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 117.600
ioText {90, 252} {50, 25} display -14.433333 0.00100 "Elev" left "Arial" 9 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -14.433
ioMeter {152, 47} {300, 300} {0, 59904, 0} "Az" 117.600000 "Elev" -14.433333 crosshair 1 0 mouse
ioMenu {15, 117} {110, 30} 0 303 "File Input,Live Input" Input
ioMenu {15, 82} {110, 30} 0 303 "hrtfer,hrtfmove,hrtfmove2,hrtfstat" Opcode
ioText {457, 2} {345, 655} label 0.000000 0.00100 "" center "Arial Black" 18 {0, 0, 0} {62464, 63488, 51200} nobackground noborder Instructions and Info
ioText {191, 354} {161, 29} label 0.000000 0.00100 "" right "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder X = Azimuth (Degrees)
ioText {54, 206} {87, 51} label 0.000000 0.00100 "" right "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Y = ElevationÂ¬ (Degrees)
ioText {461, 31} {338, 538} label 0.000000 0.00100 "" left "Arial" 14 {0, 0, 0} {63232, 62720, 61952} nobackground noborder -------------------------------------------------------------------------------------------------------------------Â¬This example demonstrates Csound's four opcodes for 3-d binaural spacialisation, these are the oldest hrtfer and the three newer opcodes, hftfmove, hrtfmove2 and hrtfstat. Â¬By presenting them in this fashion the user is able to easily compare them.Â¬Each opcode requires a data file which basically contains information about how the human ears, head and body filter and delays frequencies before they reach each ear drum.Â¬ The two crucial input parameters that each of these opcodes requires are elevation, basically vertical direction in degrees from which the sound emanates, and azimuth which Â¬determines from where on the horizontal plane the sound emanates from.                                               Â¬To allow the user to explore dynamic gestures involving both of these parameters they are combined to be controlled from an X-Y panel.Â¬Each of these opcodes expects a monophonic audio input and outputs binaural stereo audio meaning that the 3-d effect will really only work through stereo headphones.Â¬The user can choose between either a sound file input (a bouncing ping-pong ball) or the computer's live audio input.Â¬Azimuth and elevation are i-rate parameters in 'hrtfstat' therefore audio discontinuities are heard when modulating these parameters as the opcode is re-initialized.
ioText {2, 392} {455, 90} label 0.000000 0.00100 "" left "Arial Black" 18 {0, 0, 0} {62464, 63488, 51200} nobackground noborder hrtfmove
ioText {124, 400} {57, 27} label 0.000000 0.00100 "" right "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Mode :
ioMenu {185, 398} {140, 30} 1 303 "Phase truncation,Minimum phase" Mode
ioSlider {17, 434} {415, 27} 1.000000 24.000000 8.980723 Fade
ioText {382, 451} {50, 25} display 8.981000 0.00100 "Fade" right "Arial" 9 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 8.981
ioText {17, 451} {100, 26} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Fade
ioText {2, 482} {455, 105} label 0.000000 0.00100 "" left "Arial Black" 18 {0, 0, 0} {62464, 63488, 51200} nobackground noborder hrtfmove2
ioText {2, 587} {455, 70} label 0.000000 0.00100 "" left "Arial Black" 18 {0, 0, 0} {62464, 63488, 51200} nobackground noborder hrtfstat
ioText {15, 524} {100, 27} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Overlap
ioText {382, 524} {50, 25} display 4.000000 0.00100 "Overlap_value" right "Arial" 9 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 4.000
ioSlider {17, 507} {415, 27} 1.000000 24.000000 4.713253 Overlap
ioText {17, 560} {100, 27} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Radius
ioText {382, 560} {50, 25} display 9.036000 0.00100 "Radius" right "Arial" 9 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 9.036
ioSlider {17, 543} {415, 27} 1.000000 24.000000 9.036145 Radius
ioText {17, 628} {100, 27} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Radius
ioText {382, 628} {50, 25} display 14.966000 0.00100 "Radius_stat" right "Arial" 9 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 14.966
ioSlider {17, 611} {415, 27} 1.000000 24.000000 14.966265 Radius_stat
ioButton {479, 581} {170, 30} value 1.000000 "_Browse1" "Browse Audio File" "/" 
ioText {479, 615} {304, 32} edit 0.000000 0.00100 "_Browse1"  "Arial" 10 {0, 0, 0} {61440, 60160, 57856} falsenoborder /home/moi/Samples/bounce.wav
ioText {286, 178} {30, 30} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
</MacGUI>

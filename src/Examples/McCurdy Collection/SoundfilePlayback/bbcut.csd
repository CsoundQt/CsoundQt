;Written by Iain McCurdy, 2006

;Modified for QuteCsound by René, April 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817


;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio file


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 64	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1

giExp1	ftgen	0, 0, 129, -25, 0, 50.0, 128, 10000.0	;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;COUNTERS
		gksubdiv		invalue	"SubDiv"
		gkbarlen		invalue	"BarLength"
		gkphrase		invalue	"Phrase"
		gkrepeats		invalue	"Repeats"
		gkstutspd		invalue	"StutSpeed"
		gkstutchnc	invalue	"StutChance"
		gkBPM		invalue	"BPM"
		gkfltdiv		invalue	"FilDiv"
		;SLIDERS
		gkDry		invalue	"DryGain"
		gkWet		invalue	"WetGain"
		gkFltMix		invalue	"FiltMix"
		gkbw			invalue	"Bandwidth"
		kcfmin		invalue	"FreqMin"
		gkcfmin		tablei	kcfmin, giExp1, 1
					outvalue	"FreqMin_Value", gkcfmin	
		kcfmax		invalue	"FreqMax"
		gkcfmax		tablei	kcfmax, giExp1, 1
					outvalue	"FreqMax_Value", gkcfmax			
		gki_h		invalue	"Interp_SH"
		;MENU
		gkinput		invalue	"Input"
	endif
endin

instr	1
	Sfile_new		strcpy	""											;INIT TO EMPTY STRING
	Sfile		invalue	"_Browse"
	Sfile_old		strcpyk	Sfile_new
	Sfile_new		strcpyk	Sfile
	kfile 		strcmpk	Sfile_new, Sfile_old

	inumbar	=	2													;NUMBER OF BARS IN THE INPUT SOUND FILE
	kBarPS	=	gkBPM/240												;DERIVE BARS PER SECOND
	
	kSwitch	changed	gkBPM, gkrepeats, gkphrase, gkstutspd, gkstutchnc, gkbarlen, gksubdiv, gkinput, gkfltdiv, kfile		;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then													;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	UPDATE												;BEGIN A REINITIALISATION PASS FROM LABEL 'UPDATE'
	endif

	UPDATE:
	if	gkinput==0 then												;IF 'INPUT' SWITCH IS SET TO 'STORED FILE' THEN IMPLEMENT THE NEXT LINE OF CODE
		;tablei with phasor accept only (power of 2 + 1) table size
		ifnTemp	ftgentmp	0, 0, 0, 1, Sfile, 0, 0, 1						;Temporary table to get the audio file size
		iftlen	=		ftlen(ifnTemp)									;file size
		iftlen	pow		2, ceil(log(iftlen)/log(2))						;high nearest power of two table size

		ifn		ftgentmp	0, 0, 1+iftlen, 1, Sfile,0,0,1					;READ MONO OR STEREO AUDIO FILE CHANNEL 1

		aptr		phasor	kBarPS/inumbar									;CREATE A MOVING PHASE VALUE
		ain		tablei	aptr*nsamp(ifn), ifn							;READ AUDIO FROM TABLE
	else																;IF 'INPUT' SWITCH IS NOT SET TO 'STORED FILE' THEN IMPLEMENT THE NEXT LINE OF CODE
		ain, aignore	ins												;READ AUDIO FROM THE COMPUTER'S LIVE INPUT (LEFT INPUT ONLY IS READ, RIGHT CHANNEL IS IGNORED IN SUBSEQUENT CODE. A STEREO VERSION COULD EASILY BE BUILT BUT THIS WOULD DOUBLE CPU DEMANDS!)
	endif															;END OF 'IF'...'THEN' BRANCHING
	
	;OUTPUT		OPCODE	INPUT |   BPM      | SUBDIVISION | BAR_LENGTH | PHRASE_LENGTH | NUM.OF_REPEATS | STUTTER_SPEED | STUTTER_CHANCE	
	abbcutL		bbcutm	ain,   i(gkBPM)/60, i(gksubdiv),  i(gkbarlen),   i(gkphrase),    i(gkrepeats),   i(gkstutspd),   i(gkstutchnc)
	abbcutR		bbcutm	ain,   i(gkBPM)/60, i(gksubdiv),  i(gkbarlen),   i(gkphrase),    i(gkrepeats),   i(gkstutspd),   i(gkstutchnc)
	;bbcutm IS THE MONO VERSION OF THE BREAK BEAT CUTTER

	;FILTER=================================================================================================================================================================
	kfreq	=		(kBarPS*gkfltdiv)/inumbar		;FREQUENCY WITH WHICH NEW FILTER CUTOFF VALUES ARE GENERATED			;LEFT CHANNEL
			rireturn								;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES

	kcf1h	randomh	gkcfmin, gkcfmax, kfreq			;SAMPLE AND HOLD RANDOM FREQUENCY VALUES							;LEFT CHANNEL
	kcf1i	lineto	kcf1h, 1/kfreq					;INTERPOLATE VALUES												;LEFT CHANNEL
	kcf1		ntrpol	kcf1i, kcf1h, gki_h   			;CROSSFADE BETWEEN INTERPOLATING AND SAMPLE AND HOLD TYPE RANDOM VALUES	;LEFT CHANNEL
	abbFltL	reson	abbcutL, kcf1, kcf1*gkbw, 2		;BAND-PASS FILTER												;LEFT CHANNEL
	abbMixL	ntrpol	abbcutL, abbFltL, gkFltMix		;CROSSFADE BETWEEN UNFILTERED AND FILTER AUDIO SIGNAL					;LEFT CHANNEL
	kcf2h	randomh	gkcfmin, gkcfmax, kfreq			;SAMPLE AND HOLD RANDOM FREQUENCY VALUES							;RIGHT CHANNEL
	kcf2i	lineto	kcf2h, 1/kfreq					;INTERPOLATE VALUES												;RIGHT CHANNEL
	kcf2		ntrpol	kcf2i, kcf2h, gki_h   			;CROSSFADE BETWEEN INTERPOLATING AND SAMPLE AND HOLD TYPE RANDOM VALUES	;RIGHT CHANNEL
	abbFltR	reson	abbcutR, kcf2, kcf2*gkbw, 2		;BAND-PASS FILTER												;RIGHT CHANNEL
	abbMixR	ntrpol	abbcutR, abbFltR, gkFltMix		;CROSSFADE BETWEEN UNFILTERED AND FILTER AUDIO SIGNAL					;RIGHT CHANNEL
	;=======================================================================================================================================================================
	
	amixL	sum		ain*gkDry, abbMixL*gkWet			;SUM AND MIX DRY SIGNAL AND BBCUT SIGNAL (LEFT CHANNEL)
	amixR	sum		ain*gkDry, abbMixR*gkWet			;SUM AND MIX DRY SIGNAL AND BBCUT SIGNAL (RIGHT CHANNEL)
			outs		amixL, amixR					;SEND AUDIO TO OUTPUTS
endin

instr	11	;INIT
		outvalue	"SubDiv"		, 8
		outvalue	"BarLength"	, 2
		outvalue	"Phrase"		, 8
		outvalue	"Repeats"		, 2
		outvalue	"StutSpeed"	, 4
		outvalue	"StutChance"	, 1
		outvalue	"BPM"		, 110
		outvalue	"FilDiv"		, 1
		outvalue	"Input"		, 0

		outvalue	"DryGain"		, 0.5
		outvalue	"WetGain"		, 0.5
		outvalue	"FiltMix"		, 0.9
		outvalue	"Bandwidth"	, 0.3
		outvalue	"Interp_SH"	, 1.0

		outvalue	"FreqMin"		, 0.3925
		outvalue	"FreqMax"		, 0.8694
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
 <x>259</x>
 <y>220</y>
 <width>1106</width>
 <height>542</height>
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
  <height>540</height>
  <uuid>{395a9956-93f5-441f-b0ef-3828f1b2da1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>bbcutm / bbcuts </label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    On / Off  </text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>2</y>
  <width>590</width>
  <height>540</height>
  <uuid>{10e7ae72-c151-4c9d-9f49-e6b1585d8386}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>bbcutm / bbcuts </label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <y>20</y>
  <width>585</width>
  <height>517</height>
  <uuid>{97dfe67c-26c1-4af5-b858-e301d6886c2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>------------------------------------------------------------------------------------------------------------------------------------------------
bbcutm/bbcuts performs break-beat style cut-ups upon an input audio signal. (bbcutm/bbcuts represents mono and stereo versions of the same basic algorithm.) In order to create rhythmically precise cut-ups it is necessary for the input audio loop to begin at the same time that the opcode is triggered and for the tempo argument given to the bbcuts/bbcutm opcode to correspond to that of the input loop audio. This requires some planning and in this example this is implemented by playing the audio loop using the tablei opcode.
Of course there is no reason why bbcutm/bbcutm cannot be applied to unmetered sound material or even a live input signal. This example also provides the option of selecting the computer's live input as the sound source. If the live input is used then the results can be more aleatoric than rhymical. Bbcuts/bbcutm takes a variety of input arguments that determine the precise nature of the cut-ups executed. 'Sub-division' determines the note duration used as the base unit in  cut-ups. For example a value of 8 represents quavers (eighth notes), 16 represents semiquavers (sixteenth notes) and so on. 'Bar Length' represents the number of beats per bar. For example, a value of 4 represents a 4/4 bar and so on. 'Phrase' defines the number of bars that will elapse before the cutting up pattern restarts from the beginning. 'Stutter' is a separate cut-up process which occasionally will take a very short fragment of the input audio and repeat it many times. 'Stutter Speed' defines the duration of each stutter in relation to 'Sub-division'. If subdivision is 8 (quavers / eighth notes) and 'Stutter Speed' is 2 then each stutter will be a semiquaver / sixteenth note. 'Stutter Chance' defines the frequency of stutter moments. The range for this parameter is 0 to 1. Zero means stuttering will be very unlikely, 1 means it will be very likely. 'Repeats' defines the number of repeats that will be employed in normal cut-up events. When processing non-rhythmical, unmetered material it may be be more interesting to employ non-whole numbers for parameters such as 'Sub-division', 'Phrase' and 'Stutter Speed'. Additionally in this example a randomly moving band-pass filter has been implemented. 'Filter Mix' crossfades between the unfiltered bbcut signal and the filtered bbcut signal. 'Cutoff Freq.' consists of two small sliders which determine the range from which random cutoff values are derived. 'Interpolate&lt;=>S&amp;H' fades continuously between an interpolated random function and a sample and hold type random function. 'Filter Div.' controls the frequency subdivision with which new random cutoff frequency values are generated - a value of '1' means that new values are generated once every bar.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>301</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2c897206-0dbc-47b5-ba68-915d83839ab6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Filter Mix</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>FiltMix</objectName>
  <x>8</x>
  <y>284</y>
  <width>500</width>
  <height>27</height>
  <uuid>{304e78d8-b320-453a-b28f-86b0ca872b86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.89999998</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FiltMix</objectName>
  <x>448</x>
  <y>301</y>
  <width>60</width>
  <height>30</height>
  <uuid>{94c7e961-7981-4d21-942f-80bcc647daf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.900</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>340</y>
  <width>100</width>
  <height>30</height>
  <uuid>{0609a258-bba4-43bb-849c-b8709a47f1ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Bandwidth</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Bandwidth</objectName>
  <x>8</x>
  <y>323</y>
  <width>500</width>
  <height>27</height>
  <uuid>{49415594-5e61-46ce-b9f8-3adcf2b957c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.01000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.30000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Bandwidth</objectName>
  <x>448</x>
  <y>340</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6a4ff02e-3d5e-4143-855e-95b4c2614157}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.300</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>3</x>
  <y>59</y>
  <width>80</width>
  <height>30</height>
  <uuid>{f04b1289-6b5e-4fe4-9d72-b77fcf39045b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Sub-division</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>212</y>
  <width>100</width>
  <height>30</height>
  <uuid>{feb05e56-b1b1-4494-8c71-ce9e40994fb9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Dry Signal Gain</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>DryGain</objectName>
  <x>8</x>
  <y>195</y>
  <width>500</width>
  <height>27</height>
  <uuid>{88f53f0d-44d4-4847-8885-c15e934a8109}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>DryGain</objectName>
  <x>448</x>
  <y>212</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dd0574f3-9876-4c0e-b747-f61dee837c94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.500</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>251</y>
  <width>100</width>
  <height>30</height>
  <uuid>{bf3e8a57-4a8a-4a9d-b67d-9521542ae93d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>BBCut Signal Gain</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>WetGain</objectName>
  <x>8</x>
  <y>234</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8ff8f945-02c5-4ac9-a2e7-f20a8a28a2a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>WetGain</objectName>
  <x>448</x>
  <y>251</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4b684f89-629e-4f7a-974d-7dd7165f85a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.500</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>201</x>
  <y>455</y>
  <width>120</width>
  <height>30</height>
  <uuid>{9b81a1f2-bcb8-4582-925b-9ae56def3865}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Audio File</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Live Input</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>119</x>
  <y>455</y>
  <width>80</width>
  <height>30</height>
  <uuid>{62eeb695-9b83-42da-81cd-8000c232d9b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Input</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>492</y>
  <width>170</width>
  <height>30</height>
  <uuid>{9b992da1-8c0f-449e-af03-7913cc05efed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>loop.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>180</x>
  <y>493</y>
  <width>330</width>
  <height>28</height>
  <uuid>{15a8ec14-710f-43e6-be9e-f5dc8c8786cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>loop.wav</label>
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
   <r>239</r>
   <g>239</g>
   <b>239</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>SubDiv</objectName>
  <x>83</x>
  <y>56</y>
  <width>80</width>
  <height>30</height>
  <uuid>{3d5124e6-f1d8-45bc-9ae5-b4a673b7405d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <maximum>512</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>171</x>
  <y>59</y>
  <width>80</width>
  <height>30</height>
  <uuid>{8fa295f7-11c7-4b5b-a76a-259146baba51}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Bar Length</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>BarLength</objectName>
  <x>251</x>
  <y>56</y>
  <width>80</width>
  <height>30</height>
  <uuid>{4ac46d80-30ce-46e7-8622-b7089ba53aa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <resolution>0.25000000</resolution>
  <minimum>1</minimum>
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>332</x>
  <y>59</y>
  <width>80</width>
  <height>30</height>
  <uuid>{98c8e98a-297e-46da-9386-86e4d28975c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Phrase</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Phrase</objectName>
  <x>412</x>
  <y>56</y>
  <width>80</width>
  <height>30</height>
  <uuid>{8fb134dd-c928-45d3-a404-9f270e7ae731}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <resolution>0.25000000</resolution>
  <minimum>0.25</minimum>
  <maximum>512</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>3</x>
  <y>107</y>
  <width>80</width>
  <height>30</height>
  <uuid>{319d8b03-efdd-4a6a-941b-0b812e8c237c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Repeats</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Repeats</objectName>
  <x>83</x>
  <y>102</y>
  <width>80</width>
  <height>30</height>
  <uuid>{6c9d1845-606e-471d-bc37-e4cbd4d4d3b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <maximum>32</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>171</x>
  <y>103</y>
  <width>80</width>
  <height>30</height>
  <uuid>{9aae19ac-fc6c-4a8f-b4cb-320f616b698b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Stutter Speed</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>StutSpeed</objectName>
  <x>251</x>
  <y>99</y>
  <width>80</width>
  <height>30</height>
  <uuid>{81edbd00-9029-4f2e-954d-0e7ef55d7ca3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <resolution>0.25000000</resolution>
  <minimum>1</minimum>
  <maximum>32</maximum>
  <randomizable group="0">false</randomizable>
  <value>4</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>332</x>
  <y>96</y>
  <width>79</width>
  <height>47</height>
  <uuid>{d45838ca-f6b4-4bab-b933-7df773c19b3c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Stutter
Chance</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>StutChance</objectName>
  <x>412</x>
  <y>98</y>
  <width>80</width>
  <height>30</height>
  <uuid>{b028bc55-fddf-4281-b8ef-94867aa95d1e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <resolution>0.25000000</resolution>
  <minimum>0</minimum>
  <maximum>1</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>3</x>
  <y>155</y>
  <width>80</width>
  <height>30</height>
  <uuid>{9f4987a8-7e3b-4251-acf5-69e26c2c4f9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>BPM</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>BPM</objectName>
  <x>83</x>
  <y>150</y>
  <width>80</width>
  <height>30</height>
  <uuid>{97d3bf8d-4b1a-45a2-adb9-0fee6a5ff495}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <minimum>20</minimum>
  <maximum>500</maximum>
  <randomizable group="0">false</randomizable>
  <value>110</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>171</x>
  <y>151</y>
  <width>80</width>
  <height>30</height>
  <uuid>{7bef9d8c-328b-4303-94b3-78b85452f876}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Filter Div</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>FilDiv</objectName>
  <x>251</x>
  <y>147</y>
  <width>80</width>
  <height>30</height>
  <uuid>{19845bef-0d61-4d1a-bb52-d67ccd1bcd36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>FreqMin</objectName>
  <x>8</x>
  <y>370</y>
  <width>500</width>
  <height>9</height>
  <uuid>{adcb836a-13c3-4f60-baaf-3155a91cff87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.39250001</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>180</x>
  <y>389</y>
  <width>180</width>
  <height>30</height>
  <uuid>{9e525aef-949a-417e-834e-71bd88df8136}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Cuttoff Frequency min / max</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>FreqMax</objectName>
  <x>8</x>
  <y>380</y>
  <width>500</width>
  <height>9</height>
  <uuid>{a41fad57-43e8-430a-92d7-b6330f476593}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.86940002</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FreqMin_Value</objectName>
  <x>8</x>
  <y>389</y>
  <width>60</width>
  <height>30</height>
  <uuid>{271f338a-661e-40b1-a03f-20ad7feb1ba0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>400.122</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FreqMax_Value</objectName>
  <x>448</x>
  <y>389</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7b7b9f31-566c-4319-a572-ca4ada5f3f6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>5006.802</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>429</y>
  <width>100</width>
  <height>30</height>
  <uuid>{e13ea2b5-66c3-4eae-9c6c-91d9e035400b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Interpolate&lt;=>S&amp;H</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Interp_SH</objectName>
  <x>8</x>
  <y>412</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0460f13f-efd6-4403-bc20-c0d21302e628}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Interp_SH</objectName>
  <x>448</x>
  <y>429</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7d2a46b9-3d13-4fc4-8081-50dbb35f8ff4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>1.000</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

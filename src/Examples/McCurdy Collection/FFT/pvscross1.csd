;WRITTEN BY IAIN MCCURDY, 2006

;Modified for QuteCsound by René, September 2010, updated Feb 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	ksmps changed from 100 to 10	to avoid the message pvsfread: analysis frame overlap must be >= ksmps
;	Instrument 1 is activated by MIDI and by the GUI
;	Add Browser for analysis files


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>
--env:SADIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 10		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


gasrc		init		0	;INITIALISE GLOBAL AUDIO VARIABLE TO ZERO 

gisine		ftgen	0, 0, 65536, 10, 1					;SINE WAVE
giExp2000		ftgen	0, 0, 129, -25, 0, 20.0, 128, 2000.0	;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		kcps			invalue 	"CPS"
		gkcps		tablei	kcps, giExp2000, 1
					outvalue	"CPS_Value", gkcps				;init  200.0		
		gkptr		invalue 	"Pointer"						;init 0.1
		gkspd		invalue 	"Speed"						;init 1.0
		gkinput		invalue 	"Input"						;init 1
		gkwave		invalue 	"Wave"						;init 1
		gkGate		invalue	"Gate"						;init 1.0
		gkamp1		invalue 	"Excitation_Signal_Amplitude"		;init 0.0
		gkamp2		invalue 	"Cross_Synthesis_Amplitude"		;init 0.5
	endif
endin

instr	1	;SIGNAL GENERATOR
	if p4!= 0	then													;MIDI
		ioct		= p4												;READ MIDI PITCH INFORMATION FROM A MIDI KEYBOARD
		iamp		= p5

		;PITCH BEND INFORMATION IS READ
		iSemitoneBendRange = 2										;PITCH BEND RANGE IN SEMITONES (WILL BE DEFINED FURTHER LATER)
		imin		= 0												;EQUILIBRIUM POSITION
		imax 	= iSemitoneBendRange * .0833333						;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax								;PITCH BEND VARIABLE (IN oct FORMAT)

		kcps		= cpsoct(ioct + kbend)
		kenv		linsegr	0, .01, iamp, .01, 0						;CREATE AN AMPLITUDE ENVELOPE TO PREVENT CLICKS. INCLUDES A MIDI-RELEASE STAGE
	else															;GUI
		iporttime	=		.01										;CREATE A RAMPING UP VALUE THAT WILL BE USED FOR PORTAMENTO TIME
		kporttime	linseg	0, .001, iporttime, 1, iporttime				;CREATE A RAMPING UP VALUE THAT WILL BE USED FOR PORTAMENTO TIME
		kcps		portk	gkcps, kporttime							;APPLY PORTAMENTO TO gkcps
		kenv		linsegr	0, .01, 1, .01, 0							;CREATE AN AMPLITUDE ENVELOPE TO PREVENT CLICKS. INCLUDES A MIDI-RELEASE STAGE
	endif

	if	gkwave=0	then
		asine	oscili	kenv, kcps, gisine 
		gasrc	=		gasrc + asine								;ADD SINE TONE TO THE GLOBAL AUDIO VARIABLE gaexc. THIS MECHANISM FACILITATES MIDI POLYPHONY
	elseif	gkwave<=3&&gkwave>0	then
		avco		vco 		kenv, kcps, i(gkwave), 0.5, gisine, 1, 0, 22054/sr, 0			;SAWTOOTH WAVEFORM
		gasrc	=		gasrc + avco								;ADD VCO TONE TO THE GLOBAL AUDIO VARIABLE gaexc. THIS MECHANISM FACILITATES MIDI POLYPHONY
	else
		anoise	noise	kenv, 0
		gasrc	=		gasrc + anoise								;ADD NOISE SIGNAL TO THE GLOBAL AUDIO VARIABLE gaexc. THIS MECHANISM FACILITATES MIDI POLYPHONY
	endif
endin

instr	3
	if	gkinput>=1 then											;IF 'INPUT' SWITCH IS SET TO 'STORED FILE' THEN IMPLEMENT THE NEXT LINE OF CODE
	if	gkinput!=1 kgoto	SKIP1

	SAnalysisFile1	invalue		"_Browse1"
	ilen1		filelen		SAnalysisFile1							;DERIVE THE FILE LENGTH (IN SECONDS) OF THE CHOSEN ANALYSIS FILE	
	;OUTPUT		OPCODE		FREQUENCY
	kptr			phasor		gkspd/ilen1							;CREATE A MOVING PHASE VALUE (0-1) THAT WILL BE USED AS A FILE POINTER. FREQUENCY OF PHASOR WILL BE DIRECTLY PROPORTIONAL TO SPEED SLIDER AND INVERSELY PROPORTIONAL TO THE LENGTH OF THE ANALYSIS FILE
	ktrig		changed		kptr									;CREATE A TRIGGER (MOMENTARY 1 VALUE) EACH TIME VARIABLE kptr CHANGES

	if ktrig=1 then
				outvalue		"Pointer", kptr						;UPDATE 'Pointer' SLIDER WHENEVER TRIGGER IS '1' USING VALUE HELD IN THE 'VALUE' COLUMN 
	endif

	;OUTPUT		OPCODE		POINTER     |   FILE
	fdest  		pvsfread		gkptr * ilen1, SAnalysisFile1				;READ AN ANALYSIS FILE FROM THE HARD DRIVE ACCORDING TO THE GIVEN FILE POINTER LOCATION. OUTPUT AN F-SIGNAL.
				kgoto		SKIP2
	SKIP1:
	SAnalysisFile2	invalue		"_Browse2"
	ilen2		filelen		SAnalysisFile2							;DERIVE THE FILE LENGTH (IN SECONDS) OF THE CHOSEN ANALYSIS FILE	
	;OUTPUT		OPCODE		FREQUENCY
	kptr			phasor		gkspd/ilen2							;CREATE A MOVING PHASE VALUE (0-1) THAT WILL BE USED AS A FILE POINTER. FREQUENCY OF PHASOR WILL BE DIRECTLY PROPORTIONAL TO SPEED SLIDER AND INVERSELY PROPORTIONAL TO THE LENGTH OF THE ANALYSIS FILE
	ktrig		changed		kptr									;CREATE A TRIGGER (MOMENTARY 1 VALUE) EACH TIME VARIABLE kptr CHANGES

	if ktrig=1 then
				outvalue		"Pointer", kptr						;UPDATE 'Pointer' SLIDER WHENEVER TRIGGER IS '1' USING VALUE HELD IN THE 'VALUE' COLUMN 
	endif

	;OUTPUT		OPCODE		POINTER     |   FILE
	fdest  		pvsfread		gkptr * ilen2, SAnalysisFile2				;READ AN ANALYSIS FILE FROM THE HARD DRIVE ACCORDING TO THE GIVEN FILE POINTER LOCATION. OUTPUT AN F-SIGNAL.
	SKIP2:
	else															;IF 'INPUT' SWITCH IS NOT SET TO 'STORED FILE' THEN IMPLEMENT THE NEXT LINE OF CODE
	adest, aignore	ins												;READ AUDIO FROM THE COMPUTER'S LIVE INPUT (LEFT INPUT ONLY IS READ, RIGHT CHANNEL IS IGNORED IN SUBSEQUENT CODE. A STEREO VERSION COULD EASILY BE BUILT BUT THIS WOULD DOUBLE CPU DEMANDS!) 

	;OUTPUT		OPCODE		INPUT | FFTSIZE | OVERLAP | WINSIZE | WINTYPE
	fdest  		pvsanal		adest,    1024,      256,     1024,       1	;ANALYSE THE AUDIO SIGNAL
	endif														;END OF 'IF'...'THEN' BRANCHING
		
	fsrc  		pvsanal		gasrc, 1024, 256, 1024, 1				;ANALYSE THE EXCITATION AUDIO SIGNAL
	fsig 		pvscross 		fsrc, fdest, gkamp1, gkamp2

	aresyn 		pvsynth		fsig									;RESYNTHESIZE THE NEW F-SIGNAL INTO AN AUDIO SIGNAL
	
	if	gkGate=1	then
		afollow	follow2		gasrc, 0.1, 0.1						;CREATE AN AMPLITUDE FOLLOWING SIGNAL THAT FOLLOWS THE DYNAMIC ENVELOPE OF THE EXCITATION SIGNAL - THIS WILL BE USED TO GATE THE CROSS SYNTHESISED SIGNAL
		aresyn	=			aresyn*afollow
	endif
				outs			aresyn, aresyn							;SEND THE RESYNTHESIZED AUDIO SIGNAL TO THE OUTPUTS 
	gasrc		= 0												;RESET THE GLOBAL AUDIO SIGNAL TO ZERO - THIS PREVENTS A STUCK, NON-ZERO VALUE FOR gaexc IN THE SITUATION WHERE NO EXCITATION SIGNAL IS PLAYING
endin
	
instr	4	;SET SPEED SLIDER TO ZERO
		outvalue	"Speed", 0.0
endin
</CsInstruments>
<CsScore>
;INSTR | START |   DURATION
i 10		0		3600			;GUI
i  3		0 		3600			;ACTIVATE INSTRUMENT 3 FOR 1 HOUR - ALSO SUSTAINS REALTIME PERFORMANCE
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>493</x>
 <y>163</y>
 <width>860</width>
 <height>599</height>
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
  <width>516</width>
  <height>594</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvscross</label>
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
  <y>2</y>
  <width>333</width>
  <height>594</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvscross</label>
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
  <x>522</x>
  <y>33</y>
  <width>326</width>
  <height>551</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------
Pvscross combines the spectral envelope of one signal (referred to as the input signal) with the frequencies of another signal (referred to as the excitation signal).
This capability can be used to imitate the functioning of the traditional vocoder. This is what has been implemented in this example.
An input signal of either a stored analysis file (voice or drum loop) or a live input can be combined with a variety of synthesized timbres.
This signal generator can also be triggered from a connected MIDI keyboard thus allowing the playing of chords of excitation signals.
When playing from a MIDI keyboard the 'Signal Generator' switch should be deactivated. Pitch bend is also implemented.
The 'Gate Amplitude' switch forces the output sound to follow the amplitude of the excitation sound.
The user can mix between the excitation signal and the cross-synthesized signal using the 'Excitation Signal Amplitude' and 'Cross Synthesis Amplitude' controls.
When using a stored analysis file (either voice or drums) as input the speed of playback can be varied using the 'Speed' slider.
A value of 1 represents normal playback speed, 2 represents double speed and so on. File pointer movement is monitored by the 'File Pointer' slider.
Manual file pointer adjustment is possible by first reducing 'Speed' to zero by clicking the 'Speed to Zero' button and then using the 'File Pointer' slider.</label>
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
  <x>4</x>
  <y>32</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b3560c14-84be-4876-9100-5807ffe16e97}</uuid>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>65</x>
  <y>32</y>
  <width>120</width>
  <height>30</height>
  <uuid>{cdb2d3b2-5a09-4e13-865e-8501e33b9d35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Live Input</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Vocal Sample</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Drum Loop</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>178</y>
  <width>508</width>
  <height>140</height>
  <uuid>{c23f1867-583e-4e16-b094-1ce102f86873}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Signal Generator</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
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
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>217</y>
  <width>160</width>
  <height>30</height>
  <uuid>{090b86ec-158a-4f6a-abf8-78660fc5c107}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS (if No MIDI)</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>CPS</objectName>
  <x>10</x>
  <y>200</y>
  <width>500</width>
  <height>27</height>
  <uuid>{7414f1af-bc65-42bb-a972-115e0eeae202}</uuid>
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
  <objectName>CPS_Value</objectName>
  <x>450</x>
  <y>217</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bb1d774f-0ab7-400b-9a57-a8243856eee9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>200.000</label>
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
  <x>302</x>
  <y>264</y>
  <width>70</width>
  <height>30</height>
  <uuid>{217e252e-ab29-4b66-aff6-86e28505d5ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Wave</label>
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
  <objectName>Wave</objectName>
  <x>373</x>
  <y>264</y>
  <width>130</width>
  <height>30</height>
  <uuid>{76d7136c-5124-44ec-9ba4-7d0cb0e8c6eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Sine</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sawtooth</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Square</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Triangle</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Noise</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>25</x>
  <y>264</y>
  <width>210</width>
  <height>30</height>
  <uuid>{16cf4cec-b8d2-48a8-8cbe-e36230f9d26c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off   (Use if No MIDI)</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>322</y>
  <width>508</width>
  <height>140</height>
  <uuid>{68d4f34d-931a-4ea7-b688-77724021f7a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Source Signal</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
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
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>Pointer</objectName>
  <x>10</x>
  <y>362</y>
  <width>500</width>
  <height>15</height>
  <uuid>{e55fdc2d-0bbe-479a-a3d8-525e73353a9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.49766830</xValue>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pointer</objectName>
  <x>450</x>
  <y>378</y>
  <width>60</width>
  <height>30</height>
  <uuid>{450cce93-cd69-4e55-97ec-5d2f88014dd2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.498</label>
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
  <x>10</x>
  <y>378</y>
  <width>160</width>
  <height>30</height>
  <uuid>{fe34f976-e5bc-4408-a62a-5fa5026da416}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>File Pointer</label>
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
  <x>450</x>
  <y>426</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0286ec15-8443-4ab3-9f65-fdf6bbee6a17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
  <x>10</x>
  <y>409</y>
  <width>500</width>
  <height>27</height>
  <uuid>{cf784473-dd45-4074-9571-b6264bf289af}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>426</y>
  <width>120</width>
  <height>30</height>
  <uuid>{eea58f50-29cc-4f4b-982a-1f030bf01966}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>250</x>
  <y>439</y>
  <width>120</width>
  <height>21</height>
  <uuid>{014685d3-5101-4dd5-b4ef-62a64ecf195b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Speed to Zero</text>
  <image>/</image>
  <eventLine>i 4 0 0</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>466</y>
  <width>508</width>
  <height>125</height>
  <uuid>{f5f026fd-f603-4578-befa-7395826dd95a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pvscross Cross Synthesizer</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
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
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Gate</objectName>
  <x>250</x>
  <y>473</y>
  <width>120</width>
  <height>21</height>
  <uuid>{0933c911-abe9-4fd8-8760-11d20dc84ceb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Amplitude Gate</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Cross_Synthesis_Amplitude</objectName>
  <x>450</x>
  <y>559</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c3d52355-34d5-4a67-bd02-e62b51a8837c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.762</label>
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
  <objectName>Cross_Synthesis_Amplitude</objectName>
  <x>10</x>
  <y>542</y>
  <width>500</width>
  <height>27</height>
  <uuid>{45ab0ca9-cd12-4f97-a412-052d26fe0fa0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.76200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>559</y>
  <width>180</width>
  <height>30</height>
  <uuid>{0f727a6c-af68-43e5-b072-19c367c98e6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Cross Synthesis Amplitude</label>
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
  <objectName>Excitation_Signal_Amplitude</objectName>
  <x>450</x>
  <y>518</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3cd27781-8800-437d-9276-baee8eff1eb1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.054</label>
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
  <objectName>Excitation_Signal_Amplitude</objectName>
  <x>10</x>
  <y>501</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f5491987-1bc3-463b-bc73-66fcd58ecedc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.05400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>518</y>
  <width>180</width>
  <height>30</height>
  <uuid>{ec7b74e0-0c5b-4069-9fbd-d284336eaa92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Excitation Signal Amplitude</label>
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
  <objectName>_Browse1</objectName>
  <x>6</x>
  <y>88</y>
  <width>170</width>
  <height>30</height>
  <uuid>{6cab23a3-f8cb-429f-a3b7-b96225b7ba32}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>AndItsAll.pvx</stringvalue>
  <text>Browse Analysis File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>69</y>
  <width>120</width>
  <height>30</height>
  <uuid>{d02a3842-7ec5-4331-8e87-beb6a62dafbe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vocal pvx</label>
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
  <objectName>_Browse1</objectName>
  <x>177</x>
  <y>89</y>
  <width>330</width>
  <height>28</height>
  <uuid>{eff97a71-b637-48ce-a20e-3491df1b708d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>AndItsAll.pvx</label>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse2</objectName>
  <x>177</x>
  <y>141</y>
  <width>330</width>
  <height>28</height>
  <uuid>{c2692023-5b53-479f-9356-16067241f051}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>loop.pvx</label>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>121</y>
  <width>120</width>
  <height>30</height>
  <uuid>{5586a848-dee3-452a-9a83-3f8ec69ab39e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Drum Loop pvx</label>
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
  <objectName>_Browse2</objectName>
  <x>6</x>
  <y>140</y>
  <width>170</width>
  <height>30</height>
  <uuid>{bbb3f029-39f0-44c2-b932-cae140aad307}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>loop.pvx</stringvalue>
  <text>Browse Analysis File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>177</x>
  <y>66</y>
  <width>330</width>
  <height>30</height>
  <uuid>{a63909ac-6fa4-41c8-a84b-ba08e76132ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Restart the instrument after changing the analysis  file(s).</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

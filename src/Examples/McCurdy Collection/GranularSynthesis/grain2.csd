;Written by Iain McCurdy, 2011

;Modified for QuteCsound by René, May 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add Browser for audio files and power of two tables for grain2 opcode, accept mono or stereo wav files
;	Instrument 1 is activated by MIDI and by the GUI, added pitchbend
;	Removed Recording instrument 99, included in QuteCsound
;	Add INIT instrument using QuteCsound Presets system


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 64	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine	ftgen	0, 0, 4096, 10, 1							;SINE WAVE
gibuzz	ftgen	0, 0, 2048, 11, 30, 1, 0.8					;BUZZ WAVEFORM

;GRAIN ENVELOPE WINDOW FUNCTION TABLES:
giwfn1	ftgen	0, 0, 512, 20, 2							;HANNING WINDOW
giwfn2	ftgen	0, 0, 512,  7, 0, 12, 1, 500, 0				;PERCUSSIVE - STRAIGHT SEGMENTS
giwfn3	ftgen	0, 0, 512,  5, 0.001, 12, 1, 500, 0.001			;PERCUSSIVE - EXPONENTIAL SEGMENTS
giwfn4	ftgen	0, 0, 512,  7, 0, 6, 1, 500, 1, 6, 0			;GATE - WITH ANTI-CLICK RAMP UP AND RAMP DOWN SEGMENTS
giwfn5	ftgen	0, 0, 512,  7, 0, 500, 1, 12, 0				;REVERSE PERCUSSIVE - STRAIGHT SEGMENTS
giwfn6	ftgen	0, 0, 512,  5, 0.001, 500, 1, 12, 0.001			;REVERSE PERCUSSIVE - EXPONENTIAL SEGMENTS


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;BUTTONS
		koptions1		invalue	"Interp"
		koptions2		invalue	"NoInterp"
		koptions3		invalue	"FreqCont"
		koptions4		invalue	"SkipInit"
		gkMIDIToPch	invalue	"MIDItoPch"
		gkMIDIToDens	invalue	"MIDItoDens"
		gkoptions		=		koptions1 + koptions2 + koptions3 + koptions4

		;SLIDERS
		gkamp		invalue	"Amplitude"
		gkdur		invalue	"GrainDuration"
		gkratio		invalue	"PitchRatio"
		gkcps		invalue	"PitchCPS"
		gkfmd		invalue	"PitchOffset"
		gkovrlp		invalue	"NbOverlaps"
		gkfrpow		invalue	"RndPitchVar"
		gkseedL		invalue	"SeedL"
		gkseedR		invalue	"SeedR"
		gkAtt		invalue	"Attack"
		gkRel		invalue	"Release"
		;MENUS 
		gkwfn		invalue	"GrainEnvelope" 
		gksfn		invalue	"Input" 

		;AUDIO FILE CHANGE / LOAD IN POWER OF 2 TABLES **********************************************************************************************
		Sfile_new		strcpy	""										;INIT TO EMPTY STRING

		Sfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	Sfile
		kfile 		strcmpk	Sfile_new, Sfile_old

		gkfile_new	init		0
		if	kfile != 0	then											;IF A BANG HAD BEEN GENERATED IN THE LINE ABOVE
			gkfile_new	=	1										;Flag to inform instr 1 that a new file is loaded
				reinit	NEW_FILE										;REINITIALIZE FROM LABEL 'NEW_FILE'
		endif
		NEW_FILE:
		;grain2 accept only power of 2 table size
		ifnTemp		ftgentmp	0, 0, 0, 1, Sfile, 0, 0, 1					;Temporary table to get the audio file size
		iftlen		= ftlen(ifnTemp)									;file size
		giftlen2		pow	2, ceil(log(iftlen)/log(2))						;high nearest power of two table size

		;FUNCTION TABLES NUMBERS OF THE SOUND FILE THAT WILL BE GRANULATED
		ichn			filenchnls	Sfile
		if ichn == 1 then
			giFileL	ftgentmp	0, 0, giftlen2, 1, Sfile, 0, 0, 1				;READ MONO AUDIO FILE CHANNEL 1
			giFileR	=		giFileL
		else
			giFileL	ftgentmp	0, 0, giftlen2, 1, Sfile, 0, 0, 1				;READ STEREO AUDIO FILE CHANNEL 1
			giFileR	ftgentmp	0, 0, giftlen2, 1, Sfile, 0, 0, 2				;READ STEREO AUDIO FILE CHANNEL 2
		endif
;*******************************************************************************************************************************************
	endif
endin

instr	1	;GRAIN2 INSTRUMENT
	if p4!=0 then														;MIDI
		ioct		=	p4												;READ OCT VALUE FROM MIDI INPUT
		;PITCH BEND=============================================================================================
		iSemitoneBendRange = 12											;PITCH BEND RANGE IN SEMITONES
		imin		= 0													;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333							;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax									;PITCH BEND VARIABLE (IN oct FORMAT)
		kcps		=	cpsoct(ioct + kbend)								;SET FUNDAMENTAL
		;=======================================================================================================
	endif

	kporttime	linseg	0, 0.001, 0.1										;CREATE A VARIABLE FUNCTION THAT RAPIDLY RAMPS UP TO A SET VALUE	

	if p4!=0 && gkMIDIToPch=1 then										;IF THIS IS A MIDI ACTIVATED NOTE AND MIDI-TO-PITCH SWITCH IS ON... 
		kratio	=		kcps/cpsoct(8)									;MAP TO MIDI NOTE VALUE TO PITCH (CONVERT TO RATIO: MIDDLE C IS POINT OF UNISON)
	else																;OTHERWISE...
		kratio	portk	gkratio, kporttime								;USE THE GUI SLIDER VALUE
		kcps		portk	gkcps, kporttime								;USE THE GUI SLIDER VALUE
	endif															;END OF THIS CONDITIONAL BRANCH

	if p4!=0 && gkMIDIToDens=1 then										;IF THIS IS A MIDI ACTIVATED NOTE AND MIDI-TO-PITCH SWITCH IS ON... 
		gkovrlp	=		kcps											;MAP TO MIDI NOTE VALUE TO GRAIN DENSITY
	endif															;END OF THIS CONDITIONAL BRANCH

	if	gkfile_new = 1	then												;test if a new file is loaded by instr 10
		gkfile_new = 0													;flag to zero for next file change
		reinit	START												;REINITIALIZE FROM LABEL 'NEW_FILE1'
	endif

	kSwitch	changed	gkoptions, gkwfn, gksfn, gkfrpow, gkseedL, gkseedR, gkovrlp

	if	kSwitch=1	then													;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	START												;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
	endif

	START:
	isfnL	=	giFileL												;SOURCE SOUND/WAVEFORM FUNCTION TABLE
	isfnR 	=	giFileR												;SOURCE SOUND/WAVEFORM FUNCTION TABLE

	if 		i(gksfn)=1 then
	  isfnL	=	gisine
	  isfnR	=	isfnL
	elseif	i(gksfn)=2 then
	  isfnL	=	gibuzz
	  isfnR	=	isfnL
	endif

	if		gksfn = 0	then												;IF INPUT TABLE FOR GRAINS IS A SOUND FILE...
	  kpitch	=	(sr*kratio)/giftlen2
	else																;OTHERWISE (WAVEFORM)...
	  kpitch 	= 	kcps
	endif

	iwfn		=	giwfn1 + i(gkwfn)

	aSigL	grain2	kpitch, gkfmd, gkdur, i(gkovrlp), isfnL, iwfn, i(gkfrpow), i(gkseedL), i(gkoptions)
	aSigR	grain2	kpitch, gkfmd, gkdur, i(gkovrlp), isfnR, iwfn, i(gkfrpow), i(gkseedR), i(gkoptions)

			rireturn													;RETURN TO PERFORMANCE TIME PASSES

	aenv		expsegr	0.0001, i(gkAtt), 1, i(gkRel), 0.0001					;CLOUD AMPLITUDE ENVELOPE
			outs		aSigL  * gkamp * aenv, aSigR  * gkamp * aenv				;SEND AUDIO TO OUTPUTS
endin

instr	2	;INIT
		outvalue	"_SetPresetIndex", 0
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI

i 2	     0.1		 0.01	;INIT
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>1054</width>
 <height>564</height>
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
  <width>1026</width>
  <height>510</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>grain2</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>85</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>8</y>
  <width>120</width>
  <height>30</height>
  <uuid>{55273d97-d39a-441c-8da6-87ea139493b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>148</y>
  <width>180</width>
  <height>26</height>
  <uuid>{8d67138b-037d-461e-8a25-108f849b03c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch Ratio (SOUND FILE INPUT)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>PitchRatio</objectName>
  <x>8</x>
  <y>125</y>
  <width>500</width>
  <height>27</height>
  <uuid>{273087bd-e04a-4975-a3bd-5b0a8b5fd40a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.12500000</minimum>
  <maximum>4.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PitchRatio</objectName>
  <x>448</x>
  <y>148</y>
  <width>60</width>
  <height>26</height>
  <uuid>{04617e86-7abe-4120-bb9b-1d6ccd2f0983}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>521</x>
  <y>62</y>
  <width>170</width>
  <height>30</height>
  <uuid>{1757a18f-b418-4ef1-984d-bdee5e985805}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>AndItsAll.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>691</x>
  <y>63</y>
  <width>330</width>
  <height>28</height>
  <uuid>{804f4f24-03f1-4ac2-8ba2-697f15df06cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>AndItsAll.wav</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>41</y>
  <width>120</width>
  <height>30</height>
  <uuid>{a918d231-4dd1-4893-81ef-bf453535bda6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input File</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>106</y>
  <width>180</width>
  <height>26</height>
  <uuid>{93f3e274-799d-49e8-9392-4d8c6ad43ae2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Duration (ms)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>GrainDuration</objectName>
  <x>8</x>
  <y>83</y>
  <width>500</width>
  <height>27</height>
  <uuid>{89741b38-8333-4828-b8b8-656cff90d564}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.25000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>GrainDuration</objectName>
  <x>448</x>
  <y>106</y>
  <width>60</width>
  <height>26</height>
  <uuid>{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.250</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>190</y>
  <width>180</width>
  <height>26</height>
  <uuid>{9d200fd9-5a42-4f87-89ab-14ef5ac064ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch CPS (WAVEFORM INPUT)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>PitchCPS</objectName>
  <x>8</x>
  <y>167</y>
  <width>500</width>
  <height>27</height>
  <uuid>{ecd7a8b0-5bb3-4479-b692-e56294223499}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>300.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PitchCPS</objectName>
  <x>448</x>
  <y>190</y>
  <width>60</width>
  <height>26</height>
  <uuid>{f275c8fd-3605-49e8-9090-67ca5f21a9f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>300.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>64</y>
  <width>180</width>
  <height>26</height>
  <uuid>{5cde19f3-b356-4945-9c8b-43dd67c604dd}</uuid>
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
   <b>255</b>
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
  <y>41</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d6d73a88-8d82-47de-a067-758f1917a3f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.25000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>64</y>
  <width>60</width>
  <height>26</height>
  <uuid>{073ad371-9227-46fa-a005-ac10a210db79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.250</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>521</x>
  <y>319</y>
  <width>500</width>
  <height>80</height>
  <uuid>{b83b9228-3958-46d8-adf5-262b04a121c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Cloud Envelope</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>365</y>
  <width>180</width>
  <height>30</height>
  <uuid>{489dc531-f476-4ca3-b56d-f970ee2c49aa}</uuid>
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
   <b>255</b>
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
  <x>521</x>
  <y>342</y>
  <width>250</width>
  <height>27</height>
  <uuid>{dbdbe7cb-a74d-45b2-9e47-e5c0594f3ea5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.05000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Attack</objectName>
  <x>711</x>
  <y>365</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.050</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>961</x>
  <y>365</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.050</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>771</x>
  <y>342</y>
  <width>250</width>
  <height>27</height>
  <uuid>{cb664a0c-f84b-41f5-92e9-7deb5a672d56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.05000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>771</x>
  <y>365</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7a8b8cb8-12e8-415d-b11c-fb0d460c9e6f}</uuid>
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
   <b>255</b>
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
  <y>316</y>
  <width>220</width>
  <height>26</height>
  <uuid>{b6afbe1e-677c-44a6-ba84-4c32dc21b0a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Distribution of Random Pitch Variation</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>RndPitchVar</objectName>
  <x>8</x>
  <y>293</y>
  <width>500</width>
  <height>27</height>
  <uuid>{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>2.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RndPitchVar</objectName>
  <x>448</x>
  <y>316</y>
  <width>60</width>
  <height>26</height>
  <uuid>{95f6cb02-77ec-46fe-876b-a93efac3c5e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>274</y>
  <width>180</width>
  <height>26</height>
  <uuid>{7fd47947-fd0d-4964-85e5-682fed1916c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number of Overlaps</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>NbOverlaps</objectName>
  <x>8</x>
  <y>251</y>
  <width>500</width>
  <height>27</height>
  <uuid>{475cdd64-a4ca-4ebc-a000-90448e932478}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>200.00000000</maximum>
  <value>10.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>NbOverlaps</objectName>
  <x>448</x>
  <y>274</y>
  <width>60</width>
  <height>26</height>
  <uuid>{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>232</y>
  <width>180</width>
  <height>26</height>
  <uuid>{3ebc1139-1fdb-48dc-9150-49ee8dfdbd4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch Offset</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>PitchOffset</objectName>
  <x>8</x>
  <y>209</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2cf97843-5b49-438e-8034-62a459597e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.30000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PitchOffset</objectName>
  <x>448</x>
  <y>232</y>
  <width>60</width>
  <height>26</height>
  <uuid>{e54486c5-f9aa-4d0e-9a67-6506dae3c790}</uuid>
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
   <b>255</b>
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
  <objectName>Interp</objectName>
  <x>643</x>
  <y>198</y>
  <width>16</width>
  <height>16</height>
  <uuid>{c91fbe77-0e64-47c4-8d0c-8e11c6357c65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>8.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>NoInterp</objectName>
  <x>781</x>
  <y>198</y>
  <width>16</width>
  <height>16</height>
  <uuid>{82fb9bb8-870c-4d99-aa2c-e0737632eaaa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>4.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>673</x>
  <y>189</y>
  <width>107</width>
  <height>35</height>
  <uuid>{ce374c64-8397-44a6-994b-4965d6d27f36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Do Not Interpolate
Grain Waveform</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>SkipInit</objectName>
  <x>643</x>
  <y>229</y>
  <width>16</width>
  <height>16</height>
  <uuid>{a25a48b1-9ba9-49b7-a190-19023a8e37e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>MIDItoPch</objectName>
  <x>781</x>
  <y>229</y>
  <width>16</width>
  <height>16</height>
  <uuid>{15cb1c0c-7f3b-4f53-93c1-383a67f11366}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>673</x>
  <y>225</y>
  <width>107</width>
  <height>30</height>
  <uuid>{efdeda47-7ac4-4566-8c07-9f1a98886c5e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI to Pitch</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>521</x>
  <y>225</y>
  <width>120</width>
  <height>30</height>
  <uuid>{cbf5c49d-eea8-45cb-97d8-736f42feddb2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Skip Initialisation</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>FreqCont</objectName>
  <x>919</x>
  <y>198</y>
  <width>16</width>
  <height>16</height>
  <uuid>{f65b4392-389d-48ca-ba17-ab82ffa05bbc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>2.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>799</x>
  <y>189</y>
  <width>120</width>
  <height>35</height>
  <uuid>{d98d1d5d-8b96-4ca5-b011-fbd6e2e8b2f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Continuous Freq
Modulation</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>MIDItoDens</objectName>
  <x>919</x>
  <y>229</y>
  <width>16</width>
  <height>16</height>
  <uuid>{6083872a-d937-4f30-ae49-bc3a1cccab54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>799</x>
  <y>225</y>
  <width>120</width>
  <height>30</height>
  <uuid>{3e9cc7b4-8f67-4225-813b-1412a0f6f00d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI to Density</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <objectName>GrainEnvelope</objectName>
  <x>691</x>
  <y>263</y>
  <width>330</width>
  <height>30</height>
  <uuid>{1967ceb8-a1c4-4c8f-995e-05391c92b96c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Hanning</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Percussive (straight segments)</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Percussive (exponential segments)</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Gate (with anti click ramp up and ramp down)</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Reverse Percussive (straight segments)</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Reverse Percussive (exponential segments)</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>553</x>
  <y>265</y>
  <width>137</width>
  <height>32</height>
  <uuid>{48bd216b-d27b-4396-b997-30ddbe53d173}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Envelope Type</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>365</y>
  <width>120</width>
  <height>30</height>
  <uuid>{c71f1f6c-839a-4dca-a2ee-3459bf26e376}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Seed Value Left</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>535</x>
  <y>189</y>
  <width>107</width>
  <height>35</height>
  <uuid>{6524dd7f-f6aa-48d1-9348-85004d1db83f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Interpolate Grain
Window</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>691</x>
  <y>127</y>
  <width>174</width>
  <height>30</height>
  <uuid>{7c4f04d1-0710-4b77-a412-d783034c89d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Sound File</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sine</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Buzz</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>572</x>
  <y>131</y>
  <width>120</width>
  <height>30</height>
  <uuid>{0b39dee5-918a-4abe-b3be-e15ba5222429}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input :</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <y>396</y>
  <width>1015</width>
  <height>139</height>
  <uuid>{9c6abfa6-99bf-4a15-94a4-ce86b18f37d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
grain2 is a simpler version of grain3. grain3 offers more input parameters and greater user control.
grain2 provides no user control of grain phase (pointer position), instead initial phase is chosen randomly across the source function table.
Density it defined as the number of overlaps. This is an i-rate parameter, in this example moving its slider forces reinitialisations in order to implement the update but this will inevitably cause discontinuities in the audio output.
If density is thought of as grains per second then increasing 'Number of Overlaps' will increase density but reducing 'Grain Duration' will also increase density.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>SeedL</objectName>
  <x>129</x>
  <y>365</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2bf2fa3a-39f0-466f-81aa-d594b7a6f5f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <minimum>0</minimum>
  <maximum>2.14748e+09</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>229</x>
  <y>365</y>
  <width>120</width>
  <height>30</height>
  <uuid>{c83c33cb-81d2-41fa-ae19-99118698acf2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Seed Value Right</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>SeedR</objectName>
  <x>350</x>
  <y>365</y>
  <width>100</width>
  <height>30</height>
  <uuid>{716f5b71-705a-4ac8-9af6-09876c21d9a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <minimum>0</minimum>
  <maximum>2.14748e+09</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="INIT" number="0" >
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="1" >0.00000000</value>
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="4" >0</value>
<value id="{273087bd-e04a-4975-a3bd-5b0a8b5fd40a}" mode="1" >1.00000000</value>
<value id="{04617e86-7abe-4120-bb9b-1d6ccd2f0983}" mode="1" >1.00000000</value>
<value id="{04617e86-7abe-4120-bb9b-1d6ccd2f0983}" mode="4" >1.000</value>
<value id="{1757a18f-b418-4ef1-984d-bdee5e985805}" mode="4" >AndItsAll.wav</value>
<value id="{804f4f24-03f1-4ac2-8ba2-697f15df06cf}" mode="4" >AndItsAll.wav</value>
<value id="{89741b38-8333-4828-b8b8-656cff90d564}" mode="1" >0.25000000</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="1" >0.25000000</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="4" >0.250</value>
<value id="{ecd7a8b0-5bb3-4479-b692-e56294223499}" mode="1" >300.00000000</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="1" >300.00000000</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="4" >300.000</value>
<value id="{d6d73a88-8d82-47de-a067-758f1917a3f2}" mode="1" >0.25000000</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="1" >0.25000000</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="4" >0.250</value>
<value id="{dbdbe7cb-a74d-45b2-9e47-e5c0594f3ea5}" mode="1" >0.05000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="1" >0.05000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="4" >0.050</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="1" >0.05000000</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="4" >0.050</value>
<value id="{cb664a0c-f84b-41f5-92e9-7deb5a672d56}" mode="1" >0.05000000</value>
<value id="{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}" mode="1" >2.00000000</value>
<value id="{95f6cb02-77ec-46fe-876b-a93efac3c5e5}" mode="1" >2.00000000</value>
<value id="{95f6cb02-77ec-46fe-876b-a93efac3c5e5}" mode="4" >2.000</value>
<value id="{475cdd64-a4ca-4ebc-a000-90448e932478}" mode="1" >10.00000000</value>
<value id="{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}" mode="1" >10.00000000</value>
<value id="{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}" mode="4" >10.000</value>
<value id="{2cf97843-5b49-438e-8034-62a459597e86}" mode="1" >0.00000000</value>
<value id="{e54486c5-f9aa-4d0e-9a67-6506dae3c790}" mode="1" >0.00000000</value>
<value id="{e54486c5-f9aa-4d0e-9a67-6506dae3c790}" mode="4" >0.000</value>
<value id="{c91fbe77-0e64-47c4-8d0c-8e11c6357c65}" mode="1" >0.00000000</value>
<value id="{c91fbe77-0e64-47c4-8d0c-8e11c6357c65}" mode="4" >0</value>
<value id="{82fb9bb8-870c-4d99-aa2c-e0737632eaaa}" mode="1" >0.00000000</value>
<value id="{82fb9bb8-870c-4d99-aa2c-e0737632eaaa}" mode="4" >0</value>
<value id="{a25a48b1-9ba9-49b7-a190-19023a8e37e7}" mode="1" >0.00000000</value>
<value id="{a25a48b1-9ba9-49b7-a190-19023a8e37e7}" mode="4" >0</value>
<value id="{15cb1c0c-7f3b-4f53-93c1-383a67f11366}" mode="1" >0.00000000</value>
<value id="{15cb1c0c-7f3b-4f53-93c1-383a67f11366}" mode="4" >0</value>
<value id="{f65b4392-389d-48ca-ba17-ab82ffa05bbc}" mode="1" >0.00000000</value>
<value id="{f65b4392-389d-48ca-ba17-ab82ffa05bbc}" mode="4" >0</value>
<value id="{6083872a-d937-4f30-ae49-bc3a1cccab54}" mode="1" >0.00000000</value>
<value id="{6083872a-d937-4f30-ae49-bc3a1cccab54}" mode="4" >0</value>
<value id="{1967ceb8-a1c4-4c8f-995e-05391c92b96c}" mode="1" >0.00000000</value>
<value id="{7c4f04d1-0710-4b77-a412-d783034c89d7}" mode="1" >0.00000000</value>
<value id="{2bf2fa3a-39f0-466f-81aa-d594b7a6f5f2}" mode="1" >0.00000000</value>
<value id="{716f5b71-705a-4ac8-9af6-09876c21d9a4}" mode="1" >0.00000000</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

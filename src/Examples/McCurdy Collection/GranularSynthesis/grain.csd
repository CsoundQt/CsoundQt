;Written by Iain McCurdy, 2011

;Modified for QuteCsound by René, May 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add Browser for audio files and power of two tables for grain opcode, accept mono or stereo wav files
;	Instrument 1 is activated by MIDI and by the GUI, added pitchbend
;	Removed Recording instrument 99, included in QuteCsound
;	Add INIT instrument using QuteCsound Presets system


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 64	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


;THE SOUND FILES USED IN THE GRANULATION
gisine	ftgen	0,        0,     4096,         10,    1						;SINE WAVE
gibuzz	ftgen	0,        0,     2048,         11,    30, 1, 0.8				;BUZZ WAVEFORM

giratio	ftgen	0,        0,     4096,         -16,   0.125, 1024, 4, 4
gicps	ftgen	0,        0,     4096,         -16,   50,    1024, 4, 2000

;GRAIN ENVELOPE WINDOW FUNCTION TABLES:
giwfn1	ftgen	0,  0, 512,  20, 2										; HANNING WINDOW
giwfn2	ftgen	0,  0, 512,  7, 0, 12, 1, 500, 0							; PERCUSSIVE - STRAIGHT SEGMENTS
giwfn3	ftgen	0,  0, 512,  5, 0.001, 12, 1, 500, 0.001					; PERCUSSIVE - EXPONENTIAL SEGMENTS
giwfn4	ftgen	0,  0, 512,  7, 0, 6, 1, 500, 1, 6, 0						; GATE - WITH ANTI-CLICK RAMP UP AND RAMP DOWN SEGMENTS
giwfn5	ftgen	0,  0, 512,  7, 0, 500, 1, 12, 0							; REVERSE PERCUSSIVE - STRAIGHT SEGMENTS
giwfn6	ftgen	0,  0, 512,  5, 0.001, 500, 1, 12, 0.001					; REVERSE PERCUSSIVE - EXPONENTIAL SEGMENTS

gaRvbSendL	init	0
gaRvbSendR	init	0


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;BUTTONS
		gkgrnd		invalue	"Pointer"
		gkMIDIToPch	invalue	"MIDItoPch"
		gkMIDIToDens	invalue	"MIDItoDens"
		;SLIDERS
		gkamp		invalue	"Amplitude"
		gkdur		invalue	"GrainDuration"
		gkratio		invalue	"PitchRatio"
		gkcps		invalue	"PitchCPS"
		gkfmd		invalue	"PitchRnd"
		gkdens		invalue	"Density"
		gkDensRnd		invalue	"DensityRnd"
		gkampoff		invalue	"AmpOffset"
		gkAtt		invalue	"Attack"
		gkRel		invalue	"Release"
		gkRvbAmt		invalue	"Level"
		gkRvbSize		invalue	"Size"
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
		;grain accept only power of 2 table size
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

instr	1	;GRAIN INSTRUMENT
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

	if p4!=0 &&  gkMIDIToDens=1 then										;IF THIS IS A MIDI ACTIVATED NOTE AND MIDI-TO-DENSITY SWITCH IS ON... 
		kdens	=		kcps											;MAP TO MIDI NOTE VALUE TO GRAIN DENSITY
	else																;OTHERWISE...
		kdens	portk	gkdens,  kporttime								;PORTAMENTO IS APPLIED TO SMOOTH VALUE CHANGES VIA THE GUI SLIDERS
	endif															;END OF THIS CONDITIONAL BRANCH

	if	gkfile_new = 1	then												;test if a new file is loaded by instr 10
		gkfile_new = 0													;flag to zero for next file change
		reinit	START												;REINITIALIZE FROM LABEL 'NEW_FILE1'
	endif

	kSwitch		changed	gkwfn, gksfn, gkgrnd
	if	kSwitch=1	then													;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	START												;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
	endif
	START:
	isfnL 		= 	giFileL											;SOURCE SOUND/WAVEFORM FUNCTION TABLE
	isfnR 		= 	giFileR											;SOURCE SOUND/WAVEFORM FUNCTION TABLE

	if 		i(gksfn)=1 then
		isfnL = gisine
		isfnR = isfnL
	elseif	i(gksfn)=2 then
		isfnL = gibuzz
		isfnR = isfnL
	endif
	iwfn		=		giwfn1 + i(gkwfn)

	kDensRnd 	exprand	gkDensRnd											;CREATE A RANDOM OFFSET FACTOR THAT WILL BE APPLIED TO FOR DENSITY
	kdens	=		kdens * (1 + kDensRnd)								;DENSITY VALUE IS OFFSET BY RANDOM FACTOR
	imgdur	=		1												;MAXIMUM GRAIN DURATION

	if gksfn=0 then													;IF INPUT TABLE FOR GRAINS IS A SOUND FILE...
		kpitch 	=	(sr*kratio)/giftlen2
	else																;OTHERWISE (WAVEFORM)...
		kpitch 	=	kcps
	endif

	;THE AMPLITUDE OFFSET PARAMETER IS MODIFIED TO WHAT I THINK IS A SLIGHTLY MORE USEFUL ARRANGEMENT 
	aSigL	grain 	gkamp, kpitch, kdens, -(gkampoff*gkamp), gkfmd, gkdur, isfnL, iwfn, imgdur , i(gkgrnd)
	aSigR	grain 	gkamp, kpitch, kdens, -(gkampoff*gkamp), gkfmd, gkdur, isfnR, iwfn, imgdur , i(gkgrnd)

			rireturn													;RETURN TO PERFORMANCE TIME PASSES
	aenv		expsegr	0.0001,i(gkAtt),1,i(gkRel),0.0001						;CLOUD AMPLITUDE ENVELOPE
	aSigL	=		aSigL * aenv										;SCALE AUDIO SIGNAL WITH GUI AMPLITUDE SLIDER AND GRAIN CLOUD ENVELOPE
	aSigR	=		aSigR * aenv										;SCALE AUDIO SIGNAL WITH GUI AMPLITUDE SLIDER AND GRAIN CLOUD ENVELOPE

	gaRvbSendL =		gaRvbSendL + (aSigL*gkRvbAmt)							;ADD TO REVERB SEND VARIABLE (LEFT CHANNEL)
	gaRvbSendR =		gaRvbSendR + (aSigR*gkRvbAmt)							;ADD TO REVERB SEND VARIABLE (RIGHT CHANNEL)
			outs 	aSigL, aSigR										;SEND AUDIO TO OUTPUTS
endin

instr	2	;REVERB
	aRvbL,aRvbR	reverbsc	gaRvbSendL, gaRvbSendR, gkRvbSize, 10000
				outs		aRvbL, aRvbR
				clear	gaRvbSendL, gaRvbSendR
endin

instr	3	;INIT
	outvalue	"_SetPresetIndex", 0
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI
i  2		0		3600		;REVERB
i  3	     0.1		0.01		;INIT
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>1036</width>
 <height>543</height>
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
  <height>600</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>grain</label>
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
  <midichan>1</midichan>
  <midicc>2</midicc>
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
  <midichan>1</midichan>
  <midicc>1</midicc>
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
  <midichan>1</midichan>
  <midicc>3</midicc>
  <minimum>1.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>261.62554932</value>
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
  <label>261.626</label>
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
  <value>0.05000000</value>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>318</y>
  <width>500</width>
  <height>80</height>
  <uuid>{b83b9228-3958-46d8-adf5-262b04a121c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb</label>
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
  <label>Level</label>
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
  <objectName>Level</objectName>
  <x>521</x>
  <y>342</y>
  <width>250</width>
  <height>27</height>
  <uuid>{dbdbe7cb-a74d-45b2-9e47-e5c0594f3ea5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Level</objectName>
  <x>711</x>
  <y>365</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
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
  <objectName>Size</objectName>
  <x>961</x>
  <y>365</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.850</label>
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
  <objectName>Size</objectName>
  <x>771</x>
  <y>342</y>
  <width>250</width>
  <height>27</height>
  <uuid>{cb664a0c-f84b-41f5-92e9-7deb5a672d56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.85000002</value>
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
  <label>Size</label>
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
  <label>Density Randomize Amount</label>
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
  <objectName>DensityRnd</objectName>
  <x>8</x>
  <y>293</y>
  <width>500</width>
  <height>27</height>
  <uuid>{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>DensityRnd</objectName>
  <x>448</x>
  <y>316</y>
  <width>60</width>
  <height>26</height>
  <uuid>{95f6cb02-77ec-46fe-876b-a93efac3c5e5}</uuid>
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
  <label>Density</label>
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
  <objectName>Density</objectName>
  <x>8</x>
  <y>251</y>
  <width>500</width>
  <height>27</height>
  <uuid>{475cdd64-a4ca-4ebc-a000-90448e932478}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>4</midicc>
  <minimum>1.00000000</minimum>
  <maximum>500.00000000</maximum>
  <value>20.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Density</objectName>
  <x>448</x>
  <y>274</y>
  <width>60</width>
  <height>26</height>
  <uuid>{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20.000</label>
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
  <label>Pitch Randomization</label>
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
  <objectName>PitchRnd</objectName>
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
  <objectName>PitchRnd</objectName>
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
  <objectName>MIDItoPch</objectName>
  <x>976</x>
  <y>131</y>
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
  <x>856</x>
  <y>127</y>
  <width>120</width>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>MIDItoDens</objectName>
  <x>976</x>
  <y>164</y>
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
  <x>856</x>
  <y>160</y>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>164</y>
  <width>137</width>
  <height>32</height>
  <uuid>{48bd216b-d27b-4396-b997-30ddbe53d173}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Envelope Type</label>
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
  <x>521</x>
  <y>102</y>
  <width>120</width>
  <height>30</height>
  <uuid>{0b39dee5-918a-4abe-b3be-e15ba5222429}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input :</label>
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
  <y>396</y>
  <width>1014</width>
  <height>187</height>
  <uuid>{9c6abfa6-99bf-4a15-94a4-ce86b18f37d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'grain' is an opcode for the creation of granular synthesis clouds of sound. 'grain' does not offer precise control of where grains are read from in the source function table as other opcodes do so it is less suited to time stretching or or time compression tasks. Instead the grain pointer is either static or random across the duration of the input table - this option can be defined using the on-screen GUI button. 'grain' works well for granular synthesis based on a single cycle waveforms and in fact 'grain' offers some options not available with 'grain2' or 'grain3' such as amplitude randomness offset. (grain has a different author to grain2 and grain3.) This example implements many of the feature of the grain3 example, the key difference is the inclusion of single cycle waveforms as source inputs (a sine wave and a 'buzz' waveform). If a sound file is chosen as input grain's pitch input is defined using the 'Pitch CPS' slider (or MIDI note if this option has been selected). If a single cycle waveform has been chosen then pitch is define using the 'Pitch Ratio' slider.
Some GUI sliders are also controllable using MIDI controllers. Details are given on the GUI labels.</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>Pointer</objectName>
  <x>850</x>
  <y>8</y>
  <width>170</width>
  <height>30</height>
  <uuid>{bc32299e-6430-4d2b-b8fc-ab4eca36f66f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  Pointer Random/Static</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>188</x>
  <y>106</y>
  <width>60</width>
  <height>26</height>
  <uuid>{7e9a1f28-a598-4dd0-8df3-8cf7f4dd4316}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CC#1</label>
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
  <x>188</x>
  <y>148</y>
  <width>60</width>
  <height>26</height>
  <uuid>{6725c6e5-73eb-43a9-8f53-64438942c11f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CC#2</label>
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
  <x>188</x>
  <y>190</y>
  <width>60</width>
  <height>26</height>
  <uuid>{0c3d253f-e83e-4b66-b960-9d69b0c27c72}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CC#3</label>
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
  <x>188</x>
  <y>274</y>
  <width>60</width>
  <height>26</height>
  <uuid>{20134265-3566-4ded-8967-6e7d4cc607b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CC#4</label>
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
  <y>358</y>
  <width>220</width>
  <height>26</height>
  <uuid>{f1062244-7bf8-4fe3-bda2-18ee04af46b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude Offset</label>
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
  <objectName>AmpOffset</objectName>
  <x>8</x>
  <y>335</y>
  <width>500</width>
  <height>27</height>
  <uuid>{697ec088-da4a-4253-915b-08873bdc209f}</uuid>
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
  <objectName>AmpOffset</objectName>
  <x>448</x>
  <y>358</y>
  <width>60</width>
  <height>26</height>
  <uuid>{0fa1309e-7470-41eb-81d0-846f17bf4040}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>228</y>
  <width>500</width>
  <height>80</height>
  <uuid>{05dc69b3-743f-477a-8c4c-d0aa7eb2a3ab}</uuid>
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
  <y>274</y>
  <width>180</width>
  <height>30</height>
  <uuid>{0a7a76b5-f94c-47d3-ae11-58981317faae}</uuid>
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
  <y>251</y>
  <width>250</width>
  <height>27</height>
  <uuid>{f7c05650-28ed-43de-a461-54f33d5b1754}</uuid>
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
  <y>274</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c40e0ef2-2a36-4832-ac81-28d31fd7c160}</uuid>
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
  <y>274</y>
  <width>60</width>
  <height>30</height>
  <uuid>{81aea6c7-1dfc-4dec-81b8-02ab9ff4e256}</uuid>
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
  <y>251</y>
  <width>250</width>
  <height>27</height>
  <uuid>{dee81fbc-26d4-499b-a145-6c4a621f37f4}</uuid>
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
  <y>274</y>
  <width>180</width>
  <height>30</height>
  <uuid>{260b7b7f-6914-4c31-8a6f-69dcceac9db2}</uuid>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>521</x>
  <y>122</y>
  <width>170</width>
  <height>30</height>
  <uuid>{3d74c37c-0ed0-4274-b87a-89e80608d9c7}</uuid>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>GrainEnvelope</objectName>
  <x>521</x>
  <y>185</y>
  <width>330</width>
  <height>30</height>
  <uuid>{a77af4e0-33dd-453b-a8a5-f651f099be25}</uuid>
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
<value id="{ecd7a8b0-5bb3-4479-b692-e56294223499}" mode="1" >261.62554932</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="1" >261.62600708</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="4" >261.626</value>
<value id="{d6d73a88-8d82-47de-a067-758f1917a3f2}" mode="1" >0.05000000</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="1" >0.05000000</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="4" >0.050</value>
<value id="{dbdbe7cb-a74d-45b2-9e47-e5c0594f3ea5}" mode="1" >0.10000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="1" >0.10000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="4" >0.100</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="1" >0.85000002</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="4" >0.850</value>
<value id="{cb664a0c-f84b-41f5-92e9-7deb5a672d56}" mode="1" >0.85000002</value>
<value id="{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}" mode="1" >0.00000000</value>
<value id="{95f6cb02-77ec-46fe-876b-a93efac3c5e5}" mode="1" >0.00000000</value>
<value id="{95f6cb02-77ec-46fe-876b-a93efac3c5e5}" mode="4" >0.000</value>
<value id="{475cdd64-a4ca-4ebc-a000-90448e932478}" mode="1" >20.00000000</value>
<value id="{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}" mode="1" >20.00000000</value>
<value id="{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}" mode="4" >20.000</value>
<value id="{2cf97843-5b49-438e-8034-62a459597e86}" mode="1" >0.00000000</value>
<value id="{e54486c5-f9aa-4d0e-9a67-6506dae3c790}" mode="1" >0.00000000</value>
<value id="{e54486c5-f9aa-4d0e-9a67-6506dae3c790}" mode="4" >0.000</value>
<value id="{15cb1c0c-7f3b-4f53-93c1-383a67f11366}" mode="1" >0.00000000</value>
<value id="{15cb1c0c-7f3b-4f53-93c1-383a67f11366}" mode="4" >0</value>
<value id="{6083872a-d937-4f30-ae49-bc3a1cccab54}" mode="1" >0.00000000</value>
<value id="{6083872a-d937-4f30-ae49-bc3a1cccab54}" mode="4" >0</value>
<value id="{bc32299e-6430-4d2b-b8fc-ab4eca36f66f}" mode="1" >0.00000000</value>
<value id="{bc32299e-6430-4d2b-b8fc-ab4eca36f66f}" mode="4" >0</value>
<value id="{697ec088-da4a-4253-915b-08873bdc209f}" mode="1" >0.00000000</value>
<value id="{0fa1309e-7470-41eb-81d0-846f17bf4040}" mode="1" >0.00000000</value>
<value id="{0fa1309e-7470-41eb-81d0-846f17bf4040}" mode="4" >0.000</value>
<value id="{f7c05650-28ed-43de-a461-54f33d5b1754}" mode="1" >0.05000000</value>
<value id="{c40e0ef2-2a36-4832-ac81-28d31fd7c160}" mode="1" >0.05000000</value>
<value id="{c40e0ef2-2a36-4832-ac81-28d31fd7c160}" mode="4" >0.050</value>
<value id="{81aea6c7-1dfc-4dec-81b8-02ab9ff4e256}" mode="1" >0.05000000</value>
<value id="{81aea6c7-1dfc-4dec-81b8-02ab9ff4e256}" mode="4" >0.050</value>
<value id="{dee81fbc-26d4-499b-a145-6c4a621f37f4}" mode="1" >0.05000000</value>
<value id="{3d74c37c-0ed0-4274-b87a-89e80608d9c7}" mode="1" >0.00000000</value>
<value id="{a77af4e0-33dd-453b-a8a5-f651f099be25}" mode="1" >0.00000000</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

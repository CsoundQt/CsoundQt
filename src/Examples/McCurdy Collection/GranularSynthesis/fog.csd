;Written by Iain McCurdy, 2009

;Modified for QuteCsound by René, October 2010, updated Feb 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;An INIT preset is called at the start of csound (inst 3), a valid (mono or stereo) audio file have to be selected and preset 0 saved before playing.

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio files and power of two tables for fog opcode, accept mono or stereo wav files
;	Instrument 1 is activated by MIDI and by the GUI, added pitchbend
;	Removed Recording instr, included in QuteCsound
;	Removed "Instructions and Info Panel" for the gui to fit in a 1200x800 screen

;	                          					  fog
;	-----------------------------------------------------------------------------------------------------------------------------
;	Fog performs granular synthesis upon sound material stored within a GEN 1 function table using a method that bears many
;	simularities to the fof opcode.
;	The amplitude envelope that is applied to each grain is controlled by a combination of the 'Grain Duration' (kdur),
;	'Grain Rise Time' (kris), 'Grain Decay Time' (kdec) and 'Bandwidth (Grain Exponential Decay)' (kband). Bandwidth
;	controls how an exponential curve defined in a separate function is applied to the decay of each grain.
;	'Pointer' (aspd) defines the point from within the stored sound file (range 0-1) that grains will be read.
;	'Density' (kdens) controls the frequency of grain duration in grains per second.
;	'Transposition Factor' (ktrans) controls the transposition of each grain. 1=no transposition. 2=up one octave. 0.5=down one
;	octave and so on... A minus sign indicates that grains will be played backwards, the numerical part functions in the same way.
;	'Transposition Mode' (itmode) is a 2-way switch defining whether transposition modulation is carried out on a grain by
;	grain basis or continually, even within the duration of a grain. To appreciate this effect first create a texture with
;	large sparse grains.
;	'Octaviation Index' (koct) is typically zero but as it tends to 1 every other grain is increasingly attenuated. When it is
;	exactly 1 the grain density is effectively halved. From 1 to 2 the process is repeated and the density is halved again and
;	so on from 2 to 3 and beyond. This effect is perceived quite differently for dense and sparse textures.
;	In this example a controllable amount of portamento is applied to 'Pointer', 'Transposition Factor' and 'Density' in
;	order to allow smoother changes of their values. A random factor can be multiplied to the density control to
;	prevent the tone produced through synchronous reiteration of identical grains. Random factors can simlarly be multiplied
;	to grain pointer location and bandwidth (the consequence of which is grain duration).
;	This instrument can also be activated via MIDI. MIDI pitch values can be mapped to grain density and/or to the pitch of
;	the material contained within the grain. In the latter mapping option, middle C is the point at which no
;	transposition occurs. Using MIDI activation, polyphony is possible.
;	The attack and release times of an amplitude envelope applied to the entire grain cloud can be modulated by the user using
;	two on screen sliders. These controls are probably most useful when triggering this example via MIDI.


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


; CURVE USED TO FORM ATTACK AND DECAY PORTIONS OF EACH GRAIN
;       	    		NUM | INIT_TIME | SIZE | GEN_ROUTINE |  PARTIAL_NUMBER_1 | STRENGTH_1 | PHASE_1 | DC_OFFSET_1
giattdec	ftgen	0,        0,     524288,     19,             0.5,             0.5,        270,         0.5	; I.E. A RISING SIGMOID

giExp400	ftgen	0, 0, 129, -25, 0, 0.5 , 128, 400.0		;TABLE FOR EXP SLIDER
giExp2	ftgen	0, 0, 129, -25, 0, 0.01, 128,   2.0		;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gktransmode		invalue	"TransMode"
		gkMIDIToTrans		invalue	"MIDItoTrans"
		gkMIDIToDens		invalue	"MIDItoDens"

		gkoct			invalue	"Octaviation_Index"
		gktrans			invalue	"Transposition_Factor"
		gkTransRnd		invalue	"Trans_Random"
		kdur				invalue	"Grain_Duration"
		gkdur			tablei	kdur, giExp2, 1
						outvalue	"Grain_Duration_Value", gkdur
		gkris			invalue	"Grain_Rise_Time"
		gkdec			invalue	"Grain_Decay_Time"
		gkband			invalue	"Bandwidth"
		gkamp			invalue	"Amplitude"
		gkporttime		invalue	"Portamento_Amount"
		gkPtrRnd			invalue	"Pointer_Randomness"
		gkDensRnd			invalue	"Density_Randomness"
		gkBwRnd			invalue	"Bandwidth_Randomness"
		gkAtt			invalue	"Attack_Time"
		gkRel			invalue	"Release_Time"

		gkptr			invalue	"X_Pointer"
		kdens			invalue	"Y_Density"
		gkdens			tablei	kdens, giExp400, 1
						outvalue	"Y_Density_Value", gkdens

;AUDIO FILE CHANGE / LOAD IN POWER OF 2 TABLES **********************************************************************************************
;Have put all this stuff in instr 10 to reduce the respons time when playing with midi

		Sfile_new		strcpy	""										;INIT TO EMPTY STRING

		Sfile		invalue	"_Browse1"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	Sfile
		kfile 		strcmpk	Sfile_new, Sfile_old

		gkfile_new	init		0
		if	kfile != 0	then											;IF A BANG HAD BEEN GENERATED IN THE LINE ABOVE
			gkfile_new	=	1										;Flag to inform instr 1 that a new file is loaded
				reinit	NEW_FILE										;REINITIALIZE FROM LABEL 'NEW_FILE'
		endif
		NEW_FILE:
		;fog accept only power of 2 table size
		ifnTemp		ftgentmp	0, 0, 0, 1, Sfile, 0, 0, 1					;Temporary table to get the audio file size
		iftlen		= ftlen(ifnTemp)									;file size
		iftlen2		pow	2, ceil(log(iftlen)/log(2))						;high nearest power of two table size

		;FUNCTION TABLES NUMBERS OF THE SOUND FILE THAT WILL BE GRANULATED
		ichn			filenchnls	Sfile
		if ichn == 1 then
			gifnSoundFileL	ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 1			;READ MONO AUDIO FILE CHANNEL 1
			gifnSoundFileR	=		gifnSoundFileL
		else
			gifnSoundFileL	ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 1			;READ STEREO AUDIO FILE CHANNEL 1
			gifnSoundFileR	ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 2			;READ STEREO AUDIO FILE CHANNEL 2
		endif
		
;*******************************************************************************************************************************************
	endif
endin

instr	1	;FOG INSTRUMENT
	if p4!=0 then													;MIDI
		ioct		=	p4											;READ OCT VALUE FROM MIDI INPUT
		;PITCH BEND=============================================================================================
		iSemitoneBendRange = 12										;PITCH BEND RANGE IN SEMITONES
		imin		= 0												;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333						;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax								;PITCH BEND VARIABLE (IN oct FORMAT)
		kcps		=	cpsoct(ioct + kbend)							;SET FUNDEMENTAL
		;=======================================================================================================
	endif

	kporttime		linseg	0,0.001,1									;CREATE A VARIABLE FUNCTION THAT RAPIDLY RAMPS UP TO A SET VALUE	
	kporttime		=	kporttime * gkporttime							;SLIDER FOR PORTAMENTO TIME MULTIPLIED TO kporttime FUNCTION

	if p4!=0 && gkMIDIToTrans=1 then									;IF THIS IS A MIDI ACTIVATED NOTE AND MIDI-TO-PITCH SWITCH IS ON... 
		ktrans	=		kcps/cpsoct(8)								;MAP TO MIDI NOTE VALUE TO PITCH (CONVERT TO RATIO: MIDDLE C IS POINT OF UNISON)
	else															;OTHERWISE...
		ktrans	portk	gktrans, kporttime							;USE THE SLIDER VALUE
	endif														;END OF THIS CONDITIONAL BRANCH

	if p4!=0 && gkMIDIToDens=1 then									;IF THIS IS A MIDI ACTIVATED NOTE AND MIDI-TO-PITCH SWITCH IS ON... 
		kdens	=		kcps										;MAP TO MIDI NOTE VALUE TO GRAIN DENSITY
	else															;OTHERWISE...
		kdens	portk	gkdens,  kporttime							;PORTAMENTO IS APPLIED TO SMOOTH VALUE CHANGES VIA THE SLIDERS
	endif														;END OF THIS CONDITIONAL BRANCH

	kDensRnd		random	0, gkDensRnd								;DENSITY RANDOMNESS FUNCTION
	kdens		=	kdens * (1 + kDensRnd)							;APPLY RANDOMNESS 	

	kTransRnd		random	-gkTransRnd,gkTransRnd
	ktrans		=	ktrans * (cpsoct(8+kTransRnd)/cpsoct(8))

	ifnRiseDecayShape=	giattdec										;FUNCTION TABLE THAT DEFINES THE SHAPE OF THE ATTACK AND DECAY OF EACH GRAIN

	if	gkfile_new = 1	then											;test if a new file is loaded by instr 10
		gkfile_new	=	0										;flag to zero for next file change
			reinit	NEW_FILE1										;REINITIALIZE FROM LABEL 'NEW_FILE1'
	endif
	NEW_FILE1:
	kPtrRnd	random	-gkPtrRnd,gkPtrRnd								;DETERMINE POINTER RANDOM FACTOR
	kptr		=		gkptr + kPtrRnd								;ADD POINTER RANDOM FACTOR
	kptr		wrap		kptr, 0, 1									;WRAP AROUND OUT OF RANGE POINTER VALUES
	kptr		=		kptr * (nsamp(gifnSoundFileL)/ftlen(gifnSoundFileL))	;KPTR VALUE IS RESCALED TO ACCOUNT FOR UNUSED SAMPLES IN THE FUNCTION TABLE
	
	kBwRnd	random	0,gkBwRnd										;DETERMINE BANDWIDTH RANDOM FACTOR
	kband	=		gkband * (1 + kBwRnd)							;BANDWIDTH RANDOM FACTOR IS APPLIED

	iNumOverLaps	=	2000											;MAXIMUM NUMBER OF OVERLAPS (OVERESTIMATATION IS A GOOD IDEA HERE TO PREVENT CRASHES)
	itotdur		=	3600											;JUST PUT A LARGE NUMBER HERE FOR REAL TIME - FOR NON-REAL TIME GIVE IT p3
	
	kptr		portk	kptr, kporttime								;PORTAMENTO IS APPLIED TO SMOOTH VALUE CHANGES VIA THE SLIDERS
	aptr		interp	kptr											;A NEW A-RATE VARIABLE (aptr) IS CREATED BASE ON kptr

	kSwitch	changed	gktransmode									;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then												;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	START											;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
	endif
	START:
	;                                                                                                                               OPTIONAL->
	aL		fog		gkamp, kdens, ktrans, aptr, gkoct, kband, gkris, gkdur, gkdec,iNumOverLaps, gifnSoundFileL, ifnRiseDecayShape, itotdur, 0, i(gktransmode), 1
	aR		fog		gkamp, kdens, ktrans, aptr, gkoct, kband, gkris, gkdur, gkdec,iNumOverLaps, gifnSoundFileR, ifnRiseDecayShape, itotdur, 0, i(gktransmode), 1

	aenv		expsegr	0.0001,i(gkAtt),1,i(gkRel),0.0001					;CLOUD AMPLITUDE ENVELOPE
	aL		=		aL * aenv										;APPLY AMPLITUDE ENVELOPE
	aR		=		aR * aenv										;APPLY AMPLITUDE ENVELOPE
			rireturn												;RETURN TO PERFORMANCE TIME PASSES
			outs		aL, aR
endin

instr	2	;SETS TRANSPOSITION SLIDER TO UNISON
		outvalue	"Transposition_Factor", 1
endin

instr	3	;INIT
		outvalue	"_SetPresetIndex", 0
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI

i 3	     0.1		 0		;INIT
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>332</x>
 <y>307</y>
 <width>1033</width>
 <height>437</height>
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
  <width>1027</width>
  <height>430</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>fog</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>X_Pointer</objectName>
  <x>84</x>
  <y>170</y>
  <width>424</width>
  <height>254</height>
  <uuid>{2fef8117-9c62-4419-b6e0-45ef9c15647f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Y_Density</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.29952830</xValue>
  <yValue>0.55511808</yValue>
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
  <x>5</x>
  <y>185</y>
  <width>80</width>
  <height>30</height>
  <uuid>{30475d51-935d-4644-ba93-d6629f3be4d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>X - Pointer</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>X_Pointer</objectName>
  <x>25</x>
  <y>215</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6aac1f5d-f8dd-4e66-a987-3203fd01550f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.300</label>
  <alignment>center</alignment>
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
  <objectName>Y_Density_Value</objectName>
  <x>26</x>
  <y>301</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ee3fa20e-dea1-4af9-97d7-f7ba52bdd47c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20.444</label>
  <alignment>center</alignment>
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
  <x>6</x>
  <y>272</y>
  <width>80</width>
  <height>30</height>
  <uuid>{653f7154-d6f2-44e6-8ea9-eacbd5ac2206}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Y - Density</label>
  <alignment>center</alignment>
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
  <x>522</x>
  <y>64</y>
  <width>180</width>
  <height>30</height>
  <uuid>{8d67138b-037d-461e-8a25-108f849b03c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Octaviation Index</label>
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
  <objectName>Octaviation_Index</objectName>
  <x>522</x>
  <y>41</y>
  <width>500</width>
  <height>27</height>
  <uuid>{273087bd-e04a-4975-a3bd-5b0a8b5fd40a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>4.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Octaviation_Index</objectName>
  <x>962</x>
  <y>64</y>
  <width>60</width>
  <height>30</height>
  <uuid>{04617e86-7abe-4120-bb9b-1d6ccd2f0983}</uuid>
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
  <x>522</x>
  <y>106</y>
  <width>180</width>
  <height>30</height>
  <uuid>{2c02703f-de38-40de-bc69-7c787c5a13b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Transposition Factor</label>
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
  <objectName>Transposition_Factor</objectName>
  <x>522</x>
  <y>83</y>
  <width>250</width>
  <height>27</height>
  <uuid>{513ad202-18da-4809-8de3-7ddf8934ab6f}</uuid>
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
  <objectName>Transposition_Factor</objectName>
  <x>712</x>
  <y>106</y>
  <width>60</width>
  <height>30</height>
  <uuid>{530115a7-4f85-423e-99b4-263da41530d9}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Trans_Random</objectName>
  <x>962</x>
  <y>106</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bc7ab1c8-85da-4714-889e-9a193e4c685c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.128</label>
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
  <objectName>Trans_Random</objectName>
  <x>772</x>
  <y>83</y>
  <width>250</width>
  <height>27</height>
  <uuid>{c4ac15bd-d639-4a18-834e-ece88a35c131}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.12800001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>772</x>
  <y>106</y>
  <width>180</width>
  <height>30</height>
  <uuid>{4e98b9a0-55c5-4aef-b473-1d0b761def5d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Transposition Random</label>
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
  <objectName>TransMode</objectName>
  <x>8</x>
  <y>69</y>
  <width>150</width>
  <height>30</height>
  <uuid>{6ebe0e67-d0ca-49fd-a0d9-32b697a0edf6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Grain by Grain</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Continuous</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>210</x>
  <y>65</y>
  <width>180</width>
  <height>30</height>
  <uuid>{8076c47e-867b-4e8a-95a9-c1772cb80c76}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Portamento Amount</label>
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
  <objectName>Portamento_Amount</objectName>
  <x>210</x>
  <y>41</y>
  <width>300</width>
  <height>27</height>
  <uuid>{8dcbe622-f7e5-4530-906d-8d6aa856447d}</uuid>
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
  <objectName>Portamento_Amount</objectName>
  <x>450</x>
  <y>65</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e5491687-e126-474a-960e-2766ba77fd36}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>MIDItoTrans</objectName>
  <x>367</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{436e46c5-37b6-49af-acef-33f5e00d9103}</uuid>
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
  <objectName>MIDItoDens</objectName>
  <x>494</x>
  <y>98</y>
  <width>16</width>
  <height>16</height>
  <uuid>{51ecf2a3-121a-4a0d-ab70-927ecf226c69}</uuid>
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
  <x>386</x>
  <y>95</y>
  <width>107</width>
  <height>30</height>
  <uuid>{1a69252b-465f-4ed7-9476-96031257eff6}</uuid>
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
  <x>246</x>
  <y>95</y>
  <width>120</width>
  <height>30</height>
  <uuid>{01925294-4552-42e4-9703-fd80721fb15d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI to Transposition</label>
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
  <objectName>_Browse1</objectName>
  <x>6</x>
  <y>133</y>
  <width>170</width>
  <height>30</height>
  <uuid>{1757a18f-b418-4ef1-984d-bdee5e985805}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>ClassicalGuitar.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>177</x>
  <y>134</y>
  <width>330</width>
  <height>28</height>
  <uuid>{804f4f24-03f1-4ac2-8ba2-697f15df06cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ClassicalGuitar.wav</label>
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
  <y>112</y>
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
  <y>48</y>
  <width>141</width>
  <height>30</height>
  <uuid>{942cd7e3-7e3c-4329-a2c5-0c58c18c92f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Transposition Mode</label>
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
  <x>522</x>
  <y>148</y>
  <width>180</width>
  <height>30</height>
  <uuid>{93f3e274-799d-49e8-9392-4d8c6ad43ae2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Duration</label>
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
  <objectName>Grain_Duration</objectName>
  <x>522</x>
  <y>125</y>
  <width>500</width>
  <height>27</height>
  <uuid>{89741b38-8333-4828-b8b8-656cff90d564}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.43399999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Grain_Duration_Value</objectName>
  <x>962</x>
  <y>148</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>190</y>
  <width>180</width>
  <height>30</height>
  <uuid>{c477956e-c0ae-4443-b2a2-2803dc72675d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Rise Time</label>
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
  <objectName>Grain_Rise_Time</objectName>
  <x>522</x>
  <y>167</y>
  <width>250</width>
  <height>27</height>
  <uuid>{b7a6264a-85ce-44c6-912c-79f97f9c0438}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.20000000</maximum>
  <value>0.00975600</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Grain_Rise_Time</objectName>
  <x>712</x>
  <y>190</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fbb46c2d-6796-4219-b7a6-cc1ac14fe06d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.010</label>
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
  <objectName>Grain_Decay_Time</objectName>
  <x>962</x>
  <y>190</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dd67952d-a404-436b-8b6b-059d2e045177}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.010</label>
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
  <objectName>Grain_Decay_Time</objectName>
  <x>772</x>
  <y>167</y>
  <width>250</width>
  <height>27</height>
  <uuid>{25a7c11d-88d3-4c17-b1dd-d8711549b868}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.20000000</maximum>
  <value>0.00975600</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>772</x>
  <y>190</y>
  <width>180</width>
  <height>30</height>
  <uuid>{19201594-5781-4b62-8e65-3fc781995272}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Decay Time</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>653</x>
  <y>104</y>
  <width>60</width>
  <height>18</height>
  <uuid>{b19b7b33-b8aa-418a-87c7-c4ddac31fa91}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Unison</text>
  <image>/</image>
  <eventLine>i 2 0 0</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>232</y>
  <width>220</width>
  <height>30</height>
  <uuid>{9d200fd9-5a42-4f87-89ab-14ef5ac064ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandwidth (Grain Exponential Decay)</label>
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
  <objectName>Bandwidth</objectName>
  <x>522</x>
  <y>209</y>
  <width>500</width>
  <height>27</height>
  <uuid>{ecd7a8b0-5bb3-4479-b692-e56294223499}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>10.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Bandwidth</objectName>
  <x>962</x>
  <y>232</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f275c8fd-3605-49e8-9090-67ca5f21a9f6}</uuid>
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
  <x>522</x>
  <y>274</y>
  <width>180</width>
  <height>30</height>
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
  <x>522</x>
  <y>251</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d6d73a88-8d82-47de-a067-758f1917a3f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amplitude</objectName>
  <x>962</x>
  <y>274</y>
  <width>60</width>
  <height>30</height>
  <uuid>{073ad371-9227-46fa-a005-ac10a210db79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.200</label>
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
  <x>522</x>
  <y>316</y>
  <width>165</width>
  <height>30</height>
  <uuid>{413875db-1edf-4539-a48c-88a7383d05d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer Randomness</label>
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
  <objectName>Pointer_Randomness</objectName>
  <x>522</x>
  <y>293</y>
  <width>165</width>
  <height>27</height>
  <uuid>{ba02bcd6-e35d-47ad-bd59-85fad031ff58}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>689</x>
  <y>316</y>
  <width>165</width>
  <height>30</height>
  <uuid>{5df757ba-9e72-4f16-88d9-be4628916fa1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Density Randomness</label>
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
  <objectName>Density_Randomness</objectName>
  <x>689</x>
  <y>293</y>
  <width>165</width>
  <height>27</height>
  <uuid>{b3318f74-1f15-4f2e-a4af-3377eda94fd1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>856</x>
  <y>316</y>
  <width>165</width>
  <height>30</height>
  <uuid>{a50ed81d-3863-4375-88a6-04642daf5af5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandwidth Randomness</label>
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
  <objectName>Bandwidth_Randomness</objectName>
  <x>856</x>
  <y>293</y>
  <width>165</width>
  <height>27</height>
  <uuid>{9a48da69-c3f9-4d43-b89c-d0fc159e0710}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>344</y>
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
  <x>522</x>
  <y>390</y>
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
  <objectName>Attack_Time</objectName>
  <x>522</x>
  <y>367</y>
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
  <objectName>Attack_Time</objectName>
  <x>712</x>
  <y>390</y>
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
  <objectName>Release_Time</objectName>
  <x>962</x>
  <y>390</y>
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
  <objectName>Release_Time</objectName>
  <x>772</x>
  <y>367</y>
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
  <x>772</x>
  <y>390</y>
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
</bsbPanel>
<bsbPresets>
<preset name="INIT" number="0" >
<value id="{2fef8117-9c62-4419-b6e0-45ef9c15647f}" mode="1" >0.29952830</value>
<value id="{2fef8117-9c62-4419-b6e0-45ef9c15647f}" mode="2" >0.55511808</value>
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="1" >0.00000000</value>
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="4" >0</value>
<value id="{6aac1f5d-f8dd-4e66-a987-3203fd01550f}" mode="1" >0.30000001</value>
<value id="{6aac1f5d-f8dd-4e66-a987-3203fd01550f}" mode="4" >0.300</value>
<value id="{ee3fa20e-dea1-4af9-97d7-f7ba52bdd47c}" mode="1" >20.44374847</value>
<value id="{ee3fa20e-dea1-4af9-97d7-f7ba52bdd47c}" mode="4" >20.444</value>
<value id="{273087bd-e04a-4975-a3bd-5b0a8b5fd40a}" mode="1" >0.00000000</value>
<value id="{04617e86-7abe-4120-bb9b-1d6ccd2f0983}" mode="1" >0.00000000</value>
<value id="{04617e86-7abe-4120-bb9b-1d6ccd2f0983}" mode="4" >0.000</value>
<value id="{513ad202-18da-4809-8de3-7ddf8934ab6f}" mode="1" >1.00000000</value>
<value id="{530115a7-4f85-423e-99b4-263da41530d9}" mode="1" >1.00000000</value>
<value id="{530115a7-4f85-423e-99b4-263da41530d9}" mode="4" >1.000</value>
<value id="{bc7ab1c8-85da-4714-889e-9a193e4c685c}" mode="1" >0.12800001</value>
<value id="{bc7ab1c8-85da-4714-889e-9a193e4c685c}" mode="4" >0.128</value>
<value id="{c4ac15bd-d639-4a18-834e-ece88a35c131}" mode="1" >0.12800001</value>
<value id="{6ebe0e67-d0ca-49fd-a0d9-32b697a0edf6}" mode="1" >0.00000000</value>
<value id="{8dcbe622-f7e5-4530-906d-8d6aa856447d}" mode="1" >0.10000000</value>
<value id="{e5491687-e126-474a-960e-2766ba77fd36}" mode="1" >0.10000000</value>
<value id="{e5491687-e126-474a-960e-2766ba77fd36}" mode="4" >0.100</value>
<value id="{436e46c5-37b6-49af-acef-33f5e00d9103}" mode="1" >0.00000000</value>
<value id="{436e46c5-37b6-49af-acef-33f5e00d9103}" mode="4" >0</value>
<value id="{51ecf2a3-121a-4a0d-ab70-927ecf226c69}" mode="1" >0.00000000</value>
<value id="{51ecf2a3-121a-4a0d-ab70-927ecf226c69}" mode="4" >0</value>
<value id="{1757a18f-b418-4ef1-984d-bdee5e985805}" mode="4" >ClassicalGuitar.wav</value>
<value id="{804f4f24-03f1-4ac2-8ba2-697f15df06cf}" mode="4" >ClassicalGuitar.wav</value>
<value id="{89741b38-8333-4828-b8b8-656cff90d564}" mode="1" >0.43399999</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="1" >0.09970991</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="4" >0.100</value>
<value id="{b7a6264a-85ce-44c6-912c-79f97f9c0438}" mode="1" >0.00975600</value>
<value id="{fbb46c2d-6796-4219-b7a6-cc1ac14fe06d}" mode="1" >0.01000000</value>
<value id="{fbb46c2d-6796-4219-b7a6-cc1ac14fe06d}" mode="4" >0.010</value>
<value id="{dd67952d-a404-436b-8b6b-059d2e045177}" mode="1" >0.01000000</value>
<value id="{dd67952d-a404-436b-8b6b-059d2e045177}" mode="4" >0.010</value>
<value id="{25a7c11d-88d3-4c17-b1dd-d8711549b868}" mode="1" >0.00975600</value>
<value id="{b19b7b33-b8aa-418a-87c7-c4ddac31fa91}" mode="4" >0</value>
<value id="{ecd7a8b0-5bb3-4479-b692-e56294223499}" mode="1" >10.00000000</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="1" >10.00000000</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="4" >10.000</value>
<value id="{d6d73a88-8d82-47de-a067-758f1917a3f2}" mode="1" >0.20000000</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="1" >0.20000000</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="4" >0.200</value>
<value id="{ba02bcd6-e35d-47ad-bd59-85fad031ff58}" mode="1" >0.00000000</value>
<value id="{b3318f74-1f15-4f2e-a4af-3377eda94fd1}" mode="1" >0.00000000</value>
<value id="{9a48da69-c3f9-4d43-b89c-d0fc159e0710}" mode="1" >0.00000000</value>
<value id="{dbdbe7cb-a74d-45b2-9e47-e5c0594f3ea5}" mode="1" >0.05000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="1" >0.05000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="4" >0.050</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="1" >0.05000000</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="4" >0.050</value>
<value id="{cb664a0c-f84b-41f5-92e9-7deb5a672d56}" mode="1" >0.05000000</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

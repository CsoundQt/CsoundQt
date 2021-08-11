;Written by Iain McCurdy, 2006

;Modified for QuteCsound by René, October 2010, updated Feb 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;An INIT preset is called at the start of csound (inst 2), a valid (mono or stereo) audio file have to be selected and preset 0 saved before playing.

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio files and power of two tables for sndwarp opcode, accept mono or stereo wav files
;	Instrument 1 is activated by MIDI and by the GUI
;	Removed Recording instrument, included in QuteCsound
;	Removed "Instructions and Info Panel" for the gui to fit in a 1200x800 screen

;	                          sndwarp
;	---------------------------------------------------------------------------------------------------------------
;	sndwarp performs granular synthesis upon a stored function table by employing either a timestretch (as in the
;	'granule' opcode) or by making use of a time pointer (as in 'pvoc').
;	The user can select between these two modes using sndwarp's 'itimemode' input argument. Giving 'itimemode' a
;	value of zero means that a time stretching factor will be applied, giving it a value of 1 means that a pointer
;	variable will be used to define from where within the source file grains begin. On account of sndwarp's dual
;	function nature, its input argument 'xtimewarp' can mean two different things dependant upon the value of
;	'itimemode'. When itimemode=0 'xtimewarp' defines the time-stretch factor, when itimemode=1 'xtimewarp' defines
;	the pointer location in seconds.
;	For convenience in this example 'xtimewarp' is represented by two different sliders, 'Pointer' and 'Stretch Factor'.
;	The appropriate slider will be chosen by the code for the value of 'xtimewarp' depending upon the current setting
;	for the 'Warp/Pointer' switch. Therefore when the switch is on 'Warp' the 'Pointer' slider has no effect (and vice
;	versa). Instead of defining grain sizes in seconds 'sndwarp' refers to grains as 'windows'. In effect, grain size
;	is defined in samples using the 'Window Size' slider (iwsize). The 'Randomization' slider (irandw) applies
;	randomization to the value for 'Window Size' (iwsize). This value defines the bandwidth of a random number generator.
;	The random numbers will be added to 'Window Size' (iwsize). The density of the granular synthesis texture produced
;	is controlled using the 'Number of Overlaps' (ioverlap) parameter.
;	The pitch of the granular synthesis texture produced can be rescaled using the 'Pitch' slider (xresample).
;	1=no transposition, 2=up one octave, 0.5=down one octave and so on.
;	The user must supply a windowing function via a function table that the opcode will use to apply an amplitude envelope
;	to each grain. In this example six different envelope types are offered for experimentation. Descriptions of the
;	different types on offer are included on the main panel. To hear most clearly the effect of using different grain
;	envelopes set 'Number of Overlaps' to a 1 value and set 'Window Size' to a large number.
;	'Inskip into Source Sound File' (ibeg) allows the user to define where the opcode will begin reading grains from. If
;	this value is zero 'sndwarp' will begin reading grains from the beginning of the source sound file.
;	The attack and release times of an amplitude envelope applied to the entire grain cloud can be modulated by the user
;	using two on screen sliders. These controls are probably most useful when triggering this example via MIDI.


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 1		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


;GRAIN ENVELOPE WINDOW FUNCTION TABLES:
giwfn1	ftgen	0,  0, 131072,  9,   .5, 1, 	0 						; HALF SINE
giwfn2	ftgen	0,  0, 131072,  7,    0, 3072,  1, 128000,     0			; PERCUSSIVE - STRAIGHT SEGMENTS
giwfn3	ftgen	0,  0, 131072,  5, .001, 3072,  1, 128000, 0.001			; PERCUSSIVE - EXPONENTIAL SEGMENTS
giwfn4	ftgen	0,  0, 131072,  7,    0, 1536,  1, 128000, 1, 1536, 0		; GATE - WITH ANTI-CLICK RAMP UP AND RAMP DOWN SEGMENTS
giwfn5	ftgen	0,  0, 131072,  7,    0, 128000,1, 3072,  0				; REVERSE PERCUSSIVE - STRAIGHT SEGMENTS
giwfn6	ftgen	0,  0, 131072,  5, .001, 128000,1, 3072,   0.001			; REVERSE PERCUSSIVE - EXPONENTIAL SEGMENTS

;TABLE FOR EXP SLIDER
giExp8	ftgen	0, 0, 129, -25, 0,  0.01, 128, 8.0


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkolap		invalue	"Overlaps"
		gkmode		invalue	"Mode"
		gkwfn		invalue	"Grain_Envelope"
		gkMIDItoWindow	invalue	"MtoWindow"
		gkMIDItoPitch	invalue	"MtoPitch"

		gkamp		invalue	"Amplitude"
		gkptr		invalue	"Pointer"
		gkstretch		invalue	"Stretch_Factor"
		kpch			invalue	"Pitch"
		gkpch		tablei	kpch, giExp8, 1
					outvalue	"Pitch_Value", gkpch
		gkwsize		invalue	"Window_Size"
		gkrnd		invalue	"Rnd_Factor"
		gkbeg		invalue	"Inskip"
		gkporttime	invalue	"Portamento"
		gkAtt		invalue	"Attack_Time"
		gkRel		invalue	"Release_Time"

;AUDIO FILE CHANGE / LOAD IN POWER OF 2 TABLES **********************************************************************************************
;Have put all this stuff in instr 10 to reduce the respons time when playing with midi

		Sfile_new		strcpy	""											;INIT TO EMPTY STRING

		Sfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	Sfile
		kfile 		strcmpk	Sfile_new, Sfile_old

		gkfile_new	init		0
		if	kfile != 0	then												;IF A BANG HAD BEEN GENERATED IN THE LINE ABOVE
			gkfile_new	=	1											;Flag to inform instr 1 that a new file is loaded
				reinit	NEW_FILE											;REINITIALIZE FROM LABEL 'NEW_FILE'
		endif
		NEW_FILE:
		;sndwarp accept only power of 2 table size
		ifnTemp		ftgentmp	0, 0, 0, 1, Sfile, 0, 0, 1						;Temporary table to get the audio file size
		iftlen		= ftlen(ifnTemp)										;file size
		iftlen2		pow	2, ceil(log(iftlen)/log(2))							;high nearest power of two table size

		;FUNCTION TABLES NUMBERS OF THE SOUND FILE THAT WILL BE GRANULATED
		ichn			filenchnls	Sfile
		if ichn == 1 then
			giFileL	ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 1					;READ MONO AUDIO FILE CHANNEL 1
			giFileR	=		giFileL
		else
			giFileL	ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 1					;READ STEREO AUDIO FILE CHANNEL 1
			giFileR	ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 2					;READ STEREO AUDIO FILE CHANNEL 2
		endif
		
;*******************************************************************************************************************************************
	endif
endin

instr	1	;SNDWARP INSTRUMENT
	if p4!=0 then															;MIDI
		ioct		=	p4													;READ OCT VALUE FROM MIDI INPUT
		icps		=	cpsoct(ioct)											;CONVERT TO CPS
		;PITCH BEND============================================================================================================
		iSemitoneBendRange = 12												;PITCH BEND RANGE IN SEMITONES
		imin		= 0														;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333								;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax										;PITCH BEND VARIABLE (IN oct FORMAT)
		kcps		=	cpsoct(ioct + kbend)									;SET FUNDAMENTAL
		;=======================================================================================================================
	endif

	iporttime 	= 		.1												;PORTAMENTO TIME
	kporttime		linseg	0,.1,iporttime										;USE OF A RAMPING UP ENVELOPE PREVENTS GLIDING PARAMETERS EACH TIME A NOTE IS RESTARTED
	kporttime		=		kporttime * gkporttime								;GUI SLIDER FOR PORTAMENTO TIME MULTIPLIED TO kporttime FUNCTION	kporttime	linseg	0,0.001,0.1									;CREATE A VARIABLE FUNCTION THAT RAPIDLY RAMPS UP TO A SET VALUE	


	if p4!=0 && gkMIDItoPitch=1 then											;IF THIS IS A MIDI ACTIVATED NOTE AND MIDI-TO-PITCH SWITCH IS ON... 
		kpch		=		kcps/cpsoct(8)										;MAP TO MIDI NOTE VALUE TO PITCH (CONVERT TO RATIO: MIDDLE C IS POINT OF UNISON)
	else																	;OTHERWISE...
		kpch		portk	gkpch, kporttime									;USE THE SLIDER VALUE
	endif																;END OF THIS CONDITIONAL BRANCH

	if p4!=0 && i(gkMIDItoWindow)=1 then										;IF THIS IS A MIDI ACTIVATED NOTE AND MIDI-TO-PITCH SWITCH IS ON... 
		iwsize	=	sr/icps
	else																	;OTHERWISE...
		iwsize	=	i(gkwsize)											;WINDOW SIZE (CONVERTED TO I-RATE)
	endif																;END OF THIS CONDITIONAL BRANCH

	kptr		portk	gkptr,kporttime										;PORTAMENTO APPLIED TO PARAMETER TO SMOOTH CHANGES
	kamp		portk	gkamp,kporttime										;PORTAMENTO APPLIED TO PARAMETER TO SMOOTH CHANGES

	if	gkfile_new = 1	then													;test if a new file is loaded by instr 10
		gkfile_new	=	0												;flag to zero for next file change
			reinit	START												;REINITIALIZE FROM LABEL 'NEW_FILE1'
	endif

	kSwitch	changed	gkolap, gkmode, gkwsize, gkrnd, gkwfn, gkbeg
	if	kSwitch=1	then
		reinit	START
	endif

	START:
	iwfn 	= 		giwfn1 + i(gkwfn)										;WINDOW FUNCTION
	ilen 	= 		nsamp(giFileL) / sr										;DURATION (IN SECONDS) OF THE SOURCE SOUND FILE IS DERIVED
	imode 	= 		i(gkmode) 											;ENTER WARP MODE: 1=POINTER / 0=PLAYBACK SPEED WARP
	ibeg 	= 		i(gkbeg)												;INSKIP (0=BEGINNING OF FILE)
	iolap 	= 		i(gkolap)												;NUMBER OF OVERLAPS (CONVERTED TO I-RATE)
	kptr	 	=		kptr*ilen												;DERIVE POINTER POSITION RELATIVE TO THE ACTUAL DURATION OF THE FILE USED
	irnd		=		i(gkrnd)												;RANDOMIZATION OF WINDOW SIZE
	kwarp	=		(imode == 0 ? gkstretch : kptr )							;CHOOSE WHETHER TO USE 'STRETCH FACTOR' OR 'POINTER POSITION' ACCORDING TO THE STATUS OF 'imode'
	asigL 	sndwarp	kamp, kwarp, kpch, giFileL, ibeg, iwsize, irnd, iolap, iwfn, imode
	asigR 	sndwarp	kamp, kwarp, kpch, giFileR, ibeg, iwsize, irnd, iolap, iwfn, imode
			rireturn
	aenv		expsegr	0.0001,i(gkAtt),1,i(gkRel),0.0001							; CLOUD AMPLITUDE ENVELOPE
	asigL	=		asigL * aenv											;APPLY AMPLITUDE ENVELOPE
	asigR	=		asigR * aenv											;APPLY AMPLITUDE ENVELOPE
			outs 	asigL, asigR											;SEND AUDIO TO OUTPUTS
endin

instr	2	;INIT
;		Sfilename invalue "_Browse"
		outvalue	"_SetPresetIndex", 0
;		outvalue "_Browse", Sfilename
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI

i 2	     0.1		 0		;INIT
</CsScore>
</CsoundSynthesizer>





<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>495</width>
 <height>446</height>
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
  <width>1030</width>
  <height>395</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>sndwarp</label>
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
  <height>30</height>
  <uuid>{8d67138b-037d-461e-8a25-108f849b03c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Stretch Factor</label>
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
  <objectName>Stretch_Factor</objectName>
  <x>8</x>
  <y>125</y>
  <width>500</width>
  <height>27</height>
  <uuid>{273087bd-e04a-4975-a3bd-5b0a8b5fd40a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>50.00000000</maximum>
  <value>5.01800013</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Stretch_Factor</objectName>
  <x>448</x>
  <y>148</y>
  <width>60</width>
  <height>30</height>
  <uuid>{04617e86-7abe-4120-bb9b-1d6ccd2f0983}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.018</label>
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
  <x>771</x>
  <y>143</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2c02703f-de38-40de-bc69-7c787c5a13b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mode</label>
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
  <x>549</x>
  <y>203</y>
  <width>144</width>
  <height>30</height>
  <uuid>{4e98b9a0-55c5-4aef-b473-1d0b761def5d}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>521</x>
  <y>77</y>
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
  <objectName>_Browse</objectName>
  <x>691</x>
  <y>78</y>
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
   <r>240</r>
   <g>235</g>
   <b>226</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>56</y>
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
  <height>30</height>
  <uuid>{93f3e274-799d-49e8-9392-4d8c6ad43ae2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer  (Portamento Applied)</label>
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
  <objectName>Pointer</objectName>
  <x>8</x>
  <y>83</y>
  <width>500</width>
  <height>27</height>
  <uuid>{89741b38-8333-4828-b8b8-656cff90d564}</uuid>
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
  <objectName>Pointer</objectName>
  <x>448</x>
  <y>106</y>
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
  <x>8</x>
  <y>190</y>
  <width>180</width>
  <height>30</height>
  <uuid>{9d200fd9-5a42-4f87-89ab-14ef5ac064ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch (Portamento Applied)</label>
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
  <objectName>Pitch</objectName>
  <x>8</x>
  <y>167</y>
  <width>500</width>
  <height>27</height>
  <uuid>{ecd7a8b0-5bb3-4479-b692-e56294223499}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.69000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch_Value</objectName>
  <x>448</x>
  <y>190</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f275c8fd-3605-49e8-9090-67ca5f21a9f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.008</label>
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
  <width>200</width>
  <height>30</height>
  <uuid>{5cde19f3-b356-4945-9c8b-43dd67c604dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude  (Portamento Applied)</label>
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
  <value>0.30000001</value>
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
  <height>30</height>
  <uuid>{073ad371-9227-46fa-a005-ac10a210db79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.300</label>
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
  <x>516</x>
  <y>312</y>
  <width>510</width>
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
  <y>358</y>
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
  <x>521</x>
  <y>335</y>
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
  <x>711</x>
  <y>358</y>
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
  <x>961</x>
  <y>358</y>
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
  <x>771</x>
  <y>335</y>
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
  <y>358</y>
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
  <width>200</width>
  <height>30</height>
  <uuid>{b6afbe1e-677c-44a6-ba84-4c32dc21b0a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Inskip into Source Sound File (i-rate)</label>
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
  <objectName>Inskip</objectName>
  <x>8</x>
  <y>293</y>
  <width>500</width>
  <height>27</height>
  <uuid>{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}</uuid>
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
  <objectName>Inskip</objectName>
  <x>448</x>
  <y>316</y>
  <width>60</width>
  <height>30</height>
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
  <height>30</height>
  <uuid>{7fd47947-fd0d-4964-85e5-682fed1916c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Randomization Factor (i-rate)</label>
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
  <objectName>Rnd_Factor</objectName>
  <x>8</x>
  <y>251</y>
  <width>500</width>
  <height>27</height>
  <uuid>{475cdd64-a4ca-4ebc-a000-90448e932478}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10000.00000000</maximum>
  <value>1040.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Rnd_Factor</objectName>
  <x>448</x>
  <y>274</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1040.000</label>
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
  <y>358</y>
  <width>180</width>
  <height>30</height>
  <uuid>{1b53998a-9e9e-4067-8cee-83fc9f2f657b}</uuid>
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
  <objectName>Portamento</objectName>
  <x>8</x>
  <y>336</y>
  <width>500</width>
  <height>27</height>
  <uuid>{4bea56a5-96d7-49d0-90a1-6d1dd17fc584}</uuid>
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
  <objectName>Portamento</objectName>
  <x>448</x>
  <y>358</y>
  <width>60</width>
  <height>30</height>
  <uuid>{225c97bc-f9f0-4085-94c4-f8de353f00cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
  <width>200</width>
  <height>30</height>
  <uuid>{3ebc1139-1fdb-48dc-9150-49ee8dfdbd4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Window Size (i-rate)</label>
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
  <objectName>Window_Size</objectName>
  <x>8</x>
  <y>209</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2cf97843-5b49-438e-8034-62a459597e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>40000.00000000</maximum>
  <value>1520.96203613</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Window_Size</objectName>
  <x>448</x>
  <y>232</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e54486c5-f9aa-4d0e-9a67-6506dae3c790}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1520.962</label>
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
  <x>569</x>
  <y>146</y>
  <width>122</width>
  <height>29</height>
  <uuid>{8322197a-01c9-4350-b669-63dd23fe5fda}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number of Overlaps</label>
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
  <objectName>Overlaps</objectName>
  <x>691</x>
  <y>145</y>
  <width>60</width>
  <height>25</height>
  <uuid>{12cbf581-99ac-47fd-bf47-4ab1d06ec56a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
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
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Mode</objectName>
  <x>872</x>
  <y>139</y>
  <width>150</width>
  <height>30</height>
  <uuid>{528fc6d0-de84-40d0-80d2-9dd8b4e02a0b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Warp</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pointer</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Grain_Envelope</objectName>
  <x>693</x>
  <y>200</y>
  <width>330</width>
  <height>30</height>
  <uuid>{5041c02a-c619-488c-8631-a3f9e1dab457}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Half Sine</name>
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
  <x>516</x>
  <y>260</y>
  <width>510</width>
  <height>50</height>
  <uuid>{f083eb01-c7ae-40f6-9ac6-d7b32117fedd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI Notes</label>
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
  <x>591</x>
  <y>271</y>
  <width>100</width>
  <height>28</height>
  <uuid>{9f6f0612-5f3c-4a18-9f40-6fb9ece10c64}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>to Window</label>
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
  <x>723</x>
  <y>274</y>
  <width>100</width>
  <height>28</height>
  <uuid>{18bdb5ba-84f0-4561-8771-6792fe1b971f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>to Pitch</label>
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
  <objectName>MtoWindow</objectName>
  <x>697</x>
  <y>273</y>
  <width>16</width>
  <height>16</height>
  <uuid>{c64b625e-c396-4f39-89fb-9c21b77affdd}</uuid>
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
  <objectName>MtoPitch</objectName>
  <x>830</x>
  <y>275</y>
  <width>16</width>
  <height>16</height>
  <uuid>{cdf66a23-91bd-4fe3-987f-dfc531c78348}</uuid>
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
</bsbPanel>
<bsbPresets>
<preset name="INIT" number="0" >
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="1" >0.00000000</value>
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="4" >0</value>
<value id="{273087bd-e04a-4975-a3bd-5b0a8b5fd40a}" mode="1" >5.01800013</value>
<value id="{04617e86-7abe-4120-bb9b-1d6ccd2f0983}" mode="1" >5.01800013</value>
<value id="{04617e86-7abe-4120-bb9b-1d6ccd2f0983}" mode="4" >5.018</value>
<value id="{1757a18f-b418-4ef1-984d-bdee5e985805}" mode="4" >ClassicalGuitar.wav</value>
<value id="{804f4f24-03f1-4ac2-8ba2-697f15df06cf}" mode="4" >ClassicalGuitar.wav</value>
<value id="{89741b38-8333-4828-b8b8-656cff90d564}" mode="1" >0.10000000</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="1" >0.10000000</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="4" >0.100</value>
<value id="{ecd7a8b0-5bb3-4479-b692-e56294223499}" mode="1" >0.69000000</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="1" >1.00800002</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="4" >1.008</value>
<value id="{d6d73a88-8d82-47de-a067-758f1917a3f2}" mode="1" >0.30000001</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="1" >0.30000001</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="4" >0.300</value>
<value id="{dbdbe7cb-a74d-45b2-9e47-e5c0594f3ea5}" mode="1" >0.05000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="1" >0.05000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="4" >0.050</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="1" >0.05000000</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="4" >0.050</value>
<value id="{cb664a0c-f84b-41f5-92e9-7deb5a672d56}" mode="1" >0.05000000</value>
<value id="{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}" mode="1" >0.00000000</value>
<value id="{95f6cb02-77ec-46fe-876b-a93efac3c5e5}" mode="1" >0.00000000</value>
<value id="{95f6cb02-77ec-46fe-876b-a93efac3c5e5}" mode="4" >0.000</value>
<value id="{475cdd64-a4ca-4ebc-a000-90448e932478}" mode="1" >1040.00000000</value>
<value id="{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}" mode="1" >1040.00000000</value>
<value id="{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}" mode="4" >1040.000</value>
<value id="{4bea56a5-96d7-49d0-90a1-6d1dd17fc584}" mode="1" >0.50000000</value>
<value id="{225c97bc-f9f0-4085-94c4-f8de353f00cc}" mode="1" >0.50000000</value>
<value id="{225c97bc-f9f0-4085-94c4-f8de353f00cc}" mode="4" >0.500</value>
<value id="{2cf97843-5b49-438e-8034-62a459597e86}" mode="1" >1520.96203613</value>
<value id="{e54486c5-f9aa-4d0e-9a67-6506dae3c790}" mode="1" >1520.96203613</value>
<value id="{e54486c5-f9aa-4d0e-9a67-6506dae3c790}" mode="4" >1520.962</value>
<value id="{12cbf581-99ac-47fd-bf47-4ab1d06ec56a}" mode="1" >8.00000000</value>
<value id="{528fc6d0-de84-40d0-80d2-9dd8b4e02a0b}" mode="1" >0.00000000</value>
<value id="{5041c02a-c619-488c-8631-a3f9e1dab457}" mode="1" >0.00000000</value>
<value id="{c64b625e-c396-4f39-89fb-9c21b77affdd}" mode="1" >0.00000000</value>
<value id="{c64b625e-c396-4f39-89fb-9c21b77affdd}" mode="4" >0</value>
<value id="{cdf66a23-91bd-4fe3-987f-dfc531c78348}" mode="1" >0.00000000</value>
<value id="{cdf66a23-91bd-4fe3-987f-dfc531c78348}" mode="4" >0</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

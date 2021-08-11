;Written by Iain McCurdy, 2006

;Modified for QuteCsound by René, October 2010, updated Feb 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;An INIT preset is called at the start of csound (inst 2), a valid (mono or stereo) audio file have to be selected and preset 0 saved before playing.

;Notes on modifications from original csd:
;	Add Browser for audio files and power of two tables for granule opcode, accept mono or stereo wav files
;	Instrument 1 is activated by MIDI and by the GUI
;	Removed instrument 2, MIDI CC is included in QuteCsound widgets
;	Removed Recording instrument 99, included in QuteCsound
;	Removed "Instructions and Info Panel" for the gui to fit in a 1200x800 screen

;	                          granule
;	---------------------------------------------------------------------------------------------------------------------------------------------------
;	'Granule' is a complex granular synthesis opcode which is good at producing dense granular synthesis textures. Many of 'granule's' input arguments
;	operate only at i-rate making it slightly less useful for real-time work. As a source for granulation 'granule' uses an audio sample stored in a
;	function table. GEN 1 is well suited for this purpose. Instead of using a 'time pointer' to define from where grains will begin playback, 'granule'
;	uses a 'Playback Ratio' (iratio) parameter which defines the rate of the pointer's movement through the function table in relation to the original,
;	unmodified speed. For example a playback ratio of .5 produces half-speed playback of the file, a ratio of 2 produces double-speed playback and so on.
;	It should also be noted that if using the 'grain gap' parameter (i.e. giving it a value other than zero) then playback will be further retarded.  
;	'Granule' produces granular synthesis textures by creating layers of independent grain streams. The number of grain streams present is defined by the
;	'Number of Voices' (ivoice) parameter (range: 1-128). Using a high value for 'Number of Voices' increases the demand on the CPU considerably. The
;	'Grain Gap' parameter (kgap) is used to define the time gap in ms. between grains in a particular grain stream. 'Grain Gap Offset' (igap_os) is used
;	to define the amount of random variation (as a percentage of the value given for 'Grain Gap') that will be applied to the values used for the time
;	gap between grains in the granular synthesis. The 'Grain Size' parameter (kgsize) is used to define the size of the grains in ms.
;	'Grain Size Offset' (igsize_os) is used to define the amount of random variation (as a percentage of the value given for 'Grain Size') that will be
;	applied to the values used for the the size of the grains in the granular synthesis.
;	The shape of the amplitude envelope applied to each grain is created by defining the duration of of the attack, sustain and decay portions of the
;	envelope (ASD envelope). 'Attack' (iatt) and 'Decay' (idec) are defined as percentages of the entire duration (i.e. 100%) of the grain as defined by
;	'Grain Size' and 'Grain Size Offset'. The sustain portion of the envelope will be the durational remainder after the attack and decay portions have
;	been created. The sum of the values for 'Attack' and 'Decay' must be less than or equal to 100.
;	The grain envelope can also be created using a stored function table. In this case the number of this table should be given using the optional input
;	argument 'ifnenv'. Gen 5 or Gen 7 would be good choices for creating this envelope.
;	The 'Pointer Mode' switch is used to define how the pointer moves through each grain. It can be though of as a 3-way switch. A value of 1 means that
;	the pointer will move forward through each grain, a value of -1 means that the pointer will move backwards through each grain and a value of zero
;	means that, grain by grain, the pointer will randomly choose to move either forwards or backwards. To be able to clearly hear the effect of this
;	function use large grain sizes in a sparse texture.
;	'Granule' is capable of rendering 4 independent transpositions. How many trasposition are to be utilised is defined by the 'No. of Pitches' (ipshift)
;	parameter. This value can be either 0,1,2,3, or 4. A value of zero means that each grain will be randomly transposed in the range -1 to +1 octave.
;	The transpositions that will be rendered are defined by the 4 'Pitch' (ipitch#) parameters. (ipitch2 to ipitch4 are optional arguments.)
;	'Number of Voices' must be equal to or greater than 'No. of Pitches'.
;	Transpostions are defined as ratios of the original pitch, i.e. 1=no tranposition, .5=down one octave, 2=up one octave and so on.
;	'Granule' uses its own built-in pseudo-random number generator. The seed value used by this pseudo-random number generator can be defined using the
;	optional argument iseed.
;	In this example two independent 'granule opcodes are used for the left and right channels. The seed values for these two opcodes can be set
;	independently (all other input values are shared. By setting different seed values for the left and right channels, broad stereo effects can be created.
;	'Inskip' is used to define from where the opcode will begin reading grains. When addressing the input argument 'igskip' directly this is defined in
;	seconds. In this example the code interrogates the source sample's function table for its duration and the 'Inskip' slider functions as a 'ratio of the
;	entire source sample' control.
;	Giving 'Inskip' a value of zero will result in grains being initially read from the beginning of the source sound file, giving 'Inskip' a value of 0.5
;	will cause result in grains being initially read from the middle of the source sound file. 'Inskip' can function like a grain pointer if 'Playback Ratio'
;	is first set to its minimum setting. The only problem is theat 'Inskip' is an i-rate variable so changing it in realtime will case discontinuities in the
;	audio output as the instrument is reinitialized. 'Inskip Offset' introduces a random offset into the 'Inskip' (igskip) parameter. This can be used to
;	prevent an amplitude spike when 'Number of when Voices' is a high number and all of the pitch streams begin at the same time with the identical grains.
;	This example can also be triggered via MIDI. MIDI note values will be mapped as a global transposition of all voices.
;	Middle C will be the point of unison. MIDI controller 1 (modulation wheel) can also be used to modulate grain gap and controller 2 can be used to modulate
;	grain size.


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


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkamp		invalue	"Amplitude"
		gkratio		invalue	"Ratio"
		gkgap		invalue	"Gap"
		gkgapos		invalue	"Gap_Offset"
		gksize		invalue	"Size"
		gksizeos		invalue	"Size_Offset"
		gkatt		invalue	"Attack"
		gkdec		invalue	"Decay"
		gkpch1		invalue	"Pitch1"
		gkpch2		invalue	"Pitch2"
		gkpch3		invalue	"Pitch3"
		gkpch4		invalue	"Pitch4"
		gkseedL		invalue	"Seed_L"
		gkseedR		invalue	"Seed_R"
		gkskip		invalue	"Inskip"
		gkskipos		invalue	"Inskip_Offset"
		gkAtt		invalue	"Attack_Time"
		gkRel		invalue	"Release_Time"

		gkvoices		invalue	"Voices"
		kptrmode		invalue	"Pointer_Mode"
		gkptrmode		=		kptrmode -1
		gknumpchs		invalue	"Num_Pitches"

;AUDIO FILE CHANGE / LOAD IN POWER OF 2 TABLES **********************************************************************************************
;Have put all this stuff in instr 10 to reduce the respons time when playing with midi

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
		;granule accept only power of 2 table size
		ifnTemp		ftgentmp	0, 0, 0, 1, Sfile, 0, 0, 1					;Temporary table to get the audio file size
		iftlen		= ftlen(ifnTemp)									;file size
		iftlen2		pow	2, ceil(log(iftlen)/log(2))						;high nearest power of two table size

		;FUNCTION TABLES NUMBERS OF THE SOUND FILE THAT WILL BE GRANULATED
		ichn			filenchnls	Sfile
		if ichn == 1 then
			giFileL	ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 1			;READ MONO AUDIO FILE CHANNEL 1
			giFileR	=		giFileL
		else
			giFileL	ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 1			;READ STEREO AUDIO FILE CHANNEL 1
			giFileR	ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 2			;READ STEREO AUDIO FILE CHANNEL 2
		endif
		
;*******************************************************************************************************************************************
	endif
endin

instr	1	;GRAIN3 INSTRUMENT
	if p4!=0 then													;MIDI
		iPitchRatio	=	cpsoct(p4)/cpsoct(8)						;MAP TO MIDI OCT VALUE TO PITCH (CONVERT TO RATIO: MIDDLE C IS POINT OF UNISON)
		;=======================================================================================================
	else															;OTHERWISE...
		iPitchRatio	=	1										;PITCH RATIO IS JUST 1
	endif														;END OF THIS CONDITIONAL BRANCH

	kporttime	linseg	0,0.001,0.1									;CREATE A VARIABLE FUNCTION THAT RAPIDLY RAMPS UP TO A SET VALUE	
	ksize	portk	gksize, kporttime								;PORTAMENTO SMOOTHING IS APPLIED TO ksize PARAMETER
	kgap		portk	gkgap, kporttime								;PORTAMENTO SMOOTHING IS APPLIED TO kgap PARAMETER

	if	gkfile_new = 1	then											;test if a new file is loaded by instr 10
		gkfile_new	=	0										;flag to zero for next file change
			reinit	START										;REINITIALIZE FROM LABEL 'NEW_FILE1'
	endif

	kSwitch		changed	gkvoices, gkptrmode, gknumpchs, gkskip, gkskipos, gkpch1, gkpch2, gkpch3, gkpch4, gkatt, gkdec, gkratio, gkgapos, gksizeos, gkseedL, gkseedR	;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then												;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	START											;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
	endif														;END OF CONDITIONAL BRANCHING
	START:														;LABEL

	ivoices 		= 	i(gkvoices)
	iratio 		= 	i(gkratio)
	iptrmode 		= 	i(gkptrmode)
	ithd 		= 	0
	inumpchs 		= 	i(gknumpchs)
	ilen			=	nsamp(giFileL)/sr
	iskip 		= 	i(gkskip)*ilen
	kskipos 		= 	gkskipos*ilen
	iskipos 		= 	i(kskipos)
	igapos 		= 	i(gkgapos)
	isizeos 		= 	i(gksizeos)
	iatt 		= 	i(gkatt)
	idec 		= 	i(gkdec)
	iseedL 		= 	i(gkseedL)
	iseedR 		= 	i(gkseedR)
	ipch1 		= 	i(gkpch1) * iPitchRatio							;DERIVE THE PITCH RATIOS OF THE 4 POSSIBLE VOICES FROM THE GUI SLIDER VALUES MULIPLIED BY MIDI RATIO VALUE (IN THE CASE OF AN GUI TRIGGERED NOTE THIS WILL BE JUST 1
	ipch2 		= 	i(gkpch2) * iPitchRatio
	ipch3 		= 	i(gkpch3) * iPitchRatio
	ipch4 		= 	i(gkpch4) * iPitchRatio

	aSigL		granule	gkamp, ivoices, iratio, iptrmode, ithd, giFileL, inumpchs, iskip, iskipos, ilen, kgap, igapos, ksize, isizeos, iatt, idec, iseedL, ipch1, ipch2, ipch3, ipch4
	aSigR		granule	gkamp, ivoices, iratio, iptrmode, ithd,giFileR, inumpchs, iskip, iskipos, ilen, kgap, igapos, ksize, isizeos, iatt, idec, iseedR, ipch1, ipch2, ipch3, ipch4
				rireturn											;RETURN FROM REINITIALIZATION PASS

	aenv			expsegr	0.0001,i(gkAtt),1,i(gkRel),0.0001				;CLOUD AMPLITUDE ENVELOPE
	aSigL		=		aSigL  * gkamp * aenv						;SCALE AUDIO SIGNAL WITH GUI AMPLITUDE SLIDER AND GRAIN CLOUD ENVELOPE
	aSigR		=		aSigR  * gkamp * aenv						;SCALE AUDIO SIGNAL WITH GUI AMPLITUDE SLIDER AND GRAIN CLOUD ENVELOPE
				outs 	aSigL, aSigR								;SEND AUDIO TO OUTPUTS
endin

instr	2	;INIT
		outvalue	"_SetPresetIndex", 0
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
 <x>318</x>
 <y>330</y>
 <width>1029</width>
 <height>432</height>
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
  <label>granule</label>
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
  <label>Grain Gap (CC#1)</label>
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
  <objectName>Gap</objectName>
  <x>8</x>
  <y>125</y>
  <width>500</width>
  <height>27</height>
  <uuid>{273087bd-e04a-4975-a3bd-5b0a8b5fd40a}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.01000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gap</objectName>
  <x>448</x>
  <y>148</y>
  <width>60</width>
  <height>30</height>
  <uuid>{04617e86-7abe-4120-bb9b-1d6ccd2f0983}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>394</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2c02703f-de38-40de-bc69-7c787c5a13b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer Mode</label>
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
  <x>258</x>
  <y>394</y>
  <width>100</width>
  <height>30</height>
  <uuid>{4e98b9a0-55c5-4aef-b473-1d0b761def5d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>No. of Pitches</label>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
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
  <label>Playback Ratio (i-rate)</label>
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
  <objectName>Ratio</objectName>
  <x>8</x>
  <y>83</y>
  <width>500</width>
  <height>27</height>
  <uuid>{89741b38-8333-4828-b8b8-656cff90d564}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00004995</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Ratio</objectName>
  <x>448</x>
  <y>106</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}</uuid>
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
  <label>Grain Gap Offset (i-rate)</label>
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
  <objectName>Gap_Offset</objectName>
  <x>8</x>
  <y>167</y>
  <width>500</width>
  <height>27</height>
  <uuid>{ecd7a8b0-5bb3-4479-b692-e56294223499}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>50.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gap_Offset</objectName>
  <x>448</x>
  <y>190</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f275c8fd-3605-49e8-9090-67ca5f21a9f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>50.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>316</y>
  <width>180</width>
  <height>30</height>
  <uuid>{b6afbe1e-677c-44a6-ba84-4c32dc21b0a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack</label>
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
  <x>8</x>
  <y>293</y>
  <width>500</width>
  <height>27</height>
  <uuid>{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>30.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Attack</objectName>
  <x>448</x>
  <y>316</y>
  <width>60</width>
  <height>30</height>
  <uuid>{95f6cb02-77ec-46fe-876b-a93efac3c5e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>30.000</label>
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
  <label>Grain Size Offset</label>
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
  <objectName>Size_Offset</objectName>
  <x>8</x>
  <y>251</y>
  <width>500</width>
  <height>27</height>
  <uuid>{475cdd64-a4ca-4ebc-a000-90448e932478}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>30.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Size_Offset</objectName>
  <x>448</x>
  <y>274</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>30.000</label>
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
  <label>Decay</label>
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
  <objectName>Decay</objectName>
  <x>8</x>
  <y>335</y>
  <width>500</width>
  <height>27</height>
  <uuid>{4bea56a5-96d7-49d0-90a1-6d1dd17fc584}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>30.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Decay</objectName>
  <x>448</x>
  <y>358</y>
  <width>60</width>
  <height>30</height>
  <uuid>{225c97bc-f9f0-4085-94c4-f8de353f00cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>30.000</label>
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
  <height>30</height>
  <uuid>{3ebc1139-1fdb-48dc-9150-49ee8dfdbd4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Size (CC#2)</label>
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
  <objectName>Size</objectName>
  <x>8</x>
  <y>209</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2cf97843-5b49-438e-8034-62a459597e86}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>2</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.02009800</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Size</objectName>
  <x>448</x>
  <y>232</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e54486c5-f9aa-4d0e-9a67-6506dae3c790}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.020</label>
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
  <width>250</width>
  <height>30</height>
  <uuid>{5d8814e4-a0fd-40f9-b2da-c13148918037}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Inskip Offset</label>
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
  <objectName>Inskip_Offset</objectName>
  <x>522</x>
  <y>293</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2a3075e3-627c-410d-be6e-1914f6f9aef0}</uuid>
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
  <objectName>Inskip_Offset</objectName>
  <x>962</x>
  <y>316</y>
  <width>60</width>
  <height>30</height>
  <uuid>{691ed7a3-eb1b-4d80-8163-4b8f218f345c}</uuid>
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
  <x>839</x>
  <y>33</y>
  <width>122</width>
  <height>29</height>
  <uuid>{8322197a-01c9-4350-b669-63dd23fe5fda}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number of Voices</label>
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
  <objectName>Voices</objectName>
  <x>961</x>
  <y>32</y>
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
  <maximum>128</maximum>
  <randomizable group="0">false</randomizable>
  <value>16</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>274</y>
  <width>250</width>
  <height>30</height>
  <uuid>{ba795236-15a2-4e36-b47d-40480764448d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Inskip</label>
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
  <x>522</x>
  <y>251</y>
  <width>500</width>
  <height>27</height>
  <uuid>{07bcf6fb-e425-41b8-902c-14300e606e78}</uuid>
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
  <x>962</x>
  <y>274</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a4a45d55-c94e-410d-bdf1-032286df751b}</uuid>
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
  <y>232</y>
  <width>180</width>
  <height>30</height>
  <uuid>{2343bdcd-a22e-429f-9430-0e5d4ee91112}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Seed Value (left)</label>
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
  <objectName>Seed_L</objectName>
  <x>522</x>
  <y>209</y>
  <width>250</width>
  <height>27</height>
  <uuid>{01ce49ae-3a96-4910-b06d-20cc089fc003}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.40000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Seed_L</objectName>
  <x>712</x>
  <y>232</y>
  <width>60</width>
  <height>30</height>
  <uuid>{aa1636ff-6d18-4308-a713-8786150937a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.400</label>
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
  <objectName>Seed_R</objectName>
  <x>962</x>
  <y>232</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f25cb089-0703-4af8-9496-3d4f9646e132}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Seed_R</objectName>
  <x>772</x>
  <y>209</y>
  <width>250</width>
  <height>27</height>
  <uuid>{1c81f9d7-e069-4775-8f6a-3e956b6152fb}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>772</x>
  <y>232</y>
  <width>180</width>
  <height>30</height>
  <uuid>{56d53b30-cc1c-4b2f-b206-a37336763455}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Seed Value (right)</label>
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
  <y>190</y>
  <width>180</width>
  <height>30</height>
  <uuid>{3b34a99d-a3ab-447a-95db-83b15890f823}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch3</label>
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
  <objectName>Pitch3</objectName>
  <x>522</x>
  <y>167</y>
  <width>250</width>
  <height>27</height>
  <uuid>{cfcd7ee9-3368-4e12-925e-f8c1f2cd4657}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.50000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00399995</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch3</objectName>
  <x>712</x>
  <y>190</y>
  <width>60</width>
  <height>30</height>
  <uuid>{069be99b-5265-4e89-8105-f743e53b9e6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.004</label>
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
  <objectName>Pitch4</objectName>
  <x>962</x>
  <y>190</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bdbb20fc-d271-4859-bb42-a502d1e98465}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.004</label>
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
  <objectName>Pitch4</objectName>
  <x>772</x>
  <y>167</y>
  <width>250</width>
  <height>27</height>
  <uuid>{bf355517-881f-4a14-9a89-17f519f6b7db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.50000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00399995</value>
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
  <uuid>{4113c2b3-4ebf-4e61-b651-41bedc719b6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch4</label>
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
  <uuid>{657e9359-ec61-4bce-a908-45adfb6ccac3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch1</label>
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
  <objectName>Pitch1</objectName>
  <x>522</x>
  <y>125</y>
  <width>250</width>
  <height>27</height>
  <uuid>{ba6cfd54-41d8-44b3-8b2b-443d1902c798}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.50000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00399995</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch1</objectName>
  <x>712</x>
  <y>148</y>
  <width>60</width>
  <height>30</height>
  <uuid>{39f53fab-1eb4-47eb-b621-2f15963e4a2f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.004</label>
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
  <objectName>Pitch2</objectName>
  <x>962</x>
  <y>148</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ca2c7a27-5546-4fda-8268-15089236c456}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.004</label>
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
  <objectName>Pitch2</objectName>
  <x>772</x>
  <y>125</y>
  <width>250</width>
  <height>27</height>
  <uuid>{3d16f153-ba9f-432b-8875-2595ef00dc6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.50000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00399995</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>772</x>
  <y>148</y>
  <width>180</width>
  <height>30</height>
  <uuid>{d0d7d676-228f-4441-a2b4-5c674eb3ffd2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch2</label>
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
  <objectName>Pointer_Mode</objectName>
  <x>108</x>
  <y>390</y>
  <width>150</width>
  <height>30</height>
  <uuid>{528fc6d0-de84-40d0-80d2-9dd8b4e02a0b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Move Backward</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Move Random</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Move Forward</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Num_Pitches</objectName>
  <x>358</x>
  <y>390</y>
  <width>150</width>
  <height>30</height>
  <uuid>{5041c02a-c619-488c-8631-a3f9e1dab457}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Random</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pitch1</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pitch2</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pitch3</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pitch4</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="INIT" number="0" >
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="1" >0.00000000</value>
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="4" >0</value>
<value id="{273087bd-e04a-4975-a3bd-5b0a8b5fd40a}" mode="1" >0.01000000</value>
<value id="{04617e86-7abe-4120-bb9b-1d6ccd2f0983}" mode="1" >0.01000000</value>
<value id="{04617e86-7abe-4120-bb9b-1d6ccd2f0983}" mode="4" >0.010</value>
<value id="{1757a18f-b418-4ef1-984d-bdee5e985805}" mode="4" >ClassicalGuitar.wav</value>
<value id="{804f4f24-03f1-4ac2-8ba2-697f15df06cf}" mode="4" >ClassicalGuitar.wav</value>
<value id="{89741b38-8333-4828-b8b8-656cff90d564}" mode="1" >1.00004995</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="1" >1.00000000</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="4" >1.000</value>
<value id="{ecd7a8b0-5bb3-4479-b692-e56294223499}" mode="1" >50.00000000</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="1" >50.00000000</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="4" >50.000</value>
<value id="{d6d73a88-8d82-47de-a067-758f1917a3f2}" mode="1" >0.30000001</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="1" >0.30000001</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="4" >0.300</value>
<value id="{dbdbe7cb-a74d-45b2-9e47-e5c0594f3ea5}" mode="1" >0.05000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="1" >0.05000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="4" >0.050</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="1" >0.05000000</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="4" >0.050</value>
<value id="{cb664a0c-f84b-41f5-92e9-7deb5a672d56}" mode="1" >0.05000000</value>
<value id="{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}" mode="1" >30.00000000</value>
<value id="{95f6cb02-77ec-46fe-876b-a93efac3c5e5}" mode="1" >30.00000000</value>
<value id="{95f6cb02-77ec-46fe-876b-a93efac3c5e5}" mode="4" >30.000</value>
<value id="{475cdd64-a4ca-4ebc-a000-90448e932478}" mode="1" >30.00000000</value>
<value id="{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}" mode="1" >30.00000000</value>
<value id="{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}" mode="4" >30.000</value>
<value id="{4bea56a5-96d7-49d0-90a1-6d1dd17fc584}" mode="1" >30.00000000</value>
<value id="{225c97bc-f9f0-4085-94c4-f8de353f00cc}" mode="1" >30.00000000</value>
<value id="{225c97bc-f9f0-4085-94c4-f8de353f00cc}" mode="4" >30.000</value>
<value id="{2cf97843-5b49-438e-8034-62a459597e86}" mode="1" >0.02009800</value>
<value id="{e54486c5-f9aa-4d0e-9a67-6506dae3c790}" mode="1" >0.02000000</value>
<value id="{e54486c5-f9aa-4d0e-9a67-6506dae3c790}" mode="4" >0.020</value>
<value id="{2a3075e3-627c-410d-be6e-1914f6f9aef0}" mode="1" >0.00000000</value>
<value id="{691ed7a3-eb1b-4d80-8163-4b8f218f345c}" mode="1" >0.00000000</value>
<value id="{691ed7a3-eb1b-4d80-8163-4b8f218f345c}" mode="4" >0.000</value>
<value id="{12cbf581-99ac-47fd-bf47-4ab1d06ec56a}" mode="1" >16.00000000</value>
<value id="{07bcf6fb-e425-41b8-902c-14300e606e78}" mode="1" >0.00000000</value>
<value id="{a4a45d55-c94e-410d-bdf1-032286df751b}" mode="1" >0.00000000</value>
<value id="{a4a45d55-c94e-410d-bdf1-032286df751b}" mode="4" >0.000</value>
<value id="{01ce49ae-3a96-4910-b06d-20cc089fc003}" mode="1" >0.40000001</value>
<value id="{aa1636ff-6d18-4308-a713-8786150937a4}" mode="1" >0.40000001</value>
<value id="{aa1636ff-6d18-4308-a713-8786150937a4}" mode="4" >0.400</value>
<value id="{f25cb089-0703-4af8-9496-3d4f9646e132}" mode="1" >0.50000000</value>
<value id="{f25cb089-0703-4af8-9496-3d4f9646e132}" mode="4" >0.500</value>
<value id="{1c81f9d7-e069-4775-8f6a-3e956b6152fb}" mode="1" >0.50000000</value>
<value id="{cfcd7ee9-3368-4e12-925e-f8c1f2cd4657}" mode="1" >1.00399995</value>
<value id="{069be99b-5265-4e89-8105-f743e53b9e6a}" mode="1" >1.00399995</value>
<value id="{069be99b-5265-4e89-8105-f743e53b9e6a}" mode="4" >1.004</value>
<value id="{bdbb20fc-d271-4859-bb42-a502d1e98465}" mode="1" >1.00399995</value>
<value id="{bdbb20fc-d271-4859-bb42-a502d1e98465}" mode="4" >1.004</value>
<value id="{bf355517-881f-4a14-9a89-17f519f6b7db}" mode="1" >1.00399995</value>
<value id="{ba6cfd54-41d8-44b3-8b2b-443d1902c798}" mode="1" >1.00399995</value>
<value id="{39f53fab-1eb4-47eb-b621-2f15963e4a2f}" mode="1" >1.00399995</value>
<value id="{39f53fab-1eb4-47eb-b621-2f15963e4a2f}" mode="4" >1.004</value>
<value id="{ca2c7a27-5546-4fda-8268-15089236c456}" mode="1" >1.00399995</value>
<value id="{ca2c7a27-5546-4fda-8268-15089236c456}" mode="4" >1.004</value>
<value id="{3d16f153-ba9f-432b-8875-2595ef00dc6a}" mode="1" >1.00399995</value>
<value id="{528fc6d0-de84-40d0-80d2-9dd8b4e02a0b}" mode="1" >2.00000000</value>
<value id="{5041c02a-c619-488c-8631-a3f9e1dab457}" mode="1" >1.00000000</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

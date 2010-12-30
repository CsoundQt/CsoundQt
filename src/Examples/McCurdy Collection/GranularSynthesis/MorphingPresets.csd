;Written by Iain McCurdy, 2008


; Modified for QuteCsound by René, December 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio files and power of two tables for grain3 opcode
;	Removed "Instructions and Info Panel" for the gui to fit in a 1200x800 screen

;	                     Morphing Presets
;	---------------------------------------------------------------------------------------------------------------------------------
;	This example is based on the example 'grain3.csd' so I would recommend investigating that example first.
;	The innovation that this example introduces is the use of an X-Y 'joy' panel to allow the user to 2-dimensionally morph between 
;	4 presets.
;	The quickest way to see what this does is first to select a valid stereo audio file, then activate the on-screen 'On/Off' button,
;	then click on the 'Load' button (ensure that the files 'Preset1.txt', 'Preset2.txt', 'Preset3.txt' and 'Preset4.txt' are in the
;	same directory as this file),  and to then drag the cross-hairs of the joy panel.
;	Four distinct presets are referenced to the four corners of the X-Y panel. Dragging the cross-hairs to locations other than these
;	four corners creates a morph, or interpolation, between the four presets, the influence of each preset on the resultant preset is
;	relative to its closeness to the current location of the cross-hairs.
;	You will notice that only parameters whose slider labels have been suffixed with an asterisk ('*') are influenced by the presets.
;	The sliders can of course be modified individually. A preset or snapshot can then be stored by clicking on one of the blue
;	boxes at each corner of the X-Y panel. All four presets can be stored permanantly a set of four text files by clicking on the red
;	'save' button. These four text files, and consequently the four presets, can be re-loaded in a later Csound session by clicking
;	on the green 'load' button. The mechanism by which this is achieved is explained in detail in example 'ftsave_ftload.csd'.
;	More parameters can easily be included in a preset by making a small modification to the code.


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


;FUNCTION TABLE USED TO STORE DATA FOR PRESET 1 to 4; NOTE THAT FUNCTION TABLES WILL NEED TO BE ENLARGED IF MORE THAT 8 PARAMETERS ARE TO BE INCLUDED IN THE PRESETS
gipfn1	ftgen	1, 0, 8, -2, 0
gipfn2	ftgen	2, 0, 8, -2, 0
gipfn3	ftgen	3, 0, 8, -2, 0
gipfn4	ftgen	4, 0, 8, -2, 0

;;GRAIN ENVELOPE WINDOW FUNCTION TABLES:
giwfn1	ftgen	0,  0, 512,  20, 2									; HANNING WINDOW
giwfn2	ftgen	0,  0, 512,  7, 0, 12, 1, 500, 0						; PERCUSSIVE - STRAIGHT SEGMENTS
giwfn3	ftgen	0,  0, 512,  5, 0.00001, 12, 1, 500, 0.00001				; PERCUSSIVE - EXPONENTIAL SEGMENTS
giwfn4	ftgen	0,  0, 512,  7, 0, 6, 1, 500, 1, 6, 0					; GATE - WITH ANTI-CLICK RAMP UP AND RAMP DOWN SEGMENTS
giwfn5	ftgen	0,  0, 512,  7, 0, 500, 1, 12, 0						; REVERSE PERCUSSIVE - STRAIGHT SEGMENTS
;giwfn6	ftgen	0,  0, 512,  5, 0.001, 500, 1, 12, 0.001				; REVERSE PERCUSSIVE - EXPONENTIAL SEGMENTS
giwfn6	ftgen	0,  0, 131072, 5, 0.00001, 131072-1024, 1, 1024, 0.00001	; REVERSE PERCUSSIVE - EXPONENTIAL SEGMENTS

;TABLE FOR EXP SLIDER
giExp16	ftgen	0, 0, 129, -25, 0, 0.016125, 128, 16.0


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkSyncCPS		invalue	"SyncCPS"
		gkIntegerLoc	invalue	"IntegerLoc"
		gkLessZero	invalue	"LessZero"
		gkInterp		invalue	"Interp"
		gkNoInterp	invalue	"NoInterp"
		gkFreqCont	invalue	"FreqCont"
		gkSkipInit	invalue	"SkipInit"
		gkmode 		=		gkSyncCPS + gkIntegerLoc + gkLessZero + gkInterp + gkNoInterp + gkFreqCont + gkFreqCont + gkSkipInit

		gkamp		invalue	"Amplitude"
		gkdur		invalue	"Grain_Duration"			;* saved in file preset
		kpch			invalue	"Pitch"					;* saved in file preset
		gkpch		tablei	kpch, giExp16, 1
					outvalue	"Pitch_Value", gkpch
		gkfmd		invalue	"Pitch_Offset"				;* saved in file preset
		gkdens		invalue	"Density"					;* saved in file preset
		gkphs		invalue	"Grain_Phase"				;* saved in file preset
		gkpmd		invalue	"Grain_Phase_Rnd_Offset"		;* saved in file preset
		gkfrpow		invalue	"Dist_Rnd_Freq_Var"
		gkprpow		invalue	"Dist_Rnd_Phase_Var"
		gkseedL		invalue	"Seed_Value_L"
		gkseedR		invalue	"Seed_Value_R"
		gkDensRnd		invalue	"Density_Rnd_Amount"

		gkmaxolap		invalue	"Maximum_Overlaps"
		gkwfn		invalue	"Grain_Envelope"

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
		;grain3 accept only power of 2 table size
		ifnTemp		ftgentmp	0, 0, 0, 1, Sfile, 0, 0, 1					;Temporary table to get the audio file size
		iftlen		= ftlen(ifnTemp)									;file size
		iftlen2		pow	2, ceil(log(iftlen)/log(2))						;high nearest power of two table size

		;FUNCTION TABLES NUMBERS OF THE SOUND FILE THAT WILL BE GRANULATED
		giFileL		ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 1				;READ STEREO AUDIO FILE CHANNEL 1
		giFileR		ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 2				;READ STEREO AUDIO FILE CHANNEL 2
		
;*******************************************************************************************************************************************
	endif
endin

instr	1	;GRAIN3 INSTRUMENT
	if	gkfile_new = 1	then												;test if a new file is loaded by instr 10
		gkfile_new	=	0											;flag to zero for next file change
			reinit	START											;REINITIALIZE FROM LABEL 'NEW_FILE1'
	endif

	kSwitch		changed	gkmaxolap, gkseedL, gkseedR, gkmode, gkwfn
	if	kSwitch=1	then													;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	START												;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
	endif

	START:
	imode	=		i(gkmode)											;SUM THE MODE BUTTON OUTPUTS
	imaxovr 	= 		i(gkmaxolap)										;MAXIMUM NUMBER OF OVERLAPS
	iwfn		=		giwfn1 + i(gkwfn)
	kpitch 	= 		(sr*gkpch)/ftlen(giFileL)							;MATHEMATICALLY REINTERPRET USER INPUTTED PITCH RATIO VALUE INTO A FORMAT THAT IS USABLE AS AN INPUT ARGUMENT BY THE grain3 OPCODE - ftlen(x) FUNCTION RETURNS THE LENGTH OF A FUNCTION TABLE (no. x), REFER TO MANUAL FOR MORE INFO.
	kphs 	= 		gkphs*(nsamp(giFileL)/ftlen(giFileL))					;MATHREMATICALLY REINTERPRET USER INPUTTED PHASE VALUE INTO A FORMAT THAT IS USABLE AS AN INPUT ARGUMENT  BY THE grain3 OPCODE
	kDensRnd 	exprand	gkDensRnd											;CREATE A RANDOM OFFSET FACTOR THAT WILL BE APPLIED TO FOR DENSITY
	kdens	=		gkdens * (1 + kDensRnd)								;DENSITY VALUE IS OFFSET BY RANDOM FACTOR

	aSigL	grain3	kpitch, kphs, gkfmd, gkpmd, gkdur, kdens, imaxovr, giFileL, iwfn, gkfrpow, gkprpow , i(gkseedL), imode
	aSigR	grain3	kpitch, kphs, gkfmd, gkpmd, gkdur, kdens, imaxovr, giFileL, iwfn, gkfrpow, gkprpow , i(gkseedR), imode
			rireturn													;RETURN TO PERFORMANCE TIME PASSES
			outs 	aSigL * gkamp, aSigR * gkamp							;SEND AUDIO TO OUTPUTS

	kx		invalue	"Morph_X"
	ky		invalue	"Morph_Y"

	ktrigger	changed	kx, ky
	if		ktrigger!=1 kgoto SKIP

	;A TEXT MACRO IS DEFINED THAT PROVIDES THE CODE THAT WILL BE USED TO DERIVE A VALUE FOR EACH PARAMETER GOVERNED BY THE PRESETS
	;THIS CODE WILL BE REPEATED FOR EACH PARAMETER SO TO USE A MACRO GREATLY REDUCES THE AMOUNT OF CODE NEEDED, PARTICULARLY IF A LARGE NUMBER OF PARAMETERS ARE NEEDED 
	;START OF TEXT MACRO
#define	MORPH(VAR'WIDGET'NDX)	#
	k$VAR1		table	$NDX, 1										;DERIVE PARAMETER FOR PRESET 1 (UPPER LEFT CORNER) 
	k$VAR2		table	$NDX, 2										;DERIVE PARAMETER FOR PRESET 2 (UPPER RIGHT CORNER)
	k$VAR3		table	$NDX, 3										;DERIVE PARAMETER FOR PRESET 3 (BOTTOM LEFT CORNER)
	k$VAR4		table	$NDX, 4										;DERIVE PARAMETER FOR PRESET 4 (BOTTOM RIGHT CORNER)
	k$VARXTop		ntrpol	k$VAR1,k$VAR2,kx								;CREATE AN INTERIM VARIABLE INTERPOLATED BETWEEN PRESET 1 AND PRESET 2 (UPPER EDGE OF GUI panel)
	k$VARXBot		ntrpol	k$VAR3,k$VAR4,kx								;CREATE AN INTERIM VARIABLE INTERPOLATED BETWEEN PRESET 3 AND PRESET 4 (BOTTOM EDGE OF GUI panel)
	k$VARi		ntrpol	k$VARXBot,k$VARXTop,ky							;DERIVE THE FINAL VALUE FOR THE REQUIRED PARAMETER BY INTERPOLATING BETWEEN UPPER EDGE VARIABLE AND BOTTOM EDGE VARIABLE
				outvalue	"$WIDGET", k$VARi								;UPDATE SLIDER APPEARANCE FOR RELEVANT PARAMETER
#
	;END OF TEXT MACRO

	;CREATE AN ITERATION OF THE 'MORPH' CODE MACRO
	$MORPH(dens'Density'0)
	$MORPH(dur'Grain_Duration'1)
	$MORPH(pch'Pitch'2)
	$MORPH(fmd'Pitch_Offset'3)
	$MORPH(phs'Grain_Phase'4)
	$MORPH(pmd'Grain_Phase_Rnd_Offset'5)
SKIP:
endin

instr	11	;SAVE DATA TO A FUNCTION TABLE, THIS INSTRUMENT IS ACTIVATED EACH TIME A CORNER BUTTON IS PRESSED
			;PARAMETER VALUE IS WRITTEN TO ITS OWN UNIQUE LOCATION IN THE FUNCTION TABLE FOR THAT PRESET
	tableiw	i(gkdens), 0, p4
	tableiw	i(gkdur),  1, p4
	tableiw	i(gkpch),  2, p4
	tableiw	i(gkfmd),  3, p4
	tableiw	i(gkphs),  4, p4
	tableiw	i(gkpmd),  5, p4
endin

instr	21	;LOAD DATA FROM STORED TEXT FILES, THIS INSTRUMENT IS ACTIVATED BRIEFLY WHENEVER THE 'Load' BUTTON IS PRESSED
			;LOAD FILE TO FUNCTION TABLE
	ftload	"Preset1.txt", 1, 1
	ftload	"Preset2.txt", 1, 2
	ftload	"Preset3.txt", 1, 3
	ftload	"Preset4.txt", 1, 4
endin

instr	31	;SAVE DATA TO TEXT FILES STORED ON DISK, THIS INSTRUMENT IS ACTIVATED BRIEFLY WHENEVER THE 'Save' BUTTON IS PRESSED
			;FUNCTION TABLE IS SAVED AS A TEXT FILE (FILE EXTENSION COULD BE ANYTHING OR NOTHING BUT MAKING IT A TEXT FILE MAKES IT EASY TO OPEN AND EXAMINE AND POSSIBLY ALTER - FOR THIS, DATA TYPE FLAG SHOULD BE NON-ZERO)
	ftsave	"Preset1.txt", 1, 1		
	ftsave	"Preset2.txt", 1, 2
	ftsave	"Preset3.txt", 1, 3
	ftsave	"Preset4.txt", 1, 4
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>274</x>
 <y>657</y>
 <width>1125</width>
 <height>388</height>
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
  <width>1123</width>
  <height>386</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Morphing Presets</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <text>     On / Off</text>
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
  <label>Pitch  *</label>
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
  <y>125</y>
  <width>350</width>
  <height>27</height>
  <uuid>{273087bd-e04a-4975-a3bd-5b0a8b5fd40a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.80036458</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch_Value</objectName>
  <x>298</x>
  <y>148</y>
  <width>60</width>
  <height>30</height>
  <uuid>{04617e86-7abe-4120-bb9b-1d6ccd2f0983}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.037</label>
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
  <x>578</x>
  <y>49</y>
  <width>120</width>
  <height>30</height>
  <uuid>{2c02703f-de38-40de-bc69-7c787c5a13b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Seed Value L</label>
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
  <x>702</x>
  <y>49</y>
  <width>120</width>
  <height>30</height>
  <uuid>{4e98b9a0-55c5-4aef-b473-1d0b761def5d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Seed Value R</label>
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
  <objectName>_Browse</objectName>
  <x>370</x>
  <y>110</y>
  <width>170</width>
  <height>30</height>
  <uuid>{1757a18f-b418-4ef1-984d-bdee5e985805}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/moi/Samples/ClassicalGuitar.wav</stringvalue>
  <text>Browse Stereo Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>540</x>
  <y>111</y>
  <width>282</width>
  <height>28</height>
  <uuid>{804f4f24-03f1-4ac2-8ba2-697f15df06cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/moi/Samples/ClassicalGuitar.wav</label>
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
  <x>370</x>
  <y>89</y>
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
  <label>Grain Duration (ms)  *</label>
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
  <x>8</x>
  <y>83</y>
  <width>350</width>
  <height>27</height>
  <uuid>{89741b38-8333-4828-b8b8-656cff90d564}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.16597564</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Grain_Duration</objectName>
  <x>298</x>
  <y>106</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.166</label>
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
  <label>Pitch Offset  *</label>
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
  <objectName>Pitch_Offset</objectName>
  <x>8</x>
  <y>167</y>
  <width>350</width>
  <height>27</height>
  <uuid>{ecd7a8b0-5bb3-4479-b692-e56294223499}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.05361016</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch_Offset</objectName>
  <x>298</x>
  <y>190</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f275c8fd-3605-49e8-9090-67ca5f21a9f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.054</label>
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
  <width>350</width>
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
  <x>298</x>
  <y>64</y>
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
  <x>8</x>
  <y>316</y>
  <width>180</width>
  <height>30</height>
  <uuid>{b6afbe1e-677c-44a6-ba84-4c32dc21b0a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Phase Random Offset *</label>
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
  <objectName>Grain_Phase_Rnd_Offset</objectName>
  <x>8</x>
  <y>293</y>
  <width>350</width>
  <height>27</height>
  <uuid>{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.24872152</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Grain_Phase_Rnd_Offset</objectName>
  <x>298</x>
  <y>316</y>
  <width>60</width>
  <height>30</height>
  <uuid>{95f6cb02-77ec-46fe-876b-a93efac3c5e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.249</label>
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
  <label>Grain Phase  *</label>
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
  <objectName>Grain_Phase</objectName>
  <x>8</x>
  <y>251</y>
  <width>350</width>
  <height>27</height>
  <uuid>{475cdd64-a4ca-4ebc-a000-90448e932478}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20491120</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Grain_Phase</objectName>
  <x>298</x>
  <y>274</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.205</label>
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
  <width>250</width>
  <height>30</height>
  <uuid>{1b53998a-9e9e-4067-8cee-83fc9f2f657b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Distribution of Random Frequency Variation</label>
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
  <objectName>Dist_Rnd_Freq_Var</objectName>
  <x>8</x>
  <y>335</y>
  <width>350</width>
  <height>27</height>
  <uuid>{4bea56a5-96d7-49d0-90a1-6d1dd17fc584}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Dist_Rnd_Freq_Var</objectName>
  <x>298</x>
  <y>358</y>
  <width>60</width>
  <height>30</height>
  <uuid>{225c97bc-f9f0-4085-94c4-f8de353f00cc}</uuid>
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
  <y>232</y>
  <width>180</width>
  <height>30</height>
  <uuid>{3ebc1139-1fdb-48dc-9150-49ee8dfdbd4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Density  *</label>
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
  <y>209</y>
  <width>350</width>
  <height>27</height>
  <uuid>{2cf97843-5b49-438e-8034-62a459597e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>500.00000000</maximum>
  <value>139.75754142</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Density</objectName>
  <x>298</x>
  <y>232</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e54486c5-f9aa-4d0e-9a67-6506dae3c790}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>139.758</label>
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
  <x>370</x>
  <y>357</y>
  <width>250</width>
  <height>30</height>
  <uuid>{7fcf32c6-3a0e-4612-954b-4d5058e0c8ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Distribution of Random Phase Variation</label>
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
  <objectName>Dist_Rnd_Phase_Var</objectName>
  <x>370</x>
  <y>334</y>
  <width>350</width>
  <height>27</height>
  <uuid>{c9a337f2-f38b-4b56-8acb-2ee24ea9690d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Dist_Rnd_Phase_Var</objectName>
  <x>660</x>
  <y>357</y>
  <width>60</width>
  <height>30</height>
  <uuid>{37c96c68-4b39-43be-9026-e1eba2af009e}</uuid>
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
  <x>370</x>
  <y>316</y>
  <width>250</width>
  <height>30</height>
  <uuid>{5d8814e4-a0fd-40f9-b2da-c13148918037}</uuid>
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
  <objectName>Density_Rnd_Amount</objectName>
  <x>370</x>
  <y>293</y>
  <width>350</width>
  <height>27</height>
  <uuid>{2a3075e3-627c-410d-be6e-1914f6f9aef0}</uuid>
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
  <objectName>Density_Rnd_Amount</objectName>
  <x>660</x>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>SyncCPS</objectName>
  <x>504</x>
  <y>158</y>
  <width>16</width>
  <height>16</height>
  <uuid>{418a721f-9fff-4c7e-8843-76bbfeef1c09}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>64.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>IntegerLoc</objectName>
  <x>642</x>
  <y>158</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b6d59515-e40d-4f73-9f8a-134d81bd0682}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>32.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>535</x>
  <y>149</y>
  <width>107</width>
  <height>34</height>
  <uuid>{285d8003-23e9-4481-95c3-771460a2d34d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Start All Grains at Integer Location</label>
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
  <x>376</x>
  <y>149</y>
  <width>129</width>
  <height>35</height>
  <uuid>{d15a7624-b9fa-4559-b56e-d27d103f686f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sync Start Phase
to CPS</label>
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
  <objectName>Interp</objectName>
  <x>504</x>
  <y>189</y>
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
  <x>642</x>
  <y>189</y>
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
  <x>534</x>
  <y>180</y>
  <width>107</width>
  <height>35</height>
  <uuid>{ce374c64-8397-44a6-994b-4965d6d27f36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>No Interpolate
Waveform</label>
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
  <x>382</x>
  <y>184</y>
  <width>120</width>
  <height>30</height>
  <uuid>{56471eb8-6569-46ca-a7e8-e4415bbafdfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Interpolate Window</label>
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
  <x>504</x>
  <y>220</y>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>382</x>
  <y>216</y>
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
  <objectName>LessZero</objectName>
  <x>780</x>
  <y>158</y>
  <width>16</width>
  <height>16</height>
  <uuid>{1a0333ca-ffd3-417c-b1af-bf022458d6aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>16.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>660</x>
  <y>149</y>
  <width>120</width>
  <height>35</height>
  <uuid>{df9ab6cb-8028-4d98-bfc9-41753c52aee3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Ignore Grains Starting
at Negative Phase</label>
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
  <x>780</x>
  <y>189</y>
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
  <x>660</x>
  <y>180</y>
  <width>120</width>
  <height>35</height>
  <uuid>{d98d1d5d-8b96-4ca5-b011-fbd6e2e8b2f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Continual Freq
Modification</label>
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
  <x>719</x>
  <y>302</y>
  <width>108</width>
  <height>42</height>
  <uuid>{8322197a-01c9-4350-b669-63dd23fe5fda}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Maximum Overlaps</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Maximum_Overlaps</objectName>
  <x>743</x>
  <y>324</y>
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
  <maximum>1000</maximum>
  <randomizable group="0">false</randomizable>
  <value>600</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Grain_Envelope</objectName>
  <x>492</x>
  <y>252</y>
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
  <x>354</x>
  <y>254</y>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Seed_Value_L</objectName>
  <x>578</x>
  <y>69</y>
  <width>120</width>
  <height>30</height>
  <uuid>{7ff1d947-e233-4aad-a77c-81f28b30f77d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
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
  <minimum>0</minimum>
  <maximum>2.14748e+09</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Seed_Value_R</objectName>
  <x>702</x>
  <y>69</y>
  <width>120</width>
  <height>30</height>
  <uuid>{43b6bfc8-a3ea-46d5-87bb-c487380b9a79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
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
  <minimum>0</minimum>
  <maximum>2.14748e+09</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>Morph_X</objectName>
  <x>837</x>
  <y>72</y>
  <width>280</width>
  <height>280</height>
  <uuid>{27ca0a87-3ec2-40fe-9804-d743d82ef625}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Morph_Y</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.52500000</yValue>
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
  <x>840</x>
  <y>50</y>
  <width>16</width>
  <height>16</height>
  <uuid>{1c7ca574-f5cd-4f44-9074-e185e5c141fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i11 0 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>1098</x>
  <y>50</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b9cef5f7-ecfe-4b70-b580-054554776b64}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i11 0 0 2</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>840</x>
  <y>358</y>
  <width>16</width>
  <height>16</height>
  <uuid>{af023c8d-89f9-4366-94aa-bb21dbee38b5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i11 0 0 3</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>1098</x>
  <y>358</y>
  <width>16</width>
  <height>16</height>
  <uuid>{0772c173-3025-40dd-ba78-27d8efcd72c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i11 0 0 4</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>904</x>
  <y>49</y>
  <width>70</width>
  <height>20</height>
  <uuid>{799eb7a3-99b4-467f-9220-341c4d29187d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Load</text>
  <image>/</image>
  <eventLine>i21 0 0</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>979</x>
  <y>49</y>
  <width>70</width>
  <height>20</height>
  <uuid>{e176334e-a812-4e5f-b2e9-b5dbe7961a0c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Save</text>
  <image>/</image>
  <eventLine>i31 0 0</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

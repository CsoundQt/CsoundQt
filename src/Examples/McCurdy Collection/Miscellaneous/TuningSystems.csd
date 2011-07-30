;Written by Iain McCurdy, 2009

;Modified for QuteCsound by René, February 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817


;Notes on modifications from original csd:
;	Changed (1-kamp_n) by kamp_n
;	Add INIT instrument 11


;my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1	


gisine	ftgen	0,0,4096,10,1	;A SINE WAVE
;			FN_NUM | INIT_TIME | SIZE | GEN_ROUTINE | NUM_GRADES | REPEAT | BASE_FREQ | BASE_KEY_MIDI | TUNING_RATIOS:-0-|----1----|---2----|----3----|----4----|----5----|----6----|----7----|----8----|----9----|----10----|---11----|-12-|
gijust	ftgen  0,         0,       64,       -2,          12,         2,     261.626,        60,                        1,   16/15,    9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,       9/5,     15/8,     2		;RATIOS FOR JUST INTONATION
gipyth	ftgen  0,         0,       64,       -2,          12,         2,     261.626,        60,                        1,  256/243,   9/8,    32/27,    81/64,      4/3,    729/512,    3/2,    128/81,   27/16,     16/9,     243/128,  2		;RATIOS FOR PYTHAGOREAN TUNING


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkmode		invalue	"Mode"
		gkGlobAmp		invalue	"Amplitude"

		gkamp1		invalue	"Par1"
		gkamp2		invalue	"Par2"
		gkamp3		invalue	"Par3"
		gkamp4		invalue	"Par4"
		gkamp5		invalue	"Par5"
		gkamp6		invalue	"Par6"
		gkamp7		invalue	"Par7"
		gkamp8		invalue	"Par8"
		gkamp9		invalue	"Par9"
		gkamp10		invalue	"Par10"
		gkamp11		invalue	"Par11"
		gkamp12		invalue	"Par12"
		gkamp13		invalue	"Par13"
		gkamp14		invalue	"Par14"
		gkamp15		invalue	"Par15"
		gkamp16		invalue	"Par16"
	endif
endin

instr	11	;INIT
		outvalue	"Par1",  1/1
		outvalue	"Par2",  1/2
		outvalue	"Par3",  1/3
		outvalue	"Par4",  1/4
		outvalue	"Par5",  1/5
		outvalue	"Par6",  1/6
		outvalue	"Par7",  1/7
		outvalue	"Par8",  1/8
		outvalue	"Par9",  1/9
		outvalue	"Par10", 1/10
		outvalue	"Par11", 1/11
		outvalue	"Par12", 1/12
		outvalue	"Par13", 1/13
		outvalue	"Par14", 1/14
		outvalue	"Par15", 1/15
		outvalue	"Par16", 1/16
endin

instr	1	;MIDI ACTIVATED INSTRUMENT
	icpsET	cpsmidi									;NOTE PITCH IN CYCLES PER SECOND (EQUALLY TEMPERED)
	icpsJI	cpstmid	gijust							;NOTE PITCH IN CYCLES PER SECOND (JUST INTONATION)
	icpsPy	cpstmid	gipyth							;NOTE PITCH IN CYCLES PER SECOND (PYTHAGOREAN)
	if	gkmode==0	then									;IF 'EQUAL TEMPERAMENT' MIDI MODE HAS BEEN CHOSED...
		kcps	=	icpsET								;kcps TAKES EQUALLY TEMPERED PITCH VALUE
	elseif	gkmode==1	then								;IF 'JUST INTONATION' MIDI MODE HAS BEEN CHOSED...
		kcps	=	icpsJI 								;kcps TAKES JUST INTONATION PITCH VALUE
	elseif	gkmode==2	then								;IF 'PYTHAGOREAN' MIDI MODE HAS BEEN CHOSED...
		kcps	=	icpsPy								;kcps TAKES PYTHAGOREAN PITCH VALUE
	endif											;END OF CONDITIONAL BRANCHING

	iporttime	=		0.01								;PORTAMENTO TIME
	kporttime	linseg	0,iporttime,1,1,1					;CREATE A RAMPING UP FUNCTION FOR PORTAMENTO TIME
	kamp1	portk	gkamp1, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE		
	kamp2	portk	gkamp2, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp3	portk	gkamp3, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp4	portk	gkamp4, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp5	portk	gkamp5, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp6	portk	gkamp6, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp7	portk	gkamp7, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp8	portk	gkamp8, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp9	portk	gkamp9, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp10	portk	gkamp10, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp11	portk	gkamp11, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp12	portk	gkamp12, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp13	portk	gkamp13, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp14	portk	gkamp14, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp15	portk	gkamp15, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	kamp16	portk	gkamp16, kporttime					;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE
	
	a1		oscili	kamp1,  kcps, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a2		oscili	kamp2,  kcps*2, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a3		oscili	kamp3,  kcps*3, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a4		oscili	kamp4,  kcps*4, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a5		oscili	kamp5,  kcps*5, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a6		oscili	kamp6,  kcps*6, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a7		oscili	kamp7,  kcps*7, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a8		oscili	kamp8,  kcps*8, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a9		oscili	kamp9,  kcps*9, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a10		oscili	kamp10, kcps*10, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a11		oscili	kamp11, kcps*11, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a12		oscili	kamp12, kcps*12, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a13		oscili	kamp13, kcps*13, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a14		oscili	kamp14, kcps*14, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a15		oscili	kamp15, kcps*15, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a16		oscili	kamp16, kcps*16, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE

	asig		sum		a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16		;SUM (MIX) ALL PARTIALS
	aenv		expsegr	0.01,0.001,1,0.05,0.001								;CREATE AN AMPLITUDE ENVELOPE WITH A RELEASE SEGMENT
	asig		=		(asig*aenv*gkGlobAmp)/16								;SCALE AUDIO SIGNAL USING GLOBAL AMPLITUDE SLIDER VARIABLE, AMPLITUDE ENVELOPE AND ACCORDING TO THE NUMBER OF PARTIALS PRESENT
			outs		asig,asig											;SEND AUDIO TO OUTPUTS
endin

;CREATE A MACRO FOR GUI INSTRUMENT TO REDUCE CODE REPETITION
;THIS MACRO WILL TAKE TWO INPUT ARGUMENTS FOR INSTRUMENT NUMBER AND A COUNTER THAT WILL RELATE TO THE NAMES OF THE VARIABLES OUTPUT BY GUI BUTTONS
#define GUI_INSTRUMENT(I'N)
#
instr	$I	;GUI INSTRUMENT
	icps		=		cpsoct(8) * p4						;CREATE THE RELEVANT PITCH VALUE IN CYCLES PER SECOND (THE INTERVAL (AS A RATIO) WITH REFERENCE TO MIDDLE C IS OUTPUT AS p4 BY THE GUI BUTTONS)

	iporttime	=		0.01								;PORTAMENTO TIME
	kporttime	linseg	0,iporttime,iporttime,1,iporttime		;CREATE A RAMPING UP FUNCTION FOR PORTAMENTO TIME
	kamp1	portk	gkamp1, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp2	portk	gkamp2, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp3	portk	gkamp3, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp4	portk	gkamp4, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp5	portk	gkamp5, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp6	portk	gkamp6, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp7	portk	gkamp7, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp8	portk	gkamp8, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp9	portk	gkamp9, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp10	portk	gkamp10, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp11	portk	gkamp11, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp12	portk	gkamp12, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp13	portk	gkamp13, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp14	portk	gkamp14, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp15	portk	gkamp15, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp16	portk	gkamp16, kporttime					;APPLY PORTAMENTO TO SLIDER VARIABLE

	a1		oscili	kamp1,  icps, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a2		oscili	kamp2,  icps*2, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a3		oscili	kamp3,  icps*3, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a4		oscili	kamp4,  icps*4, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a5		oscili	kamp5,  icps*5, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a6		oscili	kamp6,  icps*6, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a7		oscili	kamp7,  icps*7, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a8		oscili	kamp8,  icps*8, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a9		oscili	kamp9,  icps*9, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a10		oscili	kamp10, icps*10, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a11		oscili	kamp11, icps*11, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a12		oscili	kamp12, icps*12, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a13		oscili	kamp13, icps*13, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a14		oscili	kamp14, icps*14, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a15		oscili	kamp15, icps*15, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE
	a16		oscili	kamp16, icps*16, gisine				;CREATE OSCILLATOR FOR PARTIAL OF ADDITIVE SYNTHESIS TONE

	asig		sum		a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16		;SUM (MIX) ALL PARTIALS
	aenv		expsegr	0.01,0.001,1,0.05,0.001								;CREATE AN AMPLITUDE ENVELOPE WITH A RELEASE SEGMENT
	asig		=		(asig*aenv*gkGlobAmp)/16								;SCALE AUDIO SIGNAL USING GLOBAL AMPLITUDE SLIDER VARIABLE, AMPLITUDE ENVELOPE AND ACCORDING TO THE NUMBER OF PARTIALS PRESENT
			outs		asig,asig											;SEND AUDIO TO OUTPUTS
endin
#

;EXECUTE MACRO FOR EACH GUI BUTTON
$GUI_INSTRUMENT(101'1)
$GUI_INSTRUMENT(102'2)
$GUI_INSTRUMENT(103'3)
$GUI_INSTRUMENT(104'4)
$GUI_INSTRUMENT(105'5)
$GUI_INSTRUMENT(106'6)
$GUI_INSTRUMENT(107'7)
$GUI_INSTRUMENT(108'8)
$GUI_INSTRUMENT(109'9)
$GUI_INSTRUMENT(110'10)
$GUI_INSTRUMENT(111'11)
$GUI_INSTRUMENT(112'12)
$GUI_INSTRUMENT(113'13)
$GUI_INSTRUMENT(114'14)
$GUI_INSTRUMENT(115'15)
$GUI_INSTRUMENT(116'16)
$GUI_INSTRUMENT(117'17)
$GUI_INSTRUMENT(118'18)
$GUI_INSTRUMENT(119'19)
$GUI_INSTRUMENT(120'20)
$GUI_INSTRUMENT(121'21)
$GUI_INSTRUMENT(122'22)
$GUI_INSTRUMENT(123'23)
$GUI_INSTRUMENT(124'24)
$GUI_INSTRUMENT(125'25)
$GUI_INSTRUMENT(126'26)
$GUI_INSTRUMENT(127'27)
$GUI_INSTRUMENT(128'28)
$GUI_INSTRUMENT(129'29)
$GUI_INSTRUMENT(130'30)
$GUI_INSTRUMENT(131'31)
$GUI_INSTRUMENT(132'32)
$GUI_INSTRUMENT(133'33)
$GUI_INSTRUMENT(134'34)
$GUI_INSTRUMENT(135'35)
$GUI_INSTRUMENT(136'36)
$GUI_INSTRUMENT(137'37)
$GUI_INSTRUMENT(138'38)
$GUI_INSTRUMENT(139'39)
</CsInstruments>
<CsScore>
i 10 0 3600	;GUI
i 11 0 0.1	;INIT
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>428</x>
 <y>423</y>
 <width>1097</width>
 <height>517</height>
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
  <width>1090</width>
  <height>310</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Equal Temperament / Just Intonation / Pythagorean Tuning Compare</label>
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
   <r>5</r>
   <g>27</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Mode</objectName>
  <x>548</x>
  <y>225</y>
  <width>180</width>
  <height>30</height>
  <uuid>{004ff588-9f8c-4edc-9dba-8f30f0605e3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Equal Temperament</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Just Intonation</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pythagorean</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>53</y>
  <width>50</width>
  <height>30</height>
  <uuid>{5682fe9d-e29a-40ac-9a5b-fbecaaf87e54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Equal</label>
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
  <x>2</x>
  <y>313</y>
  <width>1090</width>
  <height>200</height>
  <uuid>{62250ba1-6738-4cea-a686-cfae11291a02}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Comparing Tuning Systems  </label>
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
   <r>5</r>
   <g>27</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>330</y>
  <width>1078</width>
  <height>174</height>
  <uuid>{f0bc3e6c-8cfe-4b23-bf59-e0e11834e35f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This example allows users to compare the equal temperament, just intonation and pythagorean tuning systems in various ways. Equal temperament tuning is devised by dividing an octave into twelve equal intervals (semitones). The consequence of this is that none of the intervals created will represent any sort of simple ratio with respect to the starting pitch (apart from the octave). All intervals will be distorted (tempered) by varying degrees from the nearest simple ratio. The strength of equal temperament is that all keys sound equally tempered. The ratios used for just intonation (indicated as fractions on the key buttons) are derived from ratios revealed by the various degrees of the harmonic series. Most intervals will provide purer intervals without the 'beating' produced by equally tempered intervals. Pythagorean tuning intervals are derived by stacking perfect fifths (3/2) and fourths (4/3) and transposing intervals down by octaves (1/2) to bring them all within the same octave. Following this procedure all standard intervals can be created but the circle does not link up perfectly and an intervallic mismatch results between F# and C#.
Notes in the various tuning systems can be activated either using the GUI buttons or from a MIDI keyboard.</label>
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
  <objectName/>
  <x>54</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{144af7d7-87c7-43d6-8cad-15afe5ec171b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     C      </text>
  <image>/</image>
  <eventLine>i 101 0 -1 1.0</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>133</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{10eb3bec-76af-4450-8bee-351697b9bb29}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    C#    </text>
  <image>/</image>
  <eventLine>i 104 0 -1 1.059463094</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>212</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{6c1257d6-d7b3-4c4b-a867-690277191ed3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     D      </text>
  <image>/</image>
  <eventLine>i 107 0 -1 1.122462048</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>291</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{8b5c5889-930c-487e-992a-d4e2f511e639}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    D#    </text>
  <image>/</image>
  <eventLine>i 110 0 -1 1.189207115</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>370</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{65101e18-2394-4803-bf52-1983385a2c8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     E      </text>
  <image>/</image>
  <eventLine>i 113 0 -1 1.25992105</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>449</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{bc0b7753-f4e3-45f2-bbef-b23a2b9ef85b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     F      </text>
  <image>/</image>
  <eventLine>i 116 0 -1 1.334839854</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>528</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{9ea335cb-8753-4966-ad15-42ed759a51b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    F#     </text>
  <image>/</image>
  <eventLine>i 119 0 -1 1.414213562</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>607</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{67932dd1-47fc-4555-b8da-5e8a81005d80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     G      </text>
  <image>/</image>
  <eventLine>i 122 0 -1 1.498307077</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>686</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{bd4e3676-a4b7-48e5-bb4e-780d77860f1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    G#    </text>
  <image>/</image>
  <eventLine>i 125 0 -1 1.587401052</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>765</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{926e218b-1c1e-4f1d-988e-347e40db8cd7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     A      </text>
  <image>/</image>
  <eventLine>i 128 0 -1 1.681792831</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>844</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{2573c3a1-1d8a-4f00-b0a0-107086b6d75d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    A#    </text>
  <image>/</image>
  <eventLine>i 131 0 -1 1.781797436</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>96</y>
  <width>50</width>
  <height>30</height>
  <uuid>{ff2c2e98-28ca-4785-801e-17c61e979251}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Just</label>
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
  <objectName/>
  <x>54</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{61bb9335-2883-4842-8279-b038826aaa17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     C      </text>
  <image>/</image>
  <eventLine>i 102 0 -1 1.0</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>133</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{6228dda7-cd7d-43ed-8888-4d1bbcab0cd6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    C#
  16/15 </text>
  <image>/</image>
  <eventLine>i 105 0 -1 1.066666667</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>212</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{e9b1db0d-02fd-423d-bf4f-0b68226e878d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     D     
     9/8   </text>
  <image>/</image>
  <eventLine>i 108 0 -1 1.125</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>291</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{bdbf4441-a209-4707-95cb-41b5c8e6fbba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    D# 
    6/5   </text>
  <image>/</image>
  <eventLine>i 111 0 -1 1.2</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>370</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{ff74e9e3-9565-4228-b600-4435832c2ed7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     E     
     5/4   </text>
  <image>/</image>
  <eventLine>i 114 0 -1 1.25</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>449</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{2c51844e-c197-4f6d-8fff-7f36e96fd5d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     F     
     4/3   </text>
  <image>/</image>
  <eventLine>i 117 0 -1 1.333333333</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>528</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{1d8ee39f-08e3-46a8-8ebd-1e234ec7fbaa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    F#    
  45/32 </text>
  <image>/</image>
  <eventLine>i 120 0 -1 1.40625</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>607</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{8871bfb5-534f-4b9b-9f44-7481c6623ec0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     G     
     3/2   </text>
  <image>/</image>
  <eventLine>i 123 0 -1 1.5</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>686</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{7e79e02a-7e9f-4e2e-b09a-df7329587d7f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    G#    
    8/5    </text>
  <image>/</image>
  <eventLine>i 126 0 -1 1.6</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>765</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{6cb2105e-7259-4a1b-adc2-aa3809df8b4d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     A     
     5/3   </text>
  <image>/</image>
  <eventLine>i 129 0 -1 1.666666667</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>844</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{9ca00f6c-13c1-472f-83bc-2a2abd08308b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    A#    
    9/5    </text>
  <image>/</image>
  <eventLine>i 132 0 -1 1.8</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>139</y>
  <width>50</width>
  <height>30</height>
  <uuid>{33849c32-41dd-4949-9f94-9fbe58044395}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pyth</label>
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
  <objectName/>
  <x>54</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{32ab814c-e171-403c-af46-6488b2f6a044}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     C      </text>
  <image>/</image>
  <eventLine>i 103 0 -1 1.0</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>133</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{775b7d18-dd03-47df-9fdb-deb55dfa086e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    C#
256/243</text>
  <image>/</image>
  <eventLine>i 106 0 -1 1.053497942</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>212</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{3af65db2-10d7-47db-9d55-2091af3b5de2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     D     
     9/8   </text>
  <image>/</image>
  <eventLine>i 109 0 -1 1.125</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>291</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{92c8dcf8-6af2-441a-95b6-c480bed4426e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    D#    
 32/27 </text>
  <image>/</image>
  <eventLine>i 112 0 -1 1.185185185</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>370</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{f01ac087-c31b-4c7c-b406-e3065ef5b1da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     E    
  81/64  </text>
  <image>/</image>
  <eventLine>i 115 0 -1 1.265625</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>449</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{203ed1bb-02d4-4ca4-a847-fdc124bf75ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     F     
     4/3   </text>
  <image>/</image>
  <eventLine>i 118 0 -1 1.333333333</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>528</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{cc82cdb2-0d64-4c95-9d7d-30ec66514ce4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     F#
729/512</text>
  <image>/</image>
  <eventLine>i 121 0 -1 1.423828125</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>607</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{7a4f7d49-cbd0-4007-81a9-e4db38d1167f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     G     
     3/2   </text>
  <image>/</image>
  <eventLine>i 124 0 -1 1.5</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>686</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{0ac8a51c-18dc-46c7-bfdb-7c836f6599f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    G#    
 128/81 </text>
  <image>/</image>
  <eventLine>i 127 0 -1 1.580246914</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>765</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{bb5d0589-e10d-4ca0-8607-17f1a032bb7c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    A 
   27/16</text>
  <image>/</image>
  <eventLine>i 130 0 -1 1.6875</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>844</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{a54666ac-06a9-4976-8338-3c4f20572645}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    A#  
    16/9  </text>
  <image>/</image>
  <eventLine>i 133 0 -1 1.777777778</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>54</x>
  <y>180</y>
  <width>440</width>
  <height>122</height>
  <uuid>{aeed0302-b1ff-4e53-b266-457d2bc50a10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <borderradius>6</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>189</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{bdf98463-69b5-410a-a275-006405fbc7fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>1.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>205</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{d6a62e4b-f3f5-4334-90bf-e211233c60c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>221</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{1ca71fc0-7cee-4bbf-bb14-3dd70f4ec252}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.33333334</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>237</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{19521fe0-f9e6-4276-8f87-244e1e46d438}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.25000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>253</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{b1f7ed87-41e2-4b2b-b90d-292d664b4f98}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par5</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.20000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>269</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{27c45753-3da6-45bf-a6b6-6546bb860f0a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.16666667</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>285</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{184e17a1-d7b7-4de8-857c-4088b216c4a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par7</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.14285715</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>301</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{fc96f48d-e45b-4b80-806b-2a7da01f6ff3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.12500000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>317</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{aa2bbbf5-5596-4263-867d-3f4b9bcbb588}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par9</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.11111111</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>333</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{52242375-0b2e-425f-83c0-d6347636706b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par10</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.10000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>349</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{8212f46b-e6a8-4735-a430-6218c8859920}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par11</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.09090909</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>365</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{a315f7f4-cf47-48bc-97de-1ef0e6e0df28}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par12</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.08333334</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>381</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{fa85eaec-a613-4acb-88bf-44d2e36cf400}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par13</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.07692308</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>397</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{29c691f1-51cf-4d1d-a5de-5671964cdba1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par14</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.07142857</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>413</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{ae16b560-b300-4b9f-9a3c-739b93a04b80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par15</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.06666667</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>429</x>
  <y>194</y>
  <width>16</width>
  <height>80</height>
  <uuid>{60c01555-b3ec-4e03-94e4-02bb2f931f0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Par16</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.06250000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>808</x>
  <y>251</y>
  <width>199</width>
  <height>30</height>
  <uuid>{75986f4b-4680-42d6-8a6a-0512a4ac2ca2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Global Amplitude</label>
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
  <x>498</x>
  <y>226</y>
  <width>50</width>
  <height>30</height>
  <uuid>{24c9510b-6288-4f0b-835d-1fb69e2c34bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI</label>
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
  <x>189</x>
  <y>275</y>
  <width>300</width>
  <height>28</height>
  <uuid>{6f744640-d304-4b08-a6c6-24a0a96ae06f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1 -------------------------------------------------------- 16</label>
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
  <x>923</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{ecec89e6-0019-4ca5-8123-9058fafc38bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     B      </text>
  <image>/</image>
  <eventLine>i 134 0 -1 1.887748625</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>1002</x>
  <y>47</y>
  <width>80</width>
  <height>40</height>
  <uuid>{107062ba-57ac-45a9-a1fe-a6838597c89b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    C2     </text>
  <image>/</image>
  <eventLine>i 137 0 -1 2.0</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>923</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{a9690f39-2d61-43e2-93d4-a96100cc8c85}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     B  
    15/8  </text>
  <image>/</image>
  <eventLine>i 135 0 -1 1.875</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>1002</x>
  <y>90</y>
  <width>80</width>
  <height>40</height>
  <uuid>{e32ad9a0-ee9f-413e-a431-f4cee05136ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    C2     </text>
  <image>/</image>
  <eventLine>i 138 0 -1 2.0</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>923</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{c4e507ec-fe8a-4351-a194-ec435ac2b83e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     B
243/128</text>
  <image>/</image>
  <eventLine>i 136 0 -1 1.8984375</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>1002</x>
  <y>133</y>
  <width>80</width>
  <height>40</height>
  <uuid>{3201d7da-be07-4c20-9682-b4d462c4cae7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    C2     </text>
  <image>/</image>
  <eventLine>i 139 0 -1 2.0</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Amplitude</objectName>
  <x>756</x>
  <y>226</y>
  <width>300</width>
  <height>27</height>
  <uuid>{0807b000-00be-4a09-ada9-9b42cb21054a}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>34</x>
  <y>216</y>
  <width>131</width>
  <height>42</height>
  <uuid>{87a549b7-78f7-4373-bc51-9c9ea8ff8772}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Partial Strengths</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

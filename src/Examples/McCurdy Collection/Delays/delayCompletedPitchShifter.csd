;Written by Iain McCurdy, 2006

;Modified for QuteCsound by René, September 2010, updated Feb 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 32			;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


gihalfsine	ftgen	0, 0, 1025, 9, 0.5, 1, 0	;HALF SINE  WINDOW FUNCTION USED FOR AMPLITUDE ENVELOPING


opcode FilePlay2, aa, Skoo		; Credit to Joachim Heintz
	;gives stereo output regardless your soundfile is mono or stereo
	Sfil, kspeed, iskip, iloop	xin
	ichn		filenchnls	Sfil
	if ichn == 1 then
		aL		diskin2	Sfil, kspeed, iskip, iloop
		aR		=		aL
	else
		aL, aR	diskin2	Sfil, kspeed, iskip, iloop
	endif
		xout		aL, aR
endop


instr	10	;GUI
	gkGain	invalue	"Gain"			;init .5
	gktrans	invalue 	"Transposition"	;init 0
	gkdlt	invalue 	"Delay_Time"		;init .05
	gkFB		invalue	"Feedback"		;init 0
	gkinput	invalue	"Input"
	gkMix		invalue	"Mix"			;init 1
endin

instr	1	;PLAYS FILE
	if	gkinput=0	then
		Sfile	invalue	"_Browse1"
		;OUTPUT		OPCODE	FILE   | SPEED | INSKIP | LOOPING (0=OFF 1=ON)
		asigL, asigR	FilePlay2	Sfile,     1,       0,        1
	else
		asigL, asigR	ins
	endif
	aenv			linsegr	0,0.01,1,0.01,0					;ANTI CLICK ENVELOPE WITH RELEASE STAGE
	gasigL		=		asigL * gkGain * aenv				;RESCALE AUDIO SIGNAL WITH ON-SCREEN GAIN SLIDER
	gasigR		=		asigR * gkGain * aenv				;RESCALE AUDIO SIGNAL WITH ON-SCREEN GAIN SLIDER
endin

instr	2	;PITCH SHIFTER
	kporttime		linseg	0,0.001,0.005,1,0.005				;CREATE A VARIABLE FUNCTION THAT RAPIDLY RAMPS UP TO A SET VALUE
	ktrans		portk	gktrans, kporttime					;SMOOTH CHANGES IN SLIDER VARIABLE
	kdlt			portk	gkdlt, kporttime					;SMOOTH CHANGES IN SLIDER VARIABLE
	adlt			interp	kdlt			;CREATE A-RATE VERSION OF kdlt
	koctfract		=		ktrans/12							;TRANSPOSITION AS FRACTION OF AN OCTAVE
	kratio		=		cpsoct(8+koctfract)/cpsoct(8)			;RATIO OF NEW FREQ TO A DECLARED BASE FREQUENCY (MIDDLE C)
	krate		=		(kratio-1)/kdlt					;SUBTRACT 1/1 SPEED
	
	aphase1		phasor	-krate							;MOVING PHASE 1-0
	aphase2		phasor	-krate, .5						;MOVING PHASE 1-0 - PHASE OFFSET BY 180 DEGREES (.5 RADIANS)
	
	agate1		tablei	aphase1, gihalfsine, 1, 0, 1			;WINDOW FUNC =HALF SINE
	agate2		tablei	aphase2, gihalfsine, 1, 0, 1			;WINDOW FUNC =HALF SINE

	;LEFT CHANNEL===========================================================================================================================================================
	aignore		delayr	2								;DECLARE DELAY BUFFER
	adelsig1L		deltap3	aphase1 * adlt						;VARIABLE TAP
	aGatedSig1L	=		adelsig1L * agate1
				delayw	gasigL + (aGatedSig1L*gkFB)			;WRITE AUDIO TO THE BEGINNING OF THE DELAY BUFFER, MIX IN FEEDBACK SIGNAL - PROPORTION DEFINED BY gkFB
	
	aignore		delayr	2								;DECLARE DELAY BUFFER
	adelsig2L		deltap3	aphase2 * adlt						;VARIABLE TAP
	aGatedSig2L	=		adelsig2L * agate2
				delayw	gasigL + (aGatedSig2L*gkFB)			;WRITE AUDIO TO THE BEGINNING OF THE DELAY BUFFER, MIX IN FEEDBACK SIGNAL - PROPORTION DEFINED BY gkFB
	;=======================================================================================================================================================================

	;RIGHT CHANNEL==========================================================================================================================================================
	aignore		delayr	2								;DECLARE DELAY BUFFER
	adelsig1R		deltap3	aphase1 * adlt						;VARIABLE TAP
	aGatedSig1R	=		adelsig1R * agate1
				delayw	gasigR + (aGatedSig1R*gkFB)			;WRITE AUDIO TO THE BEGINNING OF THE DELAY BUFFER, MIX IN FEEDBACK SIGNAL - PROPORTION DEFINED BY gkFB
	
	aignore		delayr	2								;DECLARE DELAY BUFFER
	adelsig2R		deltap3	aphase2 * adlt						;VARIABLE TAP
	aGatedSig2R	=		adelsig2R * agate2
				delayw	gasigR + (aGatedSig2R*gkFB)			;WRITE AUDIO TO THE BEGINNING OF THE DELAY BUFFER, MIX IN FEEDBACK SIGNAL - PROPORTION DEFINED BY gkFB
	;=======================================================================================================================================================================
	aGatedMixL	=		(aGatedSig1L + aGatedSig2L) * .5		;SUM AND RESCALE PITCH SHIFTER OUTPUTS (LEFT CHANNEL)
	aGatedMixR	=		(aGatedSig1R + aGatedSig2R) * .5		;SUM AND RESCALE PITCH SHIFTER OUTPUTS (RIGHT CHANNEL)
	aL		ntrpol	gasigL,aGatedMixL,gkMix
	aR		ntrpol	gasigR,aGatedMixR,gkMix
			outs	aL, aR				;SEND AUDIO TO OUTPUTS
				clear	gasigL, gasigR						;CLEAR GLOBAL AUDIO VARIABLES
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		-1		;GUI
i  2      0         -1		;INSTRUMENT 2 PLAYS A HELD NOTE

f 0	  3600				;DUMMY SCORE EVENT KEEPS REALTIME PERFORMANCE GOING FOR 1 HOUR
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>1134</width>
 <height>413</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>241</r>
  <g>226</g>
  <b>185</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>3</x>
  <y>2</y>
  <width>516</width>
  <height>368</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Completed Pitch Shifter</label>
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
   <r>158</r>
   <g>220</g>
   <b>217</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>5</x>
  <y>5</y>
  <width>118</width>
  <height>29</height>
  <uuid>{487d5181-d838-4cce-9628-317fefc350cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>   ON / OFF</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain</objectName>
  <x>9</x>
  <y>60</y>
  <width>500</width>
  <height>27</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.47600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>78</y>
  <width>100</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
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
  <objectName>Gain</objectName>
  <x>449</x>
  <y>77</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.476</label>
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
  <x>518</x>
  <y>2</y>
  <width>606</width>
  <height>367</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Completed Pitch Shifter</label>
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
   <r>158</r>
   <g>220</g>
   <b>217</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>524</x>
  <y>19</y>
  <width>594</width>
  <height>346</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------------------------------------------
This example is an refinement of the 'Delay: Simple Pitch Shifter' example in that amplitude enveloping is employed to prevent glitching in the sound output whenever the sawtooth LFO waveform that modulates delay time instantaneously jumps from a maximum to a minimum (or vice versa). Two modulated delay taps (180 degrees out of phase with each other) are employed and are enveloped individually.
The outputs of the two delay taps are mixed to create an - as smooth as possible - pitch shifted output. Pitch shifting effects can also be produced using any of the granular synthesis opcodes but this method has the advantage that it can be applied to a streamed live audio input or a signal generated within Csound and it does not rely upon a stored function table.
Some experimentation with the setting for 'Delay Time' can enhance the resultant sound quality. An appropriate setting for 'Delay Time' is partially dependent upon the type of sound material being processed. Most hardware implementations of pitch shifters do not include this parameter. Large values for 'Delay Time' tend to temporally smear the processed sound whereas excessively small values for 'Delay Time' tend to distort the harmonic content of the original sound. The 'Feedback' control allows some of the pitch shifted output to be fed back into the input thus allowing the creation of arpeggiation effects.</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Transposition</objectName>
  <x>449</x>
  <y>117</y>
  <width>60</width>
  <height>30</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2.304</label>
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
  <x>9</x>
  <y>159</y>
  <width>120</width>
  <height>30</height>
  <uuid>{b57ba536-8f28-4986-9bf7-8eb84262d8ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Time</label>
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
  <objectName>Transposition</objectName>
  <x>9</x>
  <y>100</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b8fa76b9-3d04-4156-a2f2-a413d3864da3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-24.00000000</minimum>
  <maximum>24.00000000</maximum>
  <value>2.30400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Delay_Time</objectName>
  <x>448</x>
  <y>157</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5f670bb1-e411-4f17-94a3-2321fdf5742b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.101</label>
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
  <objectName>Delay_Time</objectName>
  <x>9</x>
  <y>140</y>
  <width>500</width>
  <height>27</height>
  <uuid>{1920efdc-fe11-4010-a22c-50efec0c27d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.10095000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>118</y>
  <width>160</width>
  <height>30</height>
  <uuid>{aea841b2-29e6-42d6-ac23-02439b1cc47f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Transposition (semitones)</label>
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
  <x>98</x>
  <y>261</y>
  <width>80</width>
  <height>30</height>
  <uuid>{429fca04-6933-4c2e-9e1a-301edbfcdc10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Source</label>
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
  <x>180</x>
  <y>263</y>
  <width>120</width>
  <height>30</height>
  <uuid>{45d19438-752c-4ed6-a700-3a764c5ab185}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Audio File</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Live</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Feedback</objectName>
  <x>10</x>
  <y>180</y>
  <width>500</width>
  <height>27</height>
  <uuid>{afe11ed2-eb11-423d-a391-3677ebeda4f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.18200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Feedback</objectName>
  <x>449</x>
  <y>197</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d6bd3764-66b6-499b-8028-0113ff526003}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.182</label>
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
  <x>8</x>
  <y>199</y>
  <width>120</width>
  <height>30</height>
  <uuid>{4100a5b8-76c3-4420-9229-a606f4defaf9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feedback</label>
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
  <x>10</x>
  <y>302</y>
  <width>170</width>
  <height>30</height>
  <uuid>{2f6cb425-0ff4-4d5c-8417-9ec219e24182}</uuid>
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
  <objectName>_Browse1</objectName>
  <x>182</x>
  <y>302</y>
  <width>330</width>
  <height>30</height>
  <uuid>{408db175-49b4-461e-81e8-fd44ab10814b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>AndItsAll.wav</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>182</x>
  <y>332</y>
  <width>330</width>
  <height>30</height>
  <uuid>{cc4ee995-e25a-4871-bb14-477ea340315b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Restart the instrument after changing the audio file.</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Mix</objectName>
  <x>8</x>
  <y>216</y>
  <width>500</width>
  <height>27</height>
  <uuid>{4789481d-2dc3-4414-9c94-80e2ff95c3cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>241</y>
  <width>80</width>
  <height>25</height>
  <uuid>{be3fcf6a-e523-4700-9b94-375bc6583a14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry / Wet Mix</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

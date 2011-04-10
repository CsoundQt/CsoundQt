;Written by Iain McCurdy, 2010

;Modified for QuteCsound by René, February 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table for exp slider
;	Replaced (1-kamp) by kamp in poscil3 amplitudes
;	Removed "Instructions and Info Panel" for the gui to fit in a 1200x800 screen

;	                            Beating
;	--------------------------------------------------------------------------------------------------------------------------------
;	'Beating' is the name given to the effect of amplitude modulation that occurs when two similar tones are sounded
;	together and detuned with respect to one other. Typically the frequencies of the two tones need to be within about 20 hertz
;	of each other in order for the effect of amplitude modulation to be perceived.
;	The effect will be most clearly heard when the two tones are sine waves.
;	The 'Base Frequency' slider controls the frequency of both the tones. The 'Detune' roller controls the amount by which
;	the second tone will be detuned with respect to the first. As detuning frequency is increased to around 15 hertz we
;	begin to lose track of the amplitude modulation effect and begin to perceive a tone with 'roughness'. As the detuning
;	is increased further the two tones un-fuse and we perceive two distinct pitches.
;	This example defaults to employing a sine wave for both of the tone but the user can add partials to explore
;	relationships between beating frequency and partial number. Beating frequency for the second partial will be twice that
;	for the first partial (fundemental), beat frequency for the third partial will be three times that for the first partial
;	and so on. As more partials are added the clear sense of amplitude modulation is lost and instead a periodic swirling is
;	perceived at the fundemental beat frequency. The phenomenon of beating is often used by string players and
;	guitarists to tune their instruments. Additionally, this example allows the user to offset the
;	second tone by a number of just intoned intervals (octave, fifth or a fourth). It can be observed how beating occurs
;	between different partials when the two tones are not in unison. When the interval is an octave, beating most clearly
;	occurs between partials 1 and 2, when the interval is a fifth between partials 2 and 3 and when the interval is a fourth
;	between partials 3 and 4. When 'binaural' mode is selected the two tones are sent separately to the left and right channels.
;	If headphones are used the beating effect effect no longer occurs acoustically but instead within the brain.
;	This effect is called 'binaural beating' and is sometimes used as a therapy for insomnia and to aid relaxation and concentration.
;	This technique is called 'brainwave entrainment' or 'brainwave synchronization'.
;	More information on this subject can easily be researched.


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine		ftgen	0, 0, 131072, 10, 1					;SINE WAVE
giintervals	ftgen	0, 0, 4, -2, 1, 2, 3/2, 4/3			;TABLE OF JUST INTONATION INTERVALS
giExp1		ftgen	0, 0, 129, -25, 0, 50.0, 128, 5000.0	;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;SLIDERS
		kcps			invalue	"BaseFreq"
		gkcps		tablei	kcps, giExp1, 1
					outvalue	"BaseFreq_Value", gkcps
		gkdtn		invalue 	"Detune"
		gkgain		invalue	"Gain"
		gkTone1Amp	invalue	"Tone1_Amp"
		gkTone2Amp	invalue	"Tone2_Amp"
		;PARTIAL STRENGTH SLIDERS
		gkamp1		invalue	"Partial1"
		gkamp2		invalue	"Partial2"
		gkamp3		invalue	"Partial3"
		gkamp4		invalue	"Partial4"
		gkamp5		invalue	"Partial5"
		gkamp6		invalue	"Partial6"
		gkamp7		invalue	"Partial7"
		gkamp8		invalue	"Partial8"
		gkamp9		invalue	"Partial9"
		gkamp10		invalue	"Partial10"
		gkamp11		invalue	"Partial11"
		gkamp12		invalue	"Partial12"
		gkamp13		invalue	"Partial13"
		gkamp14		invalue	"Partial14"
		gkamp15		invalue	"Partial15"
		gkamp16		invalue	"Partial16"
		;MENUS
		gkinterval 	invalue	"Interval"
		gkmode	 	invalue	"Mode"
	endif
endin

instr	1
	iporttime	=		0.05								;PORTAMENTO TIME
	kporttime	linseg	0,0.001,iporttime,1,iporttime			;RAMPING UP FUNCTION FOR PORTAMENTO TIME

	;APPLY PORTAMENTO TO SLIDER VARIABLE
	kamp1 	portk	gkamp1, kporttime
	kamp2 	portk	gkamp2, kporttime
	kamp3 	portk	gkamp3, kporttime
	kamp4 	portk	gkamp4, kporttime
	kamp5 	portk	gkamp5, kporttime
	kamp6 	portk	gkamp6, kporttime
	kamp7 	portk	gkamp7, kporttime
	kamp8 	portk	gkamp8, kporttime
	kamp9 	portk	gkamp9, kporttime
	kamp10	portk	gkamp10, kporttime
	kamp11	portk	gkamp11, kporttime
	kamp12	portk	gkamp12, kporttime
	kamp13	portk	gkamp13, kporttime
	kamp14	portk	gkamp14, kporttime
	kamp15	portk	gkamp15, kporttime
	kamp16	portk	gkamp16, kporttime
	kcps		portk	gkcps, kporttime
	kTone1Amp	portk	gkTone1Amp, kporttime
	kTone2Amp	portk	gkTone2Amp, kporttime
	kgain	portk	gkgain, kporttime
	
	kcps1	=		kcps								;PITCH (IN CYCLES PER SECOND) OF FIRST TONE
	kinterval	table	gkinterval, giintervals				;INTERVAL BY WHICH SECOND TONE WILL BE TRANSPOSED
	kcps2	=		(kcps*kinterval)+gkdtn				;PITCH (IN CYCLES PER SECOND) PF SECOND TONE

	;CREATE OSCILLATOR FOR PARTIAL OF FIRST ADDITIVE SYNTHESIS TONE
	a1_1 	poscil3	kamp1 , kcps1,    gisine
	a1_2 	poscil3	kamp2 , kcps1*2,  gisine
	a1_3 	poscil3	kamp3 , kcps1*3,  gisine
	a1_4 	poscil3	kamp4 , kcps1*4,  gisine
	a1_5 	poscil3	kamp5 , kcps1*5,  gisine
	a1_6 	poscil3	kamp6 , kcps1*6,  gisine
	a1_7 	poscil3	kamp7 , kcps1*7,  gisine
	a1_8 	poscil3	kamp8 , kcps1*8,  gisine
	a1_9 	poscil3	kamp9 , kcps1*9,  gisine
	a1_10	poscil3	kamp10, kcps1*10, gisine
	a1_11	poscil3	kamp11, kcps1*11, gisine
	a1_12	poscil3	kamp12, kcps1*12, gisine
	a1_13	poscil3	kamp13, kcps1*13, gisine
	a1_14	poscil3	kamp14, kcps1*14, gisine
	a1_15	poscil3	kamp15, kcps1*15, gisine
	a1_16	poscil3	kamp16, kcps1*16, gisine
	;SUM (MIX) ALL PARTIALS OF FIRST TONE
	a1		sum		a1_1,a1_2,a1_3,a1_4,a1_5,a1_6,a1_7,a1_8,a1_9,a1_10,a1_11,a1_12,a1_13,a1_14,a1_15,a1_16

	;CREATE OSCILLATOR FOR PARTIAL OF SECOND ADDITIVE SYNTHESIS TONE
	a2_1 	poscil3	kamp1 , kcps2,    gisine		
	a2_2 	poscil3	kamp2 , kcps2*2,  gisine
	a2_3 	poscil3	kamp3 , kcps2*3,  gisine
	a2_4 	poscil3	kamp4 , kcps2*4,  gisine
	a2_5 	poscil3	kamp5 , kcps2*5,  gisine
	a2_6 	poscil3	kamp6 , kcps2*6,  gisine
	a2_7 	poscil3	kamp7 , kcps2*7,  gisine
	a2_8 	poscil3	kamp8 , kcps2*8,  gisine
	a2_9 	poscil3	kamp9 , kcps2*9,  gisine
	a2_10	poscil3	kamp10, kcps2*10, gisine
	a2_11	poscil3	kamp11, kcps2*11, gisine
	a2_12	poscil3	kamp12, kcps2*12, gisine
	a2_13	poscil3	kamp13, kcps2*13, gisine
	a2_14	poscil3	kamp14, kcps2*14, gisine
	a2_15	poscil3	kamp15, kcps2*15, gisine
	a2_16	poscil3	kamp16, kcps2*16, gisine
		;SUM (MIX) ALL PARTIALS OF SECOND TONE
	a2		sum		a2_1,a2_2,a2_3,a2_4,a2_5,a2_6,a2_7,a2_8,a2_9,a2_10,a2_11,a2_12,a2_13,a2_14,a2_15,a2_16
	
	if	gkmode==0	then							;IF MONO MIX MODE IS SELECTED...
		amix	sum		a1*kTone1Amp, a2*kTone2Amp	;MIX THE TWO TONES
		amix	=		(amix*kgain) / 16			;RESCALE AMPLTUDE WITH 'Gain' SLIDER AND ALSO SCALE AMPLITUDE DOWN TO COMPENSATE FOR THE SUMMATION OF THE 16 PARTIALS
			outs		amix, amix				;SEND MIX OF TWO TONES TO EACH SPEAKER
	else										;ELSE (BINAURAL MODE IS SELECTED)...
		a1	=		(a1*kTone1Amp*kgain)/16		;RESCALE AMPLTUDE OF TONE 1 WITH 'TONE 1 AMPLITUDE' SLIDER AND ALSO SCALE AMPLITUDE DOWN TO COMPENSATE FOR THE SUMMATION OF THE 16 PARTIALS
		a2	=		(a2*kTone2Amp*kgain)/16		;RESCALE AMPLTUDE OF TONE 2 WITH 'TONE 2 AMPLITUDE' SLIDER AND ALSO SCALE AMPLITUDE DOWN TO COMPENSATE FOR THE SUMMATION OF THE 16 PARTIALS
			outs		a1, a2					;SEND TONE 1 AND TONE 2 SEPARATELY TO THE LEFT AND RIGHT SPEAKERS
	endif									;END OF CONDITIONAL BRANCHING
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>626</x>
 <y>271</y>
 <width>812</width>
 <height>328</height>
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
  <width>807</width>
  <height>323</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Beating</label>
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
  <text>  On / Off</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
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
  <label>Base Frequency (hertz)</label>
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
  <objectName>BaseFreq</objectName>
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
  <value>0.47200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>BaseFreq_Value</objectName>
  <x>448</x>
  <y>64</y>
  <width>60</width>
  <height>30</height>
  <uuid>{073ad371-9227-46fa-a005-ac10a210db79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>439.580</label>
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
  <y>285</y>
  <width>200</width>
  <height>30</height>
  <uuid>{b6afbe1e-677c-44a6-ba84-4c32dc21b0a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tone 2 Amplitude</label>
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
  <objectName>Tone2_Amp</objectName>
  <x>8</x>
  <y>262</y>
  <width>500</width>
  <height>27</height>
  <uuid>{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.35000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Tone2_Amp</objectName>
  <x>448</x>
  <y>285</y>
  <width>60</width>
  <height>30</height>
  <uuid>{95f6cb02-77ec-46fe-876b-a93efac3c5e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.350</label>
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
  <uuid>{7fd47947-fd0d-4964-85e5-682fed1916c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tone 1 Amplitude</label>
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
  <objectName>Tone1_Amp</objectName>
  <x>8</x>
  <y>209</y>
  <width>500</width>
  <height>27</height>
  <uuid>{475cdd64-a4ca-4ebc-a000-90448e932478}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.33000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Tone1_Amp</objectName>
  <x>448</x>
  <y>232</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.330</label>
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
  <y>179</y>
  <width>200</width>
  <height>30</height>
  <uuid>{3ebc1139-1fdb-48dc-9150-49ee8dfdbd4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Global Gain</label>
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
  <objectName>Gain</objectName>
  <x>8</x>
  <y>156</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2cf97843-5b49-438e-8034-62a459597e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.53400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gain</objectName>
  <x>448</x>
  <y>179</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e54486c5-f9aa-4d0e-9a67-6506dae3c790}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.534</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Detune</objectName>
  <x>8</x>
  <y>95</y>
  <width>500</width>
  <height>29</height>
  <uuid>{0836262b-c494-4286-bcbb-f3e0ad323dd8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>-100.00000000</xMin>
  <xMax>100.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Interval</objectName>
  <x>525</x>
  <y>286</y>
  <width>120</width>
  <height>30</height>
  <uuid>{8ea371ed-50f1-450f-b078-4a586bcef87b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Unison (1/1)</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Octave (2/1)</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Fifth (3/2)</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Fouth (4/3)</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Mode</objectName>
  <x>667</x>
  <y>286</y>
  <width>120</width>
  <height>30</height>
  <uuid>{f53bdee8-81e9-41c6-baae-fbcd5e84a69e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Mixed Mono</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Binaural</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>124</y>
  <width>140</width>
  <height>30</height>
  <uuid>{df793d36-bab0-482f-9c72-788309ce3c00}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Detune (Hertz)</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Detune</objectName>
  <x>448</x>
  <y>124</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fe0db982-6ed6-4ac3-bf81-7d9f8cf989b4}</uuid>
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
  <x>525</x>
  <y>41</y>
  <width>266</width>
  <height>215</height>
  <uuid>{bdd673e3-e25a-40f8-863d-d577728cfcd3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Partial Strengths</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>545</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{87938e2d-58f8-4df2-980a-5d9e090cde92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>559</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{40282ff6-1e2d-412d-984c-d5605ef962c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>573</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{485a7e91-6936-45d1-ac6b-21493edd0a4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>587</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{7ce39515-8510-4352-bac4-071d3634f03a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>601</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{b6cfa456-b479-4cee-a5c1-515e928a88b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial5</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>615</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{4aadcaea-41ec-41ff-93c1-dbca615c1473}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>629</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{89702924-67a8-4da8-a92e-655c6e31ff58}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial7</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>643</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{bfebe91b-6ba8-4779-8d64-d0c8478d6f5c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>657</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{36d92aa3-97ab-429c-a2d2-e28139f7b691}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial9</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>671</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{b3031351-252d-4e77-8ed0-743551ee41a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial10</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>685</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{7567c27b-656b-4639-b6ce-51cd5cf9576f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial11</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>699</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{bab86535-9562-415e-8026-48efe79e4b4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial12</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>713</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{bbb91654-f5cf-430c-8f3c-297d3e596a44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial13</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>727</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{2d41026d-d330-4aa5-897e-b9946fb6fc77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial14</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>741</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{c04a47d5-69c0-4385-9347-d08f483446a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial15</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>755</x>
  <y>77</y>
  <width>12</width>
  <height>130</height>
  <uuid>{a1620aa2-fd7e-44f2-92fc-5784545cb51e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Partial16</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.16666667</xValue>
  <yValue>1.00000000</yValue>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>537</x>
  <y>213</y>
  <width>240</width>
  <height>27</height>
  <uuid>{798870a8-da25-4230-ab04-fec3e1af83de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1 --------------------------------------------------16</label>
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
  <x>525</x>
  <y>263</y>
  <width>120</width>
  <height>24</height>
  <uuid>{6decaf4d-be74-4edb-8815-51176aca4329}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Interval:</label>
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
  <x>667</x>
  <y>263</y>
  <width>120</width>
  <height>24</height>
  <uuid>{6301b17e-6aa3-43c8-a22b-e743ae806fcf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mode:</label>
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
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

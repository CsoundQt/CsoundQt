;Written by Iain McCurdy, 2009


; Modified for QuteCsound by René, November 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Instrument 1 is activated by MIDI and by the GUI
;	Cannot display more than one space in Label, so can't display the schematic shown below:

	;Phase Modulation Synthesis: modulator->modulator->carrier
	;-----------------------------------------------------------

	;                      +---------+
	;                      | MOD. 1  |
	;                      +----+----+
	;                           |
	;                      +----+----+
	;                      | MOD. 2  |
	;                      +----+----+
	;                           |
	;                      +----+----+
	;                      | CARRIER |
	;                      +----+----+
	;                           |
	;                           V
	;                          OUT


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


			zakinit	2,2

gisine		ftgen	0,0,65537,10,1							;A SINE WAVE THAT CAN BE REFERENCED BY THE GLOBAL VARIABLE 'gisine'
giExp20000	ftgen	0, 0, 129, -25, 0, 20.0, 128, 20000.0		;TABLES FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		kbasefreq		invalue 	"Base_Frequency"
		gkbasefreq	tablei	kbasefreq, giExp20000, 1
					outvalue	"Base_Frequency_Value", gkbasefreq		
		gkindex1		invalue 	"Modulation_Index_1"
		gkindex2		invalue 	"Modulation_Index_2"

		gkCarRatio	invalue	"Carrier_Frequency"
		gkModRatio1	invalue	"Modulator1_Frequency"
		gkModRatio2	invalue	"Modulator2_Frequency"	
		gkCarAmp		invalue 	"Carrier_Amplitude"

		gkChoDep		invalue 	"Chorus_Depth"
		gkChoRte		invalue 	"Chorus_Rate"
		gkChoMix		invalue 	"Chorus_Mix"
	endif
endin

instr	1	;FM INSTRUMENT
	if p4!=0 then												;MIDI
		ioct		= p4											;READ OCT VALUE FROM MIDI INPUT
		iamp		= p5											;READ midi-velocity-amp FROM MIDI INPUT
		kCarAmp	= iamp * gkCarAmp								;SET AMPLITUDE TO RECEIVED p5 (I.E. MIDI VELOCITY) MULTIPLIED BY SLIDER "Carrier_Amplitude"
		kindex1	= iamp * gkindex1
		kindex2	= iamp * gkindex2
		;PITCH BEND===========================================================================================================================================================
		iSemitoneBendRange = 4									;PITCH BEND RANGE IN SEMITONES
		imin		= 0											;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333					;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax							;PITCH BEND VARIABLE (IN oct FORMAT)
		kbasefreq	=	cpsoct(ioct + kbend)						;SET FUNDEMENTAL FROM MIDI
		;=====================================================================================================================================================================
	else														;GUI
		kbasefreq = gkbasefreq									;SET FUNDEMENTAL FROM GUI SLIDER "Base_Frequency"
		kCarAmp	= gkCarAmp									;SET kamp TO SLIDER VALUE "Carrier_Amplitude"
		kindex1	= gkindex1
		kindex2	= gkindex2
	endif

	iporttime		=		.01									;PORTAMENTO FUNCTION (WILL BE USED TO SMOOTH PARAMETER MOVED BY WIDGETS)
	kporttime		linseg	0,.001,iporttime,1,iporttime				;PORTAMENTO FUNCTION (WILL BE USED TO SMOOTH PARAMETER MOVED BY WIDGETS)
	
	kindex1		portk	kindex1, kporttime						;APPLY SMOOTHING PORTAMENTO TO THE VARIABLE 'kindex1'
	kindex2		portk	kindex2, kporttime						;APPLY SMOOTHING PORTAMENTO TO THE VARIABLE 'kindex2'
	kbasefreq		portk	kbasefreq, kporttime					;APPLY SMOOTHING PORTAMENTO TO THE VARIABLE 'kbasefreq'
	kCarAmp		portk	kCarAmp, kporttime						;APPLY SMOOTHING PORTAMENTO TO THE VARIABLE 'kCarAmp'

	aModPhase1	phasor	kbasefreq * gkModRatio1					;CREATE A MOVING PHASE VALUE THAT WILL BE USED TO READ CREATE MODULATOR 1
	aModulator1	tablei	aModPhase1,gisine,1,0,1					;MODULATOR 1 IS CREATED                                                  
	aModulator1	=		aModulator1*kindex1						;MODULATOR 1 AMPLITUDE RESCALED                                          

	aModPhase2	phasor	kbasefreq * gkModRatio2					;CREATE A MOVING PHASE VALUE THAT WILL BE USED TO READ CREATE MODULATOR 2
	aModPhase2	=		aModPhase2 + aModulator1					;MODULATOR 1 SIGNAL IS ADDED TO MODULATOR 2 PHASE VARIABLE
	aModulator2	tablei	aModPhase2,gisine,1,0,1					;MODULATOR 2 OSCILLATOR IS CREATED
	aModulator2	=		aModulator2 * kindex2					;MODULATOR 2 AMPLITUDE RESCALED

	aCarrPhase	phasor	kbasefreq * gkCarRatio					;CREATE A MOVING PHASE VALUE THAT WILL BE USED TO READ CREATE THE CARRIER
	aCarrPhase	=		aCarrPhase + aModulator2					;MODULATOR 2 SIGNAL IS ADDED TO CARRIER PHASE VARIABLE
	aCarrier		tablei	aCarrPhase,gisine,1,0,1					;MODULATOR OSCILLATOR IS CREATED
	aAntiClick	linsegr	0,0.001,1,0.01,0						;ANTI CLICK ENVELOPE
	aCarrier	=			aCarrier*kCarAmp*aAntiClick				;CARRIER AMPLITUDE IS RESCALED
				zawm		aCarrier, 1							;MIX PM SYNTHESIZED TONES INTO ZAK AUDIO CHANNEL 1
endin

instr	2	;INIT
		outvalue	"_SetPresetIndex", 0
endin

instr	3	;CHORUS
	iporttime		=		0.05									;DEFINE A RAMPING UP VARIABLE THAT WILL BE USED FOR PORTAMENTO TIME
	kporttime		linseg	0,0.01,iporttime,1,iporttime    			;DEFINE A RAMPING UP VARIABLE THAT WILL BE USED FOR PORTAMENTO TIME		
	kChoDep		portk	gkChoDep, kporttime             			;APPLY PORTAMENTO SMOOTHING TO SLIDER VARIABLE gkChoDep
	ain			zar		1									;READ AUDIO FROM ZAK CHANNEL 1
	ichooffset	init		.001									;OFFSET TIME FOR CHORUSING DELAY
	achodepth		interp	kChoDep								;CONVERT kChoDep TO A-RATE
	kchofrq		randomi	-gkChoRte, gkChoRte, 1					;CREATE CHORUS RATE VARIABLE AS RANDOMLY MOVING VARIABLE THE RANGE OF WHICH IS DEFINED BY SLIDER 'Chorus Rate'
	adlt			oscili	kChoDep * 0.5, kchofrq*gkChoRte, gisine		;CREATE DELAY TIME VARIABLE
	adlt			=		adlt + (achodepth * 0.5) + ichooffset		;OFFSET DELAY TIME VARIABLE
	
	imaxdlt		init		1									;DEFINE MAXIMUM DELAY TIME
	abuffer		delayr	1									;SET UP DELAY BUFFER
	atap			deltap3	adlt									;READ A DELAY TAP FROM THE BUFFER
				delayw	ain									;WRITE AUDIO INTO BUFFER
				zawm		atap, 2								;MIX CHORUSED TONES INTO ZAK CHANNEL 2
endin

instr	4	;AUDIO OUTPUT
	adry		zar		1										;READ DRY SIGNAL FROM ZAK CHANNEL 1
	acho		zar		2										;READ CHORUSED AUDIO FROM ZAK CHANNEL 2
	amix		ntrpol	adry, acho, gkChoMix						;MIX DRY AND CHORUSED AND AUDIO
			outs		amix, amix								;SEND AUDIO TO OUTPUTS
			zacl		0,2										;CLEAR ZAK VARIABLES
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI

i 2	     0.1		 0		;INIT

i 3 		0		3600		;CHORUS VOICES
i 3 		0		3600		;CHORUS VOICES
i 3 		0		3600		;CHORUS VOICES
i 3 		0		3600		;CHORUS VOICES
i 3 		0		3600		;CHORUS VOICES
i 3 		0		3600		;CHORUS VOICES
i 3 		0		3600		;CHORUS VOICES
i 3 		0		3600		;CHORUS VOICES
i 3 		0		3600		;CHORUS VOICES
i 4 		0		3600		;AUDIO OUTPUT
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>379</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
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
  <width>513</width>
  <height>500</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
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
  <x>514</x>
  <y>2</y>
  <width>280</width>
  <height>301</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
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
  <x>524</x>
  <y>67</y>
  <width>263</width>
  <height>205</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------
An implementation of phase modulation synthesis in which a modulator modulates another modulator which in turn modulates a carrier.
Additionally the output of the synthesizer is passed through a chorus effect.
To bypass this effect set 'Chorus Dry/Wet Mix' to zero.</label>
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
  <x>8</x>
  <y>6</y>
  <width>124</width>
  <height>30</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> ON / OFF (MIDI)</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Carrier_Amplitude</objectName>
  <x>448</x>
  <y>328</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.200</label>
  <alignment>right</alignment>
  <font>Arial</font>
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
  <objectName>Carrier_Amplitude</objectName>
  <x>8</x>
  <y>305</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>328</y>
  <width>180</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Carrier Amplitude</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>73</x>
  <y>201</y>
  <width>358</width>
  <height>83</height>
  <uuid>{53a95371-23f7-4d54-a6c6-63bbabdb388d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>173</x>
  <y>203</y>
  <width>32</width>
  <height>46</height>
  <uuid>{81ded06c-d53f-4a6d-a597-5f1b68b18042}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>27</fontsize>
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
  <objectName>Modulator1_Frequency</objectName>
  <x>89</x>
  <y>213</y>
  <width>80</width>
  <height>28</height>
  <uuid>{6f8fc775-201d-40f9-931b-687c9b3ef417}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Modulator2_Frequency</objectName>
  <x>212</x>
  <y>213</y>
  <width>80</width>
  <height>28</height>
  <uuid>{fd4b783c-f008-4a1c-b2e6-50340aad9093}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>89</x>
  <y>241</y>
  <width>70</width>
  <height>50</height>
  <uuid>{d7a84933-3d3a-4adf-8289-84a4413362a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulator 1
Frequency</label>
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
  <x>336</x>
  <y>241</y>
  <width>70</width>
  <height>50</height>
  <uuid>{7723878b-fcac-4444-84a2-a4ba87008431}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Carrier
Frequency</label>
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
  <x>8</x>
  <y>86</y>
  <width>180</width>
  <height>30</height>
  <uuid>{541ace1b-b1de-4c04-8d84-1de90288dded}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Base Frequency</label>
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
  <objectName>Base_Frequency</objectName>
  <x>8</x>
  <y>63</y>
  <width>500</width>
  <height>27</height>
  <uuid>{eac88081-deaa-45c0-b896-32a3ffedc74a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.13400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Base_Frequency_Value</objectName>
  <x>448</x>
  <y>86</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3be43919-ad18-4aef-b554-03c4b4d991c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>50.479</label>
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
  <y>129</y>
  <width>180</width>
  <height>30</height>
  <uuid>{0c691576-66a5-4aa6-a82c-48f930da9708}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulation Index 1</label>
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
  <objectName>Modulation_Index_1</objectName>
  <x>8</x>
  <y>106</y>
  <width>500</width>
  <height>27</height>
  <uuid>{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}</uuid>
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
  <objectName>Modulation_Index_2</objectName>
  <x>448</x>
  <y>171</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c03c8ac7-b287-4328-8e07-bbf81f16291a}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Modulation_Index_2</objectName>
  <x>8</x>
  <y>148</y>
  <width>500</width>
  <height>27</height>
  <uuid>{9e41022a-6d97-415e-82ef-dafd223f6de8}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>171</y>
  <width>180</width>
  <height>30</height>
  <uuid>{dd30e1bc-c2a4-4d61-8df6-fafe394c7687}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulation Index 2</label>
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
  <x>213</x>
  <y>241</y>
  <width>70</width>
  <height>50</height>
  <uuid>{a41c9bd7-bf11-4aeb-99d0-39e0949d0da0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulator 2
Frequency</label>
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
  <objectName>Carrier_Frequency</objectName>
  <x>336</x>
  <y>213</y>
  <width>80</width>
  <height>28</height>
  <uuid>{4613a393-76fd-495c-8e3b-95f1257e8326}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>297</x>
  <y>203</y>
  <width>32</width>
  <height>46</height>
  <uuid>{42146cc9-014a-446b-94e1-296f9c3f8fdb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>27</fontsize>
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
  <x>155</x>
  <y>5</y>
  <width>305</width>
  <height>35</height>
  <uuid>{c35c6c13-7799-4395-9775-f3006b3eafcb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Phase Modulation Synthesis</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
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
  <x>114</x>
  <y>28</y>
  <width>387</width>
  <height>31</height>
  <uuid>{20b81ac9-e24a-4a60-bdb1-2c3bc2c578cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>modulator->modulator->carrier</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
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
  <x>514</x>
  <y>28</y>
  <width>288</width>
  <height>50</height>
  <uuid>{dd72e305-5880-4889-b044-bf9d9333880b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>modulator->modulator->carrier</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
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
  <x>530</x>
  <y>5</y>
  <width>250</width>
  <height>35</height>
  <uuid>{28873f9f-f41a-4961-9ae9-c3948ecc50f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Phase Modulation Synthesis</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
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
  <objectName>Modulation_Index_1</objectName>
  <x>448</x>
  <y>126</y>
  <width>60</width>
  <height>30</height>
  <uuid>{eb489cb5-93a5-43ca-bd05-14ec2a67e140}</uuid>
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
  <y>372</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7ab7dcd1-0b6f-4f11-9b36-c6a2ea0e5a87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chorus Depth</label>
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
  <objectName>Chorus_Depth</objectName>
  <x>8</x>
  <y>349</y>
  <width>500</width>
  <height>27</height>
  <uuid>{9d01a407-9af0-4e24-a903-b4f08bce805b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.03000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Chorus_Depth</objectName>
  <x>448</x>
  <y>372</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f9c26af6-6311-452e-9cd9-51e286efef9a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.030</label>
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
  <y>415</y>
  <width>180</width>
  <height>30</height>
  <uuid>{c1848eda-3576-47f9-87b0-7fdfd3708a73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chorus Rate</label>
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
  <objectName>Chorus_Rate</objectName>
  <x>8</x>
  <y>392</y>
  <width>500</width>
  <height>27</height>
  <uuid>{dcfe5f2a-7d7c-4523-a789-ad0183784c14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Chorus_Rate</objectName>
  <x>448</x>
  <y>415</y>
  <width>60</width>
  <height>30</height>
  <uuid>{cb37672a-f349-4dbb-8223-f12d94559811}</uuid>
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
  <y>458</y>
  <width>180</width>
  <height>30</height>
  <uuid>{ca32d821-6eae-4414-b0f6-678fa719fcd2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chorus Dry/Wet Mix</label>
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
  <objectName>Chorus_Mix</objectName>
  <x>8</x>
  <y>435</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0412e819-ba3c-46f5-8a6f-1e7d1dd51c4c}</uuid>
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
  <objectName>Chorus_Mix</objectName>
  <x>448</x>
  <y>458</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8ed8cdda-b744-40df-a909-00fa169f66fc}</uuid>
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
</bsbPanel>
<bsbPresets>
<preset name="Init" number="0" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.20000000</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.200</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.20000000</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >3.00099993</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >5.00099993</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.13400000</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >50.47920990</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >50.479</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >0.25000000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >0.25000000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >0.250</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >0.25000000</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >1.00000000</value>
<value id="{eb489cb5-93a5-43ca-bd05-14ec2a67e140}" mode="1" >0.25000000</value>
<value id="{eb489cb5-93a5-43ca-bd05-14ec2a67e140}" mode="4" >0.250</value>
<value id="{9d01a407-9af0-4e24-a903-b4f08bce805b}" mode="1" >0.03000000</value>
<value id="{f9c26af6-6311-452e-9cd9-51e286efef9a}" mode="1" >0.03000000</value>
<value id="{f9c26af6-6311-452e-9cd9-51e286efef9a}" mode="4" >0.030</value>
<value id="{dcfe5f2a-7d7c-4523-a789-ad0183784c14}" mode="1" >1.00000000</value>
<value id="{cb37672a-f349-4dbb-8223-f12d94559811}" mode="1" >1.00000000</value>
<value id="{cb37672a-f349-4dbb-8223-f12d94559811}" mode="4" >1.000</value>
<value id="{0412e819-ba3c-46f5-8a6f-1e7d1dd51c4c}" mode="1" >0.50000000</value>
<value id="{8ed8cdda-b744-40df-a909-00fa169f66fc}" mode="1" >0.50000000</value>
<value id="{8ed8cdda-b744-40df-a909-00fa169f66fc}" mode="4" >0.500</value>
</preset>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 72 179 400 200
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView background {61937, 58082, 47545}
ioText {2, 2} {513, 500} label 0.000000 0.00100 "" center "DejaVu Sans" 18 {65280, 65280, 65280} {1280, 6912, 38400} nobackground noborder 
ioText {514, 2} {280, 301} label 0.000000 0.00100 "" center "DejaVu Sans" 18 {65280, 65280, 65280} {1280, 6912, 38400} nobackground noborder 
ioText {524, 67} {263, 205} label 0.000000 0.00100 "" left "Liberation Sans" 14 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder --------------------------------------------------------------------Â¬An implementation of phase modulation synthesis in which a modulator modulates another modulator which in turn modulates a carrier.Â¬Additionally the output of the synthesizer is passed through a chorus effect.Â¬To bypass this effect set 'Chorus Dry/Wet Mix' to zero.
ioButton {8, 6} {124, 30} event 1.000000 "" " ON / OFF (MIDI)" "/" i 1 0 -1
ioText {448, 328} {60, 30} display 0.200000 0.00100 "Carrier_Amplitude" right "Arial" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 0.200
ioSlider {8, 305} {500, 27} 0.000000 1.000000 0.200000 Carrier_Amplitude
ioText {8, 328} {180, 30} label 0.000000 0.00100 "" left "Arial" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Carrier Amplitude
ioText {73, 201} {358, 83} label 0.000000 0.00100 "" left "Arial" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 
ioText {173, 203} {32, 46} label 0.000000 0.00100 "" center "DejaVu Sans" 27 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder :
ioText {89, 213} {80, 28} editnum 0.125000 0.000100 "Modulator1_Frequency" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.125000
ioText {212, 213} {80, 28} editnum 0.125000 0.000100 "Modulator2_Frequency" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.125000
ioText {89, 241} {70, 50} label 0.000000 0.00100 "" center "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Modulator 1Â¬Frequency
ioText {336, 241} {70, 50} label 0.000000 0.00100 "" center "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder CarrierÂ¬Frequency
ioText {8, 86} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Base Frequency
ioSlider {8, 63} {500, 27} 0.000000 1.000000 0.134000 Base_Frequency
ioText {448, 86} {60, 30} display 50.479000 0.00100 "Base_Frequency_Value" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 50.479
ioText {8, 129} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Modulation Index 1
ioSlider {8, 106} {500, 27} 0.000000 1.000000 0.250000 Modulation_Index_1
ioText {448, 171} {60, 30} display 0.250000 0.00100 "Modulation_Index_2" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 0.250
ioSlider {8, 148} {500, 27} 0.000000 1.000000 0.250000 Modulation_Index_2
ioText {8, 171} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Modulation Index 2
ioText {213, 241} {70, 50} label 0.000000 0.00100 "" center "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Modulator 2Â¬Frequency
ioText {336, 213} {80, 28} editnum 0.125000 0.000100 "Carrier_Frequency" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.125000
ioText {297, 203} {32, 46} label 0.000000 0.00100 "" center "DejaVu Sans" 27 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder :
ioText {155, 5} {305, 35} label 0.000000 0.00100 "" center "Liberation Sans" 18 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Phase Modulation Synthesis
ioText {114, 28} {387, 31} label 0.000000 0.00100 "" center "Liberation Sans" 18 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder modulator->modulator->carrier
ioText {514, 28} {288, 50} label 0.000000 0.00100 "" center "Liberation Sans" 18 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder modulator->modulator->carrier
ioText {530, 5} {250, 35} label 0.000000 0.00100 "" center "Liberation Sans" 18 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Phase Modulation Synthesis
ioText {448, 126} {60, 30} display 0.250000 0.00100 "Modulation_Index_1" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 0.250
ioText {8, 372} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Chorus Depth
ioSlider {8, 349} {500, 27} 0.000000 0.100000 0.030000 Chorus_Depth
ioText {448, 372} {60, 30} display 0.030000 0.00100 "Chorus_Depth" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 0.030
ioText {8, 415} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Chorus Rate
ioSlider {8, 392} {500, 27} 0.000000 10.000000 1.000000 Chorus_Rate
ioText {448, 415} {60, 30} display 1.000000 0.00100 "Chorus_Rate" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 1.000
ioText {8, 458} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Chorus Dry/Wet Mix
ioSlider {8, 435} {500, 27} 0.000000 1.000000 0.500000 Chorus_Mix
ioText {448, 458} {60, 30} display 0.500000 0.00100 "Chorus_Mix" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 0.500
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

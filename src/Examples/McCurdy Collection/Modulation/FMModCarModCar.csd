;Written by Iain McCurdy, 2008


; Modified for QuteCsound by René, November 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Instrument 1 is activated by MIDI and by the GUI
;	Removed presets (included in QuteCsound)	
;	Cannot display more than one space in Label, so can't display the schematic shown below:

	;   FM Synthesis: Modulator->Carrier / Modulator->Carrier
	;-----------------------------------------------------------
	;               +-----+      +-----+
	;               |MOD.1|      |MOD.2|
	;               +--+--+      +--+--+
	;                  |            |
	;               +--+--+      +--+--+
	;               |CAR.1|      |CAR.2|
	;               +--+--+      +--+--+
	;                  |            |
	;                  +------+-----+
	;                         |
	;                         V
	;                        OUT


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 1		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine		ftgen	0, 0, 4096, 10, 1						;FUNCTION TABLE THAT STORES A SINGLE CYCLE OF A SINE WAVE
giExp20000	ftgen	0, 0, 129, -25, 0, 20.0, 128, 20000.0		;TABLES FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		kbasefreq		invalue 	"Base_Frequency"
		gkbasefreq	tablei	kbasefreq, giExp20000, 1
					outvalue	"Base_Frequency_Value", gkbasefreq		
		gkFTune1		invalue 	"Fine_Tune_1"
		gkFTune2		invalue 	"Fine_Tune_2"
		gkindex1		invalue 	"Modulation_Index_1"
		gkindex2		invalue 	"Modulation_Index_2"
		gkCar1Amp		invalue 	"Carrier_Amplitude_1"
		gkCar2Amp		invalue 	"Carrier_Amplitude_2"
		gkGain		invalue 	"Master_Gain"
		gkCar1Ratio	invalue	"Carrier1_Frequency"
		gkMod1Ratio	invalue	"Modulator1_Frequency"
		gkCar2Ratio	invalue	"Carrier2_Frequency"
		gkMod2Ratio	invalue	"Modulator2_Frequency"
	endif
endin

instr	1	;FM INSTRUMENT
	if p4!=0 then													;MIDI
		ioct		= p4												;READ OCT VALUE FROM MIDI INPUT
		iamp		= p5												;READ midi-velocity-amp FROM MIDI INPUT
		kCar1Amp	= iamp * gkCar1Amp									;SET AMPLITUDE TO RECEIVED p5 RECEIVED FROM INSTR 1 (I.E. MIDI VELOCITY) MULTIPLIED BY SLIDER gkCar1Amp.
		kCar2Amp	= iamp * gkCar2Amp									;SET AMPLITUDE TO RECEIVED p5 RECEIVED FROM INSTR 1 (I.E. MIDI VELOCITY) MULTIPLIED BY SLIDER gkCar2Amp.
		kindex1	= iamp * gkindex1
		kindex2	= iamp * gkindex2
		;PITCH BEND===========================================================================================================================================================
		iSemitoneBendRange = 4										;PITCH BEND RANGE IN SEMITONES
		imin		= 0												;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333						;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax								;PITCH BEND VARIABLE (IN oct FORMAT)
		kbasefreq	=	cpsoct(ioct + kbend)							;SET FUNDEMENTAL FROM MIDI
		;=====================================================================================================================================================================
	else															;GUI
		kbasefreq	= gkbasefreq
		kCar1Amp	= gkCar1Amp										;SET kCar1Amp TO SLIDER VALUE gkCar1Amp
		kCar2Amp	= gkCar2Amp										;SET kCar2Amp TO SLIDER VALUE gkCar2Amp
		kindex1	= gkindex1
		kindex2	= gkindex2
	endif

	iporttime		=		.02										;PORTAMENTO TIME (TO BE APPLIED TO K-RATE VARIABLES IN ORDER TO IMPLEMENT DAMPING)
	kporttime		linseg	0, .001, iporttime, 1, iporttime				;FINAL VARIABLE WILL RAMP UP
	
	kbasefreq		portk	kbasefreq, kporttime						;PORTAMENTO APPLIED
	kindex1		portk	kindex1, kporttime							;PORTAMENTO APPLIED
	kindex2		portk	kindex2, kporttime							;PORTAMENTO APPLIED
	kCar1Amp		portk	kCar1Amp, kporttime							;PORTAMENTO APPLIED
	kCar2Amp		portk	kCar2Amp, kporttime							;PORTAMENTO APPLIED
	kFTune1		portk	gkFTune1,  kporttime						;PORTAMENTO APPLIED
	kFTune2		portk	gkFTune2,  kporttime						;PORTAMENTO APPLIED
	kGain		portk	gkGain,  kporttime							;PORTAMENTO APPLIED
	
	kMltplier1	=	cpsoct(8+(kFTune1*.001*(5/6)))/cpsoct(8)
	kMltplier2	=	cpsoct(8+(kFTune2*.001*(5/6)))/cpsoct(8)
	
	kpeakdeviation1	=	kbasefreq * kindex1							;CALCUALATE THE PEAK DEVIATION OF THE MODULATOR FROM THE VALUES GIVEN FOR BASE FREQUENCY AND THE INDEX OF MODULATION
	kpeakdeviation2	=	kbasefreq * kindex2							;CALCUALATE THE PEAK DEVIATION OF THE MODULATOR FROM THE VALUES GIVEN FOR BASE FREQUENCY AND THE INDEX OF MODULATION

	aAntiClick	linsegr	0,0.001,1,0.01,0							;ANTI CLICK ENVELOPE
	
	;OUTPUT		OPCODE	AMPLITUDE            |     FREQUENCY                         		    | FUNCTION_TABLE
	aModulator1	oscili	kpeakdeviation1,      kbasefreq * gkMod1Ratio * kMltplier1,                  gisine			;DEFINE THE MODULATOR WAVEFORM
	aCarrier1		oscili	kCar1Amp*aAntiClick,  ((kbasefreq * gkCar1Ratio) + aModulator1) * kMltplier1, gisine			;DEFINE THE CARRIER WAVEFORM (NOTE HOW ITS FREQUENCY IS MODULATED (THROUGH ADDITION) BY THE AUDIO OUTPUT OF THE MODULATOR WAVEFORM)
	aModulator2	oscili	kpeakdeviation2,      (kbasefreq * gkMod2Ratio) * kMltplier2,                 gisine			;DEFINE THE MODULATOR WAVEFORM
	aCarrier2		oscili	kCar2Amp*aAntiClick,  ((kbasefreq * gkCar2Ratio) + aModulator2) * kMltplier2, gisine			;DEFINE THE CARRIER WAVEFORM (NOTE HOW ITS FREQUENCY IS MODULATED (THROUGH ADDITION) BY THE AUDIO OUTPUT OF THE MODULATOR WAVEFORM)
	aMix			sum		aCarrier1, aCarrier2
				outs		aMix*.5*kGain, aMix*.5*kGain														;SEND THE AUDIO OUTPUT OF THE CARRIERS TO THE OUTPUTS 

	ktrig	  	metro	10																			;CREATE A REPEATING TRIGGER SIGNAL
	if ktrig == 1 then
			outvalue		"Peak_Dev_1", kpeakdeviation1
			outvalue		"Peak_Dev_2", kpeakdeviation2
	endif
endin

instr	2	;INIT
		outvalue	"_SetPresetIndex", 0
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0	   3600		;GUI
i 2	     0.1		 0		;INIT
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>344</x>
 <y>245</y>
 <width>833</width>
 <height>484</height>
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
  <width>536</width>
  <height>480</height>
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
  <x>538</x>
  <y>2</y>
  <width>289</width>
  <height>245</height>
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
  <x>542</x>
  <y>56</y>
  <width>282</width>
  <height>188</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------
This example demonstrates a four oscillator algorithm that combines the audio outputs of two modulator-carrier pairs.
Each carrier-modulator pair has a fine tune control which facilitates detuning of both the modulator and the carrier of that pair.
This function facilitates the introduction of beating effects between the two oscillator pairs.</label>
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
  <objectName>Master_Gain</objectName>
  <x>460</x>
  <y>411</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.800</label>
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
  <objectName>Master_Gain</objectName>
  <x>20</x>
  <y>388</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.80000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>20</x>
  <y>411</y>
  <width>180</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Master Gain</label>
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
  <x>19</x>
  <y>90</y>
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
  <x>19</x>
  <y>67</y>
  <width>500</width>
  <height>27</height>
  <uuid>{eac88081-deaa-45c0-b896-32a3ffedc74a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.23295900</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Base_Frequency_Value</objectName>
  <x>459</x>
  <y>90</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3be43919-ad18-4aef-b554-03c4b4d991c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>100.000</label>
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
  <x>155</x>
  <y>5</y>
  <width>305</width>
  <height>35</height>
  <uuid>{c35c6c13-7799-4395-9775-f3006b3eafcb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FM Synthesis</label>
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
  <label>Modulator->Modulator->Carrier</label>
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
  <x>540</x>
  <y>28</y>
  <width>288</width>
  <height>50</height>
  <uuid>{dd72e305-5880-4889-b044-bf9d9333880b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulator->Modulator->Carrier</label>
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
  <x>571</x>
  <y>5</y>
  <width>250</width>
  <height>35</height>
  <uuid>{28873f9f-f41a-4961-9ae9-c3948ecc50f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FM Synthesis</label>
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
  <x>132</x>
  <y>436</y>
  <width>294</width>
  <height>38</height>
  <uuid>{024ca7a4-84dd-4d37-bbb5-1963bc37de79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Presets</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>_SetPresetIndex</objectName>
  <x>189</x>
  <y>441</y>
  <width>44</width>
  <height>28</height>
  <uuid>{dace86e6-2bd1-4e11-8230-036973772d8f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <maximum>10</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_GetPresetName</objectName>
  <x>241</x>
  <y>440</y>
  <width>180</width>
  <height>30</height>
  <uuid>{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Init</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
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
  <x>6</x>
  <y>119</y>
  <width>262</width>
  <height>260</height>
  <uuid>{492a6416-ef71-4571-9aad-d354d427a342}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>271</x>
  <y>119</y>
  <width>262</width>
  <height>260</height>
  <uuid>{b2074a69-e364-44d9-965c-8611a942d0c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Fine_Tune_1</objectName>
  <x>202</x>
  <y>148</y>
  <width>60</width>
  <height>30</height>
  <uuid>{19817529-3f8b-44d0-9a9a-67d17b4b37e7}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Fine_Tune_1</objectName>
  <x>12</x>
  <y>125</y>
  <width>250</width>
  <height>27</height>
  <uuid>{22c04b50-69c8-4d1e-bd32-2681a17bf37c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-100.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>148</y>
  <width>180</width>
  <height>30</height>
  <uuid>{0568f562-1c69-4e8e-b2c5-d587f753e160}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fine Tune (Cents) 1</label>
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
  <x>88</x>
  <y>219</y>
  <width>80</width>
  <height>38</height>
  <uuid>{6cdfbd9c-bcd2-42fe-86dc-d1c1f273d105}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>P Dev 1</label>
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
  <objectName>Peak_Dev_1</objectName>
  <x>156</x>
  <y>215</y>
  <width>60</width>
  <height>28</height>
  <uuid>{6043e5fb-a628-4042-86fd-70a7c77c775a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>300.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
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
  <x>34</x>
  <y>290</y>
  <width>70</width>
  <height>50</height>
  <uuid>{431fb03d-454f-484f-bea4-f4cc6a19ba49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Carrier 1
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
  <x>157</x>
  <y>290</y>
  <width>70</width>
  <height>50</height>
  <uuid>{548865dd-f4ee-48cc-bd60-a96291ee52ba}</uuid>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Modulator1_Frequency</objectName>
  <x>156</x>
  <y>261</y>
  <width>80</width>
  <height>28</height>
  <uuid>{300e441a-2169-4b87-8eac-e6b4b1963e0f}</uuid>
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
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Carrier1_Frequency</objectName>
  <x>34</x>
  <y>261</y>
  <width>80</width>
  <height>28</height>
  <uuid>{4ccc97ef-2ce5-465c-bf12-0f2cfebd1ca7}</uuid>
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
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>118</x>
  <y>251</y>
  <width>32</width>
  <height>46</height>
  <uuid>{7e299a1b-7b46-4b1d-9d11-304c6e06c0dc}</uuid>
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
  <x>12</x>
  <y>354</y>
  <width>180</width>
  <height>30</height>
  <uuid>{f366971a-6a33-479f-b52e-f235b6132e07}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Carrier Amplitude 1</label>
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
  <objectName>Carrier_Amplitude_1</objectName>
  <x>12</x>
  <y>331</y>
  <width>250</width>
  <height>27</height>
  <uuid>{b7efd329-6510-45a9-94f0-78a54b87fff8}</uuid>
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
  <objectName>Carrier_Amplitude_1</objectName>
  <x>202</x>
  <y>354</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b2fc8a45-cd01-4b05-86d9-02f362081001}</uuid>
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
  <x>12</x>
  <y>191</y>
  <width>180</width>
  <height>30</height>
  <uuid>{705344d8-23fc-4323-ae65-f795a4fed44a}</uuid>
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
  <x>12</x>
  <y>168</y>
  <width>250</width>
  <height>27</height>
  <uuid>{e5ffeffc-7a8c-4ebf-98d2-f9ce13cb903d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>50.00000000</maximum>
  <value>3.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Modulation_Index_1</objectName>
  <x>202</x>
  <y>191</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bca63915-625a-402d-bd80-8f18abc114ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3.000</label>
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
  <objectName>Modulation_Index_2</objectName>
  <x>468</x>
  <y>191</y>
  <width>60</width>
  <height>30</height>
  <uuid>{97a069e0-3849-4942-ac00-0ac762893744}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3.000</label>
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
  <x>278</x>
  <y>168</y>
  <width>250</width>
  <height>27</height>
  <uuid>{f663bfda-6700-47d6-b0cf-b54aedc6b2a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>50.00000000</maximum>
  <value>3.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>278</x>
  <y>191</y>
  <width>180</width>
  <height>30</height>
  <uuid>{b4108041-4ee2-45b5-976d-faafc1186380}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Carrier_Amplitude_2</objectName>
  <x>468</x>
  <y>354</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0811f410-5216-48ad-ae60-0a1f122f28e7}</uuid>
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
  <objectName>Carrier_Amplitude_2</objectName>
  <x>278</x>
  <y>331</y>
  <width>250</width>
  <height>27</height>
  <uuid>{85ae5c05-d87f-428f-8137-43dcd6a3b478}</uuid>
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
  <x>278</x>
  <y>354</y>
  <width>180</width>
  <height>30</height>
  <uuid>{9c26fc9e-47c4-4121-9f67-fd47c21afecb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Carrier Amplitude 2</label>
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
  <x>384</x>
  <y>251</y>
  <width>32</width>
  <height>46</height>
  <uuid>{16e81a17-fb48-4e48-937a-6cde4a39adf3}</uuid>
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
  <objectName>Carrier2_Frequency</objectName>
  <x>300</x>
  <y>261</y>
  <width>80</width>
  <height>28</height>
  <uuid>{9d38f46c-5c31-4fc1-acf7-fe37a4a69dfe}</uuid>
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
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Modulator2_Frequency</objectName>
  <x>422</x>
  <y>261</y>
  <width>80</width>
  <height>28</height>
  <uuid>{b26bd75c-d565-4767-b55d-fe88c5039ef7}</uuid>
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
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>423</x>
  <y>290</y>
  <width>70</width>
  <height>50</height>
  <uuid>{b5bdfe63-bf87-430c-bc37-afa162f78f65}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>300</x>
  <y>290</y>
  <width>70</width>
  <height>50</height>
  <uuid>{6287b0be-80fd-4c73-8efd-606eef1d28cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Carrier 2
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Peak_Dev_2</objectName>
  <x>422</x>
  <y>215</y>
  <width>60</width>
  <height>28</height>
  <uuid>{d02c396b-85ed-4972-b83f-7ef7a2255ea7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>300.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
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
  <x>354</x>
  <y>219</y>
  <width>80</width>
  <height>38</height>
  <uuid>{f1d9d325-283a-4be3-867b-2ce170aedcf4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>P Dev 2</label>
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
  <x>278</x>
  <y>148</y>
  <width>180</width>
  <height>30</height>
  <uuid>{16f9c06a-d78a-4191-8737-dc6b0e5e71aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fine Tune (Cents) 2</label>
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
  <objectName>Fine_Tune_2</objectName>
  <x>278</x>
  <y>125</y>
  <width>250</width>
  <height>27</height>
  <uuid>{6ad05378-e543-444d-86f0-d8f3f0d31cbb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-100.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Fine_Tune_2</objectName>
  <x>468</x>
  <y>148</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f4ccbe4b-c888-49c9-9139-69f14cb57215}</uuid>
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
</bsbPanel>
<bsbPresets>
<preset name="Init" number="0" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.80000001</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.800</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.80000001</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.23295900</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >99.99994659</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >100.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="1" >0.00000000</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="4" >0.000</value>
<value id="{22c04b50-69c8-4d1e-bd32-2681a17bf37c}" mode="1" >0.00000000</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="1" >299.99984741</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="4" >300.000</value>
<value id="{300e441a-2169-4b87-8eac-e6b4b1963e0f}" mode="1" >1.00000000</value>
<value id="{4ccc97ef-2ce5-465c-bf12-0f2cfebd1ca7}" mode="1" >1.00000000</value>
<value id="{b7efd329-6510-45a9-94f0-78a54b87fff8}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="4" >0.500</value>
<value id="{e5ffeffc-7a8c-4ebf-98d2-f9ce13cb903d}" mode="1" >3.00000000</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="1" >3.00000000</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="4" >3.000</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="1" >3.00000000</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="4" >3.000</value>
<value id="{f663bfda-6700-47d6-b0cf-b54aedc6b2a9}" mode="1" >3.00000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="1" >0.50000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="4" >0.500</value>
<value id="{85ae5c05-d87f-428f-8137-43dcd6a3b478}" mode="1" >0.50000000</value>
<value id="{9d38f46c-5c31-4fc1-acf7-fe37a4a69dfe}" mode="1" >1.00000000</value>
<value id="{b26bd75c-d565-4767-b55d-fe88c5039ef7}" mode="1" >1.00000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="1" >299.99984741</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="4" >300.000</value>
<value id="{6ad05378-e543-444d-86f0-d8f3f0d31cbb}" mode="1" >0.00000000</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="1" >0.00000000</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="4" >0.000</value>
</preset>
<preset name="Preset 1" number="1" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.80000001</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.800</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.80000001</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.23148599</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >98.99987793</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >99.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >1.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 1</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="1" >-4.00000000</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="4" >-4.000</value>
<value id="{22c04b50-69c8-4d1e-bd32-2681a17bf37c}" mode="1" >-4.00000000</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="1" >128.78280640</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="4" >128.783</value>
<value id="{300e441a-2169-4b87-8eac-e6b4b1963e0f}" mode="1" >1.29999995</value>
<value id="{4ccc97ef-2ce5-465c-bf12-0f2cfebd1ca7}" mode="1" >1.00000000</value>
<value id="{b7efd329-6510-45a9-94f0-78a54b87fff8}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="4" >0.500</value>
<value id="{e5ffeffc-7a8c-4ebf-98d2-f9ce13cb903d}" mode="1" >3.00000000</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="1" >3.00000000</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="4" >3.000</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="1" >3.00000000</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="4" >3.000</value>
<value id="{f663bfda-6700-47d6-b0cf-b54aedc6b2a9}" mode="1" >3.00000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="1" >0.50000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="4" >0.500</value>
<value id="{85ae5c05-d87f-428f-8137-43dcd6a3b478}" mode="1" >0.50000000</value>
<value id="{9d38f46c-5c31-4fc1-acf7-fe37a4a69dfe}" mode="1" >1.00000000</value>
<value id="{b26bd75c-d565-4767-b55d-fe88c5039ef7}" mode="1" >1.30200005</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="1" >128.78280640</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="4" >128.783</value>
<value id="{6ad05378-e543-444d-86f0-d8f3f0d31cbb}" mode="1" >1.33000004</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="1" >1.33000004</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="4" >1.330</value>
</preset>
<preset name="Preset 2" number="2" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.80000001</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.800</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.80000001</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.33474699</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >202.00012207</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >202.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >2.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 2</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="1" >-17.33300018</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="4" >-17.333</value>
<value id="{22c04b50-69c8-4d1e-bd32-2681a17bf37c}" mode="1" >-17.33300018</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="1" >300.00000000</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="4" >300.000</value>
<value id="{300e441a-2169-4b87-8eac-e6b4b1963e0f}" mode="1" >1.97599995</value>
<value id="{4ccc97ef-2ce5-465c-bf12-0f2cfebd1ca7}" mode="1" >1.00000000</value>
<value id="{b7efd329-6510-45a9-94f0-78a54b87fff8}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="4" >0.500</value>
<value id="{e5ffeffc-7a8c-4ebf-98d2-f9ce13cb903d}" mode="1" >5.30000019</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="1" >5.30000019</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="4" >5.300</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="1" >3.29999995</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="4" >3.300</value>
<value id="{f663bfda-6700-47d6-b0cf-b54aedc6b2a9}" mode="1" >3.29999995</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="1" >0.50000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="4" >0.500</value>
<value id="{85ae5c05-d87f-428f-8137-43dcd6a3b478}" mode="1" >0.50000000</value>
<value id="{9d38f46c-5c31-4fc1-acf7-fe37a4a69dfe}" mode="1" >1.00000000</value>
<value id="{b26bd75c-d565-4767-b55d-fe88c5039ef7}" mode="1" >1.30200005</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="1" >300.00000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="4" >300.000</value>
<value id="{6ad05378-e543-444d-86f0-d8f3f0d31cbb}" mode="1" >0.44440001</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="1" >0.44400001</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="4" >0.444</value>
</preset>
<preset name="Preset 3" number="3" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.80000001</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.800</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.80000001</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.23295900</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >99.99994659</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >100.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >3.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 3</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="1" >0.00000000</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="4" >0.000</value>
<value id="{22c04b50-69c8-4d1e-bd32-2681a17bf37c}" mode="1" >0.00000000</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="1" >78.51667023</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="4" >78.517</value>
<value id="{300e441a-2169-4b87-8eac-e6b4b1963e0f}" mode="1" >1.00000000</value>
<value id="{4ccc97ef-2ce5-465c-bf12-0f2cfebd1ca7}" mode="1" >1.00000000</value>
<value id="{b7efd329-6510-45a9-94f0-78a54b87fff8}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="4" >0.500</value>
<value id="{e5ffeffc-7a8c-4ebf-98d2-f9ce13cb903d}" mode="1" >3.00000000</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="1" >3.00000000</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="4" >3.000</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="1" >3.00000000</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="4" >3.000</value>
<value id="{f663bfda-6700-47d6-b0cf-b54aedc6b2a9}" mode="1" >3.00000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="1" >0.50000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="4" >0.500</value>
<value id="{85ae5c05-d87f-428f-8137-43dcd6a3b478}" mode="1" >0.50000000</value>
<value id="{9d38f46c-5c31-4fc1-acf7-fe37a4a69dfe}" mode="1" >1.00000000</value>
<value id="{b26bd75c-d565-4767-b55d-fe88c5039ef7}" mode="1" >1.00000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="1" >78.51667023</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="4" >78.517</value>
<value id="{6ad05378-e543-444d-86f0-d8f3f0d31cbb}" mode="1" >0.00000000</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="1" >0.00000000</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="4" >0.000</value>
</preset>
<preset name="Preset 4" number="4" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.80000001</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.800</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.80000001</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.17496499</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >67.00029755</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >67.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >4.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 4</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="1" >-0.44400001</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="4" >-0.444</value>
<value id="{22c04b50-69c8-4d1e-bd32-2681a17bf37c}" mode="1" >-0.44440001</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="1" >300.00000000</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="4" >300.000</value>
<value id="{300e441a-2169-4b87-8eac-e6b4b1963e0f}" mode="1" >4.00000000</value>
<value id="{4ccc97ef-2ce5-465c-bf12-0f2cfebd1ca7}" mode="1" >5.00000000</value>
<value id="{b7efd329-6510-45a9-94f0-78a54b87fff8}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="4" >0.500</value>
<value id="{e5ffeffc-7a8c-4ebf-98d2-f9ce13cb903d}" mode="1" >7.33300018</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="1" >7.33300018</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="4" >7.333</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="1" >4.00000000</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="4" >4.000</value>
<value id="{f663bfda-6700-47d6-b0cf-b54aedc6b2a9}" mode="1" >4.00000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="1" >0.50000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="4" >0.500</value>
<value id="{85ae5c05-d87f-428f-8137-43dcd6a3b478}" mode="1" >0.50000000</value>
<value id="{9d38f46c-5c31-4fc1-acf7-fe37a4a69dfe}" mode="1" >3.00000000</value>
<value id="{b26bd75c-d565-4767-b55d-fe88c5039ef7}" mode="1" >2.00000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="1" >300.00000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="4" >300.000</value>
<value id="{6ad05378-e543-444d-86f0-d8f3f0d31cbb}" mode="1" >17.33300018</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="1" >17.33300018</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="4" >17.333</value>
</preset>
<preset name="Preset 5" number="5" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.80000001</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.800</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.80000001</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.22398700</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >94.00043488</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >94.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >5.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 5</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="1" >-4.00000000</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="4" >-4.000</value>
<value id="{22c04b50-69c8-4d1e-bd32-2681a17bf37c}" mode="1" >-4.00000000</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="1" >300.00000000</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="4" >300.000</value>
<value id="{300e441a-2169-4b87-8eac-e6b4b1963e0f}" mode="1" >4.00000000</value>
<value id="{4ccc97ef-2ce5-465c-bf12-0f2cfebd1ca7}" mode="1" >7.00000000</value>
<value id="{b7efd329-6510-45a9-94f0-78a54b87fff8}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="4" >0.500</value>
<value id="{e5ffeffc-7a8c-4ebf-98d2-f9ce13cb903d}" mode="1" >26.00000000</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="1" >26.00000000</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="4" >26.000</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="1" >16.00000000</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="4" >16.000</value>
<value id="{f663bfda-6700-47d6-b0cf-b54aedc6b2a9}" mode="1" >16.00000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="1" >0.50000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="4" >0.500</value>
<value id="{85ae5c05-d87f-428f-8137-43dcd6a3b478}" mode="1" >0.50000000</value>
<value id="{9d38f46c-5c31-4fc1-acf7-fe37a4a69dfe}" mode="1" >9.00000000</value>
<value id="{b26bd75c-d565-4767-b55d-fe88c5039ef7}" mode="1" >5.00000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="1" >300.00000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="4" >300.000</value>
<value id="{6ad05378-e543-444d-86f0-d8f3f0d31cbb}" mode="1" >-1.33299994</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="1" >-1.33299994</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="4" >-1.333</value>
</preset>
<preset name="Preset 6" number="6" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.80000001</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.800</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.80000001</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.24541400</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >108.99982452</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >109.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >6.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 6</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="1" >-9.33300018</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="4" >-9.333</value>
<value id="{22c04b50-69c8-4d1e-bd32-2681a17bf37c}" mode="1" >-9.33300018</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="1" >300.00000000</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="4" >300.000</value>
<value id="{300e441a-2169-4b87-8eac-e6b4b1963e0f}" mode="1" >2.00000000</value>
<value id="{4ccc97ef-2ce5-465c-bf12-0f2cfebd1ca7}" mode="1" >1.00000000</value>
<value id="{b7efd329-6510-45a9-94f0-78a54b87fff8}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="4" >0.500</value>
<value id="{e5ffeffc-7a8c-4ebf-98d2-f9ce13cb903d}" mode="1" >26.00000000</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="1" >26.00000000</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="4" >26.000</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="1" >16.00000000</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="4" >16.000</value>
<value id="{f663bfda-6700-47d6-b0cf-b54aedc6b2a9}" mode="1" >16.00000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="1" >0.50000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="4" >0.500</value>
<value id="{85ae5c05-d87f-428f-8137-43dcd6a3b478}" mode="1" >0.50000000</value>
<value id="{9d38f46c-5c31-4fc1-acf7-fe37a4a69dfe}" mode="1" >1.00000000</value>
<value id="{b26bd75c-d565-4767-b55d-fe88c5039ef7}" mode="1" >4.00000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="1" >300.00000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="4" >300.000</value>
<value id="{6ad05378-e543-444d-86f0-d8f3f0d31cbb}" mode="1" >0.44440001</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="1" >0.44400001</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="4" >0.444</value>
</preset>
<preset name="Preset 7" number="7" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.80000001</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.800</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.80000001</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.52976501</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >777.00048828</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >777.001</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >7.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 7</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="1" >-2.22199988</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="4" >-2.222</value>
<value id="{22c04b50-69c8-4d1e-bd32-2681a17bf37c}" mode="1" >-2.22199988</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="1" >300.00000000</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="4" >300.000</value>
<value id="{300e441a-2169-4b87-8eac-e6b4b1963e0f}" mode="1" >0.75000000</value>
<value id="{4ccc97ef-2ce5-465c-bf12-0f2cfebd1ca7}" mode="1" >1.00000000</value>
<value id="{b7efd329-6510-45a9-94f0-78a54b87fff8}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="4" >0.500</value>
<value id="{e5ffeffc-7a8c-4ebf-98d2-f9ce13cb903d}" mode="1" >2.66669989</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="1" >2.66700006</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="4" >2.667</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="1" >3.77800012</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="4" >3.778</value>
<value id="{f663bfda-6700-47d6-b0cf-b54aedc6b2a9}" mode="1" >3.77780008</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="1" >0.50000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="4" >0.500</value>
<value id="{85ae5c05-d87f-428f-8137-43dcd6a3b478}" mode="1" >0.50000000</value>
<value id="{9d38f46c-5c31-4fc1-acf7-fe37a4a69dfe}" mode="1" >1.00000000</value>
<value id="{b26bd75c-d565-4767-b55d-fe88c5039ef7}" mode="1" >0.50000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="1" >300.00000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="4" >300.000</value>
<value id="{6ad05378-e543-444d-86f0-d8f3f0d31cbb}" mode="1" >0.44440001</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="1" >0.44400001</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="4" >0.444</value>
</preset>
<preset name="Preset 8" number="8" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.80000001</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.800</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.80000001</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.42057419</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >365.45953369</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >365.460</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >8.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 8</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="1" >-0.44400001</value>
<value id="{19817529-3f8b-44d0-9a9a-67d17b4b37e7}" mode="4" >-0.444</value>
<value id="{22c04b50-69c8-4d1e-bd32-2681a17bf37c}" mode="1" >-0.44400001</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="1" >300.00000000</value>
<value id="{6043e5fb-a628-4042-86fd-70a7c77c775a}" mode="4" >300.000</value>
<value id="{300e441a-2169-4b87-8eac-e6b4b1963e0f}" mode="1" >2.29999995</value>
<value id="{4ccc97ef-2ce5-465c-bf12-0f2cfebd1ca7}" mode="1" >3.17000008</value>
<value id="{b7efd329-6510-45a9-94f0-78a54b87fff8}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="1" >0.50000000</value>
<value id="{b2fc8a45-cd01-4b05-86d9-02f362081001}" mode="4" >0.500</value>
<value id="{e5ffeffc-7a8c-4ebf-98d2-f9ce13cb903d}" mode="1" >1.77779996</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="1" >1.77800000</value>
<value id="{bca63915-625a-402d-bd80-8f18abc114ad}" mode="4" >1.778</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="1" >2.22199988</value>
<value id="{97a069e0-3849-4942-ac00-0ac762893744}" mode="4" >2.222</value>
<value id="{f663bfda-6700-47d6-b0cf-b54aedc6b2a9}" mode="1" >2.22219992</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="1" >0.50000000</value>
<value id="{0811f410-5216-48ad-ae60-0a1f122f28e7}" mode="4" >0.500</value>
<value id="{85ae5c05-d87f-428f-8137-43dcd6a3b478}" mode="1" >0.50000000</value>
<value id="{9d38f46c-5c31-4fc1-acf7-fe37a4a69dfe}" mode="1" >1.17499995</value>
<value id="{b26bd75c-d565-4767-b55d-fe88c5039ef7}" mode="1" >4.36999989</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="1" >300.00000000</value>
<value id="{d02c396b-85ed-4972-b83f-7ef7a2255ea7}" mode="4" >300.000</value>
<value id="{6ad05378-e543-444d-86f0-d8f3f0d31cbb}" mode="1" >0.44440001</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="1" >0.44400001</value>
<value id="{f4ccbe4b-c888-49c9-9139-69f14cb57215}" mode="4" >0.444</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

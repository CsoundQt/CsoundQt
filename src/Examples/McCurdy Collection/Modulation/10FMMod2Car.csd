;Written by Iain McCurdy, 2008


; Modified for QuteCsound by René, November 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Instrument 1 is activated by MIDI and by the GUI
;	Removed presets (included in QuteCsound)	
;	Cannot display more than one space in Label, so can't display the schematic shown below:

	;   FM Synthesis: Modulator -> 2 Carriers
	;-------------------------------------------
	;           +-----+
	;           |MOD. |
	;           +--+--+
	;              |
	;       +------+-----+
	;       |            |
	;    +--+--+      +--+--+
	;    |CAR.1|      |CAR.2|
	;    +--+--+      +--+--+
	;       |            |
	;       +------+-----+
	;              |
	;              V
	;             OUT


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
		gkindex		invalue 	"Modulation_Index"
		gkCar1Amp		invalue 	"Carrier1_Amplitude"
		gkCar2Amp		invalue 	"Carrier2_Amplitude"
		gkCar1Ratio	invalue	"Carrier1_Frequency"
		gkCar2Ratio	invalue	"Carrier2_Frequency"
		gkModRatio	invalue	"Modulator_Frequency"
		gkGain		invalue 	"Master_Gain"
	endif
endin

instr	1	;FM INSTRUMENT
	if p4!=0 then													;MIDI
		ioct		= p4												;READ OCT VALUE FROM MIDI INPUT
		iamp		= p5												;READ midi-velocity-amp FROM MIDI INPUT
		kCar1Amp	= iamp * gkCar1Amp									;SET AMPLITUDE TO RECEIVED p5 RECEIVED FROM INSTR 1 (I.E. MIDI VELOCITY) MULTIPLIED BY SLIDER gkCar1Amp.
		kCar2Amp	= iamp * gkCar2Amp									;SET AMPLITUDE TO RECEIVED p5 RECEIVED FROM INSTR 1 (I.E. MIDI VELOCITY) MULTIPLIED BY SLIDER gkCar2Amp.
		kindex	= iamp * gkindex
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
		kindex	= gkindex
	endif
	
	iporttime		=		.02										;PORTAMENTO TIME (TO BE APPLIED TO K-RATE VARIABLES IN ORDER TO IMPLEMENT DAMPING)
	kporttime		linseg	0, .001, iporttime, 1, iporttime				;FINAL VARIABLE WILL RAMP UP
	
	kbasefreq		portk	kbasefreq, kporttime						;PORTAMENTO APPLIED
	kindex		portk	kindex, kporttime							;PORTAMENTO APPLIED
	kCar1Amp		portk	kCar1Amp, kporttime							;PORTAMENTO APPLIED
	kCar2Amp		portk	kCar2Amp, kporttime							;PORTAMENTO APPLIED
	kGain		portk	gkGain, kporttime							;PORTAMENTO APPLIED

	kpeakdeviation	=		kbasefreq * kindex							;CALCUALATE THE PEAK DEVIATION OF THE MODULATOR FROM THE VALUES GIVEN FOR BASE FREQUENCY AND THE INDEX OF MODULATION
	
	aAntiClick	linsegr	0,0.001,1,0.01,0							;ANTI CLICK ENVELOPE

	;OUTPUT		OPCODE	AMPLITUDE           |     FREQUENCY                        | FUNCTION_TABLE
	aModulator	oscili	kpeakdeviation,       kbasefreq * gkModRatio,                gisine		;DEFINE THE MODULATOR WAVEFORM
	aCarrier1		oscili	kCar1Amp*aAntiClick, (kbasefreq * gkCar1Ratio) + aModulator, gisine		;DEFINE THE CARRIER WAVEFORM (NOTE HOW ITS FREQUENCY IS MODULATED (THROUGH ADDITION) BY THE AUDIO OUTPUT OF THE MODULATOR WAVEFORM)
	aCarrier2		oscili	kCar2Amp*aAntiClick, (kbasefreq * gkCar2Ratio) + aModulator, gisine		;DEFINE THE CARRIER WAVEFORM (NOTE HOW ITS FREQUENCY IS MODULATED (THROUGH ADDITION) BY THE AUDIO OUTPUT OF THE MODULATOR WAVEFORM)
	aMix			sum		aCarrier1, aCarrier2
				outs		aMix*kGain, aMix*kGain											;SEND THE MIXED AUDIO OUTPUT OF THE CARRIER WAVEFORMS TO THE OUTPUTS 

	ktrig	  	metro	10															;CREATE A REPEATING TRIGGER SIGNAL
	if ktrig == 1 then
			outvalue		"Peak_Dev", kpeakdeviation
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
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>434</x>
 <y>190</y>
 <width>925</width>
 <height>505</height>
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
  <width>512</width>
  <height>430</height>
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
  <width>289</width>
  <height>203</height>
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
  <x>517</x>
  <y>49</y>
  <width>284</width>
  <height>150</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------
This three oscillator example demonstrates a single modulator simultaneously modulating the frequency parameter of a single carrier.
</label>
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
  <x>448</x>
  <y>341</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.700</label>
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
  <x>8</x>
  <y>318</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.69999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>341</y>
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
  <x>79</x>
  <y>223</y>
  <width>346</width>
  <height>82</height>
  <uuid>{53a95371-23f7-4d54-a6c6-63bbabdb388d}</uuid>
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
  <x>172</x>
  <y>225</y>
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
  <objectName>Carrier1_Frequency</objectName>
  <x>88</x>
  <y>235</y>
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
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Carrier2_Frequency</objectName>
  <x>211</x>
  <y>235</y>
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
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>211</x>
  <y>264</y>
  <width>70</width>
  <height>50</height>
  <uuid>{d7a84933-3d3a-4adf-8289-84a4413362a7}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>88</x>
  <y>264</y>
  <width>70</width>
  <height>50</height>
  <uuid>{7723878b-fcac-4444-84a2-a4ba87008431}</uuid>
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
  <value>0.23295900</value>
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
  <x>8</x>
  <y>142</y>
  <width>180</width>
  <height>30</height>
  <uuid>{0c691576-66a5-4aa6-a82c-48f930da9708}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulation Index</label>
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
  <objectName>Modulation_Index</objectName>
  <x>8</x>
  <y>119</y>
  <width>380</width>
  <height>27</height>
  <uuid>{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}</uuid>
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
  <objectName>Carrier1_Amplitude</objectName>
  <x>200</x>
  <y>184</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c03c8ac7-b287-4328-8e07-bbf81f16291a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.124</label>
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
  <objectName>Carrier1_Amplitude</objectName>
  <x>8</x>
  <y>161</y>
  <width>250</width>
  <height>27</height>
  <uuid>{9e41022a-6d97-415e-82ef-dafd223f6de8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.12400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>184</y>
  <width>180</width>
  <height>30</height>
  <uuid>{dd30e1bc-c2a4-4d61-8df6-fafe394c7687}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Carrier 1 Amplitude</label>
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
  <x>335</x>
  <y>264</y>
  <width>70</width>
  <height>50</height>
  <uuid>{a41c9bd7-bf11-4aeb-99d0-39e0949d0da0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulator
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
  <objectName>Modulator_Frequency</objectName>
  <x>335</x>
  <y>235</y>
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
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>296</x>
  <y>225</y>
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
  <label>Modulator -> 2 Carriers</label>
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
  <label>Modulator -> 2 Carriers</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Peak_Dev</objectName>
  <x>447</x>
  <y>119</y>
  <width>60</width>
  <height>28</height>
  <uuid>{bde34782-49c0-47e9-a5bb-1151657e6610}</uuid>
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
  <x>384</x>
  <y>123</y>
  <width>80</width>
  <height>38</height>
  <uuid>{72e281e6-31e1-429b-8e9b-fddb7a4b7809}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>P Dev</label>
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
  <x>112</x>
  <y>379</y>
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
  <x>173</x>
  <y>384</y>
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
  <x>221</x>
  <y>383</y>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Modulation_Index</objectName>
  <x>330</x>
  <y>142</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>259</x>
  <y>184</y>
  <width>180</width>
  <height>30</height>
  <uuid>{43703f58-bc58-4e9b-909e-53b1c347801e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Carrier 2 Amplitude</label>
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
  <objectName>Carrier2_Amplitude</objectName>
  <x>259</x>
  <y>161</y>
  <width>250</width>
  <height>27</height>
  <uuid>{4cf60868-438f-46b5-98ea-394efed9c205}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.12400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Carrier2_Amplitude</objectName>
  <x>451</x>
  <y>184</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2acb9526-537a-48ce-8113-9e6f2781bf14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.124</label>
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
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.69999999</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.700</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.69999999</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >1.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >1.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.23295900</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >99.99994659</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >100.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >3.00000000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >0.12400000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >0.124</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >0.12400000</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >1.00000000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >300.00000000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >300.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="1" >3.00000000</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="4" >3.000</value>
<value id="{4cf60868-438f-46b5-98ea-394efed9c205}" mode="1" >0.12400000</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="1" >0.12400000</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="4" >0.124</value>
</preset>
<preset name="Preset 1" number="1" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.69999999</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.700</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.69999999</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >1.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >1.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.13264200</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >49.99991608</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >50.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >10.50000000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >0.30000001</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >0.300</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >0.30000001</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >1.00500000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >524.99908447</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >524.999</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="1" >10.50000000</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="4" >10.500</value>
<value id="{4cf60868-438f-46b5-98ea-394efed9c205}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="4" >0.300</value>
</preset>
<preset name="Preset 2" number="2" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.69999999</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.700</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.69999999</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >18.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >18.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.05864500</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >30.00012207</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >30.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >9.00000000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >0.30000001</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >0.300</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >0.30000001</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >20.00000000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >270.00109863</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >270.001</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="1" >9.00000000</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="4" >9.000</value>
<value id="{4cf60868-438f-46b5-98ea-394efed9c205}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="4" >0.300</value>
</preset>
<preset name="Preset 3" number="3" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.69999999</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.700</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.69999999</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >8.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >8.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.10736700</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >42.00013733</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >42.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >11.69999981</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >0.30000001</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >0.300</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >0.30000001</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >1.99909997</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >491.40161133</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >491.402</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="1" >11.69999981</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="4" >11.700</value>
<value id="{4cf60868-438f-46b5-98ea-394efed9c205}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="4" >0.300</value>
</preset>
<preset name="Preset 4" number="4" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.69999999</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.700</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.69999999</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >1.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >1.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.39769000</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >311.99951172</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >312.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >1.79999995</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >0.30000001</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >0.300</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >0.30000001</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >1.30499995</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >561.59912109</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >561.599</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="1" >1.79999995</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="4" >1.800</value>
<value id="{4cf60868-438f-46b5-98ea-394efed9c205}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="4" >0.300</value>
</preset>
<preset name="Preset 5" number="5" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.69999999</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.700</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.69999999</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >5.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >5.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.38096750</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >278.00045776</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >278.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >2.09999990</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >0.30000001</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >0.300</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >0.30000001</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >20.00000000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >583.80096436</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >583.801</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="1" >2.09999990</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="4" >2.100</value>
<value id="{4cf60868-438f-46b5-98ea-394efed9c205}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="4" >0.300</value>
</preset>
<preset name="Preset 6" number="6" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.69999999</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.700</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.69999999</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >0.50000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >0.50000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.37126201</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >260.00018311</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >260.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >4.00000000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >0.30000001</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >0.300</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >0.30000001</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >20.00000000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >1040.00073242</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >1040.001</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="1" >4.00000000</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="4" >4.000</value>
<value id="{4cf60868-438f-46b5-98ea-394efed9c205}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="4" >0.300</value>
</preset>
<preset name="Preset 7" number="7" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.69999999</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.700</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.69999999</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >18.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >18.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.23722000</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >102.99997711</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >103.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >3.00000000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >0.30000001</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >0.300</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >0.30000001</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >20.00000000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >308.99993896</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >309.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="1" >3.00000000</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="4" >3.000</value>
<value id="{4cf60868-438f-46b5-98ea-394efed9c205}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="4" >0.300</value>
</preset>
<preset name="Preset 8" number="8" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.69999999</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.700</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.69999999</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >8.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >8.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.18132000</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >69.99961090</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >70.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >2.29999995</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >0.30000001</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >0.300</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >0.30000001</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >1.00999999</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >160.99909973</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >160.999</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="1" >2.29999995</value>
<value id="{f1eeae2a-1a61-4da1-8d67-c4fbf0e711e3}" mode="4" >2.300</value>
<value id="{4cf60868-438f-46b5-98ea-394efed9c205}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="1" >0.30000001</value>
<value id="{2acb9526-537a-48ce-8113-9e6f2781bf14}" mode="4" >0.300</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

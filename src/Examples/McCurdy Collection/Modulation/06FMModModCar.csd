;Written by Iain McCurdy, 2008


; Modified for QuteCsound by René, November 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Instrument 1 is activated by MIDI and by the GUI
;	Removed presets (included in QuteCsound)	
;	Cannot display more than one space in Label, so can't display the schematic shown below:

	; FM Synthesis: Modulator->Modulator->Carrier
	;---------------------------------------------
	;			+-----+
	;			|MOD.1|
	;			+--+--+
	;			   |
	;			+--+--+
	;			|MOD.2|
	;			+--+--+
	;			   |
	;			+--+--+
	;			|CAR. |
	;			+--+--+
	;			   |
	;			   V
	;			  OUT


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

		gkindex1		invalue 	"Modulation_Index_1"
		gkindex2		invalue 	"Modulation_Index_2"

		gkCarRatio	invalue	"Carrier_Frequency"
		gkMod1Ratio	invalue	"Modulator1_Frequency"
		gkMod2Ratio	invalue	"Modulator2_Frequency"	
		
		gkCarAmp		invalue 	"Carrier_Amplitude"
	endif
endin

instr	1	;FM INSTRUMENT
	if p4!=0 then													;MIDI
		ioct		= p4												;READ OCT VALUE FROM MIDI INPUT
		iamp		= p5												;READ midi-velocity-amp FROM MIDI INPUT
		kCarAmp	= iamp * gkCarAmp									;SET AMPLITUDE TO RECEIVED p5 (I.E. MIDI VELOCITY) MULTIPLIED BY SLIDER "Carrier_Amplitude"

		;PITCH BEND===========================================================================================================================================================
		iSemitoneBendRange = 4										;PITCH BEND RANGE IN SEMITONES
		imin		= 0												;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333						;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax								;PITCH BEND VARIABLE (IN oct FORMAT)
		kbasefreq	=	cpsoct(ioct + kbend)							;SET FUNDEMENTAL FROM MIDI
		;=====================================================================================================================================================================
	else															;GUI
		kbasefreq = gkbasefreq										;SET FUNDEMENTAL FROM GUI SLIDER "Base_Frequency"
		kCarAmp	= gkCarAmp										;SET kamp TO SLIDER VALUE "Carrier_Amplitude"
	endif

	iporttime		=		.02										;PORTAMENTO TIME (TO BE APPLIED TO K-RATE VARIABLES IN ORDER TO IMPLEMENT DAMPING)
	kporttime		linseg	0, .001, iporttime, 1, iporttime				;FINAL VARIABLE WILL RAMP UP
	
	kbasefreq		portk	kbasefreq, kporttime						;PORTAMENTO APPLIED
	kindex1		portk	gkindex1, kporttime							;PORTAMENTO APPLIED
	kindex2		portk	gkindex2, kporttime							;PORTAMENTO APPLIED
	kCarAmp		portk	kCarAmp, kporttime							;PORTAMENTO APPLIED
	
	kpeakdeviation1	=	kbasefreq * kindex1							;CALCUALATE THE PEAK DEVIATION OF THE MODULATOR FROM THE VALUES GIVEN FOR BASE FREQUENCY AND THE INDEX OF MODULATION
	kpeakdeviation2	=	kbasefreq * kindex2							;CALCUALATE THE PEAK DEVIATION OF THE MODULATOR FROM THE VALUES GIVEN FOR BASE FREQUENCY AND THE INDEX OF MODULATION

	aAntiClick	linsegr	0,0.001,1,0.01,0							;ANTI CLICK ENVELOPE
	
	;OUTPUT		OPCODE	AMPLITUDE          |     FREQUENCY						| FUNCTION_TABLE
	aModulator1	oscili	kpeakdeviation1,   kbasefreq * gkMod1Ratio,				gisine			;DEFINE THE MODULATOR WAVEFORM
	aModulator2	oscili	kpeakdeviation2,   (kbasefreq * gkMod2Ratio) + aModulator1,	gisine			;DEFINE THE MODULATOR WAVEFORM
	aCarrier		oscili	kCarAmp*aAntiClick,(kbasefreq * gkCarRatio) + aModulator2,	gisine			;DEFINE THE CARRIER WAVEFORM (NOTE HOW ITS FREQUENCY IS MODULATED (THROUGH ADDITION) BY THE AUDIO OUTPUT OF THE MODULATOR WAVEFORM)
				outs		aCarrier, aCarrier													;SEND THE AUDIO OUTPUT OF THE CARRIER WAVEFORM *ONLY* TO THE OUTPUTS 

	ktrig	  	metro	10	;CREATE A REPEATING TRIGGER SIGNAL
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
 <x>251</x>
 <y>227</y>
 <width>915</width>
 <height>410</height>
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
  <height>400</height>
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
  <width>386</width>
  <height>400</height>
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
  <x>518</x>
  <y>58</y>
  <width>373</width>
  <height>342</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------
This three oscillator algorithm has the audio output of a modulator modulating the frequency of a second modulator, the audio output of which modulates the frequency of a carrier.
The modulation index control for modulator 2, as well as controlling the amount of influence modulator 2 has on the carrier, inevitably also governs the influence modulator 1 has on the carrier.
This type of arrangement is capable of generating extremely complex and sometimes chaotic spectra therefore care and subtlety are probably needed.
Note that 'Modulation Index 1' is also controllable from the number box beneath the slider. This is included to permit fine and precise control of this parameter.
Some of the presets in this example demonstrate the more extreme and strident spectra possible with this FM algorithm.
When the 'On/Off' switch is off the instrument can be played from MIDI.</label>
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
  <label>0.600</label>
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
  <value>0.60000002</value>
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
  <x>27</x>
  <y>200</y>
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
  <x>127</x>
  <y>202</y>
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
  <objectName>Carrier_Frequency</objectName>
  <x>43</x>
  <y>212</y>
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
  <objectName>Modulator1_Frequency</objectName>
  <x>166</x>
  <y>212</y>
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
  <x>166</x>
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
  <x>43</x>
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
  <maximum>100.00000000</maximum>
  <value>3.00000000</value>
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
  <x>8</x>
  <y>148</y>
  <width>500</width>
  <height>27</height>
  <uuid>{9e41022a-6d97-415e-82ef-dafd223f6de8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>3.00000000</value>
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
  <x>290</x>
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
  <objectName>Modulator2_Frequency</objectName>
  <x>290</x>
  <y>212</y>
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
  <x>251</x>
  <y>202</y>
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
  <x>562</x>
  <y>27</y>
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
  <x>578</x>
  <y>4</y>
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
  <objectName>Peak_Dev_1</objectName>
  <x>444</x>
  <y>210</y>
  <width>60</width>
  <height>28</height>
  <uuid>{bde34782-49c0-47e9-a5bb-1151657e6610}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>100.000</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Peak_Dev_2</objectName>
  <x>444</x>
  <y>242</y>
  <width>60</width>
  <height>28</height>
  <uuid>{f81f2df4-7205-480a-87e3-6d851d08312b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>100.000</label>
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
  <x>375</x>
  <y>212</y>
  <width>80</width>
  <height>38</height>
  <uuid>{72e281e6-31e1-429b-8e9b-fddb7a4b7809}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>P. Dev. 1</label>
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
  <x>375</x>
  <y>243</y>
  <width>80</width>
  <height>38</height>
  <uuid>{c9bd7c94-edba-4166-8960-1821efe2e88d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>P. Dev. 2</label>
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
  <y>356</y>
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
  <x>69</x>
  <y>361</y>
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
  <x>117</x>
  <y>360</y>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Modulation_Index_1</objectName>
  <x>427</x>
  <y>128</y>
  <width>80</width>
  <height>25</height>
  <uuid>{06fdaf07-2d54-44c6-8bc5-bc999eac9aa5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
  <value>9.31100000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="Init" number="0" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.60000002</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.600</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.60000002</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >1.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >1.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.23295900</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >99.99994659</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >100.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >3.00000000</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="1" >3.00000000</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="4" >3.000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >3.00000000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >3.000</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >3.00000000</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >1.00000000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >99.99994659</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >100.000</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="1" >99.99994659</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="4" >100.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 1</value>
</preset>
<preset name="Preset 1" number="1" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.60000002</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.600</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.60000002</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >1.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >8.98519993</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.26172400</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >122.00006866</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >122.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >18.00000000</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="1" >18.00000000</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="4" >18.000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >4.67530012</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >4.675</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >4.67530012</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >1.00360000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >122.00006866</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >122.000</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="1" >122.00006866</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="4" >122.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
</preset>
<preset name="Preset 2" number="2" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.60000002</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.600</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.60000002</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >1.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >0.99919999</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.18132000</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >69.99961090</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >70.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >0.00070000</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="1" >0.00070000</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="4" >0.001</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >17.14299965</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >17.143</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >17.14299965</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >1.00000000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >69.99961090</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >70.000</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="1" >69.99961090</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="4" >70.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >2.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 1</value>
</preset>
<preset name="Preset 3" number="3" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.60000002</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.600</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.60000002</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >1.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >1.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.75259250</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >3622.00048828</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >3622.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >74.80519867</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="1" >74.80519867</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="4" >74.805</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >74.80000305</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >74.800</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >74.80000305</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >2.00000000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >3622.00048828</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >3622.000</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="1" >3622.00048828</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="4" >3622.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >2.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 1</value>
</preset>
<preset name="Preset 4" number="4" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.60000002</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.600</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.60000002</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >1.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >4.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.21115001</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >85.99971771</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >86.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >100.00000000</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="1" >100.00000000</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="4" >100.000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >5.71430016</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >5.714</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >5.71430016</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >1.00100005</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >85.99971771</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >86.000</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="1" >85.99971771</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="4" >86.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >3.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 3</value>
</preset>
<preset name="Preset 5" number="5" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.60000002</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.600</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.60000002</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >1.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >1.30009997</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.37726951</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >271.00033569</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >271.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >1.29999995</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="1" >1.29999995</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="4" >1.300</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >4.00000000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >4.000</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >4.00000000</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >1.29999995</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >271.00033569</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >271.000</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="1" >271.00033569</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="4" >271.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >4.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 4</value>
</preset>
<preset name="Preset 6" number="6" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.60000002</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.600</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.60000002</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >15.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >14.00000000</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.17926300</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >69.00029755</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >69.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >31.00000000</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="1" >31.00000000</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="4" >31.000</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >3.11689997</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >3.117</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >3.11689997</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >13.00000000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >69.00029755</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >69.000</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="1" >69.00029755</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="4" >69.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Init</value>
</preset>
<preset name="Preset 7" number="7" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="1" >0.60000002</value>
<value id="{745d6bee-b951-4a03-9fe8-9e10d5ae4556}" mode="4" >0.600</value>
<value id="{06814721-6151-4baa-84e2-8f39843b07a4}" mode="1" >0.60000002</value>
<value id="{6f8fc775-201d-40f9-931b-687c9b3ef417}" mode="1" >15.00000000</value>
<value id="{fd4b783c-f008-4a1c-b2e6-50340aad9093}" mode="1" >12.97229958</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.22243200</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >93.00016785</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >93.000</value>
<value id="{9cf53cef-488f-4075-b87f-dc2c3e6a21e6}" mode="1" >1.29869998</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="1" >1.29869998</value>
<value id="{c80205fb-7ad4-4b4e-878c-8bf7bf8737c0}" mode="4" >1.299</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="1" >4.15579987</value>
<value id="{c03c8ac7-b287-4328-8e07-bbf81f16291a}" mode="4" >4.156</value>
<value id="{9e41022a-6d97-415e-82ef-dafd223f6de8}" mode="1" >4.15579987</value>
<value id="{4613a393-76fd-495c-8e3b-95f1257e8326}" mode="1" >13.00000000</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="1" >93.00016785</value>
<value id="{bde34782-49c0-47e9-a5bb-1151657e6610}" mode="4" >93.000</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="1" >93.00016785</value>
<value id="{f81f2df4-7205-480a-87e3-6d851d08312b}" mode="4" >93.000</value>
<value id="{dace86e6-2bd1-4e11-8230-036973772d8f}" mode="1" >4.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="1" >0.00000000</value>
<value id="{f21d8bf3-cad5-40b6-ac3f-bbdcbe8f2a57}" mode="4" >Preset 4</value>
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
ioText {2, 2} {512, 400} label 0.000000 0.00100 "" center "DejaVu Sans" 18 {65280, 65280, 65280} {1280, 6912, 38400} nobackground noborder 
ioText {514, 2} {386, 400} label 0.000000 0.00100 "" center "DejaVu Sans" 18 {65280, 65280, 65280} {1280, 6912, 38400} nobackground noborder 
ioText {518, 58} {373, 342} label 0.000000 0.00100 "" left "Liberation Sans" 14 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder ------------------------------------------------------------------------------------------Â¬This three oscillator algorithm has the audio output of a modulator modulating the frequency of a second modulator, the audio output of which modulates the frequency of a carrier.Â¬The modulation index control for modulator 2, as well as controlling the amount of influence modulator 2 has on the carrier, inevitably also governs the influence modulator 1 has on the carrier.Â¬This type of arrangement is capable of generating extremely complex and sometimes chaotic spectra therefore care and subtlety are probably needed.Â¬Note that 'Modulation Index 1' is also controllable from the number box beneath the slider. This is included to permit fine and precise control of this parameter.Â¬Some of the presets in this example demonstrate the more extreme and strident spectra possible with this FM algorithm.Â¬When the 'On/Off' switch is off the instrument can be played from MIDI.
ioButton {8, 6} {124, 30} event 1.000000 "" " ON / OFF (MIDI)" "/" i 1 0 -1
ioText {448, 328} {60, 30} display 0.600000 0.00100 "Carrier_Amplitude" right "Arial" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 0.600
ioSlider {8, 305} {500, 27} 0.000000 1.000000 0.600000 Carrier_Amplitude
ioText {8, 328} {180, 30} label 0.000000 0.00100 "" left "Arial" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Carrier Amplitude
ioText {27, 200} {358, 83} label 0.000000 0.00100 "" left "Arial" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 
ioText {127, 202} {32, 46} label 0.000000 0.00100 "" center "DejaVu Sans" 27 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder :
ioText {43, 212} {80, 28} editnum 0.125000 0.000100 "Carrier_Frequency" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.125000
ioText {166, 212} {80, 28} editnum 0.125000 0.000100 "Modulator1_Frequency" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.125000
ioText {166, 241} {70, 50} label 0.000000 0.00100 "" center "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Modulator 1Â¬Frequency
ioText {43, 241} {70, 50} label 0.000000 0.00100 "" center "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder CarrierÂ¬Frequency
ioText {8, 86} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Base Frequency
ioSlider {8, 63} {500, 27} 0.000000 1.000000 0.232959 Base_Frequency
ioText {448, 86} {60, 30} display 100.000000 0.00100 "Base_Frequency_Value" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 100.000
ioText {8, 129} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Modulation Index 1
ioSlider {8, 106} {500, 27} 0.000000 100.000000 3.000000 Modulation_Index_1
ioText {448, 171} {60, 30} display 3.000000 0.00100 "Modulation_Index_2" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 3.000
ioSlider {8, 148} {500, 27} 0.000000 100.000000 3.000000 Modulation_Index_2
ioText {8, 171} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Modulation Index 2
ioText {290, 241} {70, 50} label 0.000000 0.00100 "" center "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Modulator 2Â¬Frequency
ioText {290, 212} {80, 28} editnum 0.125000 0.000100 "Modulator2_Frequency" left "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.125000
ioText {251, 202} {32, 46} label 0.000000 0.00100 "" center "DejaVu Sans" 27 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder :
ioText {155, 5} {305, 35} label 0.000000 0.00100 "" center "Liberation Sans" 18 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder FM Synthesis
ioText {114, 28} {387, 31} label 0.000000 0.00100 "" center "Liberation Sans" 18 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Modulator->Modulator->Carrier
ioText {562, 27} {288, 50} label 0.000000 0.00100 "" center "Liberation Sans" 18 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Modulator->Modulator->Carrier
ioText {578, 4} {250, 35} label 0.000000 0.00100 "" center "Liberation Sans" 18 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder FM Synthesis
ioText {444, 210} {60, 28} display 100.000000 0.00100 "Peak_Dev_1" center "Liberation Sans" 9 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 100.000
ioText {444, 242} {60, 28} display 100.000000 0.00100 "Peak_Dev_2" center "Liberation Sans" 9 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 100.000
ioText {375, 212} {80, 38} label 0.000000 0.00100 "" center "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder P. Dev. 1
ioText {375, 243} {80, 38} label 0.000000 0.00100 "" center "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder P. Dev. 2
ioText {8, 356} {294, 38} label 0.000000 0.00100 "" left "Liberation Sans" 14 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Presets
ioText {69, 361} {44, 28} editnum 0.000000 1.000000 "_SetPresetIndex" center "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 0.000000
ioText {117, 360} {180, 30} display 0.000000 0.00100 "_GetPresetName" center "Liberation Sans" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Init
ioText {427, 128} {80, 25} scroll 9.311000 0.001000 "Modulation_Index_1" left "Liberation Sans" 10 {0, 0, 0} {65280, 65280, 65280} background noborder 
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

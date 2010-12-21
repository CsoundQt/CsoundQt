;Written by Iain McCurdy, 2008


; Modified for QuteCsound by René, November 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Instrument 1 is activated by MIDI and by the GUI
;	Cannot display more than one space in Label, so can't display the schematic shown below:

	;Phase Modulation Synthesis: Modulator->Carrier(with feedback)
	;-------------------------------------------------------------
	;                  +------+
	;                  V      |
	;               +--+--+   |
	;               |MOD.1|   |
	;               +--+--+   |
	;                  |      |
	;                  |      |(feedback)
	;                  |      |
	;               +--+--+   |
	;               |CAR.1|   |
	;               +--+--+   |
	;                  |      |
	;                  +-->---+
	;                  |
	;                  V
	;                 OUT


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 1		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH

gisine		ftgen	0,0,65537,10,1							;A SINE WAVE THAT CAN BE REFERENCED BY THE GLOBAL VARIABLE 'gisine'
giExp20000	ftgen	0, 0, 129, -25, 0, 20.0, 128, 20000.0		;TABLES FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		kbasefreq		invalue 	"Base_Frequency"
		gkbasefreq	tablei	kbasefreq, giExp20000, 1
					outvalue	"Base_Frequency_Value", gkbasefreq		
		gkindex		invalue	"Modulation_Index"
		gkCarAmp		invalue 	"Carrier_Amplitude"
		gkFBRatio		invalue 	"Feedback_Ratio"
		gkCarRatio	invalue	"Carrier_Frequency"
		gkModRatio	invalue	"Modulation_Frequency"
	endif
endin

instr	1	;FM INSTRUMENT
	if p4!=0 then											;MIDI
		ioct		= p4										;READ OCT VALUE FROM MIDI INPUT
		iamp		= p5										;READ midi-velocity-amp FROM MIDI INPUT
		kCarAmp	= iamp * gkCarAmp							;SET AMPLITUDE TO RECEIVED p5 (I.E. MIDI VELOCITY) MULTIPLIED BY SLIDER "Carrier_Amplitude"
		kindex	= iamp * gkindex							;SET INDEX TO SLIDER gkindex MULTIPLIED BY SLIDER "Carrier_Amplitude"
		;PITCH BEND=============================================================================================================================================
		iSemitoneBendRange = 4								;PITCH BEND RANGE IN SEMITONES
		imin		= 0										;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333				;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax						;PITCH BEND VARIABLE (IN oct FORMAT)
		kbasefreq	=	cpsoct(ioct + kbend)					;SET FUNDEMENTAL FROM MIDI
		;=======================================================================================================================================================
	else													;GUI
		kbasefreq = gkbasefreq								;SET FUNDEMENTAL FROM SLIDER "Base_Frequency"
		kCarAmp	= gkCarAmp								;SET kamp TO SLIDER VALUE "Carrier_Amplitude"
		kindex	= gkindex									;SET INDEX TO SLIDER gkindex
	endif

	iporttime		=		.02								;PORTAMENTO FUNCTION (WILL BE USED TO SMOOTH PARAMETER MOVED BY FLTK WIDGETS)
	kporttime		linseg	0,.001,iporttime,1,iporttime			;PORTAMENTO FUNCTION (WILL BE USED TO SMOOTH PARAMETER MOVED BY FLTK WIDGETS)
	
	kindex		portk	kindex, kporttime					;APPLY SMOOTHING PORTAMENTO TO THE VARIABLE 'kindex'
	kbasefreq		portk	kbasefreq, kporttime				;APPLY SMOOTHING PORTAMENTO TO THE VARIABLE 'kbasefreq'
	kFBRatio		portk	gkFBRatio, kporttime				;APPLY SMOOTHING PORTAMENTO TO THE VARIABLE 'kFBratio'
	kCarAmp		portk	kCarAmp, kporttime					;APPLY SMOOTHING PORTAMENTO TO THE VARIABLE 'gkCarAmp'

	aFB			init		0								;CREATE AN INITIAL VALUE FOR THE FEEDBACK SIGNAL
	aModPhase		phasor	kbasefreq * gkModRatio				;CREATE A MOVING PHASE VALUE THAT WILL BE USED TO READ CREATE THE MODULATOR
	aModulator	tablei	aModPhase+aFB,gisine,1,0,1			;MODULATOR OSCILLATOR IS CREATED. NOTE THAT FEEDBACK SIGNAL IS ADDED TO THE POINTER VARIABLE
	aModulator	=		aModulator * (kindex*.17)			;MODULATOR RESCALED
	aCarrPhase	phasor	kbasefreq * gkCarRatio				;CREATE A MOVING PHASE VALUE THAT WILL BE USED TO READ CREATE THE CARRIER
	aCarrPhase	=		aCarrPhase + aModulator				;MODULATOR SIGNAL IS ADDED TO CARRIER PHASE VARIABLE
	aCarrier		tablei	aCarrPhase,gisine,1,0,1				;MODULATOR OSCILLATOR IS CREATED. NOTE THAT FEEDBACK SIGNAL IS ADDED TO THE POINTER VARIABLE
	aFB			=		aCarrier * kFBRatio					;FEEDBACK SIGNAL UPDATED FOR THE NEXT PASS
	aAntiClick	linsegr	0,0.001,1,0.01,0					;ANTI CLICK ENVELOPE
	aCarrier		=		aCarrier*kCarAmp*aAntiClick			;CARRIER AMPLITUDE IS RESCALED
				outs		aCarrier, aCarrier					;SEND THE AUDIO OUTPUT OF THE CARRIER WAVEFORM *ONLY* TO THE OUTPUTS 
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0	   3600		;GUI
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>613</x>
 <y>179</y>
 <width>911</width>
 <height>420</height>
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
  <height>350</height>
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
  <x>515</x>
  <y>2</y>
  <width>258</width>
  <height>350</height>
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
  <x>527</x>
  <y>78</y>
  <width>233</width>
  <height>263</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------
This example implements phase modulation synthesis with a modulator->carrier pairing and with a feedback loop on the
modulator -> carrier pairing.</label>
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
  <y>272</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.178</label>
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
  <y>249</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.17800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>272</y>
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
  <x>132</x>
  <y>158</y>
  <width>236</width>
  <height>84</height>
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
  <x>232</x>
  <y>160</y>
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
  <x>148</x>
  <y>170</y>
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
  <resolution>0.00100000</resolution>
  <minimum>0.125</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Modulation_Frequency</objectName>
  <x>271</x>
  <y>170</y>
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
  <resolution>0.00100000</resolution>
  <minimum>0.125</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.125</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>271</x>
  <y>199</y>
  <width>70</width>
  <height>50</height>
  <uuid>{d7a84933-3d3a-4adf-8289-84a4413362a7}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>148</x>
  <y>199</y>
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
  <value>0.23600000</value>
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
  <label>102.126</label>
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
  <label>Modulator->Carrier(with feedback)</label>
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
  <x>517</x>
  <y>27</y>
  <width>249</width>
  <height>71</height>
  <uuid>{dd72e305-5880-4889-b044-bf9d9333880b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulator->Carrier
(with feedback)</label>
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
  <x>518</x>
  <y>4</y>
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
  <objectName>Modulation_Index</objectName>
  <x>448</x>
  <y>129</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0365274e-7611-4acf-a238-86002c301cf8}</uuid>
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
  <x>8</x>
  <y>317</y>
  <width>180</width>
  <height>30</height>
  <uuid>{a4ff1577-f924-4663-a2b6-454ad56675a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feedback Ratio</label>
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
  <objectName>Feedback_Ratio</objectName>
  <x>8</x>
  <y>294</y>
  <width>500</width>
  <height>27</height>
  <uuid>{88dd26a5-845f-4faa-ab42-21f978a83013}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.07000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Feedback_Ratio</objectName>
  <x>448</x>
  <y>317</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2f291140-79b3-4b2f-b4d7-549ad78efe23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.070</label>
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
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

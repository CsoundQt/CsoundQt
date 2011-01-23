;Written by Iain McCurdy, 2006

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 January 2011 and QuteCsound svn rev 805


;Notes on modifications from original csd:
;	Add limits for Lower/Upper frequencies
;	Removed "Instructions and Info Panel" for the gui to fit in a 1200x800 screen


;												Pitch
;	-------------------------------------------------------------------------------------------------------------------------------------------
;	This example presents a simple demonstration of the 'pitch' opcode, used for pitch and amplitude tracking.
;	It requires a live audio input so you should have a microphone connected to your computer and get ready to sing into it!
;	'Pitch' outputs two k-rate variables and for frequency and the other for the amplitude of an input audio signal.
;	For clarity, the usage of this data in this example is quite trivial in that it is used merely as input data for the
;	frequency and amplitude of a simple synthesizing oscillator. With a little imagination, many more interesting applications are possible.
;	'Update Period' defines the time period over which output data is updated. Higher values here will stabilise the output stream of
;	frequency data at the expense of response time. Lower values will allow a faster response to changing pitch.
;	Upper and lower limits of pitch detection can be defined (in the octave point decimal format). Careful setting of these limits can help
;	prevent incorrect pitch detections.
;	'Threshold of Detection' allows the user to define an amplitude threshold (in dB) above which detection will begin.
;	Once the threshold is crossed the signal amplitude must drop to beyond 6 dB lower than the threshold before detection ceases.
;	This parameter can be used to prevent extraneous and environmental noise from triggering the tracking process.
;	'Octave Divisions' allows us to quantize the number of allowed pitches in an octave. A setting of 12 will limit the output frequency
;	values to twelve per octave (as in the equally tempered tuning system). Maximum allowed setting here is 120.
;	'Conformations' defines the number of confirmations that will be required before the tracker shifts to a higher or lower octave.
;	This parameter can be used to control unstable jumping between octaves. Experimentation is required to find the appropriate setting.
;	'Starting Pitch of the Tracker' defines the starting pitch (in oct) of the tracker. 'Octave Decimations' defines the number of octave
;	decimations in the spectrum.
;	This may need adjusting depending on the nature of the sound being tracked. Experimentation is  required.
;	'Q of Filters' defines the sharpness or resonance of the analysis filters. Again this should be fine tuned according to the nature of
;	the sound being tracked.
;	Noisy or spectrally unstable sounds may require lower settings for 'Q' to allow sucessful pitch tracking.
;	'Number of Partials' defines the number of partials that will be used in the pitch tracking process.
;	Higher values here may facilitate more successful pitch tracking in sounds with a weak fundemental, but at the expense CPU.
;	'Rolloff' defines the amplitude rolloff (expressed as a fraction of an octave) of the filters used in tracking. 'Skip', if activated, skips
;	initialisation. An alternative opcode for pitch and amplitude tracking worth investigating is 'pitchamdf'.
;	Pitch tracking is a much more involved and CPU intensive process than amplitude tracking.
;	If you only require amplitude tracking it is recommended that you use either the 'follow' or 'follow2' opcodes.


;my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 -+rtmidi=null
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


instr	1	;GUI	;(ALWAYS ON - SEE SCORE) PLAYS FILE AND SENSES FADER MOVEMENT AND RESTARTS INSTR 2 FOR I-RATE CONTROLLERS

	klimit	init	0
	idelta	=	0.1

	ktrig	metro	10
	if (ktrig == 1)	then
		gkskip		invalue	"Skip"

		gkupdte		invalue 	"Update"
		gklo			invalue 	"Lower"
		gkhi			invalue 	"Upper"

		if gklo > gkhi - idelta then
			gklo	=	gkhi - idelta
			klimit	=	1
		else
			klimit	=	0
		endif
					outvalue	"Lower_Value", gklo
					outvalue	"Limit", klimit

		gkdbthresh	invalue 	"Threshold"
		gkstrt		invalue 	"Starting"
		gkq			invalue 	"Q_Filters"
		gkrolloff		invalue 	"Rolloff"

		gkfrqs		invalue  "Divisions"
		gkconf		invalue  "Conformations"
		gkocts		invalue  "Decimations"
		gknptls		invalue  "Harmonics"
	endif

	kSwitch	changed		gkupdte, gklo, gkhi, gkdbthresh, gkfrqs, gkconf, gkstrt, gkocts, gkq, gknptls, gkrolloff		;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	;					ITRIGGER | IMINTIM | IMAXNUM | IINSNUM | IWHEN | IDUR (-1 MEANS A NOTE OF INFINITE DURATION)
			schedkwhen	kSwitch,    0,        0,        2,        0,      -1									;RESTART INSTRUMENT 2 WITH A SUSTAINED (HELD) NOTE WHENEVER kSwitch=1
endin

instr	2
	aL, aR		ins												;READ STEREO INPUT TO THE COMPUTER

	;CREATE A PITCH TRACKING VARIABLE AND AN AMPLITUDE TRACKING VARIABLE USING THE 'pitch' OPCODE - IMPROVED RESULTS CAN BE ACHIEVED BY FIRST ATTENUATING THE AMPLITUDE OF THE INPUT SIGNAL, YOU WILL NOTICE THAT 'aL' IS FIRST DIVIDED BY 50
	koct, kamp	pitch	aL/50, i(gkupdte), i(gklo), i(gkhi), i(gkdbthresh), i(gkfrqs), i(gkconf), i(gkstrt), i(gkocts), i(gkq), i(gknptls), i(gkrolloff), i(gkskip)
	kamp			port		kamp, 0.01								;SMOOTH OUT DISCONTINUITIES IN THE AMPLITUDE PARAMETER STREAM

	aamp			interp	kamp/500									;RECALIBRATE THE AMPLITUDE FOLLOWING SIGNAL - ALSO INTERPOLATE TO CREATE AN A-RATE SIGNAL TO PREVENT CLICKS AS THE AMPLITUDE FLUCTUATES
	asig			oscili	aamp, cpsoct(koct), 1						;CREATE A SYNTHESIZED TONE THAT MIMICS THE FREQUENCY AND AMPLITUDE ATTRIBUTES OF THE INPUT SIGNAL
				outs		asig, asig								;SEND THE STNTHESIZED TONE TO THE OUTPUTS
endin
</CsInstruments>
<CsScore>
f 1 0 1024 10 1 .2 .15 .1 .2 .1 .05 .02 .01		;A RICH TONE - USED BY THE PITCH TRACKING SYNTHESIZER
f 2 0 131072 10 1							;A SINE WAVE

;INSTR | START | DURATION
i 1		 0	   3600		;GUI (THIS ALSO KEEPS PERFORMANCE GOING)
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1090</x>
 <y>482</y>
 <width>526</width>
 <height>470</height>
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
  <width>514</width>
  <height>456</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pitch</label>
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
   <b>158</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>156</y>
  <width>180</width>
  <height>30</height>
  <uuid>{63ab529c-3f14-4886-8215-fd6e8f1a37ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Upper Pitch Detection Limit (oct)</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Upper</objectName>
  <x>8</x>
  <y>139</y>
  <width>500</width>
  <height>27</height>
  <uuid>{a7c37920-a18a-446b-8b66-6a1119503da0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>4.00000000</minimum>
  <maximum>14.00000000</maximum>
  <value>11.02000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Upper</objectName>
  <x>448</x>
  <y>156</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b453c0e4-809f-4074-94fd-506ebb68f3b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>11.020</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <y>49</y>
  <width>180</width>
  <height>30</height>
  <uuid>{93cc32a5-c161-4212-baeb-c28b120f89a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Update Period (seconds)</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Update</objectName>
  <x>8</x>
  <y>32</y>
  <width>500</width>
  <height>27</height>
  <uuid>{107836e5-a726-4a83-83b5-c368481d9a48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.00991000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Update</objectName>
  <x>448</x>
  <y>49</y>
  <width>60</width>
  <height>30</height>
  <uuid>{71f0e6eb-f79d-4cd7-80f7-a22cc355e64f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.010</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <y>85</y>
  <width>180</width>
  <height>30</height>
  <uuid>{e193ffd3-920b-40d4-9eaa-bd11dad75bff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Threshold of Detection (db)</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Threshold</objectName>
  <x>8</x>
  <y>68</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e4aa4e7b-5b74-4a61-8bd7-4beea2c0bb93}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-90.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>-0.46000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Threshold</objectName>
  <x>448</x>
  <y>85</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dc879380-3a9e-4939-b482-a0b4ee46dac5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-0.460</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <y>121</y>
  <width>180</width>
  <height>30</height>
  <uuid>{866a933e-0c0d-493a-84af-29f3557f8e4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Lower Pitch Detection Limit (oct)</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Lower</objectName>
  <x>8</x>
  <y>104</y>
  <width>500</width>
  <height>27</height>
  <uuid>{fbbd0dd3-c206-4214-aa5e-10d42b909252}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>4.00000000</minimum>
  <maximum>14.00000000</maximum>
  <value>4.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Lower_Value</objectName>
  <x>448</x>
  <y>121</y>
  <width>60</width>
  <height>30</height>
  <uuid>{31c3cb1b-308f-47cd-9396-c81d85a1c30a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Limit</objectName>
  <x>438</x>
  <y>177</y>
  <width>70</width>
  <height>20</height>
  <uuid>{f98fd774-20f8-4893-b3e6-bf114c64ffef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
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
  <x>438</x>
  <y>176</y>
  <width>70</width>
  <height>20</height>
  <uuid>{729f7333-9653-4a15-906e-244e730dee00}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Min > Max !</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Divisions</objectName>
  <x>82</x>
  <y>210</y>
  <width>80</width>
  <height>30</height>
  <uuid>{c465316b-7488-436a-92e7-5a8df08a26d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <maximum>120</maximum>
  <randomizable group="0">false</randomizable>
  <value>120</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>53</x>
  <y>239</y>
  <width>130</width>
  <height>29</height>
  <uuid>{8ade1b4d-d8c8-4654-b667-180b451c2362}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Octave Divisions</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Conformations</objectName>
  <x>209</x>
  <y>210</y>
  <width>80</width>
  <height>30</height>
  <uuid>{aba72173-7514-4b8c-b838-edb9c8958119}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>10</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>183</x>
  <y>239</y>
  <width>130</width>
  <height>29</height>
  <uuid>{150649c9-6403-47c0-95a5-22291e533ef9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Conformations</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Decimations</objectName>
  <x>341</x>
  <y>210</y>
  <width>80</width>
  <height>30</height>
  <uuid>{d15c95fc-cdea-4be2-8aec-1cc4adb9d83a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>6</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>313</x>
  <y>239</y>
  <width>130</width>
  <height>29</height>
  <uuid>{86f60b7a-d8dc-44b8-9554-2b52982c6354}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Octave Decimations</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
  <x>8</x>
  <y>291</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7819af6f-a4b0-4b0a-b121-88f6c51493f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Starting Pitch of Tracker (oct)</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Starting</objectName>
  <x>8</x>
  <y>274</y>
  <width>500</width>
  <height>27</height>
  <uuid>{831982c9-56fa-43a3-9d99-98b0d9cc4012}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>4.00000000</minimum>
  <maximum>14.00000000</maximum>
  <value>7.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Starting</objectName>
  <x>448</x>
  <y>291</y>
  <width>60</width>
  <height>30</height>
  <uuid>{22528a34-170f-4f51-95fa-9cdb38c5374e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <y>327</y>
  <width>180</width>
  <height>30</height>
  <uuid>{6c0cca1d-0205-4af5-9689-f0ae09584691}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Q of Filters</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Q_Filters</objectName>
  <x>8</x>
  <y>310</y>
  <width>500</width>
  <height>27</height>
  <uuid>{928b4ab1-3eb0-4f63-9d91-e93d30ed3d7d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>50.00000000</maximum>
  <value>10.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Q_Filters</objectName>
  <x>448</x>
  <y>327</y>
  <width>60</width>
  <height>30</height>
  <uuid>{642c0bde-f5a4-4152-a74d-b9f752e6e26f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Harmonics</objectName>
  <x>209</x>
  <y>364</y>
  <width>80</width>
  <height>30</height>
  <uuid>{4b481150-4539-41ae-b10b-dc27d4aa2c83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <maximum>50</maximum>
  <randomizable group="0">false</randomizable>
  <value>10</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>79</x>
  <y>389</y>
  <width>130</width>
  <height>29</height>
  <uuid>{4e135e75-5181-4d12-b801-79f5db9fb50c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>No of Harmonics</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <objectName>Skip</objectName>
  <x>311</x>
  <y>364</y>
  <width>130</width>
  <height>30</height>
  <uuid>{b984279b-6ce2-47f5-805d-d341e65b26f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> Skip Initialisation</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>426</y>
  <width>180</width>
  <height>30</height>
  <uuid>{351e790b-4ed4-4578-92e9-b6bc8e9965ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rolloff</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Rolloff</objectName>
  <x>8</x>
  <y>409</y>
  <width>500</width>
  <height>27</height>
  <uuid>{16ac42a7-e8d7-4cb7-81ff-fab93f2203f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.99000000</maximum>
  <value>0.75066200</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Rolloff</objectName>
  <x>448</x>
  <y>426</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e687fcfa-dd20-4c7b-aa5c-d5823fdbdb7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.751</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

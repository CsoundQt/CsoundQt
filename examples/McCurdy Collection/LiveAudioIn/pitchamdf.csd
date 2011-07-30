;Written by Iain McCurdy, 2009

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add limits for min/max frequencies


;my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 -+rtmidi=null
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 64		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


giExp10000	ftgen	0, 0, 129, -25, 0, 20.0, 128, 10000.0	;TABLE FOR EXP SLIDER


instr	10	;GUI
	klimit	init	0
	idelta	=	10.0

	ktrig	metro	10
	if (ktrig == 1)	then
		gkInGain		invalue 	"Input_Gain"
		gkGateThresh	invalue 	"Gate_Threshold"
		kmincps		invalue 	"Min_Freq"
		gkmincps		tablei	kmincps, giExp10000, 1
		kmaxcps		invalue 	"Max_Freq"
		gkmaxcps		tablei	kmaxcps, giExp10000, 1

	if gkmincps > gkmaxcps - idelta then
		gkmincps	=	gkmaxcps - idelta
		klimit	=	1
	else
		klimit	=	0
	endif
					outvalue	"Min_Freq_Value", gkmincps
					outvalue	"Max_Freq_Value", gkmaxcps
					outvalue	"Limit", klimit
	endif
endin

instr	1
	aL			inch		1									;READ FIRST/LEFT AUDIO INPUT TO THE COMPUTER
	aL			=		aL * gkInGain							;RESCALE AUDIO SIGNAL USING INPUT GAIN CONTROL

	;;;;;;;;;AUDIO GATE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	afollow 		follow2 	aL, .0001, .03							;CREATE A AMPLITUDE FOLLOWING UNIPOLAR SIGNAL
	kfollow		downsamp	afollow								;DOWNSAMPLE TO CREATE A K-RATE VERSION OF THE AMPLITUDE FOLLOWING SIGNAL
	kgate		=		(kfollow<gkGateThresh?0:1)				;CREATE A GATE SIGNAL (EITHER 1 OR ZERO DEPENDING UPON COMPARISON WITH THE THRESHOLD VALUE
	kgateport		port		kgate,.01								;SMOOTH THE OPENING AND CLOSING OF THE GATE TO PREVENT CLICKS
	aL			=		aL*kgateport							;APPLY THE GATING SIGNAL
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;CREATE A PITCH TRACKING VARIABLE AND AN AMPLITUDE TRACKING VARIABLE USING THE 'pitchamdf' OPCODE - IMPROVED RESULTS CAN BE ACHIEVED BY FIRST ATTENUATING THE AMPLITUDE OF THE INPUT SIGNAL, YOU WILL NOTICE THAT 'aL' IS FIRST DIVIDED BY 10
	kSwitch		changed	gkmincps, gkmaxcps						;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if 	kSwitch=1	then											;IF A CHANGE HAS BEEN DETECTED...
				reinit	UPDATE								;BEGIN A REINITIALISATION PASS BEGINNING AT LABEL 'UPDATE'
	endif													;END OF CONDITIONAL BRANCHING

	UPDATE:													;LABEL
	kcps, krms 	pitchamdf	aL, i(gkmincps), i(gkmaxcps)				;TRACK PITCH AND RMS
				rireturn										;END OF INITIALISATION PASS

	arms			interp	krms*10								;RECALIBRATE THE AMPLITUDE FOLLOWING SIGNAL UPWARDS - ALSO INTERPOLATE TO CREATE AN A-RATE SIGNAL TO PREVENT CLICKS AS THE AMPLITUDE FLUCTUATES
	asig			oscili	1, kcps, 1							;CREATE A SYNTHESIZED TONE THAT MIMICS THE FREQUENCY AND AMPLITUDE ATTRIBUTES OF THE INPUT SIGNAL
	ares 		gain 	asig, krms
				outs		ares, ares							;SEND THE SYNTHESIZED TONE TO THE OUTPUTS

	;;;;;;;;UPDATE METERS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	ktrigger		metro	20									;UPDATE RATE FOR METERS
	if	kgate = 0	then											;IF GATE IS ON...
		krms	=	0											;SET RMS TO MINIMUM - THIS IS TO PREVENT ERRATIC METER MOVEMENT WHEN GATE IS ON
		kcps	=	20											;SET CPS TO MINIMUM - THIS IS TO PREVENT ERRATIC METER MOVEMENT WHEN GATE IS ON
	endif													;END OF CONDITIONAL BRANCHING

	if	ktrigger = 1	then
				outvalue	"rms", krms							;UPDATE GUI METERS
				outvalue	"cps", log10(kcps)						;UPDATE GUI METERS
	endif
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endin
</CsInstruments>
<CsScore>
f 1 0 1024 10 1 .2 .15 .1 .2 .1 .05 .02 .01		;A RICH TONE - USED BY THE PITCH TRACKING SYNTHESIZER
f 2 0 131072 10 1							;A SINE WAVE

;INSTR | START | DURATION
i 10		0	   3600	;GUI AND AUDIO INPUTS
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
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
  <width>514</width>
  <height>300</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pitchamdf</label>
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
  <x>519</x>
  <y>2</y>
  <width>566</width>
  <height>300</height>
  <uuid>{cebe7e5c-304d-4db6-8da2-0e27c0616bab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pitchamdf</label>
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
  <x>520</x>
  <y>18</y>
  <width>563</width>
  <height>280</height>
  <uuid>{c24a85f3-363e-476e-81da-37729ad65bb7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------------------------------------------------------
This example presents a simple demonstration of the 'pitchamdf' opcode, used for pitch and amplitude tracking. It requires a live audio input so you should have a microphone connected to your computer and get ready to sing into it!
'Pitchamdf' outputs two k-rate variables and for frequency and the other for the amplitude of an input audio signal. For clarity, the usage of this data in this example is quite trivial in that it is used merely as input data for the frequency and amplitude of a simple synthesizing oscillator. With a little imagination, many more interesting applications are possible. Careful adjustment of the controls for minimum and maximum allowed frequencies can improve the pitch tracker's accuracy. I have added a basic noise gate to prevent ambient noise being tracked between intentional notes being played or sung. You can fine-tune the threshold of this noise gate. I have added meters that allow you to monitor the pitch tracker's output visually. An alternative opcode for pitch and amplitude tracking worth investigating is 'pitch'. Pitch tracking is a much more involved and CPU intensive process than amplitude tracking. If you only require amplitude tracking it is recommended that you use either the 'follow' or 'follow2' opcodes.</label>
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
   <r>158</r>
   <g>220</g>
   <b>158</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>180</y>
  <width>180</width>
  <height>30</height>
  <uuid>{63ab529c-3f14-4886-8215-fd6e8f1a37ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Maximum Frequency (cps)</label>
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
  <objectName>Max_Freq</objectName>
  <x>8</x>
  <y>163</y>
  <width>500</width>
  <height>27</height>
  <uuid>{a7c37920-a18a-446b-8b66-6a1119503da0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.55200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Max_Freq_Value</objectName>
  <x>448</x>
  <y>180</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b453c0e4-809f-4074-94fd-506ebb68f3b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>617.985</label>
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
  <y>73</y>
  <width>180</width>
  <height>30</height>
  <uuid>{93cc32a5-c161-4212-baeb-c28b120f89a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input Gain</label>
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
  <objectName>Input_Gain</objectName>
  <x>8</x>
  <y>56</y>
  <width>500</width>
  <height>27</height>
  <uuid>{107836e5-a726-4a83-83b5-c368481d9a48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Input_Gain</objectName>
  <x>448</x>
  <y>73</y>
  <width>60</width>
  <height>30</height>
  <uuid>{71f0e6eb-f79d-4cd7-80f7-a22cc355e64f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
  <y>109</y>
  <width>180</width>
  <height>30</height>
  <uuid>{e193ffd3-920b-40d4-9eaa-bd11dad75bff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gate Threshold</label>
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
  <objectName>Gate_Threshold</objectName>
  <x>8</x>
  <y>92</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e4aa4e7b-5b74-4a61-8bd7-4beea2c0bb93}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.30000000</maximum>
  <value>0.01980000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gate_Threshold</objectName>
  <x>448</x>
  <y>109</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dc879380-3a9e-4939-b482-a0b4ee46dac5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.020</label>
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
  <y>145</y>
  <width>180</width>
  <height>30</height>
  <uuid>{866a933e-0c0d-493a-84af-29f3557f8e4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Minimum Frequency (cps)</label>
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
  <objectName>Min_Freq</objectName>
  <x>8</x>
  <y>128</y>
  <width>500</width>
  <height>27</height>
  <uuid>{fbbd0dd3-c206-4214-aa5e-10d42b909252}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.26800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Min_Freq_Value</objectName>
  <x>448</x>
  <y>145</y>
  <width>60</width>
  <height>30</height>
  <uuid>{31c3cb1b-308f-47cd-9396-c81d85a1c30a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>105.795</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>6</x>
  <y>6</y>
  <width>100</width>
  <height>30</height>
  <uuid>{78037c31-527b-4eba-beba-f939296eb729}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off</text>
  <image>/</image>
  <eventLine>i1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>rms</objectName>
  <x>8</x>
  <y>226</y>
  <width>500</width>
  <height>10</height>
  <uuid>{6d7a1ba4-fb93-4386-9ab8-498172ff97e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.04192121</xValue>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>234</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6e554bee-8b48-4edd-b180-7d48199200ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>rms</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>cps</objectName>
  <x>8</x>
  <y>261</y>
  <width>500</width>
  <height>10</height>
  <uuid>{8ea565dd-f7f8-491d-a403-ffe0ea30dda6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>5.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>2.24476480</xValue>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>269</y>
  <width>60</width>
  <height>30</height>
  <uuid>{13f39f2d-425c-4a77-a2dc-9569d9048cfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>cps</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Limit</objectName>
  <x>438</x>
  <y>199</y>
  <width>70</width>
  <height>20</height>
  <uuid>{4862a393-c371-4b97-b288-d6561f337911}</uuid>
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
  <y>198</y>
  <width>70</width>
  <height>20</height>
  <uuid>{98a2d52e-ef0c-4b6a-879a-2e7bc94bc844}</uuid>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

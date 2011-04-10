;Written by Iain McCurdy, 2008

;THE delay OPCODES IS PLACED IN A SEPARATE, ALWAYS ON, INSTRUMENT FROM THE SOURCE SOUND PRODUCING INSTRUMENT.
;THE IS A COMMONLY USED TECHNIQUE WITH TIME SMEARING OPCODES AND EFFECTS LIKE REVERBS AND DELAYS.

;ksmps MAY NEED TO BE LOW (AND kr THEREFORE HIGH) WHEN WORKING WITH SHORT DELAY TIMES DEFINED INITIALLY AT KRATE


;Modified for QuteCsound by René, September 2010
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Cannot display more than one space in Label, so can't display the schematic shown below:
;
;                           (feedback)
;                        +-------<------+
;                        |              |
;                        v  +--------+  ^
;                        |  |        |  |
;      +-----------------+--+Delay L +--+---->LEFT_OUT
;      |                    |time x 2|
;      |                    +--------+
;      |
; IN->-+
;      |
;      |     +--------+     +--------+
;      |     |Offset  |     |        |
;      +-----+Delay   +--+--+Delay  R+--+---->RIGHT_OUT
;            |time x 1|  |  |time x 2|  |
;            +--------+  ^  +--------+  v
;                        |              |
;                        +-------<------+
;                           (feedback)


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 48000		;SAMPLE RATE
ksmps	= 10			;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


gimaxdelay	=	5	;MAXIMUM DELAY TIME VARIABLE USED BOTH BY THE ORCHESTRA CODE AND BY GUI INSTRUMENT (giExp1 table used for Delay_Time slider)

giExp1		ftgen	0, 0, 129, -25, 0, 0.01, 128, gimaxdelay		;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkInGain		invalue 		"Live_Input_Gain"				;init 0
		kdlt			invalue		"Delay_Time"
		gkdlt		tablei		kdlt, giExp1, 1
					outvalue		"Delay_Time_Value", gkdlt		;init 0.33
		gkmix		invalue	 	"Mix"						;init 0.5
		gkfeedamt		invalue 		"Feedback_Amount"				;init 0.66
		gkamp		invalue 		"Output_Amplitude_Rescaling"		;init .7
	endif
endin

instr	1	;GENERATES A SHORT SYNTHESISED IMPULSE SOUND                                                                                                     
	aenv			expseg	0.0001, 0.01, 1, p3-0.01, 0.0001			;PERCUSSIVE-TYPE AMPLITUDE ENVELOPE
	asig1		noise	0.3 * aenv, 0							;GENERATE A 'WHITE NOISE' SIGNAL
	iCutoff_Oct	random	6,14									;CREATE A RANDOM VALUE FOR CUTOFF FREQUENCY (IN OCT FORMAT)
	asig2		butlp	asig1, cpsoct(iCutoff_Oct)				;LOWPASS FILTER WHITE NOISE
	gasig		balance	asig2, asig1							;BALANCE FILTERED SIGNAL WITH UNFILTERED WHITE NOISE SIGNAL TO COMPENSATE FOR AMPLITUDE LOSS
endin

instr 	2	;STEREO PING-PONG DELAY INSTRUMENT - ALSO READS LIVE INPUT SIGNAL
	gasig		init		0									;SET INITIAL STATE OF GLOBAL AUDIO SIGNAL (SILENCE)
	aInL, aInR	ins											;READ LIVE AUDIO INPUT
	aInL			=		(aInL * gkInGain) + gasig				;MIX LIVE AUDIO IN WITH GLOBAL AUDIO SIGNAL RECEIVED FROM INSTR 1
	aInR			=		(aInR * gkInGain) + gasig				;MIX LIVE AUDIO IN WITH GLOBAL AUDIO SIGNAL RECEIVED FROM INSTR 1
	
	iporttime		=		.1									;PORTAMENTO TIME
	kporttime		linseg	0, .001, iporttime, 1, iporttime			;USE OF AN ENVELOPE VALUE THAT QUICKLY RAMPS UP FROM ZERO TO THE REQUIRED VALUE. THIS PREVENTS VARIABLES GLIDING TO THEIR REQUIRED VALUES EACH TIME THE INSTRUMENT IS STARTED
	kdlt			portk	gkdlt, kporttime						;PORTAMENTO IS APPLIED TO THE VARIABLE 'gkdlt'. A NEW VARIABLE 'kdlt' IS CREATED.
	adlt			interp	kdlt									;A NEW A-RATE VARIABLE 'adlt' IS CREATED BY INTERPOLATING THE K-RATE VARIABLE 'kdlt' 
	
	;;;RIGHT CHANNEL OFFSET;;;NO FEEDBACK!!;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	abufferR_OS	delayr	gimaxdelay							;CREATE A DELAY BUFFER OF imaxdelay SECONDS DURATION
	adelsigR_OS 	deltap3	adlt									;TAP THE DELAY LINE AT adlt SECONDS
				delayw	aInL									;WRITE AUDIO SOURCE INTO THE BEGINNING OF THE BUFFER
	
	;;;LEFT CHANNEL DELAY;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	abufferL		delayr	gimaxdelay*2							;CREATE A DELAY BUFFER OF 5 SECONDS DURATION (EQUIVALENT TO THE MAXIMUM DELAY TIME POSSIBLE USING THIS EXAMPLE)
	adelsigL 		deltap3	adlt*2								;TAP THE DELAY LINE AT gkdlt SECONDS
				delayw	aInR + (adelsigL * gkfeedamt)				;WRITE AUDIO SOURCE AND FEEDBACK SIGNAL INTO THE BEGINNING OF THE BUFFER
	
	abufferR		delayr	gimaxdelay*2							;CREATE A DELAY BUFFER OF 5 SECONDS DURATION (EQUIVALENT TO THE MAXIMUM DELAY TIME POSSIBLE USING THIS EXAMPLE)
	adelsigR 		deltap3	adlt*2								;TAP THE DELAY LINE AT gkdlt SECONDS
				delayw	adelsigR_OS + (adelsigR * gkfeedamt)		;WRITE AUDIO SOURCE AND FEEDBACK SIGNAL INTO THE BEGINNING OF THE BUFFER

				outs		((adelsigL * gkmix) + (aInL * (1-gkmix))) * gkamp, (((adelsigR + adelsigR_OS) * gkmix) + (aInR * (1-gkmix))) * gkamp	;CREATE A MIX BETWEEN THE WET AND THE DRY SIGNALS AT THE OUTPUT
	gasig		=		0									;CLEAR THE GLOBAL AUDIO SEND VARIABLES
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		-1		;GUI
i  2      0    	-1		;INSTRUMENT 2 (DELAY INSTRUMENT) PLAYS A HELD NOTE

f 0	  3600				;DUMMY SCORE EVENT KEEPS REALTIME PERFORMANCE GOING FOR 1 HOUR
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>501</x>
 <y>703</y>
 <width>933</width>
 <height>324</height>
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
  <width>524</width>
  <height>310</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>     Stereo Ping-Pong Delay</label>
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
  <width>160</width>
  <height>30</height>
  <uuid>{487d5181-d838-4cce-9628-317fefc350cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Short Impulse Sound</text>
  <image>/</image>
  <eventLine>i 1 0 0.1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Live_Input_Gain</objectName>
  <x>10</x>
  <y>69</y>
  <width>500</width>
  <height>27</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>88</y>
  <width>140</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Live Input Gain</label>
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
  <objectName>Live_Input_Gain</objectName>
  <x>451</x>
  <y>86</y>
  <width>59</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.002</label>
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
  <x>527</x>
  <y>2</y>
  <width>399</width>
  <height>310</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Stereo Ping-Pong Delay</label>
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
  <x>530</x>
  <y>28</y>
  <width>393</width>
  <height>283</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------
This example implements the classic ping-pong delay effect. To implement the effect a total of three delay buffers are required. One for the left channel with its own feedback loop, one for the right channel with its own feedback loop and a third one to create an initial delay offset in the right channel. The first echo we will hear will be in the left channel. The offsetting delay buffer has no feedback loop. The schematic is shown in the csd. The delay time for the offsetting delay is the same as that defined by the on-screen slider for delay time. The delay times for the other two delays with feedback are twice the value defined by the slider. When the echoes alternate the perceived delay time will be the same as that defined by the slider. The input sound for the effect in this example can be either a short synthesised impulse triggered by the button or the computer's live input controlled by the 'Input Gain' slider.</label>
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
  <objectName>Delay_Time_Value</objectName>
  <x>450</x>
  <y>126</y>
  <width>60</width>
  <height>30</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.218</label>
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
  <x>10</x>
  <y>169</y>
  <width>140</width>
  <height>30</height>
  <uuid>{b57ba536-8f28-4986-9bf7-8eb84262d8ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry/Wet Mix</label>
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
  <objectName>Delay_Time</objectName>
  <x>10</x>
  <y>109</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b8fa76b9-3d04-4156-a2f2-a413d3864da3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.49600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Mix</objectName>
  <x>450</x>
  <y>166</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5f670bb1-e411-4f17-94a3-2321fdf5742b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.502</label>
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
  <objectName>Mix</objectName>
  <x>10</x>
  <y>149</y>
  <width>500</width>
  <height>27</height>
  <uuid>{1920efdc-fe11-4010-a22c-50efec0c27d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>128</y>
  <width>140</width>
  <height>30</height>
  <uuid>{aea841b2-29e6-42d6-ac23-02439b1cc47f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Time (sec.)</label>
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
  <objectName>Feedback_Amount</objectName>
  <x>10</x>
  <y>189</y>
  <width>500</width>
  <height>27</height>
  <uuid>{afe11ed2-eb11-423d-a391-3677ebeda4f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.66800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Feedback_Amount</objectName>
  <x>450</x>
  <y>206</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d6bd3764-66b6-499b-8028-0113ff526003}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.668</label>
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
  <x>10</x>
  <y>209</y>
  <width>140</width>
  <height>30</height>
  <uuid>{4100a5b8-76c3-4420-9229-a606f4defaf9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feedback Amount</label>
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
  <objectName>Output_Amplitude_Rescaling</objectName>
  <x>450</x>
  <y>247</y>
  <width>60</width>
  <height>30</height>
  <uuid>{54ac276d-3b29-4d80-bbeb-a86bdb760fe3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.702</label>
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
  <x>10</x>
  <y>249</y>
  <width>180</width>
  <height>30</height>
  <uuid>{224170e9-6fd8-4117-9cb2-a90d433639ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Amplitude Rescaling</label>
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
  <objectName>Output_Amplitude_Rescaling</objectName>
  <x>10</x>
  <y>230</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f188ef98-8516-4b91-9a8e-7bf3a39b6227}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.70200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

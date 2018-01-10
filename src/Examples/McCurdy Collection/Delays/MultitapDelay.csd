;Written by Iain McCurdy, 2008

; Modified for QuteCsound by René, September 2010
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for lin slider for variable maximum


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


gasig		init	0

giMaxDelay	=	5	;MAXIMUM DELAY TIME - A VARIABLE USED BY BOTH THE GUI CODE AND THE ORCHESTRA (WHICH IS WHY IT APPEARS UP HERE)

giLin1		ftgen	0, 0, 129, -27, 0, 0.0001, 128, giMaxDelay		;TABLE FOR LIN SLIDER

instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkInGain		invalue 	"Live_Input_Gain"				;init 0
		gkdlt1		invalue 	"Delay_Time1"					;init 31		;PERCENTAGE
		gkdlt2		invalue 	"Delay_Time2"					;init 67		;PERCENTAGE
		gkdlt3		invalue 	"Delay_Time3"					;init 83		;PERCENTAGE
		kdlt4		invalue	"Delay_Time4"
		gkdlt4		tablei	kdlt4, giLin1, 1
					outvalue	"Delay_Time4_Value", gkdlt4		;init 1.789	;SECONDS

		gkgain1		invalue 	"Tap_Gain1"					;init .1
		gkgain2		invalue 	"Tap_Gain2"					;init .5
		gkgain3		invalue 	"Tap_Gain3"					;init .2
		gkgain4		invalue 	"Tap_Gain4"					;init .9

		gkpan1		invalue 	"Tap_Pan1"					;init .1
		gkpan2		invalue 	"Tap_Pan2"					;init .9
		gkpan3		invalue 	"Tap_Pan3"					;init .2
		gkpan4		invalue 	"Tap_Pan4"					;init .8

		gkmix		invalue 	"Dry_Wet_Ratio"				;init 0.5
		gkfeedamt		invalue 	"Feedback_Ratio"				;init 0.5
		gkMgain		invalue 	"Master_Gain"					;init 0.7
	endif
endin

instr	1	;GENERATES A SHORT SYNTHESISED IMPULSE SOUND                                                                                                     
	aenv			expseg		0.0001, 0.01, 1, p3-0.01, 0.0001			;PERCUSSIVE-TYPE AMPLITUDE ENVELOPE
	asig1		noise		0.3 * aenv, 0							;GENERATE A 'WHITE NOISE' SIGNAL
	iCutoff_Oct	random		6,14									;CREATE A RANDOM VALUE FOR CUTOFF FREQUENCY (IN OCT FORMAT)
	asig2		butlp		asig1, cpsoct(iCutoff_Oct)				;LOWPASS FILTER WHITE NOISE
	gasig		balance		asig2, asig1							;BALANCE FILTERED SIGNAL WITH UNFILTERED WHITE NOISE SIGNAL TO COMPENSATE FOR AMPLITUDE LOSS
endin

instr 	2	;DELAY INSTRUMENT
	ain			inch			1									;READ LIVE AUDIO FROM INPUT CHANNEL 1 (LEFT)
	ain			=			(ain * gkInGain) + gasig					;SCALE LIVE INPUT WITH ON-SCREEN GAIN SLIDER, ADD ANY SOUND IMPULSE SIGNAL FROM INSTR 1
	afeedbacksigL	init			0									;LEFT AND RIGHT CHANNELS OF THE FEEDBACK SIGNAL ARE INITIALISED TO ZERO
	afeedbacksigR	init			0									;LEFT AND RIGHT CHANNELS OF THE FEEDBACK SIGNAL ARE INITIALISED TO ZERO
	iporttime		=			.1									;PORTAMENTO TIME
	kporttime		linseg		0, .001, iporttime, 1, iporttime			;USE OF AN ENVELOPE VALUE THAT QUICKLY RAMPS UP FROM ZERON TO THE REQUIRED VALUE PREVENTS VARIABLES GLIDING TO THEIR REQUIRED VALUES EACH TIME THE INSTRUMENT IS STARTED
	
	kdlt1		=			gkdlt4 * gkdlt1 * 0.01					;DELAY TIME 1 WILL BE A RATIO OF DELAY TIME 4
	kdlt2		=			gkdlt4 * gkdlt2 * 0.01					;DELAY TIME 2 WILL BE A RATIO OF DELAY TIME 4
	kdlt3		=			gkdlt4 * gkdlt3 * 0.01					;DELAY TIME 3 WILL BE A RATIO OF DELAY TIME 4
	kdlt1		portk		kdlt1, kporttime					 	;PORTAMENTO IS APPLIED TO kdlt1
	kdlt2		portk		kdlt2, kporttime					 	;PORTAMENTO IS APPLIED TO kdlt2
	kdlt3		portk		kdlt3, kporttime					 	;PORTAMENTO IS APPLIED TO kdlt3
	kdlt4		portk		gkdlt4,kporttime					 	;PORTAMENTO IS APPLIED TO kdlt4
	adlt1		interp		kdlt1								;A NEW A-RATE VARIABLE 'adlt' IS CREATED BY INTERPOLATING THE K-RATE VARIABLE 'kdlt' 
	adlt2		interp		kdlt2								;A NEW A-RATE VARIABLE 'adlt' IS CREATED BY INTERPOLATING THE K-RATE VARIABLE 'kdlt' 
	adlt3		interp		kdlt3								;A NEW A-RATE VARIABLE 'adlt' IS CREATED BY INTERPOLATING THE K-RATE VARIABLE 'kdlt' 
	adlt4		interp		kdlt4								;A NEW A-RATE VARIABLE 'adlt' IS CREATED BY INTERPOLATING THE K-RATE VARIABLE 'kdlt' 
	
	abufferL		delayr		giMaxDelay							;CREATE A DELAY BUFFER OF giMaxDelay (5) SECONDS DURATION (EQUIVALENT TO THE MAXIMUM DELAY TIME POSSIBLE USING THIS EXAMPLE)
	atap1L 		deltap3		adlt1								;TAP THE DELAY LINE AT gkdlt SECONDS
	atap2L 		deltap3		adlt2								;TAP THE DELAY LINE AT gkdlt SECONDS
	atap3L 		deltap3		adlt3								;TAP THE DELAY LINE AT gkdlt SECONDS
	atap4L 		deltap3		adlt4								;TAP THE DELAY LINE AT gkdlt SECONDS
				delayw		ain + afeedbacksigL						;WRITE AUDIO SOURCE AND FEEDBACK SIGNAL INTO THE BEGINNING OF THE BUFFER
	afeedbacksigL	=			atap4L * gkfeedamt						;CREATE FEEDBACK SIGNAL (AN ATTENUATED PROPORTION OF THE DELAY OUTPUT SIGNAL)
	atap1L		=			atap1L*gkpan1
	atap2L		=			atap2L*gkpan2
	atap3L		=			atap3L*gkpan3
	atap4L		=			atap4L*gkpan4
	
	abufferR		delayr		giMaxDelay							;CREATE A DELAY BUFFER OF giMaxDelay (5) SECONDS DURATION (EQUIVALENT TO THE MAXIMUM DELAY TIME POSSIBLE USING THIS EXAMPLE)
	atap1R 		deltap3		adlt1								;TAP THE DELAY LINE AT gkdlt SECONDS
	atap2R 		deltap3		adlt2								;TAP THE DELAY LINE AT gkdlt SECONDS
	atap3R 		deltap3		adlt3								;TAP THE DELAY LINE AT gkdlt SECONDS
	atap4R 		deltap3		adlt4								;TAP THE DELAY LINE AT gkdlt SECONDS
				delayw		ain + afeedbacksigR						;WRITE AUDIO SOURCE AND FEEDBACK SIGNAL INTO THE BEGINNING OF THE BUFFER
	afeedbacksigR	=			atap4R * gkfeedamt						;CREATE FEEDBACK SIGNAL (AN ATTENUATED PROPORTION OF THE DELAY OUTPUT SIGNAL)
	atap1R		=			atap1R*(1-gkpan1)
	atap2R		=			atap2R*(1-gkpan2)
	atap3R		=			atap3R*(1-gkpan3)
	atap4R		=			atap4R*(1-gkpan4)
	
	aoutL		=			(((atap1L+atap2L+atap3L+atap4L) * gkmix) + (ain * (1-gkmix))) * gkMgain
	aoutR		=			(((atap1R+atap2R+atap3R+atap4R) * gkmix) + (ain * (1-gkmix))) * gkMgain
	
				outs			aoutL, aoutR
	gasig		=			0									;CLEAR THE GLOBAL AUDIO SEND VARIABLES
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		-1		;GUI
i  2      0    	-1		;INSTRUMENT 10 (MULTITAP DELAY) PLAYS A HELD NOTE

f 0	  3600				;DUMMY SCORE EVENT KEEPS REALTIME PERFORMANCE GOING FOR 1 HOUR
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>550</x>
 <y>265</y>
 <width>814</width>
 <height>552</height>
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
  <width>520</width>
  <height>520</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4 Tap Delay with Feedback</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
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
  <width>150</width>
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
  <y>48</y>
  <width>500</width>
  <height>27</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>65</y>
  <width>160</width>
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
  <x>450</x>
  <y>65</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
  <x>523</x>
  <y>2</y>
  <width>284</width>
  <height>520</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Multitap Delay
 (using delayw, delayr &amp; deltap3)</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
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
  <x>529</x>
  <y>59</y>
  <width>273</width>
  <height>398</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------
This example is an implementation of a typical multitap delay. This is a four-tap delay but as it is stereo there are actually two separate delay buffers, one for each channel with four taps on each.
Input for this example can be either the computers live input (raise the input gain control) or a short noise impulse sound triggered by clicking the on-screen button.
The feedback signal for the feedback loop is taken from the fourth delay tap. For this reason the delay time for the fourth tap must be longest.
In the design of this GUI, the fourth tap is the only one where the user specifies a delay time in seconds, the other three are expressed as percentages of the fourth, thus ensuring that they can not exceed the fourth.</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <objectName>Dry_Wet_Ratio</objectName>
  <x>450</x>
  <y>413</y>
  <width>60</width>
  <height>30</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.840</label>
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
  <y>453</y>
  <width>140</width>
  <height>30</height>
  <uuid>{b57ba536-8f28-4986-9bf7-8eb84262d8ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feedback Ratio</label>
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
  <objectName>Dry_Wet_Ratio</objectName>
  <x>10</x>
  <y>396</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b8fa76b9-3d04-4156-a2f2-a413d3864da3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.84000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Feedback_Ratio</objectName>
  <x>450</x>
  <y>453</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5f670bb1-e411-4f17-94a3-2321fdf5742b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.872</label>
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
  <objectName>Feedback_Ratio</objectName>
  <x>10</x>
  <y>436</y>
  <width>500</width>
  <height>27</height>
  <uuid>{1920efdc-fe11-4010-a22c-50efec0c27d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.87200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>413</y>
  <width>140</width>
  <height>30</height>
  <uuid>{aea841b2-29e6-42d6-ac23-02439b1cc47f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry / Wet Ratio</label>
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
  <objectName>Master_Gain</objectName>
  <x>10</x>
  <y>476</y>
  <width>500</width>
  <height>27</height>
  <uuid>{afe11ed2-eb11-423d-a391-3677ebeda4f1}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Master_Gain</objectName>
  <x>450</x>
  <y>493</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d6bd3764-66b6-499b-8028-0113ff526003}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
  <y>493</y>
  <width>140</width>
  <height>30</height>
  <uuid>{4100a5b8-76c3-4420-9229-a606f4defaf9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Master Gain</label>
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
  <objectName>Delay_Time1</objectName>
  <x>10</x>
  <y>88</y>
  <width>500</width>
  <height>21</height>
  <uuid>{b9afae76-a81f-4aa0-bba9-b2b97eccb4cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>31.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Delay_Time2</objectName>
  <x>10</x>
  <y>108</y>
  <width>500</width>
  <height>21</height>
  <uuid>{f152ae02-4ec2-4820-bb61-215c969c473f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>39.01600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Delay_Time4</objectName>
  <x>10</x>
  <y>148</y>
  <width>500</width>
  <height>21</height>
  <uuid>{da58bf25-2f86-4782-a5fa-fe106680df8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.34600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Delay_Time3</objectName>
  <x>10</x>
  <y>128</y>
  <width>500</width>
  <height>21</height>
  <uuid>{5161fb3f-90e5-4713-bdf2-63f8ffc49b6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>36.04600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>162</y>
  <width>160</width>
  <height>30</height>
  <uuid>{7bd168df-93d9-4c33-a178-8b003676811b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Times</label>
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
  <objectName>Delay_Time1</objectName>
  <x>156</x>
  <y>162</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3445797f-d2df-4774-8859-e2264b42f870}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>31.000</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Delay_Time2</objectName>
  <x>246</x>
  <y>162</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3feb4e25-01ad-47e4-97f8-4c4e7b3ff0e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>39.016</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Delay_Time3</objectName>
  <x>336</x>
  <y>162</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ea048849-1425-4adf-893a-6c60353369b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>36.046</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Delay_Time4_Value</objectName>
  <x>426</x>
  <y>162</y>
  <width>60</width>
  <height>30</height>
  <uuid>{aed3ec30-9b73-4235-bc36-927b49f57914}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.730</label>
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
  <x>216</x>
  <y>162</y>
  <width>30</width>
  <height>30</height>
  <uuid>{39393883-5092-4a77-81e9-dd5c24321cd7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>%</label>
  <alignment>left</alignment>
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
  <x>306</x>
  <y>162</y>
  <width>30</width>
  <height>30</height>
  <uuid>{14fea16e-150a-403f-bd23-dbc7227ad749}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>%</label>
  <alignment>left</alignment>
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
  <x>396</x>
  <y>162</y>
  <width>30</width>
  <height>30</height>
  <uuid>{dfe31563-5fbd-4239-95ad-8c80e6dc6474}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>%</label>
  <alignment>left</alignment>
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
  <x>483</x>
  <y>162</y>
  <width>40</width>
  <height>30</height>
  <uuid>{9b7185ea-ed53-43e3-8fd0-e206980b23a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>secs</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Tap_Gain4</objectName>
  <x>426</x>
  <y>264</y>
  <width>60</width>
  <height>30</height>
  <uuid>{95cc65a0-be4a-4b26-9ca8-87fa598e13bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.374</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Tap_Gain3</objectName>
  <x>336</x>
  <y>264</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5367fe85-742c-4e8a-a000-58b687f368a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.402</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Tap_Gain2</objectName>
  <x>246</x>
  <y>264</y>
  <width>60</width>
  <height>30</height>
  <uuid>{588b8513-8bd5-436e-957d-d3b6b3802854}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.416</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Tap_Gain1</objectName>
  <x>156</x>
  <y>263</y>
  <width>60</width>
  <height>30</height>
  <uuid>{844d7324-1228-4552-a4db-fe978e99f16a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.404</label>
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
  <y>264</y>
  <width>160</width>
  <height>30</height>
  <uuid>{61b33350-22c4-4beb-b7cb-ed6188885ad5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Taps Gains</label>
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
  <objectName>Tap_Gain3</objectName>
  <x>10</x>
  <y>230</y>
  <width>500</width>
  <height>21</height>
  <uuid>{a7d138f1-c40b-4aa6-b5fc-a208d3a6f04b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.40200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Tap_Gain4</objectName>
  <x>10</x>
  <y>250</y>
  <width>500</width>
  <height>21</height>
  <uuid>{39cb041f-1f1e-4129-892a-50ec5f4448d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.37400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Tap_Gain2</objectName>
  <x>10</x>
  <y>210</y>
  <width>500</width>
  <height>21</height>
  <uuid>{a682fdb3-33dd-4aed-9b02-f6d8deb7dc3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.41600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Tap_Gain1</objectName>
  <x>10</x>
  <y>190</y>
  <width>500</width>
  <height>21</height>
  <uuid>{a93aa347-20eb-4f95-943f-9406c0525022}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.40400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Tap_Pan4</objectName>
  <x>426</x>
  <y>366</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3d2a9a58-98fd-486c-b239-c768725db0e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.286</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Tap_Pan3</objectName>
  <x>336</x>
  <y>366</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2320156c-6c0d-4445-a1bf-1dde9373c87b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.678</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Tap_Pan2</objectName>
  <x>246</x>
  <y>366</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d3f59ca2-bfc0-425d-be42-fbcf297122a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.118</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Tap_Pan1</objectName>
  <x>156</x>
  <y>366</y>
  <width>60</width>
  <height>30</height>
  <uuid>{31ca3327-aded-4b65-8508-a20119c9bb23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.598</label>
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
  <y>366</y>
  <width>160</width>
  <height>30</height>
  <uuid>{3b07dbe8-6a28-4440-b25b-8f9208d04414}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Taps Pans</label>
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
  <objectName>Tap_Pan3</objectName>
  <x>10</x>
  <y>332</y>
  <width>500</width>
  <height>21</height>
  <uuid>{09e39593-09c7-4db4-8474-dbfd5bf4a03b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.67800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Tap_Pan4</objectName>
  <x>10</x>
  <y>352</y>
  <width>500</width>
  <height>21</height>
  <uuid>{d4cd6a95-bfdd-44a9-b7a0-099b3796961f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.28600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Tap_Pan2</objectName>
  <x>10</x>
  <y>312</y>
  <width>500</width>
  <height>21</height>
  <uuid>{6e005919-a141-41cd-8823-489d821bef01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.11800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Tap_Pan1</objectName>
  <x>10</x>
  <y>292</y>
  <width>500</width>
  <height>21</height>
  <uuid>{43d26f0e-dc87-49fe-b43b-f093dfe376e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.59800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

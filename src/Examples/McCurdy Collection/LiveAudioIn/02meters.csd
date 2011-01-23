;Written by Iain McCurdy

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 January 2011 and QuteCsound svn rev 805


;Notes on modifications from original csd:


;my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 --expression-opt -+rtmidi=null
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 64		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


instr	1	;ALWAYS ON - SEE SCORE

	kgainL		invalue 	"Gain_L"
	kgainR		invalue 	"Gain_R"
	kpanL		invalue 	"Pan_L"
	kpanR		invalue 	"Pan_R"

	ainL, ainR	ins											;READ AUDIO FROM THE COMPUTER'S INPUT
	ainL			=		ainL * kgainL							;APPLY GAIN CONTROL
	ainR			=		ainR * kgainR							;APPLY GAIN CONTROL
	aL			=		(ainL * (1-kpanL)) + (ainR * (1 - kpanR))	;APPLY PANNING CONTROL
	aR			=		(ainL * kpanL) + (ainR * kpanR)			;APPLY PANNING CONTROL
	ameterL		follow 	aL, .01								;CREATE AN AMPLITUDE FOLLOWING UNIPOLAR SIGNAL (NEEDED FOR THE AMPLITUDE METERS)
	ameterR		follow 	aR, .01								;CREATE AN AMPLITUDE FOLLOWING UNIPOLAR SIGNAL (NEEDED FOR THE AMPLITUDE METERS)

	kmeterL		downsamp	ameterL								;CONVERT AMPLITUDE FOLLOWING SIGNAL TO K-RATE
	kmeterR		downsamp	ameterR								;CONVERT AMPLITUDE FOLLOWING SIGNAL TO K-RATE
	kmeterL		portk	kmeterL, .1							;SMOOTH THE MOVEMENT OF THE AMPLITUDE FOLLOWING SIGNAL - THIS WILL MAKE THE METERS EASIER TO VIEW
	kmeterR		portk	kmeterR, .1						     ;SMOOTH THE MOVEMENT OF THE AMPLITUDE FOLLOWING SIGNAL - THIS WILL MAKE THE METERS EASIER TO VIEW
	ktrig		changed	kmeterL, kmeterR						;IF THE AMPLIUDE FOLLOWING SIGNAL CHANGES GENERATE A TRIGGER SIGNAL (A MOMENTARY '1' VALUE)

	kreadouttrig	metro	10									;METRONOMIC TRIGGER (USED BY NUMBER BOX READOUTS) - 2 PER SECOND
	if kreadouttrig == 1 && ktrig == 1 then
				outvalue	"Meter_L", kmeterL						;UPDATE NUMBER BOX READOUTS
				outvalue	"Meter_R", kmeterR						;UPDATE NUMBER BOX READOUTS
	endif
				outs		aL, aR								;SEND THE AUDIO SIGNAL TO THE SPEAKERS
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 1		0	   3600	;INSTRUMENT 1 PLAYS FOR 1 HOUR (AND KEEPS PERFORMANCE GOING)
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
  <width>472</width>
  <height>188</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Level Meters</label>
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
  <y>64</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2c897206-0dbc-47b5-ba68-915d83839ab6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain L</label>
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
  <objectName>Gain_L</objectName>
  <x>8</x>
  <y>47</y>
  <width>300</width>
  <height>27</height>
  <uuid>{304e78d8-b320-453a-b28f-86b0ca872b86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>0.80000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gain_L</objectName>
  <x>248</x>
  <y>64</y>
  <width>60</width>
  <height>30</height>
  <uuid>{94c7e961-7981-4d21-942f-80bcc647daf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.800</label>
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
  <x>477</x>
  <y>2</y>
  <width>489</width>
  <height>188</height>
  <uuid>{cebe7e5c-304d-4db6-8da2-0e27c0616bab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Level Meters</label>
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
  <x>481</x>
  <y>21</y>
  <width>481</width>
  <height>159</height>
  <uuid>{c24a85f3-363e-476e-81da-37729ad65bb7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>---------------------------------------------------------------------------------------------------------------------
This example adds some features to the previous example that, again whilst not aurally spectacular, may prove useful in managing a live input signal in a larger realtime audio processing Csound orchestra.
Individual volume controls for each channel of the stereo input have been added.
Each channel can be panned independently.
Visual meters monitor amplitude levels and number boxes give textual confimation of these values.</label>
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
  <y>103</y>
  <width>100</width>
  <height>30</height>
  <uuid>{322c6985-0f80-4582-91e3-210b00046e85}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain R</label>
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
  <objectName>Gain_R</objectName>
  <x>8</x>
  <y>86</y>
  <width>300</width>
  <height>27</height>
  <uuid>{ff585363-a115-4dfe-8f64-1d8b9dc91bcd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>0.80000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gain_R</objectName>
  <x>248</x>
  <y>103</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a17ebb72-5cba-4282-a33d-4a9f72ff9915}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.800</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan_L</objectName>
  <x>339</x>
  <y>37</y>
  <width>60</width>
  <height>60</height>
  <uuid>{2113663f-1b1d-4a74-bcda-87143abe7d58}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pan_L</objectName>
  <x>339</x>
  <y>110</y>
  <width>60</width>
  <height>30</height>
  <uuid>{54632fef-9411-46c4-8e28-e24274a8b096}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
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
  <x>339</x>
  <y>95</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dd84a32c-32a9-4b1e-8113-4f0b999d54cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pan L</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan_R</objectName>
  <x>409</x>
  <y>37</y>
  <width>60</width>
  <height>60</height>
  <uuid>{c1ce0c6a-987b-4181-b0a3-aa3b7a8f4298}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pan_R</objectName>
  <x>409</x>
  <y>110</y>
  <width>60</width>
  <height>30</height>
  <uuid>{57976c16-ee9e-46df-9826-50cb3dd84817}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
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
  <x>409</x>
  <y>95</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1123ce5e-57e6-43ed-b6d8-958dc5e7382e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pan R</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Meter_L</objectName>
  <x>8</x>
  <y>147</y>
  <width>415</width>
  <height>9</height>
  <uuid>{62c7b289-2e6d-4604-bb01-e3cfe5d79438}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.51675668</xValue>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Meter_L</objectName>
  <x>422</x>
  <y>140</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dbaac762-0630-468d-a155-84211833082c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.517</label>
  <alignment>left</alignment>
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
  <objectName>Meter_R</objectName>
  <x>8</x>
  <y>161</y>
  <width>415</width>
  <height>9</height>
  <uuid>{30aa812f-6955-4b4a-bdaa-995875ea6d82}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55793618</xValue>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Meter_R</objectName>
  <x>422</x>
  <y>154</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d610653d-fcd0-4f1a-adbc-47ea01e299cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.558</label>
  <alignment>left</alignment>
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
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

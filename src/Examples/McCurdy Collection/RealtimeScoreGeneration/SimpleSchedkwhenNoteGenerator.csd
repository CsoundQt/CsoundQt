;Written by Iain McCurdy, 2006

;Modified for QuteCsound by René, March 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkTrigFreqMin	invalue 	"TrigFreqMin"
		gkTrigFreqMax	invalue 	"TrigFreqMax"
		gkscale		invalue	"Scale"
	endif
endin

instr	1	;THIS INSTRUMENT TRIGGERS NOTES IN INSTRUMENT 2 WITH A MINIMUM TIME GAP BETWEEN NOTES OF kmintim SECONDS
	kTrigFreq	randomi		gkTrigFreqMin, gkTrigFreqMax, 5		;TRIGGER FREQUENCY - DEFINED RANDOMLY WITHIN THE GIVEN RANGE - FREQUENCY OF NEW RANDOM NUMBER OUTPUT=5Hz
	ktrigger	metro		kTrigFreq							;CREATE A TRIGGER SIGNAL (MOMENTARY '1' IMPULSES) ACCORDING TO THE FLUCTUATING VARIABLE 'kTrigFreq'
	;NOTE DURATIONS WILL BE DEFINED RANDOMLY:
	;					MIN | MAX | FREQUENCY
	kdur		randomh		.1,    2,       5					;SAMPLE-AND-HOLD RANDOM NUMBER GENERATOR
	;		 			TRIGGER | MINTIM | MAXNUM | INSNUM | WHEN | KDUR
			schedkwhen 	ktrigger,   0,        0,       2,      0,   kdur
endin

instr	2	;THIS IS THE SOUND PRODUCING INSTRUMENT - A SIMPLE SINE WAVE 'PING'
	iamp		random	0.03,0.5								;AMPLITUDES WILL BE RANDOM VALUES BETWEEN 1000 (VERY QUIET) AND 10000 (LOUD)
	ipan		random	0, 1									;PAN VALUES WILL BE RANDOM VALUES BETWEEN 0 (LEFT SPEAKER) AND 1 (RIGHT SPEAKER)
	ipchndx	random	0,13									;A RANDOM INDEX VALUE IS DEFINED FOR EACH NEW NOTE.
														;THIS INDEX WILL BE USED TO SELECT VALUES FROM THE 'SCALE' FUNCTION TABLE.
														;THE MAXIMUM POSSIBLE VALUE SHOULD NOT EXCEED THE NUMBER OF VALUES (NOTES) DEFINED IN THE CORRESPONDING FUNCTION TABLE (SCALE).
	ipch		table	ipchndx, 2+i(gkscale)					;THE VARIABLE ipch WILL BE SELECTED FROM THE ipchndx VALUE IN FUNCTION TABLE 2
	aenv		expseg	1, (p3), .001							;PERCUSSIVE-TYPE AMPLITUDE ENVELOPE
	asig		oscil	iamp * aenv, cpspch(ipch), 1				;GENERATE AN AUDIO SIGNAL ACCORDING TO THE WAVEFORM IN FUNCTION TABLE 1 - USE THE SELECTED PCH VALUE AND APPLY THE AMPLITUDE ENVELOPE AND RANDOM AMPLITUDE VALUE
			outs		asig * ipan, asig * (1-ipan)				;SEND AUDIO TO OUTPUTS AND APPLY SIMPLE PANNING
endin
</CsInstruments>
<CsScore>
f 1 0 4096 10 1		;SINE WAVE

;TABLE_NO.|INIT_TIME|SIZE|GEN_NUMBER|VALUES.1..	2	3	4	5	6	7	8	9	10	11	12	13	
f   2          0      64      -2 	7 	7.03 	7.05 	7.07 	7.10 	8	8.03 	8.05 	8.07 	8.10 	9			;PENTATONIC SCALE - 2 OCTAVES
f   3          0      64      -2 	7 	7.02 	7.04 	7.06 	7.08 	7.10	8.00 	8.02 	8.04 	8.06 	8.08	8.10	9.00	;WHOLE TONE SCALE - 2 OCTAVES
;GEN 2 OFFERS US A MEANS TO STORE DISCRETE VALUES, DEFINED VALUE BY VALUE - IN THIS CASE THESE VALUES WILL BE INTERPRETED IN THE ORCHESTRA AS PCH FORMAT VALUES
;IF THE GEN ROUTINE NUMBER IS GIVEN AS A NEGATIVE NUMBER THEN VALUES WON'T BE NORMALIZED (RESCALED WITHIN THE RANGE -1 TO 1)

i 10	 0	 3600		;GUI
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1160</x>
 <y>149</y>
 <width>519</width>
 <height>488</height>
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
  <width>510</width>
  <height>482</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>schedkwhen - Simple Algorithmic Note Generator</label>
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
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>127</y>
  <width>501</width>
  <height>355</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------
This example demonstrates how the opcode 'schedkwhen' can be used to implement a simple algorithmic note generator. 'Algorithmic' refers to the fact that the pitches of notes generated will be indeterminate but not completely random. Pitches will be chosen at random from a set of notes defined in a function table. Schedkwhen allows one instrument to generate multiple notes that will be played by another instrument. Schedkwhen is activated by a trigger signal which could be pulsed, rhythmical or unpulsed/rhymically aleatoric. Schedkwhen also allows the user to define start time, note duration and any number of additional p-fields at k-rate. (The called instrument will receive these values as i-rate p-values. With these capabilties the possiblities for algorithmically generating notes are immense. In this very simple example the user can vary the random value limits for the trigger frequency. Setting these two controls to the same value will create metered note generation. The user can also choose between two different scale types (stored in two separate GEN-02 function tables). Each time a note is generated its duration will be a randomly chosen value between .1 and 2 (seconds). The amplitude of each note will also be random. Each note will occupy a randomly chosen location between the left and right speakers. This example employs very simple and uniform random number generators. Csound offers a wide variety of more powerful random number generators portraying a variety of distributions.</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>44</y>
  <width>80</width>
  <height>26</height>
  <uuid>{04d44ebe-12eb-4bb0-a3f5-9e4fd3e7830e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>109</x>
  <y>45</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7c945fd6-92be-427f-bceb-ab7630e97198}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Scale</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Scale</objectName>
  <x>195</x>
  <y>44</y>
  <width>120</width>
  <height>26</height>
  <uuid>{2940aaee-8fb3-46d5-bb2c-a70e3e47e5cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Pentatonic</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Whole Tone</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>TrigFreqMin</objectName>
  <x>7</x>
  <y>83</y>
  <width>500</width>
  <height>12</height>
  <uuid>{4e625263-998b-44d3-aa3d-30623c5a9616}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.01000000</xMin>
  <xMax>20.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>5.00750000</xValue>
  <yValue>0.25000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>255</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>TrigFreqMax</objectName>
  <x>7</x>
  <y>99</y>
  <width>500</width>
  <height>12</height>
  <uuid>{5f320247-5c85-42cc-b569-5d88268b1c6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.01000000</xMin>
  <xMax>20.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>5.00750000</xValue>
  <yValue>0.25000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>255</b>
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
  <x>177</x>
  <y>110</y>
  <width>160</width>
  <height>26</height>
  <uuid>{c0e508d9-0147-47a9-8441-51028c427718}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Trigger Frequency: min / max</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>TrigFreqMax</objectName>
  <x>447</x>
  <y>110</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f7047b7a-3e79-47a8-8711-b538657cc78f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.008</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>TrigFreqMin</objectName>
  <x>7</x>
  <y>110</y>
  <width>60</width>
  <height>30</height>
  <uuid>{11206a4a-c384-42c7-b034-19e06c2d1d6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.008</label>
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
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

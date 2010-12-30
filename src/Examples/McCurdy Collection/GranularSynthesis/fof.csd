;Written by Iain McCurdy, 2009


; Modified for QuteCsound by René, December 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Instrument 1 is activated by MIDI and by the GUI


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 128	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine		ftgen	0, 0, 4096, 10, 1						;SINE WAVE
giexp		ftgen	0, 0, 1024, 19, 0.5, 0.5, 270, 0.5			;EXPONENTIAL CURVE
giExp1_5000	ftgen	0, 0, 129, -25, 0,  1.0, 128, 5000.0		;TABLE FOR EXP SLIDER
giExp20_5000	ftgen	0, 0, 129, -25, 0,  20.0, 128, 5000.0		;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkamp			invalue	"Amplitude"
		gkoct			invalue	"Octaviation"
		gkband			invalue	"Bandwidth"
		gkdur			invalue	"Duration"
		gkris			invalue	"Rise_Time"
		gkdec			invalue	"Decay_Time"

		kfund			invalue	"X_Fund"
		gkfund			tablei	kfund, giExp1_5000, 1
						outvalue	"X_Fund_Value", gkfund
		kform			invalue	"Y_Form"
		gkform			tablei	kform, giExp20_5000, 1
						outvalue	"Y_Form_Value", gkform
	endif
endin

instr	1
	if p4!=0 then												;MIDI
		ioct		= p4											;READ OCT VALUE FROM MIDI INPUT
		;PITCH BEND======================================================================================================
		iSemitoneBendRange = 12									;PITCH BEND RANGE IN SEMITONES
		imin		= 0											;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333					;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax							;PITCH BEND VARIABLE (IN oct FORMAT)
		kfund	=	cpsoct(ioct + kbend)						;SET FUNDEMENTAL
		;=================================================================================================================
	else														;GUI
		kfund		= gkfund									;SET FUNDEMENTAL
	endif

	iporttime		=		0.2									;CREATE A VARIABLE THAT WILL BE USED FOR PORTAMENTO TIME
	kporttime		linseg	0,0.001,iporttime						;CREATE A VARIABLE THAT WILL BE USED FOR PORTAMENTO TIME
	kfund		portk	kfund, kporttime
	kamp			portk	gkamp, kporttime						;APPLY PORTAMENTO TO SELECTED SLIDER VARIABLE AND CREATE NEW NON-GLOBAL VARIABLES TO BE USED BY THE FOF OPCODE
	kform		portk	gkform, kporttime     					;APPLY PORTAMENTO TO SELECTED SLIDER VARIABLE AND CREATE NEW NON-GLOBAL VARIABLES TO BE USED BY THE FOF OPCODE
	
	iolaps		=		500									;MAXIMUM ALLOWED NUMBER OF GRAIN OVERLAPS (THE BEST IDEA IS TO SIMPLY OVERESTIMATE THIS VALUE)
	ifna			=		gisine								;WAVEFORM USED BY THE GRAINS (NORMALLY A SINE WAVE)
	ifnb			=		giexp								;WAVEFORM USED IN THE DESIGN OF THE EXPONENTIAL ATTACK AND DECAY OF THE GRAINS
	itotdur		=		3600									;TOTAL DURATION OF THE FOF NOTE. IN NON-REALTIME THIS WILL BE p3. IN REALTIME OVERESTIMATE THIS VALUE, IN THIS CASE 1 HOUR - PERFORMANCE CAN STILL BE INTERRUPTED PREMATURELY
	
	;THE FOF OPCODE:
	asig 		fof 		kamp, kfund, kform, gkoct, gkband, gkris, gkdur, gkdec, iolaps, ifna, ifnb, itotdur ;[, iphs] [, ifmode] [, iskip
				outs		asig, asig							;OUTPUT OF fof OPCODE IS SENT TO THE OUTPUTS  
endin

instr	2	;INIT
		outvalue	"_SetPresetIndex", 0
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI

i 2	     0.1		 0		;INIT
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>73</x>
 <y>144</y>
 <width>965</width>
 <height>627</height>
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
  <height>625</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>fof</label>
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
   <r>0</r>
   <g>85</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>515</x>
  <y>2</y>
  <width>450</width>
  <height>625</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>fof</label>
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
   <r>0</r>
   <g>85</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>529</x>
  <y>34</y>
  <width>422</width>
  <height>571</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------
FOF (fonction d'onde formantique) is a rather specialised type of granular synthesis in that its intended use is the creation of vocal vowel sounds through the use of rapidly repeated sine wave grains. (The should not be viewed as a restriction upon it being used less conventionally.) If the user starts this example the first thing that is heard is a stream of repeated pulses in which each pulse is easily discernible. The pitch of each grain is just about discernible. If the 'Formant' slider is moved it is heard that the pitch of each grain is modulated. If the 'Fundemental' slider is slowly moved from left to right it is heard that the frequency of grain repetition increases. As we pass about 35 hertz we are no longer able distinguish individual grains and instead a new tone emerges which is a consequence of the periodically repeating identical grains. Keep 'Fundemental' at a highish value (say 200 Hz.) and now move the 'Formant' slider. The effect this time is of a bandpass filter being applied to the tone. A formant is really just a peak of energy on a harmonic sound spectrum. The phenomena just demonstrated are the fundemental principles behind fof synthesis. To convincingly imitate vowel sounds of the human voice about six simulataneous fof signals are needed. The next example demonstrates this. The amplitude envelope that is applied to each grain is controlled by a combination of the 'Duration' (kdur), 'Rise Time' (kris), 'Decay Time' (kdec) and 'Bandwidth' (kband). Bandwidth controls how an exponential curve defined in a separate function is applied to the decay of each grain. 'Octaviation Index' (koct) is typically zero but as it tends to 1 every other grain is increasingly attenuated. When it is exactly 1 the grain density is effectively halved and the fof fundemental is dropped by one octave. From 1 to 2 the process is repeated and the density is halved again and so on from 2 to 3 and beyond. This effect is perceived quite differently for dense and sparse textures. This example can also be played from a MIDI keyboard.</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>64</y>
  <width>60</width>
  <height>30</height>
  <uuid>{85d968f7-91e1-4b16-8a3d-0d4309dbf3ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.064</label>
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
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>41</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2f9f9de8-c3ea-4d8e-8359-7f41e2a836f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.06400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>64</y>
  <width>180</width>
  <height>30</height>
  <uuid>{bb6b2a39-ac56-4b6f-a0b5-e590b03ca177}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>X_Fund</objectName>
  <x>8</x>
  <y>91</y>
  <width>500</width>
  <height>284</height>
  <uuid>{2fef8117-9c62-4419-b6e0-45ef9c15647f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Y_Form</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55600000</xValue>
  <yValue>0.50000000</yValue>
  <type>crosshair</type>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>8</y>
  <width>120</width>
  <height>30</height>
  <uuid>{55273d97-d39a-441c-8da6-87ea139493b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Bandwidth</objectName>
  <x>448</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2d99c0d7-0052-4c4e-8a31-baf686e42f08}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>86.800</label>
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
  <objectName>Bandwidth</objectName>
  <x>8</x>
  <y>446</y>
  <width>500</width>
  <height>27</height>
  <uuid>{7aafd1a1-9ee8-40a1-9153-9b52fc9e59c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>86.80000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>469</y>
  <width>180</width>
  <height>30</height>
  <uuid>{21aa36d3-8a62-4517-8d0d-6bb48ae6f907}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandwidth</label>
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
  <objectName>Octaviation</objectName>
  <x>448</x>
  <y>426</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3be43919-ad18-4aef-b554-03c4b4d991c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.896</label>
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
  <objectName>Octaviation</objectName>
  <x>8</x>
  <y>403</y>
  <width>500</width>
  <height>27</height>
  <uuid>{eac88081-deaa-45c0-b896-32a3ffedc74a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>8.00000000</maximum>
  <value>0.89600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>426</y>
  <width>180</width>
  <height>30</height>
  <uuid>{541ace1b-b1de-4c04-8d84-1de90288dded}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Octaviation Factor</label>
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
  <x>8</x>
  <y>511</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7bb9de46-0e02-4a7c-b5ba-63ae733b846c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Duration</label>
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
  <objectName>Duration</objectName>
  <x>8</x>
  <y>488</y>
  <width>500</width>
  <height>27</height>
  <uuid>{21afbb73-0783-452a-aefd-4d2b00424579}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01700000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.06811600</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Duration</objectName>
  <x>448</x>
  <y>511</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3bf57752-ee27-478a-b10b-f9fcab18a19d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.068</label>
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
  <y>554</y>
  <width>180</width>
  <height>30</height>
  <uuid>{49e05f60-2891-4f57-8965-f1132a646100}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rise Time</label>
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
  <objectName>Rise_Time</objectName>
  <x>8</x>
  <y>531</y>
  <width>500</width>
  <height>27</height>
  <uuid>{26d0b0da-2328-467a-8494-6e7cf1ce5244}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.05000000</maximum>
  <value>0.01756200</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Rise_Time</objectName>
  <x>448</x>
  <y>554</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8a11b4be-340f-42a2-af1c-b35e36ed5408}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.018</label>
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
  <y>596</y>
  <width>180</width>
  <height>30</height>
  <uuid>{8f4461f8-dae3-4738-9bab-d994bf5310b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay Time</label>
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
  <objectName>Decay_Time</objectName>
  <x>8</x>
  <y>573</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0c2876b9-e986-4d77-9979-2b91676b8372}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.05000000</maximum>
  <value>0.00737000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Decay_Time</objectName>
  <x>448</x>
  <y>596</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ad11a387-9c87-4924-bb44-2a5e28034b0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.007</label>
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
  <y>373</y>
  <width>120</width>
  <height>30</height>
  <uuid>{30475d51-935d-4644-ba93-d6629f3be4d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>X - Fundamental</label>
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
  <objectName>X_Fund_Value</objectName>
  <x>127</x>
  <y>373</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6aac1f5d-f8dd-4e66-a987-3203fd01550f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>113.963</label>
  <alignment>left</alignment>
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
  <objectName>Y_Form_Value</objectName>
  <x>448</x>
  <y>374</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ee3fa20e-dea1-4af9-97d7-f7ba52bdd47c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>316.227</label>
  <alignment>left</alignment>
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
  <x>330</x>
  <y>374</y>
  <width>120</width>
  <height>30</height>
  <uuid>{653f7154-d6f2-44e6-8ea9-eacbd5ac2206}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Y - Formant</label>
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
</bsbPanel>
<bsbPresets>
<preset name="INIT" number="0" >
<value id="{85d968f7-91e1-4b16-8a3d-0d4309dbf3ea}" mode="1" >0.20200001</value>
<value id="{85d968f7-91e1-4b16-8a3d-0d4309dbf3ea}" mode="4" >0.202</value>
<value id="{2f9f9de8-c3ea-4d8e-8359-7f41e2a836f1}" mode="1" >0.20200001</value>
<value id="{2fef8117-9c62-4419-b6e0-45ef9c15647f}" mode="1" >0.31200001</value>
<value id="{2fef8117-9c62-4419-b6e0-45ef9c15647f}" mode="2" >0.47535211</value>
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="1" >0.00000000</value>
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="4" >0</value>
<value id="{2d99c0d7-0052-4c4e-8a31-baf686e42f08}" mode="1" >5.40000010</value>
<value id="{2d99c0d7-0052-4c4e-8a31-baf686e42f08}" mode="4" >5.400</value>
<value id="{7aafd1a1-9ee8-40a1-9153-9b52fc9e59c4}" mode="1" >5.40000010</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >0.51200002</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >0.512</value>
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.51200002</value>
<value id="{21afbb73-0783-452a-aefd-4d2b00424579}" mode="1" >0.13102800</value>
<value id="{3bf57752-ee27-478a-b10b-f9fcab18a19d}" mode="1" >0.13102800</value>
<value id="{3bf57752-ee27-478a-b10b-f9fcab18a19d}" mode="4" >0.131</value>
<value id="{26d0b0da-2328-467a-8494-6e7cf1ce5244}" mode="1" >0.03020400</value>
<value id="{8a11b4be-340f-42a2-af1c-b35e36ed5408}" mode="1" >0.03000000</value>
<value id="{8a11b4be-340f-42a2-af1c-b35e36ed5408}" mode="4" >0.030</value>
<value id="{0c2876b9-e986-4d77-9979-2b91676b8372}" mode="1" >0.00737000</value>
<value id="{ad11a387-9c87-4924-bb44-2a5e28034b0d}" mode="1" >0.00700000</value>
<value id="{ad11a387-9c87-4924-bb44-2a5e28034b0d}" mode="4" >0.007</value>
<value id="{6aac1f5d-f8dd-4e66-a987-3203fd01550f}" mode="1" >14.26051235</value>
<value id="{6aac1f5d-f8dd-4e66-a987-3203fd01550f}" mode="4" >14.261</value>
<value id="{ee3fa20e-dea1-4af9-97d7-f7ba52bdd47c}" mode="1" >276.02487183</value>
<value id="{ee3fa20e-dea1-4af9-97d7-f7ba52bdd47c}" mode="4" >276.025</value>
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
ioText {2, 2} {514, 625} label 0.000000 0.00100 "" center "DejaVu Sans" 18 {65280, 65280, 65280} {0, 21760, 0} nobackground noborder fof
ioText {515, 2} {450, 625} label 0.000000 0.00100 "" center "DejaVu Sans" 18 {65280, 65280, 65280} {0, 21760, 0} nobackground noborder fof
ioText {529, 34} {422, 571} label 0.000000 0.00100 "" left "Liberation Sans" 14 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder -------------------------------------------------------------------------------------------------------Â¬FOF (fonction d'onde formantique) is a rather specialised type of granular synthesis in that its intended use is the creation of vocal vowel sounds through the use of rapidly repeated sine wave grains. (The should not be viewed as a restriction upon it being used less conventionally.) If the user starts this example the first thing that is heard is a stream of repeated pulses in which each pulse is easily discernible. The pitch of each grain is just about discernible. If the 'Formant' slider is moved it is heard that the pitch of each grain is modulated. If the 'Fundemental' slider is slowly moved from left to right it is heard that the frequency of grain repetition increases. As we pass about 35 hertz we are no longer able distinguish individual grains and instead a new tone emerges which is a consequence of the periodically repeating identical grains. Keep 'Fundemental' at a highish value (say 200 Hz.) and now move the 'Formant' slider. The effect this time is of a bandpass filter being applied to the tone. A formant is really just a peak of energy on a harmonic sound spectrum. The phenomena just demonstrated are the fundemental principles behind fof synthesis. To convincingly imitate vowel sounds of the human voice about six simulataneous fof signals are needed. The next example demonstrates this. The amplitude envelope that is applied to each grain is controlled by a combination of the 'Duration' (kdur), 'Rise Time' (kris), 'Decay Time' (kdec) and 'Bandwidth' (kband). Bandwidth controls how an exponential curve defined in a separate function is applied to the decay of each grain. 'Octaviation Index' (koct) is typically zero but as it tends to 1 every other grain is increasingly attenuated. When it is exactly 1 the grain density is effectively halved and the fof fundemental is dropped by one octave. From 1 to 2 the process is repeated and the density is halved again and so on from 2 to 3 and beyond. This effect is perceived quite differently for dense and sparse textures. This example can also be played from a MIDI keyboard.
ioText {448, 64} {60, 30} display 0.064000 0.00100 "Amplitude" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 0.064
ioSlider {8, 41} {500, 27} 0.000000 1.000000 0.064000 Amplitude
ioText {8, 64} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Amplitude
ioMeter {8, 91} {500, 284} {0, 59904, 0} "X_Fund" 0.556000 "Y_Form" 0.500000 crosshair 1 0 mouse
ioButton {8, 8} {120, 30} event 1.000000 "" "  On / Off (MIDI)" "/" i1 0 -1
ioText {448, 469} {60, 30} display 86.800000 0.00100 "Bandwidth" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 86.800
ioSlider {8, 446} {500, 27} 0.000000 100.000000 86.800000 Bandwidth
ioText {8, 469} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Bandwidth
ioText {448, 426} {60, 30} display 0.896000 0.00100 "Octaviation" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 0.896
ioSlider {8, 403} {500, 27} 0.000000 8.000000 0.896000 Octaviation
ioText {8, 426} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Octaviation Factor
ioText {8, 511} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Duration
ioSlider {8, 488} {500, 27} 0.017000 1.000000 0.068116 Duration
ioText {448, 511} {60, 30} display 0.068116 0.00100 "Duration" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 0.068
ioText {8, 554} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Rise Time
ioSlider {8, 531} {500, 27} 0.001000 0.050000 0.017562 Rise_Time
ioText {448, 554} {60, 30} display 0.017562 0.00100 "Rise_Time" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 0.018
ioText {8, 596} {180, 30} label 0.000000 0.00100 "" left "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Decay Time
ioSlider {8, 573} {500, 27} 0.001000 0.050000 0.007370 Decay_Time
ioText {448, 596} {60, 30} display 0.007000 0.00100 "Decay_Time" right "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 0.007
ioText {8, 373} {120, 30} label 0.000000 0.00100 "" center "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder X - Fundamental
ioText {127, 373} {60, 30} display 113.963364 0.00100 "X_Fund_Value" left "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 113.963
ioText {448, 374} {60, 30} display 316.226807 0.00100 "Y_Form_Value" left "Liberation Sans" 9 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder 316.227
ioText {330, 374} {120, 30} label 0.000000 0.00100 "" center "Liberation Sans" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Y - Formant
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

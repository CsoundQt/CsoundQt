;Written by Iain McCurdy, 2006


;Modified for QuteCsound by René, April 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Removed subinstr call to instrument 2 from instrument 1
;	Use QuteCsound internal midi interface for Harmonics (Channel 1, CC#1)


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 32			;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


gisine	ftgen	0, 0, 4096, 10, 1					;FUNCTION TABLE THAT STORES A SINGLE CYCLE OF A SINE WAVE
giExp1	ftgen	0, 0, 129, -25, 0, 1.0, 128, 5000.0	;TABLE FOR EXP SLIDER


instr	10	;GUI
	gkamp		invalue	"Amplitude"
	kfreq		invalue	"Frequency"
	gkfreq		tablei	kfreq, giExp1, 1
				outvalue	"Frequency_Value", gkfreq	
	gkharm		invalue	"Harmonics"
endin

instr	1	;MIDI INPUT INSTRUMENT
	icps		cpsmidi										;READ CYCLES PER SECOND VALUE FROM MIDI INPUT
	iamp		ampmidi	1									;READ IN A NOTE VELOCITY VALUE FROM THE MIDI INPUT
	kamp		=		iamp * gkamp

	;PITCH BEND===========================================================================================================================================================
	iSemitoneBendRange=	2									;PITCH BEND RANGE IN SEMITONES
	imin		=		0									;EQUILIBRIUM POSITION
	imax		=		iSemitoneBendRange * .0833333				;MAX PITCH DISPLACEMENT (IN oct FORMAT)
	kbend	pchbend	imin, imax							;PITCH BEND VARIABLE (IN oct FORMAT)
	koct		=		octcps(icps)
	kfreq	=		cpsoct(koct + kbend)
	;=====================================================================================================================================================================

	;OUTPUT	OPCODE	AMPLITUDE | FREQUENCY | NO.OF HARMONICS | FUNCTION_TABLE
	asig		buzz		kamp,        kfreq,    int(gkharm),           gisine
	aenv		linsegr	0,0.01,1,0.01,0								;ANTI-CLICK ENVELOPE
			outs		asig*aenv, asig*aenv							;SEND AUDIO OUTPUT TO THE SPEAKERS
endin

instr	2	;BUZZ INSTRUMENT
	;OUTPUT	OPCODE	AMPLITUDE | FREQUENCY | NO.OF HARMONICS | FUNCTION_TABLE
	asig		buzz		gkamp,        gkfreq,    int(gkharm),		gisine
	aenv		linsegr	0,0.01,1,0.01,0								;ANTI-CLICK ENVELOPE
			outs		asig*aenv, asig*aenv							;SEND AUDIO OUTPUT TO THE SPEAKERS
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0.0	   3600	;GUI
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>425</x>
 <y>433</y>
 <width>941</width>
 <height>258</height>
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
  <height>250</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>buzz</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>10</y>
  <width>124</width>
  <height>30</height>
  <uuid>{487d5181-d838-4cce-9628-317fefc350cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> ON / OFF (MIDI)</text>
  <image>/</image>
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>138</y>
  <width>150</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
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
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>138</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.492</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <x>516</x>
  <y>2</y>
  <width>420</width>
  <height>250</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>buzz</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>520</x>
  <y>17</y>
  <width>412</width>
  <height>231</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------
Buzz creates a composite tone of harmonically related sine wave partials. The user is given control of the number of partials required (from the fundemental upwards) and of the the amplitude and the fundemental frequency of the tone. Buzz requires the user to first supply it with a sine waveform via a function table (probably GEN 10). This table should not be too small, sizes of 8192 and upwards are recommended. Buzz provides a useful source for subtractive synthesis. This example can also be played from an external MIDI keyboard. Pitch, note velocity and pitch bend and represented appropriately. MIDI controller 1 (the modulation wheel) can be used to modulate 'Number of Harmonics'.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>122</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2a8dc6e2-12f4-443d-af9b-59e4373cc24b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.49200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>176</y>
  <width>150</width>
  <height>30</height>
  <uuid>{4fa545c6-e2f1-4387-8c9f-4a9dd388bb42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Oscillator Frequency</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Frequency_Value</objectName>
  <x>448</x>
  <y>176</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b0ad1916-b43e-44c2-be40-bca29f5cb1f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>126.245</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Frequency</objectName>
  <x>8</x>
  <y>160</y>
  <width>500</width>
  <height>27</height>
  <uuid>{9069e547-5638-4568-896f-980087c61de0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.56800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>40</x>
  <y>68</y>
  <width>169</width>
  <height>31</height>
  <uuid>{ada34c8d-83fe-4eae-b207-ac7e38c5251f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>No. of Harmonics CC#1 :</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <x>210</x>
  <y>68</y>
  <width>50</width>
  <height>30</height>
  <uuid>{c37974b7-7a24-481d-8f02-a116324085e3}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <alignment>right</alignment>
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
  <minimum>1</minimum>
  <maximum>80</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

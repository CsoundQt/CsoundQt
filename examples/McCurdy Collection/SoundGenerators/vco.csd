;Written by Iain McCurdy, 2006


;Modified for QuteCsound by René, April 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table for exp slider
;	Add INIT instrument
;	Use of QuteCsound internal midi for Pulse Width widget control by CC#1


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 16			;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


gisine		ftgen	0,0,131072,10,1						;TABLE THAT STORES A SINGLE CYCLE OF A SINE WAVE
giExp1		ftgen	0, 0, 129, -25, 0, 2.0, 128, 10000.0		;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;SLIDERS
		gkamp, 		invalue	"Amplitude"
		kcps, 		invalue	"Frequency"
		gkcps		tablei	kcps, giExp1, 1
					outvalue	"Frequency_Value", gkcps
		gkleak, 		invalue	"Leak"
		gknyx, 		invalue	"Harmonics"
		gkpw, 		invalue	"PW"
		gkphs, 		invalue	"InitPhase"
		;MENU
		gkwave		invalue	"Waveform"
	endif
endin

instr	11	;INIT
		outvalue	"Waveform"	, 2
		outvalue	"Amplitude"	, 0.1
		outvalue	"Frequency"	, 0.46
		outvalue	"Leak"		, 0.0
		outvalue	"Harmonics"	, 0.5
		outvalue	"PW"			, 0.5
		outvalue	"InitPhase"	, 0.0
endin

instr	1	;MIDI INPUT INSTRUMENT
	icps		cpsmidi									;READ CYCLES PER SECOND VALUE FROM MIDI INPUT
	iamp		ampmidi	1								;READ IN A NOTE VELOCITY VALUE FROM THE MIDI INPUT

	;PITCH BEND===========================================================================================================================================================
	iSemitoneBendRange=	2								;PITCH BEND RANGE IN SEMITONES
	imin		=		0								;EQUILIBRIUM POSITION
	imax		=		iSemitoneBendRange / 12				;MAX PITCH DISPLACEMENT (IN oct FORMAT)
	kbend	pchbend	imin, imax						;PITCH BEND VARIABLE (IN oct FORMAT)
	koct		=		octcps(icps)
	kcps		=		cpsoct(koct + kbend)
	;=====================================================================================================================================================================

	iporttime	=		0.05								;PORTAMENTO TIME VARIABLE
	kporttime	linseg	0,0.001,iporttime,1,iporttime			;CREATE A RAMPING UP FUNCTION TO REPRESENT PORTAMENTO TIME
	kpw		portk	gkpw, kporttime					;APPLY PORTAMENTO SMOOTHING
	imaxd	=		1
	kSwitch	changed	gkleak, gknyx, gkwave, gkphs
	if	kSwitch=1	then									;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	UPDATE								;BEGIN A REINITIALISATION PASS FROM LABEL 'UPDATE'
	endif
	UPDATE:
	aenv		linsegr	0,0.01,1,0.01,0					;ANTI-CLICK ENVELOPE
	asig		vco 		aenv*iamp*gkamp, kcps, i(gkwave)+1, kpw, gisine, imaxd, i(gkleak), i(gknyx), i(gkphs)
			rireturn									;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
			outs		asig, asig
endin

instr	2	;VCO INSTRUMENT
	iporttime	=		0.05								;PORTAMENTO TIME VARIABLE
	kporttime	linseg	0,0.001,iporttime,1,iporttime			;CREATE A RAMPING UP FUNCTION TO REPRESENT PORTAMENTO TIME
	kpw		portk	gkpw, kporttime					;APPLY PORTAMENTO SMOOTHING
	imaxd	=		1
	kSwitch	changed	gkleak, gknyx, gkwave, gkphs
	if	kSwitch=1	then									;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	UPDATE								;BEGIN A REINITIALISATION PASS FROM LABEL 'UPDATE'
	endif
	UPDATE:
	aenv		linsegr	0,0.01,1,0.01,0					;ANTI-CLICK ENVELOPE
	asig		vco 		aenv*gkamp, gkcps, i(gkwave)+1, kpw, gisine, imaxd, i(gkleak), i(gknyx), i(gkphs)
			rireturn									;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
			outs		asig, asig
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0.0	   3600	;GUI
i 11		0.0     0.01	;INIT
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>537</x>
 <y>324</y>
 <width>1142</width>
 <height>455</height>
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
  <height>450</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>vco</label>
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
  <x>8</x>
  <y>232</y>
  <width>220</width>
  <height>30</height>
  <uuid>{d1ad1809-ed86-4ecd-b6c9-15b4c9686e35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Integrator Leak</label>
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
  <objectName>Leak</objectName>
  <x>448</x>
  <y>232</y>
  <width>60</width>
  <height>30</height>
  <uuid>{39d4f770-c1eb-4c2d-9b6d-41b78e8955f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
  <objectName>Leak</objectName>
  <x>8</x>
  <y>216</y>
  <width>500</width>
  <height>27</height>
  <uuid>{37911dd5-758c-4ec8-9871-ce3f5cd67670}</uuid>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Waveform</objectName>
  <x>280</x>
  <y>68</y>
  <width>160</width>
  <height>26</height>
  <uuid>{fd321c7c-a7e3-49dd-9c35-b4d1a0054c73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Saw</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Square/PWM</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Saw/Triangle/Ramp</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>10</x>
  <y>16</y>
  <width>120</width>
  <height>26</height>
  <uuid>{c4c1aae5-edb9-47d9-94a7-8d15578e0bf2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off - MIDI</text>
  <image>/</image>
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>200</x>
  <y>68</y>
  <width>80</width>
  <height>26</height>
  <uuid>{e192d1b0-4e18-4b7a-97cb-800767992d7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Waveform :</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>2</y>
  <width>620</width>
  <height>450</height>
  <uuid>{9798823d-b60e-424f-a3c4-1a43d5e0312d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Miscellaneous Waveforms
vco</label>
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
  <y>47</y>
  <width>613</width>
  <height>400</height>
  <uuid>{66493881-548a-48d2-bdb6-08aad6d0fe91}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------------------------------------------------------------------
Vco is a digital emulation of a voltage controlled oscillator that one might find on an analogue synthesizer. The precise method used is the integration of band limited impulses. Vco implements a digital model of the analogue electronics that were used to achieve this. It has three basic waveform settings: 'Saw', 'Square/PWM' and 'Saw/Triangle/Ramp'. As you can see, two of these settings are capable of producing more than one wave type. This is achieved by warping the waveform using the 'Pulse Width' (PW) control.
For example when the 'Square/PWM' waveform is selected a square wave is achieved by setting 'Pulse Width' to 0.5. When 'Saw/Triangle/Ramp' is selected a triangle wave is achieved by setting 'Pulse Width' again to 0.5. Giving 'Pulse Width' a value of zero or 1 achieves silence. PWM or 'Pulse Width Modulation' was a an effect popular on analogue synthesizers whereby the pulse width of a waveform was modulated by an LFO (Low Frequency Oscillator). In this example this can only be achieved by manually moving the 'Pulse Width' slider back and forth. In the next example featuring vco an LFO has been implemented to drive the 'Pulse Width' parameter. Note that 'Pulse Width' has no effect when 'Saw' waveform is selected.
The 'Integrator Leak' control implements a quirk of the original analogue oscillator upon which this is based which has an effect on the sound produced. For a more in depth discussion I point you in the direction of the the Csound Reference Manual in which the opcode's author, Hans Mikelson, gives more technical information about the effect of integrator leakage.
'Number of Harmonics' can be used to limit the number of harmonics that will be present in the waveform. Normally this argument should be in the range close to zero up to 0.5. I have done some additional mathematics in the code so that the values you see in the interface represent this harmonic limit in hertz. the author suggests that a waveform can be 'fattened up' by reducing this parameter.
Vco provides a useful source for subtractive synthesis and could be used as the starting point for a Csound model of an analogue synthesizer. This example can also be played from an external MIDI keyboard. Pitch, note velocity and pitch bend and represented appropriately. MIDI controller 1 (the modulation wheel) can be used to modulate 'Pulse Width'.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>155</y>
  <width>160</width>
  <height>30</height>
  <uuid>{6089425b-bdef-4a75-9cf7-e1f298ad9d5b}</uuid>
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
  <y>155</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1d38ea29-bbe3-45e2-b37c-02af9787d0e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
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
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>139</y>
  <width>500</width>
  <height>27</height>
  <uuid>{dd3dce47-c107-46e8-90ae-f06422cb97cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>193</y>
  <width>160</width>
  <height>30</height>
  <uuid>{07bf36b2-367f-4332-8200-0b6d7017afe1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency (Hertz)</label>
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
  <y>193</y>
  <width>60</width>
  <height>30</height>
  <uuid>{600f5f27-7f32-4cbc-9402-6bbb7415c568}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>100.614</label>
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
  <y>177</y>
  <width>500</width>
  <height>27</height>
  <uuid>{859b8f24-fbc4-4127-9432-95e0e467cbab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.46000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>309</y>
  <width>160</width>
  <height>30</height>
  <uuid>{aa9f17fc-ae7b-47ca-9049-8c93a118b120}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pulse Width (CC#1)</label>
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
  <objectName>PW</objectName>
  <x>448</x>
  <y>309</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ce6e47b4-3b22-4b50-921f-d76f18e3cdf0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
  <objectName>PW</objectName>
  <x>8</x>
  <y>293</y>
  <width>500</width>
  <height>27</height>
  <uuid>{6ce81dfe-7526-4b6b-b9c9-afaacea0f5be}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>347</y>
  <width>160</width>
  <height>30</height>
  <uuid>{22115502-b439-488b-be3e-fdac45e5fb20}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Initial Phase</label>
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
  <objectName>InitPhase</objectName>
  <x>448</x>
  <y>347</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f61d9fa9-52cc-4f37-9a73-f58bbc4a4bb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
  <objectName>InitPhase</objectName>
  <x>8</x>
  <y>331</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5cdfa99c-960f-481b-8653-ad88365a8532}</uuid>
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
  <x>8</x>
  <y>271</y>
  <width>220</width>
  <height>30</height>
  <uuid>{8994a5d6-0616-4073-88ca-89bd8910cd2b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number of Harmonics</label>
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
  <objectName>Harmonics</objectName>
  <x>448</x>
  <y>271</y>
  <width>60</width>
  <height>30</height>
  <uuid>{df89196d-9aea-489f-9a6b-97a25e3df9e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
  <objectName>Harmonics</objectName>
  <x>8</x>
  <y>255</y>
  <width>500</width>
  <height>27</height>
  <uuid>{dc9e8a06-d156-4247-9272-bdc7fa976c8c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

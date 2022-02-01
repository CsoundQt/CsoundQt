;Written by Iain McCurdy, 2007

;Modified for QuteCsound by René, September 2010, updated Feb 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio files and use of FilePlay2 udo, now accept mono or stereo wav files
;	Instrument 1 is activated by MIDI and by the GUI


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


giFFTattributes0	ftgen	1, 0, 4, -2,  512, 256, 1024, 1
giFFTattributes1	ftgen	2, 0, 4, -2, 1024, 256, 1024, 1
giFFTattributes2	ftgen	3, 0, 4, -2, 2048, 128, 2048, 1
giFFTattributes3	ftgen	4, 0, 4, -2, 4096, 128, 4096, 1

giExp8			ftgen	0, 0, 129, -25, 0, 0.125, 128, 8.0		;TABLE FOR EXP SLIDER


opcode FilePlay2, aa, Skoo		; Credit to Joachim Heintz
	;gives stereo output regardless your soundfile is mono or stereo
	Sfil, kspeed, iskip, iloop	xin
	ichn		filenchnls	Sfil
	if ichn == 1 then
		aL		diskin2	Sfil, kspeed, iskip, iloop
		aR		=		aL
	else
		aL, aR	diskin2	Sfil, kspeed, iskip, iloop
	endif
		xout		aL, aR
endop


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		kscal			invalue 	"Frequency_Rescale"
		gkscal			tablei	kscal, giExp8, 1
						outvalue	"Frequency_Rescale_Value", gkscal
		gkgain			invalue 	"Gain_Rescale"
		gkkeepform		invalue	"Keepform"
		gkinput			invalue	"Input"
		gkFFTattributes	invalue	"FFTattributes"
	endif
endin

instr	1	;SOUND PRODUCING AND TRANSFORMING INSTRUMENT
	if p4!=0 then														;MIDI
		kscal	= cpsoct(p4)/cpsoct(8)									;CREATE FREQUENCY SCALING VARIABLE
	else																;GUI
		kscal	= gkscal												;SET FUNDEMENTAL TO GUI SLIDER gkfund
	endif

	if	gkinput = 0	then												;IF 'INPUT' SWITCH IS SET TO 'Live Input' THEN IMPLEMENT THE NEXT LINE OF CODE
		asig		inch		1											;READ AUDIO FROM THE COMPUTER'S LIVE INPUT CHANNEL 1 (LEFT)
	elseif	gkinput = 1 	then											;IF 'INPUT' SWITCH IS SET TO 'Voice' THEN IMPLEMENT THE NEXT LINE OF CODE
		Sfile1	invalue	"_Browse1"
		;OUTPUT		OPCODE	FILE_PATH	| SPEED | INSKIP | WRAPAROUND (1=ON)
		asig, asigR	FilePlay2	Sfile1,		1,      0,        1				;READ A STORED AUDIO FILE FROM THE HARD DRIVE
	else																;IF 'INPUT' SWITCH IS NOT SET TO 'STORED FILE' THEN IMPLEMENT THE NEXT LINE OF CODE
		Sfile2	invalue	"_Browse2"
		;OUTPUT		OPCODE	FILE_PATH	| SPEED | INSKIP | WRAPAROUND (1=ON)
		asig, asigR	FilePlay2	Sfile2,		1,      0,        1				;READ A STORED AUDIO FILE FROM THE HARD DRIVE
	endif															;END OF 'IF'...'THEN' BRANCHING

	kSwitch		changed	gkgain, gkkeepform, gkFFTattributes				;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch = 1	then												;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	START												;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
	endif
	START:
	iFFTsize		table	0, i(gkFFTattributes)+1
	ioverlap		table	1, i(gkFFTattributes)+1
	iwinsize		table	2, i(gkFFTattributes)+1
	iwintype		table	3, i(gkFFTattributes)+1	

	fsig1  		pvsanal	asig, iFFTsize, ioverlap, iwinsize, iwintype			;ANALYSE THE AUDIO SIGNAL THAT WAS CREATED IN INSTRUMENT 1. OUTPUT AN F-SIGNAL.
	;OUTPUT		OPCODE	INPUT | RESCALE_VALUE | FORMANT_MODE |   GAIN
	fsig2 		pvscale 	fsig1,      kscal,     i(gkkeepform), i(gkgain)		;RESCALE THE FREQUENCY VALUES ACCORDING TO THE INPUT ARGUMENT gkscal.
	;OUTPUT		OPCODE	INPUT
	aresyn 		pvsynth  	fsig2   					                   		;RESYNTHESIZE THE f-SIGNAL AS AN AUDIO SIGNAL
	aenv			linsegr	0,0.01,1,0.02,0								;ANTI CLICK ENVELOPE WITH AMIDI SENSING RELEASE SEGMENT
				rireturn												;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
				outs		aresyn*aenv, aresyn*aenv							;SEND THE RESCALED, RESYNTHESIZED SIGNAL TO THE AUDIO OUTPUTS AND RESCALE AMPLITUDE WITH ENVELOPE aenv
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0	   3600	;GUI
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1</x>
 <y>28</y>
 <width>914</width>
 <height>427</height>
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
  <width>515</width>
  <height>425</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvscale</label>
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
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>519</x>
  <y>2</y>
  <width>395</width>
  <height>425</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvscale</label>
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
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>18</y>
  <width>390</width>
  <height>387</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------
The opcode pvscale performs rescaling of the frequency values of an f-signal. If the 'Frequency Rescale' slider is given a value of 2, frequency values will be transposed up by one octave, if it is given a value of .5, frequency values will be transposed down 1 octave and so on. Pvscale also offers three transposition modes of dealing with formants of the original spectrum. This is an optional argument and it defaults to 0. In mode 0 no attempt is made to retain formants.
In mode 1 formants are retained by imposing the original amplitude values. In mode 2 formants are retained through filtering the output according to the spectral envelope of the original signal. A variety of combination of FFT analysis attributes are selectable using radio button selectors. It can be observed that smaller FFT size and window sizes results in less time smearing but greater harmonic distortion whereas larger FFT sizes and window sizes results in greater time smearing but less harmonic distortion. This example can also be activated from a MIDI keyboard (if the 'GUI / MIDI' switch is set to off (MIDI). In this mode frequency rescaling values are derived from notes played on the keyboard. Each MIDI note pressed begins another frequency rescaling voice thus permitting polyphony.</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>8</y>
  <width>140</width>
  <height>35</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>   ON  : GUI
   OFF : MIDI</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Keepform</objectName>
  <x>277</x>
  <y>161</y>
  <width>230</width>
  <height>30</height>
  <uuid>{65bb9cc6-078d-45fd-99aa-dd17a8d2d144}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Do not preserve formants</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Impose original amplitudes</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Keep original spectral envelope</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>3</x>
  <y>159</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b3560c14-84be-4876-9100-5807ffe16e97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input</label>
  <alignment>right</alignment>
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
  <objectName>Frequency_Rescale_Value</objectName>
  <x>450</x>
  <y>71</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5ba6647c-7395-493b-94fb-2e39de38cae6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.699</label>
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
  <objectName>Frequency_Rescale</objectName>
  <x>10</x>
  <y>54</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2440dba1-0ca3-473e-9e1c-590341c95eaf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.41400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>71</y>
  <width>150</width>
  <height>30</height>
  <uuid>{40ab6aec-b542-473a-97c1-8e1d3da00a5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency Rescale</label>
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
  <objectName>Gain_Rescale</objectName>
  <x>450</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7760eb6e-e14b-485f-a2f6-46a3fb79fa71}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain_Rescale</objectName>
  <x>10</x>
  <y>95</y>
  <width>500</width>
  <height>27</height>
  <uuid>{daf328f8-0158-459b-9ed0-2f3c65031ad0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>112</y>
  <width>150</width>
  <height>30</height>
  <uuid>{ca0b021c-8ec2-4628-ad65-be1b22eea34d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain Rescale</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>64</x>
  <y>159</y>
  <width>110</width>
  <height>30</height>
  <uuid>{cdb2d3b2-5a09-4e13-865e-8501e33b9d35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Live Input</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Voice</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Drum Loop</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>216</x>
  <y>161</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e901fc37-d03f-4905-ba4a-fa840edf51a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mode</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>350</y>
  <width>501</width>
  <height>71</height>
  <uuid>{f0c4875d-4e35-4d37-b043-9c1476025645}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FFT Attributes</label>
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
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>168</x>
  <y>356</y>
  <width>315</width>
  <height>29</height>
  <uuid>{c2cdd204-e32b-488e-b5c2-70688fb2defa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FFT Size - Overlap - Window Size - Window Type</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>FFTattributes</objectName>
  <x>168</x>
  <y>376</y>
  <width>274</width>
  <height>32</height>
  <uuid>{c8c311f9-c1b7-4bbb-becf-9c9f1fa862c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>512       256       1024            1</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>1024       256       1024            1</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2048       128       2048            1</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4096       128       4096            1</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>10</x>
  <y>240</y>
  <width>170</width>
  <height>30</height>
  <uuid>{61d95a96-a89c-43fa-90aa-3c8770efa839}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>AndItsAll.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>181</x>
  <y>241</y>
  <width>330</width>
  <height>28</height>
  <uuid>{a848b1a2-c8a9-4d9f-8184-340a620f0825}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>AndItsAll.wav</label>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>222</y>
  <width>100</width>
  <height>30</height>
  <uuid>{4676d5c2-09a3-41b9-b76f-f9fb702c6465}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Voice</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>274</y>
  <width>100</width>
  <height>30</height>
  <uuid>{e2a25f0b-50f8-40a7-b867-f76f6e352019}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Drum Loop</label>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse2</objectName>
  <x>181</x>
  <y>293</y>
  <width>330</width>
  <height>28</height>
  <uuid>{61ae6913-de24-49d7-a7d4-ee336ab3a090}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>loop.wav</label>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse2</objectName>
  <x>10</x>
  <y>292</y>
  <width>170</width>
  <height>30</height>
  <uuid>{2441252d-f464-4862-aa1c-9351311f35b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/moi/Samples/loop.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>181</x>
  <y>321</y>
  <width>330</width>
  <height>30</height>
  <uuid>{a63909ac-6fa4-41c8-a84b-ba08e76132ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Restart the instrument after changing the audio file.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>181</x>
  <y>269</y>
  <width>330</width>
  <height>30</height>
  <uuid>{e72946a4-38e2-434b-965e-98bbab24e7a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Restart the instrument after changing the audio file.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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

;Written by Iain McCurdy 2009

; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio files


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


				zakinit	1,1

gisine			ftgen	0, 0, 4096, 10, 1  				;SINE WAVE
;TABLES THAT STORE FFT ANALYSIS ATTRIBUTES DATA
giFFTattributes0	ftgen	1, 0, 4, -2,  512, 256, 1024, 1
giFFTattributes1	ftgen	2, 0, 4, -2, 1024, 256, 1024, 1
giFFTattributes2	ftgen	3, 0, 4, -2, 2048, 128, 2048, 1
giFFTattributes3	ftgen	4, 0, 4, -2, 4096, 128, 4096, 1

;TABLE FOR EXP SLIDER
giExp10000		ftgen	0, 0, 129, -25, 0, 20.0, 128, 10000


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkpow			invalue	"Power"					;init 1.0
		kfreq			invalue	"Frequency"
		gkfreq			tablei	kfreq, giExp10000, 1
						outvalue	"Frequency_Value", gkfreq	;init 250.0	
		gkmltfreq			invalue	"Mult_Frequency"			;init 1.0
		gkDrySigGain		invalue	"Dry_Signal"				;init 0.0
		gkFiltSigGain		invalue	"Filter_Signal"			;init 0.0
		gkResSigGain		invalue	"Resultant_Signal"			;init 1.0

		gkOnOff			invalue	"On_Off"					;		,i1 0 0.01
		gkpartials		invalue	"Partials"				;init 8	,i1 0 0.01
		gkoffset			invalue	"Offset"					;init 0	,i1 0 0.01

		ktrig			changed	gkpartials, gkoffset
		if ktrig = 1 then
				event "i", 1, 0, 0.01	
		endif

		gkmode			invalue	"Mode"					;init 1
		gkinput			invalue	"Input"
		gkFFTattributes	invalue	"FFTattributes"	
	endif
endin

instr 1																	;GENERATES PARTIAL INSTANCES FOR FILTER SIGNAL
	turnon	3															;TURN ON INSTR 3 (FILTERING INSTRUMENT) WITH A HELD NOTE
	turnoff2	2, 0, 1														;CLEAR ALL INSTANCES OF INSTR 2 (FILTER SIGNAL PARTIALS) BEFORE STARTING AGAIN
	kcount init i(gkoffset)+1												;SET INITIAL VALUE OF COUNTER
	begin:																;LABEL
	;         P1 | P2 | P3 |    P4
	event "i",2,    0, 3600,  kcount											;TRIGGER INSTR 2 - I.E. A PARTIAL
	kcount = kcount + 1														;INCREMENT COUNTER
	if (kcount <= i(gkpartials)) kgoto begin									;IF MAX NUMBER OF PARTIALS NOT YET REACHED GO BACK TO LABEL 'BEGIN'
	turnoff																;TUNOFF THIS INSTRUMENT - ITS JOB OS DONE
endin
 
instr 2		;PARTIAL FOR FILTER SIGNAL (MAY BE CALLED MULTIPLE TIME BY INSTR 1)
	if gkOnOff=0 then														;IF ON/OFF BUTTON IS OFF...
		turnoff															;TURN OFF THIS INSTRUMENT IMMEDIATELY
	endif																;END OF CONDITIONAL BRANCHING
	iporttime	= 0.1														;GENERATE A RAMPING-UP VARIABLE FOR PORTAMENTO TIME
	kporttime	linseg	0,0.001,iporttime,1,iporttime								;GENERATE A RAMPING-UP VARIABLE FOR PORTAMENTO TIME
	kfreq	portk	gkfreq, kporttime										;APPLY PORTAMENTO TO SMOOTH SLIDER MOVEMENT
	kpow		portk	gkpow, kporttime										;APPLY PORTAMENTO TO SMOOTH SLIDER MOVEMENT
	kmltfreq	portk	gkmltfreq, kporttime									;APPLY PORTAMENTO TO SMOOTH SLIDER MOVEMENT

	if		gkmode=1	then
		kfrq	limit	p4*kfreq*(kmltfreq^p4), 20, sr/2							;LIMIT FREQUENCY OF PARTIAL TO BELOW NYQUIST FREQ.
	elseif	gkmode=2	then
		kfrq	limit	gkfreq*(1+gkmltfreq^(p4-1)), 20, sr/2						;LIMIT FREQUENCY OF PARTIAL TO BELOW NYQUIST FREQ.
	endif

	a1		oscili	(1/gkpartials)*(kpow^p4), kfrq, gisine						;GENERATE A PARTIAL
			zawm		a1, 1												;ADD IT TO ZAK VARIABLE
endin

instr 	3	;FILTERING INSTRUMENT
	kSwitch		changed		gkFFTattributes								;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then														;IF I-RATE VARIABLE IS CHANGED...
		reinit	UPDATE													;BEGIN A REINITIALISATION PASS IN ORDER TO EFFECT THIS CHANGE. BEGIN THIS PASS AT LABEL ENTITLED 'UPDATE' AND CONTINUE UNTIL rireturn OPCODE 
	endif																;END OF CONDITIONAL BRANCHING
	UPDATE:																;LABEL
	if		gkinput=0	then													;IF 'INPUT' SWITCH IS SET TO 'Live Input' THEN IMPLEMENT THE NEXT LINE OF CODE
		asig		inch		1												;READ AUDIO FROM THE COMPUTER'S LIVE INPUT CHANNEL 1 (LEFT)
	else																	;IF 'INPUT' SWITCH IS NOT SET TO 'STORED FILE' THEN IMPLEMENT THE NEXT LINE OF CODE
		Sfile	invalue	"_Browse"
		;OUTPUT	OPCODE	FILE_PATH | SPEED | INSKIP | WRAPAROUND (1=ON)
		asig		diskin2	Sfile,      1,      0,        1						;READ A STORED AUDIO FILE FROM THE HARD DRIVE
	endif																;END OF 'IF'...'THEN' BRANCHING
	if		gkOnOff!=0	kgoto	CONTINUE									;SENSE FLTK ON/OFF SWITCH. IF ON, SKIP THE NEXT LINE
		turnoff															;TURN THIS INSTRUMENT OFF IMMEDIATELY               
	CONTINUE:																;LABEL                                              

	iFFTsize	table	0, i(gkFFTattributes)+1									;READ FFT SIZE FROM APPROPRIATE TABLE    
	ioverlap	table	1, i(gkFFTattributes)+1									;READ OVERLAP SIZE FROM APPROPRIATE TABLE
	iwinsize	table	2, i(gkFFTattributes)+1									;READ WINDOW SIZE FROM APPROPRIATE TABLE 
	iwintype	table	3, i(gkFFTattributes)+1									;READ WINDOW TYPE FROM APPROPRIATE TABLE

	fsigIn	pvsanal	asig, iFFTsize, ioverlap, iwinsize, iwintype					;ANALYSE THE AUDIO SIGNAL. OUTPUT AN F-SIGNAL.

	aFiltSig	zar		1													;READ IN FILTER SIGNAL FROM ZAK VARIABLE
	aBalSig	oscili	1,1000,gisine											;SPECIFY A BALANCING SIGNAL REFERENCE
	aFiltSig	balance	aFiltSig, aBalSig										;BALANCE FILTER SIGNAL
	kenv		linseg	0,0.1,1,1,1											;AMP ENVELOPE

	fsigFilt	pvsanal	aFiltSig*kenv, iFFTsize, ioverlap, iwinsize, iwintype			;ANALYSE THE FILTER AUDIO SIGNAL. OUTPUT AN F-SIGNAL.
	fsigOut	pvsfilter	fsigIn, fsigFilt, 1										;PERFORM fsig FILTERING

	aresyn 	pvsynth  	fsigOut								                    ;RESYNTHESIZE THE f-SIGNAL AS AN AUDIO SIGNAL

	aout		sum		asig*gkDrySigGain, aFiltSig*gkFiltSigGain, aresyn*gkResSigGain	;MIXER
			outs		aout, aout											;SEND THE RESYNTHESIZED SIGNAL TO THE AUDIO OUTPUTS
			zacl		0,1
			rireturn
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0	   3600	;GUI
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>529</x>
 <y>175</y>
 <width>971</width>
 <height>619</height>
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
  <height>550</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvsfilter</label>
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
  <x>517</x>
  <y>2</y>
  <width>280</width>
  <height>550</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvsfilter</label>
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
  <y>19</y>
  <width>278</width>
  <height>529</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------
pvsfilter filters as fsig according to the spectral content of another signal. This allows for complex spectrally dynamic filtering.
In this example the filter signal used as the template for the filtering process is an additive synthesis tone.
The user has a number of controls over this tone, namely 'Frequency', 'Number of Partials', 'Offset' (lowest partial), 'Power' (a kind of parametric EQ sweep) and finally 'Mult.
Frequency', which affects how partials are spaced in conjunction with the selection made for mode (1 or 2).
For further clarification it is probably best to study the code. A mixer is provided to allow the user to mix between the input signal, the filtering template signal and the sound resulting from the filtering process.
Three options are provided for the input source sound. The user can select between a variety of combinations of parameters for the FFT analysis.
Larger values for FFT size will give better harmonic reproduction but greater time smearing effects and higher computational cost.
Lower values will result in less time smearing but greater harmonic distortion.</label>
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
  <objectName>On_Off</objectName>
  <x>8</x>
  <y>8</y>
  <width>100</width>
  <height>30</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  ON / OFF</text>
  <image>/</image>
  <eventLine>i 1 0 0.01</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>478</y>
  <width>506</width>
  <height>70</height>
  <uuid>{f0c4875d-4e35-4d37-b043-9c1476025645}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FFT Attributes</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
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
  <x>169</x>
  <y>484</y>
  <width>300</width>
  <height>30</height>
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
  <x>169</x>
  <y>504</y>
  <width>274</width>
  <height>32</height>
  <uuid>{c8c311f9-c1b7-4bbb-becf-9c9f1fa862c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>512         256       1024            1</name>
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
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>45</y>
  <width>506</width>
  <height>198</height>
  <uuid>{80ea6034-7533-4a21-a547-4c00f18e8e5e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Filtering Template Signal</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
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
  <x>16</x>
  <y>80</y>
  <width>80</width>
  <height>30</height>
  <uuid>{5b8d26a2-2397-439e-b2ff-21072fb8f53f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>No of Partials</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Partials</objectName>
  <x>96</x>
  <y>80</y>
  <width>40</width>
  <height>30</height>
  <uuid>{6c726695-a184-4e03-9c9b-5a7defdb3984}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <maximum>60</maximum>
  <randomizable group="0">false</randomizable>
  <value>10</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Offset</objectName>
  <x>218</x>
  <y>80</y>
  <width>40</width>
  <height>30</height>
  <uuid>{dab1b064-395c-483f-9944-a8311aba4438}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <minimum>0</minimum>
  <maximum>59</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>138</x>
  <y>80</y>
  <width>80</width>
  <height>30</height>
  <uuid>{63c66be6-1d1f-4a44-8b22-8680f083e808}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Offset</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Mode</objectName>
  <x>340</x>
  <y>80</y>
  <width>40</width>
  <height>30</height>
  <uuid>{3039dd4c-40c6-4553-b4be-9187ba630c04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <maximum>2</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>260</x>
  <y>80</y>
  <width>80</width>
  <height>30</height>
  <uuid>{34bc6389-9909-465c-93aa-5f708194d623}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Mult_Frequency</objectName>
  <x>448</x>
  <y>212</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0aad6f1d-ce40-46c5-92ee-e0f805b68528}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.099</label>
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
  <objectName>Mult_Frequency</objectName>
  <x>8</x>
  <y>195</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d33c4bea-1b6f-4e17-904d-9e67f5b179b7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.09940000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>212</y>
  <width>150</width>
  <height>30</height>
  <uuid>{48c82bc5-2d7c-4cf5-8e31-12caf3d38e31}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mult Frequency</label>
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
  <x>8</x>
  <y>172</y>
  <width>150</width>
  <height>30</height>
  <uuid>{d0d16fd7-660f-4d45-9ea9-2fad66cae306}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency</label>
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
  <objectName>Frequency</objectName>
  <x>8</x>
  <y>155</y>
  <width>500</width>
  <height>27</height>
  <uuid>{7419569a-aec9-4de8-ade2-feb9afabc177}</uuid>
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
  <objectName>Frequency_Value</objectName>
  <x>448</x>
  <y>172</y>
  <width>60</width>
  <height>30</height>
  <uuid>{43bd3451-78f6-487d-821e-edb77ce13a54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>246.330</label>
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
  <objectName>Power</objectName>
  <x>448</x>
  <y>132</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.009</label>
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
  <objectName>Power</objectName>
  <x>8</x>
  <y>115</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00898000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>132</y>
  <width>150</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Power</label>
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
  <x>6</x>
  <y>244</y>
  <width>506</width>
  <height>150</height>
  <uuid>{cdc434d0-b9e7-4f6f-aa90-800ec76dced6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mixer</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
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
  <x>8</x>
  <y>281</y>
  <width>150</width>
  <height>30</height>
  <uuid>{7ff4f06d-512f-4f97-ae7a-ba61ad7ae9a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry Signal</label>
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
  <objectName>Dry_Signal</objectName>
  <x>8</x>
  <y>264</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8deca5e5-2181-4c11-bed5-67d38c1df60c}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Dry_Signal</objectName>
  <x>448</x>
  <y>281</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7435a4a8-2016-49f7-9b3d-2715ef85f4d3}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Filter_Signal</objectName>
  <x>448</x>
  <y>321</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fb713ee8-3ee7-4a52-864b-9e641dec1327}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Filter_Signal</objectName>
  <x>8</x>
  <y>304</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b837c995-70ad-4a2a-8185-490b1f8142a0}</uuid>
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
  <y>321</y>
  <width>150</width>
  <height>30</height>
  <uuid>{8af89861-ace0-4296-8c89-ac5ec07aad45}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Filter Signal</label>
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
  <objectName>Resultant_Signal</objectName>
  <x>448</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{205a01bc-e7bb-489c-a9ea-6140870b4189}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.240</label>
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
  <objectName>Resultant_Signal</objectName>
  <x>8</x>
  <y>344</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f0e95ad8-0e35-4d52-973a-1b1ebd663849}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>5.24000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>361</y>
  <width>150</width>
  <height>30</height>
  <uuid>{c12af3a6-1a09-4dca-9913-31716dbc7dcf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Resultant Signal</label>
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
  <x>6</x>
  <y>395</y>
  <width>506</width>
  <height>82</height>
  <uuid>{70618fd0-47b8-418a-a344-e579eb1d201e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>9</x>
  <y>437</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/moi/Samples/loop.wav</stringvalue>
  <text>Browse Mono Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>61</x>
  <y>403</y>
  <width>120</width>
  <height>30</height>
  <uuid>{cc64e047-7e82-416c-9753-d010ddefabe4}</uuid>
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
    <name>Sound File</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>179</x>
  <y>438</y>
  <width>330</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/moi/Samples/loop.wav</label>
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
   <r>240</r>
   <g>235</g>
   <b>226</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

;Written by Iain McCurdy, 2006

;Modified for QuteCsound by René, October 2010, updated Feb 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for analysis files


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SADIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)


giExp2			ftgen	1000, 0, 129, -25, 0, 0.5, 128, 2.0		;TABLE FOR EXP SLIDER


instr	1	;GUI AND CREATE A CONTINUOUS MOVING PHASE VALUE WITH A GLOBAL VARIABLE OUTPUT

	Sfile_new			strcpy	""					;INIT TO EMPTY STRING

	ktrig	metro	10
	if (ktrig == 1)	then
		gkporttime	invalue	"Portamento_Amount"
		kpch			invalue	"Pitch"
		gkpch		tablei	kpch, giExp2, 1
					outvalue	"Pitch_Value", gkpch
		gkptr		invalue	"Pointer"
		gkspeed		invalue	"Speed"
		gkoutgain		invalue	"Amplitude"

		gkptrswitch	invalue	"Pointer_Switch"
		gkextractmode	invalue	"Extract_Mode"
		gkfreqlim		invalue	"Frequency_Limit"
		gkgatefn		invalue	"Gating_Function"
		gkspec		invalue  "Spec_Env"

		gSfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	gSfile
		kfile 		strcmpk	Sfile_new, Sfile_old
		gkfile		= abs(kfile)					
	endif

	if gkfile = 1 then
		reinit NEW_FILE														;gkfile = 1 if the file have changed
	endif
	NEW_FILE:
	gifilelen		filelen	gSfile	
	gkphs		phasor	gkspeed/gifilelen
				rireturn
endin

instr	2	;pvoc INSTRUMENT
	iporttime	=		.1														;DEFINE A VALUE FOR PORTAMENTO TIME (THIS WILL BE USED TO SMOOTH FLTK SLIDER MOVEMENTS) 
	kporttime	linseg	0, .001, iporttime, 1, iporttime								;DEFINE A RAMPING UP, K-RATE FUNCTION THAT WILL BE USED FOR PORTAMENTO TIME (BASED ON THE I-RATE VALUE DEFINED IN THE PREVIOUS LINE). RAMPING UP THIS VALUE FROM ZERO PREVENTS VARIABLE FROM SLIDING UP TO THEIR REQUIRED INITIAL VALUES EACH TIME THE INSTRUMENT IS RESTARTED.
	kporttime	=		kporttime * gkporttime										;SLIDER FOR PORTAMENTO TIME MULTIPLIED TO kporttime FUNCTION
	kptr		portk	gkptr, kporttime											;APPLY PORTAMENTO TO THE SLIDER DERIVED VAIABLE 'gkptr'. A NEW VARIABLE CALLED 'kptr' IS OUTPUTTED.
	kpch		portk	gkpch, kporttime											;APPLY PORTAMENTO TO THE SLIDER DERIVED VAIABLE 'gkpch'. A NEW VARIABLE CALLED 'kpch' IS OUTPUTTED.
	kSwitch	changed	gkspec, gkptrswitch, gkextractmode, gkfreqlim, gkgatefn, gkfile		;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then															;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	START														;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
	endif

	START:
	ifilelen1	filelen	gSfile													;DERIVE THE TOTAL DURATION OF THE ORIGINAL SOUND FILE FROM THE ANALYSIS FILE
	kptr		=		kptr * ifilelen1											;REDEFINE THE VARIABLE 'kptr' TAKING INTO ACCOUNT THE ACTUAL DURATION OF THE ORIGINAL SOUND FILE (ifilelen)
	kphs		phasor	gkspeed/ifilelen1											;DEFINE A MOVING PHASE VALUE THE FREQUENCY OF WHICH IS DIRECTLY PROPORTIONAL TO THE SPEED DEFINED BY THE FLTK SLIDER AND INVERSELY PROPORTIONAL TO THE DURATION OF THE ORIGINAL SOUND FILE
	kphs		=		kphs * ifilelen1											;RESCALE THE AMPLITUDE OF THE MOVING PHASE VALUE ACCORDING TO THE DURATION OF THE ORIGINAL SOUND FILE
	kptr		=		(gkptrswitch == 0 ? kptr : kphs) 								;CHECK TO SEE WHICH POINTER MODE HAS BEEN SELECTED AND DEFINE THE FINAL VALUE OF 'kptr' ACCORDINGLY

	;OUTPUT	OPCODE	REQUIRED INPUT ARGS         |OPTIONAL INPUT ARGS...
	ares		pvoc		kptr, kpch, gSfile, i(gkspec), i(gkextractmode), i(gkfreqlim), i(gkgatefn)

			rireturn															;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
			outs		ares * gkoutgain, ares * gkoutgain								;SEND pvoc OUTPUT TO THE OUTPUTS, SCALE USING GLOBAL AMPLITUDE VARIABLE
endin
</CsInstruments>
<CsScore>
;GATING FUNCTIONS USED BY PVOC (OPTIONAL)
f 1 0 512 7 0 256 1 256 1	;50% THRESHOLD SHARP GATING
f 2 0 512 5 1 512 .001		;INVERT AMPLITUDES

;INSTR | START | DURATION
i  1      0       3600		;INSTRUMENT 1 PLAYS FOR 1 HOUR
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>329</x>
 <y>260</y>
 <width>1036</width>
 <height>502</height>
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
  <height>500</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvoc</label>
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
  <x>517</x>
  <y>2</y>
  <width>519</width>
  <height>500</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvoc</label>
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
  <x>520</x>
  <y>18</y>
  <width>515</width>
  <height>482</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------------------------------------
Pvoc performs FFT resynthesis on a analysis data file that has been previously created using the pvanal utility that comes with Csound. (This example uses a pre-prepared analysis file but you are encouraged to replace it with one of your own.) The input arguments required by the opcode include one for pitch ratio between the resynthesized sound and the original sound, and an argument for time location within the analysis file from which to resynthesise. This example offers two ways in which to control the time location variable according to how the 'Pointer Switch' is counter is set. When on 'Pointer' mode the 'Pointer' slider is simply used to move the variable ('Speed Control' slider is ignored). When 'Pointer Switch' is set to 'Speed Control' then the 'Speed Control' slider is used to control the speed of the movement (and direction) of the pointer through the analysis file. This value is given as a ratio between the resynthesized sound to the original sound. In this mode 'Pointer' slider is ignored. Optional arguments are also used in this example. When 'Spec. Env.' (spectral enveloping) is on the opcode attempts to preserve the spectral envelope of the original sound. The audible upshot of this is most clearly heard when resynthesizing speech in which transpositions up or down are heard as the person speaking higher or lower rather than as a complete transformation of the character of the voice. 'Extract Mode' and 'Frequency Limit' are used in combination and can be set to filter either resonant components of the sound or noise based components of the sound. If 'Extract Mode' is set to '1' (greater than frequency limit) and 'Frequency Limit' is given a value grater than zero then noise aspects of the sound are favoured in the resynthesis and if 'Frequency Limit' is set to '2' (less than frequency limit) and 'Frequency Limit' is given a value greater than zero then resonant aspects of the sound will be favoured. Using a gating function (table) allows spectrally informed dynamic modification of the sound (akin to a complex multi- -band compressor). Two function shapes are offered by this example.</label>
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
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Portamento_Amount</objectName>
  <x>448</x>
  <y>77</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.518</label>
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
  <objectName>Portamento_Amount</objectName>
  <x>8</x>
  <y>60</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.51800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>77</y>
  <width>320</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Portamento Amount</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>10</x>
  <y>438</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>loop.pvx</stringvalue>
  <text>Browse Analysis File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>181</x>
  <y>439</y>
  <width>330</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>loop.pvx</label>
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
  <y>417</y>
  <width>150</width>
  <height>30</height>
  <uuid>{936f6eb0-5225-4bd7-a5fe-a49df1c9c5ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Analysis File</label>
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
  <x>162</x>
  <y>300</y>
  <width>80</width>
  <height>40</height>
  <uuid>{2389fd37-3d82-4b68-908e-cabc2131db46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency
Limit</label>
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
  <objectName>Frequency_Limit</objectName>
  <x>242</x>
  <y>300</y>
  <width>50</width>
  <height>30</height>
  <uuid>{8f4e9b38-a8c5-4e7b-ab35-16285fab7d46}</uuid>
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
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>305</x>
  <y>279</y>
  <width>120</width>
  <height>30</height>
  <uuid>{3a6af7c2-dd44-4bd8-af21-c500e52ce7da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gating Function</label>
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
  <y>115</y>
  <width>320</width>
  <height>30</height>
  <uuid>{f4029fbc-c802-493b-aacb-44a251dfd70c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch (portamento applied)</label>
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
  <objectName>Pitch</objectName>
  <x>8</x>
  <y>98</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b5b98b11-0602-412e-9830-0bbe82f5476b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.64600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch_Value</objectName>
  <x>448</x>
  <y>115</y>
  <width>60</width>
  <height>30</height>
  <uuid>{aa9d2e59-a8e3-4b3d-a00a-04fcecc3d502}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.224</label>
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
  <x>8</x>
  <y>153</y>
  <width>320</width>
  <height>30</height>
  <uuid>{a9a9faee-c907-4aff-ad05-6a70bd9d06ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer (portamento applied) (Pointer Mode Only)</label>
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
  <objectName>Pointer</objectName>
  <x>8</x>
  <y>136</y>
  <width>500</width>
  <height>27</height>
  <uuid>{360b66e8-758f-4ff0-a7df-169be9d8760b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pointer</objectName>
  <x>448</x>
  <y>153</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7ecbe521-c05c-45c2-b743-43681fcab991}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
  <x>8</x>
  <y>191</y>
  <width>320</width>
  <height>30</height>
  <uuid>{dee4e931-c60f-43f0-87e8-f62fd0c449fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Speed (Speed Control Mode Only)</label>
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
  <objectName>Speed</objectName>
  <x>8</x>
  <y>174</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5d7eeb71-9608-4e1b-be84-48362e1fd850}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-5.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.98000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Speed</objectName>
  <x>448</x>
  <y>191</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ad9154fb-3e69-43ab-87cb-3dab2a26cde6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.980</label>
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
  <x>8</x>
  <y>229</y>
  <width>180</width>
  <height>30</height>
  <uuid>{2e52a7a7-dc13-405e-896d-db2a7431d8dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Gain</label>
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
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>212</y>
  <width>500</width>
  <height>27</height>
  <uuid>{6ab84e0f-82a7-4b9c-af23-35bd7d9b7fa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.71600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>229</y>
  <width>60</width>
  <height>30</height>
  <uuid>{99d6bf8b-3c85-4911-a29a-7dd678a940ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.716</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Pointer_Switch</objectName>
  <x>304</x>
  <y>360</y>
  <width>130</width>
  <height>30</height>
  <uuid>{29a37c71-8767-4302-9132-7a1c2f4b7917}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Pointer</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Speed Control</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Extract_Mode</objectName>
  <x>17</x>
  <y>300</y>
  <width>130</width>
  <height>30</height>
  <uuid>{6a55c957-42d0-48b7-b636-c5cbb2adc7d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Off</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>>  Freq Limit</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>&lt;  Freq Limit</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>17</x>
  <y>279</y>
  <width>120</width>
  <height>30</height>
  <uuid>{47e9a2f7-66fe-45f6-965c-a52c28b135dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Extract Mode</label>
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
  <objectName>Gating_Function</objectName>
  <x>305</x>
  <y>300</y>
  <width>190</width>
  <height>29</height>
  <uuid>{d472f7b4-25f1-4edd-b0d1-a7a026bb9a39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Off</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Amp &lt; 50% attenuated</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Amp spectrum inverted</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Spec_Env</objectName>
  <x>48</x>
  <y>360</y>
  <width>100</width>
  <height>30</height>
  <uuid>{b6345774-7938-4e62-9d8b-0ada81f7bcc5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>   Spec Env</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

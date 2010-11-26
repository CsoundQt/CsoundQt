;Written by Iain McCurdy, 2010

; Modified for QuteCsound by René, November 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add Browser for audio files
;	Instrument 1 is activated by MIDI and by the GUI, portamento added
;	Add Init instrument 4


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 10		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1


giFFTsizes	ftgen	0,0,8,-2,128,256,512,1024,2048,4096,8192	;FFT SIZES


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkptr		invalue	"Manual_Pointer"
		gkspeed		invalue	"Pointer_Speed"
		gkpitch		invalue	"Pitch"
		gkamp		invalue	"Amp"

		gklock		invalue	"Lock"
		gkPtrMode		invalue	"PtrMode"
		gkFFTsize		invalue	"FFTsize"
	endif
endin

instr 1
	if p4!=0 then																	;MIDI
		ioct		= p4																;READ OCT VALUE FROM MIDI INPUT

		;PITCH BEND===========================================================================================================================================================
		iSemitoneBendRange = 24														;PITCH BEND RANGE IN SEMITONES
		imin		= 0																;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333										;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax												;PITCH BEND VARIABLE (IN oct FORMAT)
		kfreq	=	cpsoct(ioct + kbend) / cpsoct(8)									;(CONVERT TO RATIO: MIDDLE C IS POINT OF UNISON)
		;=====================================================================================================================================================================
	else																			;GUI
		kfreq		= gkpitch														;SET FUNDEMENTAL TO SLIDER "pitch"
	endif

	kporttime		linseg	0,0.001,0.02												;CREATE A VARIABLE FUNCTION THAT RAPIDLY RAMPS UP TO A SET VALUE	
	kpitch		portk	kfreq, kporttime											;CUTOFF FREQ. IS A SMOOTHED VERSION OF SLIDER FOR CUTOFF FREQUENCY


	Sfile_new		strcpy	""					;INIT TO EMPTY STRING

	Sfile		invalue	"_Browse"
	Sfile_old		strcpyk	Sfile_new
	Sfile_new		strcpyk	Sfile
	kfile 		strcmpk	Sfile_new, Sfile_old

	if	kfile != 0	then															;IF A BANG HAD BEEN GENERATED IN THE LINE ABOVE
			reinit	NEW_FILE														;REINITIALIZE FROM LABEL 'UPDATE'
	endif
	NEW_FILE:
		
	ifile	ftgentmp	0, 0, 0, 1, Sfile,0,0,1											;READ MONO OR STEREO AUDIO FILE CHANNEL 1
	ilen		=	nsamp(ifile)/sr													;DERIVE FILE LENGTH IN SECONDS
			rireturn																;RETURN FROM REINITIALIZATION PASS

	kptr		=	gkptr*ilen														;POINTER IN SECONDS (AS OPPOSED TO 0-1)	
				outvalue	"Manual_Pointer_Value", kptr									;UPDATE POINTER VALUE IN SECONDS DISPLAY BOX
	kptr			portk	kptr, kporttime											;APPLY PORTAMENTO TO POINTER VARIABLE
	if gkPtrMode=0 then																;IF 'MANUAL POINTER' POINTER MODE HAS BEEN CHOSEN...
		atimpt	interp	kptr														;POINTER TAKEN DIRECTLY FROM FLTK SLIDER
	elseif gkPtrMode=1 then															;OR IF SPEED POINTER MODE HAS BEEN CHOSEN... 
		kspeed	portk	gkspeed, kporttime											;APPLY PORTAMENTO SMOOTHING TO SPEED SLIDER 
		atimpt	phasor	kspeed/ilen												;CREATE A MOVING PHASE VALUE PROPORTIONAL TO SPEED AND INVERSELY PROPOERTIONAL TO FILE LENGTH
		atimpt	=		atimpt * ilen												;RESCALE MOVING PHASE VALUE TO ENCOMPASS ENTIRE SOUND FILE
	endif																		;END OF THIS CONDITIONAL BRANCH

	kamp			portk	gkamp, kporttime											;APPLY PORTAMENTO SMOOTHING TO AMPLITUDE SLIDER VALUE
	
	ktrigger		changed	gkFFTsize													;IF gkFFTsize CHANGES GENERATE A '1' (BANG)
	if ktrigger=1 then																;IF THE ABOVE LINE HAS GENERATED A '1'...
			reinit	UPDATE2														;BEGIN A REINITIALIZATION PASS FROM LABEL 'UPDATE2'
	endif																		;END OF THIS CONDITIONAL BRANCH
	UPDATE2:																		;LABEL CALLED 'UPDATE2'
	ifftsize	table	i(gkFFTsize), giFFTsizes											;DERIVE CHOSEN FFT SIZE FROM ON SCREEN BUTTON BANK AND FFTsizes FUNCTION TABLE
	asig 	mincer 	atimpt, kamp, kpitch, ifile, gklock, ifftsize	;,idecim]				;ktab AND klock SEEM TO BE REVERSED WITH RESPECT TO THEIR DOCUMENTATION IN THE MANUAL
			rireturn
	aenv		linsegr	0,0.05,1,0.05,0												;DE-CLICKING ENVELOPE
			outs		asig*aenv, asig*aenv											;SEND AUDIO TO OUTPUTS
endin

instr	2	;SET TIME SCALING SLIDER TO P4 DETERMINED VALUES
	outvalue	"Pointer_Speed", p4
endin

instr	3	;SET PITCH SCALING SLIDER TO P4 DETERMINED VALUES
	outvalue	"Pitch", p4
endin

instr	4	;INIT
	outvalue	"Amp", 1.0
	outvalue	"Lock", 1
	outvalue	"Pitch", 1.0
	outvalue	"FFTsize", 3
	outvalue	"Pointer_Speed", 1.0
	outvalue	"PtrMode", 1
	outvalue	"Manual_Pointer", 0.1
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0	   3600	;GUI
i  4      0.1       0	;INIT
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>308</x>
 <y>186</y>
 <width>1143</width>
 <height>411</height>
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
  <height>344</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>mincer</label>
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
  <x>518</x>
  <y>2</y>
  <width>537</width>
  <height>344</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>mincer</label>
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
  <y>18</y>
  <width>533</width>
  <height>322</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------------------------------------------
mincer performs phase vocoding resynthesis on GEN 1 function tables with the option of phase locking. Phase locking can give improved results, particularly when freezing the time pointers progress through the sound. Access to the GEN 1 function table is done by providing the opcode with a time value in seconds. This example interprets the lengths of a variety of sound files so that the pointer always encompasses the entirety of the chosen file. External to the opcode, a phasor is used to move through the file (speed mode) to provide a 'time scaling' type operation using the 'Speed' control. Additional buttons allow the user to freeze progress through the sound file or to restore normal speed. Pitch transposition is also possible by providing a pitch ratio value. An on screen button will return this control to its unison setting. The user can choose  any mono   or stereo sound file, only channel one is loaded. A variety of FFT sizes can be explored - smaller sizes will will result in less time smearing by more spectral distortion larger sizes will result in less spectral distortion but more time smearing. This example can also be activated from a MIDI keyboard in which case MIDI pitch is mapped to the the pitch ratio used by mincer. In this mode the slider for pitch will be ignored. Middle C is the point of no transposition.
NOTE THAT IN THE 5.13 MANUAL THE ktab AND klock PARAMETER ARE INCORRECTLY SWAPPED.</label>
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
  <width>120</width>
  <height>30</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>301</y>
  <width>506</width>
  <height>40</height>
  <uuid>{f0c4875d-4e35-4d37-b043-9c1476025645}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FFT Size</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>FFTsize</objectName>
  <x>325</x>
  <y>305</y>
  <width>100</width>
  <height>32</height>
  <uuid>{c8c311f9-c1b7-4bbb-becf-9c9f1fa862c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>128</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>512</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>1024</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2048</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4096</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8192</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>3</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Manual_Pointer_Value</objectName>
  <x>446</x>
  <y>91</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.963</label>
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
  <objectName>Manual_Pointer</objectName>
  <x>6</x>
  <y>74</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
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
  <x>6</x>
  <y>91</y>
  <width>180</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Manual Pointer (seconds)</label>
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
  <height>56</height>
  <uuid>{cdc434d0-b9e7-4f6f-aa90-800ec76dced6}</uuid>
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
  <x>10</x>
  <y>265</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/moi/Samples/808loop.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>180</x>
  <y>266</y>
  <width>330</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/moi/Samples/808loop.wav</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>PtrMode</objectName>
  <x>197</x>
  <y>41</y>
  <width>100</width>
  <height>30</height>
  <uuid>{be1f1edc-082e-4433-a418-1e81baf4e305}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Manual</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Speed</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Lock</objectName>
  <x>327</x>
  <y>41</y>
  <width>120</width>
  <height>30</height>
  <uuid>{c2ce77b0-a2e9-4055-8013-ac958f83938a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  Lock On / Off</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>77</x>
  <y>41</y>
  <width>120</width>
  <height>30</height>
  <uuid>{28e35706-38ed-48ef-9db8-d33ceb43f556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer Mode</label>
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
  <x>6</x>
  <y>128</y>
  <width>180</width>
  <height>30</height>
  <uuid>{658605d0-b67f-46be-afc9-d4e81186d1c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer Speed</label>
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
  <objectName>Pointer_Speed</objectName>
  <x>6</x>
  <y>111</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b4e86d09-493d-4b35-a9d4-b32004edb444}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pointer_Speed</objectName>
  <x>446</x>
  <y>128</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f1ecf7ec-a379-4bc9-b168-2627289c7bd8}</uuid>
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
  <x>6</x>
  <y>175</y>
  <width>180</width>
  <height>30</height>
  <uuid>{e4b74d62-17a5-44e2-807e-3251bd2570e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch</label>
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
  <x>6</x>
  <y>158</y>
  <width>500</width>
  <height>27</height>
  <uuid>{c15a2d14-f6f2-4f3b-8ffd-fc1fc422644a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.12500000</minimum>
  <maximum>4.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch</objectName>
  <x>446</x>
  <y>175</y>
  <width>60</width>
  <height>30</height>
  <uuid>{27d7476c-9550-4f4b-97e4-79c0fe22d00f}</uuid>
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
  <x>6</x>
  <y>222</y>
  <width>180</width>
  <height>30</height>
  <uuid>{244f4991-4d70-459c-9125-dc0bedb44336}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp</label>
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
  <objectName>Amp</objectName>
  <x>6</x>
  <y>205</y>
  <width>500</width>
  <height>27</height>
  <uuid>{aec1f16e-6cc4-4ec0-b6ac-0507d179454f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amp</objectName>
  <x>446</x>
  <y>222</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab6dedab-477d-4361-bf78-2763acfd72f8}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>241</x>
  <y>139</y>
  <width>80</width>
  <height>20</height>
  <uuid>{3e3dffdf-b30f-4572-8bdc-f88dfece9e87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Normal</text>
  <image>/</image>
  <eventLine>i2 0 0 1 </eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>324</x>
  <y>139</y>
  <width>80</width>
  <height>20</height>
  <uuid>{13cad86e-f79e-4377-a027-b55df036ba18}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Freeze</text>
  <image>/</image>
  <eventLine>i2 0 0 0</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>324</x>
  <y>183</y>
  <width>80</width>
  <height>20</height>
  <uuid>{de156fcb-ea14-4edd-90ac-adf962f25958}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Unisson</text>
  <image>/</image>
  <eventLine>i3 0 0 1</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

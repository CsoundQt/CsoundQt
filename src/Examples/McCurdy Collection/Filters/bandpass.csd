;Written by Iain McCurdy, 2010

;Modified for QuteCsound by René, October 2010, updated Feb 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files
;	Removed recording instrument (included in QuteCsound)
;	Instrument 1 is activated by MIDI and by the GUI, portamento added
;	Modified the macro CONTROLLER and now included in GUI instrument
;	Removed giconcave and kactive
;	Add init instrument 2


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1


;TABLES FOR EXP SLIDER
giExp2			ftgen	0, 0, 129, -25, 0, 0.125, 128, 2.0
giExp5			ftgen	0, 0, 129, -25, 0, 0.01,  128, 5.0
giExp20			ftgen	0, 0, 129, -25, 0, 1.0,   128, 20.0
giExp15000		ftgen	0, 0, 129, -25, 0, 20.0,  128, 15000.0


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

	Sfile_new			strcpy	""					;INIT TO EMPTY STRING

	ktrig	metro	10
	if (ktrig == 1)	then
		gkslope		invalue	"Slope"
		gkbalance		invalue	"Balance"

		kspeed		invalue	"Playback_Speed"
		gkspeed		tablei	kspeed, giExp2, 1
					outvalue	"Playback_Speed_Value", gkspeed
		khp			invalue	"Balance_Half_Point"
		gkhp			tablei	khp, giExp20, 1
					outvalue	"Balance_Half_Point_Value", gkhp
		gkInGain		invalue	"Input_Gain"
		gkAtt		invalue	"Attack_Time"
		gkRel		invalue	"Release"
		gkgain		invalue	"Amplitude"
		kfreq		invalue	"X_Frequency"
		gkfreq		tablei	kfreq, giExp15000, 1
					outvalue	"X_Frequency_Value", gkfreq
		kband		invalue	"Y_Bandwidth"
		gkband		tablei	kband, giExp5, 1
					outvalue	"Y_Bandwidth_Value", gkband
		gkinput		invalue	"Input"

		gSfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	gSfile
		gkfile 		strcmpk	Sfile_new, Sfile_old

;A MACRO IS DEFINE TO PREVENT CODE REPETITION
#define CONTROLLER(NAME'NUMBER')
		#	;START OF MACRO
		k$NAME_M			ctrl7	1,$NUMBER,0,1   									;READ MIDI CONTROLLER ON CHANNEL 1
		ktrig$NAME		changed	k$NAME_M                								;CREATE A TRIGGER PULSE IF MIDI CONTROLLER IS MOVED
		if ktrig$NAME=1	then														;IF MIDI SLIDER HAS BEEN MOVED
			outvalue	"$NAME", k$NAME_M												;UPDATE LINEAR SLIDER
		endif																	;END OF THIS CONDITIONAL BRANCH			
		#	;END OF MACRO
	
		;           NAME  NUM
		$CONTROLLER(X_Frequency'    1')												;EXPAND MACRO
		$CONTROLLER(Y_Bandwidth'    2')												;EXPAND MACRO
		$CONTROLLER(Playback_Speed' 3')												;EXPAND MACRO
	endif
endin

instr	1
	if p4!=0 then																	;MIDI
		ioct		= p4																;READ OCT VALUE FROM MIDI INPUT

		;PITCH BEND===========================================================================================================================================================
		iSemitoneBendRange = 24														;PITCH BEND RANGE IN SEMITONES
		imin		= 0																;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333										;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax												;PITCH BEND VARIABLE (IN oct FORMAT)
		kfreq	=	cpsoct(ioct + kbend)
		;=====================================================================================================================================================================
	else																			;GUI
		kfreq		= gkfreq														;SET FUNDEMENTAL TO SLIDER X_Frequency
	endif

	kporttime		linseg	0,0.001,0.05												;CREATE A VARIABLE FUNCTION THAT RAPIDLY RAMPS UP TO A SET VALUE	
	kfreq		portk	kfreq, kporttime											;CUTOFF FREQ. IS A SMOOTHED VERSION OF SLIDER FOR CUTOFF FREQUENCY
	kband		portk	gkband, kporttime											;SMOOTH MOVEMENT OF SLIDER VARIABLE
	kspeed		portk	gkspeed, kporttime											;SMOOTH MOVEMENT OF SLIDER VARIABLE
	kband		limit	kband*kfreq, 0, 10000										;SCALE BANDWIDTH ACCORDING TO CUTOFF FREQUENCY VALUE - LIMIT VALUE TO PREVENT FILTER 'EXPLOSION'

	if gkinput=0 then
		kNew_file		changed	gkfile												;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
		if	kNew_file=1	then														;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
			reinit	NEW_FILE														;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
		endif
		NEW_FILE:
		;OUTPUTS		OPCODE	FILE  | SPEED | INSKIP | LOOPING (0=OFF 1=ON)
		asigL, asigR	FilePlay2	gSfile, kspeed,  0,       1								;GENERATE 2 AUDIO SIGNALS FROM A STEREO SOUND FILE
					rireturn														;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
	else
		asigL,asigR	ins
		asigL	=	asigL * gkInGain
		asigR	=	asigR * gkInGain
	endif

	aresL 		butbp 	asigL, kfreq, kband, 0										;FILTER EACH CHANNEL SEPARATELY
	aresR 		butbp 	asigR, kfreq, kband, 0										;FILTER EACH CHANNEL SEPARATELY
	if gkslope=1	then																;IF SLOPE SWITCH IS ON 48dB PER OCTAVE
		aresL 	butbp 	aresL, kfreq, kband, 0										;FILTER EACH CHANNEL SEPARATELY
		aresR 	butbp 	aresR, kfreq, kband, 0										;FILTER EACH CHANNEL SEPARATELY
	endif																		;END OF THIS CONDITIONAL BRANCH
	if gkbalance=1 then																;IF BALANCVE SWITCH IS ON
		ktrig	changed	gkhp
		if ktrig=1 then
				reinit	UPDATE
		endif
		UPDATE:
		aresL	balance	aresL, asigL, i(gkhp)										;APPLY 'BALANCE' DYNAMICS PROCESSING
		aresR	balance	aresR, asigR, i(gkhp)										;APPLY 'BALANCE' DYNAMICS PROCESSING
				rireturn
	endif																		;END OF THIS CONDITIONAL BRANCH

	aenv			expsegr	0.0001,i(gkAtt),1,i(gkRel),0.0001								;CLOUD AMPLITUDE ENVELOPE
	aresL		=		aresL * gkgain * aenv										;SCALE AUDIO SIGNAL WITH FLTK GAIN SLIDER AND ENVELOPE
	aresR		=		aresR * gkgain * aenv										;SCALE AUDIO SIGNAL WITH FLTK GAIN SLIDER AND ENVELOPE
				outs 	aresL, aresR												;SEND AUDIO TO OUTPUTS
endin

instr	2	;INIT
				outvalue	"X_Frequency", 0.5
				outvalue	"Y_Bandwidth", 0.5
				outvalue	"Playback_Speed", 0.75
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i  10      0       3600		;GUI, PLAYS FOR 1 HOUR
i   2      0.1       0		;INIT
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>73</x>
 <y>116</y>
 <width>822</width>
 <height>646</height>
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
  <height>640</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandpass</label>
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
  <x>516</x>
  <y>2</y>
  <width>306</width>
  <height>640</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandpass</label>
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
  <y>25</y>
  <width>296</width>
  <height>598</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------
This example is an implementation of a bandpass filter using Csound's butterworth bandpass filter (butterbp/butbp) but with some extra options added. Cutoff frequency and bandwidth can be controlled via the on-screen x-y panel. The actual value used for bandwidth is proportional to the current value of the cutoff frequency, this gives a slightly more musical response. The normal cutoff slope for a butterworth bandpass filter is 24 decibels per octave (dB/oct). By activating the slope switch the steepness of this slope is doubled to 48dB/oct by engaging another iteration of the butbp opcode. Activating the 'Balance' switch applies Csound's 'balance' opcode to the output of the filter, this opcode modifies the dynamics of the signal given to it to match those of the signal pre-filtering. The half-point of the smoothing of its response - effectively the response speed - can be adjusted. This is an i-rate variable so realtime adjustments causes discontinuities in the realtime audio output. Cutoff frequency, bandwidth and playback speed of the input sound file can also be modulated using MIDI controllers 1, 2 and 3 respectively. MIDI controller modulation is  reflected in the on screen sliders. If the instrument is activated by MIDI notes, MIDI pitch is interpretted as cutoff frequency, in this mode the GUI and MIDI controller assignment for cutoff frequency is ignored.</label>
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
  <x>10</x>
  <y>40</y>
  <width>150</width>
  <height>30</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>       On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Input_Gain</objectName>
  <x>447</x>
  <y>103</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
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
  <objectName>Input_Gain</objectName>
  <x>200</x>
  <y>84</y>
  <width>308</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
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
  <x>200</x>
  <y>103</y>
  <width>180</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>140</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>SynthPad.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>179</x>
  <y>141</y>
  <width>330</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>SynthPad.wav</label>
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
  <x>8</x>
  <y>119</y>
  <width>150</width>
  <height>30</height>
  <uuid>{936f6eb0-5225-4bd7-a5fe-a49df1c9c5ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Audio File</label>
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
  <y>540</y>
  <width>180</width>
  <height>30</height>
  <uuid>{f4029fbc-c802-493b-aacb-44a251dfd70c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Balance Half Point (Hz)</label>
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
  <objectName>Balance_Half_Point</objectName>
  <x>8</x>
  <y>523</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b5b98b11-0602-412e-9830-0bbe82f5476b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.69400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Balance_Half_Point_Value</objectName>
  <x>448</x>
  <y>540</y>
  <width>60</width>
  <height>30</height>
  <uuid>{aa9d2e59-a8e3-4b3d-a00a-04fcecc3d502}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7.997</label>
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
  <objectName>Slope</objectName>
  <x>201</x>
  <y>40</y>
  <width>150</width>
  <height>30</height>
  <uuid>{d643d19c-34ce-4bcd-9ee2-135c4a051d99}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  Slope: 24dB / 48dB</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Balance</objectName>
  <x>357</x>
  <y>40</y>
  <width>150</width>
  <height>30</height>
  <uuid>{eab383a7-3552-4ad8-9017-91cb1ea03bfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     Balance On / Off</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>60</x>
  <y>90</y>
  <width>100</width>
  <height>30</height>
  <uuid>{553f3292-c18a-4e4f-8f54-e701a305a278}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Audio File</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Live Input</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>90</y>
  <width>50</width>
  <height>30</height>
  <uuid>{a77052fe-1711-4d82-ad04-1570e61a6c4e}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>X_Frequency</objectName>
  <x>8</x>
  <y>179</y>
  <width>500</width>
  <height>261</height>
  <uuid>{dae61b8e-3fef-455e-abaf-9c75f65c8770}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Y_Bandwidth</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.50000000</xValue>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Playback_Speed_Value</objectName>
  <x>448</x>
  <y>503</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d0075173-7a71-436d-a925-46c4fc754d6c}</uuid>
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
  <objectName>Playback_Speed</objectName>
  <x>8</x>
  <y>486</y>
  <width>500</width>
  <height>27</height>
  <uuid>{a4423654-78c9-49e9-bd4f-bca0f58c872b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.75000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>503</y>
  <width>180</width>
  <height>30</height>
  <uuid>{27bac8a7-0227-4b0b-8225-558f992bec4b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Playback Speed (CC#3)</label>
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
  <x>96</x>
  <y>440</y>
  <width>320</width>
  <height>30</height>
  <uuid>{9f99cd4a-fb91-4ac9-a6ba-7826fd7a3cca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>X - Frequency (CC#1) Y - Bandwidth (CC#2)</label>
  <alignment>center</alignment>
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
  <objectName>Y_Bandwidth_Value</objectName>
  <x>428</x>
  <y>442</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b203f995-09c6-4fad-9c2e-d66d400c89e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.224</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>428</x>
  <y>464</y>
  <width>80</width>
  <height>30</height>
  <uuid>{99c2ab61-04de-4979-ad6e-c3ae3f17f202}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandwidth</label>
  <alignment>center</alignment>
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
  <y>464</y>
  <width>80</width>
  <height>30</height>
  <uuid>{d5c5d50e-4f37-41e7-9694-710adcc4ec69}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency</label>
  <alignment>center</alignment>
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
  <objectName>X_Frequency_Value</objectName>
  <x>8</x>
  <y>442</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8d54c298-41f4-4e92-a222-4f994ac014a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>547.721</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>616</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c3c1b3bc-47fc-4187-9f95-850f7fb2683c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.160</label>
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
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>599</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5859ebf7-c1f2-4866-9a7e-793d30329ab9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.16000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>616</y>
  <width>180</width>
  <height>30</height>
  <uuid>{0665b286-163c-4d04-a056-7a8fd1ef7d1e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Amplitude Scaling</label>
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
  <objectName>Release</objectName>
  <x>448</x>
  <y>578</y>
  <width>60</width>
  <height>30</height>
  <uuid>{65484666-a900-4555-bea6-c28d9885ebe9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.154</label>
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
  <objectName>Release</objectName>
  <x>268</x>
  <y>561</y>
  <width>240</width>
  <height>27</height>
  <uuid>{e83fee54-dc21-4304-81f2-b75c7a9fad16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.05000000</minimum>
  <maximum>10.00000000</maximum>
  <value>4.15437500</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>268</x>
  <y>578</y>
  <width>180</width>
  <height>30</height>
  <uuid>{de95ecce-1745-43ee-b5bd-aabc2cdb811b}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <label>Release</label>
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
  <y>578</y>
  <width>180</width>
  <height>30</height>
  <uuid>{73be8c0f-bbd2-41d0-a889-e68922e068eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack Time</label>
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
  <objectName>Attack_Time</objectName>
  <x>8</x>
  <y>561</y>
  <width>240</width>
  <height>27</height>
  <uuid>{aee90a16-28eb-42af-a8e0-b13c92530675}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.05000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Attack_Time</objectName>
  <x>188</x>
  <y>578</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f36fac9f-cf76-481e-8041-6e6971d43023}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.050</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

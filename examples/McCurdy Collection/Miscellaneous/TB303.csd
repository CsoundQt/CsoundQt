;Written by Iain McCurdy, 2010

;Modified for QuteCsound by René, February 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:


;                                             Bassline
;	---------------------------------------------------------------------------------------------------------------------------------
;	This example is an emulation of a Roland TB303 Bassline step synthesizer. It makes use of Csound's looping envelopes lpshold
;	loopseg and looptseg to loop pitch, note on/off status, hold status and filter envelopes for each note.
;	The filter used is Csound's moogladder filter (this can be swapped with moogvcf is real-time performance is an issue).
;	Distortion is implemented using the 'clip' opcode. The pitch of each step is controlled by its own knob, the values of these
;	are expressed in Csound 'pch' format - middle C = 8.00, G above middle C = 8.07, C above middle C = 9.00 and so on.
;	Each step has its own on/off switch and 'hold' switch. The hold function defeats a retriggering of the filter envelope to
;	create a smoother transition between notes. A stereo delay and reverb effect are included. Delay times are defined in
;	semitones This example is a work in progress.


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine	ftgen	0, 0, 8192, 10, 1


instr	1	;GUI and SENSE NOTE KNOBS
	ktrig	metro	10
	if (ktrig == 1)	then
		gkVol		invalue	"Volume"
		gkCfBase		invalue	"Cutoff"
		gkCfEnv		invalue	"Envelope"
		gkRes		invalue	"Resonance"
		gkDecay		invalue	"Decay"
		gkDist		invalue	"Distortion"
		gkTempo		invalue	"Tempo"
		gkWaveform	invalue	"Waveform"
		;DELAY
		gkDelTimL		invalue	"DelayTimeL"
		gkDelTimR		invalue	"DelayTimeR"
		gkDelSnd		invalue	"DelaySend"
		gkDelFB		invalue	"DelayFB"
		;REVERB
		gkRvbSnd		invalue	"ReverbSend"
		gkRvbFB		invalue	"ReverbFB"

#define	STEP(N)
		#
		;KNOBS
		gkNote$N		invalue	"Note$N"

		;TEXT INPUT
		gkpch$N		invalue	"PCH$N"

		;SWITCHES
		gkOn$N		invalue	"On$N"
		gkHold$N		invalue	"Hold$N"
		#

		$STEP(1)
		$STEP(2)
		$STEP(3)
		$STEP(4)
		$STEP(5)
		$STEP(6)
		$STEP(7)
		$STEP(8)
		$STEP(9)
		$STEP(10)
		$STEP(11)
		$STEP(12)
		$STEP(13)
		$STEP(14)
		$STEP(15)
		$STEP(16)
	endif

#define	NOTE(N)
	#
	koct$N	=	int(gkNote$N)						;DERIVE OCTAVE
	ksemi$N	=	frac(gkNote$N) * 0.12				;DERIVE PCH FORMAT INTERVAL ABOVE OCTAVE
	ksemi$N	=	int(ksemi$N*100) * 0.01				;CLEAN TO 2 DECIMAL PLACES
	kNote$N	=	koct$N + ksemi$N					;ADD OCTAVE TO SEMITONES
	ktrig$N	changed	kNote$N						;IF PCH HAS CHANGED GENERATE A TRIGGER
	if ktrig$N=1	then								;IF PCH VALUE HAS CHANGED...
		event "i", 2, 0, 0.01, kNote$N, $N
		ktrig$N=0									;PREVENT REITERATION
	endif										;END OF THIS CONDITIONAL BRANCH
	#
	$NOTE(1)
	$NOTE(2)
	$NOTE(3)
	$NOTE(4)
	$NOTE(5)
	$NOTE(6)
	$NOTE(7)
	$NOTE(8)
	$NOTE(9)
	$NOTE(10)
	$NOTE(11)
	$NOTE(12)
	$NOTE(13)
	$NOTE(14)
	$NOTE(15)
	$NOTE(16)
endin

instr	2	;UPDATE NOTE VALUE DISPLAYS
#define	PRINTVAL(N)
	#
	if p5=$N then
		outvalue	"PCH$N", p4
	endif
	#
	$PRINTVAL(1)
	$PRINTVAL(2)
	$PRINTVAL(3)
	$PRINTVAL(4)
	$PRINTVAL(5)
	$PRINTVAL(6)	
	$PRINTVAL(7)	
	$PRINTVAL(8)	
	$PRINTVAL(9)	
	$PRINTVAL(10)	
	$PRINTVAL(11)	
	$PRINTVAL(12)	
	$PRINTVAL(13)	
	$PRINTVAL(14)	
	$PRINTVAL(15)	
	$PRINTVAL(16)
endin

instr	3	;Bassline instrument
	kPhFreq   =            gkTempo/240						; frequency with which to repeat the entire phrase
	kBtFreq   =            (gkTempo)/15					; frequency of each 1/16th note
	
	;envelopes with held segments        note:1         2         3         4         5         6         7         8         9         10         11         12         13         14         15         16           DUMMY
	kPch      lpshold      kPhFreq, 0, 0,gkpch1, 1,gkpch2, 1,gkpch3, 1,gkpch4, 1,gkpch5, 1,gkpch6, 1,gkpch7, 1,gkpch8, 1,gkpch9, 1,gkpch10, 1,gkpch11, 1,gkpch12, 1,gkpch13, 1,gkpch14, 1,gkpch15, 1,gkpch16,   1,gkpch1; need an extra 'dummy' value
	kOn       lpshold      kPhFreq, 0, 0,gkOn1,  1,gkOn2,  1,gkOn3,  1,gkOn4,  1,gkOn5,  1,gkOn6,  1,gkOn7,  1,gkOn8,  1,gkOn9,  1,gkOn10,  1,gkOn11,  1,gkOn12,  1,gkOn13,  1,gkOn14,  1,gkOn15,  1,gkOn16,     1,1
	kHold     lpshold      kPhFreq, 0, 0,gkHold1,1,gkHold2,1,gkHold3,1,gkHold4,1,gkHold5,1,gkHold6,1,gkHold7,1,gkHold8,1,gkHold9,1,gkHold10,1,gkHold11,1,gkHold12,1,gkHold13,1,gkHold14,1,gkHold15,1,gkHold16,   1,0; need an extra 'dummy' value

	kHold     vdel_k       kHold, 1/kBtFreq, 1				; offset hold by 1/2 note duration
	kOct      portk        octpch(kPch), 0.01*kHold			; apply portamento to pitch changes - if note is not held, no portamento will be applied
	
	; amplitude envelope
	if kHold=0 then									; if hold status is 'off'...
		;                                         attack     sustain        decay
		kAmpEnv   loopseg      kBtFreq, 0,   0,   0,0.1,  1, 60/gkTempo, 1,  0.1,0			; sustain segment duration (and therefore attack and decay segment durations) are dependent upon tempo
	else
		kAmpEnv   =            1													; if hold status is 'on', ignore amplitude envelope, replace with a constant value of '1'
	endif
	
	;filter envelope
	kCfOct    init         i(gkCfBase)												; give kCfOct and initial value
	if kHold=0 then				; if hold is off
		; create a filter cutoff frequency envelope
		kCfOct    looptseg      kBtFreq, 0, 0, gkCfBase+gkCfEnv, gkDecay, 1, gkCfBase		;5.12 OR GREATER OPTION
		;kCfOct    loopseg      kBtFreq, 0, 0, gkCfBase+gkCfEnv, 1, gkCfBase				;PRE-VERSION 5.12 OPTION - DECAY CONTROL WILL NOT WORK WITH THIS OPTION
	endif
	kCfOct    limit        kCfOct, 4, 14											; limit the cutoff frequency to be within sensible limits
	;kCfOct    port         kCfOct, 0.05											; smooth the cutoff frequency envelope with portamento
	
	kWavTrig  changed      gkWaveform												; generate a 'bang' if waveform selector changes
	if kWavTrig=1 then															; if a 'bang' has been generated...
		reinit REINIT_VCO														; begin a reinitialization pass from the label 'REINIT_VCO'
	endif
	REINIT_VCO:; a label
	aSig      vco2         0.2, cpsoct(kOct), i(gkWaveform)*2, 0.5						; generate audio using VCO oscillator
			rireturn															; return from initialization pass to performance passes

	aSig      moogladder   aSig, cpsoct(kCfOct), gkRes								; filter audio 

	;acf	interp	cpsoct(kCfOct)
	;aSig      moogvcf   aSig, cpsoct(kCfOct), gkRes 	;use moogvcf if CPU is struggling with moogladder
	;aSig      moogvcf   aSig, acf, gkRes 	;use moogvcf if CPU is struggling with moogladder
	
	; distortion
	iSclLimit ftgentmp     0, 0, 1024, -16, 1, 1024,  -8, 0.01							; rescaling curve for clip 'limit' parameter
	iSclGain  ftgentmp     0, 0, 1024, -16, 1, 1024,   4, 10							; rescaling curve for gain compensation
	kLimit    table        gkDist, iSclLimit, 1										; read Limit value from rescaling curve
	kGain     table        gkDist, iSclGain, 1										;  read Gain value from rescaling curve
	kTrigDist changed      kLimit													; if limit value changes generate a 'bang'
	if kTrigDist=1 then															; if a 'bang' has been generated...
		reinit REINIT_CLIP														; begin a reinitialization pass from label 'REINIT_CLIP'
	endif
	REINIT_CLIP:
	aSig      clip		aSig, 0, i(kLimit)											; clip distort audio signal
			rireturn
	aSig      =		aSig * kGain												; compensate for gain loss from 'clip' processing
	kOn       port		kOn, 0.006
	aSig		=		aSig * kAmpEnv * gkVol * kOn
			outs		aSig, aSig										     	; audio sent to output, apply amp. envelope, volume control and note On/Off status
	gaDelSnd	=		aSig * gkDelSnd
	gaRvbSndL	=		aSig * gkRvbSnd
	gaRvbSndR	=		gaRvbSndL
endin

instr	10	;Delay
	kDelTimL	limit	(gkDelTimL * 60) / (gkTempo * 4), 0.001, 9.99
	kDelTimR	limit	(gkDelTimR * 60) / (gkTempo * 4), 0.001, 9.99
	aDelTimL	interp	kDelTimL
	aDelTimR	interp	kDelTimR
	aBuffer	delayr	10
	atapL	deltap3	aDelTimL
			delayw	gaDelSnd + (atapL * gkDelFB)
	aBuffer	delayr	10
	atapR	deltap3	aDelTimR
			delayw	gaDelSnd + (atapR * gkDelFB)
			outs		atapL, atapR
	gaRvbSndL	=		gaRvbSndL + (atapL * gkRvbSnd)
	gaRvbSndR	=		gaRvbSndR + (atapR * gkRvbSnd)
			clear	gaDelSnd			
endin

instr	11	;REVERB
	aRvbL, aRvbR	reverbsc	gaRvbSndL, gaRvbSndR, gkRvbFB, 10000
				outs		aRvbL, aRvbR
				clear	gaRvbSndL, gaRvbSndR
endin
</CsInstruments>
<CsScore>
i 1 0 3600	;GUI and SCAN FOR NOTE KNOB CHANGES
i 10 0 3600
i 11 0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>350</x>
 <y>257</y>
 <width>986</width>
 <height>435</height>
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
  <width>980</width>
  <height>432</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bassline TB303</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>5</r>
   <g>27</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>150</x>
  <y>68</y>
  <width>80</width>
  <height>30</height>
  <uuid>{b6afbe1e-677c-44a6-ba84-4c32dc21b0a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tempo:</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>9</x>
  <y>9</y>
  <width>100</width>
  <height>30</height>
  <uuid>{7dbefb02-2884-4758-bb74-9d8c2c05fdee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> Start / Stop</text>
  <image>/</image>
  <eventLine>i 3 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Tempo</objectName>
  <x>231</x>
  <y>68</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1a670196-b3bf-4425-88a0-475d5ec594bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <maximum>500</maximum>
  <randomizable group="0">false</randomizable>
  <value>110</value>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Volume</objectName>
  <x>20</x>
  <y>129</y>
  <width>80</width>
  <height>80</height>
  <uuid>{2561be08-8152-4a56-ae21-e14a05258589}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>2.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>20</x>
  <y>207</y>
  <width>80</width>
  <height>30</height>
  <uuid>{9fe3110e-fc92-4af5-b902-5d9527e1cb4b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Volume</label>
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
  <objectName>Volume</objectName>
  <x>20</x>
  <y>227</y>
  <width>80</width>
  <height>25</height>
  <uuid>{880f19d6-05a5-4415-87e6-eb8f1e2e16ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Cutoff</objectName>
  <x>109</x>
  <y>129</y>
  <width>80</width>
  <height>80</height>
  <uuid>{7357627e-9f0b-4986-8226-514401f8b4eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>4.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>6.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>109</x>
  <y>207</y>
  <width>80</width>
  <height>30</height>
  <uuid>{6e55e7d7-1acb-4acf-90ea-367e5cc1c53e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Cutoff</label>
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
  <objectName>Cutoff</objectName>
  <x>109</x>
  <y>227</y>
  <width>80</width>
  <height>25</height>
  <uuid>{09a60093-6f5c-40d1-b2cb-1cc3f9c2311e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Envelope</objectName>
  <x>198</x>
  <y>129</y>
  <width>80</width>
  <height>80</height>
  <uuid>{a1ca0a23-93f9-40bf-aa52-99a4612621ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>6.48000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>198</x>
  <y>207</y>
  <width>80</width>
  <height>30</height>
  <uuid>{5f6b48b7-7099-4b9a-b818-4ac0dc25abf6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Envelope</label>
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
  <objectName>Envelope</objectName>
  <x>198</x>
  <y>227</y>
  <width>80</width>
  <height>25</height>
  <uuid>{36fa1f41-09f6-4e72-9db4-93bf74f8c577}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6.480</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Resonance</objectName>
  <x>287</x>
  <y>129</y>
  <width>80</width>
  <height>80</height>
  <uuid>{690dd771-4589-4265-9bba-3158f2c98695}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.98000000</maximum>
  <value>0.49980000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>287</x>
  <y>207</y>
  <width>80</width>
  <height>30</height>
  <uuid>{8234c5b9-218b-4c72-b1bb-b6cbded61122}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Resonance</label>
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
  <objectName>Resonance</objectName>
  <x>287</x>
  <y>227</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5b144149-8cf5-4da5-a24b-9ce7824c6adb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Decay</objectName>
  <x>376</x>
  <y>129</y>
  <width>80</width>
  <height>80</height>
  <uuid>{9838a013-7f80-432b-af02-6385e76092eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-10.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>376</x>
  <y>207</y>
  <width>80</width>
  <height>30</height>
  <uuid>{2a1536c7-e5a4-45fe-976e-c20ad54eabe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay</label>
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
  <objectName>Decay</objectName>
  <x>376</x>
  <y>227</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4d5450d7-b89c-4b39-9d25-3969d63dc554}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Distortion</objectName>
  <x>465</x>
  <y>129</y>
  <width>80</width>
  <height>80</height>
  <uuid>{0a874874-ee5f-43d4-82be-5c9e336aef9d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>465</x>
  <y>207</y>
  <width>80</width>
  <height>30</height>
  <uuid>{b626728e-79a8-4cf8-85c9-a933f504289e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Distortion</label>
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
  <objectName>Distortion</objectName>
  <x>465</x>
  <y>227</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f0d122d6-49ee-4fab-a9de-b33ee4479c1b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.200</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Waveform</objectName>
  <x>379</x>
  <y>67</y>
  <width>100</width>
  <height>30</height>
  <uuid>{d11bad82-2cb0-430f-b9ab-50e1661af121}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Sawtooth</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Square</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>DelayTimeL</objectName>
  <x>645</x>
  <y>68</y>
  <width>40</width>
  <height>30</height>
  <uuid>{19df37b9-4535-490d-bd07-fe07f1983762}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>DelayTimeR</objectName>
  <x>688</x>
  <y>68</y>
  <width>40</width>
  <height>30</height>
  <uuid>{7a69a5c5-40c8-4d6c-b5ec-b684bdbac670}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>71</y>
  <width>120</width>
  <height>30</height>
  <uuid>{e508ea94-2d8c-4521-8e9c-01bff5101b89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Time L - R:</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note1</objectName>
  <x>64</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9b14a796-fecc-4aca-a29c-549cd7a5e3c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>7.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH1</objectName>
  <x>64</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{703c2ebd-6f54-46e8-a854-fe4dea29d541}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7.010</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>64</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{fcfba5c7-b8e9-41b9-ab82-f4099a23cf41}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On1</objectName>
  <x>80</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{86f303d1-7e82-43c5-9eda-9f465102838d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold1</objectName>
  <x>80</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{4144af63-0200-4bae-8551-886f7081c3e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note2</objectName>
  <x>120</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{e4a55d30-ff82-4ce0-a61b-38cba63df0ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>8.54000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH2</objectName>
  <x>120</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{9ac2c790-5f19-497d-bf32-89b5334b4232}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.060</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>120</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{a328fda3-db2c-417c-82ea-1713d19dd540}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On2</objectName>
  <x>136</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{c94b154c-22e6-40d8-a095-6794f925b553}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold2</objectName>
  <x>136</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{e4d3232a-ea2f-4fc6-8989-12b6e4d80a10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>-1</x>
  <y>273</y>
  <width>60</width>
  <height>30</height>
  <uuid>{59423e9f-e9b0-425f-af1e-bac08ab0bf46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch</label>
  <alignment>right</alignment>
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
  <x>-1</x>
  <y>361</y>
  <width>60</width>
  <height>30</height>
  <uuid>{964071cc-d2d3-4878-82a3-d6c8a69febf4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On/Off</label>
  <alignment>right</alignment>
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
  <x>-1</x>
  <y>385</y>
  <width>60</width>
  <height>30</height>
  <uuid>{174cd992-57bf-4e56-b469-f7aeb08db543}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Hold</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note11</objectName>
  <x>635</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{e3ed8991-2f5f-4bfc-b5ca-b21fe07e1308}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>7.16000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH11</objectName>
  <x>635</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{8fcf902b-095b-457d-b717-a693315c3a43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7.010</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>635</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{ba570a81-9e1c-4aca-aba5-45cf5a231e22}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>11</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On11</objectName>
  <x>651</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{8f3f0074-a2cb-4815-81c9-3ce3d6c2b1fd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold11</objectName>
  <x>651</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{45f98ca5-c552-457d-abd6-fd2bdc29475b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note12</objectName>
  <x>693</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{221fc474-c058-46e1-9923-32d26650cfeb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>8.18000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH12</objectName>
  <x>693</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{f341bc03-4348-4c6f-bcfb-69ca2d334a8c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.020</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>693</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{15068633-064a-4233-87b9-1cd5aabbc6c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>12</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On12</objectName>
  <x>709</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{6edc30a5-b647-4038-a8b1-e87e16d8724d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold12</objectName>
  <x>709</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{7467dbba-0ce8-4a9b-9339-63a06a8f5b84}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note13</objectName>
  <x>750</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{25259292-bc97-4153-b79c-28de5fc57c77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>7.46000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH13</objectName>
  <x>750</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{0cc86b0f-7c7b-409b-853a-aca86e76e1df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7.050</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>750</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{c2ba75d2-fc7f-4049-af5f-88bccf97b3a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>13</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On13</objectName>
  <x>766</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{6a9cce3c-f14b-44a5-a55d-5ea27d13fcd0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold13</objectName>
  <x>766</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{b3f7826e-1048-4d95-9992-962e2fe0c227}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note14</objectName>
  <x>807</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{5a69ab48-0fa0-474c-bc4b-e00160fd1e90}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>6.44000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH14</objectName>
  <x>807</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{2579546c-9e3a-49ae-bed9-d1884753069f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6.050</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>807</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{68b39c3b-73c1-48ff-9195-e87bdedaad15}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>14</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On14</objectName>
  <x>823</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{03bc97d6-3c9d-4510-a5d5-b8dfdf851961}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold14</objectName>
  <x>823</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{620f4b1e-b5f7-4a31-ace6-dd84c14a4c9a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note15</objectName>
  <x>864</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{fb3dd8b3-91b8-4053-9620-ca07be186806}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>6.80000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH15</objectName>
  <x>864</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{52c14df7-8289-4b94-95db-26d1cfeb6d96}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6.090</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>864</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{7869c70b-3fd4-4be2-9a67-8415adb07d67}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>15</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On15</objectName>
  <x>880</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{878e4ad0-75c0-4d79-9512-6a55d05c8642}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold15</objectName>
  <x>880</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{a7ccfae7-dd38-4855-b73a-66dd73e6c51c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note16</objectName>
  <x>921</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{8ccadfb0-2fe4-4072-b22d-1e468e403997}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>6.14000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH16</objectName>
  <x>921</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{f5f4144d-142d-4608-b744-fef3d962dc7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6.010</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>921</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{2efbaa9f-493d-4500-b6cf-a997cf39dacc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>16</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On16</objectName>
  <x>937</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{8f5bb747-82fb-4592-a122-bbada7be3ca6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold16</objectName>
  <x>937</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{7aa54da5-6e12-4bb5-a893-a37e5be30cdc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note3</objectName>
  <x>178</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{0f77aff4-7455-4528-92b1-a0e6bc64c99c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>6.80000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH3</objectName>
  <x>178</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{63dbd372-bc0c-4b12-9e17-8a269d66cbea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6.090</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>178</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{957486d4-ddf0-4f79-83da-98d43f6af456}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On3</objectName>
  <x>194</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{afe4dffb-892a-4e46-b357-60e11c688f9a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold3</objectName>
  <x>194</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{cab6eb87-75a3-4f90-9ed5-aa896b55661a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note4</objectName>
  <x>235</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{097bbcdb-5805-478e-b6b5-c9552620c267}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>8.84000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH4</objectName>
  <x>235</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{1bab7216-e5b7-4605-ac46-659a06c3aa3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.100</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>235</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{bcf5141a-d0e4-475b-b0db-0c788429070b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On4</objectName>
  <x>251</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{34dec287-cc74-4353-b4ca-565bd94f1d5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold4</objectName>
  <x>251</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{56f58bc0-8c10-4e30-a865-b0fcfd22d2fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note5</objectName>
  <x>292</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{82cd78e4-c821-47f3-be02-ee60ab985951}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>7.64000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH5</objectName>
  <x>292</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{a3e1b1d5-31d1-4cae-a6f2-5a585bafa675}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7.070</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>292</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{b1f43934-7b08-446f-928a-a9ff454adbae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On5</objectName>
  <x>308</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{306e3062-5a6e-4336-b221-533f6469f8ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold5</objectName>
  <x>308</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{2edfa77f-836e-4920-b80b-18cc6ffd1d50}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note6</objectName>
  <x>349</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{48dfa96d-aa31-424a-9495-4f26e0fb4a9e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>7.94000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH6</objectName>
  <x>349</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{a5ec53cd-7f9e-46b0-b818-a81af1529dcd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7.110</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>349</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{f9babb00-bd5f-4a7c-95ef-a6c199f911ff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On6</objectName>
  <x>365</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{03c6ea27-11de-4da9-9b63-e8ff92e7d47f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold6</objectName>
  <x>365</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{8f940322-3443-4c3e-bccb-ff855509f148}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note7</objectName>
  <x>406</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{74dc0a94-d877-4e53-a878-57d01b5c607f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>8.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH7</objectName>
  <x>406</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{16f01fdc-b723-4810-91ca-a0a7dcd14bf4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>406</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{65a8511c-79b1-496a-a705-64205355bba4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On7</objectName>
  <x>422</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{5c53b734-da48-4e75-9c8c-309bf8e5a5b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold7</objectName>
  <x>422</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{02a861c7-8fd3-4f46-a0ab-acc403704108}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note8</objectName>
  <x>463</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{ec336734-45fa-4fff-a5b3-45156fec8291}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>6.14000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH8</objectName>
  <x>463</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{3878d49d-b526-4081-9cff-9f51f34c9e02}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6.010</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>463</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{9303c9e3-9680-4d0e-b5de-360a0a847634}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On8</objectName>
  <x>479</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{b37655a6-97f1-4d85-a1a6-bc9beb8c2d2c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold8</objectName>
  <x>479</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{5d498949-6c23-4625-93ae-9a2e9053d41a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note9</objectName>
  <x>520</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{602d78eb-ce7e-46eb-b942-7137b2c88add}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>7.04000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH9</objectName>
  <x>520</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{97993f6e-6b2b-4bd5-86bc-d7f6caed4f7d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>520</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{eb1aea73-fb13-4d0d-ab73-6cf911ad212f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>9</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On9</objectName>
  <x>536</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{4e578e5a-2bdf-4e90-99b4-949780fd3cd4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold9</objectName>
  <x>536</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{c0cb3e46-bbf9-4085-bfd7-fc75d0d28d79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Note10</objectName>
  <x>577</x>
  <y>260</y>
  <width>50</width>
  <height>50</height>
  <uuid>{4e191016-5288-4ef7-912e-38857a1d2f58}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>5.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>6.80000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PCH10</objectName>
  <x>577</x>
  <y>330</y>
  <width>50</width>
  <height>25</height>
  <uuid>{0dbb1c6c-af77-41ec-be0c-c101b6d62ad5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6.090</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>577</x>
  <y>310</y>
  <width>50</width>
  <height>30</height>
  <uuid>{234272a9-836e-4d6c-b7c8-38f47fec9901}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>On10</objectName>
  <x>593</x>
  <y>362</y>
  <width>20</width>
  <height>20</height>
  <uuid>{3e5720ed-7fd6-418c-aeb9-37b18c5d841a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Hold10</objectName>
  <x>593</x>
  <y>387</y>
  <width>20</width>
  <height>20</height>
  <uuid>{1a78441b-56d8-4a61-942d-2dd958110109}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>295</x>
  <y>69</y>
  <width>80</width>
  <height>30</height>
  <uuid>{ff3befd2-bf5e-400e-9979-cf581a0426e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input:</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>DelaySend</objectName>
  <x>635</x>
  <y>147</y>
  <width>50</width>
  <height>50</height>
  <uuid>{402f3274-6d0f-4677-aff3-8b68cc2a08e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.19000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>635</x>
  <y>197</y>
  <width>50</width>
  <height>50</height>
  <uuid>{bcd62122-1456-4dcd-86ea-060d28739b04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay
Send</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>DelayFB</objectName>
  <x>693</x>
  <y>147</y>
  <width>50</width>
  <height>50</height>
  <uuid>{e0dbd7bc-6e5b-4210-90b9-db16a5d3f2d3}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>693</x>
  <y>197</y>
  <width>50</width>
  <height>50</height>
  <uuid>{a3b25ce5-2107-4b61-bdb2-7ca27d3f409a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay
FB</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>ReverbSend</objectName>
  <x>864</x>
  <y>147</y>
  <width>50</width>
  <height>50</height>
  <uuid>{e1b25181-0b8b-477d-a86a-332854720c6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.19000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>864</x>
  <y>197</y>
  <width>50</width>
  <height>50</height>
  <uuid>{4c918331-cc3f-483f-b03d-d636fa2bef43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb
Send</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>ReverbFB</objectName>
  <x>921</x>
  <y>147</y>
  <width>50</width>
  <height>50</height>
  <uuid>{6b4416d6-e3f9-4661-b281-39df8b9c0948}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.83000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>921</x>
  <y>197</y>
  <width>50</width>
  <height>50</height>
  <uuid>{15541d10-f6a3-4a2a-9f91-e71d3ebd959b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb
FB</label>
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
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

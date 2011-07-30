;Written by Iain McCurdy, 2009

;Modified for QuteCsound by René, March 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add tables for exp slider
;	Use menu for exitation signal choice
;	INIT instrument added
;	Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine	ftgen	0,0,1024,10,1						;A SINE WAVE
giExp1	ftgen	0, 0, 129, -25, 0, 20.0, 128, 8000.0	;TABLE FOR EXP SLIDER
giExp2	ftgen	0, 0, 129, -25, 0,  5.0, 128, 7000.0	;TABLE FOR EXP SLIDER


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
		gkInput		invalue	"Input"
		gkNseDur		invalue	"NoiseDur"
		kSineTFrq		invalue	"SineTFreq"
		gkSineTFrq	tablei	kSineTFrq, giExp1, 1
					outvalue	"SineTFreq_Value", gkSineTFrq
		gkSineDur		invalue	"SineBDur"
		kSineFrq		invalue	"SineBFreq"
		gkSineFrq		tablei	kSineFrq, giExp1, 1
					outvalue	"SineBFreq_Value", gkSineFrq
		gkplk		invalue	"PluckPos"
		gkpick		invalue	"PickPos"
		gkdamp		invalue	"Damping"
		kcps			invalue	"Pitch"
		gkcps		tablei	kcps, giExp2, 1
					outvalue	"Pitch_Value", gkcps
		gkamp		invalue	"Amplitude"
		gkfilt		invalue	"Filter"

		gkImplsGain	invalue	"ImpGain"
		gkOutGain		invalue	"OutGain"

		Sfile_new		strcpy	""											;INIT TO EMPTY STRING
		gSfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	gSfile
		gkfile 		strcmpk	Sfile_new, Sfile_old
	endif
endin

instr	1	;MIDI INPUT INSTRUMENT
	icps		cpsmidi														;READ CYCLES PER SECOND VALUE FROM MIDI INPUT
	iamp		ampmidi	1													;AMPLITUDE IS READ FROM INCOMING MIDI NOTE

	iporttime	=		0.1													;PORTAMENTO TIME
	kporttime	linseg	0,0.01,iporttime,1,iporttime								;PORTAMENTO TIME VARIABLE THAT RAMPS UP FROM ZERO
	kpick	portk	gkpick, kporttime										;APPLY PORTAMENTO TO 'PICK-UP POSITION' VARIABLE (PREVENTS 'ZIP' NOISE)
	kSineTFrq	portk	gkSineTFrq, kporttime									;APPLY PORTAMENTO TO 'SINE TONE FREQUENCY' VARIABLE (MAKES MODULATION SMOOTHER)

	if		gkInput==0	then												;IF gkinput=1, I.E. IF 'NOISE BURST' IS SELECTED...
		kenv		expseg	1,i(gkNseDur),.00001,1,.00001							;CREATE AN AMPLITUDE ENVELOPE FOR THE NOISE BURST
		axcite	pinkish	kenv												;CREATE A PINK NOISE SIGNAL
	elseif	gkInput==1	then												;IF gkinput=2, I.E. IF 'SOUND FILE' IS SELECTED...
		kNew_file	changed	gkfile											;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
		if	kNew_file=1	then												;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
			reinit	NEW_FILE												;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
		endif
		NEW_FILE:
		;OUTPUTS	OPCODE	FILE  | SPEED | INSKIP | LOOPING (0=OFF 1=ON)
		axcite,aR	FilePlay2	gSfile,  1,      0,         1							;GENERATE 2 AUDIO SIGNALS FROM A STEREO SOUND FILE RIGHT CHANNEL WILL BE IGNORED
				rireturn													;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES

	elseif	gkInput==2	then												;IF gkinput=3, I.E. IF 'SINE TONE' IS SELECTED...
		kenv		expseg	1,i(gkSineDur),.00001,1,.00001						;CREATE AN AMPLITUDE ENVELOPE FOR THE SINE BURST
		axcite	oscili	kenv, gkSineFrq, gisine								;CREATE A SINE TONE, FREQUENCY TAKEN FROM GUI SLIDER
	elseif	gkInput==3	then												;IF gkinput=4, I.E. IF 'SINE BURST' IS SELECTED...
		axcite	oscili	1, kSineTFrq, gisine								;CREATE A SINE TONE
	endif

	kSwitch	changed	gkplk, gkdamp, gkfilt									;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then														;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	UPDATE
	endif

	UPDATE:
	ares		wgpluck 	icps, iamp, kpick, i(gkplk), i(gkdamp), i(gkfilt), axcite * gkImplsGain	
			rireturn														;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
			outs		ares * gkOutGain, ares * gkOutGain							;SEND AUDIO TO OUTPUTS, SCALE OUTPUT BY gkOutGain WHICH IS CREATED BY A SLIDER
endin

instr	2	;GUI ACTIVATED INSTRUMENT
	iporttime	=		0.1													;PORTAMENTO TIME
	kporttime	linseg	0,0.01,iporttime,1,iporttime								;PORTAMENTO TIME VARIABLE THAT RAMPS UP FROM ZERO
	kpick	portk	gkpick, kporttime										;APPLY PORTAMENTO TO 'PICK-UP POSITION' VARIABLE (PREVENTS 'ZIP' NOISE)
	kSineTFrq	portk	gkSineTFrq, kporttime									;APPLY PORTAMENTO TO 'SINE TONE FREQUENCY' VARIABLE (MAKES MODULATION SMOOTHER)

	if		gkInput==0	then												;IF gkinput=1, I.E. IF 'NOISE BURST' IS SELECTED...
		kenv		expseg	1,i(gkNseDur),.00001,1,.00001							;CREATE AN AMPLITUDE ENVELOPE FOR THE NOISE BURST
		axcite	pinkish	kenv												;CREATE A PINK NOISE SIGNAL
	elseif	gkInput==1	then												;IF gkinput=2, I.E. IF 'SOUND FILE' IS SELECTED...
		kNew_file	changed	gkfile											;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
		if	kNew_file=1	then												;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
			reinit	NEW_FILE												;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
		endif
		NEW_FILE:
		;OUTPUTS	OPCODE	FILE  | SPEED | INSKIP | LOOPING (0=OFF 1=ON)
		axcite,aR	FilePlay2	gSfile,  1,      0,         1							;GENERATE 2 AUDIO SIGNALS FROM A STEREO SOUND FILE RIGHT CHANNEL WILL BE IGNORED
				rireturn													;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES

	elseif	gkInput==2	then												;IF gkinput=3, I.E. IF 'SINE TONE' IS SELECTED...
		kenv		expseg	1,i(gkSineDur),.00001,1,.00001						;CREATE AN AMPLITUDE ENVELOPE FOR THE SINE BURST
		axcite	oscili	kenv, gkSineFrq, gisine								;CREATE A SINE TONE, FREQUENCY TAKEN FROM GUI SLIDER
	elseif	gkInput==3	then												;IF gkinput=4, I.E. IF 'SINE BURST' IS SELECTED...
		axcite	oscili	1, kSineTFrq, gisine								;CREATE A SINE TONE
	endif

	kSwitch	changed	gkcps, gkamp, gkplk, gkdamp, gkfilt						;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then														;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	UPDATE
	endif

	UPDATE:
	ares		wgpluck 	i(gkcps), i(gkamp), kpick, i(gkplk), i(gkdamp), i(gkfilt), axcite * gkImplsGain	
			rireturn														;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
			outs 	ares * gkOutGain, ares * gkOutGain							;SEND AUDIO TO OUTPUTS, SCALE OUTPUT BY gkOutGain WHICH IS CREATED BY A SLIDER
endin

instr	3	;INIT
		outvalue	"PluckPos"	, .98
		outvalue	"PickPos"		, .1
		outvalue	"Damping"		, 20
		outvalue	"Pitch"		, 0.5652
		outvalue	"Amplitude"	, 0.5
		outvalue	"Filter"		, 1000
		outvalue	"ImpGain"		, 0.15
		outvalue	"OutGain"		, 0.15
		outvalue	"NoiseDur"	, 0.3
		outvalue	"SineBDur"	, 0.3
		outvalue	"SineBFreq"	, 0.45201
		outvalue	"SineTFreq"	, 0.45201
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION 
i 10		0		3600	;GUI

i 3		0		0.1	;INIT
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>835</x>
 <y>209</y>
 <width>844</width>
 <height>684</height>
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
  <width>511</width>
  <height>680</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wgpluck</label>
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
   <r>147</r>
   <g>154</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>62</y>
  <width>220</width>
  <height>30</height>
  <uuid>{640b50b7-7200-4f81-8394-89d9843ae939}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pluck Position (i-rate)</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>PluckPos</objectName>
  <x>8</x>
  <y>41</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.98000002</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PluckPos</objectName>
  <x>448</x>
  <y>62</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b731b52e-e14a-476a-a583-f3b2bd885539}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.980</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>8</y>
  <width>120</width>
  <height>30</height>
  <uuid>{04d44ebe-12eb-4bb0-a3f5-9e4fd3e7830e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>108</y>
  <width>220</width>
  <height>30</height>
  <uuid>{1fee3c20-99d2-4c60-baa7-669d23492f06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pick-up Position (k-rate)</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>PickPos</objectName>
  <x>8</x>
  <y>87</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f5ebacc2-9a31-48e3-adb0-3cb090aec444}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.99999000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>PickPos</objectName>
  <x>448</x>
  <y>108</y>
  <width>60</width>
  <height>30</height>
  <uuid>{221d17eb-f6ee-4286-a97f-e6bc5c0a1749}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>154</y>
  <width>220</width>
  <height>30</height>
  <uuid>{bce7cccd-a303-4a57-af94-fd50cf914991}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Damping</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Damping</objectName>
  <x>8</x>
  <y>133</y>
  <width>500</width>
  <height>27</height>
  <uuid>{aaf82558-9229-4d61-8190-0286f3764e87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>20.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Damping</objectName>
  <x>448</x>
  <y>154</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1cd1723d-bcd9-44df-9f08-9d8191f03601}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>200</y>
  <width>220</width>
  <height>30</height>
  <uuid>{0f0e06ef-104c-459c-8a8b-3bf531321341}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch in CPS</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Pitch</objectName>
  <x>8</x>
  <y>179</y>
  <width>500</width>
  <height>27</height>
  <uuid>{4a2f399c-8a7b-40cf-84ab-839e1d7012f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.56519997</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch_Value</objectName>
  <x>448</x>
  <y>200</y>
  <width>60</width>
  <height>30</height>
  <uuid>{62bd5b38-121f-4382-8c01-02c75edf2237}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>300.136</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>246</y>
  <width>220</width>
  <height>30</height>
  <uuid>{3967c371-a6b0-46ca-a51c-5a44bcad618d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>225</y>
  <width>500</width>
  <height>27</height>
  <uuid>{fa94c4bb-3469-4fbf-9096-f6f7c115eb69}</uuid>
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
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>246</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1f01b045-b441-4f44-8dfe-884fb64aba2a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>336</y>
  <width>220</width>
  <height>30</height>
  <uuid>{ca70090e-4ea1-4812-92c7-b0185789dd74}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Impulse Gain</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>ImpGain</objectName>
  <x>8</x>
  <y>315</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5c956305-dd8a-41c4-a8c8-f6810de98456}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.15000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ImpGain</objectName>
  <x>448</x>
  <y>336</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5c7fff71-06fa-4537-b05e-42f313464f5e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.150</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>382</y>
  <width>220</width>
  <height>30</height>
  <uuid>{5c040edc-9c01-48f3-82f1-b1ab4ab783a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Gain</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>OutGain</objectName>
  <x>8</x>
  <y>361</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5964ce8f-786f-4f9c-b7fd-4296524ae0d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>OutGain</objectName>
  <x>448</x>
  <y>382</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3e946893-6ed7-47aa-a9f4-01ca8e1b0aa9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.508</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>2</y>
  <width>323</width>
  <height>680</height>
  <uuid>{d4197d59-95e7-4fb4-8c29-56aaf8759c16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wgpluck</label>
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
   <r>147</r>
   <g>154</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>511</y>
  <width>220</width>
  <height>30</height>
  <uuid>{46af5ce6-bccf-4dde-8bf1-3b1813564763}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Noise Burst Duration</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>NoiseDur</objectName>
  <x>8</x>
  <y>490</y>
  <width>500</width>
  <height>27</height>
  <uuid>{6b9dfa56-4f64-43e4-917b-e67a1651cfa0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.30000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>NoiseDur</objectName>
  <x>448</x>
  <y>511</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f6d137ad-4713-4831-b3df-5a9ffeac43d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.300</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>557</y>
  <width>220</width>
  <height>30</height>
  <uuid>{5827f4b1-ad0a-4d1c-8747-414e88af2ee7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sine Tone Frequency</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>SineTFreq</objectName>
  <x>8</x>
  <y>536</y>
  <width>500</width>
  <height>27</height>
  <uuid>{bb541ae6-8236-40d8-a0d0-744c3296a512}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.45201001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>SineTFreq_Value</objectName>
  <x>448</x>
  <y>557</y>
  <width>60</width>
  <height>30</height>
  <uuid>{084a8d91-cf42-4dc1-95a8-c3da37aa3874}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>300.084</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>603</y>
  <width>220</width>
  <height>30</height>
  <uuid>{62a32db8-949d-4a30-baf2-0eb6962c0383}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sine Burst Duration</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>SineBDur</objectName>
  <x>8</x>
  <y>582</y>
  <width>500</width>
  <height>27</height>
  <uuid>{aa58e620-d673-4877-a5c8-0a970b666b12}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.30000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>SineBDur</objectName>
  <x>448</x>
  <y>603</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fb39934d-98b2-46d5-aa5b-9e321297c251}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.300</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>649</y>
  <width>220</width>
  <height>30</height>
  <uuid>{acf61f85-e306-4fa2-9ec4-7339ea03554c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sine Burst Frequency</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>SineBFreq</objectName>
  <x>8</x>
  <y>628</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d38266cc-b4dc-4933-9631-98588ff07969}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.45201001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>SineBFreq_Value</objectName>
  <x>448</x>
  <y>649</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bea552e7-1162-45d7-a7be-ab38bfa073ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>300.084</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>178</x>
  <y>406</y>
  <width>137</width>
  <height>30</height>
  <uuid>{7a28c75c-0384-43d7-a78c-917ef55f9f74}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Noise Burst</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sound File</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sine Burst</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sine Tone</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>520</x>
  <y>45</y>
  <width>316</width>
  <height>578</height>
  <uuid>{4dd9a56f-89f0-4d88-aacf-1fcb6f6145fd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------
wgpluck produces a simulation of a plucked string using interpolating delay lines and is based on the Karpluss-Strong plucked string model.
It takes an audio signal as an input with which to excite the string although even if this exitation signal is silence a plucked string sound is still produced. Nonetheless, the exitation signal does still influence the sound produced.
 'Damping' and 'Filter' both have an impact on the tone produced. 'Damping' has a more marked influence on the sound produced and also has the effect of shorting the duration of the note. 'Pick-up Position' is the only parameter that can be modulated at k-rate.
I have included gain controls on the exitation signal and on the output signal of the opcode. A variety of short burst and sustained signals are offered. A short burst of pink noise, a short sine tone burst whose frequency can be modulated, a sound file and a sustained sine tone.
'Amplitude' controls the amplitude of the sound of the plucked string. Low values will not result in silence at the output but instead a greater predominance of the exitation signal.
'Pick-up Position' allows the user to vary the location of the pick-up along the length of the string. A value of 0.5 here represents the half-way point along the string, zero and 1 represent either end of the string. Zero and 1 will accentuate the higher harmonics (as the output is a harmonic sound) and 0.5 will favour the odd numbered harmonics, producing a clarinet-like tone.</label>
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
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>442</y>
  <width>170</width>
  <height>30</height>
  <uuid>{43341095-bc3a-4607-bd0e-01254da7bc67}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>Songpan.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>177</x>
  <y>443</y>
  <width>330</width>
  <height>28</height>
  <uuid>{b66f3878-dfd0-4290-9b9d-73be88197222}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Songpan.wav</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>291</y>
  <width>220</width>
  <height>30</height>
  <uuid>{9a2e6222-da30-40a0-a0bb-4c203f351200}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Filter</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Filter</objectName>
  <x>8</x>
  <y>270</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f524826c-f8e9-42ef-bbbc-91b65da0382f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <value>1000.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Filter</objectName>
  <x>448</x>
  <y>291</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b05c66ec-15b1-4b14-b4b2-a22617214f75}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1000.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>75</x>
  <y>410</y>
  <width>100</width>
  <height>30</height>
  <uuid>{32c52184-d40a-4c61-82dd-1900bf7bbd9e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Exitation signal</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

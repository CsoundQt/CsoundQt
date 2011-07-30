;Written by Iain McCurdy, 2006

;DEMONSTRATION OF THE wgbow OPCODE. THIS IS A PHYSICALLY MODELLED BOWED STRING INSTRUMENT BASED ON WORK BY PERRY COOK

;kamp - AMPLITUDE

;kfreq - THE FUNDEMENTAL OF THE TONE PRODUCED

;kpres - PRESSURE OF THE BOW UPON THE STRING
;	THE OPCODE AUTHOR, JOHN FFITCH, SUGGESTS THAT WE CHOOSE VALUES WITHIN THE RANGE 1 to 5
;	HE ALSO SUGGESTS THAT A VALUE OF 3 REFLECTS NORMAL PLAYING PRESSURE

;krat - POSITION OF THE BOW ALONG THE LENGTH OF THE STRING
;	THE OPCODE AUTHOR SUGGESTS THAT WE CHOOSE VALUES WITHIN THE RANGE .025 to 0.23
;	HE ALSO SUGGESTS THAT A VALUE OF .127236 REFLECTS A NORMAL BOWING POSITION
;	STRING EFFECTS SUCH AS 'SUL PONTICELLO' (AT THE BRIDGE) AND 'FLAUTANDO' (OVER THE NECK) CAN BE IMITATED USING THIS PARAMETER
;	A VALUE OF .025 REFLECTS A 'SUL PONTICELLO' STYLE OF PLAYING AND PRODUCES A THINNER TONE
;	A VALUE OF .23 REFLECTS A 'FLAUTANDO' STYLE OF PLAYING AND PRODUCES A FLUTE-LIKE TONE
;	THESE SUGGESTED SETTINGS FOR krat ARE BASED UPON A CONVENTIONAL PLAYING TECHNIQUE OF A BOWED INSTRUMENT.
;	IF VALUES ARE CHOSEN BEYOND THESE LIMITS OTHER UNCONVENTIONAL SOUNDS ARE POSSIBLE.
;	0 = THE STRING BEING BOWED AT THE NUT (NECK), 1 = THE STRING BEING BOWED AT THE BRIDGE
;	IN ACTUALITY VALUES OF 0 AND 1 WILL PRODUCE SILENCE
;	VALUES CLOSE TO ZERO OR CLOSE TO 1 WILL PRODUCE A THIN, HARD SOUND (BOWED NEAR THE NECK END OR NEAR THE BRIDGE)
;	A VALUE OF .5 WILL PRODUCE A SOFT FLUTEY SOUND (STRING BOWED HALFWAY ALONG ITS LENGTH)

;kvibf/kvibamp - THIS OPCODE IMPLEMENTS VIBRATO THAT GOES BEYOND JUST FREQUENCY MODULATION AND INCLUDES MODULATION 
;	-UPON SEVERAL OTHER ASPECTS OF THE SOUND INCLUDING AMPLITUDE MODULATION
;	A USEFUL RANGE FOR kvibamp (AMPLITUDE OF VIBRATO) IS 0-.1 WHERE 0=NO VIBRATO AND .1=A LOT OF VIBRATO
;	kvibf IS USED TO CONTROL VIBRATO FREQUENCY, A NATURAL VIBRATYO FREQUENCY IS ABOUT 5 HZ

;ifn - A FUNCTION TABLE WAVEFORM MUST BE GIVEN TO DEFINE THE SHAPE OF THE VIBRATO, 
;	-THIS SHOULD NORMALLY BE A SINE WAVE.

;THE OPCODE OFFERS 1 FURTHER *OPTIONAL* PARAMETER:

;iminfreq - A MINIMUM FREQUENCY SETTING GIVEN TO THE ALGORITHM
;	- TYPICALLY THIS IS SET TO A VALUE BELOW THE FREQUENCY SETTING GIVEN BY kfreq (IF OMITTED IT DEFAULTS TO 50HZ)
;	- IF kfreq GOES BELOW iminfreq THE SETTING FOR kfreq NO LONGER REFLECTS THE PITCH THAT IS ACTUALLY HEARD.


;Modified for QuteCsound by René, March 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add tables for exp slider
;	INIT instrument added


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine	ftgen	0, 0, 4096, 10, 1						;SINE WAVE (USED FOR VIBRATO)
giExp1	ftgen	0, 0, 129, -25, 0, 20.0, 128, 4000.0		;TABLE FOR EXP SLIDER
giExp2	ftgen	0, 0, 129, -25, 0, 0.01, 128, 90.0			;TABLE FOR EXP SLIDER
giExp3	ftgen	0, 0, 129, -25, 0, 20.0, 128, 20000.0		;TABLE FOR EXP SLIDER


instr	2	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkamp		invalue	"Amp"
		kfreq		invalue	"Freq"
		gkfreq		tablei	kfreq, giExp1, 1
					outvalue	"Freq_Value", gkfreq
		kpres		invalue	"BowPress"
		gkpres		tablei	kpres, giExp2, 1
					outvalue	"BowPress_Value", gkpres
		gkrat		invalue	"BowPos"
		gkvibf		invalue	"VibFreq"
		gkvibamp		invalue	"VibAmp"
		kminfreq		invalue	"MinFreq"
		gkminfreq		tablei	kminfreq, giExp3, 1
					outvalue	"MinFreq_Value", gkminfreq
	endif
endin

instr	1	;MIDI ACTIVATED INSTRUMENT
	ioct		octmidi											;READ NOTE VALUES FROM MIDI INPUT IN THE 'OCT' FORMAT
	iamp		ampmidi	1										;AMPLITUDE IS READ FROM INCOMING MIDI NOTE

	;kpres	aftouch	1, 5										;AFTERTOUCH CONTROL OF BOW PRESSURE
	;kpres	ctrl7	1, 1, 1, 5								;MOD. WHEEL CONTROL OF BOW PRESSURE
	kpres	=	gkpres

	;PITCH BEND INFORMATION IS READ
	iSemitoneBendRange=	2										;PITCH BEND RANGE IN SEMITONES (WILL BE DEFINED FURTHER LATER)
	imin 	=		0										;EQUILIBRIUM POSITION
	imax		=		iSemitoneBendRange * .0833333					;MAX PITCH DISPLACEMENT (IN oct FORMAT)
	kbend	pchbend	imin, imax								;PITCH BEND VARIABLE (IN oct FORMAT)
	kfreq	=		cpsoct(ioct+ kbend)

	aenv		linsegr	1, 3600, 1, 0.01, 0							;ANTI-CLICK ENVELOPE
	abow		wgbow	gkamp*iamp, kfreq, kpres, gkrat, gkvibf, gkvibamp, gisine, i(gkminfreq)
			outs		abow * aenv, abow * aenv						;SEND AUDIO TO OUTPUTS
endin

instr	3	;GUI TRIGGERED INSTRUMENT
	kSwitch	changed	gkminfreq									;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then
		reinit	START
	endif

	iporttime	=		0.01
	kporttime	linseg	0, 0.01, iporttime, 1, iporttime
	krat		portk	gkrat, kporttime
	kpres	portk	gkpres, kporttime
	kfreq	portk	gkfreq, kporttime
	START:
	abow		wgbow	gkamp, kfreq, kpres, krat, gkvibf, gkvibamp, gisine, i(gkminfreq)
			rireturn
			outs 	abow, abow
endin

instr	4	;INIT
		outvalue	"Amp"	, 0.3
		outvalue	"Freq"	, 0.404
		outvalue	"BowPress", 0.6264
		outvalue	"BowPos"	, .127236
		outvalue	"VibFreq"	, 4.5
		outvalue	"VibAmp"	, .008
		outvalue	"MinFreq"	, 0.0
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION 
i 2		0		3600	;GUI
i 4		0		0.1	;INIT
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>551</x>
 <y>302</y>
 <width>1020</width>
 <height>384</height>
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
  <height>380</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wgbow</label>
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
  <y>76</y>
  <width>220</width>
  <height>30</height>
  <uuid>{640b50b7-7200-4f81-8394-89d9843ae939}</uuid>
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
  <objectName>Amp</objectName>
  <x>8</x>
  <y>54</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.30000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amp</objectName>
  <x>448</x>
  <y>76</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b731b52e-e14a-476a-a583-f3b2bd885539}</uuid>
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
  <x>515</x>
  <y>2</y>
  <width>500</width>
  <height>380</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wgbow</label>
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
  <x>518</x>
  <y>25</y>
  <width>493</width>
  <height>348</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------------
wgbow is a wave guide physical model of a bowed string based on work by Perry Cook but re-coded for Csound by John ffitch. Bow pressure represents the downward pressure of the bow upon the string and should be a value between 1 and 5. The author suggests a value of about 3 to represent normal bow pressure. Bow position represents the position of the bow along the length of the string. Bow position represents the position of the bow along the length of the string. The opcode author suggests that we choose values within the range .025 to 0.23. He also suggests that a value of .127236 reflects a normal bowing position. String effects such as 'sul ponticello' (at the bridge) and 'flautando' (over the neck) can be imitated using this parameter. A value of .025 reflects a 'sul ponticello' style of playing and produces a thinner tone. A value of .23 reflects a 'flautando' style of playing and produces a flute-like tone. Vibrato is implemented within the opcode and does not need to be applied separately to the frequency parameter. Vibrato is implemented so that it only takes effect after a short time delay. This time delay is retriggered if bow position is changed during note performance. Minimum frequency (optional) defines the lowest frequency at which the model will play. This example can also be triggered via MIDI. MIDI note number, velocity and pitch bend are interpreted appropriately.</label>
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
  <objectName/>
  <x>8</x>
  <y>16</y>
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
  <eventLine>i 3 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>121</y>
  <width>220</width>
  <height>30</height>
  <uuid>{6e0c35ca-d489-456c-a3c8-7b02cf334c36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency</label>
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
  <objectName>Freq</objectName>
  <x>8</x>
  <y>99</y>
  <width>500</width>
  <height>27</height>
  <uuid>{28514f48-2718-4dab-b43c-78c3cc4fba09}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.40400001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Freq_Value</objectName>
  <x>448</x>
  <y>121</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1ad30bb1-9a2f-461a-bf9e-cc7cc6c9d678}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>170.107</label>
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
  <y>166</y>
  <width>220</width>
  <height>30</height>
  <uuid>{b6d928a2-0d92-4eaa-b1e8-9f3091c5794c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bow Pressure</label>
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
  <objectName>BowPress</objectName>
  <x>8</x>
  <y>144</y>
  <width>500</width>
  <height>27</height>
  <uuid>{49a6777a-6ac7-430b-b827-547dc2686e49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.62639999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>BowPress_Value</objectName>
  <x>448</x>
  <y>166</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fca8b154-9112-4b23-8054-469dafd66230}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3.000</label>
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
  <y>211</y>
  <width>220</width>
  <height>30</height>
  <uuid>{55089f0d-6978-4aca-b682-ae666b30683e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bow Position</label>
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
  <objectName>BowPos</objectName>
  <x>8</x>
  <y>189</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3439fd43-d6bf-41ba-88ab-efcbcda0122c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00600000</minimum>
  <maximum>0.98800000</maximum>
  <value>0.12723599</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>BowPos</objectName>
  <x>448</x>
  <y>211</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d78b9853-b96c-4bc2-a2d5-375b6a4869ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.127</label>
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
  <y>256</y>
  <width>220</width>
  <height>30</height>
  <uuid>{d8273459-fbc3-40c2-b202-003f954906f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vibrato Frequency</label>
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
  <objectName>VibFreq</objectName>
  <x>8</x>
  <y>234</y>
  <width>500</width>
  <height>27</height>
  <uuid>{ab819133-79c9-448f-a33b-8cbd65c8d6af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>30.00000000</maximum>
  <value>4.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>VibFreq</objectName>
  <x>448</x>
  <y>256</y>
  <width>60</width>
  <height>30</height>
  <uuid>{22ea767e-1d44-46df-a57d-1b39aeeeaa04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.500</label>
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
  <y>301</y>
  <width>220</width>
  <height>30</height>
  <uuid>{eb9ca396-c5b9-439b-a2d6-173005d43519}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vibrato Amplitude</label>
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
  <objectName>VibAmp</objectName>
  <x>8</x>
  <y>279</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8efddf99-5c6c-4272-8941-b63cbfa97d8e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.00800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>VibAmp</objectName>
  <x>448</x>
  <y>301</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f23ee963-c062-4762-86c4-6695f28e2b01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.008</label>
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
  <y>346</y>
  <width>220</width>
  <height>30</height>
  <uuid>{d6cb8f92-de61-422f-8766-540c72a00b8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Minimum Frequency (i-rate and optional)</label>
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
  <objectName>MinFreq</objectName>
  <x>8</x>
  <y>324</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d9ea8c83-8cee-4e8f-b828-e50fd40cfd3d}</uuid>
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
  <objectName>MinFreq_Value</objectName>
  <x>448</x>
  <y>346</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f4fdaa52-b84c-445a-8710-7a2a6df4c1ad}</uuid>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

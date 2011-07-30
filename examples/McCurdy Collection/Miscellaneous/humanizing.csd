;Written by Iain McCurdy, 2011


;Modified for QuteCsound by René, May 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add tables for exp slider
;	Changed max value of gkgaussCPS 0.4*kr, QuteCsound freeze if gkgaussCPS = 0.5*kr


;	Humanizing
;	--------------------------------------------------------------------------------------------------------------------------
;	'Humanizing' refers to the practice of adding a random, varying or jitter element to an otherwise static or predictable
;	function in an attempt to render the performance of that function to better resemble the performance of a human musician.
;	A number of opcodes are introduced which can be used for this purpose. In all cases the output of each of these opcodes
;	are applied to the frequency parameter of a sine tone oscillator so that their performance can be assessed. The input
;	parameters for each opcode are accesed using the FL tabs in the lower half of the interface. Each opcode (mode of
;	modulation) can be activated or deactivated using its own switch. Any number of modulation sources can be combined
;	simultaneously.
;	For details of the operation of each of the opcodes covered, vibr, vibrato, jitter, jitter2, jspline and gauss, I refer
;	to the Csound Manual (http://www.csounds.com/manual/html/index.html) for greater detail than could be covered here.
;	'vibrato' is an opcode intended to emulate expressive pitch modulation better than a simple sine wave LFO. It makes use of
	;many input parameters so a simplified version 'vibr' was created which uses hardwired settings for most of 'vibrato''s
;	parameters. 'jitter' and 'jitter2' generate random straight line functions. 'Jitter2' is more complex than 'Jitter' and
;	demands a greater number of input arguments. 'rsspline' generates a random function based on spline curves, this can
;	provide more natural sounding results than those possible with 'jitter' or 'jitter2' (see also 'jspline'). The final
;	possibility is based upon a gaussian noise generator. The function output is processed using 'samphold' (sample and hold)
;	and interpolation to provide controllable rate jitter with smooth changes between values. It might also be worth exploring"
;	some of Csound's other noise generators.


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 10		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine	ftgen	0,0,1024,10,1						;SINE TABLE	
giExp1	ftgen	0, 0, 129, -25, 0, 100.0, 128, 5000.0	;TABLE FOR EXP SLIDER
giExp2	ftgen	0, 0, 129, -25, 0, 0.01, 128, 100.0	;TABLE FOR EXP SLIDER
giExp3	ftgen	0, 0, 129, -25, 0, 0.01, 128, 0.4*kr	;TABLE FOR EXP SLIDER



instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		kToneFrq			invalue	"ToneFreq"
		gkToneFrq			tablei	kToneFrq, giExp1, 1
						outvalue	"ToneFreq_Value", gkToneFrq
		;vibr
		gkvibrOnOff		invalue	"vibr"
		gkvibrAmp			invalue	"vibrAmp"
		gkvibrFrq			invalue	"vibrFreq"
		;vibrato
		gkvibratoOnOff		invalue	"vibrato"
		gkvibratoAvAmp		invalue	"vibratoAmp"
		gkvibratoAvFrq		invalue	"vibratoFreq"
		gkvibratoRndAmp	invalue	"vibratoRndAmp"
		gkvibratoRndFrq	invalue	"vibratoRndFreq"
		gkvibratoAmpMinRate	invalue	"vibratoAmpMinRate"
		gkvibratoAmpMaxRate	invalue	"vibratoAmpMaxRate"
		gkvibratocpsMinRate	invalue	"vibratoCPSMinRate"
		gkvibratocpsMaxRate	invalue	"vibratoCPSMaxRate"
		;jitter
		gkjitterOnOff		invalue	"jitter"
		gkjitterAmp		invalue	"jitterAmp"
		gkjitterCpsmin		invalue	"jitterCPSMin"
		gkjitterCpsmax		invalue	"jitterCPSMax"
		;jitter2
		gkjitter2OnOff		invalue	"jitter2"
		gkjitter2Totamp	invalue	"jitter2TotAmp"
		gkjitter2Amp1		invalue	"jitter2Amp1"
		kjitter2Cps1		invalue	"jitter2CPS1"
		gkjitter2Cps1		tablei	kjitter2Cps1, giExp2, 1
						outvalue	"jitter2CPS1_Value", gkjitter2Cps1
		gkjitter2Amp2		invalue	"jitter2Amp2"
		kjitter2Cps2		invalue	"jitter2CPS2"
		gkjitter2Cps2		tablei	kjitter2Cps2, giExp2, 1
						outvalue	"jitter2CPS2_Value", gkjitter2Cps2
		gkjitter2Amp3		invalue	"jitter2Amp3"
		kjitter2Cps3		invalue	"jitter2CPS3"
		gkjitter2Cps3		tablei	kjitter2Cps3, giExp2, 1
						outvalue	"jitter2CPS3_Value", gkjitter2Cps3
		;jspline
		gkjsplineOnOff		invalue	"jspline"
		gkjsplineAmp		invalue	"jsplineAmp"
		kjsplineCpsMin		invalue	"jsplineCPSMin"
		gkjsplineCpsMin	tablei	kjsplineCpsMin, giExp2, 1
						outvalue	"jsplineCPSMin_Value", gkjsplineCpsMin
		kjsplineCpsMax		invalue	"jsplineCPSMax"
		gkjsplineCpsMax	tablei	kjsplineCpsMax, giExp2, 1
						outvalue	"jsplineCPSMax_Value", gkjsplineCpsMax
		;gauss
		gkgaussOnOff		invalue	"gauss"
		gkgaussAmp		invalue	"gaussAmp"
		kgaussCPS			invalue	"gaussCPS"						;range 0.01 to kr/2
		gkgaussCPS		tablei	kgaussCPS, giExp3, 1
						outvalue	"gaussCPS_Value", gkgaussCPS
	endif
endin

instr	1	;PLAYS
	kporttime	linseg	0,0.001,0.03									;A FUNCTION THAT RAMPS UP FROM ZERO THAT WILL BE USED TO DEFINE PORTAMENTO TIME
	kToneFrq	portk	gkToneFrq, kporttime							;PORTAMENTO SMOOTHING APPLIED TO THE TONE GENERATOR FREQUENCY CONTROL 

	;vibr
	if gkvibrOnOff=1	then											;IF 'vibr' BUTTON IS 'ON'...
		;KOUT	VIBR	KAVERAGEAMP | KAVERAGEFREQ | IFNFLGROUPEND
		kvibr	vibr	gkvibrAmp,     gkvibrFrq,     gisine				;CREATE A RANDOM FUNCTION USING vibr
		kToneFrq	=	kToneFrq * (1+kvibr)							;OFFSET FUNCTION BY +1 AND MULTIPLY TO TONE GENERATOR FREQUENCY CONTROL
	endif
	
	;vibrato
	if gkvibratoOnOff=1	then											;IF 'vibrato' BUTTON IS 'ON'...
		;KOUT	VIBRATO	KAVERAGEAMP    | KAVERAGEFREQ | KRANDAMOUNTAMP | KRANDAMOUNTFREQ |     KAMPMINRATE    |   KAMPMAXRATE       |     KCPSMINRATE    |   KCPSMAXRATE      |IFN
		kvibrato	vibrato	gkvibratoAvAmp, gkvibratoAvFrq, gkvibratoRndAmp, gkvibratoRndFrq, gkvibratoAmpMinRate,  gkvibratoAmpMaxRate, gkvibratocpsMinRate, gkvibratocpsMaxRate, 	gisine	;CREATE A RANDOM FUNCTION USING vibrato                                  
		kToneFrq	=		kToneFrq * (1+kvibrato)						;OFFSET FUNCTION BY +1 AND MULTIPLY TO TONE GENERATOR FREQUENCY CONTROL
	endif

	;jitter
	if gkjitterOnOff=1	then											;IF 'jitter' BUTTON IS 'ON'...
		;KOUT	JITTER 	KAMP        |    KCPSMIN    |   KCPSMAX
		kjitter	jitter	gkjitterAmp, gkjitterCpsmin, gkjitterCpsmax		;CREATE A RANDOM FUNCTION USING jitter                                  
		kToneFrq	=		kToneFrq * (1+kjitter)          			  	;OFFSET FUNCTION BY +1 AND MULTIPLY TO TONE GENERATOR FREQUENCY CONTROL
	endif

	;jitter2
	if gkjitter2OnOff=1	then											;IF 'jitter2' BUTTON IS 'ON'...
		;KOUT	JITTER2	KTOTAMP         |    KAMP1     |    KCPS1     |   KAMP2      |   KCPS2      |    KAMP3     |   KCPS3
		kjitter2	jitter2	gkjitter2Totamp, gkjitter2Amp1, gkjitter2Cps1, gkjitter2Amp2, gkjitter2Cps2, gkjitter2Amp3, gkjitter2Cps3	;CREATE A RANDOM FUNCTION USING jitter2                                   
		kToneFrq	=		kToneFrq * (1+kjitter2)						;OFFSET FUNCTION BY +1 AND MULTIPLY TO TONE GENERATOR FREQUENCY CONTROL
	endif

	;jspline
	if gkjsplineOnOff=1	then											;IF 'jspline' BUTTON IS 'ON'...
		;KOUT	RSPLINE	AMPLITUDE    |    KCPSMIN     |   KCPSMAX
		kjspline	jspline	gkjsplineAmp, gkjsplineCpsMin, gkjsplineCpsMax	;CREATE A RANDOM FUNCTION USING jspline                                   
		kToneFrq	=		kToneFrq * (1+kjspline)						;OFFSET FUNCTION BY +1 AND MULTIPLY TO TONE GENERATOR FREQUENCY CONTROL
	endif

	;gauss
	if gkgaussOnOff=1	then											;IF 'gauss' BUTTON IS 'ON'...
		kgauss	gauss	gkgaussAmp								;GENERATE GAUSSIAN NOISE (FREQUENCY IS EQUAL TO kr/CONTROL RATE)
		kmetro	metro	gkgaussCPS								;CREATE A METRONOME THAT WILL BE USED TO DOWNSAMPLE GAUSSSIAN NOISE FUNCTION
		kgauss	samphold	kgauss, kmetro								;SAMPLE AND HOLD GAUSSIAN NOISE FUNCTION
		kgauss	lineto	kgauss, 1/gkgaussCPS						;INTERPOLATE BETWEEN SAMPLE AND HOLD CYCLES
		kToneFrq	=		kToneFrq * (1+kgauss)						;OFFSET FUNCTION BY +1 AND MULTIPLY TO TONE GENERATOR FREQUENCY CONTROL 
	endif														;END OF THIS CONDITIONAL BRANCH
	
	aenv		linsegr	0,0.02,0.3,0.02,0								;CREATE AN AMPLITUDE ENVELOPE THAT WILL BE USED TO PREVENT CLICKS AT THE BEGINNING AND THE END OF NOTES
	a1		poscil	aenv, kToneFrq, gisine							;CREATE AN AUDIO SINE TONE USING CSOUND'S PRECISION OSCILLATOR
			outs		a1, a1										;SEND AUDIO TO OUTPUTS
endin

instr	11	;INIT
	outvalue	"ToneFreq"		, 0.4115
	;vibr
	outvalue	"vibrAmp"			, 0.01
	outvalue	"vibrFreq"		, 4.0
	;vibrato
	outvalue	"vibratoAmp"		, 0.01
	outvalue	"vibratoFreq"		, 4.0
	outvalue	"vibratoRndAmp"	, 1.0
	outvalue	"vibratoRndFreq"	, 0.2
	outvalue	"vibratoAmpMinRate"	, 0.5
	outvalue	"vibratoAmpMaxRate"	, 1.0
	outvalue	"vibratoCPSMinRate"	, 0.5
	outvalue	"vibratoCPSMaxRate"	, 1.0
	;jitter
	outvalue	"jitterAmp"		, 0.01
	outvalue	"jitterCPSMin"		, 4.0
	outvalue	"jitterCPSMax"		, 8.0
	;jitter2
	outvalue	"jitter2TotAmp"	, 0.04
	outvalue	"jitter2Amp1"		, 0.2
	outvalue	"jitter2CPS1"		, 0.726
	outvalue	"jitter2Amp2"		, 0.25
	outvalue	"jitter2CPS2"		, 0.345
	outvalue	"jitter2Amp3"		, 1.0
	outvalue	"jitter2CPS3"		, 0.2499
	;jspline
	outvalue	"jsplineAmp"		, 0.01
	outvalue	"jsplineCPSMin"	, 0.651
	outvalue	"jsplineCPSMax"	, 0.726
	;gauss
	outvalue	"gaussAmp"		, 0.015
	outvalue	"gaussCPS"		, 0.572
endin
</CsInstruments>
<CsScore>
i 10 0 3600	;GUI
i 11 0 0.01	;init
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>774</x>
 <y>151</y>
 <width>838</width>
 <height>774</height>
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
  <width>836</width>
  <height>772</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Humanizing</label>
  <alignment>left</alignment>
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
  <x>8</x>
  <y>65</y>
  <width>410</width>
  <height>391</height>
  <uuid>{c9ed7f8a-f31c-4ba6-a0c4-76514bb500cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>vibrato</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>120</y>
  <width>200</width>
  <height>30</height>
  <uuid>{bb648d86-36d4-4547-b828-3127a41cd30c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Average Amplitude</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vibratoAmp</objectName>
  <x>13</x>
  <y>99</y>
  <width>400</width>
  <height>27</height>
  <uuid>{bedc2c77-13fd-4ebc-969f-bf56187e0231}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.20000000</maximum>
  <value>0.01000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>vibratoAmp</objectName>
  <x>353</x>
  <y>120</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0e565e9a-eab6-4218-adde-6577d1a9254c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.010</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>13</x>
  <y>163</y>
  <width>200</width>
  <height>30</height>
  <uuid>{e8f18fc7-d5e0-4b14-a79a-408581fde3de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Average Frequency</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vibratoFreq</objectName>
  <x>13</x>
  <y>142</y>
  <width>400</width>
  <height>27</height>
  <uuid>{39bb3497-e71c-412d-ac87-6b6899c5bb35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>4.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>vibratoFreq</objectName>
  <x>353</x>
  <y>163</y>
  <width>60</width>
  <height>30</height>
  <uuid>{97bfca64-32ca-47e9-a55b-e174496122e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>13</x>
  <y>206</y>
  <width>200</width>
  <height>30</height>
  <uuid>{c5fabb47-c80c-4ee2-bbc4-cbea821ae4dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Random Amp Amount</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vibratoRndAmp</objectName>
  <x>13</x>
  <y>185</y>
  <width>400</width>
  <height>27</height>
  <uuid>{33867e18-c4c3-41cd-977e-1376f7496444}</uuid>
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
  <objectName>vibratoRndAmp</objectName>
  <x>353</x>
  <y>206</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fb9c8670-3590-47f4-a338-e02e163f3d99}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>13</x>
  <y>250</y>
  <width>200</width>
  <height>30</height>
  <uuid>{c4f57d4f-2271-4daf-9d46-bc7e5d857cdb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Random Freq Amount</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vibratoRndFreq</objectName>
  <x>13</x>
  <y>229</y>
  <width>400</width>
  <height>27</height>
  <uuid>{eaf9b183-0d5a-4a2b-bb90-12c8b5568188}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>vibratoRndFreq</objectName>
  <x>353</x>
  <y>250</y>
  <width>60</width>
  <height>30</height>
  <uuid>{29bbe495-e5de-4351-bf19-572b1fe45fcb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.200</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>13</x>
  <y>294</y>
  <width>200</width>
  <height>30</height>
  <uuid>{505e8f5d-bfdf-44ee-918f-9ab44c8c6334}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp Minimum Rate</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vibratoAmpMinRate</objectName>
  <x>13</x>
  <y>273</y>
  <width>400</width>
  <height>27</height>
  <uuid>{d9e31b75-adff-4643-99a7-dcdbac985ea0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>vibratoAmpMinRate</objectName>
  <x>353</x>
  <y>294</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ed6a0335-c99c-4b19-8311-2c857065bab7}</uuid>
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
  <x>13</x>
  <y>338</y>
  <width>200</width>
  <height>30</height>
  <uuid>{306337fd-66dc-4c08-9d2a-8254848490d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp Maximum Rate</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vibratoAmpMaxRate</objectName>
  <x>13</x>
  <y>317</y>
  <width>400</width>
  <height>27</height>
  <uuid>{43b9af7e-7ee3-4b71-8ec9-2da95fee708b}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>vibratoAmpMaxRate</objectName>
  <x>353</x>
  <y>338</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e760387e-366f-4fb5-95fd-4934840f2d1b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>13</x>
  <y>382</y>
  <width>200</width>
  <height>30</height>
  <uuid>{f6704a95-a620-405d-9b6e-fecd64332fc2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS Minimum Rate</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vibratoCPSMinRate</objectName>
  <x>13</x>
  <y>361</y>
  <width>400</width>
  <height>27</height>
  <uuid>{f7f2561c-e159-40db-89d5-213a31b41889}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>vibratoCPSMinRate</objectName>
  <x>353</x>
  <y>382</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9f0dcc2d-f639-40e7-89e6-09a9dcea8144}</uuid>
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
  <x>13</x>
  <y>425</y>
  <width>200</width>
  <height>30</height>
  <uuid>{cab92aa0-01a2-4c01-8355-9b3615230a95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS Maximum Rate</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vibratoCPSMaxRate</objectName>
  <x>13</x>
  <y>404</y>
  <width>400</width>
  <height>27</height>
  <uuid>{0609dc0f-1334-49bd-a0d4-e96a4db71767}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>vibratoCPSMaxRate</objectName>
  <x>353</x>
  <y>425</y>
  <width>60</width>
  <height>30</height>
  <uuid>{08145bd2-3952-4d99-891b-18bab7f45773}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>8</x>
  <y>460</y>
  <width>410</width>
  <height>172</height>
  <uuid>{a4b6475f-7308-4645-9bf4-5158554233b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>jitter</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>515</y>
  <width>200</width>
  <height>30</height>
  <uuid>{c641833f-4bca-428b-a8a3-94bed0cfbd9c}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jitterAmp</objectName>
  <x>13</x>
  <y>494</y>
  <width>400</width>
  <height>27</height>
  <uuid>{14fc414a-b11d-4652-b748-125461ffcdc9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.20000000</maximum>
  <value>0.01000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jitterAmp</objectName>
  <x>353</x>
  <y>515</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7bd3f618-c0a2-4949-b2a7-d6807a25e20c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.010</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>13</x>
  <y>558</y>
  <width>200</width>
  <height>30</height>
  <uuid>{91e51702-8aba-4ee5-8066-ec984c9dbf7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS Minimum</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jitterCPSMin</objectName>
  <x>13</x>
  <y>537</y>
  <width>400</width>
  <height>27</height>
  <uuid>{9a4b1622-2286-46b2-8c40-5ddcc7b4c283}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>4.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jitterCPSMin</objectName>
  <x>353</x>
  <y>558</y>
  <width>60</width>
  <height>30</height>
  <uuid>{83f06650-99e6-4c62-beeb-41779dc0ae4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>13</x>
  <y>601</y>
  <width>200</width>
  <height>30</height>
  <uuid>{ea1e7f26-097d-4771-bf13-b2813e14ded5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS Maximum</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jitterCPSMax</objectName>
  <x>13</x>
  <y>580</y>
  <width>400</width>
  <height>27</height>
  <uuid>{93adccfc-80aa-4b6e-b872-b4ffdc09f267}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>8.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jitterCPSMax</objectName>
  <x>353</x>
  <y>601</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f3c5d0ec-158f-47d3-92b9-6ee167ee9217}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>421</x>
  <y>65</y>
  <width>410</width>
  <height>391</height>
  <uuid>{e1304016-25b0-4d90-88fa-804e7edc58f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>jitter2</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>426</x>
  <y>120</y>
  <width>200</width>
  <height>30</height>
  <uuid>{30f72e67-ae43-4380-9755-a11399f72e90}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Total Amplitude</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jitter2TotAmp</objectName>
  <x>426</x>
  <y>99</y>
  <width>400</width>
  <height>27</height>
  <uuid>{b261eed3-bd1f-4e16-aa45-95c1d3e4847e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.04000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jitter2TotAmp</objectName>
  <x>766</x>
  <y>120</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1c84f4b4-60a6-40df-a87a-5fcc5e0128f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.040</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>426</x>
  <y>163</y>
  <width>200</width>
  <height>30</height>
  <uuid>{d273c022-b9f9-4b5e-bca4-01142aa17c04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude 1</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jitter2Amp1</objectName>
  <x>426</x>
  <y>142</y>
  <width>400</width>
  <height>27</height>
  <uuid>{6330b9f6-ccf8-491f-8e7d-ac64e9120ef1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jitter2Amp1</objectName>
  <x>766</x>
  <y>163</y>
  <width>60</width>
  <height>30</height>
  <uuid>{09ed5fca-bc46-41c4-87ba-4ff60bac8edb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.200</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>426</x>
  <y>206</y>
  <width>200</width>
  <height>30</height>
  <uuid>{ad8a1bf7-9542-48e6-910f-fa6cc2c4672c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS 1</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jitter2CPS1</objectName>
  <x>426</x>
  <y>185</y>
  <width>400</width>
  <height>27</height>
  <uuid>{e1366594-680e-4df5-9325-d9d8feb34998}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.72600001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jitter2CPS1_Value</objectName>
  <x>766</x>
  <y>206</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e400b07c-538b-4ca8-b8bf-e9b571c3ab9f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.018</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>426</x>
  <y>250</y>
  <width>200</width>
  <height>30</height>
  <uuid>{a0f67548-5d59-4c6d-a884-376c8c472c0f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude 2</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jitter2Amp2</objectName>
  <x>426</x>
  <y>229</y>
  <width>400</width>
  <height>27</height>
  <uuid>{af142550-a1db-40d9-8c36-edcf7f9f50ff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.25000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jitter2Amp2</objectName>
  <x>766</x>
  <y>250</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d19532ad-3830-4989-8d7c-f4203b11b554}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.250</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>426</x>
  <y>294</y>
  <width>200</width>
  <height>30</height>
  <uuid>{f7541039-2e3a-421f-9414-768b73f9ec3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS 2</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jitter2CPS2</objectName>
  <x>426</x>
  <y>273</y>
  <width>400</width>
  <height>27</height>
  <uuid>{3b8a358c-9899-41f5-8bab-792795af723d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.34500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jitter2CPS2_Value</objectName>
  <x>766</x>
  <y>294</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e5301700-92b0-4ccd-99f6-15f9d47de795}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.240</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>426</x>
  <y>338</y>
  <width>200</width>
  <height>30</height>
  <uuid>{677d25ad-269e-420f-a9ad-50f021c1d35d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude 3</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jitter2Amp3</objectName>
  <x>426</x>
  <y>317</y>
  <width>400</width>
  <height>27</height>
  <uuid>{6137d76d-6d46-4d69-a383-5e692dc5d675}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jitter2Amp3</objectName>
  <x>766</x>
  <y>338</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1db59ed8-7a46-4662-b127-03ac68e4668a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>426</x>
  <y>382</y>
  <width>200</width>
  <height>30</height>
  <uuid>{93eaef47-6002-4097-ba51-91ec03702114}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS 3</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jitter2CPS3</objectName>
  <x>426</x>
  <y>361</y>
  <width>400</width>
  <height>27</height>
  <uuid>{66db3cd4-379a-4b7c-a9b0-1a4bf0bfaad7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.24990000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jitter2CPS3_Value</objectName>
  <x>766</x>
  <y>382</y>
  <width>60</width>
  <height>30</height>
  <uuid>{65a90057-08ee-42bc-a507-70d3e0227ee5}</uuid>
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
  <x>421</x>
  <y>460</y>
  <width>410</width>
  <height>172</height>
  <uuid>{c8a49138-0573-45ec-9a9d-e74dcb0ab8b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>jspline</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>426</x>
  <y>515</y>
  <width>200</width>
  <height>30</height>
  <uuid>{48a75d82-11e7-4c1e-851e-002166bd6c10}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jsplineAmp</objectName>
  <x>426</x>
  <y>494</y>
  <width>400</width>
  <height>27</height>
  <uuid>{6ad15099-991d-4ff0-b3c5-83c2ea80b2d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.01000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jsplineAmp</objectName>
  <x>766</x>
  <y>515</y>
  <width>60</width>
  <height>30</height>
  <uuid>{325de495-ae37-411f-8f45-6c3248a7452d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.010</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>426</x>
  <y>558</y>
  <width>200</width>
  <height>30</height>
  <uuid>{ce278c4f-6315-4b0e-8150-a2dc2f81a901}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS Minimum</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jsplineCPSMin</objectName>
  <x>426</x>
  <y>537</y>
  <width>400</width>
  <height>27</height>
  <uuid>{1967bb61-cc5a-4556-b39d-8d9913626811}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.65100002</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jsplineCPSMin_Value</objectName>
  <x>766</x>
  <y>558</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1b26e224-0165-438a-8ce3-e42c23a003e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.020</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>426</x>
  <y>601</y>
  <width>200</width>
  <height>30</height>
  <uuid>{066c75b0-1458-4540-b7ce-fd4651901351}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS Maximum</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>jsplineCPSMax</objectName>
  <x>426</x>
  <y>580</y>
  <width>400</width>
  <height>27</height>
  <uuid>{ba4eefde-1e14-4618-9c19-bd834d864776}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.72600001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>jsplineCPSMax_Value</objectName>
  <x>766</x>
  <y>601</y>
  <width>60</width>
  <height>30</height>
  <uuid>{41c3bf48-263a-4d78-a476-466b88d405c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.018</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>421</x>
  <y>636</y>
  <width>410</width>
  <height>130</height>
  <uuid>{540f5746-4f2a-4f0d-b895-9c7134d0fb69}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>gauss</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>426</x>
  <y>691</y>
  <width>200</width>
  <height>30</height>
  <uuid>{d4052ff1-a207-4a6b-8133-d17642cd9df5}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>gaussAmp</objectName>
  <x>426</x>
  <y>670</y>
  <width>400</width>
  <height>27</height>
  <uuid>{d0e7b623-36b0-4b0e-a9f8-14c7621e97b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.01500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>gaussAmp</objectName>
  <x>766</x>
  <y>691</y>
  <width>60</width>
  <height>30</height>
  <uuid>{85a86775-23c7-4887-97a3-471a06155a43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.015</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>426</x>
  <y>734</y>
  <width>200</width>
  <height>30</height>
  <uuid>{d967b23e-76ac-467f-b6e1-97945f0d908a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>gaussCPS</objectName>
  <x>426</x>
  <y>713</y>
  <width>400</width>
  <height>27</height>
  <uuid>{df25099a-4b82-4467-ae68-03c65d56c93e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.57200003</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>gaussCPS_Value</objectName>
  <x>766</x>
  <y>734</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d60ee55f-ad28-4de5-a8f2-b6aab1418d60}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10.031</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <objectName>jitter2</objectName>
  <x>552</x>
  <y>73</y>
  <width>16</width>
  <height>16</height>
  <uuid>{f3354a0b-966f-47cd-a77d-45906c2dfb9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>479</x>
  <y>71</y>
  <width>68</width>
  <height>28</height>
  <uuid>{847c3bd2-acc5-4d54-8e40-56bf45102f39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On / Off</label>
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
  <objectName>jitter</objectName>
  <x>140</x>
  <y>469</y>
  <width>16</width>
  <height>16</height>
  <uuid>{63543c8a-41fc-4812-ac2c-e40da4d87824}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>67</x>
  <y>467</y>
  <width>68</width>
  <height>28</height>
  <uuid>{b74b65d4-06ff-4012-b190-9dc8c280e652}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On / Off</label>
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
  <objectName>vibrato</objectName>
  <x>139</x>
  <y>74</y>
  <width>16</width>
  <height>16</height>
  <uuid>{b3e6c810-b176-497e-90c1-f78797f774e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>66</x>
  <y>72</y>
  <width>68</width>
  <height>28</height>
  <uuid>{98c27a60-f7cb-4431-b713-8f30de3050a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On / Off</label>
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
  <objectName>jspline</objectName>
  <x>553</x>
  <y>469</y>
  <width>16</width>
  <height>16</height>
  <uuid>{31718aa5-8525-4c64-99d9-e6f20e258397}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>480</x>
  <y>467</y>
  <width>68</width>
  <height>28</height>
  <uuid>{559e1580-196e-4a1e-a768-a94b62c51755}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On / Off</label>
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
  <objectName>gauss</objectName>
  <x>553</x>
  <y>645</y>
  <width>16</width>
  <height>16</height>
  <uuid>{68892652-6150-4165-9115-4803d10717b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>480</x>
  <y>643</y>
  <width>68</width>
  <height>28</height>
  <uuid>{da0ad73b-1633-4250-8931-6b2e15db98ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On / Off</label>
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
  <x>8</x>
  <y>636</y>
  <width>410</width>
  <height>130</height>
  <uuid>{fb1c7ce5-aca0-4c89-8266-85c870249ea4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>vibr</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>691</y>
  <width>200</width>
  <height>30</height>
  <uuid>{255f434e-3650-4f42-97cc-3768195a1a9f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Average Amplitude</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vibrAmp</objectName>
  <x>13</x>
  <y>670</y>
  <width>400</width>
  <height>27</height>
  <uuid>{573add17-f5f6-4cbe-8dd1-386b3763ddf4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.20000000</maximum>
  <value>0.01000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>vibrAmp</objectName>
  <x>353</x>
  <y>691</y>
  <width>60</width>
  <height>30</height>
  <uuid>{493ca771-e88c-45c4-a506-1aff167bd2c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.010</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>13</x>
  <y>734</y>
  <width>200</width>
  <height>30</height>
  <uuid>{7ff8ee4c-03cb-4798-a1fe-735dbdcd3396}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Average Frequency</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vibrFreq</objectName>
  <x>13</x>
  <y>713</y>
  <width>400</width>
  <height>27</height>
  <uuid>{4c0b0c5a-322c-4b4b-814d-d64bf69b0ae2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>4.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>vibrFreq</objectName>
  <x>353</x>
  <y>734</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c9e5570b-6ee8-45c0-878b-d71b490b5f89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <objectName>vibr</objectName>
  <x>140</x>
  <y>645</y>
  <width>16</width>
  <height>16</height>
  <uuid>{e2311a91-a9f8-4848-b244-f5aa0056385a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>67</x>
  <y>643</y>
  <width>68</width>
  <height>28</height>
  <uuid>{c98eb1dd-dc15-4fb3-8510-c46224afac0e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On / Off</label>
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
  <x>426</x>
  <y>29</y>
  <width>200</width>
  <height>30</height>
  <uuid>{00556a9f-f6b8-4540-808b-efb87d4ed1cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tone Frequency</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>ToneFreq</objectName>
  <x>426</x>
  <y>8</y>
  <width>400</width>
  <height>27</height>
  <uuid>{53439d48-ec1a-4ded-a53e-daae9664ba26}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.41150001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ToneFreq_Value</objectName>
  <x>766</x>
  <y>29</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5aee9d0a-b333-4ac7-b4c0-3d52b5265b9a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>500.230</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>325</x>
  <y>14</y>
  <width>16</width>
  <height>16</height>
  <uuid>{c1966b3f-013d-487b-ba93-c71c4c9a4769}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>239</x>
  <y>12</y>
  <width>80</width>
  <height>28</height>
  <uuid>{69aafe25-0d6e-4e00-8438-8dc329c1fb44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tone On / Off</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

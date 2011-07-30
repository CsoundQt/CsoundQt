;Written by Iain McCurdy, 2011

;Modified for QuteCsound by René, May 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add denorm in reverb instrument
;	Add INIT instrument using QuteCsound Presets system


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 1		;KR MUST EQUAL SR SO THEREFORE KSMPS MUST BE 1
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gaL		init		0
gaR		init		0

giwave	ftgen	1,0,4096,10,1
;TABLES FOR EXP SLIDER
giExp1	ftgen	0, 0, 129, -25, 0, 0.1, 128, 5000.0
giExp2	ftgen	0, 0, 129, -25, 0, 0.01, 128, 2.0
giExp3	ftgen	0, 0, 129, -25, 0, 0.0000001, 128, 0.1


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;SLIDERS
		gkOutGain		invalue	"OutGain"
		kFundMin		invalue	"FundMin"
		gkFundMin		tablei	kFundMin, giExp1, 1
					outvalue	"FundMin_Value", gkFundMin		
		kFundMax		invalue	"FundMax"
		gkFundMax		tablei	kFundMax, giExp1, 1
					outvalue	"FundMax_Value", gkFundMax
		kFundRateMin	invalue	"FundRateMin"
		gkFundRateMin	tablei	kFundRateMin, giExp2, 1
					outvalue	"FundRateMin_Value", gkFundRateMin
		kFundRateMax	invalue	"FundRateMax"
		gkFundRateMax	tablei	kFundRateMax, giExp2, 1
					outvalue	"FundRateMax_Value", gkFundRateMax
		kFundDeReg	invalue	"FundDeReg"
		gkFundDeReg	tablei	kFundDeReg, giExp3, 1
					outvalue	"FundDeReg_Value", gkFundDeReg
		gkFormMin		invalue	"FormMin"
		gkFormMax		invalue	"FormMax"
		gkFormRateMin	invalue	"FormRateMin"
		gkFormRateMax	invalue	"FormRateMax"
		gkFormDeReg	invalue	"FormDeReg"
		gkRvbSnd		invalue	"RvbSend"
		gkRvbTim		invalue	"RvbTime"
		gkAmpModDep	invalue	"AmpModDepth"
		gkPanModDep	invalue	"PanModDepth"

		gkamp1		invalue	"Amp01"
		gkamp2		invalue	"Amp02"
		gkamp3		invalue	"Amp03"
		gkamp4		invalue	"Amp04"
		gkamp5		invalue	"Amp05"
		gkamp6		invalue	"Amp06"
		gkamp7		invalue	"Amp07"
		gkamp8		invalue	"Amp08"
		gkamp9		invalue	"Amp09"
		gkamp10		invalue	"Amp10"
		gkamp11		invalue	"Amp11"
		gkamp12		invalue	"Amp12"
		gkamp13		invalue	"Amp13"
		gkamp14		invalue	"Amp14"
		gkamp15		invalue	"Amp15"
		gkamp16		invalue	"Amp16"
		gkamp17		invalue	"Amp17"
		gkamp18		invalue	"Amp18"
		gkamp19		invalue	"Amp19"
		gkamp20		invalue	"Amp20"
		;COUNTERS 
		gknum		invalue	"NumWavelets" 
	endif
endin

instr	1	; WAVELET GENERATING INSTRUMENT
	;GENERATE A TRIGGER IMPULSE (MOMENTARY '1' VALUE) IN kupdate IF ANY OF THE INPUT ARGUMENTS CHANGE
	kupdate		changed	gkamp1, gkamp2, gkamp3, gkamp6, gkamp5, gkamp6, gkamp7, gkamp8, gkamp9, gkamp10, gkamp11, gkamp12, gkamp13, gkamp14, gkamp15, gkamp16, gkamp17, gkamp18, gkamp19, gkamp20 
	if kupdate=1 then												;IF A TRIGGER IMPULSE HAS BEEN GENERATED...
				reinit	UPDATE									;...BEGIN AN INTIALISATION PASS FROM LABEL 'UPDATE'
		UPDATE:													;LABEL 'UPDATE'
		;CREATE A NEW FUNCTION TABLE TO BE USED BY THE AUDIO OSCILLLATOR IN INSTR 2
		giwave	ftgen	1,0,4096,10,i(gkamp1), i(gkamp2), i(gkamp3), i(gkamp6), i(gkamp5), i(gkamp6), i(gkamp7), i(gkamp8), i(gkamp9), i(gkamp10), i(gkamp11), i(gkamp12), i(gkamp13), i(gkamp14), i(gkamp15), i(gkamp16), i(gkamp17), i(gkamp18), i(gkamp19), i(gkamp20)
				rireturn											;RETURN FROM REINITIALISATION PASS
	endif

	krate	rspline	gkFundMin, gkFundMax, gkFundRateMin, gkFundRateMax	;RATE OF WAVELET GENERATION
	ktrigger	metro	krate										;GENERATE A STREAM OF TRIGGER IMPULSES '1' VALUES OVER A BED OF ZEROES
	koct		rspline	gkFormMin, gkFormMax, gkFormRateMin, gkFormRateMax	;PITCH OF THE WAVEFORM CONTAINED WITHIN THE WAVELET (IN oct FORMAT)
	kFormOS	gauss	gkFormDeReg
	kcps		=		cpsoct(koct+kFormOS)							;CONVERT oct FORMAT VARIABLE TO A cps FORMAT VARIABLE
	kamp		rspline	1-gkAmpModDep, 1, 0.05, 0.1						;AMPLITUDE OF WAVELET TRAIN DEFINED BY A RANDOM SPLINE
	kpan		rspline	0.5-gkPanModDep, 0.5+gkPanModDep, 0.1, 0.2			;PANNING OF WAVELET TRAIN DEFINED BY A RANDOM SPLINE
	kDelay	exprand	gkFundDeReg

	;GENERATE A WAVELET:
	;                                                 	  p4    p5    p6
			schedkwhen ktrigger, 0, 0, 2, kDelay, 0.001, kcps, kamp, kpan	;p3 IS IRRELEVANT AS IT WILL BE DEFINED IN INSTR 2
endin

instr	2	;WAVELET SOUNDING INSTRUMENT
	icps		=		p4
	p3		=		i(gknum)/icps									;NOTE DURATION WILL BE DESCRIBED AS A PRECISE NUMBER OF COMPLETE CYCLES OF THE OSCILLATOR WAVEFORM
	a1		poscil	gkOutGain*p5, icps, giwave
	
	aL,aR	pan2		a1, p6
			outs		aL, aR
	gaL		=		gaL+aL*gkRvbSnd
	gaR		=		gaR+aL*gkRvbSnd
endin

instr	4	;REVERB
				denorm	gaL, gaR
	aRvbL, aRvbR	reverbsc	gaL, gaR, gkRvbTim, 5000
				outs		aRvbL, aRvbR
				clear	gaL, gaR
endin

instr	11	;INIT
		outvalue	"_SetPresetIndex", 0
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI
i 11	     0		0.00		;INIT
i  4		0		3600		;REVERB
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>470</x>
 <y>244</y>
 <width>1017</width>
 <height>518</height>
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
  <width>1010</width>
  <height>511</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wavelets</label>
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
   <r>0</r>
   <g>85</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>10</y>
  <width>100</width>
  <height>30</height>
  <uuid>{55273d97-d39a-441c-8da6-87ea139493b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    On / Off</text>
  <image>/</image>
  <eventLine>i1 0 -1</eventLine>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FundMin_Value</objectName>
  <x>8</x>
  <y>71</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
  <alignment>left</alignment>
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
  <x>161</x>
  <y>71</y>
  <width>180</width>
  <height>30</height>
  <uuid>{5cde19f3-b356-4945-9c8b-43dd67c604dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fund. Rand Range</label>
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
  <objectName>FundMax_Value</objectName>
  <x>448</x>
  <y>71</y>
  <width>60</width>
  <height>30</height>
  <uuid>{073ad371-9227-46fa-a005-ac10a210db79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>60.094</label>
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
  <x>6</x>
  <y>305</y>
  <width>1004</width>
  <height>203</height>
  <uuid>{9c6abfa6-99bf-4a15-94a4-ce86b18f37d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Wavelet granular synthesis is a special type of granular synthesis in which each grain begins and end at a zero crossing in the source waveform, where phase equals zero. Typically each grain will represent a complete single cycle of the source waveform. For this reason the source waveform should really be a simple monophonic tone. In this example the source waveform is generated using additive synthesis techniques via a GEN 10 function table. The user can modify the structure of overtones in this waveform using the bank of mini sliders. Because each grain is always starting at a zero crossing in the waveform we do not need to worry about enveloping the amplitude of each grain to prevent clicks. The type of granular sythesis tone produced is governed by two main principles: the rate of grain generation which here is referred to (and perceived as) the fundemental (Fund.) of the generated tone, and the pitch of the sound material within the grain (formant/Form.). As each grain will be very short the pitch of the sound material within the grain will not be perceived as a steady pitch, instead it will be perceived as a resonant peak in the tone, the fundemental of which is instead governed by the rate of grain generation. Clearly wavelet granular synthesis shares many principles with FOF synthesis.
To faciltate the exploration of these two parameters in this implementation they are controlled via two random spline curve generators. For each of these generators the user has control over the minimum and maximum values possible and the minimum and maximum rates of change of the generators. In addition to these two spline generators as a method of control, fundemental and formant can also be modulated using high frequency randomisation, referred to as 'de-regulation'. As mentioned before, normally a wavelet contains just a single cycle of the waveform but in the example the user can increase the number of wavelets ('Num. Wavelets'). This is done in integer steps so that each grain will still begin and end at a zero crossing. Increasing the number of wavelets per grain will increase the apparent resonance of the formant. In addition reverb can be added as well as a slow random modulation of amplitude and panning.</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>FundMin</objectName>
  <x>8</x>
  <y>53</y>
  <width>500</width>
  <height>10</height>
  <uuid>{7e1a4451-ac38-4e90-81c7-25737b478e39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.14870000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>FundMax</objectName>
  <x>8</x>
  <y>63</y>
  <width>500</width>
  <height>10</height>
  <uuid>{382b63b4-cd22-44be-82ae-83a232e76e13}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59130001</xValue>
  <yValue>0.00000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
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
  <objectName>FundRateMin_Value</objectName>
  <x>8</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d3a717f5-0f16-440e-b555-221394ed3014}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.070</label>
  <alignment>left</alignment>
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
  <x>161</x>
  <y>112</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7c96183b-c6c4-4d21-91b8-0c3e22ef8b61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fund. Rand. Rate</label>
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
  <objectName>FundRateMax_Value</objectName>
  <x>448</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4b101870-439e-4ca4-91c8-5cc81e7bfeac}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>FundRateMin</objectName>
  <x>8</x>
  <y>94</y>
  <width>500</width>
  <height>10</height>
  <uuid>{c32bd13e-dfd4-4b06-ac7b-1b8388271eb4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.36800000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>FundRateMax</objectName>
  <x>8</x>
  <y>104</y>
  <width>500</width>
  <height>10</height>
  <uuid>{d4def40d-ec58-4ce1-9cbc-50eb21815740}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.56500000</xValue>
  <yValue>0.00000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>161</x>
  <y>153</y>
  <width>180</width>
  <height>30</height>
  <uuid>{216d4512-abcc-4965-a0d6-9994a6acdc4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fund. De-regulate</label>
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
  <objectName>FundDeReg_Value</objectName>
  <x>448</x>
  <y>153</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d86edddb-025e-4912-a58c-b8abd3a12418}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>FundDeReg</objectName>
  <x>8</x>
  <y>138</y>
  <width>500</width>
  <height>16</height>
  <uuid>{082f6a04-48e9-4235-9224-4ec0c825ca22}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
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
  <objectName>FormMin</objectName>
  <x>8</x>
  <y>194</y>
  <width>60</width>
  <height>30</height>
  <uuid>{850ec477-dd03-48c9-adeb-e99b52e02d77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.000</label>
  <alignment>left</alignment>
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
  <x>161</x>
  <y>194</y>
  <width>180</width>
  <height>30</height>
  <uuid>{fbf17bca-3102-42c5-acec-6760535ab723}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Form. Rand. Range</label>
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
  <objectName>FormMax</objectName>
  <x>448</x>
  <y>194</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3d053b66-9bd6-44b7-8724-e8ea8b2afbd1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>12.000</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>FormMin</objectName>
  <x>8</x>
  <y>176</y>
  <width>500</width>
  <height>10</height>
  <uuid>{8456b375-6330-4f38-b987-79c47bde8437}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>4.00000000</xMin>
  <xMax>14.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>5.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>FormMax</objectName>
  <x>8</x>
  <y>186</y>
  <width>500</width>
  <height>10</height>
  <uuid>{79e1a0de-e783-4ed5-b901-3aa26412e715}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>4.00000000</xMin>
  <xMax>14.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>12.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
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
  <objectName>FormRateMin</objectName>
  <x>8</x>
  <y>235</y>
  <width>60</width>
  <height>30</height>
  <uuid>{31c0b14c-73fe-4c15-828d-16654755abba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.070</label>
  <alignment>left</alignment>
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
  <x>161</x>
  <y>235</y>
  <width>180</width>
  <height>30</height>
  <uuid>{ac1d9f27-6692-4b93-8b21-4b1ae63862ff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Form Rand. Rate</label>
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
  <objectName>FormRateMax</objectName>
  <x>448</x>
  <y>235</y>
  <width>60</width>
  <height>30</height>
  <uuid>{54d11598-0bf1-4de3-8eab-b2fac159a349}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>FormRateMin</objectName>
  <x>8</x>
  <y>217</y>
  <width>500</width>
  <height>10</height>
  <uuid>{8412cc88-b78b-4f9e-8423-976b1a430d8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.01000000</xMin>
  <xMax>2.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.07000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>FormRateMax</objectName>
  <x>8</x>
  <y>227</y>
  <width>500</width>
  <height>10</height>
  <uuid>{7df97ca1-c392-4927-a778-e1fdf18e05c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.01000000</xMin>
  <xMax>2.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.20000000</xValue>
  <yValue>0.00000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>161</x>
  <y>276</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7dab8eae-436a-424a-9298-06a7dd934abd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Form. De-regulate</label>
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
  <objectName>FormDeReg</objectName>
  <x>448</x>
  <y>276</y>
  <width>60</width>
  <height>30</height>
  <uuid>{279f55b5-595d-4ef9-8e4b-0ebcb572953a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.001</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>FormDeReg</objectName>
  <x>8</x>
  <y>260</y>
  <width>500</width>
  <height>16</height>
  <uuid>{1419ea11-eb45-4375-afb2-102c2cda8397}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>5.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00100000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>520</x>
  <y>237</y>
  <width>240</width>
  <height>30</height>
  <uuid>{02b31cf7-05dc-4053-854e-528d0e894f76}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rvb Send</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>RvbSend</objectName>
  <x>520</x>
  <y>221</y>
  <width>240</width>
  <height>16</height>
  <uuid>{686432a5-c937-411a-977a-7c5774a19488}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000001</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>767</x>
  <y>237</y>
  <width>240</width>
  <height>30</height>
  <uuid>{692bddc3-8d86-4e36-9c22-807b62bf00ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rvb Time</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>RvbTime</objectName>
  <x>767</x>
  <y>221</y>
  <width>240</width>
  <height>16</height>
  <uuid>{9507d1ba-a1bb-4c56-8f42-9d16966938ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.85000002</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>520</x>
  <y>276</y>
  <width>240</width>
  <height>30</height>
  <uuid>{6824c6b3-5b86-4c02-a7cb-b271933da758}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp. Mod. Depth</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>AmpModDepth</objectName>
  <x>520</x>
  <y>260</y>
  <width>240</width>
  <height>16</height>
  <uuid>{ca7e6997-0f59-49d8-9eac-fe8199d3ffd8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.20000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>767</x>
  <y>276</y>
  <width>240</width>
  <height>30</height>
  <uuid>{102f7010-0865-4e4d-ade0-7d68a9b2ab58}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pan. Mod. Depth</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>PanModDepth</objectName>
  <x>767</x>
  <y>260</y>
  <width>240</width>
  <height>16</height>
  <uuid>{79419085-a89a-4dfd-8d5f-2cf285745b71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>0.50000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.40000001</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>109</x>
  <y>10</y>
  <width>80</width>
  <height>40</height>
  <uuid>{b1dd8221-3caa-496d-b70c-2598adb586c8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output
Gain</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>OutGain</objectName>
  <x>190</x>
  <y>20</y>
  <width>240</width>
  <height>16</height>
  <uuid>{d1eaf0cc-1805-4d46-a4ea-91ff62fddb8f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>0.20000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.20000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>85</r>
   <g>255</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>876</x>
  <y>142</y>
  <width>100</width>
  <height>30</height>
  <uuid>{bb77da2f-f78b-43dd-806d-a6e47ccd1585}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Num. Wavelets</label>
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
  <y>53</y>
  <width>324</width>
  <height>160</height>
  <uuid>{0296d684-fb79-4f59-a92f-2314102b1e91}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>GEN10 Amplitudes   1 &lt;---> 20</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>534</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{8284e81f-0cb3-40e1-8681-da6d72cfc915}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp01</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>1.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>549</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{74e7072e-2ba1-4bc7-95d6-028b340d1392}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp02</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>564</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{d295a632-8b24-4460-9f50-7a10f55812ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp03</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>579</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{4e968ec6-cb97-4450-93dc-8ad09072b69f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp04</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.80000001</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>594</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{32f3f4f3-c58b-4a48-8dfb-5842665c8cfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp05</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>609</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{b5c71182-4851-40b0-a410-f808973b08de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp06</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>624</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{791815fb-2dfa-4e36-b19d-6af30618e575}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp07</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>639</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{0aee34a8-4757-4560-8d0e-b2fc520c95f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp08</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>653</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{e55fa091-63fa-44bb-92d9-0eccdd29b12c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp09</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>668</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{6e719580-5a32-46db-9973-60b4c884e95e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp10</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>683</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{78583ffe-0311-424b-ba4e-d5b4f33795eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp11</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>698</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{4106d154-2e69-499c-8ee3-7af80049623a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp12</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>713</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{f28f878a-aec9-4b57-af9d-4dd650d4e53e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp13</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>728</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{a2f38d6a-5984-421d-b5f8-685104f1ab78}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp14</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>743</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{d4631e7d-06a9-4474-b96a-e718fdb037f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp15</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>758</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{f4ed670b-850b-44e9-955f-c287dc202346}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp16</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>773</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{de80a01e-aa3a-4212-a24f-12250160ff94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp17</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>788</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{5749ff7e-4a86-468b-b8ab-fea38e7c548f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp18</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>803</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{1145b3b6-3902-48c6-b0e9-7d63648bc1f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp19</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>818</x>
  <y>86</y>
  <width>12</width>
  <height>110</height>
  <uuid>{aa9ef00d-4b7e-4b7d-a47d-956e249ccc80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp20</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.90909094</yValue>
  <type>fill</type>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>NumWavelets</objectName>
  <x>902</x>
  <y>116</y>
  <width>50</width>
  <height>26</height>
  <uuid>{92552f78-6b43-4ee5-9204-c45d22408a64}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
  <maximum>64</maximum>
  <randomizable group="0">false</randomizable>
  <value>15</value>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="INIT" number="0" >
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="1" >0.00000000</value>
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="4" >0</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="1" >0.49979129</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="4" >0.500</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="1" >60.09410477</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="4" >60.094</value>
<value id="{7e1a4451-ac38-4e90-81c7-25737b478e39}" mode="1" >0.14870000</value>
<value id="{7e1a4451-ac38-4e90-81c7-25737b478e39}" mode="2" >0.00000000</value>
<value id="{382b63b4-cd22-44be-82ae-83a232e76e13}" mode="1" >0.59130001</value>
<value id="{382b63b4-cd22-44be-82ae-83a232e76e13}" mode="2" >0.00000000</value>
<value id="{d3a717f5-0f16-440e-b555-221394ed3014}" mode="1" >0.07027707</value>
<value id="{d3a717f5-0f16-440e-b555-221394ed3014}" mode="4" >0.070</value>
<value id="{4b101870-439e-4ca4-91c8-5cc81e7bfeac}" mode="1" >0.19960095</value>
<value id="{4b101870-439e-4ca4-91c8-5cc81e7bfeac}" mode="4" >0.200</value>
<value id="{c32bd13e-dfd4-4b06-ac7b-1b8388271eb4}" mode="1" >0.36800000</value>
<value id="{c32bd13e-dfd4-4b06-ac7b-1b8388271eb4}" mode="2" >0.00000000</value>
<value id="{d4def40d-ec58-4ce1-9cbc-50eb21815740}" mode="1" >0.56500000</value>
<value id="{d4def40d-ec58-4ce1-9cbc-50eb21815740}" mode="2" >0.00000000</value>
<value id="{d86edddb-025e-4912-a58c-b8abd3a12418}" mode="1" >0.00000010</value>
<value id="{d86edddb-025e-4912-a58c-b8abd3a12418}" mode="4" >0.000</value>
<value id="{082f6a04-48e9-4235-9224-4ec0c825ca22}" mode="1" >0.00000000</value>
<value id="{082f6a04-48e9-4235-9224-4ec0c825ca22}" mode="2" >0.00000000</value>
<value id="{850ec477-dd03-48c9-adeb-e99b52e02d77}" mode="1" >5.00000000</value>
<value id="{850ec477-dd03-48c9-adeb-e99b52e02d77}" mode="4" >5.000</value>
<value id="{3d053b66-9bd6-44b7-8724-e8ea8b2afbd1}" mode="1" >12.00000000</value>
<value id="{3d053b66-9bd6-44b7-8724-e8ea8b2afbd1}" mode="4" >12.000</value>
<value id="{8456b375-6330-4f38-b987-79c47bde8437}" mode="1" >5.00000000</value>
<value id="{8456b375-6330-4f38-b987-79c47bde8437}" mode="2" >0.00000000</value>
<value id="{79e1a0de-e783-4ed5-b901-3aa26412e715}" mode="1" >12.00000000</value>
<value id="{79e1a0de-e783-4ed5-b901-3aa26412e715}" mode="2" >0.00000000</value>
<value id="{31c0b14c-73fe-4c15-828d-16654755abba}" mode="1" >0.07000000</value>
<value id="{31c0b14c-73fe-4c15-828d-16654755abba}" mode="4" >0.070</value>
<value id="{54d11598-0bf1-4de3-8eab-b2fac159a349}" mode="1" >0.20000000</value>
<value id="{54d11598-0bf1-4de3-8eab-b2fac159a349}" mode="4" >0.200</value>
<value id="{8412cc88-b78b-4f9e-8423-976b1a430d8b}" mode="1" >0.07000000</value>
<value id="{8412cc88-b78b-4f9e-8423-976b1a430d8b}" mode="2" >0.00000000</value>
<value id="{7df97ca1-c392-4927-a778-e1fdf18e05c1}" mode="1" >0.20000000</value>
<value id="{7df97ca1-c392-4927-a778-e1fdf18e05c1}" mode="2" >0.00000000</value>
<value id="{279f55b5-595d-4ef9-8e4b-0ebcb572953a}" mode="1" >0.00100000</value>
<value id="{279f55b5-595d-4ef9-8e4b-0ebcb572953a}" mode="4" >0.001</value>
<value id="{1419ea11-eb45-4375-afb2-102c2cda8397}" mode="1" >0.00100000</value>
<value id="{1419ea11-eb45-4375-afb2-102c2cda8397}" mode="2" >0.00000000</value>
<value id="{686432a5-c937-411a-977a-7c5774a19488}" mode="1" >0.40000001</value>
<value id="{686432a5-c937-411a-977a-7c5774a19488}" mode="2" >0.00000000</value>
<value id="{9507d1ba-a1bb-4c56-8f42-9d16966938ca}" mode="1" >0.85000002</value>
<value id="{9507d1ba-a1bb-4c56-8f42-9d16966938ca}" mode="2" >0.00000000</value>
<value id="{ca7e6997-0f59-49d8-9eac-fe8199d3ffd8}" mode="1" >0.20000000</value>
<value id="{ca7e6997-0f59-49d8-9eac-fe8199d3ffd8}" mode="2" >0.00000000</value>
<value id="{79419085-a89a-4dfd-8d5f-2cf285745b71}" mode="1" >0.40000001</value>
<value id="{79419085-a89a-4dfd-8d5f-2cf285745b71}" mode="2" >0.00000000</value>
<value id="{d1eaf0cc-1805-4d46-a4ea-91ff62fddb8f}" mode="1" >0.20000000</value>
<value id="{d1eaf0cc-1805-4d46-a4ea-91ff62fddb8f}" mode="2" >0.00000000</value>
<value id="{8284e81f-0cb3-40e1-8681-da6d72cfc915}" mode="1" >0.00000000</value>
<value id="{8284e81f-0cb3-40e1-8681-da6d72cfc915}" mode="2" >1.00000000</value>
<value id="{74e7072e-2ba1-4bc7-95d6-028b340d1392}" mode="1" >0.00000000</value>
<value id="{74e7072e-2ba1-4bc7-95d6-028b340d1392}" mode="2" >0.00000000</value>
<value id="{d295a632-8b24-4460-9f50-7a10f55812ae}" mode="1" >0.00000000</value>
<value id="{d295a632-8b24-4460-9f50-7a10f55812ae}" mode="2" >0.00000000</value>
<value id="{4e968ec6-cb97-4450-93dc-8ad09072b69f}" mode="1" >0.00000000</value>
<value id="{4e968ec6-cb97-4450-93dc-8ad09072b69f}" mode="2" >0.80000001</value>
<value id="{32f3f4f3-c58b-4a48-8dfb-5842665c8cfa}" mode="1" >0.00000000</value>
<value id="{32f3f4f3-c58b-4a48-8dfb-5842665c8cfa}" mode="2" >0.00000000</value>
<value id="{b5c71182-4851-40b0-a410-f808973b08de}" mode="1" >0.00000000</value>
<value id="{b5c71182-4851-40b0-a410-f808973b08de}" mode="2" >0.00000000</value>
<value id="{791815fb-2dfa-4e36-b19d-6af30618e575}" mode="1" >0.00000000</value>
<value id="{791815fb-2dfa-4e36-b19d-6af30618e575}" mode="2" >0.50000000</value>
<value id="{0aee34a8-4757-4560-8d0e-b2fc520c95f9}" mode="1" >0.00000000</value>
<value id="{0aee34a8-4757-4560-8d0e-b2fc520c95f9}" mode="2" >0.00000000</value>
<value id="{e55fa091-63fa-44bb-92d9-0eccdd29b12c}" mode="1" >0.00000000</value>
<value id="{e55fa091-63fa-44bb-92d9-0eccdd29b12c}" mode="2" >0.00000000</value>
<value id="{6e719580-5a32-46db-9973-60b4c884e95e}" mode="1" >0.00000000</value>
<value id="{6e719580-5a32-46db-9973-60b4c884e95e}" mode="2" >0.00000000</value>
<value id="{78583ffe-0311-424b-ba4e-d5b4f33795eb}" mode="1" >0.00000000</value>
<value id="{78583ffe-0311-424b-ba4e-d5b4f33795eb}" mode="2" >0.00000000</value>
<value id="{4106d154-2e69-499c-8ee3-7af80049623a}" mode="1" >0.00000000</value>
<value id="{4106d154-2e69-499c-8ee3-7af80049623a}" mode="2" >0.00000000</value>
<value id="{f28f878a-aec9-4b57-af9d-4dd650d4e53e}" mode="1" >0.00000000</value>
<value id="{f28f878a-aec9-4b57-af9d-4dd650d4e53e}" mode="2" >0.00000000</value>
<value id="{a2f38d6a-5984-421d-b5f8-685104f1ab78}" mode="1" >0.00000000</value>
<value id="{a2f38d6a-5984-421d-b5f8-685104f1ab78}" mode="2" >0.00000000</value>
<value id="{d4631e7d-06a9-4474-b96a-e718fdb037f3}" mode="1" >0.00000000</value>
<value id="{d4631e7d-06a9-4474-b96a-e718fdb037f3}" mode="2" >0.00000000</value>
<value id="{f4ed670b-850b-44e9-955f-c287dc202346}" mode="1" >0.00000000</value>
<value id="{f4ed670b-850b-44e9-955f-c287dc202346}" mode="2" >0.00000000</value>
<value id="{de80a01e-aa3a-4212-a24f-12250160ff94}" mode="1" >0.00000000</value>
<value id="{de80a01e-aa3a-4212-a24f-12250160ff94}" mode="2" >0.00000000</value>
<value id="{5749ff7e-4a86-468b-b8ab-fea38e7c548f}" mode="1" >0.00000000</value>
<value id="{5749ff7e-4a86-468b-b8ab-fea38e7c548f}" mode="2" >0.00000000</value>
<value id="{1145b3b6-3902-48c6-b0e9-7d63648bc1f0}" mode="1" >0.00000000</value>
<value id="{1145b3b6-3902-48c6-b0e9-7d63648bc1f0}" mode="2" >0.00000000</value>
<value id="{aa9ef00d-4b7e-4b7d-a47d-956e249ccc80}" mode="1" >0.00000000</value>
<value id="{aa9ef00d-4b7e-4b7d-a47d-956e249ccc80}" mode="2" >0.90909094</value>
<value id="{92552f78-6b43-4ee5-9204-c45d22408a64}" mode="1" >15.00000000</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

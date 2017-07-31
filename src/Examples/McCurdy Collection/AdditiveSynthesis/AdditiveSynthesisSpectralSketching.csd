; Written by Iain McCurdy, 2006
; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add denorm in reverb to avoid CPU overload when instruments 1 and 3 are not activated.
;	Add denorm to portk in OSCILLATOR macros to avoid CPU overload when PartAmp sliders are zeros.
;	Add table(s) for exp slider
;	Instrument 1 is activated by MIDI and by the GUI

;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100
ksmps 	= 32
nchnls 	= 2
0dbfs	= 1		;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH

gasend		init		0

gisine		ftgen	0,0,4096,10,1													;SINE WAVE
giwaveform	ftgen	0,0,32,-2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;TABLE THAT CONTAINS PARTIAL STRENGTHS. THIS WILL BE UPDATED BY MOVEMENTS ON THE X-Y PANEL

;TABLES FOR EXP SLIDERS
giExp8000		ftgen	0, 0, 129, -25, 0, 4, 128, 8000
giExp20000	ftgen	0, 0, 129, -25, 0, 20, 128, 20000

instr	10	;GUI
	ktrig	metro	10

	if (ktrig == 1) then

#define	PART(COUNT)	
	#
	gkPartAmp$COUNT	invalue	"PartAmp$COUNT"
	gkRatio$COUNT		invalue	"Ratio$COUNT"
	#

		$PART(1) 
		$PART(2) 
		$PART(3) 
		$PART(4) 
		$PART(5) 
		$PART(6) 
		$PART(7) 
		$PART(8) 
		$PART(9) 
		$PART(10)
		$PART(11)
		$PART(12)
		$PART(13)
		$PART(14)
		$PART(15)
		$PART(16)
		$PART(17)
		$PART(18)
		$PART(19)
		$PART(20)
		$PART(21)
		$PART(22)
		$PART(23)
		$PART(24)
		$PART(25)
		$PART(26)
		$PART(27)
		$PART(28)
		$PART(29)
		$PART(30)

		gkamp		invalue	"Amplitude"
		gkFundFrq		invalue	"Fund_Freq"					
		gkFundFrq		tablei	gkFundFrq, giExp8000, 1
					outvalue	"Fund_Freq_Value", gkFundFrq
		gkAmpPort		invalue	"Amp_Fund_Port"
		gkRatiosPort	invalue	"Ratio_Port"
		gkAttTim		invalue	"Attack_Time"
		gkRelTim		invalue 	"Release_Time"
		gkRvbMix		invalue	"Reverb_Mix"
		gkRvbFbl		invalue	"Reverb_Time"
		gkRvbLPF		invalue 	"Reverb_LPF"
		gkRvbLPF		tablei	gkRvbLPF, giExp20000, 1
	endif
endin

instr	1	;SOUND GENERATING INSTRUMENT

	if p4!=0 then											;MIDI
		ioct		= p4										;READ OCT VALUE FROM MIDI INPUT
		iamp		= p5	* 0.1								;READ IN A NOTE VELOCITY VALUE FROM THE MIDI INPUT
		kamp 	= iamp * gkamp								;SET kamp TO MIDI KEY VELOCITY MULTIPLIED BY SLIDER VALUE gkamp

		;PITCH BEND===========================================================================================================================================================
		iSemitoneBendRange = 2								;PITCH BEND RANGE IN SEMITONES (WILL BE DEFINED FURTHER LATER) - SUGGESTION - THIS COULD BE CONTROLLED BY AN COUNTER
		imin		= 0										;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333				;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax						;PITCH BEND VARIABLE (IN oct FORMAT)
		kFundFrq	=	cpsoct(ioct + kbend)
		;=====================================================================================================================================================================
	else													;GUI
		kamp			= gkamp * 0.1							;SET kamp TO SLIDER VALUE gkamp
		kFundFrq		= gkFundFrq							;SET FUNDEMENTAL TO SLIDER gkfund
	endif

	kporttime		linseg	0, 0.001, 1, 1, 1					;CREATE A RAMPING UP VARIABLE TO PREVENT PORTAMENTO GLIDE UPON NOTE ONSET
	kAmpPort		=		kporttime * gkAmpPort				;VARIABLE THAT WILL BE USED FOR AMPLITUDE (AND FUNDEMENTAL) PORTAMENTO
	kRatiosPort	=		kporttime * gkRatiosPort				;VARIABLE THAT WILL BE USED FOR AMPLITUDE (AND FUNDEMENTAL) PORTAMENTO
	kfund		portk	kFundFrq, kAmpPort					;APPLY PORTAMENTO TO FUNDEMENTAL SLIDER OUTPUT
	amix			init		0

#define	OSCILLATOR(COUNT)	
	#
	kPartAmp$COUNT		table	$COUNT-1, giwaveform							;READ RELEVANT PARTIAL AMPLITUDE FROM TABLE
	kPartAmp$COUNT		portk	0.000001 + kPartAmp$COUNT , kAmpPort				;APPLY PORTAMENTO SMOOTHING TO CHANGES IN PARTIAL AMPLITUDE
	kRatio$COUNT		portk	gkRatio$COUNT, kRatiosPort						;READ RELEVANT PARTIAL RATIO
	apart$COUNT		oscil	kamp*kPartAmp$COUNT, kfund*kRatio$COUNT, gisine		;GENERATE AUDIO FOR PARTIAL
	amix				=		amix + apart$COUNT								;ADD PARTIAL AUDIO TO CUMULATIVE AUDIO VARIABLE
	#

	$OSCILLATOR(1) 
	$OSCILLATOR(2) 
	$OSCILLATOR(3) 
	$OSCILLATOR(4) 
	$OSCILLATOR(5) 
	$OSCILLATOR(6) 
	$OSCILLATOR(7) 
	$OSCILLATOR(8) 
	$OSCILLATOR(9) 
	$OSCILLATOR(10)
	$OSCILLATOR(11)
	$OSCILLATOR(12)
	$OSCILLATOR(13)
	$OSCILLATOR(14)
	$OSCILLATOR(15)
	$OSCILLATOR(16)
	$OSCILLATOR(17)
	$OSCILLATOR(18)
	$OSCILLATOR(19)
	$OSCILLATOR(20)
	$OSCILLATOR(21)
	$OSCILLATOR(22)
	$OSCILLATOR(23)
	$OSCILLATOR(24)
	$OSCILLATOR(25)
	$OSCILLATOR(26)
	$OSCILLATOR(27)
	$OSCILLATOR(28)
	$OSCILLATOR(29)
	$OSCILLATOR(30)
	
	aenv		linsegr	0, i(gkAttTim), 1, i(gkRelTim), 0						;AMPLITUDE ENVELOPE
	amix		=		amix * aenv										;ANTI-CLICK ENVELOPE
	gasend	=		gasend +  (amix * gkRvbMix)
			outs		amix * (1 - gkRvbMix), amix * (1 - gkRvbMix)				;SEND DRY SIGNAL TO OUTPUTS
			clear	amix
endin

instr	2	;UPDATE SLIDERS

	kx			invalue	"X_Part"
	ky			invalue	"Y_Amp"
	kx			=		int(kx)										;CONVERT X-AXIS VALUES TO INTEGERS 
	ktrig_XY		changed	kx, ky										;GENERATE A TRIGGER (MOMENTARY '1') IF X OR Y AXIS VALUES CHANGE
	
	;	SCHEDKWHEN KTRIGGER, KMINTIM, KMAXNUM, KINSNUM, KWHEN, KDUR, p4,  p5
		schedkwhen ktrig_XY,    0,       0,       4,     0,    0,    kx,  ky		;TRIGGER INSTRUMENT THAT UPDATES THE TABLE

#define	UPDATE_SLIDER(COUNT)	
	#
	kPartAmp$COUNT	table	$COUNT-1, giwaveform							;READ RELEVANT PARTIAL AMPLITUDE FROM TABLE (DEPENDENT UPON Y LOCATION OF POINTER)
				outvalue	"PartAmp$COUNT", kPartAmp$COUNT
	#
	
	if (ktrig_XY == 1)	then
		$UPDATE_SLIDER(1) 
		$UPDATE_SLIDER(2) 
		$UPDATE_SLIDER(3) 
		$UPDATE_SLIDER(4) 
		$UPDATE_SLIDER(5) 
		$UPDATE_SLIDER(6) 
		$UPDATE_SLIDER(7) 
		$UPDATE_SLIDER(8) 
		$UPDATE_SLIDER(9) 
		$UPDATE_SLIDER(10)
		$UPDATE_SLIDER(11)
		$UPDATE_SLIDER(12)
		$UPDATE_SLIDER(13)
		$UPDATE_SLIDER(14)
		$UPDATE_SLIDER(15)
		$UPDATE_SLIDER(16)
		$UPDATE_SLIDER(17)
		$UPDATE_SLIDER(18)
		$UPDATE_SLIDER(19)
		$UPDATE_SLIDER(20)
		$UPDATE_SLIDER(21)
		$UPDATE_SLIDER(22)
		$UPDATE_SLIDER(23)
		$UPDATE_SLIDER(24)
		$UPDATE_SLIDER(25)
		$UPDATE_SLIDER(26)
		$UPDATE_SLIDER(27)
		$UPDATE_SLIDER(28)
		$UPDATE_SLIDER(29)
		$UPDATE_SLIDER(30)
	endif
endin

instr	4	;UPDATE PARTIAL VALUE
				tableiw	p5, p4, giwaveform					;UPDATE AMPLITUDE VALUE IN TABLE
endin

instr	5	;HARMONIC RATIOS
	outvalue	"Ratio1",1 
	outvalue	"Ratio2",2 
	outvalue	"Ratio3",3
	outvalue	"Ratio4",4
	outvalue	"Ratio5",5
	outvalue	"Ratio6",6
	outvalue	"Ratio7",7
	outvalue	"Ratio8",8
	outvalue	"Ratio9",9
	outvalue	"Ratio10",10
	outvalue	"Ratio11",11
	outvalue	"Ratio12",12
	outvalue	"Ratio13",13
	outvalue	"Ratio14",14
	outvalue	"Ratio15",15
	outvalue	"Ratio16",16
	outvalue	"Ratio17",17
	outvalue	"Ratio18",18
	outvalue	"Ratio19",19
	outvalue	"Ratio20",20
	outvalue	"Ratio21",21
	outvalue	"Ratio22",22
	outvalue	"Ratio23",23
	outvalue	"Ratio24",24
	outvalue	"Ratio25",25
	outvalue	"Ratio26",26
	outvalue	"Ratio27",27
	outvalue	"Ratio28",28
	outvalue	"Ratio29",29
	outvalue	"Ratio30",30
endin

instr	6	;RANDOMIZE RATIOS

#define	RANDOMIZE_RATIO(COUNT)
	#
	iratio	random	1,30
			outvalue	"Ratio$COUNT", iratio
	#
	$RANDOMIZE_RATIO(1) 
	$RANDOMIZE_RATIO(2) 
	$RANDOMIZE_RATIO(3) 
	$RANDOMIZE_RATIO(4) 
	$RANDOMIZE_RATIO(5) 
	$RANDOMIZE_RATIO(6) 
	$RANDOMIZE_RATIO(7) 
	$RANDOMIZE_RATIO(8) 
	$RANDOMIZE_RATIO(9) 
	$RANDOMIZE_RATIO(10)
	$RANDOMIZE_RATIO(11)
	$RANDOMIZE_RATIO(12)
	$RANDOMIZE_RATIO(13)
	$RANDOMIZE_RATIO(14)
	$RANDOMIZE_RATIO(15)
	$RANDOMIZE_RATIO(16)
	$RANDOMIZE_RATIO(17)
	$RANDOMIZE_RATIO(18)
	$RANDOMIZE_RATIO(19)
	$RANDOMIZE_RATIO(20)
	$RANDOMIZE_RATIO(21)
	$RANDOMIZE_RATIO(22)
	$RANDOMIZE_RATIO(23)
	$RANDOMIZE_RATIO(24)
	$RANDOMIZE_RATIO(25)
	$RANDOMIZE_RATIO(26)
	$RANDOMIZE_RATIO(27)
	$RANDOMIZE_RATIO(28)
	$RANDOMIZE_RATIO(29)
	$RANDOMIZE_RATIO(30)
endin

instr	7	;ZERO PARTIAL AMPLITUDES

#define	ZERO_AMPLITUDE(COUNT)
	#
	outvalue		"PartAmp$COUNT", 0
	tableiw		0, $COUNT - 1, giwaveform	;UPDATE AMPLITUDE VALUE IN TABLE
	#
	$ZERO_AMPLITUDE(1) 
	$ZERO_AMPLITUDE(2) 
	$ZERO_AMPLITUDE(3) 
	$ZERO_AMPLITUDE(4) 
	$ZERO_AMPLITUDE(5) 
	$ZERO_AMPLITUDE(6) 
	$ZERO_AMPLITUDE(7) 
	$ZERO_AMPLITUDE(8) 
	$ZERO_AMPLITUDE(9) 
	$ZERO_AMPLITUDE(10)
	$ZERO_AMPLITUDE(11)
	$ZERO_AMPLITUDE(12)
	$ZERO_AMPLITUDE(13)
	$ZERO_AMPLITUDE(14)
	$ZERO_AMPLITUDE(15)
	$ZERO_AMPLITUDE(16)
	$ZERO_AMPLITUDE(17)
	$ZERO_AMPLITUDE(18)
	$ZERO_AMPLITUDE(19)
	$ZERO_AMPLITUDE(20)
	$ZERO_AMPLITUDE(21)
	$ZERO_AMPLITUDE(22)
	$ZERO_AMPLITUDE(23)
	$ZERO_AMPLITUDE(24)
	$ZERO_AMPLITUDE(25)
	$ZERO_AMPLITUDE(26)
	$ZERO_AMPLITUDE(27)
	$ZERO_AMPLITUDE(28)
	$ZERO_AMPLITUDE(29)
	$ZERO_AMPLITUDE(30)
endin

instr	8	;REVERB
				denorm	gasend

	;OUTPUTS		OPCODE		INPUTS    |FEEDBACK|LPF_CUTPFF
	arvbL,arvbR	reverbsc	gasend, gasend, gkRvbFbl,gkRvbLPF		;CREATE A REVERBERATED SIGNAL

				outs		arvbL, arvbR						;SEND AUDIO SIGNAL TO THE OUTPUTS
				clear	gasend
endin
</CsInstruments>
<CsScore>
i 2  0 3600	;INSTRUMENT 2 PLAYS FOR 1 HOUR
i 8  0 3600	;INSTRUMENT 8 PLAYS FOR 1 HOUR	(REVERB)
i 10 0 3600	;INSTRUMENT 10 PLAYS FOR 1 HOUR	(GUI)
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>14</x>
 <y>63</y>
 <width>1010</width>
 <height>705</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>208</r>
  <g>208</g>
  <b>208</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>698</width>
  <height>700</height>
  <uuid>{19bcfbdb-6e13-48da-86ce-a105d2a13bde}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Additive Synthesis Spectrum Sketching</label>
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
   <r>170</r>
   <g>170</g>
   <b>170</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>X_Part</objectName>
  <x>6</x>
  <y>34</y>
  <width>690</width>
  <height>218</height>
  <uuid>{15c1d525-2593-4026-8825-cbb7b8b48386}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Y_Amp</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>30.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>29.26086957</xValue>
  <yValue>0.06422018</yValue>
  <type>point</type>
  <pointsize>14</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>6</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{1ff21053-e0a7-4ff8-9925-d242f5da7d24}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.04128440</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>250</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>29</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{a2bb061a-4fe1-4d55-95e0-abcde3e9a9f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.08256881</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>242</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>52</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{56397fd7-e4f1-46d5-a28d-3458f476c5d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.17889908</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>234</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>75</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{4df17551-c921-42a3-b729-32916c9d3e59}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.32110092</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>226</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>98</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{e1d257a0-d296-4664-9671-a5b31dc81729}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp5</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.43577982</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>218</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>121</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{2a68240a-102f-4c1e-8679-ccb30754b1e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.61926606</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>210</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>144</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{535dfa72-3f17-4fa0-b898-4222a23f2e5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp7</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.88532110</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>202</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>167</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{1415e177-0d36-494b-9e1d-9adb29727023}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp8</objectName2>
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
   <r>255</r>
   <g>255</g>
   <b>194</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>190</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{3048f27b-3135-4cfd-a962-5c8894e7b860}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp9</objectName2>
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
   <r>255</r>
   <g>255</g>
   <b>186</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>213</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{f787419e-5e7d-4ad4-89b7-099d9b8c0774}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp10</objectName2>
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
   <r>255</r>
   <g>255</g>
   <b>178</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>236</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{7990f481-6e52-4ebf-a727-d2855563a0cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp11</objectName2>
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
   <r>255</r>
   <g>255</g>
   <b>170</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>259</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{114ea0b8-7e3f-4d87-ae82-e2ecf543f97e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp12</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.85321101</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>162</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>282</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{c14666ee-3231-4924-8b68-6d1260d8f7d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp13</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.78440367</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>154</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>305</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{e4b1aebb-9ac9-492f-a796-6a4e07746608}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp14</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.73853211</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>146</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>328</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{82a8f078-cb67-410a-acb7-f0641a71b624}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp15</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.67889908</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>138</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>351</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{ce13a13f-da2d-407d-827f-35868a1c807d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp16</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.62385321</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>130</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>374</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{a62836e8-dbfc-42f7-91a1-2d4e0ace52b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp17</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.56422018</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>122</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>397</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{15dc200d-e075-400e-84d8-ec4408d8c432}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp18</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.48623853</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>114</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>420</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{5433d406-01f8-4b40-83db-75deb79363b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp19</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.41284404</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>106</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>443</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{c472caed-51a7-445f-b84f-ea7a0849c3bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp20</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.35321101</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>98</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>466</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{2729b894-f261-493e-ae14-6ef55c22b962}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp21</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.27064220</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>90</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>489</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{822408bd-8276-4735-8b7e-64e6373a6436}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp22</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.17431193</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>82</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>512</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{c40cc99a-34d2-4c97-86cd-144ac86a8506}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp23</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.11467890</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>74</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>535</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{a720ffd9-34c9-4a02-9e4f-bf3b7610f8bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp24</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.06880734</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>66</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>558</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{01b8abe6-a770-4c67-8e38-af3265958a7f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp25</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.04587156</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>58</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>581</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{c616d1ee-a79d-4c8b-95db-3a82795dfe2f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp26</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.07798165</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>50</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>604</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{82997ddf-5de3-4f35-af72-a3d959ca27ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp27</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.06880734</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>42</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>627</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{6189af65-f099-453e-9947-65446943de8d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp28</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.06880734</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>34</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>650</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{a92b69ed-87d3-4b75-909d-a7a9cd25ec2a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp29</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.06880734</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>26</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>673</x>
  <y>254</y>
  <width>23</width>
  <height>240</height>
  <uuid>{3bedb0a5-3967-4aa9-91b4-bccc6cdc2e95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp30</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.06880734</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>18</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>0</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{bebe5079-eb12-4209-a08d-5f5f09bb0249}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>23</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{2936bf24-558f-4b80-a383-3f55d9a0613b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>46</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{da5de12a-b860-40f4-b21f-de8ae3aa3f4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>69</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{02dde0df-5bc1-4d93-b1bc-f259f352d040}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>92</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{796ce824-985f-42c0-9f20-37eb01cc553c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>115</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{e51a977a-38be-43d8-b11c-3f80bb97a868}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>138</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{20307a92-e974-49ed-bb4d-c0d432fadec9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>161</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{1de61282-b0a2-4469-a769-0059565071f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>184</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{fd21c525-af29-4f0a-9c25-f468d9ed2ec9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>9</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>207</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{89191514-f0a9-4136-8530-afcc2c257e74}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>230</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{38c069a6-8f85-4e9b-8a43-24b87e47fcee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>11</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>253</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{2f3b42f7-98dc-46bc-9409-954bc3a82dfd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>12</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>276</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{3b7c09dd-248f-4525-8c43-f292aaa3adaf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>13</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>299</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{58a43bf3-4541-4177-9b99-6b06a5810e63}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>14</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>322</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{2dd44392-1051-4f3c-abc7-df89e49ec9bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>15</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>345</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{8e0b9bd2-9de2-4df3-a47e-7ced584e8fba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>16</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>368</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{f858b48c-f8d3-4934-af72-5e6db4e1c693}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>17</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>391</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{17c9065a-3ac6-48ae-b558-613166ad3e58}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>18</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>414</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{c3790294-741b-4fb4-9fe5-df4da2044ce0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>19</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>437</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{7e741b54-c3f5-4e13-96c8-a3c257418bd0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>460</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{f7b4c772-2833-4f3f-84bc-f5fb36b09f19}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>21</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>483</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{8a747a88-cd77-4ab0-9171-bdd1b1a80378}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>22</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>506</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{3daba4ed-bb22-4439-a69b-1108f87c6874}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>23</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>529</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{fab9ac5a-c055-4e86-bf5e-a33a06ff4d27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>24</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>552</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{11e972c3-2d5d-4168-bd4a-6348d8a97d2d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>25</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>575</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{ee7d179f-8e22-4988-894c-4ae287f7fc50}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>26</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>598</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{3eaa98db-0139-4ba7-a1a7-81d7b947c8cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>27</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>621</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{4cb30025-b2f7-48a5-8099-8d53d4039f23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>28</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>644</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{7f1256e9-c172-4d59-a571-8dddfb8a4382}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>29</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>667</x>
  <y>490</y>
  <width>34</width>
  <height>30</height>
  <uuid>{d7ff9654-507e-428b-8c68-fbd814469bdd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>30</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>16</fontsize>
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
  <x>574</x>
  <y>636</y>
  <width>120</width>
  <height>59</height>
  <uuid>{636e97c4-43a5-4f44-80e7-f980122d5ea4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     ON  : GUI
     OFF : MIDI</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>574</x>
  <y>601</y>
  <width>120</width>
  <height>30</height>
  <uuid>{366135f8-6288-401f-a4a4-ae6fe5dbee88}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Zero Amplitudes</text>
  <image>/</image>
  <eventLine>i 7 0 0</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>574</x>
  <y>570</y>
  <width>120</width>
  <height>30</height>
  <uuid>{b3205c4c-78d6-43f5-8384-e0e0fae60c6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Randomize Ratios</text>
  <image>/</image>
  <eventLine>i 6 0 0</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>574</x>
  <y>539</y>
  <width>120</width>
  <height>30</height>
  <uuid>{83a9fcde-fffc-4c2e-ac67-372d7fffbd44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Harmonic Ratios</text>
  <image>/</image>
  <eventLine>i 5 0 0</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Reverb_Mix</objectName>
  <x>369</x>
  <y>585</y>
  <width>190</width>
  <height>25</height>
  <uuid>{455da1c8-4be3-4570-83d5-4ff227ee4457}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.60000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Reverb_Time</objectName>
  <x>369</x>
  <y>623</y>
  <width>190</width>
  <height>25</height>
  <uuid>{062f993a-87f2-4f21-b398-018d1166de33}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.01000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.91663158</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Reverb_LPF</objectName>
  <x>369</x>
  <y>661</y>
  <width>190</width>
  <height>25</height>
  <uuid>{17a13324-db75-4638-84ca-b0287f0c3376}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.85263158</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Attack_Time</objectName>
  <x>369</x>
  <y>547</y>
  <width>90</width>
  <height>25</height>
  <uuid>{f4bea88a-8049-437a-acfa-31f669889097}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00100000</minimum>
  <maximum>4.00000000</maximum>
  <value>0.00100000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Release_Time</objectName>
  <x>469</x>
  <y>547</y>
  <width>90</width>
  <height>25</height>
  <uuid>{28c14a55-ce41-4703-9b38-418c1a826377}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00100000</minimum>
  <maximum>4.00000000</maximum>
  <value>0.97853333</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Fund_Freq</objectName>
  <x>9</x>
  <y>584</y>
  <width>350</width>
  <height>25</height>
  <uuid>{69309652-f713-4dd0-b520-49486e6c7e52}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.53142857</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Amp_Fund_Port</objectName>
  <x>9</x>
  <y>622</y>
  <width>350</width>
  <height>25</height>
  <uuid>{2705340c-af8f-433b-bedd-aa9db4f9a028}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01000000</minimum>
  <maximum>5.00000000</maximum>
  <value>1.44997143</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Ratio_Port</objectName>
  <x>9</x>
  <y>660</y>
  <width>350</width>
  <height>25</height>
  <uuid>{87e86776-8fe4-4981-9162-ed88b554f6e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01000000</minimum>
  <maximum>20.00000000</maximum>
  <value>9.45527500</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Amplitude</objectName>
  <x>9</x>
  <y>546</y>
  <width>350</width>
  <height>25</height>
  <uuid>{8a14277c-afa8-45a5-ace8-5d2915ea5e92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.54285714</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>562</y>
  <width>250</width>
  <height>28</height>
  <uuid>{90e77ec2-c864-4052-9958-660916d85676}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude</label>
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
  <y>600</y>
  <width>250</width>
  <height>28</height>
  <uuid>{d1d4f59f-333c-4a2c-bfc1-98a1d4298c3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fundamental Frequency</label>
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
  <y>638</y>
  <width>250</width>
  <height>28</height>
  <uuid>{981a37b9-0045-401b-ba79-316a29d20395}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude / Fundamental Portamento</label>
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
  <y>676</y>
  <width>250</width>
  <height>28</height>
  <uuid>{7447e1dd-6413-418f-adc3-aacc0623c016}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Ratios Portamento</label>
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
  <objectName>Amplitude</objectName>
  <x>300</x>
  <y>562</y>
  <width>60</width>
  <height>24</height>
  <uuid>{d9d06dcf-6371-48d5-93a1-0902b7baaa0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.543</label>
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
  <objectName>Amp_Fund_Port</objectName>
  <x>300</x>
  <y>637</y>
  <width>60</width>
  <height>24</height>
  <uuid>{b7d30610-1b15-4c6a-95c5-7ed2fd3dfe59}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.450</label>
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
  <objectName>Fund_Freq_Value</objectName>
  <x>300</x>
  <y>599</y>
  <width>60</width>
  <height>24</height>
  <uuid>{924e11d1-7442-4902-8a31-1c62de36bd66}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>227.164</label>
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
  <x>369</x>
  <y>567</y>
  <width>120</width>
  <height>28</height>
  <uuid>{b827c24c-61e0-4288-8bf2-80d34172061b}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>369</x>
  <y>601</y>
  <width>120</width>
  <height>28</height>
  <uuid>{78b43402-664d-490c-8b92-4ed43002b989}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Mix</label>
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
  <x>369</x>
  <y>639</y>
  <width>120</width>
  <height>28</height>
  <uuid>{201b0deb-e1c8-4ff5-969e-80af3c4ae58c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Time</label>
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
  <x>469</x>
  <y>567</y>
  <width>120</width>
  <height>28</height>
  <uuid>{4511ebbb-8cf1-48a8-b1fe-2185944eeed6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release Time</label>
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
  <x>368</x>
  <y>677</y>
  <width>120</width>
  <height>28</height>
  <uuid>{fa916ee9-3823-4073-a295-d0302517f235}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb LPF</label>
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
  <x>702</x>
  <y>2</y>
  <width>308</width>
  <height>700</height>
  <uuid>{98b7a1a5-d6d9-49a9-8537-da493951e3a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Instructions and Info</label>
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
   <r>170</r>
   <g>170</g>
   <b>170</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>704</x>
  <y>29</y>
  <width>301</width>
  <height>618</height>
  <uuid>{8730b9fb-ec3d-473c-b451-e68000ad3b13}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------


One of the drawbacks of additive synthesis is the vast number parameters that must be defined in the synthesis of a sound of any complexity. This can be a slow and unspontaneous process.

This example suggests a method in which slider values for partial amplitudes can be sketched in sweeping movements of the mouse rather than having to be dragged up or down one by one.
Sketching is done on the joystick panel at the top of the GUI.
The sliders below this, display the current values for all partials but adjusting these sliders themselves will have no effect.                                                   

This example makes extensive use of macros in order to avoid lengthy repetitions of code.
Reverb is added and is adjustable and also portamento is independently adjustable for partial amplitudes, fundemental and frequency ratios.
Frequency ratios can be randomized using the on-screen button.</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio1</objectName>
  <x>6</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{d0f37361-a55e-4660-9d45-9776c3a149b5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>250</b>
  </bgcolor>
  <value>1.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio17</objectName>
  <x>374</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{a2d576af-b41a-4392-8146-6b325d2a018d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>122</b>
  </bgcolor>
  <value>17.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio18</objectName>
  <x>397</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{d62f7992-e96b-4988-94ad-76c6d9b6504d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>114</b>
  </bgcolor>
  <value>18.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio19</objectName>
  <x>420</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{29fcb66f-92af-4565-923f-5d142ee12f79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>106</b>
  </bgcolor>
  <value>19.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio8</objectName>
  <x>167</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{20f38226-4b9b-4f27-a4f8-84726057b675}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>194</b>
  </bgcolor>
  <value>8.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio9</objectName>
  <x>190</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{3c8fac50-5d2c-428c-8561-3e98635e6c00}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>186</b>
  </bgcolor>
  <value>9.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio10</objectName>
  <x>213</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{012deb8b-14f6-4cec-910f-b43981b74c06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>178</b>
  </bgcolor>
  <value>10.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio5</objectName>
  <x>98</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{ed3832c1-928e-4319-8440-63765dc32715}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>218</b>
  </bgcolor>
  <value>5.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio6</objectName>
  <x>121</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{1ae390a1-fb49-45da-9b43-94c95de8d076}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>210</b>
  </bgcolor>
  <value>6.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio7</objectName>
  <x>144</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{40a00b97-723d-4219-934d-8a8aa6921eb1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>202</b>
  </bgcolor>
  <value>7.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio2</objectName>
  <x>29</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{30a8a1d1-183e-4081-a9b6-93ec1d14ba05}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>242</b>
  </bgcolor>
  <value>2.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio3</objectName>
  <x>52</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{d953553b-1be1-4601-9ab3-197f67e49f72}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>234</b>
  </bgcolor>
  <value>3.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio4</objectName>
  <x>75</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{44e13382-957b-436b-a388-502de9588f31}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>226</b>
  </bgcolor>
  <value>4.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio11</objectName>
  <x>236</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{66533f28-d0c1-4b1f-b6b6-81140d465d0a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>170</b>
  </bgcolor>
  <value>11.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio12</objectName>
  <x>259</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{73e4c0c4-0d95-4a5d-b1d6-a059120c5713}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>162</b>
  </bgcolor>
  <value>12.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio13</objectName>
  <x>282</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{0db04ae5-a711-43a0-ab20-35027728626e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>154</b>
  </bgcolor>
  <value>13.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio14</objectName>
  <x>305</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{ee39afdd-084e-49ea-85a9-dedda64eac6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>146</b>
  </bgcolor>
  <value>14.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio15</objectName>
  <x>328</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{9c1bc0bb-b126-4c47-9f83-f447c6321247}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>138</b>
  </bgcolor>
  <value>15.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio16</objectName>
  <x>351</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{e9d85952-1231-45d7-9bc1-34a8c285cfa8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>130</b>
  </bgcolor>
  <value>16.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio20</objectName>
  <x>443</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{029d3762-9bf0-4275-a22b-94f98cd9b427}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>98</b>
  </bgcolor>
  <value>20.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio21</objectName>
  <x>466</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{d5c5a13a-2f76-48c9-aa8a-27636a2204eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>90</b>
  </bgcolor>
  <value>21.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio22</objectName>
  <x>489</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{c0b793d1-0daf-4ad8-a6a5-df7745adf9bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>82</b>
  </bgcolor>
  <value>22.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio23</objectName>
  <x>512</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{5339e0ed-39c7-4b01-aca9-9ca0dabdb79d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>74</b>
  </bgcolor>
  <value>23.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio24</objectName>
  <x>535</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{59167812-b6ab-478e-90b3-1142a7939bef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>66</b>
  </bgcolor>
  <value>24.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio25</objectName>
  <x>558</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{da2a4286-8b09-4ab5-a7e7-44bde8750ded}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>58</b>
  </bgcolor>
  <value>25.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio26</objectName>
  <x>581</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{1a45174d-b54d-4ae5-8665-df6e99ab302d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>50</b>
  </bgcolor>
  <value>26.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio27</objectName>
  <x>604</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{1929df2c-3fa4-4a6a-8359-adaf796f83a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>42</b>
  </bgcolor>
  <value>27.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio28</objectName>
  <x>627</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{12be7caa-2bfc-4789-b2e6-8d54040c3f1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>34</b>
  </bgcolor>
  <value>28.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio29</objectName>
  <x>650</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{7ebbd809-7401-4c93-a828-43ae77cbb7cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>26</b>
  </bgcolor>
  <value>29.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>Ratio30</objectName>
  <x>673</x>
  <y>515</y>
  <width>23</width>
  <height>18</height>
  <uuid>{90fdd750-3121-4fe5-ba4d-a289cfe73cb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>18</b>
  </bgcolor>
  <value>30.00000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.12500000</minimum>
  <maximum>30.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>529</y>
  <width>100</width>
  <height>28</height>
  <uuid>{071735c5-a197-48ec-a19c-cda1cab25cf0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Freq Ratios</label>
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
  <objectName>Ratio_Port</objectName>
  <x>300</x>
  <y>675</y>
  <width>60</width>
  <height>24</height>
  <uuid>{11a5e2d2-f3d4-4183-a9aa-e6e682cd8136}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>9.455</label>
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

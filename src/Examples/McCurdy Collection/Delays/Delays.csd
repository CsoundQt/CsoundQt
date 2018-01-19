;WRITTEN BY IAIN MCCURDY 2010

; Modified for QuteCsound by René, September 2010
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 32		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


		zakinit		3,3	;DECLARE ZAK SPACE


instr	1	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkinput		invalue	"Input"
		gkNTaps		invalue	"No_Taps"			;init 30

		gkInGain		invalue 	"Input_Gain"		;init 0.5
		gkTotTime		invalue 	"Total_Time"		;init 2.5
		gkTimeCurve	invalue 	"Time_Curve"		;init -3
		gkAmpEnv		invalue 	"Amp_Env"			;init 0.3
		gkAmpCurve	invalue 	"Amp_Curve"		;init -3

		gkFiltOnOff	invalue	"Filter"			;init 1
		gkLPFEnv		invalue 	"LPF_Env"			;init 0.15
		gkLPFCurve	invalue 	"LPF_Curve"		;init -3
		gkLPFOffset	invalue 	"LPF_Offset"		;init 20
		gkLPFRes		invalue 	"LPF_Resonance"	;init 0.5

		gkPanDep		invalue 	"Pan_Depth"		;init 0.5
		gkDryGain		invalue 	"Dry_Gain"		;init 0
		gkDelaysGain	invalue 	"Delays_Gain"		;init 1
	endif
endin

;TECHNIQUE OF ITERATION WITHIN A UDO WAS INSPIRED BY STEVEN YI'S ARTICLE IN SUMMER 2006 CSOUND JOURNAL - THANKS STEVEN!
;UDOS=============================================================================================================================================================================
opcode delaytap, 0, kiiiiii	;DEFINE UDO. NO OUTPUTS (AUDIO IS WRITTEN TO ZAK SPACE). ONE K-RATE INPUT, SIX I-RATE INPUTS.
	kLPFRes, iTimeTable, iAmpTable, iLPFTable, itaps, ipan, icount  xin				;NAME INPUT ARGUMENTS
	itime	tablei	(icount-1)/itaps, iTimeTable, 1							;READ DELAY TIME OF CURRENT TAP FROM FUNCTION TABLE WITH TABLE NUMBER iTimeTable (CREATED IN INSTR 3)
	iamp		table	(icount-1)/itaps, iAmpTable, 1							;READ AMPLITUDE OF CURRENT TAP FROM FUNCTION TABLE WITH TABLE NUMBER iAmpTable (CREATED IN INSTR 3)
	;prints	"Count%d Time%5.2f Amp%5.2f\\n", icount, itime, iamp					;PRINTING LINE - USE FOR CHECKING AND TROUBLE SHOOTING
	a1		deltap	itime												;CREATE DELAY TAP
	if	gkFiltOnOff=0	goto	SKIP
	iLPFoct	tablei	(icount-1)/itaps, iLPFTable, 1							;READ FILTER CUTOFF OF CURRENT TAP FROM FUNCTION TABLE WITH TABLE NUMBER iLPFTable (CREATED IN INSTR 3)
	a1		moogvcf	a1, cpsoct(iLPFoct), kLPFRes								;APPLY RESONANT LOWPASS FILTER
	SKIP:
	ipan		init	abs(ipan-1)												;PAN POSITION ALTERNATING BETWEEN LEFT AND RIGHT
	a1,a2	pan2	a1*2, ((ipan*gkPanDep) + (0.5 * (1 - gkPanDep)))					;PANNING APPLIED USING pan2 OPCODE, DEPTH OF PANNING EFFECT IS DEFINED BY 'Pan Depth' SLIDER
			zawm	a1*iamp, 0												;MIX LEFT CHANNEL AUDIO AUDIO INTO ZAK VARIABLE						
			zawm	a2*iamp, 1												;MIX RIGHT CHANNEL AUDIO AUDIO INTO ZAK VARIABLE
	icount	=	icount + 1												;INCREMENT TAP COUNTER
	if	icount<=itaps	then													;CHECK IF WE ARE ON THE FINAL TAP, IF NOT, CALL delaytap UDO AGAIN
			delaytap	kLPFRes, iTimeTable, iAmpTable, iLPFTable, itaps, ipan, icount	;CALL delaytap UDO
	endif																;END OF CONDITIONAL BRANCHING
endop
;================================================================================================================================================================================

instr	2	;GENERATE NOTE EVENTS FOR INPUT SIGNAL
	if	gkinput=0	then
		kdur		random		0.01,0.1					;NOTE DURATION SLIGHTLY RANDOMISED
		ktrig	metro		1/(gkTotTime+0.5)			;NOTE EVENT TRIGGER IS TIMED TO OCCUR ONCE EVERY DELAY CYCLE
				schedkwhen	ktrig, 0, 0, 3, 0, kdur		;TRIGGER NOTE EVENT IN INSTRUMENT 2
	else
		a1	inch		1								;READ LIVE AUDIO IN FROM COMPUTER INPUT (CHANNEL 1)
			zawm		a1*gkInGain, 2						;WRITE AUDIO (WITH MIXING) TO ZAK VARIABLE CHANNEL 2	
	endif
endin
	
instr	3	;INPUT SIGNAL - A SHORT 'BLIP' SOUND
	aenv		expsega	1,p3,0.001						;PERCUSSIVE TYPE AMPLITUDE ENVELOPE
	ioct		random	6, 12							;OSCILLATOR PITCH (OCT FORMAT) SLIGHTLY RANDOMISED
	a1		pinkish	1								;PINK NOISE
	icfoct	random	8,13								;GENERATE A RANDOM CUTOFF FREQUENCY FOR UPCOMIMG LOW-PASS FILTER
	a1		butlp	a1, cpsoct(icfoct)					;FILTER AUDIO SIGNAL
			zawm		a1*aenv, 2						;WRITE AUDIO (WITH MIXING) TO ZAK VARIABLE CHANNEL 2
endin

instr	4	;(ALWAYS ON - SEE SCORE) PLAYS FILE AND SENSES FADER MOVEMENT AND RESTARTS INSTR 2 FOR I-RATE CONTROLLERS
	ktrig	changed	gkNTaps, gkTotTime, gkTimeCurve, gkAmpEnv, gkAmpCurve, gkLPFEnv, gkLPFCurve, gkLPFOffset			;IF ANY OF THE LISTED K-RATE VARIABLES ARE CHANGED PART OF THIS INSTRUMENT GENERATE A MOMENTARY 1 VALUE IN THE OUTPUT ktrig 
	if	(ktrig == 1)	then								;IF ktrig=1 ...
		reinit	RESTART								;REINITIALISE FROM LABEL 'RESTART'
	endif											;END OF CONDITIONAL BRANCHING

	RESTART:											;LABEL
	;GENERATE TABLE OF DELAY TIMES============================================================================================================================================
	iTimeTable	ftgen	1,0,4096,-16, 1/kr, 4096, i(gkTimeCurve) , i(gkTotTime)	;TABLE OF DELAY TIMES DEFINES AS A UUSER DEFINABLE CURVE (DELAY OFFSET IS 1/kr)
	;=========================================================================================================================================================================
	
	;GENERATE TABLE OF AMPLITUDES=============================================================================================================================================
	iAmpStart		=		(1 - i(gkAmpEnv)) * 2								;AMPLITUDE ENVELOPE START VALUE DEFINED WITH RESPECT TO gkAmpEnv CONTROL
	iAmpStart		limit	iAmpStart, 0, 1									;LIMIT VALUES BETWEEN 0 AND 1
	iAmpEnd		=		i(gkAmpEnv) * 2									;AMPLITUDE ENVELOPE END VALUE DEFINED WITH RESPECT TO gkAmpEnv CONTROL
	iAmpEnd		limit	iAmpEnd, 0, 1         								;LIMIT VALUES BETWEEN 0 AND 1                                
	iAmpTable		ftgen	2,0,4096,-16, iAmpStart, 4096, i(gkAmpCurve), iAmpEnd		;DEFINE AMPLITUDE ENVELOPE THAT WILL BE APPLIED OVER THE ENTIRE DELAY CYCLE
	;=========================================================================================================================================================================

	if	gkFiltOnOff=0	goto	SKIP
	;GENERATE TABLE OF FILTER CUTOFF VALUES===================================================================================================================================
	iLPFStart		=		((1-i(gkLPFEnv))*i(gkLPFOffset))+4						;LOW-PASS FILTER ENVELOPE START VALUE DEFINED WITH RESPECT TO gkLPFEnv CONTROL
	iLPFStart		limit	iLPFStart, 4, 14									;LIMIT VALUES BETWEEN 4 AND 14
	iLPFEnd		=		(i(gkLPFEnv)*i(gkLPFOffset))+4						;LOW-PASS FILTER ENVELOPE END VALUE DEFINED WITH RESPECT TO gkLPFEnv CONTROL
	iLPFEnd		limit	iLPFEnd, 4, 14          								;LIMIT VALUES BETWEEN 4 AND 14                                
	iLPFTable		ftgen	3,0,4096,-16, iLPFStart, 4096, i(gkLPFCurve) , iLPFEnd		;DEFINE LOW-PASS FILTER ENVELOPE THAT WILL BE APPLIED OVER THE ENTIRE DELAY CYCLE
	;=========================================================================================================================================================================
	SKIP:
	icount		init	1													;DELAY TAP COUNTER IS INITIALISED
	ipan			init	0													;ipan VARIABLE IS DEFINED
	ain			zar	2													;READ (INPUT) AUDIO FROM ZAK VARIABLE
	abuffer		delayr	i(gkTotTime)										;DEFINE ENTIRE DELAY BUFFER	
				delaytap	gkLPFRes, iTimeTable, iAmpTable, iLPFTable, i(gkNTaps), ipan, icount		;CALL UDO delaytap
				delayw	ain												;WRITE AUDIO INTO DELAY BUFFER
				rireturn													;RETURN FROM INITIALISATION PASS
	aL			zar		0												;READ DELAY TAPS LEFT CHANNEL MIX FROM ZAK VARIABLE
	aR			zar		1												;READ DELAY TAPS RIGHT CHANNEL MIX FROM ZAK VARIABLE 
	adry			delay	ain, 1/kr											;DELAY INPUT SIGNAL TO ALIGN DRY SIGNAL WITH FIRST DELAY TAP
				outs		(aL * gkDelaysGain) + (adry * gkDryGain), (aR * gkDelaysGain) + (adry * gkDryGain)			;SEND AUDIO TO OUTPUTS
				zacl		0, 2												;CLEAR ZAK VARIABLES
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 1		0	   3600	;GUI
i 2  	0	   3600	;INSTRUMENT 2 INPUT 
i 4  	0	   3600	;INSTRUMENT 4 CREATES DELAYS
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>911</width>
 <height>666</height>
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
  <width>516</width>
  <height>630</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delays</label>
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
   <r>158</r>
   <g>220</g>
   <b>217</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Input_Gain</objectName>
  <x>10</x>
  <y>69</y>
  <width>500</width>
  <height>27</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>86</y>
  <width>120</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input Gain</label>
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
  <objectName>Input_Gain</objectName>
  <x>450</x>
  <y>86</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.502</label>
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
  <x>519</x>
  <y>2</y>
  <width>381</width>
  <height>630</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delays</label>
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
   <r>158</r>
   <g>220</g>
   <b>217</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>523</x>
  <y>24</y>
  <width>374</width>
  <height>605</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>---------------------------------------------------------------------------------------
This example implements a multitap delay in which the number of taps can be redefined in real time by the user from the interface. This is made possible through UDO (user defined opcode) recursion. For more information on this technique it is recommended to study the code and comments and to also read Steven Yi's article 'Control Flow - Part II' in the summer 2006 Csound Journal. Delay tap times are defined as subdivisions of the 'Total Time' - these times can be evenly space or warped according to a curve defined by the 'Time Curve' control.
This curve is created using GEN 16. If displays are enabled you can view changes made to this table (table number 1) in real time. Using this feature 'bounce' delay effects and 'reverse bounce' delay effects can be created. In a similar way, an envelope that is applied across all of delay taps is created and modified using the controls 'Amp. Env.' and 'Amp. Curve' controls. 'Amp. Env' defines whether the envelope is building, decaying or flat. Once again the results are visible as table 2 if table displays are not suppressed. Thirdly a resonant lowpass filter with envelope control can be applied across the entire delay sequence. Its shape can be viewed as 'ftable 3'. A panning effect is implemented in which delay taps are alternately sent to the left and right channels in ping-pong delay fashion. The depth of this effect is controllable using the 'Pan Depth' slider. To test the effect short percussive noise 'blips' are generated, one for each delay cycle. It would be a simple operation to adapt this example to read live audio or a sound file as input. Alternatively the computer's live input can also be used.
Use of the resonant lowpass filter feature in this example can be rather CPU intensive, particularly if many delay taps are being employed. For this reason the filter section can be bypassed with its on/off switch if realtime operation glitches.</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pan_Depth</objectName>
  <x>450</x>
  <y>515</y>
  <width>60</width>
  <height>30</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.478</label>
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
  <x>10</x>
  <y>555</y>
  <width>120</width>
  <height>30</height>
  <uuid>{b57ba536-8f28-4986-9bf7-8eb84262d8ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry Gain</label>
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
  <objectName>Pan_Depth</objectName>
  <x>10</x>
  <y>498</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b8fa76b9-3d04-4156-a2f2-a413d3864da3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.47800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Dry_Gain</objectName>
  <x>450</x>
  <y>555</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5f670bb1-e411-4f17-94a3-2321fdf5742b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.066</label>
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
  <objectName>Dry_Gain</objectName>
  <x>10</x>
  <y>538</y>
  <width>500</width>
  <height>27</height>
  <uuid>{1920efdc-fe11-4010-a22c-50efec0c27d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.06600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>515</y>
  <width>120</width>
  <height>30</height>
  <uuid>{aea841b2-29e6-42d6-ac23-02439b1cc47f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pan Depth</label>
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
  <objectName>Delays_Gain</objectName>
  <x>10</x>
  <y>578</y>
  <width>500</width>
  <height>27</height>
  <uuid>{afe11ed2-eb11-423d-a391-3677ebeda4f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.94400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Delays_Gain</objectName>
  <x>450</x>
  <y>595</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d6bd3764-66b6-499b-8028-0113ff526003}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.944</label>
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
  <x>10</x>
  <y>595</y>
  <width>120</width>
  <height>30</height>
  <uuid>{4100a5b8-76c3-4420-9229-a606f4defaf9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delays Gain</label>
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
  <x>4</x>
  <y>275</y>
  <width>512</width>
  <height>215</height>
  <uuid>{3f5593ef-7c12-450e-aff5-44d762f347f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>132</r>
   <g>184</g>
   <b>181</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>126</y>
  <width>120</width>
  <height>30</height>
  <uuid>{6d8d92f5-813d-4e91-867e-f3384b0baf9d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Total Time</label>
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
  <objectName>Total_Time</objectName>
  <x>10</x>
  <y>109</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8fbaf396-5ad3-4de9-b5fe-cf9991b23868}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>10.00000000</maximum>
  <value>2.67400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Total_Time</objectName>
  <x>450</x>
  <y>126</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0a5ba1c3-3448-4200-9a48-c116a64fc284}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2.674</label>
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
  <objectName>Amp_Env</objectName>
  <x>450</x>
  <y>206</y>
  <width>60</width>
  <height>30</height>
  <uuid>{31926c84-b4be-4a4a-95dd-55b8aa1f8bfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.358</label>
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
  <objectName>Amp_Env</objectName>
  <x>10</x>
  <y>189</y>
  <width>500</width>
  <height>27</height>
  <uuid>{01ae35ea-9999-4552-9643-c8c7ea0bb59c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.35800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>206</y>
  <width>120</width>
  <height>30</height>
  <uuid>{b5ee6bae-137d-481b-9a16-dae92d4768ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp. Env.</label>
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
  <objectName>Time_Curve</objectName>
  <x>450</x>
  <y>166</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d222ecd6-24d8-48d4-b675-543b710ce87d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-2.432</label>
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
  <x>10</x>
  <y>166</y>
  <width>120</width>
  <height>30</height>
  <uuid>{963ea626-d7d6-49e8-bf88-13d574ae8247}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Time Curve</label>
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
  <objectName>Time_Curve</objectName>
  <x>10</x>
  <y>149</y>
  <width>500</width>
  <height>27</height>
  <uuid>{fdf77624-2665-499f-8b72-d6cbb2638117}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-8.00000000</minimum>
  <maximum>8.00000000</maximum>
  <value>-2.43200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amp_Curve</objectName>
  <x>450</x>
  <y>247</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e15c6c87-0607-4cc2-b44d-d0ddfc7d1f5e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-3.520</label>
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
  <x>10</x>
  <y>247</y>
  <width>120</width>
  <height>30</height>
  <uuid>{706810f3-b68a-404b-8586-12d2f4abeec7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp. Curve</label>
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
  <objectName>Amp_Curve</objectName>
  <x>10</x>
  <y>230</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f5f323eb-20ec-4442-976a-42ccd5860020}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-8.00000000</minimum>
  <maximum>8.00000000</maximum>
  <value>-3.52000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>LPF_Offset</objectName>
  <x>10</x>
  <y>401</y>
  <width>500</width>
  <height>27</height>
  <uuid>{6cf25638-221a-46d7-a8e5-7f908964de74}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>20.00000000</maximum>
  <value>19.56000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>418</y>
  <width>120</width>
  <height>30</height>
  <uuid>{457bf65a-4c72-4afa-9707-e4e6075454dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LPF Offset</label>
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
  <objectName>LPF_Offset</objectName>
  <x>450</x>
  <y>418</y>
  <width>60</width>
  <height>30</height>
  <uuid>{90b60fba-0e6a-427e-a220-3005ea58a6af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>19.560</label>
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
  <objectName>LPF_Resonance</objectName>
  <x>10</x>
  <y>441</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8c0f5eb2-4487-4910-b540-92f9c7977b23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.90000000</maximum>
  <value>0.50580000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>LPF_Resonance</objectName>
  <x>450</x>
  <y>458</y>
  <width>60</width>
  <height>30</height>
  <uuid>{50c1ab62-d50f-46a1-be62-736ef32aaee8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.506</label>
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
  <objectName>LPF_Curve</objectName>
  <x>450</x>
  <y>378</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d421bda5-a807-4f06-a88e-072a843e0bac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-3.296</label>
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
  <objectName>LPF_Curve</objectName>
  <x>10</x>
  <y>361</y>
  <width>500</width>
  <height>27</height>
  <uuid>{679f5118-a333-41e5-a3c8-ad0e4ef46216}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-8.00000000</minimum>
  <maximum>8.00000000</maximum>
  <value>-3.29600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>378</y>
  <width>120</width>
  <height>30</height>
  <uuid>{b8553519-9e18-4b38-9911-b09ae673984c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LPF Curve</label>
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
  <objectName>LPF_Env</objectName>
  <x>450</x>
  <y>338</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4fc920c5-89fc-42ac-b971-6368a1da516f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.164</label>
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
  <x>10</x>
  <y>338</y>
  <width>120</width>
  <height>30</height>
  <uuid>{932be6f9-41e4-4c21-afea-272e9553989b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LPF Env.</label>
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
  <objectName>LPF_Env</objectName>
  <x>10</x>
  <y>321</y>
  <width>500</width>
  <height>27</height>
  <uuid>{c3b93e51-b294-4779-a982-283e96fb07ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.16400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Filter</objectName>
  <x>10</x>
  <y>282</y>
  <width>100</width>
  <height>29</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     Filter</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>No_Taps</objectName>
  <x>83</x>
  <y>23</y>
  <width>59</width>
  <height>30</height>
  <uuid>{890238cb-c576-4212-9773-1738ea599f1a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>20</fontsize>
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
  <maximum>128</maximum>
  <randomizable group="0">false</randomizable>
  <value>30</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>3</x>
  <y>23</y>
  <width>80</width>
  <height>30</height>
  <uuid>{4f4b4fc5-86b2-4033-b3ca-1ce395613cec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>No of Taps</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>409</x>
  <y>23</y>
  <width>100</width>
  <height>29</height>
  <uuid>{3158b0e2-b91c-41af-8c0e-eff18094154c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Blips</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Live</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>348</x>
  <y>23</y>
  <width>60</width>
  <height>30</height>
  <uuid>{78ab42b4-bf04-4aaa-bc1c-ea879b382489}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Inputs</label>
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
  <x>10</x>
  <y>458</y>
  <width>120</width>
  <height>30</height>
  <uuid>{bdc52510-0b86-4734-a2aa-ca16b69dcf2a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LPF Resonance</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

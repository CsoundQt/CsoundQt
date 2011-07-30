;Written by Iain McCurdy, 2010


;Modified for QuteCsound by René, April 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817
;	On/Off latched button light is saved in presets, so light goes off when changing preset


;Notes on modifications from original csd:
;	Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files
;	Delayed reverb start to avoid "INIT ERROR in instr 2: illegal loop time"
;	Use QuteCsound Presets


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 32			;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1


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
		gkingain		invalue	"LiveGain"
		gkmix		invalue	"Mix"
		gkinput		invalue	"Input"

		gklpt1		invalue	"LoopTime1"
		gklpt2		invalue	"LoopTime2"
		gklpt3		invalue	"LoopTime3"
		gklpt4		invalue	"LoopTime4"
		gklpt5		invalue	"LoopTime5"
		gklpt6		invalue	"LoopTime6"

		gkrvt1		invalue	"RvbTime1"
		gkrvt2		invalue	"RvbTime2"
		gkrvt3		invalue	"RvbTime3"
		gkrvt4		invalue	"RvbTime4"
		gkrvt5		invalue	"RvbTime5"
		gkrvt6		invalue	"RvbTime6"
	endif
endin

instr	1	;PLAYS FILE AND OUTPUTS GLOBAL VARIABLES
	if	gkinput==0	then										;IF FILE INPUT IS SELECTED...
		Sfile		invalue	"_Browse1"
		gasigL, gasigR	FilePlay2	Sfile, 1, 0, 1						;GENERATE 2 AUDIO SIGNALS FROM A SOUND FILE (NOTE THE USE OF GLOBAL VARIABLES)		
	else														;OTHERWISE
		asigL, asigR	ins										;TAKE INPUT FROM COMPUTER'S AUDIO INPUT
		gasigL	=	asigL * gkingain							;SCALE USING 'Input Gain' SLIDER
		gasigR	=	asigR * gkingain							;SCALE USING 'Input Gain' SLIDER
	endif													;END OF CONDITIONAL BRANCHING
endin

instr	2	;REVERB - ALWAYS ON
	ktrigger	changed	gklpt1, gklpt2, gklpt3, gklpt4, gklpt5, gklpt6	;IF ANY OF THE INPUT ARGUMENTS CHANGES GENERATE A MOMENTARY '1' VALUE (BAND)
	if ktrigger=1 then											;IF QUERY IS TRUE...
		reinit	UPDATE										;BEGIN A REINITIALIZATION PASS FROM LABEL 'UPDATE' IN ORDER TO FORCE AN UPDATE OF I-RATE CONTROLLERS
	endif													;END OF THIS CONDITIONAL BRANCH

	UPDATE:													;LABEL CALLED 'UPDATE'
	a1		comb		gasigL, gkrvt1, i(gklpt1)					;COMB FILTER 1
	a2		comb		gasigL, gkrvt2, i(gklpt2)					;COMB FILTER 2
	a3		comb		gasigL, gkrvt3, i(gklpt3)					;COMB FILTER 3
	a4		comb		gasigL, gkrvt4, i(gklpt4)					;COMB FILTER 4
	aSum		sum		a1,a2,a3,a4								;MIX THE OUTPUT FROM THE FOUR COMB FILTERS
	a5		alpass	aSum, gkrvt5, i(gklpt5)						;SEND THE MIXED OUTPUT INTO THE FIRST ALLPASS FILTER
	aRvb		alpass	a5, gkrvt6,   i(gklpt6)						;SEND THE OUTPUT OF THE FIRST ALLPASS FILTER INTO THE SECOND ALLPASS FILTER
			rireturn											;RETURN FROM REINITIALIZATION PASS (IF APPLICABLE)
	amix		ntrpol	aRvb, gasigL, gkmix							;CREATE A MIX BETWEEN THE WET AND DRY SIGNALS. CONTROLLABLE BY THE USER FROM AN ON SCREEN SLIDER
			outs		amix*0.7, amix*0.7							;SEND WET/DRY MIX AUDIO TO OUTPUTS
			clear	gasigL									;CLEAR GLOBAL AUDIO VARIABLES
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0.0	   3600	;GUI
i  2		0.5	   3600	;REVERB INSTRUMENT PLAYS FOR 1 HOUR (AND KEEPS PERFORMANCE GOING)
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>426</x>
 <y>182</y>
 <width>922</width>
 <height>571</height>
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
  <width>396</width>
  <height>416</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
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
   <r>158</r>
   <g>220</g>
   <b>158</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>400</x>
  <y>2</y>
  <width>517</width>
  <height>416</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Schroeder Reverb</label>
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
   <r>158</r>
   <g>220</g>
   <b>158</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>404</x>
  <y>229</y>
  <width>511</width>
  <height>186</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------------------------------------
The Schroeder reverb represents a reverb design that was invented in the early 1960s and that has been used often since. Today, with increases in computing power, more elaborate designs have replaced the Schroeder design but it is still used and in fact Csound's freeverb is based on it. In the Schroeder algorithm the input sound is passed through four or more comb filters in parallel and the mix of their outputs in passed through two allpass filters in series. The layout of the controls for the filters in the GUI opposite therefore reflects this scheme as the signal passes from top to bottom. The comb filters create the main body of the reverb and the allpass filters serve to 'scatter' ringing artefacts created by the comb filters.</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>14</y>
  <width>92</width>
  <height>130</height>
  <uuid>{18adc638-dc9e-4360-9161-a6deaece4f61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Comb 1</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>6</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>LoopTime1</objectName>
  <x>14</x>
  <y>42</y>
  <width>80</width>
  <height>25</height>
  <uuid>{15c492fd-5d92-4a0e-a671-377808d9085e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>0.02970000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.00010000</minimum>
  <maximum>0.50000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>64</y>
  <width>80</width>
  <height>30</height>
  <uuid>{6255d00a-3fec-468c-a96f-94cac7f5bfe1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>RvbTime1</objectName>
  <x>14</x>
  <y>92</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7414dac7-8131-4e10-bc4e-d0447f28cca6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>5.00000000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.01000000</minimum>
  <maximum>20.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>114</y>
  <width>80</width>
  <height>30</height>
  <uuid>{c43c9baf-b9e3-4612-a93f-fcbc8146ed57}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>105</x>
  <y>14</y>
  <width>92</width>
  <height>130</height>
  <uuid>{90bf81b4-a6d5-40d2-872f-cdc27398303b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Comb 2</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>6</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>LoopTime2</objectName>
  <x>111</x>
  <y>42</y>
  <width>80</width>
  <height>25</height>
  <uuid>{65099784-d4a5-40df-8bd7-da5dd69f3392}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>0.03710000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.00010000</minimum>
  <maximum>0.50000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>111</x>
  <y>64</y>
  <width>80</width>
  <height>30</height>
  <uuid>{171d13cd-0a69-4854-a8fc-3421ba541ecf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>RvbTime2</objectName>
  <x>111</x>
  <y>92</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7ffce508-d2a1-4cde-a7d8-f442709a887c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>5.00000000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.01000000</minimum>
  <maximum>20.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>111</x>
  <y>114</y>
  <width>80</width>
  <height>30</height>
  <uuid>{a4bb026d-ca8e-4fe6-909c-42e50a3f1171}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>202</x>
  <y>14</y>
  <width>92</width>
  <height>130</height>
  <uuid>{b66863f7-8231-4f29-ad7e-151657173ecf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Comb 3</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>6</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>LoopTime3</objectName>
  <x>208</x>
  <y>42</y>
  <width>80</width>
  <height>25</height>
  <uuid>{9224f65e-884c-441b-86ae-93cfe9f28b05}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>0.04110000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.00010000</minimum>
  <maximum>0.50000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>208</x>
  <y>64</y>
  <width>80</width>
  <height>30</height>
  <uuid>{40efb71a-7e5f-4448-a65e-b2f711a8ae4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>RvbTime3</objectName>
  <x>208</x>
  <y>92</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f7d68c66-ecab-4152-94c4-8560e11311b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>5.00000000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.01000000</minimum>
  <maximum>20.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>208</x>
  <y>114</y>
  <width>80</width>
  <height>30</height>
  <uuid>{97e67539-6a32-48d4-9919-314828fe647f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>299</x>
  <y>14</y>
  <width>92</width>
  <height>130</height>
  <uuid>{2e3b654d-8cb4-444d-bf8e-b6d8793d2358}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Comb 4</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>6</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>LoopTime4</objectName>
  <x>305</x>
  <y>42</y>
  <width>80</width>
  <height>25</height>
  <uuid>{73e0491c-e4b2-4935-8f54-272823abeba5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>0.04370000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.00010000</minimum>
  <maximum>0.50000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>305</x>
  <y>64</y>
  <width>80</width>
  <height>30</height>
  <uuid>{4dff1ddd-0d6d-494c-92a4-93b83917459f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>RvbTime4</objectName>
  <x>305</x>
  <y>92</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4d60d18a-90e7-41f5-90ac-1a788a54bd46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>5.00000000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.01000000</minimum>
  <maximum>20.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>305</x>
  <y>114</y>
  <width>80</width>
  <height>30</height>
  <uuid>{2f6d5adc-0fe0-4cdf-93a9-ba40a938e96a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>153</x>
  <y>149</y>
  <width>92</width>
  <height>130</height>
  <uuid>{5cfba94c-0dda-4f8c-a4c7-7058e69b54a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Alpass 1</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>6</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>LoopTime5</objectName>
  <x>159</x>
  <y>177</y>
  <width>80</width>
  <height>25</height>
  <uuid>{eb11b513-2d14-4b97-8b3b-79715149a2df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>0.09683000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.00010000</minimum>
  <maximum>0.50000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>159</x>
  <y>199</y>
  <width>80</width>
  <height>30</height>
  <uuid>{1af47329-fa91-4e81-923b-cfa9bd1a4cc9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>RvbTime5</objectName>
  <x>159</x>
  <y>227</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5997d549-0e11-41e5-81fb-7c8bbae4d261}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>2.00000000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.01000000</minimum>
  <maximum>20.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>159</x>
  <y>249</y>
  <width>80</width>
  <height>30</height>
  <uuid>{400ecdeb-f616-4b4f-a3ac-9b0c997afe73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>153</x>
  <y>282</y>
  <width>92</width>
  <height>130</height>
  <uuid>{135b5447-4fe0-4c49-bf87-238f6baa2d16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Alpass 2</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>6</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>LoopTime6</objectName>
  <x>159</x>
  <y>310</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c49e5858-a370-427e-9ebf-4b610151f6aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>0.03292000</value>
  <resolution>0.00100000</resolution>
  <minimum>0.00010000</minimum>
  <maximum>0.50000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>159</x>
  <y>332</y>
  <width>80</width>
  <height>30</height>
  <uuid>{70d7d6d5-8b87-4754-8b83-0abdec3df5e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>RvbTime6</objectName>
  <x>159</x>
  <y>360</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e126b938-9da7-4076-8c0b-75487d47ce32}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>255</g>
   <b>103</b>
  </bgcolor>
  <value>2.70000005</value>
  <resolution>0.00100000</resolution>
  <minimum>0.01000000</minimum>
  <maximum>20.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>159</x>
  <y>382</y>
  <width>80</width>
  <height>30</height>
  <uuid>{8a98f9ba-6a10-4f77-ad8a-9f15c53adc66}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Time</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>409</x>
  <y>14</y>
  <width>100</width>
  <height>26</height>
  <uuid>{59afdeab-3d0a-4ec7-b256-5059df601de4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>   ON / OFF</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>409</x>
  <y>63</y>
  <width>120</width>
  <height>30</height>
  <uuid>{f5af2a56-4d3a-4209-bf6e-d910f0880e72}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Live input Gain</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>LiveGain</objectName>
  <x>849</x>
  <y>63</y>
  <width>60</width>
  <height>30</height>
  <uuid>{681b4d93-d322-42de-b247-477b5c108db6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.052</label>
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
  <x>490</x>
  <y>195</y>
  <width>120</width>
  <height>26</height>
  <uuid>{395c88b5-8a25-40c2-a698-72ce16e96264}</uuid>
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
    <name> Live Input</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>408</x>
  <y>195</y>
  <width>80</width>
  <height>26</height>
  <uuid>{6f2943df-facf-440e-900b-33493bced504}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>409</x>
  <y>132</y>
  <width>170</width>
  <height>30</height>
  <uuid>{cb5adcf7-a56f-40e9-a436-3326a882467d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>808loopMono.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>581</x>
  <y>133</y>
  <width>328</width>
  <height>28</height>
  <uuid>{4bcdbfa2-0e10-47c3-99c8-701cf9ccf00e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>808loopMono.wav</label>
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
   <r>240</r>
   <g>235</g>
   <b>226</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>581</x>
  <y>161</y>
  <width>328</width>
  <height>34</height>
  <uuid>{aa414945-b880-44e6-a26b-9cde8b733b57}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Restart the instrument after changing the audio file.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <objectName>LiveGain</objectName>
  <x>409</x>
  <y>47</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5ca7e105-304c-40ab-b5b2-891b7c34584f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.05200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>409</x>
  <y>101</y>
  <width>172</width>
  <height>33</height>
  <uuid>{14a6ebc7-ecc1-4f41-864a-0f7ea9ddb3cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Wet / Dry Mix</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Mix</objectName>
  <x>849</x>
  <y>101</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4016c830-7ceb-4117-8bda-f62caf289600}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.800</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Mix</objectName>
  <x>409</x>
  <y>86</y>
  <width>500</width>
  <height>27</height>
  <uuid>{88e2e2a5-6399-4283-b902-0d4beae241f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.80000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>_SetPresetIndex</objectName>
  <x>756</x>
  <y>195</y>
  <width>130</width>
  <height>26</height>
  <uuid>{54c9994b-1b56-4bb8-8565-31f778c5141d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Small Room</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Medium Room</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Medium Hall</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Large Hall</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>3</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>673</x>
  <y>196</y>
  <width>80</width>
  <height>26</height>
  <uuid>{c58c5007-2e70-4113-a4a9-264c359d6734}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Presets</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>420</y>
  <width>915</width>
  <height>149</height>
  <uuid>{3b417eb3-d142-4dbf-8f63-523f0513f5ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
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
   <r>158</r>
   <g>220</g>
   <b>158</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>419</y>
  <width>912</width>
  <height>147</height>
  <uuid>{f425298d-d946-497c-a051-bbed3c7b07f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>The key to minimizing ringing artefacts is chosing appropriate values of the loop times of the filters. If values are too low ringing will become obvious but if they are too large individual echoes will be heard in a 'grainy' sounding reverb tail. Loop times should all be different and should be prime to prevent periodicity between different filters which would again result in ringing artefacts. In this example all controls for each filter are included but obviously in a finished instrument multiple parameters would be combined within a more descriptive global control named something live reverb time or room size. To emulate smaller room reverbs in will be necessary to reduce some of the loop times, particularly those of the allpass filters in order for this to be possible. This basic Schroeder can be quickly improved upon by incorporating additional comb filters and perhaps one or two additional allpass filters. Adding too many allpass filters will delay the onset of the reverb tail excessively. Four preset change reverb time and loop times for all filters and offer suggested starting points for different reverb effects.</label>
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
</bsbPanel>
<bsbPresets>
<preset name="Small Room" number="0" >
<value id="{15c492fd-5d92-4a0e-a671-377808d9085e}" mode="1" >0.02970000</value>
<value id="{7414dac7-8131-4e10-bc4e-d0447f28cca6}" mode="1" >0.30000001</value>
<value id="{65099784-d4a5-40df-8bd7-da5dd69f3392}" mode="1" >0.03710000</value>
<value id="{7ffce508-d2a1-4cde-a7d8-f442709a887c}" mode="1" >0.30000001</value>
<value id="{9224f65e-884c-441b-86ae-93cfe9f28b05}" mode="1" >0.04110000</value>
<value id="{f7d68c66-ecab-4152-94c4-8560e11311b1}" mode="1" >0.30000001</value>
<value id="{73e0491c-e4b2-4935-8f54-272823abeba5}" mode="1" >0.04370000</value>
<value id="{4d60d18a-90e7-41f5-90ac-1a788a54bd46}" mode="1" >0.30000001</value>
<value id="{eb11b513-2d14-4b97-8b3b-79715149a2df}" mode="1" >0.02968000</value>
<value id="{5997d549-0e11-41e5-81fb-7c8bbae4d261}" mode="1" >0.10000000</value>
<value id="{c49e5858-a370-427e-9ebf-4b610151f6aa}" mode="1" >0.02329000</value>
<value id="{e126b938-9da7-4076-8c0b-75487d47ce32}" mode="1" >0.10000000</value>
<value id="{59afdeab-3d0a-4ec7-b256-5059df601de4}" mode="1" >0.00000000</value>
<value id="{59afdeab-3d0a-4ec7-b256-5059df601de4}" mode="4" >0</value>
<value id="{681b4d93-d322-42de-b247-477b5c108db6}" mode="1" >0.05200000</value>
<value id="{681b4d93-d322-42de-b247-477b5c108db6}" mode="4" >0.052</value>
<value id="{395c88b5-8a25-40c2-a698-72ce16e96264}" mode="1" >0.00000000</value>
<value id="{cb5adcf7-a56f-40e9-a436-3326a882467d}" mode="4" >808loopMono.wav</value>
<value id="{4bcdbfa2-0e10-47c3-99c8-701cf9ccf00e}" mode="4" >808loopMono.wav</value>
<value id="{5ca7e105-304c-40ab-b5b2-891b7c34584f}" mode="1" >0.05200000</value>
<value id="{4016c830-7ceb-4117-8bda-f62caf289600}" mode="1" >0.89999998</value>
<value id="{4016c830-7ceb-4117-8bda-f62caf289600}" mode="4" >0.900</value>
<value id="{88e2e2a5-6399-4283-b902-0d4beae241f8}" mode="1" >0.89999998</value>
<value id="{54c9994b-1b56-4bb8-8565-31f778c5141d}" mode="1" >3.00000000</value>
</preset>
<preset name="Medium Room" number="1" >
<value id="{15c492fd-5d92-4a0e-a671-377808d9085e}" mode="1" >0.02970000</value>
<value id="{7414dac7-8131-4e10-bc4e-d0447f28cca6}" mode="1" >0.80000001</value>
<value id="{65099784-d4a5-40df-8bd7-da5dd69f3392}" mode="1" >0.03710000</value>
<value id="{7ffce508-d2a1-4cde-a7d8-f442709a887c}" mode="1" >0.80000001</value>
<value id="{9224f65e-884c-441b-86ae-93cfe9f28b05}" mode="1" >0.04110000</value>
<value id="{f7d68c66-ecab-4152-94c4-8560e11311b1}" mode="1" >0.80000001</value>
<value id="{73e0491c-e4b2-4935-8f54-272823abeba5}" mode="1" >0.04370000</value>
<value id="{4d60d18a-90e7-41f5-90ac-1a788a54bd46}" mode="1" >0.80000001</value>
<value id="{eb11b513-2d14-4b97-8b3b-79715149a2df}" mode="1" >0.01297000</value>
<value id="{5997d549-0e11-41e5-81fb-7c8bbae4d261}" mode="1" >0.05000000</value>
<value id="{c49e5858-a370-427e-9ebf-4b610151f6aa}" mode="1" >0.01233000</value>
<value id="{e126b938-9da7-4076-8c0b-75487d47ce32}" mode="1" >0.05000000</value>
<value id="{59afdeab-3d0a-4ec7-b256-5059df601de4}" mode="1" >0.00000000</value>
<value id="{59afdeab-3d0a-4ec7-b256-5059df601de4}" mode="4" >0</value>
<value id="{681b4d93-d322-42de-b247-477b5c108db6}" mode="1" >0.05200000</value>
<value id="{681b4d93-d322-42de-b247-477b5c108db6}" mode="4" >0.052</value>
<value id="{395c88b5-8a25-40c2-a698-72ce16e96264}" mode="1" >0.00000000</value>
<value id="{cb5adcf7-a56f-40e9-a436-3326a882467d}" mode="4" >808loopMono.wav</value>
<value id="{4bcdbfa2-0e10-47c3-99c8-701cf9ccf00e}" mode="4" >808loopMono.wav</value>
<value id="{5ca7e105-304c-40ab-b5b2-891b7c34584f}" mode="1" >0.05200000</value>
<value id="{4016c830-7ceb-4117-8bda-f62caf289600}" mode="1" >0.85000002</value>
<value id="{4016c830-7ceb-4117-8bda-f62caf289600}" mode="4" >0.850</value>
<value id="{88e2e2a5-6399-4283-b902-0d4beae241f8}" mode="1" >0.85000002</value>
<value id="{54c9994b-1b56-4bb8-8565-31f778c5141d}" mode="1" >3.00000000</value>
</preset>
<preset name="Medim Hall" number="2" >
<value id="{15c492fd-5d92-4a0e-a671-377808d9085e}" mode="1" >0.02970000</value>
<value id="{7414dac7-8131-4e10-bc4e-d0447f28cca6}" mode="1" >2.00000000</value>
<value id="{65099784-d4a5-40df-8bd7-da5dd69f3392}" mode="1" >0.03710000</value>
<value id="{7ffce508-d2a1-4cde-a7d8-f442709a887c}" mode="1" >2.00000000</value>
<value id="{9224f65e-884c-441b-86ae-93cfe9f28b05}" mode="1" >0.04110000</value>
<value id="{f7d68c66-ecab-4152-94c4-8560e11311b1}" mode="1" >2.00000000</value>
<value id="{73e0491c-e4b2-4935-8f54-272823abeba5}" mode="1" >0.04370000</value>
<value id="{4d60d18a-90e7-41f5-90ac-1a788a54bd46}" mode="1" >2.00000000</value>
<value id="{eb11b513-2d14-4b97-8b3b-79715149a2df}" mode="1" >0.03297000</value>
<value id="{5997d549-0e11-41e5-81fb-7c8bbae4d261}" mode="1" >0.50000000</value>
<value id="{c49e5858-a370-427e-9ebf-4b610151f6aa}" mode="1" >0.04233000</value>
<value id="{e126b938-9da7-4076-8c0b-75487d47ce32}" mode="1" >0.50000000</value>
<value id="{59afdeab-3d0a-4ec7-b256-5059df601de4}" mode="1" >0.00000000</value>
<value id="{59afdeab-3d0a-4ec7-b256-5059df601de4}" mode="4" >0</value>
<value id="{681b4d93-d322-42de-b247-477b5c108db6}" mode="1" >0.05200000</value>
<value id="{681b4d93-d322-42de-b247-477b5c108db6}" mode="4" >0.052</value>
<value id="{395c88b5-8a25-40c2-a698-72ce16e96264}" mode="1" >0.00000000</value>
<value id="{cb5adcf7-a56f-40e9-a436-3326a882467d}" mode="4" >808loopMono.wav</value>
<value id="{4bcdbfa2-0e10-47c3-99c8-701cf9ccf00e}" mode="4" >808loopMono.wav</value>
<value id="{5ca7e105-304c-40ab-b5b2-891b7c34584f}" mode="1" >0.05200000</value>
<value id="{4016c830-7ceb-4117-8bda-f62caf289600}" mode="1" >0.85000002</value>
<value id="{4016c830-7ceb-4117-8bda-f62caf289600}" mode="4" >0.850</value>
<value id="{88e2e2a5-6399-4283-b902-0d4beae241f8}" mode="1" >0.85000002</value>
<value id="{54c9994b-1b56-4bb8-8565-31f778c5141d}" mode="1" >3.00000000</value>
</preset>
<preset name="Large Hall" number="3" >
<value id="{15c492fd-5d92-4a0e-a671-377808d9085e}" mode="1" >0.02970000</value>
<value id="{7414dac7-8131-4e10-bc4e-d0447f28cca6}" mode="1" >5.00000000</value>
<value id="{65099784-d4a5-40df-8bd7-da5dd69f3392}" mode="1" >0.03710000</value>
<value id="{7ffce508-d2a1-4cde-a7d8-f442709a887c}" mode="1" >5.00000000</value>
<value id="{9224f65e-884c-441b-86ae-93cfe9f28b05}" mode="1" >0.04110000</value>
<value id="{f7d68c66-ecab-4152-94c4-8560e11311b1}" mode="1" >5.00000000</value>
<value id="{73e0491c-e4b2-4935-8f54-272823abeba5}" mode="1" >0.04370000</value>
<value id="{4d60d18a-90e7-41f5-90ac-1a788a54bd46}" mode="1" >5.00000000</value>
<value id="{eb11b513-2d14-4b97-8b3b-79715149a2df}" mode="1" >0.09683000</value>
<value id="{5997d549-0e11-41e5-81fb-7c8bbae4d261}" mode="1" >2.00000000</value>
<value id="{c49e5858-a370-427e-9ebf-4b610151f6aa}" mode="1" >0.03292000</value>
<value id="{e126b938-9da7-4076-8c0b-75487d47ce32}" mode="1" >2.70000005</value>
<value id="{59afdeab-3d0a-4ec7-b256-5059df601de4}" mode="1" >0.00000000</value>
<value id="{59afdeab-3d0a-4ec7-b256-5059df601de4}" mode="4" >0</value>
<value id="{681b4d93-d322-42de-b247-477b5c108db6}" mode="1" >0.05200000</value>
<value id="{681b4d93-d322-42de-b247-477b5c108db6}" mode="4" >0.052</value>
<value id="{395c88b5-8a25-40c2-a698-72ce16e96264}" mode="1" >0.00000000</value>
<value id="{cb5adcf7-a56f-40e9-a436-3326a882467d}" mode="4" >808loopMono.wav</value>
<value id="{4bcdbfa2-0e10-47c3-99c8-701cf9ccf00e}" mode="4" >808loopMono.wav</value>
<value id="{5ca7e105-304c-40ab-b5b2-891b7c34584f}" mode="1" >0.05200000</value>
<value id="{4016c830-7ceb-4117-8bda-f62caf289600}" mode="1" >0.80000001</value>
<value id="{4016c830-7ceb-4117-8bda-f62caf289600}" mode="4" >0.800</value>
<value id="{88e2e2a5-6399-4283-b902-0d4beae241f8}" mode="1" >0.80000001</value>
<value id="{54c9994b-1b56-4bb8-8565-31f778c5141d}" mode="1" >3.00000000</value>
</preset>
</bsbPresets>

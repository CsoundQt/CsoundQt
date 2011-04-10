;PIANO PHASE BY STEVE REICH 
;CSOUND IMPLEMENTATION BY IAIN MCCURDY, 2010

;Modified for QuteCsound by René, February 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;This instrument needs the analysis files PPhase1.pvx and PPhase2.pvx to be in SADIR (Menu Configure/Environment)


;Notes on modifications from original csd:
;	Removed Tempo_2 change -> Tempo_1 update when LinkTempi is activated (values instabilities)


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;SWITCHES
		gkAutoPhase1	invalue	"AutoPhase_1"
		gkAutoPhase2	invalue	"AutoPhase_2"
		gkLinkTempi	invalue	"LinkTempi"

		;SLIDERS
		gkphs1		invalue	"Phase_1"
		gkphs2		invalue	"Phase_2"
		gkamp1		invalue	"Gain_1"
		gkamp2		invalue	"Gain_2"
		gkbal1		invalue	"Balance_1"
		gkbal2		invalue	"Balance_2"
		gkrate1		invalue	"Rate_1"
		gkrate2		invalue	"Rate_2"

		;COUNTERS
		gktrans1		invalue	"Transpose_1"
		gktrans2		invalue	"Transpose_2"
		gkfine1		invalue	"FineTune_1"
		gkfine2		invalue	"FineTune_2"
		gktempo1		invalue	"Tempo_1"
		gktempo2		invalue	"Tempo_2"
	endif
endin

instr	1
	if	gkLinkTempi==1	then										;IF 'LINK TEMPI' IS ACTIVE...
		ktrig1	changed	gktempo1								;IF TEMPO 1 IS CHANGED ktrig1 IS A MOMENTARY '1'
		if ktrig1 == 1 then
			outvalue	"Tempo_2", gktempo1							;UPDATE TEMPO 2 WITH THE VALUE OF TEMPO 1 IF TEMPO 1 HAS BEEN CHANGED
		endif
	endif
	
	kporttime		linseg	0,.01,.01,1, .01						;RAMPING UP VALUE THAT WILL BE USED FOR PORTAMENTO TIME
	
	ilen			=		1.636								;LENGTH OF LOOP
	
	;LOOP 1===================================================================================================================================
	kPBratio1	=	gktempo1/120														;PLAYBACK SPEED RATIO
	if		gkAutoPhase1==0	then													;IF 'AUTO PHASE' IS NOT ACTIVE...
		kphs1	portk	gkphs1/12, kporttime										;PHASE WILL BE SLIDER PHASE VALUE (WITH PORTAMENTO SMOOTHING)
	elseif	gkAutoPhase1==1	then													;IF 'AUTO PHASE' IS ACTIVE...
		kphs1	phasor	gkrate1													;PHASE WILL BE DERIVE FROM A MOVING PHASE VALUE GENERATOR
		kupdate1	metro	10														;RATE OF SLIDER UPDATE (USED FOR VISUAL FEEDBACK ONLY)
		if kupdate1 == 1 then	
				outvalue	"Phase_1", kphs1*12											;UPDATE ON-SCREEN SLIDER
		endif
	endif																		;END OF CONDITIONAL BRANCHING

	aptr1		osciliktp 	kPBratio1/ilen, 1, kphs1									;CREATE POINTER FOR READING FFT ANALYSIS FILE
	kptr1		downsamp		aptr1												;DOWN-SAMPLE TO K-RATE
	fsig1L  		pvsfread		kptr1*ilen, "PPhase1.pvx", 0								;READ FFT ANALYSIS FILE         
	fsig1L2		pvscale		fsig1L, cpsoct(8+(gktrans1/12)+(gkfine1/1200))/cpsoct(8)		;RESCALE PITCH                  
	asig1L 		pvsynth  		fsig1L2												;RESYNTHESIZE TO AN AUDIO SIGNAL
	fsig1R  		pvsfread		kptr1*ilen, "PPhase1.pvx", 1								;READ FFT ANALYSIS FILE         
	fsig1R2		pvscale		fsig1R, cpsoct(8+(gktrans1/12)+(gkfine1/1200))/cpsoct(8)		;RESCALE PITCH                  
	asig1R 		pvsynth  		fsig1R2												;RESYNTHESIZE TO AN AUDIO SIGNAL
	;=========================================================================================================================================
	
	;LOOP 2===================================================================================================================================
	kPBratio2	=	gktempo2/120														;PLAYBACK SPEED RATIO                                        
	if		gkAutoPhase2==0	then             							               ;IF 'AUTO PHASE' IS NOT ACTIVE...                            
		kphs2	portk		gkphs2/12, kporttime									;PHASE WILL BE SLIDER PHASE VALUE (WITH PORTAMENTO SMOOTHING)
	elseif	gkAutoPhase2==1	then											          ;IF 'AUTO PHASE' IS ACTIVE...                                
		kphs2	phasor		gkrate2   					                              ;PHASE WILL BE DERIVE FROM A MOVING PHASE VALUE GENERATOR    
		kupdate2	metro		10  													;RATE OF SLIDER UPDATE (USED FOR VISUAL FEEDBACK ONLY)       
		if kupdate2 == 1 then	
				outvalue	"Phase_2", kphs2*12											;UPDATE ON-SCREEN SLIDER
		endif
	endif																		;END OF CONDITIONAL BRANCHING                                

	aptr2		osciliktp 	kPBratio2/ilen, 1, kphs2									;CREATE POINTER FOR READING FFT ANALYSIS FILE                
	kptr2		downsamp		aptr2												;DOWN-SAMPLE TO K-RATE                                       
	fsig2L		pvsfread		kptr2*ilen, "PPhase2.pvx", 0								;READ FFT ANALYSIS FILE         
	fsig2L2		pvscale		fsig2L, cpsoct(8+(gktrans2/12)+(gkfine2/1200))/cpsoct(8)		;RESCALE PITCH                  
	asig2L 		pvsynth 	 	fsig2L2												;RESYNTHESIZE TO AN AUDIO SIGNAL
	fsig2R	  	pvsfread		kptr2*ilen, "PPhase2.pvx", 1								;READ FFT ANALYSIS FILE         
	fsig2R2		pvscale		fsig2R, cpsoct(8+(gktrans2/12)+(gkfine2/1200))/cpsoct(8)		;RESCALE PITCH                  
	asig2R 		pvsynth  		fsig2R2												;RESYNTHESIZE TO AN AUDIO SIGNAL
	;=========================================================================================================================================
	
	kamp1		lineto		gkamp1, 0.05											;SMOOTH VARIABLE FROM SLIDER
	kamp2		lineto		gkamp2, 0.05											;SMOOTH VARIABLE FROM SLIDER
	kbal1		lineto		gkbal1, 0.05											;SMOOTH VARIABLE FROM SLIDER
	kbal2		lineto		gkbal2, 0.05											;SMOOTH VARIABLE FROM SLIDER	
		
	gamixL		sum			asig1L*kamp1*(1-kbal1), asig2L*kamp2*(1-kbal2)				;CREATE LEFT CHANNEL MIX 
	gamixR		sum			asig1R*kamp1*kbal1,     asig2L*kamp2*kbal2					;CREATE RIGHT CHANNEL MIX 
endin

instr	2	;REVERB
	gkRoomSize	=		.85
	gkHFDamp		=		.5
	gkmix		=		.5
				denorm		gamixL, gamixR							;DENORMALIZE BOTH CHANNELS OF AUDIO SIGNAL
	arvbL, arvbR 	freeverb	 	gamixL, gamixR, gkRoomSize, gkHFDamp , sr
	amixL		ntrpol		gamixL, arvbL, gkmix					;CREATE A DRY/WET MIX BETWEEN THE DRY AND THE REVERBERATED SIGNAL
	amixR		ntrpol		gamixR, arvbR, gkmix					;CREATE A DRY/WET MIX BETWEEN THE DRY AND THE REVERBERATED SIGNAL
				outs			amixL, amixR
				clear		gamixL, gamixR
endin
</CsInstruments>
<CsScore>
f 1 0 1048576 7 0 1048576 1	;A SINGLE CYCLE OF A RISING SAWTOOTH

i 10 0 3600				;GUI
i  2 0 3600				;REVERB INSTRUMENT PLAYS A NOTE FOR 1 HOUR
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>451</x>
 <y>280</y>
 <width>1108</width>
 <height>629</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>241</r>
  <g>226</g>
  <b>185</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>3</x>
  <y>1</y>
  <width>1100</width>
  <height>626</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Piano Phase</label>
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
  <x>473</x>
  <y>77</y>
  <width>200</width>
  <height>30</height>
  <uuid>{78a7e9cd-fb57-421c-8e1f-40b60a90dfc0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Phase 1 Offset (semiquavers)</label>
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
  <objectName>Phase_1</objectName>
  <x>8</x>
  <y>50</y>
  <width>1088</width>
  <height>27</height>
  <uuid>{4b5d3fba-55d0-43d1-a94a-457bc9144a31}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Phase_1</objectName>
  <x>1036</x>
  <y>77</y>
  <width>60</width>
  <height>30</height>
  <uuid>{58265963-6245-459e-8071-9ed8bba850a4}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>427</y>
  <width>1090</width>
  <height>196</height>
  <uuid>{b8d89d7e-4717-4d91-a985-e6d317480e39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This example is an implementation of the piece 'Piano Phase' by the composer Steve Reich in which two pianos loop the same 1 bar motif but with one of the pianists occasionionally increasing his own tempo with respect to that of the other pianist so that his pattern 'overtakes' that of the other pianist to create a new phase relationship. This Csound implementation uses FFT resynthesis of an analysis of a recording of the pattern in order to allow the user to freely warp tempo and phase without inducing pitch warping. The two voices feature source recordings of the pattern played on two different pianos in order to prevent artificiality when both pianos are exactly in phase with one another. Firstly the user should explore different phase relationships by dragging the Phase Offset slider of one of the pianos to different locations. Phase offset values are given in semiquavers from 0 - 12 in order to reflect the 12 semiquaver motif from which the piece derives. It will be noticed that when both phase offset values are a whole number apart a rhythmic coherence results. Phase offset for each voice can be automated by activating 'Auto Phase' and setting the 'Rate' slider. A constantly shifting phase relationship between the two voices can also be achieved by slightly offsetting the tempo of one of the voices with respect to the other. The two tempi can also by synchronized (Tempo 1 change -> Tempo 2 update) by activating the 'Link Tempi' button.
The relationships between the two voices can be further explored through the individual 'Gain', 'Balance', 'Transpose' and 'Fine Tune' controls for each voice.</label>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>473</x>
  <y>134</y>
  <width>200</width>
  <height>30</height>
  <uuid>{b6dfb592-27a7-42e1-9af4-3b176bae36e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Phase 2 Offset (semiquavers)</label>
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
  <objectName>Phase_2</objectName>
  <x>8</x>
  <y>107</y>
  <width>1088</width>
  <height>27</height>
  <uuid>{72b19d18-2c57-4e3f-bfd8-4a2c7ed34074}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Phase_2</objectName>
  <x>1036</x>
  <y>134</y>
  <width>60</width>
  <height>30</height>
  <uuid>{533fea5d-cade-47f9-8a4e-828776aca488}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>190</y>
  <width>200</width>
  <height>30</height>
  <uuid>{73bae69e-5fa1-49fc-88d3-4975c6e34e87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Piano 1 Gain</label>
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
  <objectName>Gain_1</objectName>
  <x>8</x>
  <y>163</y>
  <width>540</width>
  <height>27</height>
  <uuid>{cb7dced8-50c6-4a15-86f3-e3dda415ffce}</uuid>
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
  <objectName>Gain_2</objectName>
  <x>1036</x>
  <y>190</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2ddeefc8-0a30-4a26-9029-aec505e4773a}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain_2</objectName>
  <x>556</x>
  <y>163</y>
  <width>540</width>
  <height>27</height>
  <uuid>{ca3f85ec-e185-47e2-b501-e14c9dfe9e20}</uuid>
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
  <objectName>Gain_1</objectName>
  <x>488</x>
  <y>190</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2bbbd97f-4a2a-4d33-80fe-efafe2fe3c54}</uuid>
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
  <x>556</x>
  <y>190</y>
  <width>200</width>
  <height>30</height>
  <uuid>{39db2a80-9944-4fe1-bfa2-094709881da4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Piano 2 Gain</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>246</y>
  <width>200</width>
  <height>30</height>
  <uuid>{37cfc0aa-3db8-41bb-bf6d-978607470f5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Piano 1 Balance</label>
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
  <objectName>Balance_1</objectName>
  <x>8</x>
  <y>219</y>
  <width>540</width>
  <height>27</height>
  <uuid>{44e6e37c-982c-4080-8cee-cd7e90d6e33f}</uuid>
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
  <objectName>Balance_2</objectName>
  <x>1036</x>
  <y>246</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dc88ce32-0f03-4615-b59c-1cdc1be37f95}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Balance_2</objectName>
  <x>556</x>
  <y>219</y>
  <width>540</width>
  <height>27</height>
  <uuid>{55e8cbc9-fe63-484e-8600-be66da068b1a}</uuid>
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
  <objectName>Balance_1</objectName>
  <x>488</x>
  <y>246</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e4651afe-d031-48e7-8ba6-f782c5edff09}</uuid>
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
  <x>556</x>
  <y>246</y>
  <width>200</width>
  <height>30</height>
  <uuid>{9757024e-e812-45bb-920b-3a318f398c9a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Piano 2 Balance</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>11</x>
  <y>12</y>
  <width>100</width>
  <height>30</height>
  <uuid>{bd6ab62e-6167-4972-b90f-c379535b493a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    On / Off  </text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>LinkTempi</objectName>
  <x>493</x>
  <y>290</y>
  <width>122</width>
  <height>30</height>
  <uuid>{8afdf365-ad6e-45c6-af14-d24e156091d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    Link Tempi  </text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>AutoPhase_1</objectName>
  <x>434</x>
  <y>360</y>
  <width>110</width>
  <height>30</height>
  <uuid>{25aa1158-5e4d-4f5a-b045-19c122049a1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> Auto Phase 1</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>AutoPhase_2</objectName>
  <x>560</x>
  <y>360</y>
  <width>110</width>
  <height>30</height>
  <uuid>{3ee6d5a4-4fc8-45fc-a8a6-ef92516f0b18}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> Auto Phase 2</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Tempo_1</objectName>
  <x>111</x>
  <y>290</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1580e5a2-d678-4b8d-8655-0678da288164}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <minimum>0</minimum>
  <maximum>999</maximum>
  <randomizable group="0">false</randomizable>
  <value>120</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>28</x>
  <y>293</y>
  <width>83</width>
  <height>42</height>
  <uuid>{784ac20d-28a3-48ad-9932-ddd8de0b0845}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tempo 1</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Transpose_1</objectName>
  <x>261</x>
  <y>290</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6748d041-177f-40e1-bce1-6699c02687bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <minimum>-24</minimum>
  <maximum>24</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>176</x>
  <y>287</y>
  <width>83</width>
  <height>42</height>
  <uuid>{f5e150fb-0af1-461b-bdec-207e7423e162}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Transpose 1
(Semitones)</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>FineTune_1</objectName>
  <x>411</x>
  <y>290</y>
  <width>60</width>
  <height>30</height>
  <uuid>{937588b8-5c9e-45ff-a7d9-6367b0a1eb51}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <minimum>-100</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>326</x>
  <y>287</y>
  <width>83</width>
  <height>42</height>
  <uuid>{8b31c3b5-7fea-4a65-882a-63d1e94e5f1b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fine Tune 1
(Cents)</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Tempo_2</objectName>
  <x>715</x>
  <y>290</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6515f6cf-83c3-48f9-b68c-331353a59496}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <minimum>0</minimum>
  <maximum>999</maximum>
  <randomizable group="0">false</randomizable>
  <value>120</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>632</x>
  <y>293</y>
  <width>83</width>
  <height>42</height>
  <uuid>{e6f8c02f-ae82-41bc-b491-730b105c0f36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tempo 2</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Transpose_2</objectName>
  <x>865</x>
  <y>290</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9f95e240-9a1a-43f3-aa8e-1616546ffb51}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <minimum>-24</minimum>
  <maximum>24</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>780</x>
  <y>287</y>
  <width>83</width>
  <height>42</height>
  <uuid>{025b97be-a870-41b7-a501-5257128343e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Transpose 2
(Semitones)</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>FineTune_2</objectName>
  <x>1015</x>
  <y>290</y>
  <width>60</width>
  <height>30</height>
  <uuid>{de832328-3d28-48a5-b279-960f0035a566}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <minimum>-100</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>930</x>
  <y>287</y>
  <width>83</width>
  <height>42</height>
  <uuid>{df60caba-b9a9-429b-9e72-0f1b93341149}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fine Tune 2
(Cents)</label>
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
  <y>391</y>
  <width>200</width>
  <height>30</height>
  <uuid>{0c53d072-8517-456d-b66c-237200233bfb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate 1</label>
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
  <objectName>Rate_1</objectName>
  <x>8</x>
  <y>360</y>
  <width>420</width>
  <height>27</height>
  <uuid>{c8a67a0b-0057-42e0-86fa-23293ba3f967}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>-0.01428571</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Rate_1</objectName>
  <x>368</x>
  <y>391</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d3ae0d03-960d-48eb-9d93-5d70fa511676}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-0.014</label>
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
  <x>677</x>
  <y>388</y>
  <width>200</width>
  <height>30</height>
  <uuid>{489ad298-a2a0-412b-86c2-1714b2dd7d08}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate 2</label>
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
  <objectName>Rate_2</objectName>
  <x>677</x>
  <y>360</y>
  <width>420</width>
  <height>27</height>
  <uuid>{1ed803c5-8c34-417e-8f05-b5fc97e6dffd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.02857143</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Rate_2</objectName>
  <x>1037</x>
  <y>388</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a9bbe549-b6ad-4bc5-85e2-72aea00e0fb1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.029</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

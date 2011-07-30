;Written by Iain McCurdy, 2011

;Modified for QuteCsound by René, May 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table for exp slider
;	Add Browser for audio file and use of FilePlay2 udo, accept mono or stereo wav files
;	Add denorm to moogladder input


;my flags on Ubuntu: -dm0 -iadc:system:capture_ -odac:system:playback_ -+rtaudio=jack  -b16 -B4096 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


		zakinit	4,4

gisine	ftgen	0,0,4096,10,1
gaCar	init		0
gk12_24	init		12

;TABLES FOR EXP SLIDER
giExp1	ftgen	0, 0, 129, -25, 0, 0.01, 128, 1.0
giExp2	ftgen	0, 0, 129, -25, 0, 1.0, 128, 12.0
giExp3	ftgen	0, 0, 129, -25, 0, 0.1, 128, 50.0
giExp4	ftgen	0, 0, 129, -25, 0, 40.0, 128, 10000.0


opcode VocoderChannel, 0, aaiiiii								;MODE UDO (K-RATE BASE FREQUENCY) - USED FOR NON-MIDI MODE 
	aMod,aCar,ibase,ibw,iincr,icount,inum  xin					;NAME INPUT VARIABLES
	icf		=		cpsmidinn(ibase+(icount*iincr))			;DERIVE FREQUENCY FOR *THIS* BANDPASS FILTER BASED ON BASE FREQUENCY AND FILTER NUMBER (icount)
	icount	=		icount + 1							;INCREMENT COUNTER IN PREPARTION FOR NEXT FILTER
			prints	"Band: %d %t Freq: %f %n",icount,icf		;PRINT DATA ABOUT FILTER NUMBER AND FREQUENCY TO THE TERMINAL

	if	icf>15000 goto SKIP									;IF FILTER FREQUENCY EXCEEDS A SENSIBLE LIMIT SKIP THE CREATION OF THIS FILTER AND END RECURSION
	aModF	butbp	aMod,icf,ibw*icf						;BANDPASS FILTER MODULATOR
	if gk12_24=24 then										;IF 24DB PER OCT MODE IS CHOSEN...
	  aModF	butbp	aModF,icf,ibw*icf						;...BANDPASS FILTER AGAIN TO SHARPEN CUTOFF SLOPES
	endif												;END OF THIS CONDITIONAL BRANCH
	aEnv 	follow2	aModF, 0.01, 0.01						;FOLLOW THE ENVELOPE OF THE FILTERED AUDIO

	aCarF	butbp	aCar,icf,ibw*icf						;BANDPASS FILTER CARRIER
	if gk12_24=24 then										;IF 24 DB PER OCT IS CHOSEN...
	  aCarF	butbp	aCarF,icf,ibw*icf						;...BANDPASS FILTER AGAIN TO SHARPEN CUTOFF SLOPES
	endif												;END OF THIS CONDITIONAL BRANCH
			zawm		aCarF*aEnv, 0							;MIX FILTERED CARRIER INTO THE ACCUMULATING ZAK AUDIO CHANNEL AND MODULATE ITS AMPLITUDE WITH THE MODULATOR ENVELOPE
	
	if	icount < inum	then									;IF MORE FILTERS STILL NEED TO BE CREATED...
		VocoderChannel	aMod,aCar,ibase,ibw,iincr,icount,inum		;...CALL UDO AGAIN WITH INCREMENTED COUNTER
	endif												;END OF THIS CONDITIONAL BRANCH
	SKIP:												;LABEL
endop													;END OF UDO

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
		;SPINBOXES
		gkbase		invalue	"BaseNote"
		gknum		invalue	"NumBands"
		gk12_24		invalue	"dBperOct"
		;MENUS
		gkModIn		invalue	"ModIn"
		gkCarIn		invalue	"CarIn"
		gkSynType		invalue	"SynType"
		;SLIDERS
		kbw			invalue	"Bandwidth"
		gkbw			tablei	kbw, giExp1, 1
					outvalue	"Bandwidth_Value", gkbw
		kincr		invalue	"BandSpacing"
		gkincr		tablei	kincr, giExp2, 1
					outvalue	"BandSpacing_Value", gkincr
		kBPGain		invalue	"BPGain"
		gkBPGain		tablei	kBPGain, giExp3, 1
					outvalue	"BPGain_Value", gkBPGain
		kHPGain		invalue	"HPGain"
		gkHPGain		tablei	kHPGain, giExp3, 1
					outvalue	"HPGain_Value", gkHPGain
		kLPF			invalue	"LPF"
		gkLPF		tablei	kLPF, giExp4, 1
					outvalue	"LPF_Value", gkLPF
		gkres		invalue	"Res"

		Sfile_new		strcpy	""							;INIT TO EMPTY STRING
		gSfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	gSfile
		gkfile 		strcmpk	Sfile_new, Sfile_old
	endif

			turnon	2									;VOCODER PLAYS
endin

instr	1	;SIMPLE MIDI SYNTH
	icps		cpsmidi										;READ MIDI NOTE IN CPS FORMAT
	aenv		linsegr		0,0.01,1,0.02,0					;CREATE A SIMPLE GATE-TYPE ENVELOPE

	if 	gkSynType=0	then									;IF SYNTH TYPE CHOSEN FROM BUTTON BANK GUI IS SAWTOOTH...
	  a1	vco2	1,icps										;...CREATE A SAWTOOTH WAVE TONE
	elseif gkSynType=1	then									;IF SYNTH TYPE CHOSEN FROM BUTTON BANK GUI IS SQUARE...
	  a1	vco2	1,icps,2,0.5									;...CREATE A SQUARE WAVE TONE
	elseif gkSynType=2	then									;IF SYNTH TYPE CHOSEN FROM BUTTON BANK GUI IS PULSE...
	  a1	vco2	1,icps,2,0.1									;...CREATE A PULSE WAVE TONE
	else													;OTHERWISE...
	  a1	pinkish	1										;...CREATE SOME PINK NOISE
	endif												;END OF THIS CONDITIONAL BRANCH
	gaCar	=	gaCar + (a1*aenv)							;APPLY ENVELOPE
endin

instr	2	;VOCODER
	ktrig	changed	gkbase,gkbw,gknum,gkincr,gkfile			;IF ANY OF THE INPUT VARIABLE ARE CHANGED GENERATE A MOMENTARY '1' VALUE (A BANG IN MAX-MSP LANGUAGE)
	if ktrig=1 then										;IF A CHANGED VALUE TRIGGER IS RECEIVED...
		reinit	UPDATE									;REINITIALISE THIS INSTRUMENT FROM THE LABEL 'UPDATE'
	endif												;END OF THIS CONDITIONAL BRANCH
	UPDATE:												;LABEL
	ibase	init	i(gkbase)									;CREATE AN INITIALISATION TIME VARIABLE FROM GUI CONTROL
	inum		init	i(gknum)									;CREATE AN INITIALISATION TIME VARIABLE FROM GUI CONTROL
	ibw		init	i(gkbw)									;CREATE AN INITIALISATION TIME VARIABLE FROM GUI CONTROL
	iincr	init	i(gkincr)									;CREATE AN INITIALISATION TIME VARIABLE FROM GUI CONTROL
	
	if gkModIn=0	then										;IF MODULATOR INPUT CHOSEN IS 'Audio File'...
	  aMod, asigR	FilePlay2	gSfile, 1, 0, 1					;...READ IN A SOUND FILE FROM HARD DISK
	else													;OTHERWISE...
	  aMod	inch		1									;READ LIVE AUDIO FROM THE COMPUTER'S LEFT INPUT CHANNEL
	endif												;END OF THIS CONDITIONAL BRANCH                                        

			denorm		gaCar							;to avoid high cpu load on my intel box !!!

	if gkCarIn=0	then										;IF 'Internal Synth' IS CHOSEN FOR CARRIER INPUT... 
	  aCar	moogladder	gaCar,gkLPF,gkres					;... USE INTERNAL SYNTH AUDIO FROM INSTR 1 AND APPLY A LOW PASS FILTER
	else													;OTHERWISE...
	  aCar	inch	2										;READ LIVE AUDIO FROM THE COMPUTER'S RIGHT CHANNEL INPUT CHANNEL
	endif												;END OF THIS CONDITIONAL BRANCH

	icount	init	0										;INITIALISE THE FILTER COUNTER TO ZERO
		VocoderChannel	aMod,aCar,ibase,ibw,iincr,icount,inum		;CALL 'VocoderChannel' UDO - (WILL RECURSE WITHIN THE UDO ITSELF FOR THEW REQUIRED NUMBER OF FILTERS
	amix		zar	0										;READ COMBINED FILTERS OUTPUT FROM ZAK CHANNEL
		
	;HIGH-PASS CHANNEL
	iHPcf	=		cpsmidinn(ibase+(inum*iincr)+1)			;HIGHPASS FILTER CUTOFF (ONE INCREMENT ABOVE THE HIGHEST BANDPASS FILTER)
	iHPcf	limit	iHPcf,2000,18000						;LIMIT THE HIGHPASS FILTER TO BE WITHIN SENSIBLE LIMITS
			prints	"HPF %t%t Freq: %f %n",iHPcf				;PRINT INFORMATION ABOUT THE HIGHPASS FILTER CUROPFF TO THE TERMINAL

	aModHP	buthp	aMod, iHPcf							;HIGHPASS FILTER THE MODULATOR
	aEnv		follow2	aModHP,0.01,0.01						;FOLLOW THE HIGHPASS FILTERED MODULATOR'S AMPLITUDE ENVELOPE
	aCarHP	buthp	aCar, iHPcf							;HIGHPASS FILTER THE CARRIER
	amix		=		(amix*gkBPGain)+(aCarHP*aEnv*gkHPGain)		;MIX THE HIGHPASS FILTERED CARRIER WITH THE BANDPASS FILTERS. APPLY THE MODULATOR'S ENVELOPE.

			outs		amix,amix								;SEND AUDIO TO THE OUTPUTS
			zacl		0,4
			clear	gaCar								;CLEAR THE INTERNAL SYNTH ACCUMULATING GLOBAL VARIABLE, READ FOR THE NEXT PERF. PASS
			rireturn										;RETURN FROM REINITIALISATION PASS. (NOT REALLY NEED AS THE endin FULFILS THE SAME FUNCTION.)
endin
			
instr	11	;INIT
		outvalue	"BaseNote"	, 40
		outvalue	"NumBands"	, 50
		outvalue	"dBperOct"	, 24
		outvalue	"Bandwidth"	, 0.7
		outvalue	"BandSpacing"	, 0.165
		outvalue	"BPGain"		, 0.482
		outvalue	"HPGain"		, 0.8063
		outvalue	"LPF"		, 0.8745
		outvalue	"Res"		, 0.0
endin	
</CsInstruments>
<CsScore>
i 10 0 3600	;GUI
i 11 0 0		;INIT
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>329</x>
 <y>160</y>
 <width>1036</width>
 <height>602</height>
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
  <width>1034</width>
  <height>600</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label> Analogue Style Vocoder</label>
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
  <x>9</x>
  <y>125</y>
  <width>200</width>
  <height>30</height>
  <uuid>{3ebc1139-1fdb-48dc-9150-49ee8dfdbd4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Band Spacing (semitones)</label>
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
  <objectName>BandSpacing</objectName>
  <x>9</x>
  <y>102</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2cf97843-5b49-438e-8034-62a459597e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.16500001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>BandSpacing_Value</objectName>
  <x>449</x>
  <y>125</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e54486c5-f9aa-4d0e-9a67-6506dae3c790}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.507</label>
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
  <x>9</x>
  <y>72</y>
  <width>200</width>
  <height>30</height>
  <uuid>{78a7e9cd-fb57-421c-8e1f-40b60a90dfc0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandwidth (octaves)</label>
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
  <objectName>Bandwidth</objectName>
  <x>9</x>
  <y>49</y>
  <width>500</width>
  <height>27</height>
  <uuid>{4b5d3fba-55d0-43d1-a94a-457bc9144a31}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.69999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Bandwidth_Value</objectName>
  <x>449</x>
  <y>72</y>
  <width>60</width>
  <height>30</height>
  <uuid>{58265963-6245-459e-8071-9ed8bba850a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.251</label>
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
  <x>9</x>
  <y>231</y>
  <width>200</width>
  <height>30</height>
  <uuid>{1c02d7bd-4198-417f-a816-a560f4133e23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Highpass Filter Gain</label>
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
  <objectName>HPGain</objectName>
  <x>9</x>
  <y>208</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e5fa660d-82a5-412a-a76a-500a0632ee0c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.80629998</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>HPGain_Value</objectName>
  <x>449</x>
  <y>231</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8341c14a-4acb-4d3d-824f-675147975768}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>15.006</label>
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
  <x>9</x>
  <y>178</y>
  <width>200</width>
  <height>30</height>
  <uuid>{fd3ea893-7f4f-4d74-a6c6-2ed00b696056}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandpass Filters Gain</label>
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
  <objectName>BPGain</objectName>
  <x>9</x>
  <y>155</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3911e6c3-0337-45b0-81d8-e63c67cae1f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.48199999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>BPGain_Value</objectName>
  <x>449</x>
  <y>178</y>
  <width>60</width>
  <height>30</height>
  <uuid>{78473677-bb47-45c2-bf88-fa6930dca759}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2.000</label>
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
  <x>9</x>
  <y>260</y>
  <width>100</width>
  <height>30</height>
  <uuid>{d7f5620d-8a05-4982-8edb-af45fcc4611c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Base Note</label>
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
  <x>9</x>
  <y>291</y>
  <width>1026</width>
  <height>301</height>
  <uuid>{3d230d57-2e7b-4bd4-8175-e6a7da3e9e07}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This is an implementation of a traditional analogue style vocoder.
Two audio signals, referred to as a modulator and a carrier, are passed into the vocoder effect. The modulator is is typically a voice and the carrier is typically a synthesizer. The modulator is analysed by being passed into multiband filter (bank of bandpass filters), the amplitude envelope of each band is tracked and a control function for each band generated. The carrier signal is also passed through a matching multiband filter, the set of amplitude envelopes derived from the modulator analysis is applied to outputs of this second multiband filter. In this implementation the user can vary the 'Base Note' or the frequency of the lowermost filter expressed as a MIDI note value. The number of filters in both filter banks can be varied as can the spacing between adjacent filters, expressed in semitones, and the bandwidth of the filters, expressed as a fraction of an octave. Whenever changes are made to these controls the vocoder instrument reinitializes itself and at the same time checks if any of the filter frequencies will exceed the nyquist frequency, in which case they will be omitted. For this reason the actual number of filters implemented may not be the number asked for using the GUI counter. Filter frequency data is printed to the terminal each time a change is made. The uppermost band of the filter bank is always a highpass filter. This is to allow high frequency sibilants to be in modulator to be accurately represented. In this implementation the user can choose between two internal sound files and the computer's live audio input as modulator source. If 'microphone' is chosen then audio is read from the computer's left input channel. For carrier signal there is a simple built-in synth with four waveform options and a resonant lowpass filter (moogladder). This internal synth is ideally played from an external MIDI keyboard - modify &lt;CsOptions> accordingly.
If 'External' is chosen then audio is taken from the computer's right channel input. You can connect you own hardware synthesizer here. Filter creation is controlled using a UDO with recursion so that the number of filters can be changed without having to rewrite code. The filter slopes are switchable between 12 dB per octave and 24 dB per octave. Choosing 24 dB per octave effectively doubles the number of filters used as for each band two series filters are used instead of one. Older computers may struggle in realtime with 24 dB per octave when combined with large number of filters.</label>
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
  <x>517</x>
  <y>49</y>
  <width>512</width>
  <height>95</height>
  <uuid>{0084c854-b62e-4a4d-8290-1d7db3f769e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulator</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>522</x>
  <y>106</y>
  <width>170</width>
  <height>30</height>
  <uuid>{553ef759-a6a8-4856-8b44-e46a7916ad88}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>AndItsAll.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>693</x>
  <y>107</y>
  <width>330</width>
  <height>28</height>
  <uuid>{d99fb6e8-ff26-4114-994b-4a3d44cdb7bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>AndItsAll.wav</label>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>85</y>
  <width>150</width>
  <height>30</height>
  <uuid>{43f7116d-e6bc-4121-a7d8-624b37846007}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Audio File</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>ModIn</objectName>
  <x>813</x>
  <y>57</y>
  <width>210</width>
  <height>30</height>
  <uuid>{56035bec-5d19-4dfe-95e2-4eba077267e8}</uuid>
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
    <name> Micophone (Left Channel)</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>BaseNote</objectName>
  <x>109</x>
  <y>260</y>
  <width>60</width>
  <height>30</height>
  <uuid>{66a00915-8240-4189-b441-9cc8399d70aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <minimum>24</minimum>
  <maximum>80</maximum>
  <randomizable group="0">false</randomizable>
  <value>40</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>169</x>
  <y>260</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2ff0a3cd-f045-46fa-bcbc-4f44ee7fb423}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Num. Bands</label>
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
  <objectName>NumBands</objectName>
  <x>269</x>
  <y>260</y>
  <width>60</width>
  <height>30</height>
  <uuid>{aa29e343-5d22-4238-bb99-a1a9ba851b2d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>50</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>329</x>
  <y>260</y>
  <width>100</width>
  <height>30</height>
  <uuid>{7ba7c4e3-eaeb-4036-b014-11c0c41d483c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>dB per Oct</label>
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
  <objectName>dBperOct</objectName>
  <x>429</x>
  <y>260</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e6b15ddb-b975-49ae-9770-d82aefa41f83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <minimum>12</minimum>
  <maximum>24</maximum>
  <randomizable group="0">false</randomizable>
  <value>24</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>517</x>
  <y>151</y>
  <width>512</width>
  <height>140</height>
  <uuid>{c9a8a317-ee56-436a-aefb-5ce9e2816aef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Carrier</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>CarIn</objectName>
  <x>522</x>
  <y>192</y>
  <width>210</width>
  <height>30</height>
  <uuid>{87392937-db97-42d1-8890-d619532257bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Internal Synth</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>External (Right Channel)</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>SynType</objectName>
  <x>902</x>
  <y>192</y>
  <width>120</width>
  <height>30</height>
  <uuid>{1eca9d44-ace2-4e49-b0ec-ced60019042b}</uuid>
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
   <bsbDropdownItem>
    <name>Pulse</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Noise</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>780</x>
  <y>192</y>
  <width>120</width>
  <height>30</height>
  <uuid>{fc6f50d0-1a2d-471c-9b93-792a6fccca9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Internal Synth Wave</label>
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
  <objectName>LPF</objectName>
  <x>556</x>
  <y>252</y>
  <width>200</width>
  <height>12</height>
  <uuid>{9af6561a-c1a5-4ea2-8e69-24b2ece53fd1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.87449998</xValue>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>517</x>
  <y>248</y>
  <width>40</width>
  <height>24</height>
  <uuid>{0925f33c-4729-4fd1-8a2a-53ce834d94b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LPF</label>
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
  <objectName>Res</objectName>
  <x>820</x>
  <y>252</y>
  <width>200</width>
  <height>12</height>
  <uuid>{e2a71ace-794e-42ac-b3d9-f3ffa358cdb6}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>780</x>
  <y>248</y>
  <width>40</width>
  <height>24</height>
  <uuid>{99ee820d-dc5e-4f4c-9005-7fa02564ae07}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Res</label>
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
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

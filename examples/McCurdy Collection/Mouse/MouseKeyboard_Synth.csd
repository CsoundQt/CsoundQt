;Written by Iain McCurdy, 2010

; Modified for QuteCsound by René, January 2011.
; Thanks to Andres CABRERA for the mouse channels names.

; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817 with "Widgets are an independent window" ON.


/*
Mouse Keyboard
--------------
This csd was originally written for use by someone who only had the use of a head-mouse for music performance.
A graphical keyboard is drawn on the screen. Notes are played by moving the mouse over a particular key. 
As well as activating that note, dynamic control is possible by moving the mouse vertically up the key. 
As the user moves the mouse right to the very bottom of the key, a modulation effect is also introduced. 
No clicking is required enabling better timing in performance. The GUI window needs to be in focus for this to work.
The user can change the functioning (or non-functioning) of the left click mouse button using the menu Mode.
The user can choose between different stereo wav sounds using the browse button within the GUI.
Reverb and ping-pong delay effects are provided, the parameters of which the user can change are in the GUI.
The mouse relative position is given by the channels _MouseRelX and _MouseRelY.

If the windows need to be resized, for example to accomodate use on a netbook, it is mandatory to manually update the values of boxes dimensions and positions in the csd file.

Professional head mouse or iris tracking software can be very expensive and requires practice. 
iNavigate is a free option for Mac OS 10.5 if the user wants to experiment with this approach.
*/


;Notes on modifications from original csd:
;	No automatic rescale
;	Add control widgets in GUI
;	reverse volume, upper position is 0.0, bottom position (of black key) is 1.0
;	Replaced audio file by an audio generator


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 32		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine		ftgen	0,0,4096,10,1	;A SINE WAVE	

;TABLE TO MAP MOUSE LOCATION ALONG THE Y-AXIS TO VARIOUS CONTROL PARAMETERS
giampscale	ftgen	0,0,1024,7,0,240,1,1024-240,1
gimodscale	ftgen	0,0,1024,7,0,600,0,1024-600,1
giLPFscale	ftgen	0,0,1024,7,0,800,1,224,1

giOct_White	ftgen	0,0,16,-2,7,7,7,7,7,7,7,8,8,8,8,8,8,8,9										;OCT TABLE FOR WHITES KEYS
giSemis_White	ftgen	0,0,16,-2,0,2/12,4/12,5/12,7/12,9/12,11/12,0,2/12,4/12,5/12,7/12,9/12,11/12		;SEMIS TABLE FOR WHITES KEYS


			zakinit	2,1	;INITIALISE ZAK SPACE FOR VARIABLE STORAGE


instr 	1	;SENSES MOUSE POSITION AND PLAYS SOUND (ALWAYS ON)

	ktrig	metro	10
	if ktrig = 1 then
		kportamento	invalue	"Portamento"						;TIME IT TAKES TO SLIDE BETWEEN NOTES. TRY VALUES WITHIN THE RANGE 0 - 0.3
		kOctaveTrans	invalue	"Octave"							;THIS DEFINES THE AMOUNT OF TRANSPOSITION IN OCTAVES, IDEALLY THIS SHOULD BE A WHOLE NUMBER, I.E. '1', '0', '-1' ETC. 
		kClick		invalue	"Mode"							;Click OPTION:	;0 = NO LEFT CLICK IS REQUIRED TO PLAY A NOTE. A NOTE PLAYS CONTINUOUSLY
																		;1 = IT IS REQUIRED TO LEFT CLICK TO PLAY A NOTE
																		;2 = LEFT CLICK STOPS A NOTE PLAYING
		kampport		invalue	"AmpPort"							;DEFINE AMPLITUDE PORTAMENTO TIME (SMOOTHING)
		kmodfrq		invalue	"ModFrq"							;DEFINE MODULATION FREQUENCY (VIBRATO/TREMOLO)
		kvibdep		invalue	"VibDep"							;DEFINE MAXIMUM VIBRATO DEPTH (PITCH MODULATION)
		ktrmdep		invalue	"TrmDep"							;DEFINE MAXIMUM TREMOLO DEPTH (AMPLITUDE MODULATION)

		;GUI FOR INSTR 2, PING PONG DELAY
		gkDelayTime	invalue	"DelayTime"						;DELAY TIME IN SECONDS
		gkReverbMix	invalue	"ReverbMix"						;AMOUNT OF REVERB. TRY VALUES WITHIN THE RANGE 0-1. 0=NO REVERB, 1=LOTS OF REVERB!
		gkDelayMix	invalue	"DelayMix"						;AMOUNT OF DELAY EFFECT. TRY VALUES WITHIN THE RANGE 0-1. 0=NO DELAY, 1=LOTS OF DELAY!

	endif

;KEYS WIDGETS SIZES AND POSITIONS

	iy_all	= 100
	ix_offset	= 2

	;White notes 
	iwidth_W	= 60
	iheight_W	= 300

	;ixN_W	= ix_offset + (N-1) * iwidth_W

	;Black notes
	iwidth_B	= 40
	iheight_B	= 200

	ix1_B	= 36		;upper left corner coordinates
	ix2_B	= 106
	ix3_B	= 212
	ix4_B	= 282
	ix5_B	= 352
	ix6_B	= 456
	ix7_B	= 526
	ix8_B	= 632
	ix9_B	= 702
	ix10_B	= 772

;MOUSE POSITION IN WIDGET PANEL AND SENSE MOUSE LEFT BUTTON
	krelx	invalue	"_MouseRelX"
	krely	invalue	"_MouseRelY"
	kb1		invalue	"_MouseBut1"
	

;MOUSE ON KEYBOARD AREA
	kon_kbd	init	0
	if (ix_offset <= krelx && krelx <= ix_offset+15*iwidth_W && iy_all <= krely  && krely <= iy_all+iheight_W) then
		kon_kbd	= 1
	else
		kon_kbd	= 0	
	endif

	ky		init	1								;amplitude init

;MOUSE ON A BLACK KEY
	kon_Black	init	0

#define BLACK_KEY(N) #(ix$N_B <= krelx && krelx <= ix$N_B + iwidth_B)#

	if (iy_all <= krely && krely <= iy_all+iheight_B) then
	
		ky	=	(krely - iy_all)/iheight_B			;amplitude 0 to 1
	
		if		$BLACK_KEY(1)	then
				kon_Black	= 1
				koctave	= 7
				ksemis	= 1/12
		elseif	$BLACK_KEY(2)	then
				kon_Black	= 1
				koctave	= 7
				ksemis	= 3/12
		elseif	$BLACK_KEY(3)	then
				kon_Black	= 1
				koctave	= 7
				ksemis	= 6/12
		elseif	$BLACK_KEY(4)	then
				kon_Black	= 1
				koctave	= 7
				ksemis	= 8/12
		elseif	$BLACK_KEY(5)	then
				kon_Black	= 1
				koctave	= 7
				ksemis	= 10/12
		elseif	$BLACK_KEY(6)	then
				kon_Black	= 1
				koctave	= 8
				ksemis	= 1/12
		elseif	$BLACK_KEY(7)	then
				kon_Black	= 1
				koctave	= 8
				ksemis	= 3/12
		elseif	$BLACK_KEY(8)	then
				kon_Black	= 1
				koctave	= 8
				ksemis	= 6/12
		elseif	$BLACK_KEY(9)	then
				kon_Black	= 1
				koctave	= 8
				ksemis	= 8/12
		elseif	$BLACK_KEY(10)	then
				kon_Black	= 1
				koctave	= 8
				ksemis	= 10/12
		else
				kon_Black	= 0
		endif
	else
		kon_Black	= 0	
	endif

;MOUSE ON A WHITE KEY
	kon_White	init	0
	if (kon_kbd = 1 && kon_Black = 0) then
		kx		= krelx - ix_offset
		kKey		= int(kx/iwidth_W)
		koctave	table	kKey, giOct_White
		ksemis	table	kKey, giSemis_White
		kon_White	= 1
	else
		kon_White	= 0	
	endif
	
	kgate	= kon_Black + kon_White

	;CHECK TO SEE WHICH LEFT CLICK BUTTON MODE HAS BEEN SELECTED AND IMPLEMENT THE APPROPRIATE BEHAVIOUR
	if		kClick=1	then											;IF 'LEFT CLICK ACTIVATES NOTE' MODE HAS BEEN SELECTED...
		ky1	=	ky * kb1
	elseif	kClick=2	then											;IF 'LEFT CLICK DE-ACTIVATES NOTE' MODE HAS BEEN SELECTED...
		ky1	=	ky * (1-kb1)
	else
		ky1	=	ky
	endif														;END OF CONDITIONAL BRANCHING

	kamp			table	ky1, giampscale,1							;CREATE AN AMPLITUDE VALUE ACCORDING TO Y POSITION (ky) ON KEY AND AMPLITUDE SCALING TABLE (giampscale)
	kamp			portk	kamp*kgate, kampport						;SMOOTH AMPLITUDE VARIABLE USING portk OPCODE (A KIND OF LOW PASS FILTER FOR K-RATE SIGNALS)
	
	koct			portk	koctave+ksemis+kOctaveTrans, kportamento		;COMBINE OCTAVE, SEMITONES AND TRANSPOSE VALUES AND APPLY PORTAMENTO SMOOTHING
	kmoddepth		table	ky1, gimodscale,1							;CREATE AN MODULATION DEPTH VALUE ACCORDING TO Y POSITION (ky) ON KEY AND MODULATION DEPTH SCALING TABLE (gimodscale)				;
	kmoddepth		portk	kmoddepth, kampport							;APPLY PORTAMENTO SMOOTHING
	kmod			oscili	kmoddepth, kmodfrq, gisine					;CREATE AN LFO FOR MODULATION
	koct			=		koct + (kmod*kvibdep)						;APPLY VIBRATO
	
	ktrm			oscili	ktrmdep*.5*kmoddepth, kmodfrq, gisine			;CREATE TREMOLO LFO
	ktrm			=		ktrm+.5									;ADD OFFSET

	kfrq			=		cpsoct(koct)						;CONVERT PITCH IN OCT FORMAT TO Hz

	aL			vco2	kamp*ktrm, kfrq		;CREATE AUDIO SIGNAL (LEFT CHANNEL) USING vco2 OPCODE
	aR			=		aL			;COPY AUDIO SIGNAL (RIGHT CHANNEL)
				rireturn											;RETURN FROM REINITIALISATION PASS

	kcfoct		table	ky1, giLPFscale, 1							;CREATE AN FILTER CUTOFF VALUE (OCT FORMAT) ACCORDING TO Y POSITION (ky) ON KEY AND FILTER CUTOFF SCALING TABLE (giLPFscale)				;
	kcfoct		=		(kcfoct*7)+7								;RE-RANGE AND OFFSET FILTER CUTOFF VALUE
	kcf			=		cpsoct(kcfoct)								;CONVERT FROM OCT TO CPS FORMAT
	kcf			portk	kcf, kampport								;APPLY PORTAMENTO SMOOTHING
	aL			butlp	aL, kcf									;APPLY LOW-PASS FILTERING (LEFT CHANNEL)
	aR			butlp	aR, kcf									;APPLY LOW-PASS FILTERING (RIGHT CHANNEL)
				zawm		aL, 1									;WRITE TO ZAK VARIABLE WITH MIXING (LEFT CHANNEL)
				zawm		aR, 2									;WRITE TO ZAK VARIABLE WITH MIXING (RIGHT CHANNEL)
endin	

instr	2	; PING PONG DELAY
	idlyFB		init		0.3										;DELAY FEEDBACK AMOUNT (0 - 1)
	iRoomSize		init		0.9										;REVERB ROOM SIZE (0 - 1)
	iHFDamp		init		0.5										;REVERB HIGH FREQUENCY DAMPING (0 - 1)
		
	ainL			zar		1										;READ ZAK AUDIO VARIABLE LEFT CHANNEL (WRITTEN BY INSTR 1)
	ainR			zar		2										;READ ZAK AUDIO VARIABLE RIGHT CHANNEL (WRITTEN BY INSTR 1)
	
	;LEFT CHANNEL OFFSETTING DELAY (NO FEEDBACK!)
	aBuffer		delayr	2.5										;INITIALISE DELAY BUFFER
	aLeftOffset	deltap3	gkDelayTime * 0.5							;READ AUDIO FROM DELAY TAP 
				delayw	ainL										;WRITE AUDIO INTO BUFFER
			
	;LEFT CHANNEL DELAY WITH FEEDBACK
	aBuffer		delayr	5.0										;INITIALISE DELAY BUFFER
	aDlySigL		deltap3	gkDelayTime								;READ AUDIO FROM DELAY TAP
				delayw	aLeftOffset+(aDlySigL*idlyFB)					;WRITE AUDIO INTO BUFFER
	
	;RIGHT CHANNEL DELAY WITH FEEDBACK
	aBuffer		delayr	5.0										;INITIALISE DELAY BUFFER
	aDlySigR		deltap3	gkDelayTime								;READ AUDIO FROM DELAY TAP
				delayw	ainR+(aDlySigR * idlyFB)						;WRITE AUDIO INTO BUFFER
	
	amixL		ntrpol	ainL, aDlySigL+aLeftOffset, gkDelayMix			;CREATE DRY/WET MIX FOR PING-PONG DELAY (LEFT CHANNEL)
	amixR		ntrpol	ainR, aDlySigR, gkDelayMix					;CREATE DRY/WET MIX FOR PING-PONG DELAY (RIGHT CHANNEL)
	
				denorm	amixL, amixR								;DENORMALIZE BOTH CHANNELS OF AUDIO SIGNAL
	arvbL, arvbR 	freeverb 	amixL, amixR, iRoomSize, iHFDamp , sr			;CREATE REVERB SIGNAL USING freeverb OPCODE
	amixL		ntrpol	amixL, arvbL, gkReverbMix					;CREATE A DRY/WET MIX BETWEEN THE DRY AND THE REVERBERATED SIGNAL
	amixR		ntrpol	amixR, arvbR, gkReverbMix					;CREATE A DRY/WET MIX BETWEEN THE DRY AND THE REVERBERATED SIGNAL
				outs		amixL, amixR								;SEND DELAY OUTPUT SIGNALS TO THE SPEAKERS
				zacl		1,2										;CLEAR ZAK VARIABLES
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 1 		0	   3600		;SOUND PRODUCING INSTRUMENT
i 2 		0	   3600		;PING-PONG DELAY AND REVERB
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>206</r>
  <g>206</g>
  <b>206</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>16</y>
  <width>220</width>
  <height>51</height>
  <uuid>{8696498c-ea5a-4002-80e2-b73942e10bb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mouse Keyboard</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
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
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{6aa6f818-c40c-4f0d-9eeb-f1c5651e3d6d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>62</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{3c683070-f695-4af9-94dc-3d7843d19dc8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>122</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{a6839b00-9350-4dcd-bfd7-a172629ebcec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>182</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{bae8c0bb-03d2-4099-ae9a-1763d781d57c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>242</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{b0854f55-06b9-44a8-a514-5209d08553cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>302</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{3a09e244-6262-4741-a925-27e139a46cc6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>362</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{865a22bd-dce9-41c6-80b1-7f22bfee61f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>36</x>
  <y>100</y>
  <width>40</width>
  <height>200</height>
  <uuid>{61df7d9b-ddbd-4811-8759-61f4639750ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>106</x>
  <y>100</y>
  <width>40</width>
  <height>200</height>
  <uuid>{e890b8d8-a231-41b5-aab5-d9e13a2cebca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>212</x>
  <y>100</y>
  <width>40</width>
  <height>200</height>
  <uuid>{190d5200-e15a-4f87-8f0a-a276d53b36da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>282</x>
  <y>100</y>
  <width>40</width>
  <height>200</height>
  <uuid>{debe3eff-6c42-43e3-824f-121054ff21d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>352</x>
  <y>100</y>
  <width>40</width>
  <height>200</height>
  <uuid>{a999fbb8-a44a-46be-ac45-9be60705c808}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>422</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{8531d8e1-59ea-4580-90aa-ff141d0ae7a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>482</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{c1c7c643-fae0-4890-ae3d-35c3ffc3c5e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>542</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{72ee5338-4bea-4b3d-bb3b-5316200c87c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>602</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{129baaca-2098-4c12-900e-6ab5df07b404}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>662</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{070504c2-573d-45b3-8731-89f35fbfdcfc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>722</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{222e95a8-b4e9-4ebb-b91b-cf4f7f459805}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>782</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{221b96c6-196d-498d-bd36-3975e0b37406}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>456</x>
  <y>100</y>
  <width>40</width>
  <height>200</height>
  <uuid>{30ee3225-575a-44d0-affe-c33ae51af772}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>526</x>
  <y>100</y>
  <width>40</width>
  <height>200</height>
  <uuid>{e4a7a68e-3801-4b25-a5e3-ba23ad91cb4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>632</x>
  <y>100</y>
  <width>40</width>
  <height>200</height>
  <uuid>{bf581f89-a373-4302-ba59-f85e1b2a5519}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>702</x>
  <y>100</y>
  <width>40</width>
  <height>200</height>
  <uuid>{2f2ed15f-5881-4f06-87db-9547cef44df6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>772</x>
  <y>100</y>
  <width>40</width>
  <height>200</height>
  <uuid>{8e09f51b-38bc-4db5-a4d2-bbe4270d2785}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{08c8594e-6119-4860-b97b-399dba37bdb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>39</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{217c1815-d9eb-42bc-9957-8e9488917ba5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C#</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>74</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{c2eb661f-2add-40a1-b06f-7ef2f78a8721}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>D</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>110</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{e128fb16-a520-4aba-b8b1-2e7808b1725a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>D#</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>142</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{5c468762-a4a4-458d-a81e-83927d9fe589}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>E</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>180</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{0064bc2c-741b-41a5-baa2-bedad6e05ff5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>F</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>216</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{85835b5d-70f5-4b94-a732-d3155412686e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>F#</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>250</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{0fc10f9e-ef64-4bf3-a8c4-d1b4f9c39b52}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>G</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>286</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{af2b8459-3659-4754-b64b-ead485847f0b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>G#</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>320</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{dfbf7db5-a784-4e4c-8ab6-fb3e79edae0e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>A</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>356</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{0988a89d-8f56-4d4b-9c02-34e81797acdd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>A#</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>390</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{80a1b6b9-4101-4ce6-a71a-a0f15f0c1286}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>B</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>424</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{05345e72-1676-41d9-a2fb-5b2812eb7f21}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>460</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{c34956f2-6065-4c87-8890-4285b1bf5dd5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C#</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>494</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{52c84820-7240-498b-90d4-adad7e1d5ad3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>D</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>530</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{b7e7faa7-a237-4186-b5bb-76f2799a0a59}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>D#</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>566</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{e2ae0fef-453c-48f1-ae30-c55063cfebaf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>E</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>600</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{2f1f4221-aaff-407a-b530-a071be4b812d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>F</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>636</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{e55f4426-29f2-4489-83b2-2daacaa175b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>F#</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>670</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{3960d1a8-1746-4dca-919c-52fb88666aaf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>G</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>706</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{4b55970e-c2eb-40c1-98f2-4292ba31b81a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>G#</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>740</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{a74e4583-8792-4e0b-919c-01c8df951efb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>A</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>776</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{c53a96ef-aead-4229-b590-a0a13a2004e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>A#</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>811</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{09393dfb-946d-45b5-bccb-4050cc70266d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>B</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>842</x>
  <y>100</y>
  <width>60</width>
  <height>300</height>
  <uuid>{97fad51f-43d9-402f-9ee9-3719368f4927}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>856</x>
  <y>103</y>
  <width>30</width>
  <height>25</height>
  <uuid>{af5356c7-c699-460f-8a6d-0f0a7421249b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>911</x>
  <y>100</y>
  <width>175</width>
  <height>300</height>
  <uuid>{e83a6502-9e63-4273-bb0d-7f85d4801d4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>166</r>
   <g>163</g>
   <b>157</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>4</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>DelayTime</objectName>
  <x>936</x>
  <y>179</y>
  <width>50</width>
  <height>50</height>
  <uuid>{114527f2-819d-4396-bb21-880970440765}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.60400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>922</x>
  <y>227</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5d9d940e-601f-46dc-9990-b81655c3b365}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Time</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>ReverbMix</objectName>
  <x>1008</x>
  <y>106</y>
  <width>50</width>
  <height>50</height>
  <uuid>{a13e6afd-891a-44ba-8f51-1dce848cec59}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.37000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>994</x>
  <y>154</y>
  <width>80</width>
  <height>25</height>
  <uuid>{1c31572a-567e-41dd-9654-b27cbf41f25a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb Mix</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Portamento</objectName>
  <x>936</x>
  <y>106</y>
  <width>50</width>
  <height>50</height>
  <uuid>{df7d823a-3705-4cbd-9e18-e9ff989ed8c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.30000000</maximum>
  <value>0.03300000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>922</x>
  <y>154</y>
  <width>80</width>
  <height>25</height>
  <uuid>{6df782a8-2bda-426f-b932-4fdf6fbdaadc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Portamento</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>DelayMix</objectName>
  <x>1008</x>
  <y>179</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9c253129-851f-4d01-92e2-8f801e008298}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.08000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>994</x>
  <y>227</y>
  <width>80</width>
  <height>25</height>
  <uuid>{58836950-bd2d-43a4-893a-34274c1d6d58}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Mix</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Octave</objectName>
  <x>574</x>
  <y>29</y>
  <width>52</width>
  <height>30</height>
  <uuid>{055c3420-76d2-4887-8639-8aab364c2a29}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
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
  <minimum>-2</minimum>
  <maximum>2</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>503</x>
  <y>32</y>
  <width>68</width>
  <height>25</height>
  <uuid>{7d941c8e-e8aa-4692-8a56-4c39d8d95630}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Octave</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Mode</objectName>
  <x>321</x>
  <y>29</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7434b3ae-588c-4d0b-b9e0-e5449428e485}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>No Click to Play / Stop</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Left click to Play</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Left Click to Stop</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>255</x>
  <y>31</y>
  <width>68</width>
  <height>25</height>
  <uuid>{580d20d9-8d0f-4d73-aeee-57f4a269e33c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mode</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>AmpPort</objectName>
  <x>935</x>
  <y>250</y>
  <width>50</width>
  <height>50</height>
  <uuid>{cbd37737-7bab-4ffd-936a-f74fe2c64694}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.04000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>922</x>
  <y>298</y>
  <width>80</width>
  <height>25</height>
  <uuid>{11980cb6-4448-43b1-be68-bd43a137da92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp Port</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>ModFrq</objectName>
  <x>1008</x>
  <y>250</y>
  <width>50</width>
  <height>50</height>
  <uuid>{eeca5b1a-786e-40f5-b571-7f374793e8fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>5.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>994</x>
  <y>298</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4626fcd6-d179-450c-be5f-2fd7c2dee3ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mod Frq</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>VibDep</objectName>
  <x>936</x>
  <y>323</y>
  <width>50</width>
  <height>50</height>
  <uuid>{769d9e20-1c87-4945-9d16-728abe2209a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.02000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>922</x>
  <y>371</y>
  <width>80</width>
  <height>25</height>
  <uuid>{dac0dced-1a75-42e7-977d-5ff5a95bb0f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vib Dep</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>TrmDep</objectName>
  <x>1008</x>
  <y>323</y>
  <width>50</width>
  <height>50</height>
  <uuid>{49b664f1-8bdf-4356-b278-82f7ae912c4c}</uuid>
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
  <x>994</x>
  <y>371</y>
  <width>80</width>
  <height>25</height>
  <uuid>{9606d7a3-3923-47e2-b3ef-d8acbdcccb40}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Trm Dep</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

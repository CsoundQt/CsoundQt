; =====================================================================================================================================
;|                                                            CSOUND MULTI FX                                                          |
;|-------------------------------------------------------------------------------------------------------------------------------------|
;|                                                    Written by Iain McCurdy, 2010                                                    |
; =====================================================================================================================================

;Modified for QuteCsound by René, February 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817
;GUI is big, in QuteCsound Configuration / Widgets set 'Widgets are an independent window' to OFF

;Notes on modifications from original csd:
;	Add temp tables for exp slider when required in instrument
;	Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files
;	Removed macros, no usefull because QuteCsound GUI can't be automaticaly generated
;	Increase giOnOffStatus table size from 16 to 32
;	Removed "Instructions and Info Panel"

;	                                                          Effects Modules
;	-------------------------------------------------------------------------------------------------------------------------------------------------
;	The GUI design and general approach has been based on so called 'stomp boxes' that might be used by an electric guitarist. Efficient use of the
;	computer's resources is made by making each effect a unique Csound instrument which is switched on or off as needed.
;	This example works on the computer's live input. Input is stereo and all effects are stereo in, stereo out.
;	If you don't have live input configured on your computer you can also access a built-in sound file using the 'File Play' module.
;
;	Instructions for each individual effect follows:
;
;	VOLUME
;	------
;	A simple volume control. If the effect is bypassed the input signal passes through unchanged.
;
;	FILE-PLAY
;	---------
;	A file player effect. Edit code to change the sound file used. Separate volume controls for the sound file and the input sound.
;	The main purpose of this module is to provide some audio input for auditioning effects if live audio is not available.                                                                                                                ", 	1,      5,     14,    990,    20,     5, 520
;
;	COMPRESSOR
;	----------
;	A dynamic compressor with controls for threshold (turning the knob clockwise lowers the threshold), compressions ratio (1:1 - 100:1),
;	attack time of the compression (0.01 - 0.3 seconds) and a gain compensation control (1 - 20).
;
;	ENV FOLLOWER
;	------------
;	A dynamic envelope following low-pass filter that used Csound's moogladder low-pass filter. Controls are for the sensitivity of the envelope
;	following, basic frequency of the filter (100-10000 Hz) and resonance of the filter.
;
;	DISTORTION
;	----------
;	A distortion effect with controls for level whenever the effect is active, drive (amount of distortion) and tone (basically a low-pass filter).
;
;	REVERSE
;	-------
;	Reverses buffered chunks of sound received in real-time at its input. The user can control the length of the buffer from 0.1 - 2 seconds.
;
;	PITCH SHIFTER
;	-------------
;	A pitch shifter that uses streaming phase vocoding technology. Controls for mix (minimum=all dry signal, maximum=all effect), pitch
;	(-1 octave to +1 octave in semitone steps), fine (-100 cents to +100 steps) and amount of output signal fed back into the input (0% - 100%).
;
;	FREQUENCY SHIFTER
;	-----------------
;	A frequency shifter using Csound's hilbert opcode. Controls for mix (minimum=all dry signal, maximum=all effect), frequency shift (-1000 to +1000),
;	multiplier - a value in the range -1 to +1 which is multiplied to the frequency shift value and can be used to adjust the sensitivity of the 'Freq.'
;	control - and finally a feedback control which controls the amount of output signal that is fed back into the input (0% - 75%).
;
;	RING MODULATOR
;	--------------
;	A ring modulator effect with controls for mix (minimum=all dry signal, maximum=all effect), modulating frequency (10-5000Hz) and an envelope control
;	which controls the amount of influence the dynamics of the input sound has over the modulating frequency.
;
;	PHASER
;	------
;	An 8 ordinate phaser effect with controls for rate (0.01 Hz - 14 Hz), depth (0 - 8 octaves), base frequency (65 - 4000 Hz) and a feedback control
;	which controls the intensity of the effect.
;
;	LoFi
;	------
;	Digital decimation of the input signal. Controls for bit depth reduction from 16 to 2 bits and for sample rate reduction (44100Hz to 172Hz).
;
;	FILTER
;	------
;	A high-pass followed by a low-pass filter, both 48dB/octave. Controls for high-pass filter cutoff, high-pass filter cutoff and gain.
;
;	AUTO-PAN/TREMOLO
;	----------------
;	A effect that applies lfo controlled panning or amplitude modulation. Controls for LFO rate (0.1 - 50 Hz), depth of modulation, mode (auto-panning
;	or tremolo/amplitude modulation) and LFO waveform type (sine, triangle or square).
;
;	STEREO CHORUS
;	-------------
;	A stereo chorus effect with controls for the rate of modulation (0.001 - 7 Hz), depth of modulation (0 - 0.01 secs.) and phase interval between
;	the left and right channel LFOs (0degs - 180degs).
;
;	FLANGER
;	-------
;	A flanger effect with controls for rate of modulation (0.001 - 7 Hz), depth of modulation (0 - 0.1 secs.), delay modulation offset
;	(0.0001 - 0.01 secs) and feedback (0% - 99%).
;
;	DELAY
;	-----
;	A delay effect with controls for effect mix (minimum=all dry signal, maximum=all effect), delay time (0.01 - 5 secs.), feedback (0% - 100%) and
;	high frequency loss (a low-pass filter within the delay feedback loop 200 - 20000 Hz).
;
;	REVERB
;	------
;	A reverb effect that uses Csound's reverbsc opcode and with controls for effect mix (minimum=all dry signal, maximum=all effect), room size and
;	high frequency damping.
;
;	EQUALIZER
;	---------
;	A stereo graphic equalizer. Gain controls centering around the frequencies 100Hz, 200Hz, 400Hz, 800Hz, 1600Hz, 3200Hz and 6400Hz. The lowest
;	control is a low shelving filter and the highest is a high shelving control.


;my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b32 -B4096 -+rtmidi=null
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 32		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH

#define	UPDATE	#10#

giOnOffStatus	ftgen	0,0,32,-2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;TABLE THAT STORES THE ON/OFF STATUS OF EACH EFFECT 0=OFF 1=ON
gisine		ftgen	0,0,4096,10,1
giWet		ftgen	0,0,1024,-7,0,512,1,512,1				;RESCALING FUNCTION FOR WET LEVEL CONTROL
giDry		ftgen	0,0,1024,-7,1,512,1,512,0				;RESCALING FUNCTION FOR DRY LEVEL CONTROL


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


instr	1	;TRIGGERED BY EFFECT ON/OFF SWITCHES - AMENDS ON/OFF STATUS TABLE ACCORDINGLY AND STARTS THE DESIRED EFFECT
	iStatus	table	p4, giOnOffStatus						;CURRENT STATUS
	iStatus	=		abs(iStatus - 1)						;NEW STATUS - SWAPS BETWEEN ZERO AND 1
			tablew	iStatus, p4, giOnOffStatus				;WRITE NEW STATUS
	if iStatus=1 then										;IF EFFECT IS NOW ON...
			event_i	"i", p4 + 10, 0, -1						;TURN ON THE RELELVANT EFFECT. EFFECT NUMBER DERIVED FROM p4 OF BUTTON
	endif												;END OF THIS CONDITIONAL  BRANCH
endin

instr	2	;INPUT (ALWAYS ON)
	gaSigL, gaSigR	ins										;READ STEREO INPUT INTO GLOBAL AUDIO VARIABLES
endin


;THE EFFECTS...
instr	10	;VOLUME
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use VOLUMELED widget controller for effect ON/OFF light
	;Use VOLUMEOnOff widget button to Start/Stop effect (event i 1 0 0.01 0)

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1VOLUME	invalue	"Volume"

				outvalue	"VOLUMELED", 1						;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"VOLUMELED", 0								;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH
	gaSigL	= gaSigL*k1VOLUME								;SCALE LEFT CHANNEL AMPLITUDE USING VOLUME CONTROL KNOB
	gaSigR	= gaSigR*k1VOLUME								;SCALE RIGHT CHANNEL AMPLITUDE USING VOLUME CONTROL KNOB
endin

instr	11	;FILEPLAY
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use FILEPLAYLED widget controller for effect ON/OFF light
	;Use FILEPLAYOnOff widget button to Start/Stop effect (event i 1 0 0.01 1)

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1FILEPLAY	invalue	"File"
		k2FILEPLAY	invalue	"Live"

		Sfile_new		strcpy	""							;INIT TO EMPTY STRING
		gSfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	gSfile
		kfile 		strcmpk	Sfile_new, Sfile_old

					outvalue	"FILEPLAYLED", 1				;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"FILEPLAYLED", 0							;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	kNew_file		changed	kfile							;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kNew_file=1	then									;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	NEW_FILE									;BEGIN A REINITIALISATION PASS FROM LABEL 'NEW_FILE'
	endif
	NEW_FILE:
	;OUTPUTS		OPCODE	FILE  | SPEED|INSKIP|LOOPING (0=OFF 1=ON)
	aFileL, aFileR	FilePlay2	gSfile,	1,	0,		1			;READ A FILE FROM DISK

	gaSigL	sum	aFileL*k1FILEPLAY, gaSigL*k2FILEPLAY			;MIX FILE PLAYER AUDIO WITH LIVE AUDIO ACCORDING TO THE SETTING OF KNOB 1 & 2 (LEFT CHANNEL)
	gaSigR	sum	aFileR*k1FILEPLAY, gaSigR*k2FILEPLAY			;MIX FILE PLAYER AUDIO WITH LIVE AUDIO ACCORDING TO THE SETTING OF KNOB 1 & 2 (LEFT CHANNEL)
endin
	
instr	12	;COMPRESSOR
	;GUI------------------------------------------------------------------------------------------------------------------------------------
	;Use COMPRESSORLED widget controller for effect ON/OFF light
	;Use COMPRESSOROnOff widget button to Start/Stop effect (event i 1 0 0.01 2)

	iExp1	ftgentmp	0, 0, 129, -25, 0, 1.0, 128, 100.0		;TABLE FOR EXP SLIDER
	iExp2	ftgentmp	0, 0, 129, -25, 0, 1.0, 128, 20.0		;TABLE FOR EXP SLIDER

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1COMPRESSOR	invalue	"COMPRESSOR_Thresh"
		k2COMPRESSOR	invalue	"COMPRESSOR_Ratio"
		k2COMPRESSOR	tablei	k2COMPRESSOR, iExp1, 1

		k3COMPRESSOR	invalue	"COMPRESSOR_Att"
		k4COMPRESSOR	invalue	"COMPRESSOR_PostGain"
		k4COMPRESSOR	tablei	k4COMPRESSOR, iExp2, 1

					outvalue	"COMPRESSORLED", 1				;THIS TURNS ON THE LED FOR THE EFFECT   
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus            			;READ EFFECT ON/OFF STATUS FROM TABLE                    
	if kStatus=0 then                               				;IF THIS EFFECT HAS BEEN TURNED OFF                      
		outvalue	"COMPRESSORLED", 0							;SWITCH OFF THE LED                                      
		turnoff                                 				;TURN THIS INSTRUMENT OFF                                
	endif                                           				;END OF THIS CONDITIONAL BRANCH                          

	ktrigger	changed	k2COMPRESSOR, k3COMPRESSOR				;RATIO AND ATTACK TIME ARE I-RATE SO RE-INITIALIZATION IS REQUIRED IN ORDER FOR THEM TO TAKE EFFECT
	if ktrigger=1 then										;IF A REINITIALIZATIO  TRIGGER HAS BEEN RECEIVED...
		reinit	UPDATE									;BEGIN A REINITIALIZATION PASS FROM LABEL 'UPDATE'
	endif												;END OF THIS CONDITIONAL BRANCH

	UPDATE:												;LABEL
	aCompL	dam 	gaSigL, k1COMPRESSOR, 1/i(k2COMPRESSOR), 1, i(k3COMPRESSOR), 0.1		;COMPRESSOR (LEFT CHANNEL)
	aCompR	dam 	gaSigR, k1COMPRESSOR, 1/i(k2COMPRESSOR), 1, i(k3COMPRESSOR), 0.1		;COMPRESSOR (RIGHT CHANNEL)
			rireturn										;RETURN FROM INTIALIZATION PASS
	gaSigL	=	aCompL*k4COMPRESSOR							;REDEFINE GLOBAL AUDIO SIGNAL WITH COMPRESSOR OUTPUT AUDIO (LEFT CHANNEL)
	gaSigR	=	aCompR*k4COMPRESSOR							;REDEFINE GLOBAL AUDIO SIGNAL WITH COMPRESSOR OUTPUT AUDIO (RIGHT CHANNEL)
endin

instr	13	;ENVFOLLOWER
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use ENVFOLLOWERLED widget controller for effect ON/OFF light
	;Use ENVFOLLOWEROnOff widget button to Start/Stop effect (event i 1 0 0.01 3)

	iExp1	ftgentmp	0, 0, 129, -25, 0, 100.0, 128, 10000.0		;TABLE FOR EXP SLIDER

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1ENVFOLLOWER	invalue	"ENVFOLLOWER_Sens"
		k2ENVFOLLOWER	invalue	"ENVFOLLOWER_Freq"
		k2ENVFOLLOWER	tablei	k2ENVFOLLOWER, iExp1, 1
		k3ENVFOLLOWER	invalue	"ENVFOLLOWER_Res"

					outvalue	"ENVFOLLOWERLED", 1				;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"ENVFOLLOWERLED", 0							;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	aFollowL	follow2	gaSigL, 0.01, 0.05						;AMPLITUDE FOLLOWING AUDIO SIGNAL (LEFT CHANNEL)
	aFollowR	follow2	gaSigR, 0.01, 0.05						;AMPLITUDE FOLLOWING AUDIO SIGNAL (RIGHT CHANNEL)
	kFollowL	downsamp	aFollowL								;DOWNSAMPLE TO K-RATE (LEFT CHANNEL)
	kFollowR	downsamp	aFollowR								;DOWNSAMPLE TO K-RATE (RIGHT CHANNEL)
	kFrqL	=		k2ENVFOLLOWER + (cpsoct(kFollowL*k1ENVFOLLOWER*150))				;CREATE A LEFT CHANNEL MODULATING FREQUENCY BASE ON THE STATIC VALUE CREATED BY KNOB 2 AND THE AMOUNT OF DYNAMIC ENVELOPE FOLLOWING GOVERNED BY KNOB 3
	kFrqR	=		k2ENVFOLLOWER + (cpsoct(kFollowR*k1ENVFOLLOWER*150))				;CREATE A RIGHT CHANNEL MODULATING FREQUENCY BASE ON THE STATIC VALUE CREATED BY KNOB 2 AND THE AMOUNT OF DYNAMIC ENVELOPE FOLLOWING GOVERNED BY KNOB 3
	kFrqL	port		kFrqL, 0.05							;SMOOTH CONTROL SIGNAL USING PORTAMENTO (LEFT CHANNEL) 
	kFrqR	port		kFrqR, 0.05							;SMOOTH CONTROL SIGNAL USING PORTAMENTO (RIGHT CHANNEL)
	kFrqL	limit	kFrqL, 20,18000						;LIMIT FREQUENCY RANGE TO PREVENT OUT OF RANGE FREQUENCIES (LEFT CHANNEL)  
	kFrqR	limit	kFrqR, 20,18000						;LIMIT FREQUENCY RANGE TO PREVENT OUT OF RANGE FREQUENCIES  (RIGHT CHANNEL)

	gaSigL	moogladder	gaSigL, kFrqL, k3ENVFOLLOWER			;REDEFINE GLOBAL AUDIO SIGNAL AS FILTERED VERSION OF ITSELF (LEFT CHANNEL) 
	gaSigR	moogladder	gaSigR, kFrqR, k3ENVFOLLOWER			;REDEFINE GLOBAL AUDIO SIGNAL AS FILTERED VERSION OF ITSELF (RIGHT CHANNEL)
endin

instr	14	;DISTORTION
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use DISTORTIONLED widget controller for effect ON/OFF light
	;Use DISTORTIONOnOff widget button to Start/Stop effect (event i 1 0 0.01 4)

	iExp1	ftgentmp	0, 0, 129, -25, 0, 0.01, 128, 0.4			;TABLE FOR EXP SLIDER
	iExp2	ftgentmp	0, 0, 129, -25, 0, 20.0, 128, 20000.0		;TABLE FOR EXP SLIDER

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1DISTORTION	invalue	"DISTORTION_Level"
		k2DISTORTION	invalue	"DISTORTION_Drive"
		k2DISTORTION	tablei	k2DISTORTION, iExp1, 1
		k3DISTORTION	invalue	"DISTORTION_Tone"
		k3DISTORTION	tablei	k3DISTORTION, iExp2, 1

					outvalue	"DISTORTIONLED", 1				;THIS TURNS ON THE LED FOR THE EFFECT     
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus 					;READ EFFECT ON/OFF STATUS FROM TABLE                    
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF                      
		outvalue	"DISTORTIONLED", 0							;SWITCH OFF THE LED                                      
		turnoff											;TURN THIS INSTRUMENT OFF                                
	endif												;END OF THIS CONDITIONAL BRANCH                          

	kpregain	=	(k2DISTORTION*100)							;DEFINE PREGAIN FROM KNOB 2
	kpostgain	=	0.5 * (((1-k2DISTORTION) * 0.4) + 0.6)			;DEFINE POSTGAIN FROM KNOB 2
	kshape1	=	0										;SHAPE 1 PARAMETER
	kshape2	=	0										;SHAPE 2 PARAMETER

	aDistL	distort1	gaSigL*32000, kpregain, kpostgain, kshape1, kshape2				;CREATE DISTORTION SIGNAL
	aDistR	distort1	gaSigR*32000, kpregain, kpostgain, kshape1, kshape2				;CREATE DISTORTION SIGNAL
	aDistL	butlp	aDistL/32000, k3DISTORTION				;LOWPASS FILTER DISTORTED SIGNAL (LEFT CHANNEL) 
	aDistR	butlp	aDistR/32000, k3DISTORTION				;LOWPASS FILTER DISTORTED SIGNAL (RIGHT CHANNEL)
	gaSigL	=		aDistL*k1DISTORTION						;REDEFINE GLOBAL AUDIO SIGNAL WITH DISTORTION OUTPUT AUDIO. AMPLITUDE SCALED BY KNOB 1. (LEFT CHANNEL) 
	gaSigR	=		aDistR*k1DISTORTION						;REDEFINE GLOBAL AUDIO SIGNAL WITH DISTORTION OUTPUT AUDIO. AMPLITUDE SCALED BY KNOB 1. (RIGHT CHANNEL)
endin

instr	15	;REVERSE
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use REVERSELED widget controller for effect ON/OFF light
	;Use REVERSEOnOff widget button to Start/Stop effect (event i 1 0 0.01 5)

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1REVERSE		invalue	"REVERSE_Time"

					outvalue	"REVERSELED", 1				;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"REVERSELED", 0							;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	ktrig	changed	k1REVERSE
	if ktrig=1 then
		reinit	UPDATE
	endif

	UPDATE:
	itime	=	i(k1REVERSE)
	aptr		phasor	2/itime
	aptr		=		aptr*itime
	ienv		ftgentmp	0,0,1024,7,0,(1024*0.01),1,(1024*0.98),1,(0.01*1024),0
 	aenv		poscil	1, 2/itime, ienv
 	abuffer	delayr	itime
	atapL	deltap3	aptr
			delayw	gaSigL
	abuffer	delayr	itime
	atapR	deltap3	aptr
			delayw	gaSigR		
			rireturn
	gaSigL	=		atapL*aenv
	gaSigR	=		atapR*aenv	
endin

instr	16	;PITCH_SHIFTER
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use PITCH_SHIFTERLED widget controller for effect ON/OFF light
	;Use PITCH_SHIFTEROnOff widget button to Start/Stop effect (event i 1 0 0.01 6)

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1PITCH_SHIFTER	invalue	"PITCH_SHIFTER_Mix"
		k2PITCH_SHIFTER	invalue	"PITCH_SHIFTER_Pitch"
		k3PITCH_SHIFTER	invalue	"PITCH_SHIFTER_Fine"
		k4PITCH_SHIFTER	invalue	"PITCH_SHIFTER_FBack"
		
						outvalue	"PITCH_SHIFTERLED", 1		;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"PITCH_SHIFTERLED", 0						;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	kWet		table	k1PITCH_SHIFTER, giWet, 1				;RESCALE WET LEVEL CONTROL ACCORDING TO FUNCTION TABLE giWet
	kDry		table	k1PITCH_SHIFTER, giDry, 1				;RESCALE DRY LEVEL CONTROL ACCORDING TO FUNCTION TABLE giWet
	aOutL	init		0									;INITIALIZE aOutL FOR FIRST PERFORMANCE TIME PASS
	aOutR	init		0									;INITIALIZE aOutR FOR FIRST PERFORMANCE TIME PASS
	kscal	=		octave((int(k2PITCH_SHIFTER)/12)+k3PITCH_SHIFTER)					;DERIVE PITCH SCALING RATIO. NOTE THAT THE 'COARSE' PITCH DIAL BECOMES STEPPED IN SEMITONE INTERVALS

	fsig1L 	pvsanal	gaSigL+(aOutL*k4PITCH_SHIFTER), 1024,256,1024,0					;PHASE VOCODE ANALYSE LEFT CHANNEL
	fsig1R 	pvsanal	gaSigL+(aOutR*k4PITCH_SHIFTER), 1024,256,2048,0					;PHASE VOCODE ANALYSE RIGHT CHANNEL
	fsig2L 	pvscale	fsig1L, kscal							;RESCALE PITCH (LEFT CHANNEL)
	fsig2R 	pvscale	fsig1R, kscal							;RESCALE PITCH (RIGHT CHANNEL)

	aOutL 	pvsynth	fsig2L								;RESYNTHESIZE FROM FSIG (LEFT CHANNEL)
	aOutR 	pvsynth	fsig2R								;RESYNTHESIZE FROM FSIG (RIGHT CHANNEL)

	gaSigL	sum		gaSigL*kDry, aOutL*kWet					;REDEFINE GLOBAL AUDIO SIGNAL FROM MIX OF DRY AND WET SIGNALS (LEFT CHANNEL) 
	gaSigR	sum		gaSigR*kDry, aOutR*kWet					;REDEFINE GLOBAL AUDIO SIGNAL FROM MIX OF DRY AND WET SIGNALS (RIGHT CHANNEL)
endin

instr	17	;FREQSHIFTER
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use FREQSHIFTERLED widget controller for effect ON/OFF light
	;Use FREQSHIFTEROnOff widget button to Start/Stop effect (event i 1 0 0.01 7)

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1FREQSHIFTER	invalue	"FREQSHIFTER_Mix"
		k2FREQSHIFTER	invalue	"FREQSHIFTER_Freq"
		k3FREQSHIFTER	invalue	"FREQSHIFTER_Mult"
		k4FREQSHIFTER	invalue	"FREQSHIFTER_Fback"

					outvalue	"FREQSHIFTERLED", 1				;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"FREQSHIFTERLED", 0							;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	kWet		table	k1FREQSHIFTER, giWet, 1					;RESCALE WET LEVEL CONTROL ACCORDING TO FUNCTION TABLE giWet
	kDry		table	k1FREQSHIFTER, giDry, 1					;RESCALE DRY LEVEL CONTROL ACCORDING TO FUNCTION TABLE giDry
	aOutL	init		0
	aOutR	init		0
	aInL		=		gaSigL + (aOutL * k4FREQSHIFTER)			;ADD FEEDBACK SIGNAL TO INPUT (AMOUNT OF FEEDBACK CONTROLLED BY 'Feedback Gain' SLIDER)
	aInR		=		gaSigR + (aOutR * k4FREQSHIFTER)			;ADD FEEDBACK SIGNAL TO INPUT (AMOUNT OF FEEDBACK CONTROLLED BY 'Feedback Gain' SLIDER)

	arealL, aimagL	hilbert	aInL								;HILBERT OPCODE OUTPUTS TWO PHASE SHIFTED SIGNALS, EACH 90 OUT OF PHASE WITH EACH OTHER
	arealR, aimagR	hilbert	aInR								;HILBERT OPCODE OUTPUTS TWO PHASE SHIFTED SIGNALS, EACH 90 OUT OF PHASE WITH EACH OTHER

	kporttime	linseg	0,0.001,0.02
	kfshift	portk	k2FREQSHIFTER*k3FREQSHIFTER, kporttime
	;QUADRATURE OSCILLATORS. I.E. 90 OUT OF PHASE WITH RESPECT TO EACH OTHER
	;OUTUTS	OPCODE	AMPLITUDE | FREQ. | FUNCTION_TABLE | INITIAL_PHASE (OPTIONAL;DEFAULTS TO ZERO)
	asinL 	oscili       1,    kfshift,     gisine,          0
	asinR 	oscili       1,    kfshift,     gisine,          0
	acosL 	oscili       1,    kfshift,     gisine,          .25
	acosR 	oscili       1,    kfshift,     gisine,          .25
	
	;RING MODULATE EACH SIGNAL USING THE QUADRATURE OSCILLATORS AS MODULATORS
	amod1L = arealL * acosL
	amod1R = arealR * acosR
	amod2L = aimagL * asinL
	amod2R = aimagR * asinR
	
	;UPSHIFTING OUTPUT
	aOutL = (amod1L - amod2L)
	aOutR = (amod1R - amod2R)
	
	gaSigL	sum	aOutL*kWet, gaSigL*kDry
	gaSigR	sum	aOutR*kWet, gaSigR*kDry 
endin

instr	18	;RINGMODULATOR
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use RINGMODULATORLED widget controller for effect ON/OFF light
	;Use RINGMODULATOROnOff widget button to Start/Stop effect (event i 1 0 0.01 8)

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1RINGMODULATOR	invalue	"RINGMODULATOR_Mix"
		k2RINGMODULATOR	invalue	"RINGMODULATOR_Freq"
		k3RINGMODULATOR	invalue	"RINGMODULATOR_Env"

						outvalue	"RINGMODULATORLED", 1		;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"RINGMODULATORLED", 0						;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	kWet		table	k1RINGMODULATOR, giWet, 1				;RESCALE WET LEVEL CONTROL ACCORDING TO FUNCTION TABLE giWet
	kDry		table	k1RINGMODULATOR, giDry, 1				;RESCALE DRY LEVEL CONTROL ACCORDING TO FUNCTION TABLE giWet
	kporttime	linseg	0,0.001,0.02							;PORTAMENTO VARIABLE
	kModFrq	portk	k2RINGMODULATOR, kporttime				;SMOOTH VARIABLE CHANGES
	kRMSL	rms		gaSigL								;FOLLOW THE RMS VALUE OF THE LEFT CHANNEL
	kRMSR	rms		gaSigR								;FOLLOW THE RMS VALUE OF THE RIGHT CHANNEL
	kModFrqL	=		kModFrq + (cpsoct(kRMSL*k3RINGMODULATOR*100))     ;CREATE A LEFT CHANNEL MODULATING FREQUENCY BASE ON THE STATIC VALUE CREATED BY KNOB 2 AND THE AMOUNT OF DYNAMIC ENVELOPE FOLLOWING GOVERNED BY KNOB 3
	kModFrqR	=		kModFrq + (cpsoct(kRMSR*k3RINGMODULATOR*100))     ;CREATE A RIGHT CHANNEL MODULATING FREQUENCY BASE ON THE STATIC VALUE CREATED BY KNOB 2 AND THE AMOUNT OF DYNAMIC ENVELOPE FOLLOWING GOVERNED BY KNOB 3

	aModL	poscil	1, kModFrqL, gisine  					;CREATE RING MODULATING SIGNAL (LEFT CHANNEL)
	aModR	poscil	1, kModFrqR, gisine  					;CREATE RING MODULATING SIGNAL (RIGHT CHANNEL)
	gaSigL	sum		gaSigL*kDry, gaSigL*aModL*kWet			;MIX DRY AND WET SIGNALS (LEFT CHANNEL)
	gaSigR	sum		gaSigR*kDry, gaSigR*aModR*kWet			;MIX DRY AND WET SIGNALS (RIGHT CHANNEL)
endin

instr	19	;PHASER
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use PHASERLED widget controller for effect ON/OFF light
	;Use PHASEROnOff widget button to Start/Stop effect (event i 1 0 0.01 9)

	iExp1	ftgentmp	0, 0, 129, -25, 0, 0.01, 128, 14.0			;TABLE FOR EXP SLIDER

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1PHASER		invalue	"PHASER_Rate"
		k1PHASER		tablei	k1PHASER, iExp1, 1
		k2PHASER		invalue	"PHASER_Depth"
		k3PHASER		invalue	"PHASER_Freq"
		k4PHASER		invalue	"PHASER_FBack"

					outvalue	"PHASERLED", 1					;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"PHASERLED", 0								;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	klfo		lfo		k2PHASER*0.5, k1PHASER, 1									;LFO FOR THE PHASER (TRIANGULAR SHAPE)
	gaSigL	phaser1	gaSigL, cpsoct((klfo+(k2PHASER*0.5)+k3PHASER)), 8, k4PHASER			;PHASER1 IS APPLIED TO THE LEFT CHANNEL
	gaSigR	phaser1	gaSigR, cpsoct((klfo+(k2PHASER*0.5)+k3PHASER)), 8, k4PHASER			;PHASER1 IS APPLIED TO THE RIGHT CHANNEL
endin

instr	20	;LoFi
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use LoFiLED widget controller for effect ON/OFF light
	;Use LoFiOnOff widget button to Start/Stop effect (event i 1 0 0.01 10)

	iExp1	ftgentmp	0, 0, 129, -25, 0, 1.0, 128, 256.0			;TABLE FOR EXP SLIDER

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1LoFi		invalue	"LoFi_Bits"
		k2LoFi		invalue	"LoFi_Fold"
		k2LoFi		tablei	k2LoFi, iExp1, 1
					outvalue	"LoFiLED", 1					;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"LoFiLED", 0								;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	kvalues	pow	2, ((1-k1LoFi)*15)+1						;RAISES 2 TO THE POWER OF kbitdepth. THE OUTPUT VALUE REPRESENTS THE NUMBER OF POSSIBLE VALUES AT THAT PARTICULAR BIT DEPTH
	k16bit	pow	2, 16									;RAISES 2 TO THE POWER OF 16

	gaSigL	=	(int((gaSigL*32768*kvalues)/k16bit)/32768)*(k16bit/kvalues)				;BIT DEPTH REDUCE AUDIO SIGNAL (LEFT CHANNEL)
	gaSigR	=	(int((gaSigR*32768*kvalues)/k16bit)/32768)*(k16bit/kvalues)				;BIT DEPTH REDUCE AUDIO SIGNAL (RIGHT CHANNEL)
	gaSigL	fold 	gaSigL, k2LoFi							;APPLY SAMPLING RATE FOLDOVER (LEFT CHANNEL) 
	gaSigR	fold 	gaSigR, k2LoFi							;APPLY SAMPLING RATE FOLDOVER (RIGHT CHANNEL)		
endin

instr	21	;FILTER
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use FILTERLED widget controller for effect ON/OFF light
	;Use FILTEROnOff widget button to Start/Stop effect (event i 1 0 0.01 11)

	iExp1	ftgentmp	0, 0, 129, -25, 0, 20.0, 128, 20000.0		;TABLE FOR EXP SLIDER
	iExp2	ftgentmp	0, 0, 129, -25, 0, 1.0, 128, 20.0			;TABLE FOR EXP SLIDER

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1FILTER		invalue	"FILTER_HPF"
		k1FILTER		tablei	k1FILTER, iExp1, 1
		k2FILTER		invalue	"FILTER_LPF"
		k2FILTER		tablei	k2FILTER, iExp1, 1
		k3FILTER		invalue	"FILTER_Gain"
		k3FILTER		tablei	k3FILTER, iExp2, 1

					outvalue	"FILTERLED", 1					;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"FILTERLED", 0								;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	kporttime	linseg	0,0.001,0.02							;RAMPING UP PORTAMENTO TIME VARIABLE
	kHPF		portk	k1FILTER, kporttime						;APPLY PORTAMENTO TO HIGH-PASS FILTER CUTOFF VARIABLE
	kLPF		portk	k2FILTER, kporttime						;APPLY PORTAMENTO TO HIGH-PASS FILTER CUTOFF VARIABLE

	aFiltL	buthp	gaSigL, kHPF							;HIGH-PASS FILTER GLOBAL AUDIO SIGNAL (LEFT CHANNEL)
	aFiltR	buthp	gaSigR, kHPF							;HIGH-PASS FILTER GLOBAL AUDIO SIGNAL (RIGHT CHANNEL)
	aFiltL	buthp	aFiltL, kHPF							;HIGH-PASS FILTER AUDIO SIGNAL FROM PREVIOUS FILTER (LEFT CHANNEL) 
	aFiltR	buthp	aFiltR, kHPF							;HIGH-PASS FILTER AUDIO SIGNAL FROM PREVIOUS FILTER (RIGHT CHANNEL)
	aFiltL	butlp	aFiltL, kLPF							;LOW-PASS FILTER GLOBAL AUDIO SIGNAL (LEFT CHANNEL)       
	aFiltR	butlp	aFiltR, kLPF							;LOW-PASS FILTER GLOBAL AUDIO SIGNAL (RIGHT CHANNEL)      
	aFiltL	butlp	aFiltL, kLPF							;LOW-PASS FILTER AUDIO SIGNAL FROM PREVIOUS FILTER (LEFT CHANNEL) 
	aFiltR	butlp	aFiltR, kLPF							;LOW-PASS FILTER AUDIO SIGNAL FROM PREVIOUS FILTER (RIGHT CHANNEL)
	gaSigL	=		aFiltL*k3FILTER						;REDEFINE GLOBAL AUDIO LEFT CHANNEL SIGNAL WITH OUTPUT FROM LAST FILTER. RESCALE WITH GAIN CONTROL (LEFT CHANNEL)  
	gaSigR	=		aFiltR*k3FILTER						;REDEFINE GLOBAL AUDIO RIGHT CHANNEL SIGNAL WITH OUTPUT FROM LAST FILTER. RESCALE WITH GAIN CONTROL (RIGHT CHANNEL)
endin

instr	22	;PANTREM
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use PANTREMLED widget controller for effect ON/OFF light
	;Use PANTREMOnOff widget button to Start/Stop effect (event i 1 0 0.01 12)

	iExp1	ftgentmp	0, 0, 129, -25, 0, 0.1, 128, 50.0			;TABLE FOR EXP SLIDER

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1PANTREM		invalue	"PANTREM_Rate"
		k1PANTREM		tablei	k1PANTREM, iExp1, 1
		k2PANTREM		invalue	"PANTREM_Depth"
		k3PANTREM		invalue	"PAN_TREM"
		k4PANTREM		invalue	"PANTREM_Wave"

					outvalue	"PANTREMLED", 1				;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"PANTREMLED", 0							;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	ktrig	changed	k4PANTREM								;IF LFO WAVEFORM TYPE IS CHANGED GENERATE A MOMENTARY '1' (BANG)
	if ktrig=1 then										;IF A 'BANG' HAS BEEN GENERATED IN THE ABOVE LINE
		reinit	UPDATE									;BEGIN A REINITIALIZATION PASS FROM LABEL 'UPDATE' SO THAT LFO WAVEFORM TYPE CAN BE UPDATED
	endif												;END OF THIS CONDITIONAL BRANCH

	UPDATE:												;LABEL CALLED UPDATE
	klfo		lfo			k2PANTREM, k1PANTREM, i(k4PANTREM)		;CREATE AN LFO
			rireturn										;RETURN FROM REINITIALIZATION PASS
	klfo	=	(klfo*0.5)+0.5									;RESCALE AND OFFSET LFO SO IT STAY WITHIN THE RANGE 0 - 1 ABOUT THE VALUE 0.5
	if k4PANTREM=2 then										;IF SQUARE WAVE MODULATION HAS BEEN CHOSEN...
		klfo	portk	klfo, 0.001							;SMOOTH THE WAVE A TINY BIT TO PREVENT CLICKS
	endif												;END OF THIS CONDITIONAL BRANCH	
	if k3PANTREM=0 then										;PAN	IF PANNING MODE IS CHOSEN FROM BUTTON BANK...
		alfo		interp	klfo								;INTERPOLATE K-RATE LFO AND CREATE A-RATE VARIABLE
		gaSigL	=		gaSigL*sqrt(alfo)					;REDEFINE GLOBAL AUDIO LEFT CHANNEL SIGNAL WITH AUTO-PANNING
		gaSigR	=		gaSigR*(1-sqrt(alfo))				;REDEFINE GLOBAL AUDIO RIGHT CHANNEL SIGNAL WITH AUTO-PANNING
	elseif k3PANTREM=1 then									;TREM IF TREMELO MODE IS CHOSEN FROM BUTTON BANK...
		klfo		=		klfo+(0.5-(k2PANTREM*0.5))			;MODIFY LFO AT ZERO DEPTH VALUE IS 1 AND AT MAX DEPTH CENTRE OF MODULATION IS 0.5
		alfo		interp	klfo								;INTERPOLATE K-RATE LFO AND CREATE A-RATE VARIABLE
		gaSigL	=		gaSigL*(alfo^2)					;REDEFINE GLOBAL AUDIO LEFT CHANNEL SIGNAL WITH TREMELO
		gaSigR	=		gaSigR*(alfo^2)					;REDEFINE GLOBAL AUDIO RIGHT CHANNEL SIGNAL WITH TREMELO
	endif												;END OF THIS CONDITIONAL BRANCH
endin

instr	23	;CHORUS
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use CHORUSLED widget controller for effect ON/OFF light
	;Use CHORUSOnOff widget button to Start/Stop effect (event i 1 0 0.01 13)

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1CHORUS		invalue	"CHORUS_Rate"
		k2CHORUS		invalue	"CHORUS_Depth"
		k3CHORUS		invalue	"CHORUS_Width"

					outvalue	"CHORUSLED", 1					;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"CHORUSLED", 0								;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	ilfoshape		ftgentmp	0, 0, 131072, 19, 1, 0.5, 0,  0.5		;POSITIVE DOMAIN INLY SINE WAVE	
	kporttime		linseg	0,0.001,0.02						;RAMPING UP PORTAMENTO VARIABLE
	kChoDepth		portk	k2CHORUS*0.001, kporttime			;SMOOTH VARIABLE CHANGES WITH PORTK
	aChoDepth		interp	kChoDepth							;INTERPOLATE TO CREATE A-RATE VERSION OF K-RATE VARIABLE
	amodL 		osciliktp	k1CHORUS, ilfoshape, 0				;LEFT CHANNEL LFO
	amodR 		osciliktp k1CHORUS, ilfoshape, k3CHORUS			;THE PHASE OF THE RIGHT CHANNEL LFO IS ADJUSTABLE
	amodL		=		(amodL*aChoDepth)+.01				;RESCALE AND OFFSET LFO (LEFT CHANNEL)
	amodR		=		(amodR*aChoDepth)+.01				;RESCALE AND OFFSET LFO (RIGHT CHANNEL)
	aChoL		vdelay	gaSigL, amodL*1000, 1.2*1000			;CREATE VARYING DELAYED / CHORUSED SIGNAL (LEFT CHANNEL) 
	aChoR		vdelay	gaSigR, amodR*1000, 1.2*1000			;CREATE VARYING DELAYED / CHORUSED SIGNAL (RIGHT CHANNEL)
	gaSigL		sum 		aChoL*0.6, gaSigL*0.6                 	;MIX DRY AND WET SIGNAL (LEFT CHANNEL) 
	gaSigR		sum 		aChoR*0.6, gaSigR*0.6				;MIX DRY AND WET SIGNAL (RIGHT CHANNEL)
endin

instr	24	;FLANGER
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use FLANGERLED widget controller for effect ON/OFF light
	;Use FLANGEROnOff widget button to Start/Stop effect (event i 1 0 0.01 14)

	iExp1	ftgentmp	0, 0, 129, -25, 0, 0.001, 128, 7.0			;TABLE FOR EXP SLIDER
	
	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1FLANGER		invalue	"FLANGER_Rate"
		k1FLANGER		tablei	k1FLANGER, iExp1, 1
		k2FLANGER		invalue	"FLANGER_Depth"
		k3FLANGER		invalue	"FLANGER_Delay"
		k4FLANGER		invalue	"FLANGER_FBack"

					outvalue	"FLANGERLED", 1				;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus            			;READ EFFECT ON/OFF STATUS FROM TABLE                    
	if kStatus=0 then                            	   			;IF THIS EFFECT HAS BEEN TURNED OFF                      
		outvalue	"FLANGERLED", 0	        		  			;SWITCH OFF THE LED                                      
		turnoff                                		 			;TURN THIS INSTRUMENT OFF                                
	endif                                 	          			;END OF THIS CONDITIONAL BRANCH                          

	ilfoshape		ftgentmp	0, 0, 131072, 19, 0.5, 1, 180, 1		;U-SHAPE PARABOLA FOR LFO
	kporttime		linseg	0, 0.001, 0.1 						;USE OF AN ENVELOPE VALUE THAT QUICKLY RAMPS UP FROM ZERON TO THE REQUIRED VALUE PREVENTS VARIABLES GLIDING TO THEIR REQUIRED VALUES EACH TIME THE INSTRUMENT IS STARTED
	kdlt			portk	k3FLANGER*0.001, kporttime 			;PORTAMENTO IS APPLIED TO A VARIABLE. A NEW VARIABLE 'kdlt' IS CREATED.
	adlt			interp	kdlt								;A NEW A-RATE VARIABLE 'adlt' IS CREATED BY INTERPOLATING THE K-RATE VARIABLE 'kdlt'                                                           
	kdep			portk	k2FLANGER*0.001, kporttime 			;PORTAMENTO IS APPLIED TO A VARIABLE. A NEW VARIABLE 'kdlt' IS CREATED.
	amod			oscili	kdep, k1FLANGER, ilfoshape			;OSCILLATOR THAT MAKES USE OF THE POSITIVE DOMAIN ONLY U-SHAPE PARABOLA WITH FUNCTION TABLE NUMBER gilfoshape                                                                                             
	adlt			sum		adlt, amod						;STATIC DELAY TIME AND MODULATING DELAY TIME ARE SUMMED
	adelsigL		flanger	gaSigL, adlt, k4FLANGER , 1.2			;FLANGER SIGNAL CREATED (LEFT CHANNEL)
	adelsigR		flanger	gaSigR, adlt, k4FLANGER , 1.2			;FLANGER SIGNAL CREATED (RIGHT CHANNEL)
	gaSigL		sum		gaSigL*0.5, adelsigL*0.5				;CREATE DRY/WET MIX (LEFT CHANNEL) 
	gaSigR		sum		gaSigR*0.5, adelsigR*0.5				;CREATE DRY/WET MIX (RIGHT CHANNEL)
endin

instr	25	;DELAY
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use DELAYLED widget controller for effect ON/OFF light
	;Use DELAYOnOff widget button to Start/Stop effect (event i 1 0 0.01 15)

	iExp1	ftgentmp	0, 0, 129, -25, 0, 0.01, 128, 5.0			;TABLE FOR EXP SLIDER

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1DELAY		invalue	"DELAY_Mix"
		k2DELAY		invalue	"DELAY_Time"
		k2DELAY		tablei	k2DELAY, iExp1, 1
		k3DELAY		invalue	"DELAY_FBack"
		k4DELAY		invalue	"DELAY_HFLoss"

					outvalue	"DELAYLED", 1					;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE                    
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF                      
		outvalue	"DELAYLED", 0								;SWITCH OFF THE LED                                      
		turnoff											;TURN THIS INSTRUMENT OFF                                
	endif												;END OF THIS CONDITIONAL BRANCH                          

	kWet		table	k1DELAY, giWet, 1						;RESCALE WET LEVEL CONTROL ACCORDING TO FUNCTION TABLE giWet
	kDry		table	k1DELAY, giDry, 1						;RESCALE DRY LEVEL CONTROL ACCORDING TO FUNCTION TABLE giWet
	kporttime	linseg	0,0.001,0.1							;RAMPING UP PORTAMENTO TIME
	kTime	portk	k2DELAY, kporttime*3					;APPLY PORTAMENTO SMOOTHING TO DELAY TIME PARAMETER
	kTone	portk	k4DELAY, kporttime						;APPLY PORTAMENTO SMOOTHING TO TONE PARAMETER
	aTime	interp	kTime								;INTERPOLATE AND CREAT A-RATE VERSION OF DELAY TIME PARAMETER
	aBuffer	delayr	5									;READ FROM (AND INITIALIZE) BUFFER (LEFT CHANNEL)
	atapL	deltap3	aTime								;TAP DELAY BUFFER (LEFT CHANNEL)
	atapL	tone		atapL, kTone							;LOW-PASS FILTER DELAY TAP WITHIN DELAY BUFFER (LEFT CHANNEL) 
			delayw	gaSigL+(atapL*k3DELAY)					;WRITE INPUT AUDIO AND FEEDBACK SIGNAL INTO DELAY BUFFER  (LEFT CHANNEL) 
	aBuffer	delayr	5									;READ FROM (AND INITIALIZE) BUFFER (RIGHT CHANNEL)
	atapR	deltap3	aTime								;TAP DELAY BUFFER (LEFT CHANNEL)                             
	atapR	tone		atapR, kTone							;LOW-PASS FILTER DELAY TAP WITHIN DELAY BUFFER (LEFT CHANNEL)
			delayw	gaSigR+(atapR*k3DELAY)					;WRITE INPUT AUDIO AND FEEDBACK SIGNAL INTO DELAY BUFFER  (LEFT CHANNEL)
	gaSigL	sum		gaSigL*kDry, atapL*kWet					;REDEFINE GLOBAL AUDIO SIGNAL FROM MIX OF DRY AND WET SIGNALS (LEFT CHANNEL) 
	gaSigR	sum		gaSigR*kDry, atapR*kWet					;REDEFINE GLOBAL AUDIO SIGNAL FROM MIX OF DRY AND WET SIGNALS (RIGHT CHANNEL)
endin

instr	26	;REVERB
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use REVERBLED widget controller for effect ON/OFF light
	;Use REVERBOnOff widget button to Start/Stop effect (event i 1 0 0.01 16)

	iExp1	ftgentmp	0, 0, 129, -25, 0, 20.0, 128, 20000.0		;TABLE FOR EXP SLIDER

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1REVERB		invalue	"REVERB_Mix"
		k2REVERB		invalue	"REVERB_Size"
		k3REVERB		invalue	"REVERB_Tone"
		k3REVERB		tablei	k3REVERB, iExp1, 1

					outvalue	"REVERBLED", 1					;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE                    
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF                      
		outvalue	"REVERBLED", 0								;SWITCH OFF THE LED                                      
		turnoff										     ;TURN THIS INSTRUMENT OFF                                
	endif												;END OF THIS CONDITIONAL BRANCH                          

	kWet		table	k1REVERB, giWet, 1						;RESCALE WET LEVEL CONTROL ACCORDING TO FUNCTION TABLE giWet
	kDry		table	k1REVERB, giDry, 1						;RESCALE DRY LEVEL CONTROL ACCORDING TO FUNCTION TABLE giWet

	aRvbL, aRvbR	reverbsc	gaSigL, gaSigR, k2REVERB, k3REVERB		;CREATE STEREO REVERB SIGNAL
	gaSigL		sum		gaSigL*kDry, aRvbL*kWet			  	;REDEFINE GLOBAL AUDIO SIGNAL FROM MIX OF DRY AND WET SIGNALS (LEFT CHANNEL) 
	gaSigR		sum		gaSigR*kDry, aRvbR*kWet			    	;REDEFINE GLOBAL AUDIO SIGNAL FROM MIX OF DRY AND WET SIGNALS (RIGHT CHANNEL)
endin

instr	27	;EQUALIZER
	;GUI-----------------------------------------------------------------------------------------------------------------------------------
	;Use EQUALIZERLED widget controller for effect ON/OFF light
	;Use EQUALIZEROnOff widget button to Start/Stop effect (event i 1 0 0.01 17)

	kUpdate	metro	$UPDATE
	if (kUpdate == 1)	then
		k1EQUALIZER	invalue	"EQUALIZER_100"
		k2EQUALIZER	invalue	"EQUALIZER_200"
		k3EQUALIZER	invalue	"EQUALIZER_400"
		k4EQUALIZER	invalue	"EQUALIZER_800"
		k5EQUALIZER	invalue	"EQUALIZER_1k6"
		k6EQUALIZER	invalue	"EQUALIZER_3k2"
		k7EQUALIZER	invalue	"EQUALIZER_6k4"
		k8EQUALIZER	invalue	"EQUALIZER_Gain"

					outvalue	"EQUALIZERLED", 1				;THIS TURNS ON THE LED FOR THE EFFECT
	endif
	;-----------------------------------------------------------------------------------------------------------------------------------

	kStatus	table	p1-10, giOnOffStatus					;READ EFFECT ON/OFF STATUS FROM TABLE
	if kStatus=0 then										;IF THIS EFFECT HAS BEEN TURNED OFF
		outvalue	"EQUALIZERLED", 0							;SWITCH OFF THE LED
		turnoff											;TURN THIS INSTRUMENT OFF
	endif												;END OF THIS CONDITIONAL BRANCH

	iQ			init		1								;Q OF THE FILTERS
	iEQcurve		ftgentmp	0,0,4096,-16,1/64,4096,7.9,64			;AMPLITUDE GAIN CURVE
	iGainCurve	ftgentmp	0,0,4096,-16,0.5,4096,3,4			;GLOBAL GAIN CURVE

	k1		table	k1EQUALIZER, iEQcurve, 1					;RESCALE INPUT 1 USING THE CURVE DEFINED ABOVE
	k2		table	k2EQUALIZER, iEQcurve, 1					;RESCALE INPUT 2 USING THE CURVE DEFINED ABOVE
	k3		table	k3EQUALIZER, iEQcurve, 1					;RESCALE INPUT 3 USING THE CURVE DEFINED ABOVE
	k4		table	k4EQUALIZER, iEQcurve, 1					;RESCALE INPUT 4 USING THE CURVE DEFINED ABOVE
	k5		table	k5EQUALIZER, iEQcurve, 1					;RESCALE INPUT 5 USING THE CURVE DEFINED ABOVE
	k6		table	k6EQUALIZER, iEQcurve, 1					;RESCALE INPUT 6 USING THE CURVE DEFINED ABOVE
	k7		table	k7EQUALIZER, iEQcurve, 1					;RESCALE INPUT 7 USING THE CURVE DEFINED ABOVE
	k8		table	k8EQUALIZER, iGainCurve, 1				;RESCALE INPUT 7 USING THE CURVE DEFINED ABOVE

	aInL		=		gaSigL*0.15*k8							;INPUT SIGNAL (LEFT CHANNEL)
	aInR		=		gaSigR*0.15*k8							;INPUT SIGNAL (RIGHT CHANNEL)	
	a1L		pareq 	aInL,  100,  k1, iQ , 1					;LOW SHELVING FILTER (LEFT CHANNEL)
	a2L		pareq 	aInL,  200,  k2, iQ , 0					;PEAKING FILTER (LEFT CHANNEL)
	a3L		pareq 	aInL,  400,  k3, iQ , 0					;PEAKING FILTER (LEFT CHANNEL) 
	a4L		pareq 	aInL,  800,  k4, iQ , 0					;PEAKING FILTER (LEFT CHANNEL) 
	a5L		pareq 	aInL, 1600,  k5, iQ , 0					;PEAKING FILTER (LEFT CHANNEL) 
	a6L		pareq 	aInL, 3200,  k6, iQ , 0					;PEAKING FILTER (LEFT CHANNEL) 
	a7L		pareq 	aInL, 6400,  k7, iQ , 2					;HIGH SHELVING FILTER (LEFT CHANNEL) 
	a1R		pareq 	aInR,  100,  k1, iQ , 1					;LOW SHELVING FILTER (RIGHT CHANNEL) 
	a2R		pareq 	aInR,  200,  k2, iQ , 0					;PEAKING FILTER (RIGHT CHANNEL)
	a3R		pareq 	aInR,  400,  k3, iQ , 0					;PEAKING FILTER (RIGHT CHANNEL) 
	a4R		pareq 	aInR,  800,  k4, iQ , 0					;PEAKING FILTER (RIGHT CHANNEL) 
	a5R		pareq 	aInR, 1600,  k5, iQ , 0					;PEAKING FILTER (RIGHT CHANNEL) 
	a6R		pareq 	aInR, 3200,  k6, iQ , 0					;PEAKING FILTER (RIGHT CHANNEL) 
	a7R		pareq 	aInR, 6400,  k7, iQ , 2					;HIGH SHELVING FILTER (RIGHT CHANNEL) 

	gaSigL	sum		a1L, a2L, a3L, a4L, a5L, a6L, a7L			;SUM THE FILTER OUTPUTS (LEFT CHANNEL)
	gaSigR	sum		a1R, a2R, a3R, a4R, a5R, a6R, a7R			;SUM THE FILTER OUTPUTS (RIGHT CHANNEL)
endin

instr	99	;OUTPUT (ALWAYS ON)
			outs		gaSigL, gaSigR							;SEND AUDIO FROM THE FINAL ACTIVE EFFECT TO THE OUTPUTS
endin
</CsInstruments>
<CsScore>
i 2  0 3600	;INPUT
i 99 0 3600	;OUTPUT
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1</x>
 <y>28</y>
 <width>1364</width>
 <height>734</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>179</r>
  <g>179</g>
  <b>179</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>53</y>
  <width>212</width>
  <height>330</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Volume</objectName>
  <x>68</x>
  <y>91</y>
  <width>80</width>
  <height>80</height>
  <uuid>{a8708ba6-9862-4396-a241-48db96d3d59f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>31</x>
  <y>202</y>
  <width>146</width>
  <height>44</height>
  <uuid>{2033e3b0-be04-42bf-8539-2ed31b3edd62}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VOLUME</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>30</fontsize>
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
  <x>68</x>
  <y>176</y>
  <width>80</width>
  <height>25</height>
  <uuid>{a520cddc-6eba-4302-922d-f612b3c48982}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Volume</label>
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
  <x>18</x>
  <y>255</y>
  <width>180</width>
  <height>110</height>
  <uuid>{3f71d494-4ce6-447a-b28f-1c4e9761b31d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 0</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>102</x>
  <y>61</y>
  <width>15</width>
  <height>15</height>
  <uuid>{5d29a755-55c0-43a3-b4a2-6a7fe0a280f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>VOLUMELED</objectName2>
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
   <r>255</r>
   <g>0</g>
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
  <x>214</x>
  <y>53</y>
  <width>212</width>
  <height>330</height>
  <uuid>{2c70a08a-875a-4696-bad2-5dda563585c8}</uuid>
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
   <r>0</r>
   <g>117</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>File</objectName>
  <x>241</x>
  <y>106</y>
  <width>70</width>
  <height>70</height>
  <uuid>{3c7be073-7583-4647-828e-f21d50c8c6ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.38000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>216</x>
  <y>204</y>
  <width>210</width>
  <height>44</height>
  <uuid>{de8b26ac-0e00-427d-bad6-b7aca47df5a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FILE - PLAY</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>241</x>
  <y>176</y>
  <width>70</width>
  <height>25</height>
  <uuid>{3fd93693-2857-4711-8eae-d704e574f4fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>File</label>
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
  <x>230</x>
  <y>255</y>
  <width>180</width>
  <height>110</height>
  <uuid>{e9dbd344-b1cd-4be0-ab1b-a7406adfa9f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>312</x>
  <y>61</y>
  <width>15</width>
  <height>15</height>
  <uuid>{c1c3c39d-8965-44cb-bf21-761647d0aea9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>FILEPLAYLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Live</objectName>
  <x>323</x>
  <y>106</y>
  <width>70</width>
  <height>70</height>
  <uuid>{090cca3a-97e7-4164-b6c5-9fd85278ff30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.18000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>323</x>
  <y>176</y>
  <width>70</width>
  <height>25</height>
  <uuid>{5ccda979-b7d6-4da1-be09-5a751ef65a21}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Live</label>
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
  <x>426</x>
  <y>53</y>
  <width>212</width>
  <height>330</height>
  <uuid>{36782777-d577-416b-83f0-0577026e838b}</uuid>
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
   <r>68</r>
   <g>136</g>
   <b>204</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>428</x>
  <y>204</y>
  <width>210</width>
  <height>44</height>
  <uuid>{2cc80ee2-97a5-4a69-b9c7-6d5e23e2d27c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>COMPRESSOR</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>442</x>
  <y>255</y>
  <width>180</width>
  <height>110</height>
  <uuid>{e6569c64-f79a-4af0-8061-5b915eee5abb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 2</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>524</x>
  <y>61</y>
  <width>15</width>
  <height>15</height>
  <uuid>{8d2caf0e-5b02-4d1a-9ac2-6ffaf1661d77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>COMPRESSORLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>COMPRESSOR_Thresh</objectName>
  <x>431</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{4d78354b-1174-4ca9-a35c-a8a3bd5509ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.05000000</maximum>
  <value>0.02000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>COMPRESSOR_Ratio</objectName>
  <x>482</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{7b3fb5d5-1f3d-4ee7-b9ce-d78d23f0954d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.44000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>COMPRESSOR_Att</objectName>
  <x>533</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{2fff7c80-0daa-4ac0-8e06-00c832f02927}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01000000</minimum>
  <maximum>0.30000000</maximum>
  <value>0.18690000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>COMPRESSOR_PostGain</objectName>
  <x>584</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{d91250a9-c441-4c0d-9011-ab907f7588ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.12000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>431</x>
  <y>164</y>
  <width>50</width>
  <height>25</height>
  <uuid>{bfcdf16c-2446-4a7d-abf3-fd4160a587bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Thresh</label>
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
  <x>482</x>
  <y>164</y>
  <width>50</width>
  <height>25</height>
  <uuid>{097325a6-18be-49ee-8daa-3852e9a6e033}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Ratio</label>
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
  <x>533</x>
  <y>164</y>
  <width>50</width>
  <height>25</height>
  <uuid>{376daff6-8270-4a23-a240-d653ef9a9f6d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Att</label>
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
  <x>584</x>
  <y>164</y>
  <width>50</width>
  <height>50</height>
  <uuid>{a6f452b6-3fde-4703-97bb-1c7507a043bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Post
Gain</label>
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
  <x>638</x>
  <y>53</y>
  <width>212</width>
  <height>330</height>
  <uuid>{a231f9a8-4f0a-447b-a718-cc2c60223c59}</uuid>
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
   <r>171</r>
   <g>156</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>640</x>
  <y>204</y>
  <width>210</width>
  <height>44</height>
  <uuid>{3db9bfd4-7172-495a-8b3a-6a8d31c9274e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ENV FOLLOWER</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>654</x>
  <y>255</y>
  <width>180</width>
  <height>110</height>
  <uuid>{d53e0bf0-becf-44da-bf69-2943fc1415f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 3</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>736</x>
  <y>61</y>
  <width>15</width>
  <height>15</height>
  <uuid>{96099d5b-12a6-42a6-aea5-33cc5525c7f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>ENVFOLLOWERLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>ENVFOLLOWER_Sens</objectName>
  <x>651</x>
  <y>113</y>
  <width>60</width>
  <height>60</height>
  <uuid>{b9bf3bec-4784-4b79-b770-6bd3c1e2a360}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.79000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>651</x>
  <y>175</y>
  <width>60</width>
  <height>25</height>
  <uuid>{6407d059-deac-4ad6-ae36-6f51ac7216c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sens</label>
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
  <objectName>ENVFOLLOWER_Freq</objectName>
  <x>714</x>
  <y>113</y>
  <width>60</width>
  <height>60</height>
  <uuid>{62141e93-4e85-4682-8f3b-42c80b524692}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.67000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>714</x>
  <y>175</y>
  <width>60</width>
  <height>25</height>
  <uuid>{3132e6f6-7793-4a49-897d-320675ad0a37}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Freq</label>
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
  <objectName>ENVFOLLOWER_Res</objectName>
  <x>777</x>
  <y>113</y>
  <width>60</width>
  <height>60</height>
  <uuid>{2abde9a1-341c-4e0d-880b-99753ea32d26}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.95000000</maximum>
  <value>0.72200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>777</x>
  <y>175</y>
  <width>60</width>
  <height>25</height>
  <uuid>{03e9f26e-7824-4581-bad9-b91c7c537ccc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Res</label>
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
  <x>850</x>
  <y>53</y>
  <width>212</width>
  <height>330</height>
  <uuid>{547b2b4a-6c67-49e0-a840-14bf273601fd}</uuid>
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
   <r>195</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>852</x>
  <y>204</y>
  <width>210</width>
  <height>44</height>
  <uuid>{d106d31a-f0b3-4e64-9d42-19344d63ee97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>DISTORTION</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>865</x>
  <y>255</y>
  <width>180</width>
  <height>110</height>
  <uuid>{b506abe9-a93b-4c52-a1b9-923463fcbe4b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 4</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>948</x>
  <y>61</y>
  <width>15</width>
  <height>15</height>
  <uuid>{61de7a54-70c4-4394-a0b1-e3b23e2c47d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>DISTORTIONLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>DISTORTION_Level</objectName>
  <x>863</x>
  <y>113</y>
  <width>60</width>
  <height>60</height>
  <uuid>{94bd06ba-37d2-4008-8826-5a3d74136edd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.80000000</maximum>
  <value>0.50400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>863</x>
  <y>175</y>
  <width>60</width>
  <height>25</height>
  <uuid>{e6fc0d35-d0aa-495e-8525-3ffe59ccdd20}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Level</label>
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
  <objectName>DISTORTION_Drive</objectName>
  <x>926</x>
  <y>113</y>
  <width>60</width>
  <height>60</height>
  <uuid>{4de059a5-2f52-437c-84ab-d6bb028f83c8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.59000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>926</x>
  <y>175</y>
  <width>60</width>
  <height>25</height>
  <uuid>{1ae9aba5-318f-4e27-b3bd-8f58456d2f7d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Drive</label>
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
  <objectName>DISTORTION_Tone</objectName>
  <x>989</x>
  <y>113</y>
  <width>60</width>
  <height>60</height>
  <uuid>{7b22c693-bae5-4539-be61-94d2b59694e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.77000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>989</x>
  <y>175</y>
  <width>60</width>
  <height>25</height>
  <uuid>{78116d8b-ac99-4070-939b-49c4a924a99c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tone</label>
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
  <x>1062</x>
  <y>53</y>
  <width>212</width>
  <height>330</height>
  <uuid>{76f66b6b-f1b1-43bb-9d6f-0fe435462645}</uuid>
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
   <r>122</r>
   <g>122</g>
   <b>122</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>REVERSE_Time</objectName>
  <x>1128</x>
  <y>91</y>
  <width>80</width>
  <height>80</height>
  <uuid>{b92d7ecf-6af2-4ede-8cde-10042f18e8f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.30000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.45300000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1091</x>
  <y>202</y>
  <width>146</width>
  <height>44</height>
  <uuid>{5bdd6a16-f6e0-4d8d-8aec-c3922ac5bd43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>REVERSE</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>30</fontsize>
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
  <x>1128</x>
  <y>176</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5877f35a-81c0-47a3-86a7-699a7d69593f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Time</label>
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
  <x>1078</x>
  <y>255</y>
  <width>180</width>
  <height>110</height>
  <uuid>{0449dc7b-ed98-411a-ac01-4e413c2bb0f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 5</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>1162</x>
  <y>61</y>
  <width>15</width>
  <height>15</height>
  <uuid>{90aaf314-1a2c-4993-aa13-b8493c328aef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>REVERSELED</objectName2>
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
   <r>255</r>
   <g>0</g>
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
  <x>1274</x>
  <y>53</y>
  <width>212</width>
  <height>330</height>
  <uuid>{8acdec82-f102-4cfd-accd-f911139ca2b1}</uuid>
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
   <r>209</r>
   <g>209</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1276</x>
  <y>204</y>
  <width>210</width>
  <height>44</height>
  <uuid>{5c1099e3-515e-4300-9f41-70141594e7bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>PITCH SHIFTER</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>1290</x>
  <y>255</y>
  <width>180</width>
  <height>110</height>
  <uuid>{49dbb414-2046-4f92-b16f-73e7573b1a0e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 6</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>1372</x>
  <y>61</y>
  <width>15</width>
  <height>15</height>
  <uuid>{75630bb2-487e-427e-8e57-463daeb4fe9d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PITCH_SHIFTERLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PITCH_SHIFTER_Mix</objectName>
  <x>1279</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{dbf55519-a68c-4772-a301-3764af207c61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.82000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PITCH_SHIFTER_Pitch</objectName>
  <x>1330</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{d6fc6066-1cb5-4670-9e70-8e46b0ad4cc9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>-1.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PITCH_SHIFTER_Fine</objectName>
  <x>1381</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{1baced77-96fc-432a-aba9-a0eac5775dc2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-0.08333300</minimum>
  <maximum>0.08333300</maximum>
  <value>-0.00166666</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PITCH_SHIFTER_FBack</objectName>
  <x>1432</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{bb56c3e9-f329-4d78-b8ad-dc72c3a05eb5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.47000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1279</x>
  <y>164</y>
  <width>50</width>
  <height>25</height>
  <uuid>{2354a319-14be-4115-b085-5c1d3f502387}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mix</label>
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
  <x>1330</x>
  <y>164</y>
  <width>50</width>
  <height>25</height>
  <uuid>{1d0c4e23-e102-45fb-8333-95448fb39118}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch</label>
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
  <x>1381</x>
  <y>164</y>
  <width>50</width>
  <height>25</height>
  <uuid>{cdae8fe4-42fa-4fdd-9bb9-d6dec7dd6246}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fine</label>
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
  <x>1432</x>
  <y>164</y>
  <width>50</width>
  <height>50</height>
  <uuid>{b68722fb-176a-4e8c-a71a-5cfebcfb82e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feed
Back</label>
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
  <x>1486</x>
  <y>53</y>
  <width>212</width>
  <height>330</height>
  <uuid>{b50ccdc3-3cd8-4dde-935f-8bd1032ca1d6}</uuid>
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
   <r>134</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1488</x>
  <y>204</y>
  <width>210</width>
  <height>44</height>
  <uuid>{82515e59-a788-45ac-8d8a-a5a2f29eaf5e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FREQ SHIFTER</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>1502</x>
  <y>255</y>
  <width>180</width>
  <height>110</height>
  <uuid>{33e18e9b-2980-49a3-8198-f6d79d6e63ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 7</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>1584</x>
  <y>61</y>
  <width>15</width>
  <height>15</height>
  <uuid>{3af52026-b284-49b0-9c9b-e573d9be946e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>FREQSHIFTERLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>FREQSHIFTER_Mix</objectName>
  <x>1491</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{e4eee056-2419-41b7-8c88-a4943bb50e84}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>FREQSHIFTER_Freq</objectName>
  <x>1542</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{5aec8c49-6186-496b-bd73-a0f41875af4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1000.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>400.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>FREQSHIFTER_Mult</objectName>
  <x>1593</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{a266ecdc-4fcd-4495-9c51-11ea862b388e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>-0.08000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>FREQSHIFTER_Fback</objectName>
  <x>1644</x>
  <y>115</y>
  <width>50</width>
  <height>50</height>
  <uuid>{9ca1c6ab-cdb5-431f-972d-6ae759ef7cf8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.75000000</maximum>
  <value>0.36750000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1491</x>
  <y>164</y>
  <width>50</width>
  <height>25</height>
  <uuid>{06fbd614-c7c3-40b8-9a08-c9fa26e54443}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mix</label>
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
  <x>1542</x>
  <y>164</y>
  <width>50</width>
  <height>25</height>
  <uuid>{7abee733-183b-4541-93ee-a64e433b8a9f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Freq</label>
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
  <x>1593</x>
  <y>164</y>
  <width>50</width>
  <height>25</height>
  <uuid>{6d2fb5e6-ab22-449c-aeda-3729c30dea39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mult</label>
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
  <x>1644</x>
  <y>164</y>
  <width>50</width>
  <height>50</height>
  <uuid>{2f9e0dc9-623e-4e72-98d2-ea6c7d86343b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feed
Back</label>
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
  <x>1698</x>
  <y>53</y>
  <width>212</width>
  <height>330</height>
  <uuid>{ef54ae3b-2114-4ecc-bedb-e99705c16cc8}</uuid>
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
   <r>0</r>
   <g>170</g>
   <b>127</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1700</x>
  <y>191</y>
  <width>210</width>
  <height>70</height>
  <uuid>{b5b95e56-c8e8-4d36-8efa-a944b1ea3882}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>RING MODULATOR</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>1714</x>
  <y>255</y>
  <width>180</width>
  <height>110</height>
  <uuid>{681cdcfa-44bf-4db2-b533-5b2994226285}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 8</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>1796</x>
  <y>61</y>
  <width>15</width>
  <height>15</height>
  <uuid>{c7baf4c2-715f-4001-9e8a-58188589d4ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>RINGMODULATORLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>RINGMODULATOR_Mix</objectName>
  <x>1711</x>
  <y>113</y>
  <width>60</width>
  <height>60</height>
  <uuid>{f1ea640c-354c-4ffa-b803-0880184a6fc7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.51000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1711</x>
  <y>175</y>
  <width>60</width>
  <height>25</height>
  <uuid>{5ffcf4f4-78cc-4555-b09f-9a6aa284c4ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mix</label>
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
  <objectName>RINGMODULATOR_Freq</objectName>
  <x>1774</x>
  <y>113</y>
  <width>60</width>
  <height>60</height>
  <uuid>{674f6958-19e4-43ff-b163-6c7e395fd9a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>10.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>1806.40000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1774</x>
  <y>175</y>
  <width>60</width>
  <height>25</height>
  <uuid>{b91982d4-fc58-4ba5-ab54-d47db1f955bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Freq</label>
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
  <objectName>RINGMODULATOR_Env</objectName>
  <x>1837</x>
  <y>113</y>
  <width>60</width>
  <height>60</height>
  <uuid>{62be06c6-09ad-483c-8878-14479f7d35f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.36000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1837</x>
  <y>175</y>
  <width>60</width>
  <height>25</height>
  <uuid>{4d7ab64b-2129-4186-b7d3-89d4580a2650}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Env</label>
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
  <x>2</x>
  <y>383</y>
  <width>212</width>
  <height>330</height>
  <uuid>{3eb85a3f-27d0-4b5c-a462-8cbcf1c4184c}</uuid>
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
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>534</y>
  <width>210</width>
  <height>44</height>
  <uuid>{d7aab340-0068-4569-bc30-4f3140d4b160}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>PHASER</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>18</x>
  <y>585</y>
  <width>180</width>
  <height>110</height>
  <uuid>{15c085ab-9775-4baa-ad41-2081d958e882}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 9</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>100</x>
  <y>391</y>
  <width>15</width>
  <height>15</height>
  <uuid>{d233959c-c33d-45d1-a49a-789611797623}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PHASERLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PHASER_Rate</objectName>
  <x>7</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{4258aaf0-73c4-47c2-8c36-9cf7fe58392f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.33000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PHASER_Depth</objectName>
  <x>58</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{f78f8546-82d0-4143-9420-ba46731ae18e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>8.00000000</maximum>
  <value>5.52000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PHASER_Freq</objectName>
  <x>109</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{df02ebf9-dfe5-4e2e-a862-3c4207e17027}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>6.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>6.90000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PHASER_FBack</objectName>
  <x>160</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{c2289a26-6049-4641-b6f0-67c40ed69ed9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.90000000</maximum>
  <value>0.70200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>494</y>
  <width>50</width>
  <height>25</height>
  <uuid>{c64162ab-f700-4d5a-aadf-9c439e142482}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate</label>
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
  <x>58</x>
  <y>494</y>
  <width>50</width>
  <height>25</height>
  <uuid>{ec98f825-7cd0-433e-b227-16d28ac9fcf9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Depth</label>
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
  <x>109</x>
  <y>494</y>
  <width>50</width>
  <height>25</height>
  <uuid>{12862cf1-dc3d-43c1-b9d1-499e6917d815}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Freq</label>
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
  <x>160</x>
  <y>494</y>
  <width>50</width>
  <height>50</height>
  <uuid>{f15ac32b-f98c-46cd-afe2-58f28f1a98a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feed
Back</label>
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
  <x>214</x>
  <y>383</y>
  <width>212</width>
  <height>330</height>
  <uuid>{1e6378b0-b6c4-400e-be59-af3411fd0179}</uuid>
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
   <r>85</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>LoFi_Bits</objectName>
  <x>241</x>
  <y>436</y>
  <width>70</width>
  <height>70</height>
  <uuid>{8ae8131e-f7a7-4f52-953e-84e7c5e6ed55}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.32000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>216</x>
  <y>534</y>
  <width>210</width>
  <height>44</height>
  <uuid>{044b5bd2-9dbc-408c-a096-49a93ff51682}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LoFi</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>241</x>
  <y>506</y>
  <width>70</width>
  <height>25</height>
  <uuid>{b3cb0fe9-8c48-4b60-8d62-3cb4d44f7bbe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bits</label>
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
  <x>230</x>
  <y>585</y>
  <width>180</width>
  <height>110</height>
  <uuid>{9ebff03f-b04f-43c6-88a6-a45e9913bc47}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>312</x>
  <y>391</y>
  <width>15</width>
  <height>15</height>
  <uuid>{a67dcd71-e496-4989-be6b-e59a636fbd56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>LoFiLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>LoFi_Fold</objectName>
  <x>323</x>
  <y>436</y>
  <width>70</width>
  <height>70</height>
  <uuid>{884367de-15a4-4858-9cac-4cf7c87f3620}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.73000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>323</x>
  <y>506</y>
  <width>70</width>
  <height>25</height>
  <uuid>{dd7a7ba0-1dbb-4822-9075-139e1c6b2155}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fold</label>
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
  <x>426</x>
  <y>383</y>
  <width>212</width>
  <height>330</height>
  <uuid>{1b57d097-e4e2-4cbb-87c6-add574513b22}</uuid>
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
   <r>75</r>
   <g>0</g>
   <b>115</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>428</x>
  <y>534</y>
  <width>210</width>
  <height>44</height>
  <uuid>{933b2e5e-54de-45dc-ada5-4a00a65c5430}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FILTER</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>442</x>
  <y>585</y>
  <width>180</width>
  <height>110</height>
  <uuid>{727f5453-4933-4f5d-af16-441c45b03f24}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 11</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>524</x>
  <y>391</y>
  <width>15</width>
  <height>15</height>
  <uuid>{c25a0992-ab26-410b-ba1b-ffc3a86db31e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>FILTERLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>FILTER_HPF</objectName>
  <x>439</x>
  <y>443</y>
  <width>60</width>
  <height>60</height>
  <uuid>{682c10f9-59bd-4eb7-bcbb-ab2de3bfa83c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.49000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>439</x>
  <y>505</y>
  <width>60</width>
  <height>25</height>
  <uuid>{25412d24-3dbc-4833-a1f4-942bccbbdb96}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>HPF</label>
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
  <objectName>FILTER_LPF</objectName>
  <x>502</x>
  <y>443</y>
  <width>60</width>
  <height>60</height>
  <uuid>{16e02472-35a9-4965-96d0-30acf6931bc2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.69000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>502</x>
  <y>505</y>
  <width>60</width>
  <height>25</height>
  <uuid>{b67abcfd-2dc9-49f6-8954-c0b9b8602a4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LPF</label>
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
  <objectName>FILTER_Gain</objectName>
  <x>565</x>
  <y>443</y>
  <width>60</width>
  <height>60</height>
  <uuid>{593db4a5-0420-4dd2-a782-9ffa2650ed4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.46000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>565</x>
  <y>505</y>
  <width>60</width>
  <height>25</height>
  <uuid>{3080d505-9c73-44b7-9b58-f5b015823cbe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
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
  <x>638</x>
  <y>383</y>
  <width>212</width>
  <height>330</height>
  <uuid>{c996df7a-e048-4a88-94e1-33bb1b18c3ad}</uuid>
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
   <r>255</r>
   <g>85</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>640</x>
  <y>521</y>
  <width>210</width>
  <height>70</height>
  <uuid>{8ddd9122-aee3-470a-be23-98138b3d7f1a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>AUTO PAN
TREMOLO</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>654</x>
  <y>585</y>
  <width>180</width>
  <height>110</height>
  <uuid>{428dbeda-e94a-4e04-871a-8a507c131281}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 12</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>736</x>
  <y>391</y>
  <width>15</width>
  <height>15</height>
  <uuid>{88fb1d3f-7e41-4f52-9bce-4c24c3b46f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PANTREMLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PANTREM_Rate</objectName>
  <x>643</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{de8474ad-464e-46d1-a844-2eddf3515f9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PANTREM_Depth</objectName>
  <x>694</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{1c738d41-2bb5-4c32-9982-676563059b34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.82000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>643</x>
  <y>494</y>
  <width>50</width>
  <height>25</height>
  <uuid>{29a9f349-64fc-4237-91f8-10a6bf32c93e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate</label>
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
  <x>694</x>
  <y>494</y>
  <width>50</width>
  <height>25</height>
  <uuid>{364da89a-a17f-4d85-9a72-3fc37eb996d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Depth</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>PAN_TREM</objectName>
  <x>766</x>
  <y>445</y>
  <width>70</width>
  <height>24</height>
  <uuid>{9bb8556e-af6a-4124-be71-7a8e6ff9d955}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Pan</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Trem</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>PANTREM_Wave</objectName>
  <x>766</x>
  <y>474</y>
  <width>70</width>
  <height>24</height>
  <uuid>{e3a19424-1653-4c6e-b623-8cd752000714}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Sine</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Tri</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sq</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>850</x>
  <y>383</y>
  <width>212</width>
  <height>330</height>
  <uuid>{feb0a2fa-7d3e-4f25-9c14-b83cc56396eb}</uuid>
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
   <r>0</r>
   <g>85</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>852</x>
  <y>521</y>
  <width>210</width>
  <height>70</height>
  <uuid>{89cdefa8-53cd-4438-bd26-70e587cdae48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>STEREO
CHORUS</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>866</x>
  <y>585</y>
  <width>180</width>
  <height>110</height>
  <uuid>{16b14937-a0e5-45e8-85ef-925b7f504e75}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 13</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>948</x>
  <y>391</y>
  <width>15</width>
  <height>15</height>
  <uuid>{d8b8fa64-d66b-460f-83ed-5583a2982f2c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>CHORUSLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>CHORUS_Rate</objectName>
  <x>863</x>
  <y>443</y>
  <width>60</width>
  <height>60</height>
  <uuid>{df2e41ac-4c04-425a-82b0-19dda4473024}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>7.00000000</maximum>
  <value>2.59063000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>863</x>
  <y>505</y>
  <width>60</width>
  <height>25</height>
  <uuid>{1545654c-7315-44b7-90b7-1905fbf84090}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate</label>
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
  <objectName>CHORUS_Depth</objectName>
  <x>926</x>
  <y>443</y>
  <width>60</width>
  <height>60</height>
  <uuid>{c28daf42-a2c3-42e9-ba81-bcb3dc5d159f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>5.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>926</x>
  <y>505</y>
  <width>60</width>
  <height>25</height>
  <uuid>{8a115549-47f3-4ec6-8d9b-333d3b0d74fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Depth</label>
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
  <objectName>CHORUS_Width</objectName>
  <x>989</x>
  <y>443</y>
  <width>60</width>
  <height>60</height>
  <uuid>{6b55a4e0-b94a-4625-9583-fb11cfb746cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.31500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>989</x>
  <y>505</y>
  <width>60</width>
  <height>25</height>
  <uuid>{418ae342-6f2d-42c3-a1b8-3bbe0bf439b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Width</label>
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
  <x>1062</x>
  <y>383</y>
  <width>212</width>
  <height>330</height>
  <uuid>{441c516e-bbc1-4a8d-bcc9-56ea24724d52}</uuid>
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
   <r>0</r>
   <g>255</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1064</x>
  <y>534</y>
  <width>210</width>
  <height>44</height>
  <uuid>{86303020-0eeb-4f26-b437-9a5a11cc13c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FLANGER</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>1078</x>
  <y>585</y>
  <width>180</width>
  <height>110</height>
  <uuid>{f737cfd5-c250-4e90-9682-5e6f85ad9297}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 14</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>1160</x>
  <y>391</y>
  <width>15</width>
  <height>15</height>
  <uuid>{e28f60cb-4155-4275-af32-d7a4f6bb92e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>FLANGERLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>FLANGER_Rate</objectName>
  <x>1067</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{6f5e3afd-f11f-40cd-8cc5-62939992cfc2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.52000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>FLANGER_Depth</objectName>
  <x>1118</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{21069229-2c93-4b38-bac9-6aef62da17b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>7.70000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>FLANGER_Delay</objectName>
  <x>1169</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{56e5b5cd-6456-4f94-85bb-238907365d3a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.99100000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>FLANGER_FBack</objectName>
  <x>1220</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{cc33e524-f2cd-47c5-bc1a-ed4cfd494461}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.99000000</maximum>
  <value>0.69300000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1067</x>
  <y>494</y>
  <width>50</width>
  <height>25</height>
  <uuid>{9864632d-401c-4993-aa75-014379b8b424}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate</label>
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
  <x>1118</x>
  <y>494</y>
  <width>50</width>
  <height>25</height>
  <uuid>{2ea576a4-ae2a-46c5-9d48-c60f6f2d797f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Depth</label>
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
  <x>1169</x>
  <y>494</y>
  <width>50</width>
  <height>25</height>
  <uuid>{de406206-a09b-4d39-a221-7c7395466fe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay</label>
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
  <x>1220</x>
  <y>494</y>
  <width>50</width>
  <height>50</height>
  <uuid>{d2b96b90-7cd4-46be-867a-7e4a60a747d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feed
Back</label>
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
  <x>1274</x>
  <y>383</y>
  <width>212</width>
  <height>330</height>
  <uuid>{5a2d7830-ac56-4764-8e11-6eca2b619270}</uuid>
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
   <r>170</r>
   <g>0</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1276</x>
  <y>534</y>
  <width>210</width>
  <height>44</height>
  <uuid>{d2a13c0d-246d-4f0c-83de-fb59869eeef0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>DELAY</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>1290</x>
  <y>585</y>
  <width>180</width>
  <height>110</height>
  <uuid>{6def73e6-5989-469d-a9e4-4a15fbbfe498}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 15</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>1372</x>
  <y>391</y>
  <width>15</width>
  <height>15</height>
  <uuid>{d773279c-f4d3-4a18-b284-e60c01b4c741}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>DELAYLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>DELAY_Mix</objectName>
  <x>1279</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{46ee6dd0-b835-419e-8f0d-619dd27d8970}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.79000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>DELAY_Time</objectName>
  <x>1330</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{7fca63e2-4e56-413d-b0d7-436f67012b56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.51000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>DELAY_FBack</objectName>
  <x>1381</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{519715f4-6ea1-48f2-8629-2f777a3fdccf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.47000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>DELAY_HFLoss</objectName>
  <x>1432</x>
  <y>445</y>
  <width>50</width>
  <height>50</height>
  <uuid>{180b9ae7-c93e-44ea-8464-9a75821d9c66}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>500.00000000</minimum>
  <maximum>20000.00000000</maximum>
  <value>4595.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1279</x>
  <y>494</y>
  <width>50</width>
  <height>25</height>
  <uuid>{ba96005c-1b16-4d22-98dd-13f7b99d784f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mix</label>
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
  <x>1330</x>
  <y>494</y>
  <width>50</width>
  <height>25</height>
  <uuid>{2ccb66b4-0dd2-45b3-b6de-405417af8e6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Time</label>
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
  <x>1381</x>
  <y>494</y>
  <width>50</width>
  <height>50</height>
  <uuid>{ee47d90f-5bdc-4ea7-8dbf-bd315741da47}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feed
Back</label>
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
  <x>1432</x>
  <y>494</y>
  <width>50</width>
  <height>50</height>
  <uuid>{0a8e694f-b45b-4407-8ed4-edfff14c761d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>HF
Loss</label>
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
  <x>1486</x>
  <y>383</y>
  <width>212</width>
  <height>330</height>
  <uuid>{19293415-d33a-4dfb-ab77-7bfb1ec77c51}</uuid>
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
   <r>85</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1488</x>
  <y>534</y>
  <width>210</width>
  <height>44</height>
  <uuid>{bdb948c2-6121-407a-95f4-e7acd6a1e6f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>REVERB</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>1502</x>
  <y>585</y>
  <width>180</width>
  <height>110</height>
  <uuid>{27d6b977-1f79-4b99-bca3-ebe8d4cfdb44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 16</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>1584</x>
  <y>391</y>
  <width>15</width>
  <height>15</height>
  <uuid>{12f09f14-b46c-4b7c-91d5-e5cf8f44532a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>REVERBLED</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>REVERB_Mix</objectName>
  <x>1499</x>
  <y>443</y>
  <width>60</width>
  <height>60</height>
  <uuid>{c6bd053b-dee1-4818-86e2-7c4e41f482ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.51000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1499</x>
  <y>505</y>
  <width>60</width>
  <height>25</height>
  <uuid>{16a90a4d-4e83-4580-8c19-4e1de4db5fb6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mix</label>
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
  <objectName>REVERB_Size</objectName>
  <x>1562</x>
  <y>443</y>
  <width>60</width>
  <height>60</height>
  <uuid>{e248bf6b-b7ba-43e4-93d6-cdc02fe1ed8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.62380000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1562</x>
  <y>505</y>
  <width>60</width>
  <height>25</height>
  <uuid>{15472c76-cfaf-4f26-8d62-87099c025051}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Size</label>
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
  <objectName>REVERB_Tone</objectName>
  <x>1625</x>
  <y>443</y>
  <width>60</width>
  <height>60</height>
  <uuid>{2726780e-444b-4f86-aa19-3d94642f984e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.81000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1625</x>
  <y>505</y>
  <width>60</width>
  <height>25</height>
  <uuid>{1b6fab95-d037-48e1-9c51-48c9805bd773}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tone</label>
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
  <x>1698</x>
  <y>383</y>
  <width>212</width>
  <height>330</height>
  <uuid>{81b2df2c-2add-4b77-9456-495da97b0d5e}</uuid>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1700</x>
  <y>533</y>
  <width>210</width>
  <height>44</height>
  <uuid>{f5871db4-fc64-4332-8281-e7d0588559d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>EQUALIZER</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>26</fontsize>
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
  <x>1714</x>
  <y>585</y>
  <width>180</width>
  <height>110</height>
  <uuid>{1e8a88ce-01b7-4831-9724-9170c56ab951}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 1 0 0.01 17</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>1796</x>
  <y>390</y>
  <width>15</width>
  <height>15</height>
  <uuid>{b02228da-ec7e-4e9b-8594-eb54eb225a71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>EQUALIZERLED</objectName2>
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
   <r>255</r>
   <g>0</g>
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
  <x>1715</x>
  <y>518</y>
  <width>35</width>
  <height>29</height>
  <uuid>{17b56f0f-40cd-4b8e-af2e-ebc902d36c7d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>100</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>1725</x>
  <y>422</y>
  <width>15</width>
  <height>93</height>
  <uuid>{62cef37c-a2cf-4766-8074-26bd448a5b66}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>EQUALIZER_100</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.53763441</yValue>
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
  <x>1745</x>
  <y>422</y>
  <width>15</width>
  <height>93</height>
  <uuid>{3254336d-003d-427a-94cc-a1e8a2ce7c32}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>EQUALIZER_200</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.54838710</yValue>
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
  <x>1765</x>
  <y>422</y>
  <width>15</width>
  <height>93</height>
  <uuid>{55677a12-dc02-41e8-a9d9-2b4644985a1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>EQUALIZER_400</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.54838710</yValue>
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
  <x>1785</x>
  <y>422</y>
  <width>15</width>
  <height>93</height>
  <uuid>{516859eb-6eea-4bcc-9071-2c60446708c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>EQUALIZER_800</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.55913978</yValue>
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
  <x>1805</x>
  <y>422</y>
  <width>15</width>
  <height>93</height>
  <uuid>{381d6039-e67c-421c-9a6b-328d7aa48881}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>EQUALIZER_1k6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.56989247</yValue>
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
  <x>1825</x>
  <y>422</y>
  <width>15</width>
  <height>93</height>
  <uuid>{26e42cfd-7502-4301-9897-f3ef80c9ec46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>EQUALIZER_3k2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.52688172</yValue>
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
  <x>1845</x>
  <y>422</y>
  <width>15</width>
  <height>93</height>
  <uuid>{c7614ef9-5985-4880-9cc9-dcf6ae4855be}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>EQUALIZER_6k4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50537634</yValue>
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
  <x>1865</x>
  <y>422</y>
  <width>15</width>
  <height>93</height>
  <uuid>{4f2053ad-bfcd-48be-b5d4-815c1d99b13a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>EQUALIZER_Gain</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.40860215</yValue>
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
  <x>1735</x>
  <y>518</y>
  <width>35</width>
  <height>29</height>
  <uuid>{7fc3d75a-dc64-45a0-b590-7d27a72a40bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>200</label>
  <alignment>center</alignment>
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
  <x>1755</x>
  <y>518</y>
  <width>35</width>
  <height>29</height>
  <uuid>{a6d56902-e492-4d59-aecd-512ae46dee6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>400</label>
  <alignment>center</alignment>
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
  <x>1775</x>
  <y>518</y>
  <width>35</width>
  <height>29</height>
  <uuid>{9dd59e64-0e62-49fc-af66-b7832ee0d8a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>800</label>
  <alignment>center</alignment>
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
  <x>1795</x>
  <y>518</y>
  <width>35</width>
  <height>29</height>
  <uuid>{4a5c0c04-889a-4178-8b24-0e9e9df30ae0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1k6</label>
  <alignment>center</alignment>
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
  <x>1815</x>
  <y>518</y>
  <width>35</width>
  <height>29</height>
  <uuid>{9df74520-8ac6-45ff-91e0-ec2f0b138f57}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3k2</label>
  <alignment>center</alignment>
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
  <x>1835</x>
  <y>518</y>
  <width>35</width>
  <height>29</height>
  <uuid>{963ce3bb-492d-4580-9477-f13b10ba7e62}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6k4</label>
  <alignment>center</alignment>
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
  <x>1855</x>
  <y>518</y>
  <width>35</width>
  <height>29</height>
  <uuid>{3ca96c95-f4d9-4a28-a3ac-b090055dd207}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
  <alignment>center</alignment>
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
  <x>2</x>
  <y>2</y>
  <width>212</width>
  <height>51</height>
  <uuid>{17911871-b248-45e6-945d-fa5d3ebf7cfe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Multi-FX</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>30</fontsize>
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
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>214</x>
  <y>2</y>
  <width>425</width>
  <height>51</height>
  <uuid>{d5d8b2b5-de9f-471e-9c61-8f1425361874}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>30</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>117</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>20</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>229</x>
  <y>14</y>
  <width>140</width>
  <height>28</height>
  <uuid>{f4982782-fdcc-49e1-ab2b-e5553938b259}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>ClassicalGuitar.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>372</x>
  <y>15</y>
  <width>250</width>
  <height>26</height>
  <uuid>{6e220fa1-c4e9-4356-b16a-ecd72fa593a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ClassicalGuitar.wav</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

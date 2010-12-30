;Written by Iain McCurdy, 2009


; Modified for QuteCsound by René, December 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733
; An INIT preset is called at the start of csound (inst 100), a valid mono or stereo audio file have to be selected and preset 0 saved before playing.

;Notes on modifications from original csd:
;	Add Browser for audio files and power of two tables for ftgentmp opcode
;	Add table(s) for exp slider
;	Instrument 1 is activated by MIDI and by the GUI
;	Removed Recording instrument, included in QuteCsound
;	Removed "Instructions and Info Panel" for the gui to fit in a 1200x800 screen

;	                   Schedkwhen Granulation
;	-------------------------------------------------------------------------------------------------------------------------
;	This example implements granular synthesis by using schedkwhen to create note events from within the orchestra in
;	realtime. None of Csound's built-in opcodes for granular synthesis are used.
;	The advantage of this approach is that the method of grain generation is not defined by the opcode and that further
;	processing can be applied to individual grains rather than just to the accumulated output of grains. The downside is
;	that there is likely to be greater CPU strain for dense granulations.
;	In this implemenation grain-by-grain procedures are represented through ring modulation and band-pass filtering.
;	Processes upon the accumlated output of the granular synthesizer are represented by global filtering (low-pass and
;	high-pass) and by reverb. Grain-by-grain processes are carried out in the instrument that actually renders the audio
;	for grains whereas global procedures are carried out in a separate, always on, instrument.
;	The pointer which defines the location within the sound file from which grains are read is defined by the GUI slider
;	'Pointer'. The pointer can also be modulated by an LFO. To deactivate the LFO reduce its amplitude to zero.
;	Certain paramaters of the ring modulator and the band-pass filter can be randomized from grain to grain. The range from
;	which random values are chosen are represented by two mini sliders stacked one upon the other.
;	The pitch of grains can me modulated in a variety of ways. 'Pitch (oct)' modulates the pitch of all grains by the same
;	constant number of octaves. 'Random Octave' defines a range from which random modulations on a grain-by-grain basis are
;	applied. 'Pitch Offset Range (Octaves)' define the range from which transpositions by octave intervals are applied.
;	The attack and the decay portions of each grain envelope are defined as well as a continuous morph between straight and
;	exponential envelope segements.
;	This example can also be triggered via a MIDI ketboard. MIDI note values will modulate any transposition set in the GUI
;	interface about a unison point corresponding to middle C.


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 8		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH



gisin		ftgen	0, 0, 512, 10, 1	;SINE WAVE

;TABLE FOR EXP SLIDER
giExp1		ftgen	0, 0, 129, -25, 0,  0.00001, 128,     1.0
giExp003_1	ftgen	0, 0, 129, -25, 0,  0.003,   128,     1.0
giExp10		ftgen	0, 0, 129, -25, 0,  0.001,   128,    10.0
giExp30		ftgen	0, 0, 129, -25, 0,  0.001,   128,    30.0
giExp1000		ftgen	0, 0, 129, -25, 0,  0.5,     128,  1000.0
giExp20000	ftgen	0, 0, 129, -25, 0,  20.0,    128, 20000.0

gasendL		init		0										;INITIALIZE GLOBAL AUDIO VARIABLES USED TO SEND AUDIO FROM GRAIN RENDERING INSTRUMENT
gasendR		init		0    									;INITIALIZE GLOBAL AUDIO VARIABLES USED TO SEND AUDIO FROM GRAIN RENDERING INSTRUMENT


;;;USER DEFINED OPCODES (UDOS);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;A USER DEFINED OPCODE IS CREATED FOR REVERB SO THAT ksmps CAN BE SET TO 1
opcode	reverbsr, aa, aakk
	setksmps	1
	ainsigL, ainsigR, kfblvl, kfco	xin
	arvbL, arvbR 	reverbsc 	ainsigL, ainsigR, kfblvl, kfco
				xout		arvbL, arvbR
endop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
;On / Off Buttons
		gkRvbOnOff	invalue	"RVBOnOff"
		gkRMOnOff		invalue	"RMOnOff"
		gkBPFOnOff	invalue	"BPFOnOff"
		gkFiltOnOff	invalue	"FiltOnOff"
;Sliders
;Main
		gkgain		invalue	"Output_Amp"
		gkampdepth	invalue	"Amp_Rnd_Offset"
		gkwidth		invalue	"Rnd_Pan_Amount"
;Grain Pointer
		gkptr		invalue	"Pointer"
		gkptr_OS		invalue	"Grain_Pointer_Offset"
		gkLFOamp		invalue	"Pointer_LFO_Amp"
		kLFOfrq		invalue	"Pointer_LFO_Freq"
		gkLFOfrq		tablei	kLFOfrq, giExp1, 1
					outvalue	"Pointer_LFO_Freq_Value", gkLFOfrq	
;Grain Density and Grain Size
		kGPS			invalue	"Grains_per_Second"
		gkGPS		tablei	kGPS, giExp1000, 1
					outvalue	"Grains_per_Second_Value", gkGPS	
		gkgap_OS		invalue	"Grain_Gap_Jitter"
		kdurMin		invalue	"Grain_Dur_Min"
		gkdurMin		tablei	kdurMin, giExp003_1, 1
					outvalue	"Grain_Dur_Min_Value", gkdurMin	
		kdurMax		invalue	"Grain_Dur_Max"
		gkdurMax		tablei	kdurMax, giExp003_1, 1
					outvalue	"Grain_Dur_Max_Value", gkdurMax	
;Grain Envelope
		gkatt		invalue	"Attack"
		gkdec		invalue	"Decay"
		gkEnvType		invalue	"Envelope"
;Grain Pitch
		gkoct		invalue	"Pitch"
		gkrndoctavemin	invalue	"Rnd_Octave_Min"
		gkrndoctavemax	invalue	"Rnd_Octave_Max"
		gkpchosrange	invalue	"Pitch_Offset_Range"
;Grain-by-Grain Ring Modulation
		gkRMmix		invalue	"RM_Mix"
		gkRMfreqmin	invalue	"RM_Freq_Min"
		gkRMfreqmax	invalue	"RM_Freq_Max"
;Grain-by-Grain Bandpass Filtering
		gkBPFmix		invalue	"BPF_Mix"
		gkBPFcutmin	invalue	"BPF_Cutoff_Min"
		gkBPFcutmax	invalue	"BPF_Cutoff_Max"
		kBPFbwmin		invalue	"BPF_Bandwidth_Min"
		gkBPFbwmin	tablei	kBPFbwmin, giExp10, 1
					outvalue	"BPF_Bandwidth_Min_Value", gkBPFbwmin		
		kBPFbwmax		invalue	"BPF_Bandwidth_Max"
		gkBPFbwmax	tablei	kBPFbwmax, giExp30, 1
					outvalue	"BPF_Bandwidth_Max_Value", gkBPFbwmax	
		gkBPFgain		invalue	"BPF_Gain"
;Global Filtering
		kHPFcf		invalue	"HPF_Cutoff"
		gkHPFcf		tablei	kHPFcf, giExp20000, 1
					outvalue	"HPF_Cutoff_Value", gkHPFcf			
		kLPFcf		invalue	"LPF_Cutoff"
		gkLPFcf		tablei	kLPFcf, giExp20000, 1
					outvalue	"LPF_Cutoff_Value", gkLPFcf			
;Reverb
		gkRvbDryWet	invalue	"RVB_Mix"
		gkfblvl		invalue	"RVB_Size"
		gkfco		invalue	"RVB_Cutoff"

;AUDIO FILE CHANGE / LOAD IN POWER OF 2 TABLES **********************************************************************************************
;Have put all this stuff in instr 10 to reduce the respons time when playing with midi

		Sfile_new		strcpy	""													;INIT TO EMPTY STRING

		Sfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	Sfile
		kfile 		strcmpk	Sfile_new, Sfile_old

		gkfile_new	init		0
		if	kfile != 0	then														;IF A BANG HAD BEEN GENERATED IN THE LINE ABOVE
			gkfile_new	=	1													;Flag to inform instr 1 that a new file is loaded
				reinit	NEW_FILE													;REINITIALIZE FROM LABEL 'NEW_FILE'
		endif
		NEW_FILE:
		;opcode accept only power of 2 table size
		ifnTemp		ftgentmp	0, 0, 0, 1, Sfile, 0, 0, 1								;Temporary table to get the audio file size
		iftlen		= ftlen(ifnTemp)												;file size
		iftlen2		pow	2, ceil(log(iftlen)/log(2))									;high nearest power of two table size

		;FUNCTION TABLE NUMBER OF THE SOUND FILE THAT WILL BE GRANULATED
		giFile		ftgentmp	0, 0, iftlen2, 1, Sfile, 0, 0, 1							;READ MONO or STEREO AUDIO FILE CHANNEL 1
;*******************************************************************************************************************************************
	endif
endin

instr	1	;GRAIN TRIGGERING INSTRUMENT
	if p4!=0 then																	;MIDI
		iPitchRatio	=	cpsoct(p4)/cpsoct(8)										;MAP TO MIDI OCT VALUE TO PITCH (CONVERT TO RATIO: MIDDLE C IS POINT OF UNISON)
	else																			;OTHERWISE...
		iPitchRatio	=	1														;PITCH RATIO IS JUST 1
	endif																		;END OF THIS CONDITIONAL BRANCH

	iporttime		=			0.05													;PORTAMENTO TIME
	gkporttime	linseg		0,.01,iporttime,1,iporttime								;gkporttime WILL RAMP UP AND HOLD THE VALUE iporttime
	kGPS			portk		gkGPS, gkporttime										;APPLY PORTAMENTO TO GRAINS-PER-SECOND VARIABLE
	ktrigger		metro		gkGPS												;CREATE A METRICAL TRIGGER (MOMENTARY 1s) USING GRAINS-PER-SECOND AS A FREQUENCY CONTROL
	kptr			portk		gkptr, gkporttime										;APPLY PORTAMENTO TO POINTER VARIABLE
	kLFO			lfo			(gkLFOamp * 0.5), gkLFOfrq, 1								;TRIANGLE WAVEFORM LFO TO CREATE AN LFO POINTER
	kptr			=			kptr + (kLFO + 0.5)										;ADD POINTER VARIABLE TO POINTER LFO
	kptr			wrap			kptr, 0, 1											;WRAP OUT OF RANGE VALUE FOR POINTER BETWEEN ZERO AND 1
	giSampleLen 	= 			(nsamp(giFile))/sr										;DERIVE SAMPLE LENGTH IN SECONDS
	kptr			=			kptr * giSampleLen										;RESCALE POINTER ACCORDING TO SAMPLE LENGTH
	;			OPCODE	 	KTRIGGER, KMINTIME, KMAXNUM, KINSNUM, KWHEN, KDUR,  P4     P5
				schedkwhen	ktrigger,    0,        0,       2,      0,     0,  kptr, iPitchRatio		;TRIGGER INSTR 2 ACCORDING TO TRIGGER. SEND POINTER VALUE VIA P-FIELD 4, SEND MIDI PITCH RATIO VIA P5
endin
	
instr	2	;SCHEDKWHEN TRIGGERED INSTRUMENT. ON FOR JUST AN INSTANCE. THIS INSTRUMENT DEFINES GRAIN DURATION, ADDS GRAIN GAP OFFSET, AND TRIGGERS THE GRAIN SOUNDING INSTRUMENT
	idur			random		i(gkdurMin), i(gkdurMax)									;DERIVE A GRAIN DURATION ACCORDING TO DURATION RANGE SETTINGS 
	igap_OS		random		0, i(gkgap_OS)											;DERIVE A GRAIN GAP OFFSET ACCORDING TO GUI VARIABLE "Grain Gap Offset"
				event_i		"i", 3, igap_OS, idur, p4, p5								;TRIGGER INSTRUMENT 3 (GRAIN SOUNDING INSTRUMENT). PASS POINTER VALUE VIA P-FIELD 4. GRAIN GAP OFFSET IS IMPLEMENTED USING P2/'WHEN' PARAMETER FIELD. SEND MIDI PITCH RATIO VIA P5
endin
		
instr		3	;GRAIN SOUNDING INSTRUMENT
	iwidth 		=			i(gkwidth)											;DERIVE AN I-RATE VERSION OF gkwidth
	iampdepth 	=			i(gkampdepth)											;DERIVE AN I-RATE VERSION OF gkampdepth
	iptr_OS		=			i(gkptr_OS)											;DERIVE AN I-RATE VERSION OF gkptr_OS (POINTER OFFSET)
	ioct_OS		random		-i(gkpchosrange), i(gkpchosrange)							;DERIVE CONTINUOUS TRANSPOSITION CONSTANT
	irndoctave	random		i(gkrndoctavemin), i(gkrndoctavemax)						;DERIVE OCTAVE INTERVAL TRANSPOSITION CONSTANT
	ipchrto		=			cpsoct(8+int(irndoctave)+i(gkoct)+ioct_OS)/cpsoct(8)			;CREATE A PITCH RATIO (TO UNISON) CONSTANT COMBINING ALL TRANSPOSITION CONSTANTS
	ipchrto		=			ipchrto * p5											;SCALE PITCH RATIO WITH P5 WHICH, TRACED BACK THROUGH INSTR 2 TO INSTR 1, IS MIDI PITCH RATIO
	iskip		=			p4 + rnd(iptr_OS)										;DEFINE 'IN-SKIP' INTO THE SOUND FILE (IN SECONDS) FROM POINTER VALUE PASSED FROM CALLER INSTRUMENT AND RANDOM POINTER OFFSET	
	iatt			=			i(gkatt)												;DERIVE AN I-RATE VERSION OF gkatt (ATTACK TIME)
	idec			=			i(gkdec)												;DERIVE AN I-RATE VERSION OF gkdec (DECAY TIME)

	if	iatt+idec>1	then															;IF ATTACK TIME AND DECAY TIME ARE GREATER THAN 1 THEN THE VALUES SHOULD BE RESCALED SO THAT THE SUM IS EQUAL TO 1
		iatt		=	iatt/(iatt+idec)												;RESCALE iatt
		idec		=	idec/(iatt+idec)												;RESCALE idec
	endif																		;END OF CONDITIONAL BRANCHING

	aenvL		linseg		0, (iatt * p3), 1, ((1-iatt-idec) * p3), 1, (idec * p3), 0				;DEFINE GRAIN AMPLITUDE ENVELOPE (STRAIGHT SEGMENTS)
	aenvE		expsega		.0001, (iatt * p3),	1, ((1-iatt-idec) * p3), 1, (idec * p3), .0001		;DEFINE GRAIN AMPLITUDE ENVELOPE (EXPONENTIAL SEGMENTS)	
	aenv			ntrpol		aenvL, aenvE, gkEnvType											;CREATE A RESULTANT ENVELOPE THAT IS A CONTINUOUS MORPH BETWEEN THE STRAIGHT AND EXPONENTIAL VERSIONS ABOVE
	iamp 		= 			(1 - rnd(iampdepth))*i(gkgain)									;DERIVE AMPLITUDE FROM 'Gain' SLIDER AND FROM 'Random Amplitude Depth' SLIDER
	ipan			random		-iwidth, iwidth												;DERIVE A PANNING POSITION FOR THIS GRAIN FROM 'Random Panning Amount' SLIDER
	ipan 		= 			ipan + .5														;OFFSET ipan by +0.5
	aptr			line			iskip, p3 / ipchrto, iskip+p3										;DEFINE A MOVING POINTER FUNCTION TO READ GRAIN FROM FUNCTION TABLE CONTAINING SOURCE AUDIO
	asig  		tablei		aptr * sr, giFile												;READ AUDIO FROM SOURCE SOUND FUNCTION TABLE. I.E. CREATE GRAIN
	;GRAIN-BY-GRAIN RING MODULATION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if	gkRMOnOff=1	then															;IF BAND-PASS FILTERING ON/OFF SWITCH IS ON...
		iRMfreq	random		i(gkRMfreqmin), i(gkRMfreqmax)							;DEFINE RANDOM RING MODULATION FREQUENCY
		anoRM	=			1													;A-RATE CONSTANT VALUE OF '1'
		amod		oscil		1, iRMfreq, gisin										;CREATE RING MODULATING OSCILATOR
		amod		ntrpol		anoRM, amod, gkRMmix									;CREATE A MIX BETWEEN RING MODULATING OSCILATOR AND CONSTANT VALUE '1'
		asig		=			asig * amod											;RING MODULATE AUDIO SIGNAL
	endif																		;END OF CONDITIONAL BRANCHING
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;GRAIN-BY-GRAIN BAND-PASS FILTERING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if	gkBPFOnOff=1	then															;IF BAND-PASS FILTERING ON/OFF SWITCH IS ON...
		iBPFcut	random		i(gkBPFcutmin), i(gkBPFcutmax)							;DEFINE RANDOM FILTER CUTOFF VALUE (IN OCT FORMAT)
		iBPFfrq	=			cpsoct(iBPFcut)										;CONVERT TO CPS FORMAT
		iBPFbw	random		i(gkBPFbwmin), i(gkBPFbwmax)								;DEFINE RANDOM BANDWIDTH VALUE
		aBPF 	reson 		asig, iBPFfrq, iBPFbw*iBPFfrq, 1							;FILTER AUDIO USING reson OPCODE
		asig		ntrpol		asig, aBPF*i(gkBPFgain), gkBPFmix							;CREATE MIX BETWEEN THE FILTERED SOUND AND THE DRY SOUND
	endif																		;END OF CONDITIONAL BRANCHING
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	asig 		= 	asig * aenv * iamp												;APPLY AMPLITUDE CONSTANT AND GRAIN ENVELOPE
	gasendL		=	gasendL + (asig * ipan)											;APPLY PANNING VARIABLE AND CREATE LEFT CHANNEL ACCUMULATED OUTPUT 
	gasendR		=	gasendR + (asig * (1 - ipan))										;APPLY PANNING VARIABLE AND CREATE RIGHT CHANNEL ACCUMULATED OUTPUT
endin
		
instr	4	;GLOBAL PROCESSING OF GRANULAR OUTPUT & REVERB INSTRUMENT
	asigL	=	gasendL															;READ ACCUMULATED AUDIO SENT BY GRAIN RENDERING INSTRUMENT AND CREATE A LOCAL AUDIO VARIABLE OUTPUT (THIS IS TO ALLOW REDEFINITION OF THE VARIABLE WITHIN THE SAME LINE OF CODE - NOT POSSIBLE WITH GLOBAL VARIABLES)
	asigR	=	gasendR															;READ ACCUMULATED AUDIO SENT BY GRAIN RENDERING INSTRUMENT AND CREATE A LOCAL AUDIO VARIABLE OUTPUT (THIS IS TO ALLOW REDEFINITION OF THE VARIABLE WITHIN THE SAME LINE OF CODE - NOT POSSIBLE WITH GLOBAL VARIABLES)
	if	gkFiltOnOff=1	then															;IF GLOBAL FILTERING ON/OFF SWITCH IS ON...
		kHPFcf	portk	gkHPFcf, gkporttime											;APPLY PORTAMENTO TO HIGH-PASS FILTER CUTOFF VARIABLE
		kLPFcf	portk	gkLPFcf, gkporttime  										;APPLY PORTAMENTO TO LOW-PASS FILTER CUTOFF VARIABLE
		asigL	buthp	asigL, kHPFcf												;APPLY HIGH-PASS FILTER TO LEFT CHANNEL AUDIO...
		asigL	buthp	asigL, kHPFcf												;...AND AGAIN TO SHARPEN CUTOFF SLOPE
		asigR	buthp	asigR, kHPFcf												;APPLY HIGH-PASS FILTER TO LEFT CHANNEL AUDIO...
		asigR	buthp	asigR, kHPFcf												;...AND AGAIN TO SHARPEN CUTOFF SLOPE           	
		asigL	butlp	asigL, kLPFcf												;APPLY LOW-PASS FILTER TO LEFT CHANNEL AUDIO...
		asigL	butlp	asigL, kLPFcf												;...AND AGAIN TO SHARPEN CUTOFF SLOPE           
		asigR	butlp	asigR, kLPFcf												;APPLY LOW-PASS FILTER TO RIGHT CHANNEL AUDIO...
		asigR	butlp	asigR, kLPFcf												;...AND AGAIN TO SHARPEN CUTOFF SLOPE           
	endif																		;END OF CONDITIONAL BRANCHING
	aSigL	=		asigL * (1 - gkRvbDryWet)										;SCALE AUDIO SIGNAL WITH GUI AMPLITUDE SLIDER AND GRAIN CLOUD ENVELOPE
	aSigR	=		asigR * (1 - gkRvbDryWet)										;SCALE AUDIO SIGNAL WITH GUI AMPLITUDE SLIDER AND GRAIN CLOUD ENVELOPE
			outs	 	aSigL, aSigR													;SEND AUDIO TO OUTPUTS

	if	gkRvbOnOff=1 then															;IF REVERB ON/OFF SWITCH IS ON...
			denorm	asigL, asigR													;...DENORMALIZE BOTH CHANNELS OF AUDIO SIGNAL
	arvbL, arvbR 	reverbsr 	asigL  * gkRvbDryWet, asigR  * gkRvbDryWet, gkfblvl, gkfco			;CREATE REVERBERATED SIGNAL (USING UDO DEFINED ABOVE)
			outs		arvbL, arvbR													;SEND REVERBERATED SIGNAL TO AUDIO OUTPUTS
	endif																		;END OF CONDITIONAL BRANCHING
			clear	gasendL, gasendR												;ZERO GLOBAL AUDIO VARIABLES USED TO SEND ACCUMULATED GRAINS
endin

instr	100	;INIT
		outvalue	"_SetPresetIndex", 0
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI

i 4		0		3600		;GLOBAL PROCESSING OF GRANULAR OUTPUT & REVERB
i 100     0.1		 0		;INIT
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>621</x>
 <y>388</y>
 <width>1031</width>
 <height>657</height>
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
  <width>1026</width>
  <height>652</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Schedkwhen Granulation</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <x>6</x>
  <y>8</y>
  <width>120</width>
  <height>30</height>
  <uuid>{55273d97-d39a-441c-8da6-87ea139493b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>46</y>
  <width>504</width>
  <height>124</height>
  <uuid>{0c76df6b-29e1-49c2-88f5-279e711ccadd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Main</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>60</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>82</y>
  <width>180</width>
  <height>30</height>
  <uuid>{5fb7ba54-1df4-48f7-a498-a30bba8e7da0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Amplitude</label>
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
  <objectName>Output_Amp</objectName>
  <x>8</x>
  <y>64</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8f899f73-cfdb-4cba-881e-458ca38d2473}</uuid>
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
  <objectName>Output_Amp</objectName>
  <x>448</x>
  <y>82</y>
  <width>60</width>
  <height>25</height>
  <uuid>{95133863-04df-4ec2-b7ea-3fec18dc36fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.300</label>
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
  <y>115</y>
  <width>180</width>
  <height>30</height>
  <uuid>{ef2c3359-881d-4872-b3e6-5033c784f91b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude Random Offset</label>
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
  <objectName>Amp_Rnd_Offset</objectName>
  <x>8</x>
  <y>97</y>
  <width>500</width>
  <height>27</height>
  <uuid>{189f2c49-2073-4f2d-83ed-77a51c86bcc2}</uuid>
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
  <objectName>Amp_Rnd_Offset</objectName>
  <x>448</x>
  <y>115</y>
  <width>60</width>
  <height>25</height>
  <uuid>{8829cce9-907e-440d-ace8-774244e2ca84}</uuid>
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
  <y>148</y>
  <width>180</width>
  <height>30</height>
  <uuid>{30acb4ae-9a9b-448a-b2be-16462d9f7a10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Random Panning Amount</label>
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
  <objectName>Rnd_Pan_Amount</objectName>
  <x>8</x>
  <y>130</y>
  <width>500</width>
  <height>27</height>
  <uuid>{00eb88cd-00e6-49e6-9b4e-1da883c22cb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.25000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Rnd_Pan_Amount</objectName>
  <x>448</x>
  <y>148</y>
  <width>60</width>
  <height>25</height>
  <uuid>{e3ccec3a-893c-498c-ab7f-679cb44d0dca}</uuid>
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
  <x>6</x>
  <y>171</y>
  <width>504</width>
  <height>162</height>
  <uuid>{c01a87ab-f93b-4495-a830-c492ec4973e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Pointer</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>80</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>212</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7880f995-1640-4885-964b-05b718b0c011}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer</label>
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
  <objectName>Pointer</objectName>
  <x>8</x>
  <y>194</y>
  <width>500</width>
  <height>27</height>
  <uuid>{6c0fea2c-9d68-4e97-bab0-0ff1e5904298}</uuid>
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
  <objectName>Pointer</objectName>
  <x>448</x>
  <y>212</y>
  <width>60</width>
  <height>25</height>
  <uuid>{7569fb66-578f-4c26-9a4a-7b64c1ec40ca}</uuid>
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
  <x>8</x>
  <y>245</y>
  <width>180</width>
  <height>30</height>
  <uuid>{6b54ccf8-0552-4265-bbf2-3271d9c31e9a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Pointer Offset</label>
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
  <objectName>Grain_Pointer_Offset</objectName>
  <x>8</x>
  <y>227</y>
  <width>500</width>
  <height>27</height>
  <uuid>{a0c90857-7310-4ec2-a193-24b3181a0a16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.00200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Grain_Pointer_Offset</objectName>
  <x>448</x>
  <y>245</y>
  <width>60</width>
  <height>25</height>
  <uuid>{648254b7-58e3-4a88-9110-01822df76b68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.002</label>
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
  <y>278</y>
  <width>180</width>
  <height>30</height>
  <uuid>{015f4f0f-86ab-4afb-914d-9cf1855e8857}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer LFO Amplitude</label>
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
  <objectName>Pointer_LFO_Amp</objectName>
  <x>8</x>
  <y>260</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3e019e12-b403-417b-a62f-cd514b4fbe45}</uuid>
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
  <objectName>Pointer_LFO_Amp</objectName>
  <x>448</x>
  <y>278</y>
  <width>60</width>
  <height>25</height>
  <uuid>{5d6de635-b049-4b33-9497-5dae6ed04731}</uuid>
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
  <y>312</y>
  <width>180</width>
  <height>30</height>
  <uuid>{9e5bc9af-3a99-41a9-a068-1acf9bec89b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer LFO Frequency</label>
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
  <objectName>Pointer_LFO_Freq</objectName>
  <x>8</x>
  <y>294</y>
  <width>500</width>
  <height>27</height>
  <uuid>{bba5f073-15d1-4a0d-908c-d3b73e9ec405}</uuid>
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
  <objectName>Pointer_LFO_Freq_Value</objectName>
  <x>448</x>
  <y>312</y>
  <width>60</width>
  <height>25</height>
  <uuid>{6c09f836-048e-45bb-a9e5-7ba884ef4277}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.003</label>
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
  <y>334</y>
  <width>504</width>
  <height>162</height>
  <uuid>{e2688c6f-d12c-41f9-af57-a99c5ae27a77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Density and Grain Size</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>100</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>375</y>
  <width>180</width>
  <height>30</height>
  <uuid>{cd854e51-3dc8-480b-a7c2-54cc6e749d90}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grains per Second</label>
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
  <objectName>Grains_per_Second</objectName>
  <x>8</x>
  <y>357</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5846dcd2-0841-4d6c-9708-3a2b2cb7f668}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.63000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Grains_per_Second_Value</objectName>
  <x>448</x>
  <y>375</y>
  <width>60</width>
  <height>25</height>
  <uuid>{a966e0a7-fa32-4333-8319-3869c2a3edc2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>60.089</label>
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
  <y>408</y>
  <width>180</width>
  <height>30</height>
  <uuid>{63c1fc45-d8f8-46d5-b1cd-10f21c43b4fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Gap Jitter</label>
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
  <objectName>Grain_Gap_Jitter</objectName>
  <x>8</x>
  <y>390</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2617dbe0-61b1-41af-a512-a96de791a710}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.83200002</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Grain_Gap_Jitter</objectName>
  <x>448</x>
  <y>408</y>
  <width>60</width>
  <height>25</height>
  <uuid>{8b4b116e-5d3a-48e9-a5c3-b8bf919c2f95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.832</label>
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
  <y>442</y>
  <width>180</width>
  <height>25</height>
  <uuid>{aa2150a3-9030-4df7-b6c7-1a08466b7f3c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Duration Min</label>
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
  <objectName>Grain_Dur_Min</objectName>
  <x>8</x>
  <y>424</y>
  <width>500</width>
  <height>27</height>
  <uuid>{95733af6-c2ef-4e08-9b03-9d22f3f1e454}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.91200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Grain_Dur_Min_Value</objectName>
  <x>448</x>
  <y>442</y>
  <width>60</width>
  <height>25</height>
  <uuid>{dc0c739a-ad94-4286-9c5e-10a74640b948}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.600</label>
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
  <y>475</y>
  <width>180</width>
  <height>30</height>
  <uuid>{08bb9785-1bfd-40b6-bbb6-48e9ab59509e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Duration Max</label>
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
  <objectName>Grain_Dur_Max</objectName>
  <x>8</x>
  <y>457</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2232516c-cdc7-49e6-80ee-1cf950410978}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.91200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Grain_Dur_Max_Value</objectName>
  <x>448</x>
  <y>475</y>
  <width>60</width>
  <height>25</height>
  <uuid>{2b8541c3-8e4f-4b73-adf2-462220fa1d94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.600</label>
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
  <y>497</y>
  <width>504</width>
  <height>70</height>
  <uuid>{a34c12c0-18b1-4e92-8aa2-936ccb86c3cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Reverb On</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>120</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>RVBOnOff</objectName>
  <x>82</x>
  <y>504</y>
  <width>16</width>
  <height>16</height>
  <uuid>{8e2d43f0-da03-48e0-a993-1edb26cdc5c7}</uuid>
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
  <x>519</x>
  <y>46</y>
  <width>504</width>
  <height>124</height>
  <uuid>{af3f124b-c09d-4143-82ff-ff28e799283b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Envelope</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>140</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>82</y>
  <width>180</width>
  <height>30</height>
  <uuid>{289e3dc2-01ef-458b-ace5-7f2c2d057fb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack</label>
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
  <objectName>Attack</objectName>
  <x>521</x>
  <y>64</y>
  <width>500</width>
  <height>27</height>
  <uuid>{36da2080-5c2b-4a77-9eba-0f5f52f208b5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>0.99900000</maximum>
  <value>0.39965999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Attack</objectName>
  <x>961</x>
  <y>82</y>
  <width>60</width>
  <height>25</height>
  <uuid>{a6c7e49b-194b-4778-bcd4-6176e3e02ca9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.400</label>
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
  <x>521</x>
  <y>115</y>
  <width>180</width>
  <height>30</height>
  <uuid>{412fade6-7b0d-4fd7-ada9-7b642c603c29}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay</label>
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
  <objectName>Decay</objectName>
  <x>521</x>
  <y>97</y>
  <width>500</width>
  <height>27</height>
  <uuid>{4adc99f8-c2ee-42ea-958c-f5563cf373e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00010000</minimum>
  <maximum>0.99900000</maximum>
  <value>0.49955001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Decay</objectName>
  <x>961</x>
  <y>115</y>
  <width>60</width>
  <height>25</height>
  <uuid>{84bcd025-362c-4be2-99ef-cab7de104b2a}</uuid>
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
  <x>521</x>
  <y>148</y>
  <width>180</width>
  <height>30</height>
  <uuid>{ab717982-19c3-4239-9d2f-ba2ca04bf4df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Envelope Lin:Exp</label>
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
  <objectName>Envelope</objectName>
  <x>521</x>
  <y>130</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f7feb0e5-b26f-4925-88ae-8417cf1dcd0a}</uuid>
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
  <objectName>Envelope</objectName>
  <x>961</x>
  <y>148</y>
  <width>60</width>
  <height>25</height>
  <uuid>{1efba2e1-40af-4009-bed2-1e96780d0e4b}</uuid>
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
  <x>519</x>
  <y>171</y>
  <width>504</width>
  <height>128</height>
  <uuid>{51626dcd-10bf-4210-a300-308268a41add}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Pitch</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>120</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>212</y>
  <width>180</width>
  <height>30</height>
  <uuid>{3c0039bd-5e9c-46b1-9e9f-a2f12b603199}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch (oct)</label>
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
  <objectName>Pitch</objectName>
  <x>521</x>
  <y>194</y>
  <width>250</width>
  <height>27</height>
  <uuid>{07952487-6e03-413f-930a-343610cacb73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-3.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch</objectName>
  <x>711</x>
  <y>212</y>
  <width>60</width>
  <height>30</height>
  <uuid>{58f459be-8a71-40d7-a6b3-d4dd225f0e7d}</uuid>
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
  <x>521</x>
  <y>278</y>
  <width>180</width>
  <height>30</height>
  <uuid>{acdfb7cf-9376-4966-8e28-20a279e7850f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch Offset Range (Octaves)</label>
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
  <objectName>Pitch_Offset_Range</objectName>
  <x>521</x>
  <y>260</y>
  <width>500</width>
  <height>27</height>
  <uuid>{376a6829-cc9a-4c98-a8b6-cb3b7423164b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch_Offset_Range</objectName>
  <x>961</x>
  <y>278</y>
  <width>60</width>
  <height>25</height>
  <uuid>{50b1352f-ae74-4cdb-becf-4777aaab3063}</uuid>
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
  <x>771</x>
  <y>212</y>
  <width>180</width>
  <height>30</height>
  <uuid>{817c4ab6-72c0-4d79-b7db-79066afb46ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Random Octave Min</label>
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
  <objectName>Rnd_Octave_Min</objectName>
  <x>771</x>
  <y>194</y>
  <width>250</width>
  <height>27</height>
  <uuid>{4e86c254-5afc-4db7-b63c-1ad7bf998596}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-3.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>-2.03999996</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Rnd_Octave_Min</objectName>
  <x>961</x>
  <y>212</y>
  <width>60</width>
  <height>25</height>
  <uuid>{b8bec75d-b063-48f5-a25b-0413770d54ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-2.040</label>
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
  <x>771</x>
  <y>245</y>
  <width>180</width>
  <height>30</height>
  <uuid>{53aefbc4-b66a-49bb-914e-f29f0483c5a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Random Octave Max</label>
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
  <objectName>Rnd_Octave_Max</objectName>
  <x>771</x>
  <y>227</y>
  <width>250</width>
  <height>27</height>
  <uuid>{f212768c-e843-41ca-9eef-abf032850ea6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-3.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Rnd_Octave_Max</objectName>
  <x>961</x>
  <y>245</y>
  <width>60</width>
  <height>25</height>
  <uuid>{88da0d94-99bd-4a19-acd4-daab786d139f}</uuid>
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
  <x>519</x>
  <y>300</y>
  <width>504</width>
  <height>124</height>
  <uuid>{04d2e0f0-0ad4-49ff-9e6c-692761bd3227}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain-by-Grain Ring Modulation    On</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>100</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>336</y>
  <width>180</width>
  <height>30</height>
  <uuid>{cecd1a75-7f45-44ad-9a15-15753bfab572}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mix</label>
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
  <objectName>RM_Mix</objectName>
  <x>521</x>
  <y>318</y>
  <width>500</width>
  <height>27</height>
  <uuid>{4b8bd5b8-3a8d-4982-8634-cee213a1f151}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.24800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RM_Mix</objectName>
  <x>961</x>
  <y>336</y>
  <width>60</width>
  <height>25</height>
  <uuid>{5bd5400f-83e9-43e5-852f-48fab6424531}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.248</label>
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
  <x>521</x>
  <y>369</y>
  <width>180</width>
  <height>30</height>
  <uuid>{dca2748e-9e56-4b1a-bd66-5901b157eb98}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Random RM Frequency Min</label>
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
  <objectName>RM_Freq_Min</objectName>
  <x>521</x>
  <y>351</y>
  <width>500</width>
  <height>27</height>
  <uuid>{a6bfa00a-c891-425f-943f-db79506429ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>10000.00000000</maximum>
  <value>500.95001221</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RM_Freq_Min</objectName>
  <x>961</x>
  <y>369</y>
  <width>60</width>
  <height>25</height>
  <uuid>{0ecbe118-4d18-491e-ad1a-8aa1a2f06f2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>500.950</label>
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
  <x>521</x>
  <y>402</y>
  <width>180</width>
  <height>30</height>
  <uuid>{65b95c0e-7226-4a7a-ae60-45f27284fa78}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Random RM Frequency Max</label>
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
  <objectName>RM_Freq_Max</objectName>
  <x>521</x>
  <y>384</y>
  <width>500</width>
  <height>27</height>
  <uuid>{786d3b00-71ba-4df3-bd78-efa14e9f1f85}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>10000.00000000</maximum>
  <value>8000.20019531</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RM_Freq_Max</objectName>
  <x>961</x>
  <y>402</y>
  <width>60</width>
  <height>25</height>
  <uuid>{0f8f95c3-9990-46c3-bdbf-3d2283c010e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8000.200</label>
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
  <objectName>RMOnOff</objectName>
  <x>746</x>
  <y>307</y>
  <width>16</width>
  <height>16</height>
  <uuid>{6feb99ec-2725-4450-9499-e8a01e775a4f}</uuid>
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
  <x>519</x>
  <y>425</y>
  <width>504</width>
  <height>132</height>
  <uuid>{5a7f66d0-63b6-41c9-a770-fb07ec3d240a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain-by-Grain Bandpass Filtering On</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>80</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>466</y>
  <width>180</width>
  <height>30</height>
  <uuid>{0bfc2585-8840-469a-9ba4-147d799fc0ff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Cutoff Min</label>
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
  <objectName>BPF_Cutoff_Min</objectName>
  <x>521</x>
  <y>448</y>
  <width>250</width>
  <height>27</height>
  <uuid>{3d25f4df-e980-45f9-9699-256214168d34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>4.00000000</minimum>
  <maximum>14.00000000</maximum>
  <value>6.15999985</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>BPF_Cutoff_Min</objectName>
  <x>711</x>
  <y>466</y>
  <width>60</width>
  <height>30</height>
  <uuid>{22e3f973-c3f3-4f48-bbb7-e254c82fc2c8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6.160</label>
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
  <x>771</x>
  <y>466</y>
  <width>180</width>
  <height>30</height>
  <uuid>{5bce04ee-1ec4-4e09-a16d-8131e015a8ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Cutoff Max</label>
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
  <objectName>BPF_Cutoff_Max</objectName>
  <x>771</x>
  <y>448</y>
  <width>250</width>
  <height>27</height>
  <uuid>{d48539a1-49ca-4299-8822-165c1905f9d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>4.00000000</minimum>
  <maximum>14.00000000</maximum>
  <value>14.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>BPF_Cutoff_Max</objectName>
  <x>961</x>
  <y>466</y>
  <width>60</width>
  <height>25</height>
  <uuid>{6aaa7fcb-87b1-4907-b850-403379ae8cf0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>14.000</label>
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
  <objectName>BPFOnOff</objectName>
  <x>746</x>
  <y>432</y>
  <width>16</width>
  <height>16</height>
  <uuid>{1ddbea0c-671c-4adf-b7d3-4876cec7a90e}</uuid>
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
  <x>521</x>
  <y>500</y>
  <width>180</width>
  <height>30</height>
  <uuid>{eb49930b-ef7b-4be5-bf53-a73779bfa9d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandwidth Min</label>
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
  <objectName>BPF_Bandwidth_Min</objectName>
  <x>521</x>
  <y>482</y>
  <width>250</width>
  <height>27</height>
  <uuid>{2f1b20c0-236a-46a5-aea9-80345983e20f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.25999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>BPF_Bandwidth_Min_Value</objectName>
  <x>711</x>
  <y>500</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e9feba80-3c25-465d-a83a-a0963d9eab3d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.011</label>
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
  <x>771</x>
  <y>500</y>
  <width>180</width>
  <height>30</height>
  <uuid>{98d58161-8aa8-4269-9468-e4c3b08e478b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandwidth Max</label>
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
  <objectName>BPF_Bandwidth_Max</objectName>
  <x>771</x>
  <y>482</y>
  <width>250</width>
  <height>27</height>
  <uuid>{34639c36-4fb2-4e00-969a-1ede00db03bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.26800001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>BPF_Bandwidth_Max_Value</objectName>
  <x>961</x>
  <y>501</y>
  <width>60</width>
  <height>25</height>
  <uuid>{31802f96-c7bf-4892-9333-f3423b054933}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.016</label>
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
  <x>521</x>
  <y>534</y>
  <width>180</width>
  <height>30</height>
  <uuid>{810559d5-3f0d-4d5d-b091-590c2b934a6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mix</label>
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
  <objectName>BPF_Mix</objectName>
  <x>521</x>
  <y>516</y>
  <width>250</width>
  <height>27</height>
  <uuid>{8fa04709-f197-43a6-921e-2c10600a677a}</uuid>
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
  <objectName>BPF_Mix</objectName>
  <x>711</x>
  <y>534</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c6511105-2f1b-4ed2-9e3c-18e026e8e797}</uuid>
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
  <x>771</x>
  <y>534</y>
  <width>180</width>
  <height>30</height>
  <uuid>{09dae760-2f17-4e3c-b951-fec989b91193}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
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
  <objectName>BPF_Gain</objectName>
  <x>771</x>
  <y>516</y>
  <width>250</width>
  <height>27</height>
  <uuid>{bae3e76e-3cc7-4d1d-88c3-a1d758ff53d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>30.00000000</maximum>
  <value>20.87999916</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>BPF_Gain</objectName>
  <x>961</x>
  <y>534</y>
  <width>60</width>
  <height>25</height>
  <uuid>{36653045-9f27-42b8-afed-f84e1e3af9ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20.880</label>
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
  <x>519</x>
  <y>558</y>
  <width>504</width>
  <height>90</height>
  <uuid>{d52af2b8-90f6-427c-953e-ad3129ee367e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Global Filtering    On</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>60</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>594</y>
  <width>180</width>
  <height>30</height>
  <uuid>{ebf4495e-58b0-4b92-9e12-9b3d86a36dc3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>HPF Cutoff</label>
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
  <objectName>HPF_Cutoff</objectName>
  <x>521</x>
  <y>576</y>
  <width>500</width>
  <height>27</height>
  <uuid>{cba3588b-4092-498e-afcd-916c02dae81b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>HPF_Cutoff_Value</objectName>
  <x>961</x>
  <y>594</y>
  <width>60</width>
  <height>25</height>
  <uuid>{c0fd4a55-8a99-437f-addb-63f42a190f80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20.852</label>
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
  <x>521</x>
  <y>627</y>
  <width>180</width>
  <height>30</height>
  <uuid>{14da3e8f-7483-4cc0-bc95-e6464ae40184}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LPF Cutoff</label>
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
  <objectName>LPF_Cutoff</objectName>
  <x>521</x>
  <y>609</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0bf556d0-4bcb-44b6-836a-d29171be3dd8}</uuid>
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
  <objectName>LPF_Cutoff_Value</objectName>
  <x>961</x>
  <y>627</y>
  <width>60</width>
  <height>25</height>
  <uuid>{e74cba6c-49af-46b1-a6b5-12bf6a2afac8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>20000.000</label>
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
  <objectName>FiltOnOff</objectName>
  <x>650</x>
  <y>565</y>
  <width>16</width>
  <height>16</height>
  <uuid>{41b90a50-575f-4897-ac75-4d43cfef8873}</uuid>
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
  <x>8</x>
  <y>543</y>
  <width>180</width>
  <height>30</height>
  <uuid>{51bafdef-2c23-4a21-86fe-27c32af699bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mix</label>
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
  <objectName>RVB_Mix</objectName>
  <x>8</x>
  <y>525</y>
  <width>160</width>
  <height>27</height>
  <uuid>{76cd15a8-cdb1-4598-9a58-2a8ce5a91fbe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.89375001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RVB_Mix</objectName>
  <x>110</x>
  <y>543</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d592750e-7386-4a2b-8cea-342c0f8c4e7f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.894</label>
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
  <y>580</y>
  <width>504</width>
  <height>68</height>
  <uuid>{0f013d78-60df-4341-8310-0bed7325862f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input File</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>140</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>608</y>
  <width>170</width>
  <height>30</height>
  <uuid>{bfe295fa-e4ba-482d-a338-63549ff21097}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/moi/Samples/ClassicalGuitar.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>178</x>
  <y>609</y>
  <width>330</width>
  <height>28</height>
  <uuid>{8102a36a-39d3-4c1f-90c7-36a4e07b549a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/moi/Samples/ClassicalGuitar.wav</label>
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
  <x>178</x>
  <y>543</y>
  <width>180</width>
  <height>30</height>
  <uuid>{833e6124-7572-4aa0-a989-543094ce0291}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Size</label>
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
  <objectName>RVB_Size</objectName>
  <x>178</x>
  <y>525</y>
  <width>160</width>
  <height>27</height>
  <uuid>{e1e15fd9-dc33-47d3-9f92-401c61a31f59}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.89999998</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RVB_Size</objectName>
  <x>280</x>
  <y>543</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8c21984f-2ca6-4953-b68b-eb4ff83e1966}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.900</label>
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
  <x>348</x>
  <y>543</y>
  <width>180</width>
  <height>30</height>
  <uuid>{06aa3c1c-a448-4e93-95d7-fdb864284ca8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Cutoff</label>
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
  <objectName>RVB_Cutoff</objectName>
  <x>348</x>
  <y>525</y>
  <width>160</width>
  <height>27</height>
  <uuid>{52496e94-8856-42c5-9fdd-520173ea0f2c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>20.00000000</minimum>
  <maximum>20000.00000000</maximum>
  <value>11883.12500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RVB_Cutoff</objectName>
  <x>450</x>
  <y>543</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6bd04ccc-1dce-4d44-bb01-c98eb2039799}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>11883.125</label>
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
<preset name="INIT" number="0" >
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="1" >0.00000000</value>
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="4" >0</value>
<value id="{8f899f73-cfdb-4cba-881e-458ca38d2473}" mode="1" >0.30000001</value>
<value id="{95133863-04df-4ec2-b7ea-3fec18dc36fe}" mode="1" >0.30000001</value>
<value id="{95133863-04df-4ec2-b7ea-3fec18dc36fe}" mode="4" >0.300</value>
<value id="{189f2c49-2073-4f2d-83ed-77a51c86bcc2}" mode="1" >0.00000000</value>
<value id="{8829cce9-907e-440d-ace8-774244e2ca84}" mode="1" >0.00000000</value>
<value id="{8829cce9-907e-440d-ace8-774244e2ca84}" mode="4" >0.000</value>
<value id="{00eb88cd-00e6-49e6-9b4e-1da883c22cb0}" mode="1" >0.25000000</value>
<value id="{e3ccec3a-893c-498c-ab7f-679cb44d0dca}" mode="1" >0.25000000</value>
<value id="{e3ccec3a-893c-498c-ab7f-679cb44d0dca}" mode="4" >0.250</value>
<value id="{6c0fea2c-9d68-4e97-bab0-0ff1e5904298}" mode="1" >0.50000000</value>
<value id="{7569fb66-578f-4c26-9a4a-7b64c1ec40ca}" mode="1" >0.50000000</value>
<value id="{7569fb66-578f-4c26-9a4a-7b64c1ec40ca}" mode="4" >0.500</value>
<value id="{a0c90857-7310-4ec2-a193-24b3181a0a16}" mode="1" >0.00200000</value>
<value id="{648254b7-58e3-4a88-9110-01822df76b68}" mode="1" >0.00200000</value>
<value id="{648254b7-58e3-4a88-9110-01822df76b68}" mode="4" >0.002</value>
<value id="{3e019e12-b403-417b-a62f-cd514b4fbe45}" mode="1" >1.00000000</value>
<value id="{5d6de635-b049-4b33-9497-5dae6ed04731}" mode="1" >1.00000000</value>
<value id="{5d6de635-b049-4b33-9497-5dae6ed04731}" mode="4" >1.000</value>
<value id="{bba5f073-15d1-4a0d-908c-d3b73e9ec405}" mode="1" >0.48199999</value>
<value id="{6c09f836-048e-45bb-a9e5-7ba884ef4277}" mode="1" >0.00257257</value>
<value id="{6c09f836-048e-45bb-a9e5-7ba884ef4277}" mode="4" >0.003</value>
<value id="{5846dcd2-0841-4d6c-9708-3a2b2cb7f668}" mode="1" >0.63000000</value>
<value id="{a966e0a7-fa32-4333-8319-3869c2a3edc2}" mode="1" >60.08890915</value>
<value id="{a966e0a7-fa32-4333-8319-3869c2a3edc2}" mode="4" >60.089</value>
<value id="{2617dbe0-61b1-41af-a512-a96de791a710}" mode="1" >0.83200002</value>
<value id="{8b4b116e-5d3a-48e9-a5c3-b8bf919c2f95}" mode="1" >0.83200002</value>
<value id="{8b4b116e-5d3a-48e9-a5c3-b8bf919c2f95}" mode="4" >0.832</value>
<value id="{95733af6-c2ef-4e08-9b03-9d22f3f1e454}" mode="1" >0.91200000</value>
<value id="{dc0c739a-ad94-4286-9c5e-10a74640b948}" mode="1" >0.59989184</value>
<value id="{dc0c739a-ad94-4286-9c5e-10a74640b948}" mode="4" >0.600</value>
<value id="{2232516c-cdc7-49e6-80ee-1cf950410978}" mode="1" >0.91200000</value>
<value id="{2b8541c3-8e4f-4b73-adf2-462220fa1d94}" mode="1" >0.59989184</value>
<value id="{2b8541c3-8e4f-4b73-adf2-462220fa1d94}" mode="4" >0.600</value>
<value id="{8e2d43f0-da03-48e0-a993-1edb26cdc5c7}" mode="1" >1.00000000</value>
<value id="{8e2d43f0-da03-48e0-a993-1edb26cdc5c7}" mode="4" >1</value>
<value id="{36da2080-5c2b-4a77-9eba-0f5f52f208b5}" mode="1" >0.39965999</value>
<value id="{a6c7e49b-194b-4778-bcd4-6176e3e02ca9}" mode="1" >0.40000001</value>
<value id="{a6c7e49b-194b-4778-bcd4-6176e3e02ca9}" mode="4" >0.400</value>
<value id="{4adc99f8-c2ee-42ea-958c-f5563cf373e5}" mode="1" >0.49955001</value>
<value id="{84bcd025-362c-4be2-99ef-cab7de104b2a}" mode="1" >0.50000000</value>
<value id="{84bcd025-362c-4be2-99ef-cab7de104b2a}" mode="4" >0.500</value>
<value id="{f7feb0e5-b26f-4925-88ae-8417cf1dcd0a}" mode="1" >0.00000000</value>
<value id="{1efba2e1-40af-4009-bed2-1e96780d0e4b}" mode="1" >0.00000000</value>
<value id="{1efba2e1-40af-4009-bed2-1e96780d0e4b}" mode="4" >0.000</value>
<value id="{07952487-6e03-413f-930a-343610cacb73}" mode="1" >0.00000000</value>
<value id="{58f459be-8a71-40d7-a6b3-d4dd225f0e7d}" mode="1" >0.00000000</value>
<value id="{58f459be-8a71-40d7-a6b3-d4dd225f0e7d}" mode="4" >0.000</value>
<value id="{376a6829-cc9a-4c98-a8b6-cb3b7423164b}" mode="1" >0.00000000</value>
<value id="{50b1352f-ae74-4cdb-becf-4777aaab3063}" mode="1" >0.00000000</value>
<value id="{50b1352f-ae74-4cdb-becf-4777aaab3063}" mode="4" >0.000</value>
<value id="{4e86c254-5afc-4db7-b63c-1ad7bf998596}" mode="1" >-2.03999996</value>
<value id="{b8bec75d-b063-48f5-a25b-0413770d54ae}" mode="1" >-2.03999996</value>
<value id="{b8bec75d-b063-48f5-a25b-0413770d54ae}" mode="4" >-2.040</value>
<value id="{f212768c-e843-41ca-9eef-abf032850ea6}" mode="1" >0.00000000</value>
<value id="{88da0d94-99bd-4a19-acd4-daab786d139f}" mode="1" >0.00000000</value>
<value id="{88da0d94-99bd-4a19-acd4-daab786d139f}" mode="4" >0.000</value>
<value id="{4b8bd5b8-3a8d-4982-8634-cee213a1f151}" mode="1" >0.24800000</value>
<value id="{5bd5400f-83e9-43e5-852f-48fab6424531}" mode="1" >0.24800000</value>
<value id="{5bd5400f-83e9-43e5-852f-48fab6424531}" mode="4" >0.248</value>
<value id="{a6bfa00a-c891-425f-943f-db79506429ad}" mode="1" >500.95001221</value>
<value id="{0ecbe118-4d18-491e-ad1a-8aa1a2f06f2e}" mode="1" >500.95001221</value>
<value id="{0ecbe118-4d18-491e-ad1a-8aa1a2f06f2e}" mode="4" >500.950</value>
<value id="{786d3b00-71ba-4df3-bd78-efa14e9f1f85}" mode="1" >8000.20019531</value>
<value id="{0f8f95c3-9990-46c3-bdbf-3d2283c010e7}" mode="1" >8000.20019531</value>
<value id="{0f8f95c3-9990-46c3-bdbf-3d2283c010e7}" mode="4" >8000.200</value>
<value id="{6feb99ec-2725-4450-9499-e8a01e775a4f}" mode="1" >1.00000000</value>
<value id="{6feb99ec-2725-4450-9499-e8a01e775a4f}" mode="4" >1</value>
<value id="{3d25f4df-e980-45f9-9699-256214168d34}" mode="1" >6.15999985</value>
<value id="{22e3f973-c3f3-4f48-bbb7-e254c82fc2c8}" mode="1" >6.15999985</value>
<value id="{22e3f973-c3f3-4f48-bbb7-e254c82fc2c8}" mode="4" >6.160</value>
<value id="{d48539a1-49ca-4299-8822-165c1905f9d8}" mode="1" >14.00000000</value>
<value id="{6aaa7fcb-87b1-4907-b850-403379ae8cf0}" mode="1" >14.00000000</value>
<value id="{6aaa7fcb-87b1-4907-b850-403379ae8cf0}" mode="4" >14.000</value>
<value id="{1ddbea0c-671c-4adf-b7d3-4876cec7a90e}" mode="1" >0.00000000</value>
<value id="{1ddbea0c-671c-4adf-b7d3-4876cec7a90e}" mode="4" >0</value>
<value id="{2f1b20c0-236a-46a5-aea9-80345983e20f}" mode="1" >0.25999999</value>
<value id="{e9feba80-3c25-465d-a83a-a0963d9eab3d}" mode="1" >0.01097056</value>
<value id="{e9feba80-3c25-465d-a83a-a0963d9eab3d}" mode="4" >0.011</value>
<value id="{34639c36-4fb2-4e00-969a-1ede00db03bd}" mode="1" >0.26800001</value>
<value id="{31802f96-c7bf-4892-9333-f3423b054933}" mode="1" >0.01585512</value>
<value id="{31802f96-c7bf-4892-9333-f3423b054933}" mode="4" >0.016</value>
<value id="{8fa04709-f197-43a6-921e-2c10600a677a}" mode="1" >0.00000000</value>
<value id="{c6511105-2f1b-4ed2-9e3c-18e026e8e797}" mode="1" >0.00000000</value>
<value id="{c6511105-2f1b-4ed2-9e3c-18e026e8e797}" mode="4" >0.000</value>
<value id="{bae3e76e-3cc7-4d1d-88c3-a1d758ff53d8}" mode="1" >20.87999916</value>
<value id="{36653045-9f27-42b8-afed-f84e1e3af9ef}" mode="1" >20.87999916</value>
<value id="{36653045-9f27-42b8-afed-f84e1e3af9ef}" mode="4" >20.880</value>
<value id="{cba3588b-4092-498e-afcd-916c02dae81b}" mode="1" >0.00600000</value>
<value id="{c0fd4a55-8a99-437f-addb-63f42a190f80}" mode="1" >20.85170555</value>
<value id="{c0fd4a55-8a99-437f-addb-63f42a190f80}" mode="4" >20.852</value>
<value id="{0bf556d0-4bcb-44b6-836a-d29171be3dd8}" mode="1" >1.00000000</value>
<value id="{e74cba6c-49af-46b1-a6b5-12bf6a2afac8}" mode="1" >20000.00000000</value>
<value id="{e74cba6c-49af-46b1-a6b5-12bf6a2afac8}" mode="4" >20000.000</value>
<value id="{41b90a50-575f-4897-ac75-4d43cfef8873}" mode="1" >0.00000000</value>
<value id="{41b90a50-575f-4897-ac75-4d43cfef8873}" mode="4" >0</value>
<value id="{76cd15a8-cdb1-4598-9a58-2a8ce5a91fbe}" mode="1" >0.89375001</value>
<value id="{d592750e-7386-4a2b-8cea-342c0f8c4e7f}" mode="1" >0.89375001</value>
<value id="{d592750e-7386-4a2b-8cea-342c0f8c4e7f}" mode="4" >0.894</value>
<value id="{bfe295fa-e4ba-482d-a338-63549ff21097}" mode="4" >/home/moi/Samples/ClassicalGuitar.wav</value>
<value id="{8102a36a-39d3-4c1f-90c7-36a4e07b549a}" mode="4" >/home/moi/Samples/ClassicalGuitar.wav</value>
<value id="{e1e15fd9-dc33-47d3-9f92-401c61a31f59}" mode="1" >0.89999998</value>
<value id="{8c21984f-2ca6-4953-b68b-eb4ff83e1966}" mode="1" >0.89999998</value>
<value id="{8c21984f-2ca6-4953-b68b-eb4ff83e1966}" mode="4" >0.900</value>
<value id="{52496e94-8856-42c5-9fdd-520173ea0f2c}" mode="1" >11883.12500000</value>
<value id="{6bd04ccc-1dce-4d44-bb01-c98eb2039799}" mode="1" >11883.12500000</value>
<value id="{6bd04ccc-1dce-4d44-bb01-c98eb2039799}" mode="4" >11883.125</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

;Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:


;my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


;INITIALISE GLOBAL VARIABLES
gkcps		init	0
gkNumInstr1	init	0
gkvib		init	0


instr	1
	icps			cpsmidi						;READ VALUES FOR FREQUENCY FROM A MIDI KEYBOARD 
	gkcps		=		icps					;CREATE A K-RATE GLOBAL VARIABLE FROM MIDI FREQ. VALUES
	
	;CREATE A VIBRATO FUNCTION - THIS ENVELOPE WILL BE TRIGGERED WITH EACH NEW NEW THAT IS PRESSED WHETHER LEGATO OR NOT
	ivibamp		=		.1
	ivibdelayTim	=		.3
	ivibRiseTim	=		1
	kvibenv		expseg	.001, (ivibdelayTim), .001, (ivibRiseTim), ivibamp, (1), ivibamp
	kvibfreq		=		6
	ivibwave		=		1
	kvib			oscil	kvibenv, kvibfreq, ivibwave
	gkvib		=		kvib+1
	
	;INSTR 2 IS INSTRUCTED TO PLAY A VERY LONG NOTE - ONLY ONE NOTE AT A TIME IS ALLOWED
	;						KTRIGGER, KMINTIM, KMAXNUM, KINSNUM, KWHEN, KDUR 
				schedkwhen      1,           0,       1,       2,      0,   3600
endin
			
instr	2

	kporttime_gui	invalue		"Portamento"

	kreleaseflag	release
	gkNumInstr1 	active 		1								;SENSE THE NUMBER OF NOTES ARE BEING PLAYED BY INSTR 1
	if	gkNumInstr1!=0||kreleaseflag=1	kgoto KEEP_PLAYING			;IF INSTR 1 IS PLAYING AT LEAST ONE NOTE THEN INSTR 2 MUSTN'T TURN ITSELF OFF
															;I.E. SKIP THE NEXT LINE...
	turnoff													;INSTR 2 TURNS ITSELF OFF
	KEEP_PLAYING:												;SKIP TO HERE IF INSTR 1 IS STILL PLAYING
	
	;CREATE PORTAMENTO ON PITCH PARAMETER
	kporttime		linseg	0, .01, 1, 1, 1
	kporttime		=		kporttime * kporttime_gui
	kcps			portk	gkcps, kporttime
	
	;CREATE AN OSILLATOR USING THE vco OPCODE
	iwave		=		1
	kpw			=		.5
	ifn			=		1
	imaxd		=		1
	ileak		=		0
	inyx			=		.5
	asig			vco 		0.3, kcps*gkvib, iwave, kpw, ifn, imaxd, ileak, inyx
	
	;FILTER ENVELOPE - ALL LEVELS ARE GIVEN IN OCT FORMAT
	iFAttTim		=		.1									;ATTACK TIME
	iFAttLev		=		7									;ATTACK LEVEL
	iFDecTim		=		.1									;DECAY TIME
	iFSusLev		=		5									;SUSTAIN LEVEL
	iFRelTim		=		0.01									;RELEASE TIME
	;CREATE AN ENVELOPE WITH A MIDI RELEASE SEGMENT TO INFLUENCE THE FILTER CUTOFF
	kFEnv		linsegr	0, iFAttTim, iFAttLev, iFDecTim, iFSusLev, iFRelTim, 0
	kCFOct		=		6									;BASE LEVEL OF THE FILTER (BEFORE THE ENVELOPE IS ADDED)
	kCFcps		=		cpsoct(kCFOct+kFEnv)					;FINAL FILTER CUTOFF VALUE (IN CPS) INCORPORATING THE FILTER ENVELOPE AND THE FILTER BASE LEVEL
	kres			=		.5									;RESOSNANCE
	iscale 		= 		1
	;CREATE A FILTERED VERSION OF THE OSCILLATOR SIGNAL
	aFilt		moogvcf	asig, kCFcps, kres ,iscale
	;SEND FILTERED SIGNAL TO OUTPUT
	aenv			linsegr	0,0.001,1,0.01,0						;ANTI CLICK ENVELOPE
				outs		aFilt * aenv, aFilt * aenv
endin
</CsInstruments>
<CsScore>
f 1 0 131072 10 1		;A SINE WAVE - USED BY BOTH THE VIBRATO AND THE vco
f 0 3600				;DUMMY SCORE EVENT - REAL TIME PERFORMANCE FOR 1 HOUR
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>661</x>
 <y>241</y>
 <width>718</width>
 <height>352</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>170</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>711</width>
  <height>345</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Basic Monophonic MIDI Synthesizer</label>
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
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>21</y>
  <width>702</width>
  <height>259</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------
You will need to have a midi keyboard connected to the computer for this to work. Monosynths can be implemented using 2 separate instruments and the schedkwhen opcode. The instrument containing the schedkwhen is midi triggered the schedkwhen opcode triggers a second instrument which is the one that actually produces the sound. Crucially the imaxnum parameter (maximum number of simultaneous notes allowed) in the schedkwhen opcode line is set to 1. The active opcode is used (in instr 2) to sense how many notes instr 1 is playing. If instr 1 isn't playing any notes then instr 2 turns itself off. Pitch variables are passed from the first instrument to the second using global variables. Portamento (portk) is used to implement glisandi between overlapping notes.
There are two ways in which envelopes can be triggered in monophonic synths:
1 - triggered only once, at the beginning of a sequence of overlapping notes.
2 - triggered with each new new that is pressed whether overlapping or not.
Two different envelopes which illustrate these two situations have been implemented in this example:
1 - a filter envelope is put in instrument 2 so that it will only trigger with the first of a series of overlapping notes.
2 - a vibrato function (with an vibrato depth envelope) is placed in instr 1 so that it will trigger each time a new note is is pressed whether legato or not.</label>
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
  <x>10</x>
  <y>288</y>
  <width>695</width>
  <height>50</height>
  <uuid>{b143f42f-2cbc-4532-8df7-4ba643c60b37}</uuid>
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
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>310</y>
  <width>180</width>
  <height>30</height>
  <uuid>{2e52a7a7-dc13-405e-896d-db2a7431d8dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Portamento Time</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Portamento</objectName>
  <x>12</x>
  <y>292</y>
  <width>689</width>
  <height>26</height>
  <uuid>{6ab84e0f-82a7-4b9c-af23-35bd7d9b7fa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.06095791</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Portamento</objectName>
  <x>641</x>
  <y>310</y>
  <width>60</width>
  <height>30</height>
  <uuid>{99d6bf8b-3c85-4911-a29a-7dd678a940ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.061</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

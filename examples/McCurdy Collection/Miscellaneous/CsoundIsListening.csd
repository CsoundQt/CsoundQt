;Written by Iain McCurdy, 2011


;Modified for QuteCsound by René, May 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add Voices spinbox widget and Start button 
	

;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 64		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


			zakinit	3,3		;INITIALISE ZAK VARIABLE STORAGE SPACE

	;INITIALISE REVERB SEND VARIABLES
	gasendL		init		0
	gasendR		init		0

;DEFINE A UDO FOR AN OSCILLATOR VOICE
opcode	vcomodule, 0, ii													;DEFINE OPCODE FORMAT
	icount,inum	xin														;DEFINE NAMES FOR INPUT ARGUMENTS
	kvar			jspline	15,0.1,0.2										;RANDOM JITTERING OF PITCH
	kpw			rspline	0.05,0.5,0.4,0.8									;RANDOM MOVEMENT OF PULSE WIDTH FOR vco2
	imorphtime	random	5.5,6.5											;TIME TO MORPH FROM GLIDING PITCHES TO STATIC PITCHES WILL DIFFER SLIGHTLY FROM VOICE TO VOICE
	kxfade		linseg	0,7, 0,imorphtime, 0.999,2, 0.999						;FUNCTION DEFINING MORPH FROM GLIDING TO STATIC VOICES IS CREATED				
	ioct			wrap		icount,0,8										;BASIC OCTAVE FOR EACH VOICE IS DERIVED FROM VOICE COUNT NUMBER (WRAPPED BETWEEN 0 AND 8 TO PREVENT RIDICULOUSLY HIGH TONES)
	iinitoct		random	0,2												;DEFINES THE SPREAD OF VOICES DURING THE GLIDING VOICES SECTION
	kcps			ntrpol	200*semitone(kvar)*octave(iinitoct),cpsoct(3+ioct+octpch(0.025)),kxfade		;PITCH (IN CPS) OF EACH VOICE - MORPHING BETWEEN A RANDOMLY GLIDING STAGE AND A STATIC STAGE
	koct			=		octcps(kcps)										;PITCH CONVERTED TO OCT FORMAT
	kdb			=		(5-koct)*4										;DECIBEL VALUE DERIVED FROM OCT VALUE - THIS WILL BE USED FOR 'AMPLITUDE SCALING' TO PREVENT EMPHASIS OF HIGHER PITCHED TONES

	a1			vco2		ampdb(kdb)*0.12,kcps,4,kpw,0							;THE OSCILLATOR IS CREATED
	kPanDep		linseg	0,5,0,6,0.5										;RANDOM PANNING DEPTH WILL MOVE FROM ZERO (MONOPHONIC) TO FULL STEREO AT THE END OF THE NOTE
	kpan			rspline	0.5+kPanDep,0.5-kPanDep,0.3,0.5						;RANDOM PANNING FUNCTION
	aL, aR		pan2		a1, kpan											;MONO OSCILLATOR IS RANDOMLY PANNED IN A SMOOTH GLIDING MANNER
				zawm		aL,0												;LEFT CHANNEL MIXED INTO ZAK VARIABLE
				zawm		aR,1												;RIGHT CHANNEL MIXED INTO ZAK VARIABLE

	icount		=		icount + 1										;INCREMENT VOICE COUNT COUNTER
	if	icount <= inum	then													;IF TOTAL VOICE LIMIT HAS NOT YET BEEN REACHED...
		vcomodule		icount, inum											;...CALL THE UDO AGAIN (WITH THE INCREMENTED COUNTER)
	endif																;END OF THIS CONDITIONAL BRANCH
endop

instr	1	;SYNTH VOICES GENERATING INSTRUMENT
	knum		invalue	"Voices"												;NUMBER OF VOICES
	icount	init		0													;INITIALISE VOICE COUNTER

			vcomodule	icount,i(knum)											;CALL vcomodule UDO (SUBSEQUENT CALLS WILL BE MADE WITHIN THE UDO ITSELF)

	aoutL	zar		0													;READ ZAK CHANNEL (MIX OF ALL VOICES LEFT CHANNEL)
	aoutR	zar		1													;READ ZAK CHANNEL (MIX OF ALL VOICES RIGHT CHANNEL)
	aoutL	dcblock	aoutL												;REMOVE DC OFFSET FROM AUDIO (LEFT CHANNEL)
	aoutR	dcblock	aoutR												;REMOVE DC OFFSET FROM AUDIO (RIGHT CHANNEL)
	kenv		linseg	-90,(1), -50,(6), -20,(6), 0,(p3-16),  0,(3), -90				;AMPLITUDE ENVELOPE THAT WILL BE APPLIED TO THE MIX OF ALL VOICES
	aoutL	=		aoutL*ampdb(kenv)										;APPLY ENVELOPE (LEFT CHANNEL)
	aoutR	=		aoutR*ampdb(kenv)										;APPLY ENVELOPE (RIGHT CHANNEL)
			outs		aoutL,aoutR											;SEND AUDIO TO OUTPUTS
			zacl		0,3													;CLEAR ZAK AUDIO VARIABLES
	gasendL	=		gasendL+(aoutL*0.5)										;MIX SOME AUDIO INTO THE REVERB SEND VARIABLE (LEFT CHANNEL)
	gasendR	=		gasendR+(aoutR*0.5)										;MIX SOME AUDIO INTO THE REVERB SEND VARIABLE (RIGHT CHANNEL)
endin

instr	2	;REVERB INSTRUMENT
	aRvbL,aRvbR	reverbsc	gasendL,gasendR,0.82,10000
				outs		aRvbL,aRvbR
				clear	gasendL,gasendR
endin
</CsInstruments>
<CsScore>
i 2 0 3600		;REVERB INSTRUMENT
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>760</x>
 <y>256</y>
 <width>706</width>
 <height>379</height>
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
  <width>701</width>
  <height>375</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CsoundIsListening</label>
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
  <x>7</x>
  <y>71</y>
  <width>692</width>
  <height>300</height>
  <uuid>{a22504a1-aa44-46e3-9ff9-60d7e5c3b024}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This example exemplifies the technique of opcode iteration using UDOs to create a mass of oscillators using a small amount of code.
This technique is introduced and explained in detail by Steven Yi in his article 'Control Flow - Part II' in the summer 2006 issue of the Csound Journal (http://www.csounds.com/journal/2006summer/controlFlow_part2.html).

In this example  a maximum of 1000 vco2 oscillators (voices) are created, you can change this number in the GUI, increasing it if your system permits it in realtime.
Each oscillator exhibits its own unique behaviour in terms of its pitch, pulse width and panning.
The entire mass morphs from a state in which the oscillator pitches slowly glide about randomly to a state in which they hold a fixed pitch across a range of octaves.

Some commercial synthesizers offer oscillators called 'mega-saws' or something similar. These are normally just clusters of detuned sawtooth waveforms so this is the way in which this could be emulated in Csound.
The example emulates a familiar sound ident. It is for educational purposes and no breach of copyright is intended.</label>
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
  <x>19</x>
  <y>39</y>
  <width>140</width>
  <height>30</height>
  <uuid>{3277f9fb-691f-414c-8727-17951e27cba8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number of voices :</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Voices</objectName>
  <x>161</x>
  <y>39</y>
  <width>70</width>
  <height>30</height>
  <uuid>{e4a2b012-68dd-4120-b4f6-358ea0fcd693}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
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
  <minimum>10</minimum>
  <maximum>1000</maximum>
  <randomizable group="0">false</randomizable>
  <value>50</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>280</x>
  <y>39</y>
  <width>100</width>
  <height>30</height>
  <uuid>{4f7ff38a-67e3-4225-abd4-50ff8a4704eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Start</text>
  <image>/</image>
  <eventLine>i1 0 20</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

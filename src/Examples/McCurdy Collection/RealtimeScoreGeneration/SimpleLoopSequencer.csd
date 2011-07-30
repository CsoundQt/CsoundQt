;Written by Iain McCurdy, 2011

;Modified for QuteCsound by René, March 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add Tempo SpinBox widget


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 10		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 1		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


;						1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16
gi1		ftgen	0,0,16,2,	1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0	;BASS DRUM 
gi2		ftgen	0,0,16,2,	1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1	;KALIMBA 
gi3		ftgen	0,0,16,2,	0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0	;SNARE
gi4		ftgen	0,0,16,2,	1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0	;CLOSED HI-HAT
gi5		ftgen	0,0,16,2,	0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1	;OPEN HI-HAT
gi6		ftgen	0,0,16,2,	1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0	;TAMBOURINE 
gisine	ftgen	0,0,4096,10,1										;SINE

gindx	init		0


instr	1
	ktempo	invalue		"Tempo"	
	ktick	metro		(ktempo*4)/60
			schedkwhen	ktick, 0, 0, 2, 0, 0.001, 0
endin

instr	2
#define	VOICE(N)	
	#
	iOnOff$N	table		gindx, gi$N
			schedkwhen	iOnOff$N, 0, 0, p1+$N, 0, 0.2
	#
$VOICE(1)
$VOICE(2)
$VOICE(3)
$VOICE(4)
$VOICE(5)
$VOICE(6)
	gindx	wrap		gindx+1, 0, 16
			turnoff
endin

instr	3	;SOUND 1 - BASS DRUM
	p3		=		0.2										;DEFINE DURATION FOR THIS SOUND
	aenv		expon	rnd(0.5)+0.5,p3,0.001						;AMPLITUDE ENVELOPE - PERCUSSIVE DECAY
	kcps		expon	200,p3,20									;PITCH GLISSANDO
	asig		oscil	aenv*0.5, kcps, gisine 						;OSCILLATOR
			out		asig										;SEND AUDIO TO OUTPUTS
endin

instr	4	;SOUND 2 - KALIMBA (BAR MODEL)
	p3		=		2.6										;DEFINE DURATION FOR THIS SOUND
	asig 	barmodel	1, 1, 80, 1, 0, 2.6, 0.5, 6000, 0.07			;KALIMBA SOUND CREATED USING barmodel OPCODE (SEE CSOUND MANUAL FOR MORE INFO.)
			out		asig*(rnd(0.5)+0.5)*0.1				 		;SEND AUDIO TO OUTPUTS AND ATTENUATE  USING GAIN CONTROLS
endin

instr	5	;SOUND 3 - SNARE
	p3		=		0.15										;DEFINE DURATION FOR THIS SOUND
	aenv		expon	rnd(0.5)+0.5,p3,0.001						;AMPLITUDE ENVELOPE - PERCUSSIVE DECAY
	anse		noise	1, 0 									;CREATE NOISE COMPONENT FOR SNARE DRUM SOUND
	kcps		expon	400,p3,20									;CREATE TONE COMPONENT FREQUENCY GLISSANDO FOR SNARE DRUM SOUND
	ajit		randomi	0.2,1.8,10000								;JITTER ON FREQUENCY FOR TONE COMPONENT
	atne		oscil	aenv,kcps*ajit,gisine						;CREATE TONE COMPONENT
	asig		sum		anse*0.5, atne*5							;MIX NOISE AND TONE SOUND COMPONENTS
	ares 	comb 	asig, 0.02, 0.0035							;PASS SIGNAL THROUGH A COMB FILTER TO CREATE STATIC HARMONIC RESONANCE
			out		ares*aenv*0.1								;SEND AUDIO TO OUTPUTS, APPLY ENVELOPE AND ATTENTUATE USING GAIN CONTROLS 
endin

instr	6	;SOUND 4 - CLOSED HI-HAT
			turnoff2	7,0,0									;TURN OFF ALL INSTANCES OF instr 7 (OPEN HI-HAT)
	p3		=		0.1										;DEFINE DURATION FOR THIS SOUND
	aenv		expon	rnd(0.5)+0.5,p3,0.001						;AMPLITUDE ENVELOPE - PERCUSSIVE DECAY
	asig		noise	aenv*0.3, 0								;CREATE SOUND FOR CLOSED HI-HAT
	asig		buthp	asig, 7000								;HIGHPASS FILTER SOUND
			out		asig										;SEND AUDIO TO OUTPUTS
endin

instr	7	;SOUND 5 - OPEN HI-HAT
	p3		=		1										;DEFINE DURATION FOR THIS SOUND
	aenv		expon	rnd(0.5)+0.5,p3,0.001						;AMPLITUDE ENVELOPE - PERCUSSIVE DECAY
	asig		noise	aenv*0.3, 0								;CREATE SOUND FOR CLOSED HI-HAT
	asig		buthp	asig, 7000								;HIGHPASS FILTER SOUND	
			out		asig										;SEND AUDIO TO OUTPUTS
endin

instr	8	;SOUND 6 - TAMBOURINE
	p3		=		0.5										;DEFINE DURATION FOR THIS SOUND
	asig		tambourine 0.1,0.01 ,32, 0.47, 0, 2300 , 5600, 8000		;TAMBOURINE SOUND CREATED USING tambourine PHYSICAL MODELLING OPCODE (SEE CSOUND MANUAL FOR MORE INFO.)
			out		asig*(rnd(0.5)+0.5)							;SEND AUDIO TO OUTPUTS
endin
</CsInstruments>
<CsScore>
i 1 0 300
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1030</x>
 <y>237</y>
 <width>515</width>
 <height>284</height>
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
  <width>508</width>
  <height>280</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Simple Loop Sequencer</label>
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
  <x>6</x>
  <y>84</y>
  <width>499</width>
  <height>195</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------
This example demonstrates a simple method for creating a looping step sequencer that doesn't used the 'timedseq' opcode.
Note triggers for each instrument are stored in GEN 2 function table, 1 meaning play a note, 0 meaning don't.
This example can easily be expanded to create more elaborate pattern but I have kept it simple so far to provide a basic starting point.

This method is less flexible than the method using timedseq but for simple rhythmical patterns will probably be adequate.</label>
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
  <x>16</x>
  <y>52</y>
  <width>80</width>
  <height>30</height>
  <uuid>{ab2263b1-0628-47c5-9db6-34777794227c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tempo :</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Tempo</objectName>
  <x>97</x>
  <y>52</y>
  <width>60</width>
  <height>30</height>
  <uuid>{163e9b1f-3627-4639-b0d1-b01a2d21e248}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
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
  <maximum>240</maximum>
  <randomizable group="0">false</randomizable>
  <value>90</value>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

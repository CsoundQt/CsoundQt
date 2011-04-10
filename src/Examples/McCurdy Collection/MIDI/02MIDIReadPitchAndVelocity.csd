;Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add icps and iamp displays

;my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>
 
</CsOptions>    
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 128	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


instr	1	; SIMPLE BEEP INSTRUMENT - CAN BE ACTIVATED VIA A CONNECTED MIDI KEYBOARD
	icps		cpsmidi	; THE OPCODE 'CPSMIDI' OUTPUTS A CYCLES-PER-SECOND REPRESENTATION OF A RECEIVED MIDI NOTE.
					; IN THIS EXAMPLE I HAVE CALLED THE OUTPUT VARIABLE 'ICPS'.
					; 'CPSMIDI' TAKES NO INPUT ARGUMENTS.
					; E.G. IF A4 IS STRUCK ICPS WILL EQUAL 440
			
	iscale 	= 	0.2
	iamp		ampmidi	iscale	
					; THE OPCODE 'AMPMIDI' OUTPUTS A VALUE (IN THIS CASE CALLED IAMP) CORRESPONDING TO THE
					; KEY VELOCITY OF A RECEIVED NOTE ON MESSAGE.
					; THE FIRST ,AND ONLY OBLIGATORY ARGUMENT RESCALES THE RECEIVED VELOCITY VALUE (WHICH WOULD
					; NORMALLY BE IN THE RANGE 0-127 TO THE RANGE 0-ISCALE, WHICH IN THIS CASE MEANS THAT THE 
					; VARIABLE IAMP WILL BE WITHIN THE RANGE 0-10000 DEPENDING ON HOW HARD
					; I HIT THE NOTE ON THE KEYBOARD

			outvalue	"icps", icps
			outvalue	"iamp", iamp

	;OUTPUT	OPCODE	AMPLITUDE | FREQUENCY | FUNCTION_TABLE
	asig		oscili	iamp,         icps,        1
			outs		asig, asig	;SEND AUDIO OUTPUT OF OSCILLATOR TO THE SPEAKERS
endin
</CsInstruments>
<CsScore>
f 1 0 1024 10 1	; SINE WAVE
f 0 600			; THIS LINE FUNCTIONS AS A DUMMY SCORE EVENT AND ALLOWS REALTIME MIDI PLAYING FOR 10 MINUTES
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>729</x>
 <y>354</y>
 <width>642</width>
 <height>353</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>170</r>
  <g>170</g>
  <b>170</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>638</width>
  <height>349</height>
  <uuid>{c37e13f6-7642-465f-9b2a-f059eef7bce8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>  Converting MIDI Pitch and Velocity into Csound Variables</label>
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
  <x>5</x>
  <y>27</y>
  <width>632</width>
  <height>268</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------------------------------------------------------------------------
The opcode 'cpsmidi' is used to convert a received MIDI pitch into an i-rate variable useable in Csound orchestra code. A variety of other pitch format are available:
* 'octmidi' provides a value in the 'oct' format.
* 'pchmidi' provides a value in the 'pch' format.
* 'notnum' provides the actual note MIDI note number (range 0 - 127)

More information on this opcode is given in the actual code of this example. The opcode 'ampmidi' converts a received MIDI velocity value into an i-rate variable useable in Csound orchestra code. MIDI velocity values are normally within the range 0 to 127 but the maximum limit for ampmidi's output can be modified using using the opcode's only input argument. More information on this opcode is given in the actual code of this example. An alternative opcode for scanning MIDI velocity is 'veloc'. This example uses ampmidi's output for raw amplitude values but it might be found that using its output for decibel values produces a more useful velocity response.</label>
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
  <x>5</x>
  <y>292</y>
  <width>316</width>
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
  <x>180</x>
  <y>301</y>
  <width>54</width>
  <height>30</height>
  <uuid>{841ed5e4-ff5c-45b7-9988-c19b801e45a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>iamp:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
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
  <objectName>icps</objectName>
  <x>72</x>
  <y>303</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f8119d82-f052-4a86-8790-440c42c5d41d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>195.987</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
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
  <x>18</x>
  <y>301</y>
  <width>54</width>
  <height>30</height>
  <uuid>{4dc3e62f-8cd7-48cb-8f7f-25878ba3b97e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>icps:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
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
  <objectName>iamp</objectName>
  <x>234</x>
  <y>303</y>
  <width>80</width>
  <height>25</height>
  <uuid>{302c2f66-32d0-49a4-8178-24865dfedde6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.053</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
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

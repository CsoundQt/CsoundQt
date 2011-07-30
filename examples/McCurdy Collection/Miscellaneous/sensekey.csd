;Written by Iain McCurdy, 2011


;Modified for QuteCsound by René, May 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add kkeydown output variable to sensekey opcode, if not it does not work !
	

;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 32		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 1		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gkMIDInote	init		60
giwave		ftgen	0,0,4096,10,1, 1/2, 0, 1/4, 0, 0, 1/8


instr	1	;SENSE KEYBOARD ACTIVITY AND START RECORD OR PLAYBACK INSTRUMENTS ACCORDINGLY
	kKey, kkeydown	sensekey									;SENSE ACTIVITY ON THE COMPUTER KEYBOARD

	if kkeydown == 1 then
		Smessage	sprintfk	"Key pressed. Code = %i", kKey
				outvalue	"data", Smessage
	elseif (kkeydown == 0 && kKey != -1) then
		Smessage	sprintfk	"Key released. Code = %i", kKey
				outvalue	"data", Smessage
	endif

	if		kKey=112	then									;IF ASCCI VALUE OF 112 IS OUTPUT, I.E. 'p' HAS BEEN PRESSED...
		event	"i", 2, 0, -1								;START INSTRUMENT 2
	elseif	kKey=115	then									;IF ASCII VALUE OF 115 IS OUTPUT, I.E. 's' HAS BEEN PRESSED...
		turnoff2	2,0,1									;STOP INSTRUMENT 2
	elseif	kKey=43	then									;IF ASCII VALUE OF 43 IS OUTPUT, I.E. '+' HAS BEEN PRESSED...
		gkMIDInote	limit	gkMIDInote + 1, 0, 127			;INCREMENT MIDI NOTE NUMBER UP ONE STEP (LIMIT RANGE TO BE BETWEEN ZERO AND 127)
	elseif	kKey=45	then									;IF ASCII VALUE OF 45 IS OUTPUT, I.E. '-' HAS BEEN PRESSED...
		gkMIDInote	limit	gkMIDInote - 1, 0, 127			;DECREMENT MIDI NOTE NUMBER DOWN ONE STEP (LIMIT RANGE TO BE BETWEEN ZERO AND 127)
	endif												;END OF CONDITIONAL BRANCH
endin

instr 2	;PLAYS A TONE
	aenv	linsegr	0,0.01,1,0.01,0
	a1	oscili	0.2*aenv, cpsmidinn(gkMIDInote), giwave
		out		a1
endin
</CsInstruments>
<CsScore>
i 1 0 3600	;SENSES KEYBOARD ACTIVITY INSTRUMENT
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>941</x>
 <y>239</y>
 <width>417</width>
 <height>347</height>
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
  <width>412</width>
  <height>344</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>sensekey</label>
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
  <x>8</x>
  <y>105</y>
  <width>400</width>
  <height>233</height>
  <uuid>{a22504a1-aa44-46e3-9ff9-60d7e5c3b024}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>---------------------------------------------------------------------------------------------------
This example demonstrates the sensekey opcode which senses key presses on the computer's keyboard and outputs the decimal value. To be able to use key presses we will need to know their decimal values. These can be found on line in an ASCII table (http://www.asciitable.com/) or by using this example.
Note that the Widgets window will need to be in focus for key presses to be sensed.
sensekey follows each key press value with a '-1', but key press values are reiterated according to repeat-key settings in QuteCsound configuration.
Each reiteration is again followed with a '-1'.
sensekey is case sensitive.</label>
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
  <x>8</x>
  <y>34</y>
  <width>400</width>
  <height>25</height>
  <uuid>{6f0e0438-b1dd-4f4d-b357-6580db16bd7a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Press 'p' to play, 's' to stop, '+' to raise pitch, '-' to lower pitch.</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>data</objectName>
  <x>8</x>
  <y>64</y>
  <width>400</width>
  <height>40</height>
  <uuid>{d9e70b9e-4de4-401c-b0bd-9f0d5d0b0a5e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Key released. Code = 115</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>15</fontsize>
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
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

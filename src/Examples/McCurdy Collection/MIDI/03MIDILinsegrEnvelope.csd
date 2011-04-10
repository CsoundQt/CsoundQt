;Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add scope for fun

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

	icps		cpsmidi
	iamp		ampmidi	0.2
	
	; linsegr IS USED TO CREATE AN ADSR STYLE ENVELOPE
	; ATTACK LEVEL IS HIGHER THAN SUSTAIN LEVEL GIVING THE NOTE A HARD ATTACK
	;               INITIAL_LEVEL | ATTACK_TIME | ATTACK_LEVEL | DECAY_TIME | SUSTAIN_LEVEL |  RELEASE_TIME | RELEASE_LEVEL
	aenv		linsegr	0,           (.01),          1,           (.1),          .5,            (.5),            0 

	;OUTPUT	OPCODE	AMPLITUDE | FREQUENCY | FUNCTION_TABLE
	asig		oscili	iamp*aenv,      icps,        1
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
 <x>757</x>
 <y>523</y>
 <width>642</width>
 <height>385</height>
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
  <width>639</width>
  <height>377</height>
  <uuid>{c37e13f6-7642-465f-9b2a-f059eef7bce8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>linsegr (expsegr) - envelopes with MIDI release stages </label>
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
  <label>-----------------------------------------------------------------------------------------------------------------------------------------------------------
We can still use the traditional envelope generating opcodes line/expon/linseg/expseg in MIDI activated instruments but the popular practise of employing 'p3' (note duration derived from the score) within the formation of an envelope, in order to make that envelope's segment durations at least partially dependent upon note duration, will not be possible as Csound will not know note duration until a MIDI note-off is received. The opcodes 'linsegr' (for straight line segments) and 'expsegr' (for exponential segments) will hold their penultimate break-point value until a MIDI note off is received at which point the final segment will proceed. The final three arguments in a linsegr/expsegr can, from the perspective of a playable instrument, be regarded as 'sustain time', 'release time' and 'release level'. On with expon and expseg, values of zero are illegal with expsegr - values close to zero can be used instead. Where the user desires to modify envelope parameters in this example the code should for the linsegr line can be modified. Some of the more developed MIDI examples in this catalogue include MIDI envelopes where the user can modify the times and values of the envelopes using widgets. The maximum allowed value for the release time is 32768/kr. Exceeding this limit will cause the envelope to not function properly. More information on this opcode is given in the actual code of this example.</label>
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
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>7</x>
  <y>298</y>
  <width>629</width>
  <height>73</height>
  <uuid>{78831f8c-abab-4c29-be2b-6207912c4285}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>4.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

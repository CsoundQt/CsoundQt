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
ksmps	= 2		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


instr	1	; SIMPLE BEEP INSTRUMENT - CAN BE ACTIVATED VIA A CONNECTED MIDI KEYBOARD
	
	;OUTPUT	OPCODE	CHANNEL | CTRLNUMBER | MINIMUM | MAXIMUM
	koct1	ctrl7	1,            1,          8,        9 	;READ CONTROLLER INFORMATION FROM CONTINUOUS CONTROLLER NUMBER 1 ON MIDI CHANNEL 1 AND RESCALE TO BE WITHIN THE RANGE 8 - 9. BOTH CTRL7S REFERENCE THE SAME MIDI CONTROLLER
	koct2	ctrl7	1,            1,          8,        7 	;READ CONTROLLER INFORMATION FROM CONTINUOUS CONTROLLER NUMBER 1 ON MIDI CHANNEL 1 AND RESCALE TO BE WITHIN THE RANGE 8 - 7. BOTH CTRL7S REFERENCE THE SAME MIDI CONTROLLER
	
	;OUTPUT	OPCODE	AMPLITUDE |  FREQUENCY   | F.N.
	asig1	oscili	0.25,      cpsoct(koct1),   1			;TWO OSCILLATORS ARE CREATED WITH DIFFERENT FREQUENCIES - FREQUENCY VARIABLES MUST BE CONVERTED INTO CPS FORMAT FROM OCT FORMAT
	asig2	oscili	0.25,      cpsoct(koct2),   1			;TWO OSCILLATORS ARE CREATED WITH DIFFERENT FREQUENCIES - FREQUENCY VARIABLES MUST BE CONVERTED INTO CPS FORMAT FROM OCT FORMAT
	
			outs		(asig1 + asig2), (asig1 + asig2)		;THE TWO OSCILLATORS ARE MIXED AND SENT TO THE OUTPUT
endin
</CsInstruments>
<CsScore>
f 1 0 129 10 1		; SINE WAVE
i 1 0 3600		; INSTRUMENT 1 PLAYS A NOTE FOR 1 HOUR
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1172</x>
 <y>505</y>
 <width>498</width>
 <height>298</height>
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
  <width>492</width>
  <height>292</height>
  <uuid>{c37e13f6-7642-465f-9b2a-f059eef7bce8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>A Single MIDI controller creates two Csound variables</label>
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
  <y>25</y>
  <width>484</width>
  <height>170</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------------------------------------
Move controller 1 on MIDI channel 1 or the modulation wheel on a MIDI keyboard set to channel 1. There is nothing to prevent you from using several instances of ctrl7 which reference the same MIDI controller. In this example the frequencies of two different oscillators are both driven by MIDI controller 1 on MIDI channel 1. The ranges of the two ctrl7s outputs are different however. As controller 1 is moved from minimum to maximum the pitch of oscillator 1 moves from C4 up to C5 but the pitch of oscillator 2 move from C4 down to C3.</label>
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
  <x>8</x>
  <y>193</y>
  <width>480</width>
  <height>94</height>
  <uuid>{eae32263-3d06-4f56-8de0-7386f6c41439}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

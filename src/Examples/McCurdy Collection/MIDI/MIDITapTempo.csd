;Writen by Iain McCurdy, 2008

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:


;my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)


gkTime		init	1	;INITIALISE VARIABLE FOR TIME GAP BETWEEN KEY PRESSES
gkDlyTim		init	1	;INITIALISE DELAY TIME VARIABLE USED IN THE DELAY EFFECT IN INSTR 4


instr	1	;MIDI TRIGGERED INSTRUMENT - RECEIVES 'TAPS'
			event_i		"i", p1+2, 0, 0.001, i(gkTime)			;TRIGGER TEMPO CALCULATING INSTRUMENT
			event_i		"i", p1+1, 0, -1						;START 'TIMER' INSTRUMENT (-1 DURATION INDICATES A MONPHONIC HELD NOTE)
			outvalue		"Delay_Time", i(gkDlyTim)				;SEND CURRENT DELAY TIME VALUE TO THE ON-SCREEN VALUATOR BOX
			turnoff											;TURNOFF THIS INSTRUMENT IMMEDIATELY
endin

instr	2	;TIMER TO MEASURE TIME GAP BETWEEN KEY PRESSES
	gkTime	timeinsts											;timeinsts OUTPUTS THE TIME SINCE THE START OF THE THIS NOTE BEING TRIGGERED
endin

instr	3	;CALCULATE CURRENT TEMPO BASED ON TIME GAP BETWEEN THE LAST TWO KEY PRESSES
	gkDlyTim	init	p4											;SET DELAY TIME (FOR DELAY EFFECT IN INSTR 4) TO CURRENT TIME GAP VALUE
	iTempo	=	60/p4										;DERIVE TEMPO FROM TIME GAP
			outvalue		"Tempo", iTempo						;SEND CURRENT DELAY TIME VALUE TO THE ON-SCREEN VALUATOR BOX
endin

instr	4	;DELAY INSTRUMENT - TAKES LIVE AUDIO IN AS ITS INPUT
	iMaxDlyTim	init		10									;INITIALISE VARIABLE FOR MAXIMUM DELAY TIME
	kDlyTim		limit	gkDlyTim, 0.001, iMaxDlyTim				;LIMIT DELAY TIME TO PREVENT CRASHES

	ain1			inch		1									;READ AUDIO FROM LIVE INPUT CHANNEL 1
	aFeedback		init		0									;INITIALISE FEEDBACK SIGNAL FOR FIRST k PASS
	aBuffer		delayr	iMaxDlyTim							;DEFINE AUDIO BUFFER FOR DELAY
	aTap			deltap3	kDlyTim								;READ AUDIO FROM A DELAY TAP FROM WITHIN THIS BUFFER
				delayw	ain1+(aFeedback)						;WRITE AUDIO INTO THE DELAY BUFFER (MIXTURE OF LIVE IN AND FEEDBACK LOOP)
	aFeedback		=		aTap*.5								;DEFINE THE AUDIO FEEDBACK SIGNAL FOR THE NEXT k PASS
				outs		(aTap+ain1)*.5, (aTap+ain1)*.5			;SEND AUDIO TO OUTPUTS (AND ATTENUATE)
endin
</CsInstruments>
<CsScore>
i 1 0 0.001	;INSTR 1 (SHORT NOTE)
i 4 0 3600	;INSTR 4 (DELAY) PLAYS FOR 1 HOUR 
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>915</x>
 <y>239</y>
 <width>519</width>
 <height>225</height>
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
  <width>513</width>
  <height>217</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI Tap Tempo</label>
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
  <y>28</y>
  <width>506</width>
  <height>125</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------------
The example demonstrate a method for defining a tempo by tapping notes on a MIDI keyboard. The time difference between consecutive MIDI note-ons is recorded and used to derive a tempo value. In this example this value is used to define the delay time of a simple delay effect that is applied to the live audio input of the computer.</label>
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
  <x>6</x>
  <y>153</y>
  <width>505</width>
  <height>60</height>
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
  <x>217</x>
  <y>166</y>
  <width>93</width>
  <height>30</height>
  <uuid>{a3c622cc-d6a0-4f7c-b9b8-5179d6261036}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Time</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>18</x>
  <y>166</y>
  <width>93</width>
  <height>30</height>
  <uuid>{830ca56f-fafc-4c8c-b8b0-8ac877fd49ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tempo</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Tempo</objectName>
  <x>110</x>
  <y>166</y>
  <width>80</width>
  <height>30</height>
  <uuid>{0c475a5a-d0aa-4fcd-9caa-a95cbaf1ad9d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>60.000</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Delay_Time</objectName>
  <x>309</x>
  <y>166</y>
  <width>80</width>
  <height>30</height>
  <uuid>{d39e4f0b-318a-4a5b-b29d-5972c1cf8789}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>left</alignment>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

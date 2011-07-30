;Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add kvolume display


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
	icps		cpsmidi
	iamp		ampmidi 0.2 
	
	;OUTPUT	OPCODE	CHANNEL | CTRLNUMBER | MINIMUM | MAXIMUM
	kvolume	ctrl7	1,            1,          0,        1 	;READ CONTROLLER INFORMATION FROM CONTINUOUS CONTROLLER NUMBER 1 ON MIDI CHANNEL 1 AND RESCALE TO BE WITHIN THE RANGE 0 - 1 
	
			outvalue	"ctrl1", kvolume
	
	;    	           INITIAL_LEVEL | ATTACK_TIME | ATTACK_LEVEL | DECAY_TIME | SUSTAIN_LEVEL |  RELEASE_TIME | RELEASE_LEVEL
	aenv		linsegr	      0,           (.01),          1,           (.1),          .7,            (.05),            0 
	
	asig		oscili	iamp,icps, 1
			outs		asig * aenv * kvolume, asig * aenv * kvolume
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
 <x>617</x>
 <y>498</y>
 <width>766</width>
 <height>375</height>
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
  <width>760</width>
  <height>369</height>
  <uuid>{c37e13f6-7642-465f-9b2a-f059eef7bce8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ctrl7 - Reading Continuous Controller Data into Csound</label>
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
  <width>750</width>
  <height>289</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Ctrl7 is the best opcode to use for reading continuous controller data into csound for use as k-rate variables. Ctrl7 allows the user to specify the MIDI channel (1-16) and the controller number (0-127) associated with the controller. Therefore with 128 controllers on 16 different MIDI channels we have the possibility of using 2048 different MIDI controls! 7 bit MIDI controllers normally output integers within the range 0-127 but with ctrl7 we can rescale this by specifying a different output range. In this example MIDI controller 1 on MIDI channel 1 is used to implement a volume control on the simple synthesizer that has been built up over last few examples. (The modulation wheel on MIDI keyboards is also MIDI controller 1) The first thing that is noticed is that this example is silent until you move controller 1. This is because a controller always defaults to its minimum value until the controller is moved. The next example demonstrates how this can be initialised to a value other than the minimum. Another thing that you may notice is that when moving the controller is that a clicking noise (sometimes referred to as 'zipper' noise) can be heard, particularly when the controller is moved quickly. What is happening is that the k-rate output of ctrl7 is changing in large steps rather than in a continuously smooth line. If the control rate (kr) is low then this can aggrevate the problem. Another factor is that the resolution of 7 bit controllers is quite low (128 possible values). One solution is to use a 14 bit controller and the ctrl14 opcode but there are very few MIDI controller devices that provide adequate 14 bit controller support. Another possibility is to interpolate ctrl7's output up to a-rate (ctrl7 can only output at k-rate). Applying portamento to the output variable can help - this method is demonstrated in subsequent examples.</label>
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
  <y>315</y>
  <width>188</width>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ctrl1</objectName>
  <x>91</x>
  <y>327</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f8119d82-f052-4a86-8790-440c42c5d41d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.087</label>
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
  <x>19</x>
  <y>324</y>
  <width>73</width>
  <height>31</height>
  <uuid>{4dc3e62f-8cd7-48cb-8f7f-25878ba3b97e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>kvolume:</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

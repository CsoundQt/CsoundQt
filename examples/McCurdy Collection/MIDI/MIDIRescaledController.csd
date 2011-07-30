;Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add koct display


;my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>
 
</CsOptions>    
<CsInstruments>
sr		= 44100	;SAMPLE RATE
ksmps	= 2		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


instr	1	;BEEP INSTRUMENT - ACTIVATED BY A SCORE NOTE - FREQUENCY VARIABLE USING CONTROLLER 1
	
	;OUTPUT	OPCODE	CHANNEL | CTRLNUMBER | MINIMUM | MAXIMUM | F.N._USED_TO_RESCALE_SLIDER_VALUES
	koct		ctrl7	1,            1,          0,        1,      2 					;READ CONTROLLER INFORMATION FROM CONTINUOUS CONTROLLER NUMBER 1 ON MIDI CHANNEL 1, RESCALE TO BE WITHIN THE RANGE 0 - 1 THEN RESCALE AGAIN ACCORDING TO FUNCTION TABLE NO. 2
	
			outvalue	"ctrl1", koct
	
	;OUTPUT	OPCODE	AMPLITUDE |    FREQ.    | F.N.
	asig		oscili	0.2,       cpsoct(koct),   1									;FREQUENCY IS CONVERTED FROM 'OCT' FORMAT INTO 'CPS' (CYCLES PER SECOND) FORMAT AS OSCILI EXPECTS	
			outs		asig, asig												;SEND AUDIO SIGNAL TO THE OUTPUTS
endin
</CsInstruments>
<CsScore>
f 1 0 129 10 1			;SINE WAVE
f 2 0 129 -7 8 64 9 64 7	;RESCALING FUNCTION (NOTE: UN-NORMALIZED FUNCTION - THE USE OF A MINUS SIGN IN THE GEN ROUTINE NUMBER). REFER TO CSOUND MANUAL REGARDING GEN 07 FOR MORE INFORMATION
i 1 0 3600			;INSTRUMENT 1 PLAYS A NOTE FOR 1 HOUR
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>791</x>
 <y>321</y>
 <width>585</width>
 <height>373</height>
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
  <width>578</width>
  <height>368</height>
  <uuid>{c37e13f6-7642-465f-9b2a-f059eef7bce8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rescaling a ctrl7 derived variable using a function table</label>
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
  <width>569</width>
  <height>291</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------------------------
Move controller 1 on MIDI channel 1 (or the modulation wheel on a keyboard set to channel 1). This pitch of the oscillator rises up one octave and then falls by two octaves. Ctrl7 includes an optional argument which can be used to reference a function table which will be used to rescale the range of values already defined for the controller derived varable. This feature can be used to create a non-linear mapping of values as the controller is moved. In this example a function table has been created using GEN 7 (straight line segments) as follows:
;________GEN_VAL_DUR_VAL_DUR_VAL
f_2_129___-7____8___64____9___64___7

A minus sign is placed in front of the the GEN routine number to ensure that the values will not be normalised. When the controller is rescaled using this table its output will rise from 8 to 9 for the first half of the controller's movement at which point it will change direction and descend to a final value of 7. These values are used as 'oct' format values for the oscillators frequency paramenter. Another common use of this feature is to remap logarithmic parameters such as frequency so that the MIDI slider controlling them give a more useful response.</label>
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
  <label>8.000</label>
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
  <label>koct:</label>
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

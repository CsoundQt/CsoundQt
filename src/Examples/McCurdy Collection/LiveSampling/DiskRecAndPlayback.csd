;Written by Iain McCurdy, 2008

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Use wav header
;	Pause change to avoid high cpu load


;my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 --expression-opt -+rtmidi=null
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 256	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)


gkrecdur		init	0
gkplaydur		init 0

instr	1	;GUI
 	gkPause	invalue	"Pause"
 	kPlay	invalue	"Play"
 	kPlayOn	trigger	kPlay, 0.5, 0
 			chnset	kPlayOn, "PlayOn"
	kInstr2	active	2
	kInstr3	active	3

	if kPlayOn = 1 && kInstr2 = 0 && kInstr3 = 0 then
		event	"i", 2, 0, 3600				;start playback for one hour maximum
	endif

			outvalue	"RecDur", gkrecdur
			outvalue	"PlayDur", gkplaydur
endin

instr	2	;PLAYBACK
	if	gkPause = 1	then							;IF PAUSE BUTTON IS ACTIVATED... 
		kgoto	END								;GOTO 'END' LABEL
	endif										;END OF CONDITIONAL BRANCHING
	
	asig	diskin2	"32BitRecording.wav", 1
		outs		asig, asig						;SEND AUDIO TO OUTPUTS

 	kPlayOn	chnget	"PlayOn"	
	kPlay_Led	invalue	"Play_Led"

	gkplaydur	line		0,1,1

	
	if	(gkplaydur >= gkrecdur) || (kPlayOn == 1 && kPlay_Led == 1) 	then		;IF END OF RECORDING IS REACHED...
		outvalue	"Play_Led", 0						;...DEACTIVATE PLAY BUTTON LED &
		turnoff									;TURN OFF THIS INSTRUMENT IMMEDIATELY.
	else
		outvalue	"Play_Led", 1						;...ACTIVATE PLAY BUTTON LED &
	endif										;END OF CONDITIONAL BRANCHING
	END:
endin

instr	3	;RECORD
	if	gkPause = 1	then							;IF PAUSE BUTTON IS ACTIVATED...
		kgoto	END								;GOTO 'END' LABEL
	endif										;END OF CONDITIONAL BRANCHING
	
	ain		inch		1							;READ AUDIO FROM LIVE INPUT CHANNEL 1
			fout		"32BitRecording.wav", 16, ain
	gkrecdur	line		0,1,1						;record duration

	END:
endin
</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>598</x>
 <y>247</y>
 <width>477</width>
 <height>379</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>202</r>
  <g>202</g>
  <b>202</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>475</width>
  <height>370</height>
  <uuid>{395a9956-93f5-441f-b0ef-3828f1b2da1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Record Audio to Disk With Playback (Once)</label>
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
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>140</y>
  <width>471</width>
  <height>239</height>
  <uuid>{63943056-81b7-4daa-acef-5ee3932bad61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------
When it is required to record long sections of audio for playback or for storage for later retrieval, then recording to function tables will not be sufficient.
In this situation it is necessary to record audio to the computers hard disk (function table are merely stored temporarily in RAM).
In this example recording audio to disk is implemented using the fout opcode. Playback is implemented using the diskin2 opcode.
Playback will play the entire recording back once (unless playback is deactivated).
The recording will be stored as '32BitRecording.wav' in the default location for file output storage.
In this example file format is 32 bit floats at 44100. Care always needs to be taken that file storage format and playback format correspond.</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>62</x>
  <y>44</y>
  <width>100</width>
  <height>30</height>
  <uuid>{0a44e1b8-fab4-40c8-8fa1-f1d1d743c45c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     Record </text>
  <image>/</image>
  <eventLine>i 3 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Pause</objectName>
  <x>182</x>
  <y>44</y>
  <width>100</width>
  <height>30</height>
  <uuid>{d25d9765-65f0-40fa-87b8-30ba88ad9bd2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     Pause  </text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Play</objectName>
  <x>302</x>
  <y>44</y>
  <width>100</width>
  <height>30</height>
  <uuid>{7924627d-9546-4acd-91a0-41c8282cf300}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>       Play  </text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>312</x>
  <y>54</y>
  <width>10</width>
  <height>10</height>
  <uuid>{2c1634b2-9b4f-4c8e-a392-f4bcdc4aa4eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Play_Led</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>RecDur</objectName>
  <x>221</x>
  <y>94</y>
  <width>60</width>
  <height>25</height>
  <uuid>{f4a5dac8-b31b-4480-bd5c-73d3e5228c38}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.516</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>86</x>
  <y>94</y>
  <width>135</width>
  <height>25</height>
  <uuid>{c3e4f957-74ef-427b-8d53-37abaf75a236}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Record Duration (sec)</label>
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
  <objectName>PlayDur</objectName>
  <x>221</x>
  <y>120</y>
  <width>60</width>
  <height>25</height>
  <uuid>{4cf51312-2ac5-4893-8f13-48eb831ca14f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.516</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>86</x>
  <y>120</y>
  <width>135</width>
  <height>25</height>
  <uuid>{99de1d28-1025-42ff-9d47-de31d15793ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Play Duration (sec)</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

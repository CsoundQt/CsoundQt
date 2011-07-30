;Writen by Iain McCurdy, 2008

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add instr	6 for bar display


;my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 10		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine		ftgen	0,0,65537,10,1		;A SINE WAVE

giSubDiv		=	1000					;SUBDIVISION OF THE BEAT (ESSENTIALLY THIS WILL DETERMINE THE PRECISION OF THE QUANTIZING EFFECT
gkTempoClock	init	0					;INITIALISE VARIABLE FOR MAIN CLOCK	

			;maxalloc	4,1				;POLYPHONY CONTROL FOR THE SOUND PREODUCING INSTRUMENT


instr	10	;GUI
	gkLiveQuantize		invalue		"On_Off"	;lance i2
		kB_ON		trigger		gkLiveQuantize, 0.5, 0
					schedkwhen	kB_ON, 0, 0, 2, 0, -1	;Start instr

	gkTempo			invalue		"Tempo"
	gkNoteVal			invalue		"Beat"
	gkMetroGain		invalue		"Metronone"
endin

instr	1	;MIDI TRIGGERED INSTRUMENT
	icps		cpsmidi
	iamp		veloc	0,0.2
	idelay	=		frac(i(gkTempoClock))
	idelay	=		(1-idelay)*(60/(i(gkTempo)*i(gkNoteVal)))
			event_i	"i", p1+3, idelay, 1, icps, iamp
endin

instr	2	;TURNS ON THE QUANTIZER
	gkTempoClock	init		0					;INITIALISE VARIABLE FOR MAIN CLOCK	
	if	gkLiveQuantize!=0	goto	CONTINUE
		turnoff

	CONTINUE:
	kTrigger		metro		(gkTempo*giSubDiv*gkNoteVal)/60
				schedkwhen	kTrigger, 0, 0, p1+1, 0, 0.001

	kMetronome	metro		gkTempo/240
	kbeat		=			240/gkTempo
				schedkwhen	kMetronome, 0, 0, 5, 0,         .05, 600, 0
				schedkwhen	kMetronome, 0, 0, 5, kbeat*.25, .05, 300, 1
				schedkwhen	kMetronome, 0, 0, 5, kbeat*.50, .05, 300, 2
				schedkwhen	kMetronome, 0, 0, 5, kbeat*.75, .05, 300, 3	
endin

instr	3	;INCREMENT THE CLOCK BY 1 SUBDIVISION
	kTempoClock	=	gkTempoClock + (1/giSubDiv)
	gkTempoClock	=	kTempoClock
				turnoff	
endin

instr	4	;SOUND PRODUCING INSTRUMENT
	aenv		expseg	0.0001, 0.01, 1, p3-0.01, 0.0001
	a1		oscili	aenv*p5, p4, gisine
			outs		a1, a1
endin

instr	5	;METRONOME SOUND GENERATOR
	if	gkLiveQuantize=0	then
		turnoff
	endif

	aenv		linseg		0, 0.001,1, p3-0.001,0
	asig		oscili		0.2*aenv*i(gkMetroGain), p4, gisine
			outs			asig, asig

			schedkwhen	1, 0, 0, 6, 0, 0, p5 	;START (ONLY INIT) BAR DISPLAY INSTR
endin

instr	6	;BAR DISPLAY
	;All leds OFF
	outvalue	"Bar1", 0
	outvalue	"Bar2", 0
	outvalue	"Bar3", 0
	outvalue	"Bar4", 0

	;One led ON
	if p4 = 0 igoto BAR1
	if p4 = 1 igoto BAR2
	if p4 = 2 igoto BAR3
	if p4 = 3 igoto BAR4	
	
	BAR1:
	outvalue	"Bar1", 1
	igoto END
	BAR2:
	outvalue	"Bar2", 1
	igoto END
	BAR3:
	outvalue	"Bar3", 1
	igoto END
	BAR4:
	outvalue	"Bar4", 1
	igoto END
	END:
endin
</CsInstruments>
<CsScore>
i 10 0 3600	;GUI - REAL TIME PERFORMANCE FOR 1 HOUR
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>924</x>
 <y>199</y>
 <width>522</width>
 <height>377</height>
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
  <width>516</width>
  <height>371</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Live Quantize</label>
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
  <x>7</x>
  <y>21</y>
  <width>505</width>
  <height>240</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------------
This example quantizes an incoming stream of MIDI notes according to an internal metronone. If a MIDI note-on is received the orchestra calculates how much time will elapse until the next beat and then delays the onset of the note by that amount. To provide the user with the frame of reference used by the orchestra, a metronome sounds the beats of a 4/4 bar as well as this being indicated visually with flashing dots. 'Beat Subdiv' defines how the quantizing grid relates to the beats outlined by the metronome. Giving this a value of '1' will cause each note-on to be moved to the next beat, giving it a value of '4' will cause it to move each note-on to the next quarter of a beat. Note onset delay is implemented by passing the duty of sounding the note onto another instrument through the 'schedkwhen' opcode. The 'start time' of the scheduled note is given the value of the derived delay time.</label>
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
  <x>7</x>
  <y>263</y>
  <width>505</width>
  <height>101</height>
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
  <x>10</x>
  <y>331</y>
  <width>180</width>
  <height>30</height>
  <uuid>{2e52a7a7-dc13-405e-896d-db2a7431d8dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Metronone Volume</label>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Metronone</objectName>
  <x>10</x>
  <y>313</y>
  <width>500</width>
  <height>26</height>
  <uuid>{6ab84e0f-82a7-4b9c-af23-35bd7d9b7fa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Metronone</objectName>
  <x>450</x>
  <y>331</y>
  <width>60</width>
  <height>30</height>
  <uuid>{99d6bf8b-3c85-4911-a29a-7dd678a940ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>175</x>
  <y>272</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d8448b52-b521-4a49-93f8-727644a5f9e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <maximum>999</maximum>
  <randomizable group="0">false</randomizable>
  <value>70</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Beat</objectName>
  <x>327</x>
  <y>272</y>
  <width>50</width>
  <height>30</height>
  <uuid>{7d9dfc10-dd27-4831-95ce-0f75db398265}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <maximum>4</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>111</x>
  <y>272</y>
  <width>64</width>
  <height>30</height>
  <uuid>{a3c622cc-d6a0-4f7c-b9b8-5179d6261036}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>235</x>
  <y>272</y>
  <width>93</width>
  <height>30</height>
  <uuid>{830ca56f-fafc-4c8c-b8b0-8ac877fd49ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Beat Subdiv.</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>On_Off</objectName>
  <x>11</x>
  <y>272</y>
  <width>100</width>
  <height>30</height>
  <uuid>{cee5f52d-8107-43c3-b3b3-e8d391cff31f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>      On/Off </text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>474</x>
  <y>281</y>
  <width>10</width>
  <height>10</height>
  <uuid>{ce49eac8-f6fc-4641-9137-14703a625ada}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Bar4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>1.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>434</x>
  <y>281</y>
  <width>10</width>
  <height>10</height>
  <uuid>{2eb9cd3b-090b-40ae-92a3-f692e680f6e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Bar2</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>454</x>
  <y>281</y>
  <width>10</width>
  <height>10</height>
  <uuid>{7e14a3fd-0993-4a44-b46f-f1ebd1347718}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Bar3</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>414</x>
  <y>281</y>
  <width>10</width>
  <height>10</height>
  <uuid>{752e89e5-4151-468a-9cfd-e5dc4a042af0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Bar1</objectName2>
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
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

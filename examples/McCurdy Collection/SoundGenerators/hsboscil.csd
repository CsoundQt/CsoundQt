;Written by Iain McCurdy, 2009


;Modified for QuteCsound by René, April 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Use QuteCsound internal midi interface for Brightness (Channel 1, CC#1)
;	Removed instr 2


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 16			;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


giwfn	ftgen	0, 0, 131072, 10, 1					;A SINE WAVE
gioctfn	ftgen	0, 0, 1024, -19, 1, 0.5, 270, 0.5		;A HANNING-TYPE WINDOW


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkoctcnt		invalue	"BlendRange"
		gkShepFreq	invalue	"Rate"
		gkamp		invalue	"Amplitude"
		gktone		invalue	"Tone"
		gkbrite		invalue	"Brightness"
		gkbasfreq		invalue	"Frequency"
		gkphs		invalue	"Phase"
		gkMIDI		invalue	"MIDI"
	endif
endin

instr	1	;MIDI ACTIVATED HSBOSCIL INSTRUMENT
	if	gkMIDI!=1	then												;IF SWITCH BANK IS *NOT* 1 THEN...
		turnoff													;TURN THIS INSTRUMENT OFF
	endif														;END OF CONDITIONAL BRANCHING

	iporttime		=		0.1										;PORTAMENTO TIME (CONSTANT) 
	kporttime		linseg	0,0.001,iporttime,1,iporttime					;PORTAMENTO TIME (AN ENVELOPE FUNCTION THAT RAMPS UP FROM ZERO) 
	kamp			portk	gkamp, kporttime							;APPLY PORTAMENTO
	kbrite		portk	gkbrite, kporttime 							;APPLY PORTAMENTO
	ktone		portk	gktone, kporttime							;APPLY PORTAMENTO
	ibasfreq		cpsmidi											;READ MIDI NOTE VALUES (IN HERTZ/CPS) FROM MIDI INPUT

				outvalue	"Frequency", ibasfreq						;SEND MIDI NOTE VALUES TO 'BASE FREQUENCY' SLIDER
	
	kSwitch		changed	gkoctcnt, gkphs							;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then
		reinit	START
	endif
	START:
	ares 		hsboscil	kamp, ktone, kbrite, ibasfreq, giwfn, gioctfn, i(gkoctcnt), i(gkphs)			;CREATE AN hsboscil TONE
				rireturn
	aenv			linsegr	0,0.01,1,3600,1,0.01,0						;CREATE A BASIC ENVELOPE TO PREVENT CLICKS AT THE START AND ENDS OF NOTES
				outs		ares*aenv, ares*aenv						;SEND AUDIO TO OUTPUTS, APPLY ENVELOPE
endin
	
instr	3	;HSBOSCIL INSTRUMENT - SLIDER CONTROLS BASE FREQUENCY
	iporttime	=		0.1											;PORTAMENTO TIME (CONSTANT)                                    
	kporttime	linseg	0,0.001,iporttime,1,iporttime 					;PORTAMENTO TIME (AN ENVELOPE FUNCTION THAT RAMPS UP FROM ZERO)
	kamp		portk	gkamp, kporttime								;APPLY PORTAMENTO
	kbrite	portk	gkbrite, kporttime								;APPLY PORTAMENTO
	ktone	portk	gktone, kporttime								;APPLY PORTAMENTO
	aenv		linsegr	0,0.001,1,3600,1,0.01,0							;CREATE A BASIC ENVELOPE TO PREVENT CLICKS AT THE START AND ENDS OF NOTES
	kSwitch	changed	gkbasfreq, gkoctcnt, gkphs						;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)

	if	kSwitch=1	then
		reinit	START
	endif
	START:
	ares 	hsboscil	kamp, ktone, kbrite, i(gkbasfreq), giwfn, gioctfn, i(gkoctcnt), i(gkphs)	;CREATE AN hsboscil TONE
			rireturn
			outs		ares*aenv, ares*aenv							;SEND AUDIO TO OUTPUTS, APPLY ENVELOPE
endin

instr	4	;HSBOSCIL INSTRUMENT - SHEPARD GLISSANDO 
	iporttime	=		0.1											;PORTAMENTO TIME (CONSTANT)                                    
	kporttime	linseg	0,0.001,iporttime,1,iporttime						;PORTAMENTO TIME (AN ENVELOPE FUNCTION THAT RAMPS UP FROM ZERO)
	kamp		portk	gkamp, kporttime								;APPLY PORTAMENTO                                              
	kbrite	portk	gkbrite, kporttime 							     ;APPLY PORTAMENTO                                              
	ktone	phasor	gkShepFreq       								;CREATE A MOVING PHASE VALUE THAT WILL BE USED TO MODULATE 'TONE' PARAMETER                                              

	ktrigger	metro	10											;CREATE A METRONIC PULSE OF '1' VALUES. 50 PER SECOND
	if ktrigger==1 then
			outvalue	"Tone", ktone									;UPDATE 'TONE; SLIDER (THIS WILL BE FOR VISUAL FEEDBACK ONLY)
	endif

	aenv		linsegr	0,0.001,1,3600,1,0.01,0							;CREATE A BASIC ENVELOPE TO PREVENT CLICKS AT THE START AND ENDS OF NOTES
	kSwitch	changed	gkbasfreq, gkoctcnt, gkphs						;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then
		reinit	START
	endif
	START:
	ares 	hsboscil	kamp, ktone, kbrite, i(gkbasfreq), giwfn, gioctfn, i(gkoctcnt), i(gkphs)	;CREATE AN hsboscil TONE
			rireturn
			outs		ares * aenv, ares * aenv							;SEND AUDIO TO OUTPUTS, APPLY ENVELOPE
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0.0	   3600	;GUI
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>617</x>
 <y>275</y>
 <width>1062</width>
 <height>405</height>
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
  <width>512</width>
  <height>400</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>hsboscil</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>129</y>
  <width>160</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Shepard Glissando Rate (Hz)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Rate</objectName>
  <x>448</x>
  <y>129</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <x>517</x>
  <y>2</y>
  <width>540</width>
  <height>400</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>hsboscil</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>17</y>
  <width>533</width>
  <height>381</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------------------
hsboscil generates a tone composed of partials derived from a stack of octaves. 'Brightness' (gkbrite) controls the weighting of these partials: negative values favouring lower partials, positive values favouring higher partials. 'Blending Range' (ioctcnt) defines the number of partials in the tone. 'Tone' shifts partials up or down in parallel. At the same time the entire spectrum is enveloped according to a windowing function created in a function table. The range of this spectral window is dependent upon the value given for 'Blending Range'. If 'Tone' is modulated such that partials disappear beyond the edge of spectral window they are replaced by new partials at the opposite edge of the window. It is this behaviour that allows us to create the Shepard glissando effect in which a tone appears to simultaneously be constantly rising (or falling) but never actually get any higher (lower) in pitch. A visual analogue is that of the spinning barber-pole. hsboscil's octave spaced partials tends to produce organ-like tones. This example offers three methods of activating hsboscil. Firstly, via MIDI (in which case 'Base Frequency' is determined by the MIDI note number with the 'Base Frequency' slider becoming inoperative). Secondly, without MIDI (slider becomes operative again) and thirdly, a method which produces the Shepard glissando effect by modulating the 'Tone' control using an LFO. In the original Roger Shepard experiment the tones moved stepwise. Jean-Claude Risset introduced the idea of the tone moving smoothly leading to the name Shepard Glissando or Shepard-Risset Glissando. In MIDI mode the modulation wheel can be used to control 'Brightness' This opcode was written by Peter Neubacker who is also the author of the Melodyne software.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Rate</objectName>
  <x>8</x>
  <y>113</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2a8dc6e2-12f4-443d-af9b-59e4373cc24b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>167</y>
  <width>150</width>
  <height>30</height>
  <uuid>{4fa545c6-e2f1-4387-8c9f-4a9dd388bb42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>167</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b0ad1916-b43e-44c2-be40-bca29f5cb1f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.342</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>151</y>
  <width>500</width>
  <height>27</height>
  <uuid>{9069e547-5638-4568-896f-980087c61de0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.34200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>284</x>
  <y>66</y>
  <width>169</width>
  <height>31</height>
  <uuid>{ada34c8d-83fe-4eae-b207-ac7e38c5251f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Blending Range (octaves) :</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>BlendRange</objectName>
  <x>455</x>
  <y>63</y>
  <width>50</width>
  <height>30</height>
  <uuid>{c37974b7-7a24-481d-8f02-a116324085e3}</uuid>
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
  <minimum>2</minimum>
  <maximum>10</maximum>
  <randomizable group="0">false</randomizable>
  <value>10</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>81</y>
  <width>180</width>
  <height>31</height>
  <uuid>{db9a7e63-ac06-40ee-b161-3012d7172005}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Shepard Glissando On / Off :</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <x>163</x>
  <y>85</y>
  <width>16</width>
  <height>16</height>
  <uuid>{326c4e41-c09d-41ac-98ea-9f603e424058}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 4 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>205</y>
  <width>150</width>
  <height>30</height>
  <uuid>{7db371e5-4bd3-46a9-a5e3-0aea92940a6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tone</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Tone</objectName>
  <x>448</x>
  <y>205</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2696e0c6-d92a-4577-9f7a-aef424e70a55}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.070</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Tone</objectName>
  <x>8</x>
  <y>189</y>
  <width>500</width>
  <height>27</height>
  <uuid>{c22c8f1f-06e2-4f93-90ef-76b20501e47f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.07002266</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>243</y>
  <width>150</width>
  <height>30</height>
  <uuid>{915965e7-61fd-429c-806c-afc107c02f1d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Brightness (CC#1)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Brightness</objectName>
  <x>448</x>
  <y>243</y>
  <width>60</width>
  <height>30</height>
  <uuid>{014166d8-823b-481c-b928-22acb9f85eab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Brightness</objectName>
  <x>8</x>
  <y>227</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2b177c6b-fa1d-4592-845b-18e86d7a09f5}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <minimum>-7.00000000</minimum>
  <maximum>7.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>281</y>
  <width>150</width>
  <height>30</height>
  <uuid>{53bda1d9-5ee4-4ca6-a933-8a57351bde90}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Base Frequency (i-rate)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Frequency</objectName>
  <x>448</x>
  <y>281</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6c54c71b-4092-4ae4-b3e5-8e48e0af32e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>146.828</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Frequency</objectName>
  <x>8</x>
  <y>265</y>
  <width>500</width>
  <height>27</height>
  <uuid>{11ece0ea-35e7-49e1-a8aa-1cf50108d494}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>20.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <value>146.82824707</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>319</y>
  <width>150</width>
  <height>30</height>
  <uuid>{8d94e0bf-d464-4f28-94b3-5883e7fd35a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Initial Phase (i-rate)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Phase</objectName>
  <x>448</x>
  <y>319</y>
  <width>60</width>
  <height>30</height>
  <uuid>{546ac0d3-b04a-4c3d-be2d-5705a566e35b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>Phase</objectName>
  <x>8</x>
  <y>303</y>
  <width>500</width>
  <height>27</height>
  <uuid>{075b6c1e-5c9b-4eb9-b058-2bf90b0e7ec8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>52</y>
  <width>180</width>
  <height>31</height>
  <uuid>{01f32bee-68b9-4ae4-9aef-1b14ea5ea216}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>HSBOSCIL Instr  On / Off :</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <x>163</x>
  <y>56</y>
  <width>16</width>
  <height>16</height>
  <uuid>{fac603b4-992a-4c52-9a5d-3dc031298ac1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 3 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>21</y>
  <width>180</width>
  <height>31</height>
  <uuid>{afe5727a-7833-4d95-a7fd-c8b2532b7d32}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI Instr  On / Off :</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
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
  <objectName>MIDI</objectName>
  <x>163</x>
  <y>25</y>
  <width>16</width>
  <height>16</height>
  <uuid>{feed3f3d-9dca-4f34-af94-60de6864a835}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

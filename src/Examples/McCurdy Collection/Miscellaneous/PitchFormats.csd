;Written by Iain McCurdy, 2010

;Modified for QuteCsound by René, February 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table for exp slider


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine	ftgen	0,0,4096,10,1
giExp1	ftgen	0, 0, 129, -25, 0, 8.176, 128, 12543.85		;TABLE FOR EXP SLIDER


instr	100	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gktone	invalue	"Tone"

		kcpsIP 	invalue	"cpsIP"
		gkcpsIP	tablei	kcpsIP, giExp1, 1

		gkcps	invalue	"i_cps"
		gkoct	invalue	"i_oct"
		gkpch	invalue	"i_pch"
		gknum	invalue	"i_MIDI"
	endif
endin

instr	1	;MIDI INPUT CONVERTED INTO FOUR FORMATS
	icps		cpsmidi						;READ IN MIDI AS CPS 
	ioct		octmidi						;READ IN MIDI AS OCT FORMAT
	ipch		pchmidi						;READ IN MIDI AS PCH FORMAT
	inum		notnum						;READ IN MIDI AS NOTE NUMBER 

			outvalue	"i_cps",  icps			;SEND CPS VALUE TO CPS TEXT BOX
			outvalue	"i_oct",  ioct			;SEND OCT VALUE TO CPS TEXT BOX
			outvalue	"i_pch",  ipch			;SEND PCH VALUE TO CPS TEXT BOX
			outvalue	"i_MIDI", inum			;SEND NOTE NUMBER VALUE TO CPS TEXT BOX
endin

instr	2	;PRINT SLIDER CHANGES TO VALUE BOXES
	koct		=	octcps(gkcpsIP)					;CONVERT SLIDER VALUE FROM CPS TO OCT

			outvalue	"d_cps", gkcpsIP				;SEND CPS VALUE TO CPS TEXT BOX
			outvalue	"d_oct", koct					;SEND OCT TO OCT VALUE BOX
			outvalue 	"d_pch", pchoct(koct)			;SEND PCH TO PCH VALUE BOX
			outvalue 	"d_MIDI", (koct-3)*12			;CONVERT OCT TO MIDI NUMBER USING MATHS AND SEND TO MIDI NOTE NUMBER VALUE BOX
endin

instr	3	;SEND CPS BOX VALUE TO THE OTHER 3 BOXES
	ioct		init	octcps(i(gkcps))					;DERIVE OCT FORMAT VALUE FROM CPS

			outvalue	"i_oct", ioct					;SEND OCT VALUE TO OCT BOX
			outvalue	"i_pch", pchoct(ioct)			;CONVERT OCT TO PCH AND SEND TO PCH BOX
			outvalue	"i_MIDI", (ioct-3)*12			;DERIVE MIDI NOTE NUMBER FROM OCT VALUE AND SEND TO MIDI NOTE NUMBER BOX
endin

instr	4	;SEND OCT BOX VALUE TO THE OTHER 3 BOXES
			outvalue	"i_cps", cpsoct(i(gkoct))		;CONVERT OCT VALUE TO CPS AND SEND TO CPS BOX
			outvalue	"i_pch", pchoct(i(gkoct))		;CONVERT OCT VALUE TO PCH AND SEND TO PCH BOX
			outvalue	"i_MIDI", (i(gkoct)-3)*12		;DERIVE MIDI NOTE NUMBER FROM OCT VALUE AND SEND TO MIDI NOTE NUMBER BOX
endin

instr	5	;SEND PCH BOX VALUE TO THE OTHER 3 BOXES
			outvalue	"i_cps", cpspch(i(gkpch))		;CONVERT PCH VALUE TO CPS FORMAT AND SEND TO CPS BOX

	ipch		init	i(gkpch)							;CONVERT PCH VALUE TO I-RATE LOCAL PCH VALUE
	ioct		=	octpch(ipch)						;CONVERT PCH VALUE TO OCT FORMAT VALUE

			outvalue	"i_oct", ioct					;SEND OCT VALUE TO OCT BOX 
			outvalue	"i_MIDI", (ioct-3)*12			;DERIVE MIDI NOTE NUMBER FROM OCT VALUE AND SEND TO MIDI BOTE NUMBER BOX
endin

instr	6	;SEND MIDI NOTE NUMBER BOX VALUE TO THE OTHER 3 BOXES
			outvalue	"i_cps", cpsmidinn(i(gknum))		;CONVERT MIDI NOTE NUMBER TO CPS FORMAT AND SEND TO CPS BOX
			outvalue	"i_oct", octmidinn(i(gknum))		;CONVERT MIDI NOTE NUMBER TO OCT FORMAT AND SEND TO OCT BOX
			outvalue	"i_pch", pchmidinn(i(gknum))		;CONVERT MIDI NOTE NUMBER TO PCH FORMAT AND SEND TO PCH BOX
endin

instr	10	;GENERATE A TONE
	ktrig1	changed	gkcpsIP						;IF SLIDER IS CHANGED GENERATE A MOMENTARY '1' (BANG)
	ktrig2	changed	gkcps						;IF CPS BOX IS CHANGED GENERATE A MOMENTARY '1' (BANG)

	if ktrig1=1	 then							;IF SLIDER HAS BEEN CHANGED...
		kcps	= gkcpsIP								;TAKE LOCAL CPS VALUE FROM SLIDER
	elseif ktrig2=1 then							;IF CPS TEXT BOX HAS BEEN CHANGED...
		kcps	= gkcps								;TAKE LOCAL CPS VALUE FROM CPS TEXT BOX
	endif										;END OF THIS CONDITIONAL BRANCH
	asig	poscil	0.1*gktone, kcps, gisine				;GENERATE A TONE
		outs		asig, asig						;SEND AUDIO TO OUTPUTS
endin
</CsInstruments>
<CsScore>
i 100 0 3600	;GUI

i 2 0 3600	;SCAN FOR CHANGES TO SLIDER - UPDATE DISPLAY BOXES
i 10 0 3600	;PLAY A TONE
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1151</x>
 <y>142</y>
 <width>1149</width>
 <height>604</height>
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
  <y>245</y>
  <width>1144</width>
  <height>357</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch Formats</label>
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
  <x>7</x>
  <y>267</y>
  <width>1136</width>
  <height>331</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Csound accepts expressions of pitch in a variety of formats. Accordingly there are a number of opcodes for conversion between these different formats. The four formats explored in this example are 'cps' (cycles-per-second), 'oct' (octave-point-decimal), 'pch' (octave-point-pitch-class) and MIDI note number.

"Cycles-per-second is the standard measure of frequency and defines the number of completed cycles of a waveform expressed per second. The unit of measurement of CPS is 'hertz'.

'Oct' expresses pitch as the octave registration followed by a decimal which expresses the additional interval as a fractional part of an octave. Therefore F# above middle C will be 8.5 (octave=8 + 1/2 an octave).

'Pch' again begins by expressing the octave registration. Semitones steps this octave are expressed in steps of 0.01. A chromatic scale above middle C in 'pch' format goes: 8.00 8.01 8.02 8.03 8.04 8.05 and so on. The B above middle C will be 8.11, the next semitone step above that (C5) will be 9.00.

MIDI note numbers express pitch as integers in the range 0-127 corresponding to note of a chromatic MIDI keyboard. MIDI keyboards rarely contain 128 keys so the note numbers available at any one time will be an inner subset of this range. Middle C will be represented by a MIDI note number of 60, the C above that by 72. Fractional MIDI note numbers are allowed and define fractional parts of a semitone but are only useful within Csound as keyboards neither transmit nor recognize fractional MIDI note numbers.

In this example the user can move the slider at the top of the interface and observe how pitch is expressed in the four formats discussed above. Activating the 'Tone On/Off' button will allow the user to hear the pitch described as a sine tone.
In the lower panel values can be typed directly in and converted into the other formats. Notes played on a MIDI keyboard will also be expressed in all 4 formats in these boxes.</label>
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
  <x>2</x>
  <y>2</y>
  <width>514</width>
  <height>240</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch Formats</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>Tone</objectName>
  <x>8</x>
  <y>12</y>
  <width>110</width>
  <height>24</height>
  <uuid>{9d29ab85-85e6-462e-8761-1ac91e1af325}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  Tone On/Off</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>cpsIP</objectName>
  <x>8</x>
  <y>41</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2cf97843-5b49-438e-8034-62a459597e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.68200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>134</y>
  <width>500</width>
  <height>102</height>
  <uuid>{11faf86e-aa61-4c25-b9cc-b5e7a1d6b5d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI INPUT &amp; CONVERSIONS</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>79</y>
  <width>500</width>
  <height>50</height>
  <uuid>{67e61bf6-ba32-4c64-bce4-4ae352dc35fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>d_cps</objectName>
  <x>68</x>
  <y>89</y>
  <width>60</width>
  <height>30</height>
  <uuid>{26417f0c-07eb-4e23-9391-d771142e4787}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1217.494</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>13</x>
  <y>89</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c8a8b6a3-8e29-4d54-adf9-46f3ecbd92c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>cps:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <objectName>d_oct</objectName>
  <x>183</x>
  <y>89</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1f397a23-abdd-4e89-8419-c9c49b228d61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10.218</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>128</x>
  <y>89</y>
  <width>60</width>
  <height>30</height>
  <uuid>{65f079b5-aab7-4249-91df-5cefa2edd10d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>oct:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <objectName>d_pch</objectName>
  <x>297</x>
  <y>89</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c5096e42-e329-4512-8d41-002843b7e38c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10.026</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>242</x>
  <y>89</y>
  <width>60</width>
  <height>30</height>
  <uuid>{506f0573-a463-4f9a-b136-e04f7e0e6c2c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pch:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <objectName>d_MIDI</objectName>
  <x>412</x>
  <y>89</y>
  <width>60</width>
  <height>30</height>
  <uuid>{082af5b2-4c57-465d-b6ae-08741589dbc5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>86.620</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>357</x>
  <y>89</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d865f626-2bb6-49de-949c-74cd87bfd93e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>0</x>
  <y>163</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0e66e816-cd36-458a-84b9-8de0c69fa321}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>cps:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>124</x>
  <y>163</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c303878a-396d-4717-8726-afc1414e4271}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>oct:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>238</x>
  <y>163</y>
  <width>60</width>
  <height>30</height>
  <uuid>{86bd64cb-04e2-431a-a582-3c69026e5e0a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pch:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>353</x>
  <y>163</y>
  <width>60</width>
  <height>30</height>
  <uuid>{aa062c21-d41d-4e09-a771-d90f109e3009}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>28</x>
  <y>196</y>
  <width>100</width>
  <height>24</height>
  <uuid>{dabffd3f-a11b-4b8e-a022-f38af30978c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Convert</text>
  <image>/</image>
  <eventLine>i 3 0 0.01</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>142</x>
  <y>196</y>
  <width>100</width>
  <height>24</height>
  <uuid>{0f2a5f57-408d-46d9-8ba7-2b6f98d79f35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Convert</text>
  <image>/</image>
  <eventLine>i 4 0 0.01</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>257</x>
  <y>196</y>
  <width>100</width>
  <height>24</height>
  <uuid>{3326ce9c-aab5-4961-9041-5cf0ec8c3c26}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Convert</text>
  <image>/</image>
  <eventLine>i 5 0 0.01</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>371</x>
  <y>196</y>
  <width>100</width>
  <height>24</height>
  <uuid>{ecea7ed6-a9e2-4dbb-856a-74a11042ce24}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Convert</text>
  <image>/</image>
  <eventLine>i 6 0 0.01</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>i_cps</objectName>
  <x>58</x>
  <y>163</y>
  <width>68</width>
  <height>24</height>
  <uuid>{0a076e73-3357-4fdd-9eef-f1be4d484640}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <resolution>0.01000000</resolution>
  <minimum>0</minimum>
  <maximum>20000</maximum>
  <randomizable group="0">false</randomizable>
  <value>215.47</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>i_oct</objectName>
  <x>181</x>
  <y>163</y>
  <width>60</width>
  <height>24</height>
  <uuid>{3c2aefb0-8ea2-43bd-a413-823da8e68654}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <resolution>0.01000000</resolution>
  <minimum>0</minimum>
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>7.71998</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>i_pch</objectName>
  <x>295</x>
  <y>163</y>
  <width>60</width>
  <height>24</height>
  <uuid>{98e5167d-9a4b-43ff-8f0d-8cca4273fe96}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <resolution>0.01000000</resolution>
  <minimum>0</minimum>
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>7.0864</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>i_MIDI</objectName>
  <x>410</x>
  <y>163</y>
  <width>60</width>
  <height>24</height>
  <uuid>{bc5a9d05-aa02-4152-98d1-26cf9c89309d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <minimum>0</minimum>
  <maximum>127</maximum>
  <randomizable group="0">false</randomizable>
  <value>56.6398</value>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

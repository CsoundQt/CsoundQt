;Written by Iain McCurdy, 2010

;Modified for QuteCsound by René, February 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table for exp slider


/*	                                                   Rhythmicon
	------------------------------------------------------------------------------------------------------------------------
	This example is an implmentation of the 'Rhythmicon', an instrument designed an built by the inventor Leon Theremin
	and commissioned by the composer Henry Cowell.
	This instrument presented users with a short 17 note keyboard. The first 16 notes produced a sequence of pitches
	the fundamentals of which followed a harmonic series based on on the pitch produced by the first note.
	Therefore if the first note played 100 Hz, the second played 200 Hz, the third 300 Hz, the fourth 400 Hz etc.
	Each note sounded as a rhythmical pulse rising in speed up the keyboard.
	The ratios of these pulsation speeds ascending the keyboard also followed the ratios of the harmonic series therefore the
	second key played a pulse twice that of the first, the third three time that of the first and so on. The 17th note
	produced no sound but instead acted as a switch that added a syncopation effect (I am unsure as to exactly how this was
	implemented so I have omitted it from my instrument).
	More information on the Rhythmicon can be found by searching on the internet.
	In my example the fundamental rate of pulsation defaults to 0.5 Hz. The user can modulate this using the 'Rate' slider.
	This example can be played either from a MIDI keyboard or by using the on-screen buttons.
	The numbers on the GUI buttons indicate the rhythmic subdivisions of that note with respect to the pulsation rate
	of the first note. These numbers therefore also indicate the ratios of frequencies of the tones they produce.
	Two methods of tone generation are provided which can be chosen using the 'VOICE' radio button selector. Firstly a
	plucked string physical model can be used (although certain tuning anomalies may be encountered). The reflectivity of the
	fixings at either end of the string (damping) can be changed using the 'Pluck Reflection' slider. Secondly a VCO can be
	employed. Waveform, filter cutoff and resonance can be modulated here.
	The frequency of the lowest tone that the Rhythmicon will produce can be set using the 'Fundamental Freq.' slider.
	The user can also define the lowest MIDI note that will activate the Rhythmicon with the 'Starting Note' counter.
*/


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine	ftgen	0,0,131072,10,1
giExp1	ftgen	0, 0, 129, -25, 0, 20.0, 128, 2000.0		;TABLE FOR EXP SLIDER
giExp2	ftgen	0, 0, 129, -25, 0, 100.0, 128, 10000.0		;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkrate		invalue	"Fund_Rate"
		kfund		invalue 	"Fund_Pitch"
		gkfund		tablei	kfund, giExp1, 1
					outvalue	"Fund_Pitch_Value", gkfund

		gkgain		invalue 	"Gain"		;100,    10000,   -1
		gkdur		invalue 	"Note_Dur"
		gkrefl		invalue 	"Pluck_Reflection"
		gkVCOres		invalue 	"VCO_Resonance"
		kVCOcf		invalue 	"VCO_Cutoff"
		gkVCOcf		tablei	kVCOcf, giExp2, 1
					outvalue	"VCO_Cutoff_Value", gkVCOcf

		gkStartNote	invalue  	"StartNote"
		gkvoice		invalue	"Voice"
		gkwave		invalue	"Wave"
	endif
endin

instr	1	;MIDI
	inum		notnum												;READ IN MIDI NOTE NUMBER
	iStartNote	init	i(gkStartNote)									;STARTING NOTE FOR THE RHYTHMICON
	if	inum<=iStartNote	then										;IF A NOTE BELOW THE STARTING NOTE IS PLAYED...
		turnoff													;...IT WILL BE IGNORED AND THIS INSTRUMENT WILL BE TURNED OFF
	endif														;END OF CONDITIONAL BRANCHING
	inum		=	inum - iStartNote									;CREATE A NEW VALUE FOR inum. I.E. COUNTING BEGINS AT RHYTHMICON START NOTE FROM 1
	krate	=	gkrate * inum										;RATE IS A PRODUCT OF RHYTHMICON NOTE COUNT AND 'RATE' SLIDER
	ktrigger	metro	krate										;GENERATE A METRONOME TRIGGER FOR THIS NOTE
			schedkwhen	ktrigger, 0, 0, 30, 0, gkdur, gkfund * inum		;SCHEDULE NOTE PULSE (INSTR 30)
endin

;DEFINE A MACRO FOR A GUI TRIGGERED NOTE
#define	GUI_NOTE(I)
#	
instr	$I
	inum		=	p4												;READ p4 VALUE
	krate	=	gkrate * inum										;RATE IS A PRODUCT OF RHYTHMICON NOTE COUNT AND 'RATE' SLIDER
	ktrigger	metro		krate									;GENERATE A METRONOME TRIGGER FOR THIS NOTE
			schedkwhen	ktrigger, 0, 0, 30, 0, gkdur, gkfund * inum		;SCHEDULE NOTE PULSE (INSTR 30)		
endin
#

;CREATE INSTRUMENTS 11-26 USING A MACRO EXPANSION OF 'GUI_NOTE' WITH ARGUMENTS
$GUI_NOTE(11)
$GUI_NOTE(12)
$GUI_NOTE(13)
$GUI_NOTE(14)
$GUI_NOTE(15)
$GUI_NOTE(16)
$GUI_NOTE(17)
$GUI_NOTE(18)
$GUI_NOTE(19)
$GUI_NOTE(20)
$GUI_NOTE(21)
$GUI_NOTE(22)
$GUI_NOTE(23)
$GUI_NOTE(24)
$GUI_NOTE(25)
$GUI_NOTE(26)


instr	30	;SOUND PRODUCING INSTRUMENT
	aenv		linseg	0,0.005,1, p3-0.005, 0							;AMPLITUDE ENVELOPE
	ipick	init		0.1											;PICK-UP POSITION
	iplk		random	0.85,0.98										;PLUCK POSITION
	iamp		init		1											;AMPLITUDE

	if	gkvoice=0	then
		asig 	wgpluck2	iplk, 1, p4, ipick, gkrefl					;PLUCKED STRING PHYSICAL MODEL
		asig		=		asig  * aenv * gkgain						;SCALE AUDIO SIGNAL USING AMPLITUDE ENVELOPE AND OUTPUT GAIN SLIDER
	elseif	gkvoice=1	then
		asig 	vco 		aenv * i(gkgain), p4, i(gkwave)+1, 0.5, gisine
		kcf		expon	i(gkVCOcf),p3,20
		asig		moogvcf	asig, kcf, gkVCOres
	endif
				outs		asig, asig								;SEND AUDIO TO OUTPUTS
endin
</CsInstruments>
<CsScore>
i 10 0 3600	;GUI
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>874</x>
 <y>233</y>
 <width>518</width>
 <height>642</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>241</r>
  <g>226</g>
  <b>185</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>3</x>
  <y>2</y>
  <width>512</width>
  <height>640</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rhythmicon</label>
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
  <y>250</y>
  <width>502</width>
  <height>178</height>
  <uuid>{11faf86e-aa61-4c25-b9cc-b5e7a1d6b5d2}</uuid>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>StartNote</objectName>
  <x>50</x>
  <y>215</y>
  <width>60</width>
  <height>26</height>
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
  <value>59</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>166</y>
  <width>200</width>
  <height>30</height>
  <uuid>{b6afbe1e-677c-44a6-ba84-4c32dc21b0a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Gain</objectName>
  <x>8</x>
  <y>143</y>
  <width>500</width>
  <height>27</height>
  <uuid>{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.29200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gain</objectName>
  <x>448</x>
  <y>166</y>
  <width>60</width>
  <height>30</height>
  <uuid>{95f6cb02-77ec-46fe-876b-a93efac3c5e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.292</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <y>113</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7fd47947-fd0d-4964-85e5-682fed1916c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fundamental Pitch</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Fund_Pitch</objectName>
  <x>8</x>
  <y>90</y>
  <width>500</width>
  <height>27</height>
  <uuid>{475cdd64-a4ca-4ebc-a000-90448e932478}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.27000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Fund_Pitch_Value</objectName>
  <x>448</x>
  <y>113</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>74.661</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <y>60</y>
  <width>200</width>
  <height>30</height>
  <uuid>{3ebc1139-1fdb-48dc-9150-49ee8dfdbd4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fundamental Rate</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Fund_Rate</objectName>
  <x>8</x>
  <y>37</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e37b61b7-9175-45bf-8dc5-8ff8612545a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.50280000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Fund_Rate</objectName>
  <x>448</x>
  <y>60</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e54486c5-f9aa-4d0e-9a67-6506dae3c790}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.503</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>7</x>
  <y>191</y>
  <width>123</width>
  <height>30</height>
  <uuid>{4efe17ef-0071-418f-a4b2-30d8d3309eae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Starting Note (MIDI)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
  <x>158</x>
  <y>219</y>
  <width>200</width>
  <height>30</height>
  <uuid>{994b6a17-546e-4319-9b86-bb6f0cee081d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Note Duration</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Note_Dur</objectName>
  <x>158</x>
  <y>196</y>
  <width>350</width>
  <height>27</height>
  <uuid>{cf15ae28-0472-4a21-8382-d6af83dd0a56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>3.00000000</maximum>
  <value>1.00314286</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Note_Dur</objectName>
  <x>448</x>
  <y>218</y>
  <width>60</width>
  <height>30</height>
  <uuid>{cf8351fc-2960-4245-8559-b6b4e952f379}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.003</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Voice</objectName>
  <x>106</x>
  <y>444</y>
  <width>80</width>
  <height>30</height>
  <uuid>{39794b17-c7ed-43ac-aa8b-34f01d131983}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Pluck</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>VCO</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Wave</objectName>
  <x>309</x>
  <y>444</y>
  <width>80</width>
  <height>30</height>
  <uuid>{a5a9d02b-d2d7-430b-8bc1-5e86ae9c98f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Saw</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Square</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Tri</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>24</x>
  <y>444</y>
  <width>80</width>
  <height>30</height>
  <uuid>{887d940f-1739-4ff2-bc73-c29804145881}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VOICE:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
  <x>227</x>
  <y>444</y>
  <width>80</width>
  <height>30</height>
  <uuid>{ac89d217-b801-48a4-8870-61ece5ddada7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VCO WAVE:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
  <y>612</y>
  <width>200</width>
  <height>30</height>
  <uuid>{37e632ae-42ea-478e-b426-bd3192d4412f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VCO Cutoff</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>VCO_Cutoff</objectName>
  <x>8</x>
  <y>589</y>
  <width>500</width>
  <height>27</height>
  <uuid>{6447a9dd-b5c1-48c1-b1f4-244014495b21}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.60600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>VCO_Cutoff_Value</objectName>
  <x>448</x>
  <y>612</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c4adb2be-24a8-4c1f-a688-a6275b926a32}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1224.797</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <y>559</y>
  <width>180</width>
  <height>30</height>
  <uuid>{9816b929-aa80-4ced-be9f-6ee419fa0663}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VCO Resonance</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>VCO_Resonance</objectName>
  <x>8</x>
  <y>536</y>
  <width>500</width>
  <height>27</height>
  <uuid>{c9b039b8-50e9-42db-a1e7-785ebfdcbeff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>VCO_Resonance</objectName>
  <x>448</x>
  <y>559</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7096a5c3-3446-418d-b80f-c0697d8d07a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.102</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <y>506</y>
  <width>200</width>
  <height>30</height>
  <uuid>{cfb56f63-67b6-486f-acd0-8dc64562adab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pluck Reflection</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Pluck_Reflection</objectName>
  <x>8</x>
  <y>483</y>
  <width>500</width>
  <height>27</height>
  <uuid>{56370972-f91b-4314-a6e7-ba20c7a70350}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.99900000</maximum>
  <value>0.37425200</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pluck_Reflection</objectName>
  <x>448</x>
  <y>506</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1f14eb88-0115-4928-90fa-7e1074b5b48a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.374</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>66</x>
  <y>341</y>
  <width>40</width>
  <height>80</height>
  <uuid>{a6aa45c5-a625-4d3b-a423-a71788f7ca80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> 1</text>
  <image>/</image>
  <eventLine>i 11 0 -1 1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>106</x>
  <y>341</y>
  <width>40</width>
  <height>80</height>
  <uuid>{7f9fcc69-c74e-464e-9cf1-7eb600cec1f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> 3</text>
  <image>/</image>
  <eventLine>i 13 0 -1 3</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>146</x>
  <y>341</y>
  <width>40</width>
  <height>80</height>
  <uuid>{0072a3f8-0eec-49f6-bea5-d3011a06de41}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> 5</text>
  <image>/</image>
  <eventLine>i 15 0 -1 5</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>186</x>
  <y>341</y>
  <width>40</width>
  <height>80</height>
  <uuid>{5a33b46a-1901-45bf-947b-bc87a8708501}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> 6</text>
  <image>/</image>
  <eventLine>i 16 0 -1 6</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>226</x>
  <y>341</y>
  <width>40</width>
  <height>80</height>
  <uuid>{69f2fe7a-784c-433e-a69f-4fc23be174a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> 8</text>
  <image>/</image>
  <eventLine>i 18 0 -1 8</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>266</x>
  <y>341</y>
  <width>40</width>
  <height>80</height>
  <uuid>{38cf6f9f-be50-480f-bf41-7217252e10e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>10</text>
  <image>/</image>
  <eventLine>i 20 0 -1 10</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>306</x>
  <y>341</y>
  <width>40</width>
  <height>80</height>
  <uuid>{7bc6fa14-834e-45a5-a59e-585975281250}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>12</text>
  <image>/</image>
  <eventLine>i 22 0 -1 12</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>346</x>
  <y>341</y>
  <width>40</width>
  <height>80</height>
  <uuid>{93e698d0-5245-49a9-a4e6-15c6fdabfc2f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>13</text>
  <image>/</image>
  <eventLine>i 23 0 -1 13</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>386</x>
  <y>341</y>
  <width>40</width>
  <height>80</height>
  <uuid>{8e5a3b8e-c8f8-4dab-834c-ac874f7f4826}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>15</text>
  <image>/</image>
  <eventLine>i 25 0 -1 15</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>85</x>
  <y>261</y>
  <width>40</width>
  <height>80</height>
  <uuid>{a40cd6c5-77e7-4734-8c0a-3d34ba7fa59d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> 2</text>
  <image>/</image>
  <eventLine>i 12 0 -1 2</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>125</x>
  <y>261</y>
  <width>40</width>
  <height>80</height>
  <uuid>{ba285baf-f254-47c1-884c-a8cd517d8acc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> 4</text>
  <image>/</image>
  <eventLine>i 14 0 -1 4</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>205</x>
  <y>261</y>
  <width>40</width>
  <height>80</height>
  <uuid>{d7bcff40-9869-4088-bb39-eaeb03ca5a27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> 7</text>
  <image>/</image>
  <eventLine>i 17 0 -1 7</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>245</x>
  <y>261</y>
  <width>40</width>
  <height>80</height>
  <uuid>{05550019-f053-47c1-8448-bc9001bf56bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> 9</text>
  <image>/</image>
  <eventLine>i 19 0 -1 9</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>285</x>
  <y>261</y>
  <width>40</width>
  <height>80</height>
  <uuid>{7f93c309-603f-4450-a5b0-cf62ee002c5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>11</text>
  <image>/</image>
  <eventLine>i 21 0 -1 11</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>365</x>
  <y>261</y>
  <width>40</width>
  <height>80</height>
  <uuid>{8a284bd1-eade-4fc9-8d5b-e6f298c580cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>14</text>
  <image>/</image>
  <eventLine>i 24 0 -1 14</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>405</x>
  <y>261</y>
  <width>40</width>
  <height>80</height>
  <uuid>{20a4f5dc-27d4-4dcd-a802-1db138ec38e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>16</text>
  <image>/</image>
  <eventLine>i 26 0 -1 16</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

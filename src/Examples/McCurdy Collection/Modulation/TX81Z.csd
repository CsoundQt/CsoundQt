;Written by Iain McCurdy, 2009


; Modified for QuteCsound by René, November 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
	;Use midi cccc *************************************************************************************************************************???????????,

;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine		ftgen	0, 0, 1024, 10, 1
gitwopeaks	ftgen	0, 0, 1024,  1, "twopeaks.aiff", 0, 0, 0
gifwavblnk	ftgen	0, 0, 1024,  1, "fwavblnk.aiff", 0, 0, 0


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkamp		invalue 	"Amplitude"
		gkc1			invalue 	"Control_1"
		gkc2			invalue 	"Control_2"
		gkvdepth		invalue 	"Vibrato_Depth"
		gkvrate		invalue 	"Vibrato_Rate"

		gkpreset		invalue	"Preset"

;		FLsetVal_i	0.5, gihamp
;		FLsetVal_i	1, 	gihc1
;		FLsetVal_i	1, 	gihc2
;		FLsetVal_i	0.2, gihvdepth
;		FLsetVal_i	0, 	gihvrate

	endif
endin

instr	1	;TX81Z INSTRUMENT
	ioct				= p4
	;PITCH BEND INFORMATION IS READ
	iSemitoneBendRange	= 2										;PITCH BEND RANGE IN SEMITONES (WILL BE DEFINED FURTHER LATER) - SUGGESTION - THIS COULD BE CONTROLLED BY A COUNTER
	imin				= 0										;EQUILIBRIUM POSITION
	imax				= iSemitoneBendRange * .0833333				;MAX PITCH DISPLACEMENT (IN oct FORMAT)
	kbend			pchbend	imin, imax						;PITCH BEND VARIABLE (IN oct FORMAT)
	kfreq			=	cpsoct(ioct+ kbend)
	iporttime			=	0.1									;PORTAMENTO TIME
	kporttime			linseg	0, 0.001, iporttime, 1, iporttime		;PORTAMENTO TIME RISES UP QUICKLY TO DESIRED VALUE
	kc1				portk	gkc1, kporttime					;PORTAMENTO IS APPLIED TO CONTROL VARIABLES
	kc2				portk	gkc2, kporttime					;PORTAMENTO IS APPLIED TO CONTROL VARIABLES
	ikvel			= p5										;KEY VELOCITY IS READ
	kamp				portk	gkamp * ikvel, kporttime				;AMPLITUDE IS DERIVED FROM ON-SCREEN AMPLITUDE CONTROL AND KEY VELOCITY / PORTAMENTO IS APPLIED

	;SELECT THE APPRORIATE FM OPCODE ACCORDING TO THE SETTING OF THE 'TYPE' MENU BOX SELECTER 
	if		gkpreset==0	then
		;HAMMOND B3 ORGAN
		;OUTPUT	OPCODE	AMPLITUDE | FREQUENCY | CONTROL_1 | CONTROL_2 | VIBRATO_DEPTH | VIBRATO_RATE | F.TABLE_1 | F.TABLE_2 | F.TABLE_3 | F.TABLE_4 | VIBRATO_F.TABLE
		ares		fmb3		kamp,        kfreq,      kc1,        kc2,       gkvdepth,       gkvrate,       gisine,    gisine,      gisine,    gisine,        gisine
        
     elseif	gkpreset==1	then
		;TUBULAR BELL	
		;OUTPUT	OPCODE	AMPLITUDE | FREQUENCY | CONTROL_1 | CONTROL_2 | VIBRATO_DEPTH | VIBRATO_RATE | F.TABLE_1 | F.TABLE_2 | F.TABLE_3 | F.TABLE_4 | VIBRATO_F.TABLE
		ares		fmbell	kamp,        kfreq,      kc1,       kc2,       gkvdepth,       gkvrate,       gisine,    gisine,      gisine,    gisine,        gisine

	elseif	gkpreset==2	then
		;HEAVY METAL
		;OUTPUT	OPCODE	AMPLITUDE | FREQUENCY | CONTROL_1 | CONTROL_2 | VIBRATO_DEPTH | VIBRATO_RATE | F.TABLE_1 | F.TABLE_2 | F.TABLE_3 | F.TABLE_4 | VIBRATO_F.TABLE
		ares		fmmetal	kamp,        kfreq,      kc1,       kc2,       gkvdepth,       gkvrate,      gisine,   gitwopeaks,  gitwopeaks,  gisine,        gisine

	elseif	gkpreset==3	then
		;PERCUSSIVE FLUTE
		;OUTPUT	OPCODE	AMPLITUDE | FREQUENCY | CONTROL_1 | CONTROL_2 | VIBRATO_DEPTH | VIBRATO_RATE | F.TABLE_1 | F.TABLE_2 | F.TABLE_3 | F.TABLE_4 | VIBRATO_F.TABLE
		ares		fmpercfl	kamp,        kfreq,      kc1,       kc2,       gkvdepth,       gkvrate,      gisine,      gisine,     gisine,     gisine,        gisine

	elseif	gkpreset==4	then
		;RHODES ELECTRIC PIANO
		;OUTPUT	OPCODE	AMPLITUDE | FREQUENCY | CONTROL_1 | CONTROL_2 | VIBRATO_DEPTH | VIBRATO_RATE | F.TABLE_1 | F.TABLE_2 | F.TABLE_3 | F.TABLE_4 | VIBRATO_F.TABLE
		ares		fmrhode	kamp,        kfreq,      kc1,       kc2,       gkvdepth,       gkvrate,      gisine,      gisine,     gisine,   gifwavblnk,        gisine

	elseif	gkpreset==5	then
		;VOICE
		;OUTPUT	OPCODE	AMPLITUDE | FREQUENCY | CONTROL_1 | CONTROL_2 | VIBRATO_DEPTH | VIBRATO_RATE | F.TABLE_1 | F.TABLE_2 | F.TABLE_3 | F.TABLE_4 | VIBRATO_F.TABLE
		ares		fmvoice	kamp,        kfreq,      kc1,       kc2,       gkvdepth,       gkvrate,       gisine,    gisine,      gisine,    gisine,        gisine

	elseif	gkpreset==6	then
		;WURLITZER ELECTRIC PIANO
		;OUTPUT	OPCODE	AMPLITUDE | FREQUENCY | CONTROL_1 | CONTROL_2 | VIBRATO_DEPTH | VIBRATO_RATE | F.TABLE_1 | F.TABLE_2 | F.TABLE_3 | F.TABLE_4  | VIBRATO_F.TABLE
		ares		fmwurlie	kamp,       kfreq,      kc1,       kc2,       gkvdepth,       gkvrate,       gisine,    gisine,      gisine,   gifwavblnk,        gisine

	endif
	
	aenv		linsegr	0, 0.0001, 1, 3600, 1, 0.1, 0			;A SIMPLE MIDI RESPONSIVE ENVELOPE TO PREVENT CLICKS AT THE START AND END OF NOTES
			outs		ares * aenv, ares * aenv				;SEND AUDIO TO OUTPUTS - MULTIPLY BY AMPLITUDE ENVELOPE
endin

instr	2	;INIT
		outvalue	"_SetPresetIndex", 0
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI

i 2	     0.1		 0		;INIT
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>1201</width>
 <height>518</height>
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
  <height>450</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Yamaha TX817 Models</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <x>514</x>
  <y>2</y>
  <width>610</width>
  <height>450</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Yamaha TX817 Models</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <x>521</x>
  <y>21</y>
  <width>599</width>
  <height>424</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------------------------
A set of opcodes that implement presets from the FM synthesis module, the Yamaha TX81Z, have been written by John ffitch for Csound, based on work by Perry Cook. The seven different opcodes can be selected using the Type menu in the GUI. All seven opcodes share the same set of input arguments, the only difference between them in terms of setting them up is that some of them use waveforms besides sine waves for some of their operators (oscillators). The TX81Z implements four-operator FM algorithms and in theory there is no reason why these algorithms could not be implemented from first principles using individual oscillators.
The Functions of Controls 1 and 2 are as follows:
+-----------------------------------+-----+------------------------+------------------------------------------------+
|.......... OPCODE ..........|ALG|.. CONTROL 1 ..|............... CONTROL 2 ..............|
+-----------------------------------+-----+------------------------+------------------------------------------------+
| Hammond B3 Organ......|. 4 .| Total Mod. Index |  Crossfade of the two modulators  |
| Tubular Bell..................|. 5 .| Mod. Index 1.......|  Crossfade of two outputs...........|
| Heavy Metal.................|. 4 .| Total Mod. Index |  Crossfade of the two modulators  |
| Percussive Flute...........|. 4 .| Total Mod. Index |  Crossfade of the two modulators  |
| Rhodes Elec Piano........|. 5 .| Mod. Index 1......|  Crossfade of two outputs...........|
| Voice............................|. ? .| Vowel................| Tilt............................................|
| Wurlitzer Elec Piano......|. 5 .| Mod. Index 1......|  Crossfade of two outputs............|
+-----------------------------------+----+-------------------------+-------------------------------------------------+

This example is MIDI-ified, responding to MIDI notes, key velocity, pitch bend and additional continuous controller assignments which double the funtions of the on-screen sliders. Enveloping of the sound is contained within the opcode.</label>
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
  <x>8</x>
  <y>94</y>
  <width>180</width>
  <height>30</height>
  <uuid>{541ace1b-b1de-4c04-8d84-1de90288dded}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude (CC#7)</label>
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
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>71</y>
  <width>500</width>
  <height>27</height>
  <uuid>{eac88081-deaa-45c0-b896-32a3ffedc74a}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>7</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>94</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3be43919-ad18-4aef-b554-03c4b4d991c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.308</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Control_1</objectName>
  <x>448</x>
  <y>137</y>
  <width>60</width>
  <height>30</height>
  <uuid>{11dfc416-5a1d-40f4-bbaa-6b1b2e2bb7c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.188</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Control_1</objectName>
  <x>8</x>
  <y>114</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5e37a418-576c-419e-817f-2002fc5b805b}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>99.00000000</maximum>
  <value>0.66938776</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>137</y>
  <width>180</width>
  <height>30</height>
  <uuid>{afc5d077-588e-4d40-92cf-761ea81eb1da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Control 1 (CC#3)</label>
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
  <x>8</x>
  <y>266</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7e72caae-d5e3-48e8-9285-1cbd12c5347c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vibrato Rate (CC#2)</label>
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
  <objectName>Vibrato_Rate</objectName>
  <x>8</x>
  <y>243</y>
  <width>500</width>
  <height>27</height>
  <uuid>{254004da-2c79-4209-bf6e-0f8cdd5fafcc}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>2</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.60816324</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Vibrato_Rate</objectName>
  <x>448</x>
  <y>266</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f6bcb14a-ad2e-4303-9aab-c49730db24d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.300</label>
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
  <objectName>Preset</objectName>
  <x>182</x>
  <y>328</y>
  <width>200</width>
  <height>28</height>
  <uuid>{1fceb5fa-f31b-4507-9d73-2100cf426aec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>B3</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Bell</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Heavy Metal</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Percussive Flute</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Rhodes Electric Piano</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Voice</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Wurlitzer Electric Piano</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>223</y>
  <width>180</width>
  <height>30</height>
  <uuid>{ffb0a5ee-ba0c-4308-b51d-892e1d37bd87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vibrato Depth (CC#1)</label>
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
  <objectName>Vibrato_Depth</objectName>
  <x>8</x>
  <y>200</y>
  <width>500</width>
  <height>27</height>
  <uuid>{64abd1d0-ef34-49d8-bbc4-0b1103c02d8b}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <minimum>0.00010000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.60000002</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Vibrato_Depth</objectName>
  <x>448</x>
  <y>223</y>
  <width>60</width>
  <height>30</height>
  <uuid>{da0544f6-bf20-4d77-bc1e-92be4a463d95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.200</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Control_2</objectName>
  <x>448</x>
  <y>180</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b7304e5e-85f4-43ab-85b3-76ff2664d3e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.386</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Control_2</objectName>
  <x>8</x>
  <y>157</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2f8b24c3-b597-4e5d-a3fc-0e388dc5cab4}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>4</midicc>
  <minimum>0.00000000</minimum>
  <maximum>99.00000000</maximum>
  <value>0.80612242</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>180</y>
  <width>180</width>
  <height>30</height>
  <uuid>{523f1aa4-a5ac-4b2a-a389-8b68340ce13b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Control 2 (CC#4)</label>
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
  <x>117</x>
  <y>328</y>
  <width>58</width>
  <height>28</height>
  <uuid>{b9d4f7dc-3bbc-4ec1-925e-4c78662d8b5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Type</label>
  <alignment>right</alignment>
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
</bsbPanel>
<bsbPresets>
<preset name="Init" number="0" >
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.50000000</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >0.50000000</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >0.500</value>
<value id="{11dfc416-5a1d-40f4-bbaa-6b1b2e2bb7c2}" mode="1" >1.18799996</value>
<value id="{11dfc416-5a1d-40f4-bbaa-6b1b2e2bb7c2}" mode="4" >1.188</value>
<value id="{5e37a418-576c-419e-817f-2002fc5b805b}" mode="1" >1.18799996</value>
<value id="{254004da-2c79-4209-bf6e-0f8cdd5fafcc}" mode="1" >5.30000019</value>
<value id="{f6bcb14a-ad2e-4303-9aab-c49730db24d0}" mode="1" >5.30000019</value>
<value id="{f6bcb14a-ad2e-4303-9aab-c49730db24d0}" mode="4" >5.300</value>
<value id="{1fceb5fa-f31b-4507-9d73-2100cf426aec}" mode="1" >0.00000000</value>
<value id="{64abd1d0-ef34-49d8-bbc4-0b1103c02d8b}" mode="1" >0.20008001</value>
<value id="{da0544f6-bf20-4d77-bc1e-92be4a463d95}" mode="1" >0.20008001</value>
<value id="{da0544f6-bf20-4d77-bc1e-92be4a463d95}" mode="4" >0.200</value>
<value id="{b7304e5e-85f4-43ab-85b3-76ff2664d3e4}" mode="1" >1.38600004</value>
<value id="{b7304e5e-85f4-43ab-85b3-76ff2664d3e4}" mode="4" >1.386</value>
<value id="{2f8b24c3-b597-4e5d-a3fc-0e388dc5cab4}" mode="1" >1.38600004</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

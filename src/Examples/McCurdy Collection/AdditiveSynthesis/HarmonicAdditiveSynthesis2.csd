; Written by Iain McCurdy, 2006
; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Instrument 1 is activated by MIDI and by the GUI

;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 48000		;SAMPLE RATE
ksmps	= 10			;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH

gisine		ftgen	0, 0, 4096, 10, 1				;A SINE WAVE
giExp10000	ftgen	0, 0, 129, -25, 0, 20, 128, 10000	;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then

		;SLIDERS
		gkPartAmp1	invalue 	"PartAmp1"
		gkPartAmp2	invalue 	"PartAmp2"
		gkPartAmp3	invalue 	"PartAmp3"
		gkPartAmp4	invalue 	"PartAmp4"
		gkPartAmp5	invalue 	"PartAmp5"
		gkPartAmp6	invalue 	"PartAmp6"
		gkPartAmp7	invalue 	"PartAmp7"
		gkPartAmp8	invalue 	"PartAmp8"
		gkPartAmp9	invalue 	"PartAmp9"
		gkPartAmp10	invalue 	"PartAmp10"
		gkPartAmp11	invalue 	"PartAmp11"
		gkPartAmp12	invalue 	"PartAmp12"
		gkPartAmp13	invalue 	"PartAmp13"
		gkPartAmp14	invalue 	"PartAmp14"
		gkPartAmp15	invalue 	"PartAmp15"
		gkPartAmp16	invalue 	"PartAmp16"
		gkPartAmp17	invalue 	"PartAmp17"
		gkPartAmp18	invalue 	"PartAmp18"
		gkPartAmp19	invalue 	"PartAmp19"
		gkPartAmp20	invalue 	"PartAmp20"
		gkPartAmp21	invalue 	"PartAmp21"
		gkPartAmp22	invalue 	"PartAmp22"
		gkPartAmp23	invalue 	"PartAmp23"
		gkPartAmp24	invalue 	"PartAmp24"
		gkPartAmp25	invalue 	"PartAmp25"
		gkPartAmp26	invalue 	"PartAmp26"
		gkPartAmp27	invalue 	"PartAmp27"
		gkPartAmp28	invalue 	"PartAmp28"
		gkPartAmp29	invalue 	"PartAmp29"
		gkPartAmp30	invalue 	"PartAmp30"

		;SLIDERS	
		gkfund		invalue	"Fund_Freq"
		gkfund		tablei	gkfund, giExp10000, 1
					outvalue	"Fund_Freq_Value", gkfund
		gkamp		invalue	"Amplitude"
	
		;KNOBS
		gkampatt		invalue	"Attack"
		gkampattlev	invalue	"Att_Lev"
		gkampdec		invalue	"Decay_1"
		gkampdeclev	invalue	"Dec_Lev."
		gkampdec2		invalue	"Decay_2"
		gkampslev		invalue	"Sustain"
		gkamprel		invalue	"Release"
 
		;KNOBS
		gkmodrate		invalue	"Mod_Rate"
		gkvibdep		invalue	"Vib_Depth"
		gktremdep		invalue	"Trem_Depth"
		gkmoddel		invalue	"Delay_Time"
		gkmodrise		invalue	"Rise_Time"
	endif
endin

instr	1	;SYNTHESIS INSTRUMENT
	if p4!=0 then														;MIDI
		ioct		= p4													;READ OCT VALUE FROM MIDI INPUT
		iamp		= p5 * 0.5											;READ IN A NOTE VELOCITY VALUE FROM THE MIDI INPUT
		kamp = iamp * gkamp												;SET kamp TO MIDI KEY VELOCITY MULTIPLIED BY FLTK SLIDER VALUE gkamp

		;PITCH BEND===========================================================================================================================================================
		iSemitoneBendRange	= 2											;PITCH BEND RANGE IN SEMITONES (WILL BE DEFINED FURTHER LATER) - SUGGESTION - THIS COULD BE CONTROLLED BY AN FLTK COUNTER
		imin				= 0											;EQUILIBRIUM POSITION
		imax				= iSemitoneBendRange * .0833333					;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend			pchbend	imin, imax							;PITCH BEND VARIABLE (IN oct FORMAT)
		kfund			= cpsoct	(ioct + kbend)
		;=====================================================================================================================================================================
	else	
		iporttime		= 0.05											;PORTAMENTO TIME VARIABLE
		kporttime		linseg	0,0.001,iporttime,1,iporttime					;CREATE A RAMPING UP FUNCTION TO REPRESENT PORTAMENTO TIME
		kfund		portk	gkfund, kporttime							;APPLY PORTAMENTO SMOOTHING
		kamp			portk	gkamp, kporttime							;APPLY PORTAMENTO SMOOTHING
	endif

	;AMPLITUDE ENVELOPE (WITH MIDI RELEASE SEGMENT)
	aenv		linsegr	0,i(gkampatt),i(gkampattlev),i(gkampdec),i(gkampdeclev),i(gkampdec2),i(gkampslev),i(gkamprel),0
	
	;AMPLITUDE MODULATION (TREMOLO) AND VIBRATO
	gkTremPhase	= .5													;PHASE OF THE TREMOLO LFO WAVEFORM (IN RADIANS) WITH RESPECT TO THE PHASE OF THE VIBRATO WAVEFORM WHICH IS AT ZERO RADIANS (N.B. .5 RADIANS=180 DEGREES)
	kmodenv		linseg	0, i(gkmoddel), 0, i(gkmodrise), 1, 1, 1			;ENVELOPE WHICH ALLOWS THE MODULATION FUNCTIONS TO RISE GRADUALLY AFTER THE NOTE HAS BEGUN
	kvib			oscili	gkvibdep*kmodenv, gkmodrate, gisine				;VIBRATO LFO
	kvib			= kvib + 1											;VIBRATO FUNCTION OSCILLATES ABOUT 1
	ktrem		oscili	gktremdep*kmodenv, gkmodrate, gisine, i(gkTremPhase)	;TREMOLO LFO
	ktrem		= 1-(ktrem+gktremdep)									;TREMOLO OSCILLATES DOWN FROM A MAXIMUM VALUE OF 1
	kfund		= kfund*kvib											;APPLY VIBRATO MODULATION TO THE FUNDEMENTAL (WHICH WILL IN TURN BE PASSED ON TO EACH OF THE PARTIALS)
	kamp			= kamp*ktrem											;APPLY TREMOLO MODULATION TO THE AMPLITUDE VARIABLE THAT WILL BE APPLIED TO EACH OF THE PARTIALS
	
	;SEPARATE OSCILLATORS CREATE EACH OF THE PARTIALS
	;OUTPUT		OPCODE	AMPLITUDE	       | FREQUENCY     | FUNCTION_TABLE
	apart1		oscili	kamp*gkPartAmp1,  kfund, 		 gisine
	apart2		oscili	kamp*gkPartAmp2,  kfund+(kfund), 	 gisine
	apart3		oscili	kamp*gkPartAmp3,  kfund+(kfund*2),  gisine
	apart4		oscili	kamp*gkPartAmp4,  kfund+(kfund*3),  gisine
	apart5		oscili	kamp*gkPartAmp5,  kfund+(kfund*4),  gisine
	apart6		oscili	kamp*gkPartAmp6,  kfund+(kfund*5),  gisine
	apart7		oscili	kamp*gkPartAmp7,  kfund+(kfund*6),  gisine
	apart8		oscili	kamp*gkPartAmp8,  kfund+(kfund*7),  gisine
	apart9		oscili	kamp*gkPartAmp9,  kfund+(kfund*8),  gisine
	apart10      	oscili	kamp*gkPartAmp10, kfund+(kfund*9),  gisine
	apart11      	oscili	kamp*gkPartAmp11, kfund+(kfund*10), gisine
	apart12      	oscili	kamp*gkPartAmp12, kfund+(kfund*11), gisine
	apart13      	oscili	kamp*gkPartAmp13, kfund+(kfund*12), gisine
	apart14      	oscili	kamp*gkPartAmp14, kfund+(kfund*13), gisine
	apart15      	oscili	kamp*gkPartAmp15, kfund+(kfund*14), gisine
	apart16      	oscili	kamp*gkPartAmp16, kfund+(kfund*15), gisine
	apart17      	oscili	kamp*gkPartAmp17, kfund+(kfund*16), gisine
	apart18      	oscili	kamp*gkPartAmp18, kfund+(kfund*17), gisine
	apart19      	oscili	kamp*gkPartAmp19, kfund+(kfund*18), gisine
	apart20      	oscili	kamp*gkPartAmp20, kfund+(kfund*19), gisine
	apart21      	oscili	kamp*gkPartAmp21, kfund+(kfund*20), gisine
	apart22      	oscili	kamp*gkPartAmp22, kfund+(kfund*21), gisine
	apart23      	oscili	kamp*gkPartAmp23, kfund+(kfund*22), gisine
	apart24      	oscili	kamp*gkPartAmp24, kfund+(kfund*23), gisine
	apart25      	oscili	kamp*gkPartAmp25, kfund+(kfund*24), gisine
	apart26      	oscili	kamp*gkPartAmp26, kfund+(kfund*25), gisine
	apart27      	oscili	kamp*gkPartAmp27, kfund+(kfund*26), gisine
	apart28      	oscili	kamp*gkPartAmp28, kfund+(kfund*27), gisine
	apart29      	oscili	kamp*gkPartAmp29, kfund+(kfund*28), gisine
	apart30      	oscili	kamp*gkPartAmp30, kfund+(kfund*29), gisine
	
	;SUM THE 30 OSCILLATORS:
	amix		sum	apart1,\
				apart2,\
				apart3,\
				apart4,\
				apart5,\
				apart6,\
				apart7,\
				apart8,\
				apart9,\
				apart10,\
				apart11,\
				apart12,\
				apart13,\
				apart14,\
				apart15,\
				apart16,\
				apart17,\
				apart18,\
				apart19,\
				apart20,\
				apart21,\
				apart22,\
				apart23,\
				apart24,\
				apart25,\
				apart26,\
				apart27,\
				apart28,\
				apart29,\
				apart30
			outs	amix * aenv, amix * aenv					;SEND MIXED SIGNAL TOaTHE OUTPUTS aND APPLY THE AMPLITUDE ENVELOPE
endin
	
instr	3	;PRESETS
		;SEND VALUE TO WIDGET
		outvalue		"PartAmp1" , p4
		outvalue		"PartAmp2" , p5
		outvalue		"PartAmp3" , p6
		outvalue		"PartAmp4" , p7
		outvalue		"PartAmp5" , p8
		outvalue		"PartAmp6" , p9
		outvalue		"PartAmp7" , p10
		outvalue		"PartAmp8" , p11
		outvalue		"PartAmp9" , p12
		outvalue		"PartAmp10", p13
		outvalue		"PartAmp11", p14
		outvalue		"PartAmp12", p15
		outvalue	 	"PartAmp13", p16
		outvalue	 	"PartAmp14", p17
		outvalue	 	"PartAmp15", p18
		outvalue	 	"PartAmp16", p19
		outvalue	 	"PartAmp17", p20
		outvalue	 	"PartAmp18", p21
		outvalue	 	"PartAmp19", p22
		outvalue	 	"PartAmp20", p23
		outvalue	 	"PartAmp21", p24
		outvalue		"PartAmp22", p25
		outvalue 		"PartAmp23", p26
		outvalue		"PartAmp24", p27
		outvalue	 	"PartAmp25", p28
		outvalue	 	"PartAmp26", p29
		outvalue	 	"PartAmp27", p30
		outvalue	 	"PartAmp28", p31
		outvalue	 	"PartAmp29", p32
		outvalue	 	"PartAmp30", p33
endin
</CsInstruments>
<CsScore>
i 10	0	3600	;INSTRUMENT 10 (GUI) PLAYS FOR 1 HOUR
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>269</x>
 <y>139</y>
 <width>1195</width>
 <height>750</height>
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
  <width>733</width>
  <height>535</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Additive Synthesis 2</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>211</r>
   <g>211</g>
   <b>211</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>10</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{a2478686-0cb1-4081-896c-03397bd19331}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.55000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>11</x>
  <y>321</y>
  <width>800</width>
  <height>28</height>
  <uuid>{ab0e7272-d733-4ebb-bb0e-5be83cf2d34d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1      2      3      4      5      6      7      8      9     10     11    12    13    14    15    16    17    18    19    20     21    22    23    24    25    26    27    28    29    30</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>34</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{fdb44389-5b7d-408b-86f5-c6817a697505}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.55000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>58</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{20a90144-827d-437e-8a8f-9c6cd9e2a87f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.90000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>82</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{92d15a4b-d582-4ae2-8fb2-c0993d808c34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.45000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>106</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{9a9e0651-0fc3-4772-ab39-364cac49aaae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp5</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>131</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{dec8a20a-eadd-4a93-a400-bcb352406930}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.50000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>155</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{821ddbec-2c2c-418b-bef2-233c1c69fb97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp7</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.80000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>179</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{238d4c2c-a4cd-4595-bfed-328db8c4bddf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.30000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>203</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{90c161db-14bf-4937-b50b-44a6002eb02b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp9</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.30000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>227</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{95e1897f-d796-4dba-8b9c-f382985a0a57}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp10</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.30000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>513</x>
  <y>475</y>
  <width>164</width>
  <height>33</height>
  <uuid>{487d5181-d838-4cce-9628-317fefc350cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>   ON  : GUI
   OFF : MIDI</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Fund_Freq</objectName>
  <x>25</x>
  <y>369</y>
  <width>680</width>
  <height>27</height>
  <uuid>{086a860c-b45b-47f3-978f-2f6daac6338b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.33235294</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>24</x>
  <y>386</y>
  <width>160</width>
  <height>30</height>
  <uuid>{109a592d-ca0d-4b82-bf17-3b42c0ff503a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fundamental (Hertz)</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <objectName>Fund_Freq_Value</objectName>
  <x>643</x>
  <y>385</y>
  <width>60</width>
  <height>23</height>
  <uuid>{30f36f54-9085-46d0-8f1f-4a4b89881919}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>157.822</label>
  <alignment>right</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Amplitude</objectName>
  <x>25</x>
  <y>403</y>
  <width>680</width>
  <height>27</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.44705882</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>24</x>
  <y>422</y>
  <width>160</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Global Amplitude</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <objectName>Amplitude</objectName>
  <x>642</x>
  <y>420</y>
  <width>60</width>
  <height>23</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.447</label>
  <alignment>right</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>736</x>
  <y>2</y>
  <width>387</width>
  <height>690</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Additive Synthesis 2 - 30 Harmonics</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>211</r>
   <g>211</g>
   <b>211</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>740</x>
  <y>18</y>
  <width>379</width>
  <height>670</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>---------------------------------------------------------------------------------------------------
In this example a lot more harmonics have been added in addition to an amplitude envelope, tremolo and vibrato. These additions enhance the fusion of the various partials. Some presets are provided (only the partial strengths are contained in the presets) which provide only general approximations of the sounds they attempt to imitate. Notice how the upper haromics are only used in very small amounts (their presence is nonetheless crucial in creating the tone of the instrument). The 'Buzz' preset that employs all harmonics equally sounds rather shrill and unnatural. Also the fundemental (partial 1) is not always the strongest partial. In the 'Trumpet' preset the 4th partial is the strongest. In the clarinet timbre, the odd numbered partials predominate. This is what gives the clarinet timbre its 'hollow' characteristic. The main problem in this example is that the spectrum is not dynamic. In order to create a dynamic spectrum it would be necessary to be able to control the strength of each partial with its own envelope. Implementing this would result in a vast number of controls that would require setting up. Another problem with this example is that the harmonics are always perfectly tuned whereas in the real world even harmonic sounds exhibit small distortions in pitch in their harmonics which imbue them with a slight inharmonicity, crucial to their character.
Additionally control over the initial phase of each of the partials would be needed to be able to control the nature of interference between partials. If all the suggested improvements were added we would have an extremely flexible instrument but it would have an rather unwieldy number on controls and herein lies the main problem with designing an additive synthesis interface. In contrast FM synthesis allows the creation of rich, dynamic spectra by using just a small number of controls (but it lacks the ability to modify independent partials).
Perhaps an alternative approach would be to borrow aspects of subtractive synthesis and employ filters to create dynamic spectra.
This example also allows control from a MIDI keyboard by setting the 'On (GUI) / Off (MIDI)' switch to Off (MIDI). The instrument will respond to note number, velocity and pitch bend.</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>252</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{93bae879-aa09-4b19-af7d-ee22caec4464}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp11</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.07000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>276</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{a69e1b03-fbca-4e88-8e0c-4a2f4f1a7ceb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp12</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.06000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>300</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{1753b6bf-901a-405e-9d81-f0f2005a407d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp13</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.26000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>324</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{df845b6f-ab03-4a74-ada9-a2ac3623d690}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp14</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.16000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>348</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{04cf9793-754d-42f4-8f62-d86608ea30c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp15</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.05000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>373</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{989bf86c-2883-4c06-9577-10f852276375}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp16</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.05000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>397</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{389721fb-faeb-4390-8eb9-f002aa447e10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp17</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.05000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>421</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{0e459f02-1791-43db-8c08-16766bc09241}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp18</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.05000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>445</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{4f42fd01-ba3c-42b9-a030-f48bae09a05b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp19</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.05000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>469</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{bd11dc39-1376-4241-9c09-16cb4b94e45d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp20</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.05000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>494</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{a59d9bdf-6c3c-4eb3-a4d7-853b94b8a9b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp21</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.05000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>518</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{88bb8942-77af-46d7-823f-5c609e3ea307}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp22</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.04000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>542</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{cd044856-b969-4967-9b3f-1f55ad040350}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp23</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.04000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>566</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{7d767a12-0147-4b99-b3c3-926d2f1a2d10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp24</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.04000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>590</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{a0d3bd29-12e5-4edb-90a4-adb9507a50ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp25</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.02300000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>615</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{b9e0ba11-a9a1-4068-b6d1-1905fd2bf71c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp26</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.02200000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>639</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{c77512ff-8c98-4997-ab2d-c457e4313682}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp27</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.01500000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>663</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{445b6fe7-86a6-4fb8-b396-6cf571927d10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp28</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.01000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>687</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{a7616e7f-5669-4427-94f1-e55dd14f085a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp29</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00900000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
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
  <x>711</x>
  <y>68</y>
  <width>20</width>
  <height>250</height>
  <uuid>{e367b63c-be3d-442a-9224-f64cf26b3c8d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PartAmp30</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00800000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>208</r>
   <g>208</g>
   <b>208</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>46</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{cc36858c-b5c8-4f47-8949-9a28783d45aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Violin</text>
  <image>/</image>
  <eventLine>i3  0  0  .55  .55  .9  .45  .5  .5  .8  .3  .3  .3  .07  .06  .26  .16  .05  .05  .05  .05  .05  .05  .05  .04  .04  .04  .023  .022  .015  .01  .009  .008</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>136</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{9a43f975-7c7e-4105-b110-e6e1f6e133e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Trumpet</text>
  <image>/</image>
  <eventLine>i3  0  0  .4  .47  .56  1.3  .8  .7  .6  .25  .2  .13  .07  .04  .03  .023  .013  .01  .008  .0075  .007  .0065  0  0  0  0  0  0  0  0  0  0</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>226</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{564bf011-41fa-47f3-9d38-c67a38f6cfaa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Clarinet</text>
  <image>/</image>
  <eventLine>i3  0  0  1.3  .025  .8  .15  .18  .15  .08  .035  .025  .004  .004  .008  .0035  0  .0042  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>316</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{321f7213-7b02-4959-83b8-2e465533faab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Buzz</text>
  <image>/</image>
  <eventLine>i3  0  0  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>406</x>
  <y>479</y>
  <width>80</width>
  <height>25</height>
  <uuid>{bf52bd76-c992-4053-a2a3-bfcb32fb6df1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Flat</text>
  <image>/</image>
  <eventLine>i3  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>540</y>
  <width>426</width>
  <height>152</height>
  <uuid>{4e02aae5-6318-4c8d-9e58-3d1790d659e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude Envelope</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>211</r>
   <g>211</g>
   <b>211</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>429</x>
  <y>540</y>
  <width>306</width>
  <height>152</height>
  <uuid>{caff2067-9a8e-4834-9868-52b2df6c503f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulation</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>211</r>
   <g>211</g>
   <b>211</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Attack</objectName>
  <x>9</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{fae47231-ad1f-4843-8515-f60878ab7741}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>8.00000000</maximum>
  <value>0.00100000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>625</y>
  <width>56</width>
  <height>25</height>
  <uuid>{ceb84058-a953-49a3-8f86-cd0a255000db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Attack</objectName>
  <x>5</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{e4d4f1b4-6c3a-4d38-9712-f4077c95d2d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.001</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Att_Lev</objectName>
  <x>69</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{2c44f11e-1bb7-4ea5-8569-a2ac2ed47168}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.41000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>67</x>
  <y>625</y>
  <width>56</width>
  <height>40</height>
  <uuid>{c021ba30-b469-4563-8243-d010ab5b6809}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack
Level</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Att_Lev</objectName>
  <x>65</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{e773b942-5db2-4525-b750-9438257a4703}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.410</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Decay_1</objectName>
  <x>129</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{95526f6e-25b3-4d52-8d4a-04148c8c97ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>15.00000000</maximum>
  <value>7.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>127</x>
  <y>625</y>
  <width>56</width>
  <height>40</height>
  <uuid>{e8c43e8c-1d4d-49a9-aede-247f92e60720}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay
1</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Decay_1</objectName>
  <x>125</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{2ceea935-5c20-4180-82c4-0942a7dafe4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7.050</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Dec_Lev</objectName>
  <x>189</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{d8c61ec3-f48e-4894-b1b3-c510fdb52973}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.12000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>187</x>
  <y>625</y>
  <width>56</width>
  <height>40</height>
  <uuid>{0f6e0f4e-fbb8-4e6a-a755-5a8b85d40c4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay
Level</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Dec_Lev</objectName>
  <x>185</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{9fd8f3b0-817f-4e8d-8a69-e8bdef883371}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.120</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Decay_2</objectName>
  <x>249</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{05383d81-a084-408e-849e-8fa0ac2440b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>15.00000000</maximum>
  <value>1.00699997</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>247</x>
  <y>625</y>
  <width>56</width>
  <height>40</height>
  <uuid>{e69c631b-6a27-47f7-bfaa-2e17efffbb4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay
2</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Decay_2</objectName>
  <x>245</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{96f4d795-ee8a-4467-a23e-f3f1a6692726}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.007</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Sustain</objectName>
  <x>309</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{15700ecb-448e-4157-980c-0a6d84bb2900}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.63200003</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>307</x>
  <y>625</y>
  <width>56</width>
  <height>25</height>
  <uuid>{0d1b7954-85d4-4673-8acf-4e30fa413169}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sustain</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Sustain</objectName>
  <x>305</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{54f39089-bebd-4731-9f37-ec4f3954f339}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.632</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Release</objectName>
  <x>369</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{7013c683-0269-434e-81fb-eb4b304cec96}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>15.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>367</x>
  <y>625</y>
  <width>56</width>
  <height>25</height>
  <uuid>{0d968e1d-6aba-461b-9ac6-6610937abf70}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Release</objectName>
  <x>365</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{08855eed-0851-4744-9255-54f5d12ed703}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Mod_Rate</objectName>
  <x>438</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{e7e8a54e-f28f-4a78-925f-ebbe1bbfd4d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>20.00000000</maximum>
  <value>2.60087000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>436</x>
  <y>625</y>
  <width>56</width>
  <height>40</height>
  <uuid>{dec7de58-3795-4f12-838a-219d638060c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mod
Rate</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Mod_Rate</objectName>
  <x>434</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{4c597be5-ec43-40ce-8e95-0bac5ac6f9e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2.601</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Vib_Depth</objectName>
  <x>498</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{bb72e88d-283b-4715-9c36-bd7370e716ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.00400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>496</x>
  <y>625</y>
  <width>56</width>
  <height>40</height>
  <uuid>{6358a3aa-01de-4592-9719-4968d73475cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vib
Depth</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Vib_Depth</objectName>
  <x>494</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{a70e1d54-864d-4bd9-a7f6-a0e97f028952}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.004</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Trem_Depth</objectName>
  <x>558</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{1585ca64-cd69-4556-b57f-05c41aa7dd06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.17000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>556</x>
  <y>625</y>
  <width>56</width>
  <height>40</height>
  <uuid>{69f11874-e9d2-49cb-aa69-662f18701509}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Trem
Depth</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Trem_Depth</objectName>
  <x>554</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{8b6085dc-f0ea-4ca1-af6c-d2cfabb9b941}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.170</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Delay_Time</objectName>
  <x>618</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{8cd381b6-f6d2-4d78-ae35-7735c3d24ae5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.45000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>616</x>
  <y>625</y>
  <width>56</width>
  <height>40</height>
  <uuid>{ad587fda-0e6b-47d8-8f7f-415c121170f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay
Time</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Delay_Time</objectName>
  <x>614</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{d80cf0e2-4956-436d-baf5-6cac09c9b7bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.450</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Rise_Time</objectName>
  <x>678</x>
  <y>573</y>
  <width>50</width>
  <height>50</height>
  <uuid>{a3fd5226-c3f3-439d-9a55-c479d84d9753}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.87000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>676</x>
  <y>625</y>
  <width>56</width>
  <height>40</height>
  <uuid>{d4250dbf-8564-4805-984e-918471f1ca20}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rise
Time</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <objectName>Rise_Time</objectName>
  <x>674</x>
  <y>658</y>
  <width>56</width>
  <height>26</height>
  <uuid>{d7be9e87-af8a-4c47-9b96-dc78840cb653}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.870</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>311</x>
  <y>333</y>
  <width>147</width>
  <height>26</height>
  <uuid>{0e6b982a-a492-4909-b91f-97e091cc3166}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Partial Strength</label>
  <alignment>left</alignment>
  <font>Arial</font>
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

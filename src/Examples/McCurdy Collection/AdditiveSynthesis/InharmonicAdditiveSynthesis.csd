; Written by Iain McCurdy, 2006
; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Instrument 1 is activated by MIDI and by the GUI
;	Add MIDI Pitch bend

;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 48000		;SAMPLE RATE
ksmps	= 10			;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE (MAY NEED TO BE LOW WHEN WORKING WITH SHORT DELAY TIMES DEFINED INITIALLY AT KRATE)
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH

gisine		ftgen	0, 0, 4096, 10, 1				;A SINE WAVE
giExp10000	ftgen	0, 0, 129, -25, 0, 20, 128, 10000	;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkPartAmp1	invalue	"PartAmp1"
		gkPartAmp2	invalue	"PartAmp2"
		gkPartAmp3	invalue	"PartAmp3"
		gkPartAmp4	invalue	"PartAmp4"
		gkPartAmp5	invalue	"PartAmp5"
		gkPartAmp6	invalue	"PartAmp6"
		gkPartAmp7	invalue	"PartAmp7"
		gkPartAmp8	invalue	"PartAmp8"
		gkPartAmp9	invalue	"PartAmp9"
		gkPartAmp10	invalue	"PartAmp10"
		gkfund		invalue	"Fund_Freq"
		gkfund		tablei	gkfund, giExp10000, 1
					outvalue	"Fund_Freq_Value", gkfund
		gkamp		invalue	"Amplitude"

		gkratio1		invalue	"Ratio1"
		gkratio2		invalue	"Ratio2"
		gkratio3		invalue	"Ratio3"
		gkratio4		invalue	"Ratio4"
		gkratio5		invalue	"Ratio5"
		gkratio6		invalue	"Ratio6"
		gkratio7		invalue	"Ratio7"
		gkratio8		invalue	"Ratio8"
		gkratio9		invalue	"Ratio9"
		gkratio10		invalue	"Ratio10"

		gkampatt1		invalue	"Attack1"
		gkampatt2		invalue	"Attack2"
		gkampatt3		invalue	"Attack3"
		gkampatt4		invalue	"Attack4"
		gkampatt5		invalue	"Attack5"
		gkampatt6		invalue	"Attack6"
		gkampatt7		invalue	"Attack7"
		gkampatt8		invalue	"Attack8"
		gkampatt9		invalue	"Attack9"
		gkampatt10	invalue	"Attack10"

		gkampdec1		invalue	"Decay1"
		gkampdec2		invalue	"Decay2"
		gkampdec3  	invalue	"Decay3"
		gkampdec4		invalue	"Decay4"
		gkampdec5		invalue	"Decay5"
		gkampdec6		invalue	"Decay6"
		gkampdec7		invalue	"Decay7"
		gkampdec8		invalue	"Decay8"
		gkampdec9		invalue	"Decay9"
		gkampdec10	invalue	"Decay10"

		gkamprel1		invalue	"Release1"
		gkamprel2		invalue	"Release2"
		gkamprel3		invalue	"Release3"
		gkamprel4		invalue	"Release4"
		gkamprel5		invalue	"Release5"
		gkamprel6		invalue	"Release6"
		gkamprel7		invalue	"Release7"
		gkamprel8		invalue	"Release8"
		gkamprel9		invalue	"Release9"
		gkamprel10	invalue	"Release10"
	endif
endin

instr 	1	;SYNTHESIS INSTRUMENT
	if p4!=0 then														;MIDI
		ioct		= p4													;READ OCT VALUE FROM MIDI INPUT
		iamp		= p5													;READ IN A NOTE VELOCITY VALUE FROM THE MIDI INPUT
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

	;AMPLITUDE ENVELOPES (WITH MIDI RELEASE SEGMENT)
	aenv1		expsegr	.001, i(gkampatt1), 1.001, i(gkampdec1), .001, i(gkamprel1), .001
	aenv2		expsegr	.001, i(gkampatt2), 1.001, i(gkampdec2), .001, i(gkamprel2), .001
	aenv3		expsegr	.001, i(gkampatt3), 1.001, i(gkampdec3), .001, i(gkamprel3), .001
	aenv4		expsegr	.001, i(gkampatt4), 1.001, i(gkampdec4), .001, i(gkamprel4), .001
	aenv5		expsegr	.001, i(gkampatt5), 1.001, i(gkampdec5), .001, i(gkamprel5), .001
	aenv6		expsegr	.001, i(gkampatt6), 1.001, i(gkampdec6), .001, i(gkamprel6), .001
	aenv7		expsegr	.001, i(gkampatt7), 1.001, i(gkampdec7), .001, i(gkamprel7), .001
	aenv8		expsegr	.001, i(gkampatt8), 1.001, i(gkampdec8), .001, i(gkamprel8), .001
	aenv9		expsegr	.001, i(gkampatt9), 1.001, i(gkampdec9), .001, i(gkamprel9), .001
	aenv10		expsegr	.001, i(gkampatt10),1.001, i(gkampdec10),.001, i(gkamprel10), .001
	
	;SEPARATE OSCILLATORS CREATE EACH OF THE PARTIALS (NOTE THAT FLTK VERTICAL SLIDERS ARE INVERTED TO ALLOW MINIMUM VALUES TO BE LOWEST ON THE SCREEN)
	;OUTPUT		OPCODE	AMPLITUDE	                      	  | FREQUENCY    | FUNCTION_TABLE
	apart1		oscili	kamp*(aenv1  - 0.001) * gkPartAmp1,  kfund*gkratio1, 	gisine
	apart2		oscili	kamp*(aenv2  - 0.001) * gkPartAmp2,  kfund*gkratio2, 	gisine
	apart3		oscili	kamp*(aenv3  - 0.001) * gkPartAmp3,  kfund*gkratio3, 	gisine
	apart4		oscili	kamp*(aenv4  - 0.001) * gkPartAmp4,  kfund*gkratio4, 	gisine
	apart5		oscili	kamp*(aenv5  - 0.001) * gkPartAmp5,  kfund*gkratio5, 	gisine
	apart6		oscili	kamp*(aenv6  - 0.001) * gkPartAmp6,  kfund*gkratio6, 	gisine
	apart7		oscili	kamp*(aenv7  - 0.001) * gkPartAmp7,  kfund*gkratio7, 	gisine
	apart8		oscili	kamp*(aenv8  - 0.001) * gkPartAmp8,  kfund*gkratio8, 	gisine
	apart9		oscili	kamp*(aenv9  - 0.001) * gkPartAmp9,  kfund*gkratio9, 	gisine
	apart10      	oscili	kamp*(aenv10 - 0.001) * gkPartAmp10, kfund*gkratio10, 	gisine
	                                                          
	;SUM THE 10 OSCILLATORS:
	amix			sum		apart1,\
						apart2,\
						apart3,\
						apart4,\
						apart5,\
						apart6,\
						apart7,\
						apart8,\
						apart9,\
						apart10
				
				outs		amix, amix	;SEND MIXED SIGNAL TO THE OUTPUTS
endin

instr 	3	;INIT
		outvalue	"PartAmp1",	.05
		outvalue	"PartAmp2",	.1
		outvalue	"PartAmp3",	.23
		outvalue	"PartAmp4",	1.0 
		outvalue	"PartAmp5",	.2
		outvalue	"PartAmp6",	.18
		outvalue	"PartAmp7",	.1
		outvalue	"PartAmp8",	.067
		outvalue	"PartAmp9",	.05 
		outvalue	"PartAmp10",	.3
		outvalue	"Ratio1",		272/437
		outvalue	"Ratio2",		538/437
		outvalue	"Ratio3",		874/437
		outvalue	"Ratio4",		1281/437
		outvalue	"Ratio5",		1755/437
		outvalue	"Ratio6",		2264/437
		outvalue	"Ratio7",		2813/437
		outvalue	"Ratio8",		3389/437
		outvalue	"Ratio9",		4822/437
		outvalue	"Ratio10",	5255/437	
		outvalue	"Attack1",	.003
		outvalue	"Attack2",	.003
		outvalue	"Attack3",	.003
		outvalue	"Attack4",	.003
		outvalue	"Attack5",	.003
		outvalue	"Attack6",	.003
		outvalue	"Attack7",	.003
		outvalue	"Attack8",	.003
		outvalue	"Attack9",	.003
		outvalue	"Attack10",	.003
		outvalue	"Decay1",		4.5	
		outvalue	"Decay2",		7.22
		outvalue	"Decay3",		9.26
		outvalue	"Decay4",		9.42
		outvalue	"Decay5",		8.7	
		outvalue	"Decay6",		4.98
		outvalue	"Decay7",		4.5	
		outvalue	"Decay8",		2.22
		outvalue	"Decay9",		2.42
		outvalue	"Decay10",	1.34
		outvalue	"Release1",	.3
		outvalue	"Release2",	.4	
		outvalue	"Release3",	.5	
		outvalue	"Release4",	.32	
		outvalue	"Release5",	.25	
		outvalue	"Release6",	.1	
		outvalue	"Release7",	.04	
		outvalue	"Release8",	.02	
		outvalue	"Release9",	.01
		outvalue	"Release10",	.005
		outvalue	"Fund_Freq",	0.4962345		;437 Hz
		outvalue	"Amplitude",	0.3 
endin
</CsInstruments>
<CsScore>
i 10 0 3600	;GUI
i 3 0 0		;INIT
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>463</x>
 <y>133</y>
 <width>964</width>
 <height>638</height>
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
  <width>612</width>
  <height>588</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Inharmonic Additive Synthesis</label>
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
  <x>181</x>
  <y>54</y>
  <width>20</width>
  <height>250</height>
  <uuid>{a2478686-0cb1-4081-896c-03397bd19331}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>PartAmp1</objectName2>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>93</x>
  <y>306</y>
  <width>347</width>
  <height>29</height>
  <uuid>{ab0e7272-d733-4ebb-bb0e-5be83cf2d34d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Partial Strength:    1      2      3      4      5      6      7      8      9     10 </label>
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
  <x>205</x>
  <y>54</y>
  <width>20</width>
  <height>250</height>
  <uuid>{fdb44389-5b7d-408b-86f5-c6817a697505}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>PartAmp2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.10000000</yValue>
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
  <x>229</x>
  <y>54</y>
  <width>20</width>
  <height>250</height>
  <uuid>{20a90144-827d-437e-8a8f-9c6cd9e2a87f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>PartAmp3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.23000000</yValue>
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
  <x>253</x>
  <y>54</y>
  <width>20</width>
  <height>250</height>
  <uuid>{92d15a4b-d582-4ae2-8fb2-c0993d808c34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>PartAmp4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>1.00000000</yValue>
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
  <x>277</x>
  <y>54</y>
  <width>20</width>
  <height>250</height>
  <uuid>{9a9e0651-0fc3-4772-ab39-364cac49aaae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>PartAmp5</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.20000000</yValue>
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
  <x>301</x>
  <y>54</y>
  <width>20</width>
  <height>250</height>
  <uuid>{dec8a20a-eadd-4a93-a400-bcb352406930}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>PartAmp6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.18000000</yValue>
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
  <x>325</x>
  <y>54</y>
  <width>20</width>
  <height>250</height>
  <uuid>{821ddbec-2c2c-418b-bef2-233c1c69fb97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>PartAmp7</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.10000000</yValue>
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
  <x>349</x>
  <y>54</y>
  <width>20</width>
  <height>250</height>
  <uuid>{238d4c2c-a4cd-4595-bfed-328db8c4bddf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>PartAmp8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.06700000</yValue>
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
  <y>54</y>
  <width>20</width>
  <height>250</height>
  <uuid>{90c161db-14bf-4937-b50b-44a6002eb02b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>PartAmp9</objectName2>
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
  <y>54</y>
  <width>20</width>
  <height>250</height>
  <uuid>{95e1897f-d796-4dba-8b9c-f382985a0a57}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
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
  <objectName>GUI_MIDI</objectName>
  <x>6</x>
  <y>6</y>
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
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Fund_Freq</objectName>
  <x>92</x>
  <y>334</y>
  <width>440</width>
  <height>27</height>
  <uuid>{086a860c-b45b-47f3-978f-2f6daac6338b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.49623450</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>92</x>
  <y>351</y>
  <width>157</width>
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
  <x>451</x>
  <y>351</y>
  <width>80</width>
  <height>23</height>
  <uuid>{30f36f54-9085-46d0-8f1f-4a4b89881919}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>436.998</label>
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
  <x>92</x>
  <y>372</y>
  <width>440</width>
  <height>27</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.30000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>92</x>
  <y>389</y>
  <width>156</width>
  <height>29</height>
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
  <x>452</x>
  <y>389</y>
  <width>80</width>
  <height>23</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.300</label>
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
  <x>616</x>
  <y>2</y>
  <width>305</width>
  <height>588</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Inharmonic Additive Synthesis</label>
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
  <x>621</x>
  <y>25</y>
  <width>295</width>
  <height>559</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------------------------
In inharmonic additive synthesis the partial spacings do not follow the harmonic series and so in this example each of the partials is individually tunable. The fundemental is defined using the 'Fundemental' slider. Note that the lowest partial is not necessarily the perceived fundemental of the tone. Curiously in the default timbre produced by this example, which is that of a tubular bell, the perceived fundemental of 437 Hz is not present at all!
The fundemental is actually 1 octave below the 3rd partial. The frequencies of subsequent partials are derived using ratios. A simple ADR envelope is implemented independently for each partial in order to permit the creation of dynamic spectra. This example is designed for producing percussive sounds only and therefore has no sustain portion in any of the amplitude envelopes. Setting 'decay' values very high will give the impression of a sustaining instrument.
Notice how, in general, the higher partials tend to decay quicker. Also when damped, i.e. if the envelopes enter their release stages, the higher partials tend to decay quicker. The data for the default sound in this example was derived from a sonogram sound analysis program. This example also allow pitch control from a MIDI keyboard by first activating the 'MIDI switch in the interface. In this mode the instrument will also respond to key velocity.</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>437</y>
  <width>60</width>
  <height>24</height>
  <uuid>{08031554-c1a9-4b27-8130-4d04bafdc3b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Ratio</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>479</y>
  <width>62</width>
  <height>24</height>
  <uuid>{4be78f0d-4f01-441d-8a19-bb2a66844582}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>518</y>
  <width>63</width>
  <height>25</height>
  <uuid>{7572a139-c5c0-4eb2-9d19-43e2c7d56009}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>556</y>
  <width>65</width>
  <height>26</height>
  <uuid>{431c99be-899e-4e1c-ae02-6cb36c3c367e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Attack1</objectName>
  <x>7</x>
  <y>459</y>
  <width>60</width>
  <height>24</height>
  <uuid>{b5c3455d-19dc-46a0-b238-41ef2d8a63b7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.0001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.003</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Attack2</objectName>
  <x>67</x>
  <y>459</y>
  <width>60</width>
  <height>24</height>
  <uuid>{c5db3750-db94-4e17-a234-89a814b9def8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.0001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.003</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Attack4</objectName>
  <x>187</x>
  <y>459</y>
  <width>60</width>
  <height>24</height>
  <uuid>{67a1a1c1-feb0-4fc0-baf5-8e4185bef4c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.0001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.003</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Attack3</objectName>
  <x>127</x>
  <y>459</y>
  <width>60</width>
  <height>24</height>
  <uuid>{c2082121-9dd3-451f-8391-ce3e7cd6662f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.0001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.003</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Attack7</objectName>
  <x>367</x>
  <y>459</y>
  <width>60</width>
  <height>24</height>
  <uuid>{cd9c12a1-b1f6-4f18-be9a-f98d4338101f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.0001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.003</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Attack8</objectName>
  <x>427</x>
  <y>459</y>
  <width>60</width>
  <height>24</height>
  <uuid>{cee1c633-28d2-4ad0-adaa-a8a8e31f2b5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.0001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.003</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Attack6</objectName>
  <x>307</x>
  <y>459</y>
  <width>60</width>
  <height>24</height>
  <uuid>{56748a87-f4e0-4168-8f52-5b9425b6a019}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.0001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.003</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Attack5</objectName>
  <x>247</x>
  <y>459</y>
  <width>60</width>
  <height>24</height>
  <uuid>{c0e6b910-1159-47d5-a820-98e29134997c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.0001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.003</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Attack10</objectName>
  <x>547</x>
  <y>459</y>
  <width>60</width>
  <height>24</height>
  <uuid>{b6c1a5fc-6e36-4f45-b6b5-0c3171d12b12}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.0001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.003</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Attack9</objectName>
  <x>487</x>
  <y>459</y>
  <width>60</width>
  <height>24</height>
  <uuid>{ac95a03e-fc2f-44a9-bc9e-2da9cdbb4e54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.0001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.003</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Ratio9</objectName>
  <x>487</x>
  <y>418</y>
  <width>60</width>
  <height>24</height>
  <uuid>{55ee48d6-0187-430a-bfb4-11417a699680}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>15</maximum>
  <randomizable group="0">false</randomizable>
  <value>11.0343</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Ratio10</objectName>
  <x>547</x>
  <y>418</y>
  <width>60</width>
  <height>24</height>
  <uuid>{a052133e-1e47-467d-9d8e-ba6931b7d9f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>15</maximum>
  <randomizable group="0">false</randomizable>
  <value>12.0252</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Ratio5</objectName>
  <x>247</x>
  <y>418</y>
  <width>60</width>
  <height>24</height>
  <uuid>{952bfb29-45b0-4fa4-8473-71df630e715f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>15</maximum>
  <randomizable group="0">false</randomizable>
  <value>4.01602</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Ratio6</objectName>
  <x>307</x>
  <y>418</y>
  <width>60</width>
  <height>24</height>
  <uuid>{b445bf02-cdb3-430b-ab5b-72afcf0c1d0e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>15</maximum>
  <randomizable group="0">false</randomizable>
  <value>5.18078</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Ratio8</objectName>
  <x>427</x>
  <y>418</y>
  <width>60</width>
  <height>24</height>
  <uuid>{69e80df2-0aff-4137-8c3c-d812f946356a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>15</maximum>
  <randomizable group="0">false</randomizable>
  <value>7.75515</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Ratio7</objectName>
  <x>367</x>
  <y>418</y>
  <width>60</width>
  <height>24</height>
  <uuid>{0e0a9fe0-5108-46b0-a00e-9dee1f447865}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>15</maximum>
  <randomizable group="0">false</randomizable>
  <value>6.43707</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Ratio3</objectName>
  <x>127</x>
  <y>418</y>
  <width>60</width>
  <height>24</height>
  <uuid>{64c42576-f5fd-4c28-a0bf-b95344aa5b7d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>15</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Ratio4</objectName>
  <x>187</x>
  <y>418</y>
  <width>60</width>
  <height>24</height>
  <uuid>{9e2a581e-4acf-4619-853e-66ff28fe6bbb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>15</maximum>
  <randomizable group="0">false</randomizable>
  <value>2.93135</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Ratio2</objectName>
  <x>67</x>
  <y>418</y>
  <width>60</width>
  <height>24</height>
  <uuid>{d631e600-a331-4510-888a-a95a4cdf4c35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>15</maximum>
  <randomizable group="0">false</randomizable>
  <value>1.23112</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Ratio1</objectName>
  <x>7</x>
  <y>418</y>
  <width>60</width>
  <height>24</height>
  <uuid>{150e8605-5191-45a5-a294-797af2d7888c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.125</minimum>
  <maximum>15</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.622426</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Release9</objectName>
  <x>487</x>
  <y>537</y>
  <width>60</width>
  <height>24</height>
  <uuid>{ceb2ebd6-b322-4064-8c4c-0b201a81a16e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.01</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Release10</objectName>
  <x>547</x>
  <y>537</y>
  <width>60</width>
  <height>24</height>
  <uuid>{6340cbdc-13d5-49d3-bfa9-52b8856e3f15}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.005</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Release5</objectName>
  <x>247</x>
  <y>537</y>
  <width>60</width>
  <height>24</height>
  <uuid>{9ec8d741-c65a-429b-b3a0-725cb532d245}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.25</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Release6</objectName>
  <x>307</x>
  <y>537</y>
  <width>60</width>
  <height>24</height>
  <uuid>{b95ac3ec-2423-4731-a322-7dd1ea660052}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Release8</objectName>
  <x>427</x>
  <y>537</y>
  <width>60</width>
  <height>24</height>
  <uuid>{56f54488-7d61-404c-8625-638825975717}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.02</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Release7</objectName>
  <x>367</x>
  <y>537</y>
  <width>60</width>
  <height>24</height>
  <uuid>{07b6107d-2904-424e-979f-549e275e6cff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.04</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Release3</objectName>
  <x>127</x>
  <y>537</y>
  <width>60</width>
  <height>24</height>
  <uuid>{47b9dff4-78bd-4ddd-8d7e-50dc7249baff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Release4</objectName>
  <x>187</x>
  <y>537</y>
  <width>60</width>
  <height>24</height>
  <uuid>{fefc5bd7-c4fe-4f78-a2ba-743746f1e319}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.32</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Release2</objectName>
  <x>67</x>
  <y>537</y>
  <width>60</width>
  <height>24</height>
  <uuid>{818839cd-58f8-4fc5-8f44-ced0a4ec72db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.4</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Release1</objectName>
  <x>7</x>
  <y>537</y>
  <width>60</width>
  <height>24</height>
  <uuid>{8f773041-929b-435f-8d17-69f54ec907de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Decay1</objectName>
  <x>7</x>
  <y>498</y>
  <width>60</width>
  <height>24</height>
  <uuid>{fe4802f2-a517-4a43-bad0-6cf90ee432aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>30</maximum>
  <randomizable group="0">false</randomizable>
  <value>4.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Decay2</objectName>
  <x>67</x>
  <y>498</y>
  <width>60</width>
  <height>24</height>
  <uuid>{a382301e-950a-4fe5-ab2f-e61cb2866019}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>30</maximum>
  <randomizable group="0">false</randomizable>
  <value>7.22</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Decay4</objectName>
  <x>187</x>
  <y>498</y>
  <width>60</width>
  <height>24</height>
  <uuid>{b5b261e0-e0da-49a7-b06f-3ab105131803}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>30</maximum>
  <randomizable group="0">false</randomizable>
  <value>9.42</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Decay3</objectName>
  <x>127</x>
  <y>498</y>
  <width>60</width>
  <height>24</height>
  <uuid>{129cf9dd-0e95-47e3-bc2c-3fcda5598d88}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>30</maximum>
  <randomizable group="0">false</randomizable>
  <value>9.26</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Decay7</objectName>
  <x>367</x>
  <y>498</y>
  <width>60</width>
  <height>24</height>
  <uuid>{53f95b7a-9805-46ea-8519-bd83ef160fa7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>30</maximum>
  <randomizable group="0">false</randomizable>
  <value>4.5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Decay8</objectName>
  <x>427</x>
  <y>498</y>
  <width>60</width>
  <height>24</height>
  <uuid>{4fc1e7dc-12ba-4f0d-80cc-6fe3ff16e7b7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>30</maximum>
  <randomizable group="0">false</randomizable>
  <value>2.22</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Decay6</objectName>
  <x>307</x>
  <y>498</y>
  <width>60</width>
  <height>24</height>
  <uuid>{97b405e8-f000-4483-a1f5-3577b3157af0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>30</maximum>
  <randomizable group="0">false</randomizable>
  <value>4.98</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Decay5</objectName>
  <x>247</x>
  <y>498</y>
  <width>60</width>
  <height>24</height>
  <uuid>{f9901a43-c0e3-47b3-9e31-f1c5a7da1762}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>30</maximum>
  <randomizable group="0">false</randomizable>
  <value>8.7</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Decay10</objectName>
  <x>547</x>
  <y>498</y>
  <width>60</width>
  <height>24</height>
  <uuid>{ff498b52-0632-44fc-ac27-66d239290bfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>30</maximum>
  <randomizable group="0">false</randomizable>
  <value>1.34</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Decay9</objectName>
  <x>487</x>
  <y>498</y>
  <width>60</width>
  <height>24</height>
  <uuid>{6e96b539-4078-4497-807a-5c9b85c89981}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>0.001</minimum>
  <maximum>30</maximum>
  <randomizable group="0">false</randomizable>
  <value>2.42</value>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

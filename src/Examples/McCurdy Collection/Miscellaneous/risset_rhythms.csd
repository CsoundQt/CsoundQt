;Written by Iain McCurdy, 2009

;Modified for QuteCsound by René, February 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table for exp slider
;	Add Browser for audio files, accept mono or stereo wav files (only channel 1 is used)
;	Replace (1-kenv_n) by (kenv_n) in instr 3
;	Changed instr 2, can't hide / show widgets from orc
;	Used reinit in instr 3  


/*                                                 risset rhythms
	--------------------------------------------------------------------------------------------------------------------------
	Risset rhythms is a variation of the Shepard-Risset Glissando which employs a rhythmic loop instead of a sine tone.
	This implementation uses speed control of sampled loops to vary tempo, therefore pitch as well as tempo is modulated.

	A repeating loop fades in as it gradually increases in tempo (and pitch). By the time it has doubled its tempo (and risen
	in pitch by an octave) a second layer of this loop is faded in at the same initial tempo of the original layer. It then
	follows the trajectory of the first layer, always half its tempo (and an octave lower). As the layers get faster and
	faster, they eventually fade out, just as they faded in. As many layers can be used as desired but the greater the number
	of layers, the greater the range of tempi (& pitch) covered. The effect of this should be a cognative contradiction in
	which, from moment to moment, the music appears to be getting faster, but over the longer term doesn't get faster.
	A frequently cited visual analog is that of the spinning barber's pole in which parallel lines appear to be rising but
	obviously aren't.
	In this implementation 'Rate' controls the rate of acceleration of the loops. One period will be the time it
	take for a loop to begin fading in at its lowest tempo, to when it finally fades our at its highest tempo. Negative
	values here will result in loops slowing down (getting lower in pitch). The greater the number of layers employed the
	greater the rate of acceleration will appear as each loop will cover a greater range of tempi from fading in to fading out.
	Careful tuning of the 'Number of Layers' and 'Rate' is needed to properly create the illusion. Setting rate too high
	will reveal the workings of the illusion.
	The amplitudes of each of the layers are adjustable using the numbered sliders. These are normally all left at maximum but
	listening to one layer on its own can help in understanding the mechanism of this example. The yellow bars indicate how
	the different layers fade in and out.
	A choice of amplitude window functions are available. These determine exactly how each layer fades in and out.
	A choice of four source loops are provided (including a sine tone which allows creation of the Shepard-Risset Glissando).
	'Global Speed' scales the speed of all layers equally.
*/                                                                                


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 32		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


giExp1		ftgen	0, 0, 129, -25, 0, 0.25, 128, 4.0	;TABLE FOR EXP SLIDER

giAmpWindow1	ftgen	11, 0, 131073, 9, 0.5, 1, 0		;HALF SINE
giAmpWindow2	ftgen	12, 0, 131073, 20, 3, 1			;BARTLETT (TRIANGLE)
giAmpWindow3	ftgen	13, 0, 131073, 20,  5, 1			;BLACKMAN-HARRIS

giLongSine		ftgen	0, 0, 131073, 9, 1200, 1, 0

instr	1	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;SLIDERS
		gkrate	invalue 	"Rate"
		kGSpeed	invalue 	"GSpeed"
		gkGSpeed	tablei	kGSpeed, giExp1, 1
				outvalue	"GSpeed_Value", gkGSpeed

		gk1		invalue 	"K1"
		gk2		invalue 	"K2"
		gk3		invalue 	"K3"
		gk4		invalue 	"K4"
		gk5		invalue 	"K5"
		gk6		invalue 	"K6"
		gk7		invalue 	"K7"
		gk8		invalue 	"K8"

		gkOutGain	invalue	"OutGain"

		;COUNTERS
		gklayers		invalue  "Layers"
		ktrig_layer	changed	gklayers
					schedkwhen	ktrig_layer, 0, 0, 2, 0, .1		;RESTART INSTRUMENT 2

		gkSineOnOff	invalue	"SineOnOff"
		
		;MENUS
		gkAmpWindow	invalue	"AmpWindow"

;AUDIO FILE CHANGE / LOAD IN TABLES ********************************************************************************************************
		Sfile_new		strcpy	""								;INIT TO EMPTY STRING
		Sfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	Sfile
		kfile 		strcmpk	Sfile_new, Sfile_old

		gkfile_new	init		0
		if	kfile != 0	then									;IF A BANG HAD BEEN GENERATED IN THE LINE ABOVE
			gkfile_new	=	1								;Flag to inform instr 1 that a new file is loaded
				reinit	NEW_FILE								;REINITIALIZE FROM LABEL 'NEW_FILE'
		endif
		NEW_FILE:
		ilen		filelen	Sfile								;Find length
		isr		filesr	Sfile								;Find sample rate
		isamps	=		ilen * isr							;Total number of samples

		isize	init		1
		LOOP:
		isize	=		isize * 2
		if (isize < isamps) igoto LOOP							;Loop until isize is greater than number of samples

		giloop	ftgen	0, 0, isize, 1, Sfile, 0, 0, 1			;READ AUDIO FILE CHANNEL 1
;*******************************************************************************************************************************************
	endif
endin

instr	2
	ilayers	init	i(gklayers)
	
	if	ilayers < 3	then
		outvalue	"K3",   0
		outvalue	"Amp3", 0
	endif
	if	ilayers < 4	then
		outvalue	"K4",   0
		outvalue	"Amp4", 0
	endif
	if	ilayers < 5	then
		outvalue	"K5",   0
		outvalue	"Amp5", 0
	endif
	if	ilayers < 6	then
		outvalue	"K6",   0
		outvalue	"Amp6", 0
	endif	
	if	ilayers < 7	then
		outvalue	"K7",   0
		outvalue	"Amp7", 0
	endif
	if	ilayers < 8	then
		outvalue	"K8",   0
		outvalue	"Amp8", 0
	endif
endin

instr	3
		kSwitch	changed		gkAmpWindow, gklayers,gkSineOnOff	

		if gkfile_new == 1 || kSwitch == 1 then
			gkfile_new = 0
			reinit	REINIT
		endif

	REINIT:
    	if	i(gkSineOnOff)==1 then
    		ifn	=	giLongSine
    		ilen	=	ftlen(ifn)
    	else
    		ifn	=	giloop
		ilen			=	nsamp(ifn)
	endif
	
	iAmpWindow	=	i(gkAmpWindow)+11
	kSpeedRatio	=	sr*gkGSpeed/ilen	;PLAYBACK SPEED RATIO BASED ON FILE LENGTH AND 'GLOBAL SPEED' SLIDER
	ilayers		=	i(gklayers)

	kupdate		metro	20
	
	
	
	aout		init	0			;ACCUMULATING AUDIO VARIABLE INITIALISED

	;CREATE FIRST LAYER
	kspeed1	phasor	gkrate				;PHASOR THAT TRACES AMPLITUDE ENVELOPE
	kenv1	tablei	kspeed1, iAmpWindow, 1		;AMPLITUDE ENVELOPE
	if kupdate == 1	then
			outvalue	"Amp1", kenv1
	endif
	kratio1	=		octave((kspeed1*ilayers)-(ilayers*.5))	;MOVING PLAYBACK RATIO
	aptr1	phasor	kratio1*kSpeedRatio		;PHASOR THAT TRACES MOVEMENT THROUGH THE SOUND FILE
	asig1	tablei	aptr1*ilen, ifn			;READ AUDIO FROM TABLE
	aout	=	aout + (asig1*kenv1*gk1)	;ADD AUDIO TO ACCUMULATING AUDIO VARIABLE

;MACRO DEFINED FOR ALL SUBSEQUENT LAYERS
#define	LAYER(N)
	#
	kspeed$N	phasor	gkrate, ($N-1)/ilayers				;PHASOR THAT TRACES AMPLITUDE ENVELOPE
	kenv$N	tablei	kspeed$N, iAmpWindow, 1                                 ;AMPLITUDE ENVELOPE                   
	if kupdate == 1	then
			outvalue	"Amp$N", kenv$N
	endif
	kratio$N	=	octave((kspeed$N*ilayers)-(ilayers*.5))		;MOVING PLAYBACK RATIO
	aptr$N		phasor	kratio$N*kSpeedRatio				;PHASOR THAT TRACES MOVEMENT THROUGH THE SOUND FILE
	asig$N		tablei	aptr$N*ilen, ifn		                ;READ AUDIO FROM TABLE                             
	aout	=	aout + (asig$N*kenv$N*gk$N)                             ;ADD AUDIO TO ACCUMULATING AUDIO VARIABLE          
	if	gklayers==$N	goto	FINISH					;IF THIS IS THE FINAL LAYER JUMP TO 'FINISH' LABEL
	#
	;EXECUTE MACRO MULTIPLE TIMES
	$LAYER(2)
	$LAYER(3)
	$LAYER(4)
	$LAYER(5)
	$LAYER(6)
	$LAYER(7)
	$LAYER(8)

	FINISH:									;'FINISH' LABEL
	outs	aout*gkOutGain, aout*gkOutGain					;SEND AUDIO TO OUTPUTS
	clear	aout								;CLEAR ACCUMULATING AUDIO VARIABLE
endin                                    
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 1		0		3600		;GUI
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>207</x>
 <y>248</y>
 <width>820</width>
 <height>364</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>241</r>
  <g>226</g>
  <b>185</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>807</width>
  <height>323</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>risset rhythms</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>64</y>
  <width>200</width>
  <height>30</height>
  <uuid>{5cde19f3-b356-4945-9c8b-43dd67c604dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate (hertz)</label>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Rate</objectName>
  <x>8</x>
  <y>41</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d6d73a88-8d82-47de-a067-758f1917a3f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-0.10000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.00880000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Rate</objectName>
  <x>448</x>
  <y>64</y>
  <width>60</width>
  <height>30</height>
  <uuid>{073ad371-9227-46fa-a005-ac10a210db79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.009</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>285</y>
  <width>200</width>
  <height>30</height>
  <uuid>{b6afbe1e-677c-44a6-ba84-4c32dc21b0a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Gain</label>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>OutGain</objectName>
  <x>8</x>
  <y>262</y>
  <width>500</width>
  <height>27</height>
  <uuid>{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>OutGain</objectName>
  <x>448</x>
  <y>285</y>
  <width>60</width>
  <height>30</height>
  <uuid>{95f6cb02-77ec-46fe-876b-a93efac3c5e5}</uuid>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>116</y>
  <width>200</width>
  <height>30</height>
  <uuid>{3ebc1139-1fdb-48dc-9150-49ee8dfdbd4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Global Speed</label>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>GSpeed</objectName>
  <x>8</x>
  <y>93</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2cf97843-5b49-438e-8034-62a459597e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>GSpeed_Value</objectName>
  <x>448</x>
  <y>116</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e54486c5-f9aa-4d0e-9a67-6506dae3c790}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>AmpWindow</objectName>
  <x>182</x>
  <y>215</y>
  <width>150</width>
  <height>30</height>
  <uuid>{8ea371ed-50f1-450f-b078-4a586bcef87b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Half-sine</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Bartlett (triangle)</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Blackman-Harris</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>523</x>
  <y>41</y>
  <width>275</width>
  <height>272</height>
  <uuid>{bdd673e3-e25a-40f8-863d-d577728cfcd3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LAYERS MIXER</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
 <bsbObject type="BSBController" version="2">
  <objectName>K2</objectName>
  <x>552</x>
  <y>114</y>
  <width>240</width>
  <height>16</height>
  <uuid>{87938e2d-58f8-4df2-980a-5d9e090cde92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.57500000</xValue>
  <yValue>0.48888889</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>552</x>
  <y>285</y>
  <width>30</width>
  <height>30</height>
  <uuid>{798870a8-da25-4230-ab04-fec3e1af83de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>54</x>
  <y>220</y>
  <width>120</width>
  <height>24</height>
  <uuid>{6decaf4d-be74-4edb-8815-51176aca4329}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude Windows:</label>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>Layers</objectName>
  <x>687</x>
  <y>60</y>
  <width>40</width>
  <height>30</height>
  <uuid>{8cd8a941-663d-42a8-8506-9d6f626ee7ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>560</x>
  <y>69</y>
  <width>120</width>
  <height>24</height>
  <uuid>{6360df02-ee77-4887-8a80-c42cec1f9e0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>No of Layers:</label>
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
 <bsbObject type="BSBController" version="2">
  <objectName>K3</objectName>
  <x>552</x>
  <y>132</y>
  <width>240</width>
  <height>16</height>
  <uuid>{2449a622-bff3-4423-8025-19b452abe8f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.56250000</xValue>
  <yValue>0.48888889</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>K4</objectName>
  <x>552</x>
  <y>150</y>
  <width>240</width>
  <height>16</height>
  <uuid>{8edf0689-9c06-43a5-9304-60021e1a7281}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.57083333</xValue>
  <yValue>0.48888889</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>K5</objectName>
  <x>552</x>
  <y>168</y>
  <width>240</width>
  <height>16</height>
  <uuid>{a05e924d-d1eb-4261-a87a-7f5cad5f1018}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.57083333</xValue>
  <yValue>0.48888889</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>K6</objectName>
  <x>552</x>
  <y>186</y>
  <width>240</width>
  <height>16</height>
  <uuid>{90e7ff59-af14-4d0a-b77d-7907420d4a0a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.57500000</xValue>
  <yValue>0.48888889</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>K1</objectName>
  <x>552</x>
  <y>96</y>
  <width>240</width>
  <height>16</height>
  <uuid>{847a0055-8bb1-4c09-bbff-6ef4ddc2ac35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.57916667</xValue>
  <yValue>0.48888889</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>K7</objectName>
  <x>552</x>
  <y>204</y>
  <width>240</width>
  <height>16</height>
  <uuid>{0b424caa-b6b4-440e-abf4-5fc04007bd83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.58333333</xValue>
  <yValue>0.48888889</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>K8</objectName>
  <x>552</x>
  <y>222</y>
  <width>240</width>
  <height>16</height>
  <uuid>{a13d9481-85ce-4591-8154-5b34ea77066a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55416667</xValue>
  <yValue>0.48888889</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>552</x>
  <y>239</y>
  <width>30</width>
  <height>45</height>
  <uuid>{4ed33452-74d6-481f-ab08-99d86950b729}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55833333</xValue>
  <yValue>0.41300270</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>582</x>
  <y>239</y>
  <width>30</width>
  <height>45</height>
  <uuid>{7456792e-e3fa-44bc-9eca-254789bbd30b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55833333</xValue>
  <yValue>0.73008597</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>612</x>
  <y>239</y>
  <width>30</width>
  <height>45</height>
  <uuid>{bdc55483-bac8-4356-8568-0f085cf23840}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55833333</xValue>
  <yValue>0.93602026</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>642</x>
  <y>239</y>
  <width>30</width>
  <height>45</height>
  <uuid>{ed3ff9dc-cd52-4a83-bc59-300ac50a5a12}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55833333</xValue>
  <yValue>0.99945396</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>672</x>
  <y>239</y>
  <width>30</width>
  <height>45</height>
  <uuid>{e456eef8-e8c9-4cde-8fbc-9aa0ca7ef708}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp5</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55833333</xValue>
  <yValue>0.91072983</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>702</x>
  <y>239</y>
  <width>30</width>
  <height>45</height>
  <uuid>{02f47c9e-dd19-4146-a821-3b672486d860}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55833333</xValue>
  <yValue>0.68335539</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>732</x>
  <y>239</y>
  <width>30</width>
  <height>45</height>
  <uuid>{26034605-de9c-4c45-8006-90c83afd6e37}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp7</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55833333</xValue>
  <yValue>0.35194626</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>762</x>
  <y>239</y>
  <width>30</width>
  <height>45</height>
  <uuid>{efab70b7-bf62-444a-add8-cb13edf74538}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Amp8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.55833333</xValue>
  <yValue>0.03304354</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>582</x>
  <y>285</y>
  <width>30</width>
  <height>30</height>
  <uuid>{edb43afc-4c3b-4bfb-8b14-e0c3de800f9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>612</x>
  <y>285</y>
  <width>30</width>
  <height>30</height>
  <uuid>{9a73d3de-64ba-41d4-b029-0d006db924a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>642</x>
  <y>285</y>
  <width>30</width>
  <height>30</height>
  <uuid>{dbef6f26-d72f-4079-b78e-221bbcb15520}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>672</x>
  <y>285</y>
  <width>30</width>
  <height>30</height>
  <uuid>{840b415c-78ab-4e76-b8b7-6e94ac7819ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>702</x>
  <y>285</y>
  <width>30</width>
  <height>30</height>
  <uuid>{d0fa83ca-1cff-4e4c-8d10-cf96de27eef3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>732</x>
  <y>285</y>
  <width>30</width>
  <height>30</height>
  <uuid>{eccf5c79-9abc-4e93-8e1b-60f9b3cf78a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>762</x>
  <y>285</y>
  <width>30</width>
  <height>30</height>
  <uuid>{6d8b1231-bf33-49ec-953d-4dbf4b873582}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>521</x>
  <y>94</y>
  <width>30</width>
  <height>30</height>
  <uuid>{077611e5-8912-4129-8886-2ca33c4fd0b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>521</x>
  <y>112</y>
  <width>30</width>
  <height>30</height>
  <uuid>{7526ec67-8b53-4407-8418-6c72539ad95b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>521</x>
  <y>130</y>
  <width>30</width>
  <height>30</height>
  <uuid>{d8869704-3682-4c0d-9981-49e27e937907}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>521</x>
  <y>148</y>
  <width>30</width>
  <height>30</height>
  <uuid>{d6d5cc99-71a5-4d1a-b5c6-3469d1598993}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>521</x>
  <y>166</y>
  <width>30</width>
  <height>30</height>
  <uuid>{71605fc2-1d80-46f2-84e3-78192116c5d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>521</x>
  <y>183</y>
  <width>30</width>
  <height>30</height>
  <uuid>{859d0add-2499-458a-b3e3-4ba103e72bac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>521</x>
  <y>202</y>
  <width>30</width>
  <height>30</height>
  <uuid>{4c9d9007-6734-407b-b0ca-1ecbcdf05fde}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>521</x>
  <y>222</y>
  <width>30</width>
  <height>30</height>
  <uuid>{5bdebd1c-cb56-4ba1-a795-1dfd9359363c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8</label>
  <alignment>center</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>147</y>
  <width>60</width>
  <height>24</height>
  <uuid>{75126f09-53b9-4498-862c-fcf60551bf39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Source:</label>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>169</y>
  <width>170</width>
  <height>30</height>
  <uuid>{1757a18f-b418-4ef1-984d-bdee5e985805}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>MFEM.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse</objectName>
  <x>178</x>
  <y>170</y>
  <width>330</width>
  <height>28</height>
  <uuid>{804f4f24-03f1-4ac2-8ba2-697f15df06cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MFEM.wav</label>
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
   <r>235</r>
   <g>232</g>
   <b>228</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName/>
  <x>8</x>
  <y>10</y>
  <width>109</width>
  <height>30</height>
  <uuid>{acd14897-b49e-4b3e-93d7-fa6e52da70aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    On / Off</text>
  <image>/</image>
  <eventLine>i3 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>SineOnOff</objectName>
  <x>340</x>
  <y>214</y>
  <width>164</width>
  <height>32</height>
  <uuid>{134b8425-c4e0-4077-9630-678ac8d71669}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Sine Wave On / Off</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

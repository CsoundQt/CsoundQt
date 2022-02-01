;Written by Iain McCurdy, 2010

;Modified for QuteCsound by René, January 2011, updated Feb 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add tables for exp slider
;	Add Browser for audio files and use of FilePlay2 udo, now accept mono or stereo wav files
;	Removed "Instructions and Info Panel" for the gui to fit in a 1200x800 screen
;
;	                         compress
;	-----------------------------------------------------------------------------------------------------------------------------
;	'compress' is an opcode for dynamic processing of an audio signal. The signal used by the detector does not have to be
;	the same as the signal to which dynamics processing is applied thus enabling the effect 'ducking' heard commonly in
;	radio where the DJ cutting in with an announcement causes a dynamic dip in the music sound-bed.
;	'compress' incorporates a noise gate, the threshold of which is controlled with the 'Noise Gate Threshold' slider.
;	The 'Attack Time' and 'Release Time' sliders control the attack and release times of both the noise gate and the compressor.
;	'Ratio' controls the amount of compression or expansion that will be applied.
;	Values greater than 1 will apply higher degrees of compression, values less than 1 will dynamically
;	expand the signal increasingly, a ratio of 1 will leave the signal unaltered.
;	'Look Ahead Time' defines how far ahead the detector scans in order to pre-empt dynamic changes. What actually happens is
;	that the signal to which dynamics processing is applied is delayed with respect to the detection signal but the result is the same.
;	In this implementation the user can independently select the audio signal from which dynamics will be detected and the
;	signal to which dynamics processing will be applied.
;	The 'Detect Sig. Gain' slider allows the user to mix the detected signal into the output along with the compressed signal.
;	A number of presets are provided to demonstrate some basic applications of this opcode.


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)


;TABLES FOR EXP SLIDER
giExp1		ftgen	0, 0, 129, -25, 0, 0.001, 128, 1.0
giExp2		ftgen	0, 0, 129, -25, 0, 0.001, 128, 2.0
giExp100		ftgen	0, 0, 129, -25, 0, 0.125, 128, 100.0


opcode FilePlay2, aa, Skoo		; Credit to Joachim Heintz
	;gives stereo output regardless your soundfile is mono or stereo
	Sfil, kspeed, iskip, iloop	xin
	ichn		filenchnls	Sfil
	if ichn == 1 then
		aL		diskin2	Sfil, kspeed, iskip, iloop
		aR		=		aL
	else
		aL, aR	diskin2	Sfil, kspeed, iskip, iloop
	endif
		xout		aL, aR
endop


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkInGain		invalue	"Live_Gain"
		gkDetGain		invalue	"Detect_Gain"
		gkthresh		invalue	"Gate_Threshold"
		gkloknee		invalue	"Low_Knee"
		gkhiknee		invalue	"High_Knee"
		kratio		invalue	"Ratio"
		gkratio		tablei	kratio, giExp100, 1
					outvalue	"Ratio_Value", gkratio
		katt			invalue	"Attack"
		gkatt		tablei	katt, giExp1, 1
					outvalue	"Attack_Value", gkatt
		krel			invalue	"Release"
		gkrel		tablei	krel, giExp1, 1
					outvalue	"Release_Value", gkrel
		gklook		invalue	"Look_Ahead"
		kgain		invalue	"Gain"
		gkgain		tablei	kgain, giExp2, 1
					outvalue	"Gain_Value", gkgain
		gkinput		invalue	"Input"
		gkdetect		invalue	"Detect"
	endif
endin

instr	1
	Sfile1_new	strcpy	""								;INIT TO EMPTY STRING
	Sfile1		invalue	"_Browse1"
	Sfile1_old	strcpyk	Sfile1_new
	Sfile1_new	strcpyk	Sfile1
	kfile1 		strcmpk	Sfile1_new, Sfile1_old

	if	kfile1 != 0	then									;IF A BANG HAD BEEN GENERATED IN THE LINE ABOVE
			reinit	NEW_FILE1								;REINITIALIZE FROM LABEL 'NEW_FILE1'
	endif
		
	Sfile2_new	strcpy	""								;INIT TO EMPTY STRING
	Sfile2		invalue	"_Browse2"
	Sfile2_old	strcpyk	Sfile2_new
	Sfile2_new	strcpyk	Sfile2
	kfile2 		strcmpk	Sfile2_new, Sfile2_old

	if	kfile2 != 0	then									;IF A BANG HAD BEEN GENERATED IN THE LINE ABOVE
			reinit	NEW_FILE2								;REINITIALIZE FROM LABEL 'NEW_FILE2'
	endif

	if gkinput=0 then
		aasigL, aasigR	ins
		aasigL	=	aasigL*gkInGain
		aasigR	=	aasigR*gkInGain
	else
		NEW_FILE1:
		aasigL, aasigR	FilePlay2	Sfile1, 1, 0, 1
		rireturn
	endif
	
	if gkdetect=0 then
		acsigL, acsigR	ins
		acsigL	=	acsigL*gkInGain
		acsigR	=	acsigR*gkInGain
	else
		NEW_FILE2:
		acsigL, acsigR	FilePlay2	Sfile2, 1, 0, 1
		rireturn
	endif
	
	ktrig	changed	gklook
	if ktrig=1 then
		reinit	UPDATE
	endif
	UPDATE:
	;ar 		compress 	aasig, acsig,  kthresh,  kloknee,  khiknee,  kratio,  katt,  krel, ilook
	aCompL	compress	aasigL, acsigL, gkthresh, gkloknee, gkhiknee, gkratio, gkatt, gkrel, i(gklook)
	aCompR	compress	aasigR, acsigR, gkthresh, gkloknee, gkhiknee, gkratio, gkatt, gkrel, i(gklook)
			rireturn
			outs		(aCompL*gkgain)+(acsigL*gkDetGain), (aCompR*gkgain)+(acsigR*gkDetGain)
endin

instr	2	;PRESETS
		outvalue	"_SetPresetIndex", p4
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0	   3600	;GUI
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>326</x>
 <y>411</y>
 <width>1039</width>
 <height>351</height>
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
  <width>1037</width>
  <height>348</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>compress</label>
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
   <r>147</r>
   <g>154</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>8</y>
  <width>100</width>
  <height>30</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    On / Off</text>
  <image>/</image>
  <eventLine>i1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>42</y>
  <width>506</width>
  <height>98</height>
  <uuid>{cdc434d0-b9e7-4f6f-aa90-800ec76dced6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>10</x>
  <y>103</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>SynthPad.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>181</x>
  <y>104</y>
  <width>326</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>SynthPad.wav</label>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>331</x>
  <y>61</y>
  <width>120</width>
  <height>30</height>
  <uuid>{be1f1edc-082e-4433-a418-1e81baf4e305}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Live Input</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Audio File</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>78</y>
  <width>120</width>
  <height>30</height>
  <uuid>{2c897206-0dbc-47b5-ba68-915d83839ab6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Live Input Gain</label>
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
  <objectName>Live_Gain</objectName>
  <x>8</x>
  <y>61</y>
  <width>300</width>
  <height>27</height>
  <uuid>{304e78d8-b320-453a-b28f-86b0ca872b86}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Live_Gain</objectName>
  <x>248</x>
  <y>78</y>
  <width>60</width>
  <height>30</height>
  <uuid>{94c7e961-7981-4d21-942f-80bcc647daf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>142</y>
  <width>506</width>
  <height>98</height>
  <uuid>{f264412d-1014-4e65-bc0b-e8dabda1779d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Detect</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse2</objectName>
  <x>10</x>
  <y>203</y>
  <width>170</width>
  <height>30</height>
  <uuid>{fd6d018b-1bcd-43b4-88e9-f240b379d7d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>808loop.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse2</objectName>
  <x>181</x>
  <y>204</y>
  <width>326</width>
  <height>28</height>
  <uuid>{8616b387-3762-43e0-9492-10006eb9c01f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>808loop.wav</label>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Detect</objectName>
  <x>331</x>
  <y>161</y>
  <width>120</width>
  <height>30</height>
  <uuid>{78d0d7ed-0b48-41de-bec3-8b85723c1dd6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Live Input</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Audio File</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>178</y>
  <width>120</width>
  <height>30</height>
  <uuid>{5df5ef4b-3db4-4c45-a343-9a1a05ec99fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Detect Signal Gain</label>
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
  <objectName>Detect_Gain</objectName>
  <x>8</x>
  <y>161</y>
  <width>300</width>
  <height>27</height>
  <uuid>{59bb85ee-6e9a-4e00-9fd1-ace42baf2654}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Detect_Gain</objectName>
  <x>248</x>
  <y>178</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2c621be3-47b0-4dfd-9037-ef64aa6676df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>513</x>
  <y>42</y>
  <width>520</width>
  <height>302</height>
  <uuid>{326530f7-646b-4eec-923b-c87806f17ed9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>78</y>
  <width>180</width>
  <height>30</height>
  <uuid>{640b50b7-7200-4f81-8394-89d9843ae939}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Noise Gate Threshold (dB)</label>
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
  <objectName>Gate_Threshold</objectName>
  <x>516</x>
  <y>61</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>120.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gate_Threshold</objectName>
  <x>956</x>
  <y>78</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b731b52e-e14a-476a-a583-f3b2bd885539}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>242</y>
  <width>506</width>
  <height>102</height>
  <uuid>{557603bf-8a2a-4845-9090-466ac15ef873}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Presets</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>113</y>
  <width>180</width>
  <height>30</height>
  <uuid>{989564b0-b237-4c22-9d10-b76b7c7e4e4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Low Knee Break Point (dB)</label>
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
  <objectName>Low_Knee</objectName>
  <x>516</x>
  <y>96</y>
  <width>500</width>
  <height>27</height>
  <uuid>{84cd664e-fb67-4dd4-aac3-adbcf2c81fe6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>48.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Low_Knee</objectName>
  <x>956</x>
  <y>113</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ba8682a6-056f-4432-946b-4e3ee82c47a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>48.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>147</y>
  <width>180</width>
  <height>30</height>
  <uuid>{76044785-79c4-4202-b7ce-07aee4868219}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>High Knee Break Point (dB)</label>
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
  <objectName>High_Knee</objectName>
  <x>516</x>
  <y>130</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0f952e77-ff9b-4621-b1af-23252bb9c2a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>60.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>High_Knee</objectName>
  <x>956</x>
  <y>147</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7b92c0ca-2fe8-4b4f-9ed0-f618c1b3cb5c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>60.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>182</y>
  <width>180</width>
  <height>30</height>
  <uuid>{ca41878c-b561-486b-9cf9-d0da6b48448b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Ratio</label>
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
  <objectName>Ratio</objectName>
  <x>516</x>
  <y>165</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2800fb88-347a-402c-88ed-fc97af6a36be}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.55199999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Ratio_Value</objectName>
  <x>956</x>
  <y>182</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5d1ba94c-536a-4178-be6c-c0d9d2f75e3d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.007</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>217</y>
  <width>180</width>
  <height>30</height>
  <uuid>{cdd71125-b224-471a-9c41-9c05d8d28d0c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack Time (secs)</label>
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
  <objectName>Attack</objectName>
  <x>516</x>
  <y>200</y>
  <width>500</width>
  <height>27</height>
  <uuid>{7a83bb1f-f25d-47e0-bf2d-9c5c86e0756b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.22200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Attack_Value</objectName>
  <x>956</x>
  <y>217</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7f8d2709-bf8c-46ab-83f0-36fc620b0d56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.005</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>252</y>
  <width>180</width>
  <height>30</height>
  <uuid>{9519d46e-b6e4-422e-8653-ae5db12b1c04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release Time (secs)</label>
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
  <objectName>Release</objectName>
  <x>516</x>
  <y>235</y>
  <width>500</width>
  <height>27</height>
  <uuid>{0f9b569d-7f5b-4540-a415-6fd6762f6fe9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.66600001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Release_Value</objectName>
  <x>956</x>
  <y>252</y>
  <width>60</width>
  <height>30</height>
  <uuid>{df4e20a1-b9a6-46ca-bb02-911779f6b4b5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>286</y>
  <width>180</width>
  <height>30</height>
  <uuid>{1089c148-0c3a-497a-a8d5-a62e3d62ff54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Look Ahead Time (secs)</label>
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
  <objectName>Look_Ahead</objectName>
  <x>516</x>
  <y>269</y>
  <width>500</width>
  <height>27</height>
  <uuid>{cb90b71f-234b-4c3e-875b-ce04075ae3ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Look_Ahead</objectName>
  <x>956</x>
  <y>286</y>
  <width>60</width>
  <height>30</height>
  <uuid>{54d08872-94cf-49c9-b64f-605fddc65867}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>321</y>
  <width>180</width>
  <height>30</height>
  <uuid>{8c81bb50-0c7b-4902-9178-d05f83831ade}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Make Up Gain</label>
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
  <objectName>Gain</objectName>
  <x>516</x>
  <y>304</y>
  <width>500</width>
  <height>27</height>
  <uuid>{6ef7cd84-2fc3-4cb0-b69d-4d037f7406af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.96399999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gain_Value</objectName>
  <x>956</x>
  <y>321</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9481489d-99dd-43af-8282-21a31584dd71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.522</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>47</x>
  <y>280</y>
  <width>100</width>
  <height>30</height>
  <uuid>{fd55c818-d471-4651-9897-987cd1ad2797}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Compressor</text>
  <image>/</image>
  <eventLine>i2 0 0 0</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>156</x>
  <y>280</y>
  <width>100</width>
  <height>30</height>
  <uuid>{7cab7fde-7c56-4940-bef7-cb79e979fbc4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Expander</text>
  <image>/</image>
  <eventLine>i2 0 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>264</x>
  <y>280</y>
  <width>100</width>
  <height>30</height>
  <uuid>{0c604f4c-26b3-4cf9-84a2-7d962e5b21b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Noise Gate</text>
  <image>/</image>
  <eventLine>i2 0 0 2</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>373</x>
  <y>280</y>
  <width>100</width>
  <height>30</height>
  <uuid>{56984bf7-2754-4d29-a8c2-5f1f99ab744a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Ducker</text>
  <image>/</image>
  <eventLine>i2 0 0 3</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="Compressor" number="0" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{b9431a61-61f7-432b-bf6f-c47ddc7f9050}" mode="4" >SynthPad.wav</value>
<value id="{68b5f90b-b78e-4581-b434-232db5f4c40f}" mode="4" >SynthPad.wav</value>
<value id="{be1f1edc-082e-4433-a418-1e81baf4e305}" mode="1" >1.00000000</value>
<value id="{304e78d8-b320-453a-b28f-86b0ca872b86}" mode="1" >0.50000000</value>
<value id="{94c7e961-7981-4d21-942f-80bcc647daf5}" mode="1" >0.50000000</value>
<value id="{94c7e961-7981-4d21-942f-80bcc647daf5}" mode="4" >0.500</value>
<value id="{fd6d018b-1bcd-43b4-88e9-f240b379d7d0}" mode="4" >808loop.wav</value>
<value id="{8616b387-3762-43e0-9492-10006eb9c01f}" mode="4" >808loop.wav</value>
<value id="{78d0d7ed-0b48-41de-bec3-8b85723c1dd6}" mode="1" >1.00000000</value>
<value id="{59bb85ee-6e9a-4e00-9fd1-ace42baf2654}" mode="1" >0.00000000</value>
<value id="{2c621be3-47b0-4dfd-9037-ef64aa6676df}" mode="1" >0.00000000</value>
<value id="{2c621be3-47b0-4dfd-9037-ef64aa6676df}" mode="4" >0.000</value>
<value id="{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}" mode="1" >0.00000000</value>
<value id="{b731b52e-e14a-476a-a583-f3b2bd885539}" mode="1" >0.00000000</value>
<value id="{b731b52e-e14a-476a-a583-f3b2bd885539}" mode="4" >0.000</value>
<value id="{84cd664e-fb67-4dd4-aac3-adbcf2c81fe6}" mode="1" >48.00000000</value>
<value id="{ba8682a6-056f-4432-946b-4e3ee82c47a1}" mode="1" >48.00000000</value>
<value id="{ba8682a6-056f-4432-946b-4e3ee82c47a1}" mode="4" >48.000</value>
<value id="{0f952e77-ff9b-4621-b1af-23252bb9c2a6}" mode="1" >60.00000000</value>
<value id="{7b92c0ca-2fe8-4b4f-9ed0-f618c1b3cb5c}" mode="1" >60.00000000</value>
<value id="{7b92c0ca-2fe8-4b4f-9ed0-f618c1b3cb5c}" mode="4" >60.000</value>
<value id="{2800fb88-347a-402c-88ed-fc97af6a36be}" mode="1" >0.55199999</value>
<value id="{5d1ba94c-536a-4178-be6c-c0d9d2f75e3d}" mode="1" >5.00668192</value>
<value id="{5d1ba94c-536a-4178-be6c-c0d9d2f75e3d}" mode="4" >5.007</value>
<value id="{7a83bb1f-f25d-47e0-bf2d-9c5c86e0756b}" mode="1" >0.22200000</value>
<value id="{7f8d2709-bf8c-46ab-83f0-36fc620b0d56}" mode="1" >0.00463611</value>
<value id="{7f8d2709-bf8c-46ab-83f0-36fc620b0d56}" mode="4" >0.005</value>
<value id="{0f9b569d-7f5b-4540-a415-6fd6762f6fe9}" mode="1" >0.66600001</value>
<value id="{df4e20a1-b9a6-46ca-bb02-911779f6b4b5}" mode="1" >0.09956787</value>
<value id="{df4e20a1-b9a6-46ca-bb02-911779f6b4b5}" mode="4" >0.100</value>
<value id="{cb90b71f-234b-4c3e-875b-ce04075ae3ee}" mode="1" >0.10000000</value>
<value id="{54d08872-94cf-49c9-b64f-605fddc65867}" mode="1" >0.10000000</value>
<value id="{54d08872-94cf-49c9-b64f-605fddc65867}" mode="4" >0.100</value>
<value id="{6ef7cd84-2fc3-4cb0-b69d-4d037f7406af}" mode="1" >0.96399999</value>
<value id="{9481489d-99dd-43af-8282-21a31584dd71}" mode="1" >1.52186573</value>
<value id="{9481489d-99dd-43af-8282-21a31584dd71}" mode="4" >1.522</value>
<value id="{fd55c818-d471-4651-9897-987cd1ad2797}" mode="4" >0</value>
<value id="{7cab7fde-7c56-4940-bef7-cb79e979fbc4}" mode="4" >1</value>
<value id="{0c604f4c-26b3-4cf9-84a2-7d962e5b21b6}" mode="4" >0</value>
<value id="{56984bf7-2754-4d29-a8c2-5f1f99ab744a}" mode="4" >0</value>
</preset>
<preset name="Expander" number="1" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{b9431a61-61f7-432b-bf6f-c47ddc7f9050}" mode="4" >SynthPad.wav</value>
<value id="{68b5f90b-b78e-4581-b434-232db5f4c40f}" mode="4" >SynthPad.wav</value>
<value id="{be1f1edc-082e-4433-a418-1e81baf4e305}" mode="1" >1.00000000</value>
<value id="{304e78d8-b320-453a-b28f-86b0ca872b86}" mode="1" >0.50000000</value>
<value id="{94c7e961-7981-4d21-942f-80bcc647daf5}" mode="1" >0.50000000</value>
<value id="{94c7e961-7981-4d21-942f-80bcc647daf5}" mode="4" >0.500</value>
<value id="{fd6d018b-1bcd-43b4-88e9-f240b379d7d0}" mode="4" >808loop.wav</value>
<value id="{8616b387-3762-43e0-9492-10006eb9c01f}" mode="4" >808loop.wav</value>
<value id="{78d0d7ed-0b48-41de-bec3-8b85723c1dd6}" mode="1" >1.00000000</value>
<value id="{59bb85ee-6e9a-4e00-9fd1-ace42baf2654}" mode="1" >0.00000000</value>
<value id="{2c621be3-47b0-4dfd-9037-ef64aa6676df}" mode="1" >0.00000000</value>
<value id="{2c621be3-47b0-4dfd-9037-ef64aa6676df}" mode="4" >0.000</value>
<value id="{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}" mode="1" >0.00000000</value>
<value id="{b731b52e-e14a-476a-a583-f3b2bd885539}" mode="1" >0.00000000</value>
<value id="{b731b52e-e14a-476a-a583-f3b2bd885539}" mode="4" >0.000</value>
<value id="{84cd664e-fb67-4dd4-aac3-adbcf2c81fe6}" mode="1" >0.00000000</value>
<value id="{ba8682a6-056f-4432-946b-4e3ee82c47a1}" mode="1" >0.00000000</value>
<value id="{ba8682a6-056f-4432-946b-4e3ee82c47a1}" mode="4" >0.000</value>
<value id="{0f952e77-ff9b-4621-b1af-23252bb9c2a6}" mode="1" >6.00000000</value>
<value id="{7b92c0ca-2fe8-4b4f-9ed0-f618c1b3cb5c}" mode="1" >6.00000000</value>
<value id="{7b92c0ca-2fe8-4b4f-9ed0-f618c1b3cb5c}" mode="4" >6.000</value>
<value id="{2800fb88-347a-402c-88ed-fc97af6a36be}" mode="1" >0.24800000</value>
<value id="{5d1ba94c-536a-4178-be6c-c0d9d2f75e3d}" mode="1" >0.65612835</value>
<value id="{5d1ba94c-536a-4178-be6c-c0d9d2f75e3d}" mode="4" >0.656</value>
<value id="{7a83bb1f-f25d-47e0-bf2d-9c5c86e0756b}" mode="1" >0.00100000</value>
<value id="{7f8d2709-bf8c-46ab-83f0-36fc620b0d56}" mode="1" >0.00100710</value>
<value id="{7f8d2709-bf8c-46ab-83f0-36fc620b0d56}" mode="4" >0.001</value>
<value id="{0f9b569d-7f5b-4540-a415-6fd6762f6fe9}" mode="1" >0.00100000</value>
<value id="{df4e20a1-b9a6-46ca-bb02-911779f6b4b5}" mode="1" >0.00100710</value>
<value id="{df4e20a1-b9a6-46ca-bb02-911779f6b4b5}" mode="4" >0.001</value>
<value id="{cb90b71f-234b-4c3e-875b-ce04075ae3ee}" mode="1" >0.10000000</value>
<value id="{54d08872-94cf-49c9-b64f-605fddc65867}" mode="1" >0.10000000</value>
<value id="{54d08872-94cf-49c9-b64f-605fddc65867}" mode="4" >0.100</value>
<value id="{6ef7cd84-2fc3-4cb0-b69d-4d037f7406af}" mode="1" >0.30399999</value>
<value id="{9481489d-99dd-43af-8282-21a31584dd71}" mode="1" >0.01008263</value>
<value id="{9481489d-99dd-43af-8282-21a31584dd71}" mode="4" >0.010</value>
<value id="{fd55c818-d471-4651-9897-987cd1ad2797}" mode="4" >0</value>
<value id="{7cab7fde-7c56-4940-bef7-cb79e979fbc4}" mode="4" >0</value>
<value id="{0c604f4c-26b3-4cf9-84a2-7d962e5b21b6}" mode="4" >0</value>
<value id="{56984bf7-2754-4d29-a8c2-5f1f99ab744a}" mode="4" >1</value>
</preset>
<preset name="Noise Gate" number="2" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{b9431a61-61f7-432b-bf6f-c47ddc7f9050}" mode="4" >SynthPad.wav</value>
<value id="{68b5f90b-b78e-4581-b434-232db5f4c40f}" mode="4" >SynthPad.wav</value>
<value id="{be1f1edc-082e-4433-a418-1e81baf4e305}" mode="1" >1.00000000</value>
<value id="{304e78d8-b320-453a-b28f-86b0ca872b86}" mode="1" >0.50000000</value>
<value id="{94c7e961-7981-4d21-942f-80bcc647daf5}" mode="1" >0.50000000</value>
<value id="{94c7e961-7981-4d21-942f-80bcc647daf5}" mode="4" >0.500</value>
<value id="{fd6d018b-1bcd-43b4-88e9-f240b379d7d0}" mode="4" >808loop.wav</value>
<value id="{8616b387-3762-43e0-9492-10006eb9c01f}" mode="4" >808loop.wav</value>
<value id="{78d0d7ed-0b48-41de-bec3-8b85723c1dd6}" mode="1" >1.00000000</value>
<value id="{59bb85ee-6e9a-4e00-9fd1-ace42baf2654}" mode="1" >0.00000000</value>
<value id="{2c621be3-47b0-4dfd-9037-ef64aa6676df}" mode="1" >0.00000000</value>
<value id="{2c621be3-47b0-4dfd-9037-ef64aa6676df}" mode="4" >0.000</value>
<value id="{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}" mode="1" >80.00000000</value>
<value id="{b731b52e-e14a-476a-a583-f3b2bd885539}" mode="1" >80.00000000</value>
<value id="{b731b52e-e14a-476a-a583-f3b2bd885539}" mode="4" >80.000</value>
<value id="{84cd664e-fb67-4dd4-aac3-adbcf2c81fe6}" mode="1" >48.00000000</value>
<value id="{ba8682a6-056f-4432-946b-4e3ee82c47a1}" mode="1" >48.00000000</value>
<value id="{ba8682a6-056f-4432-946b-4e3ee82c47a1}" mode="4" >48.000</value>
<value id="{0f952e77-ff9b-4621-b1af-23252bb9c2a6}" mode="1" >60.00000000</value>
<value id="{7b92c0ca-2fe8-4b4f-9ed0-f618c1b3cb5c}" mode="1" >60.00000000</value>
<value id="{7b92c0ca-2fe8-4b4f-9ed0-f618c1b3cb5c}" mode="4" >60.000</value>
<value id="{2800fb88-347a-402c-88ed-fc97af6a36be}" mode="1" >0.31200001</value>
<value id="{5d1ba94c-536a-4178-be6c-c0d9d2f75e3d}" mode="1" >1.00625920</value>
<value id="{5d1ba94c-536a-4178-be6c-c0d9d2f75e3d}" mode="4" >1.006</value>
<value id="{7a83bb1f-f25d-47e0-bf2d-9c5c86e0756b}" mode="1" >0.22600000</value>
<value id="{7f8d2709-bf8c-46ab-83f0-36fc620b0d56}" mode="1" >0.00476477</value>
<value id="{7f8d2709-bf8c-46ab-83f0-36fc620b0d56}" mode="4" >0.005</value>
<value id="{0f9b569d-7f5b-4540-a415-6fd6762f6fe9}" mode="1" >0.66399997</value>
<value id="{df4e20a1-b9a6-46ca-bb02-911779f6b4b5}" mode="1" >0.09817593</value>
<value id="{df4e20a1-b9a6-46ca-bb02-911779f6b4b5}" mode="4" >0.098</value>
<value id="{cb90b71f-234b-4c3e-875b-ce04075ae3ee}" mode="1" >0.10000000</value>
<value id="{54d08872-94cf-49c9-b64f-605fddc65867}" mode="1" >0.10000000</value>
<value id="{54d08872-94cf-49c9-b64f-605fddc65867}" mode="4" >0.100</value>
<value id="{6ef7cd84-2fc3-4cb0-b69d-4d037f7406af}" mode="1" >0.95200002</value>
<value id="{9481489d-99dd-43af-8282-21a31584dd71}" mode="1" >1.38890934</value>
<value id="{9481489d-99dd-43af-8282-21a31584dd71}" mode="4" >1.389</value>
<value id="{fd55c818-d471-4651-9897-987cd1ad2797}" mode="4" >0</value>
<value id="{7cab7fde-7c56-4940-bef7-cb79e979fbc4}" mode="4" >0</value>
<value id="{0c604f4c-26b3-4cf9-84a2-7d962e5b21b6}" mode="4" >0</value>
<value id="{56984bf7-2754-4d29-a8c2-5f1f99ab744a}" mode="4" >1</value>
</preset>
<preset name="Ducker" number="3" >
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="1" >0.00000000</value>
<value id="{24979132-c53f-4414-ac6b-6b4f503ecfe8}" mode="4" >0</value>
<value id="{b9431a61-61f7-432b-bf6f-c47ddc7f9050}" mode="4" >SynthPad.wav</value>
<value id="{68b5f90b-b78e-4581-b434-232db5f4c40f}" mode="4" >SynthPad.wav</value>
<value id="{be1f1edc-082e-4433-a418-1e81baf4e305}" mode="1" >1.00000000</value>
<value id="{304e78d8-b320-453a-b28f-86b0ca872b86}" mode="1" >1.00000000</value>
<value id="{94c7e961-7981-4d21-942f-80bcc647daf5}" mode="1" >1.00000000</value>
<value id="{94c7e961-7981-4d21-942f-80bcc647daf5}" mode="4" >1.000</value>
<value id="{fd6d018b-1bcd-43b4-88e9-f240b379d7d0}" mode="4" >808loop.wav</value>
<value id="{8616b387-3762-43e0-9492-10006eb9c01f}" mode="4" >808loop.wav</value>
<value id="{78d0d7ed-0b48-41de-bec3-8b85723c1dd6}" mode="1" >1.00000000</value>
<value id="{59bb85ee-6e9a-4e00-9fd1-ace42baf2654}" mode="1" >0.13000000</value>
<value id="{2c621be3-47b0-4dfd-9037-ef64aa6676df}" mode="1" >0.13000000</value>
<value id="{2c621be3-47b0-4dfd-9037-ef64aa6676df}" mode="4" >0.130</value>
<value id="{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}" mode="1" >0.00000000</value>
<value id="{b731b52e-e14a-476a-a583-f3b2bd885539}" mode="1" >0.00000000</value>
<value id="{b731b52e-e14a-476a-a583-f3b2bd885539}" mode="4" >0.000</value>
<value id="{84cd664e-fb67-4dd4-aac3-adbcf2c81fe6}" mode="1" >48.00000000</value>
<value id="{ba8682a6-056f-4432-946b-4e3ee82c47a1}" mode="1" >48.00000000</value>
<value id="{ba8682a6-056f-4432-946b-4e3ee82c47a1}" mode="4" >48.000</value>
<value id="{0f952e77-ff9b-4621-b1af-23252bb9c2a6}" mode="1" >60.00000000</value>
<value id="{7b92c0ca-2fe8-4b4f-9ed0-f618c1b3cb5c}" mode="1" >60.00000000</value>
<value id="{7b92c0ca-2fe8-4b4f-9ed0-f618c1b3cb5c}" mode="4" >60.000</value>
<value id="{2800fb88-347a-402c-88ed-fc97af6a36be}" mode="1" >0.55199999</value>
<value id="{5d1ba94c-536a-4178-be6c-c0d9d2f75e3d}" mode="1" >5.00668192</value>
<value id="{5d1ba94c-536a-4178-be6c-c0d9d2f75e3d}" mode="4" >5.007</value>
<value id="{7a83bb1f-f25d-47e0-bf2d-9c5c86e0756b}" mode="1" >0.23000000</value>
<value id="{7f8d2709-bf8c-46ab-83f0-36fc620b0d56}" mode="1" >0.00489955</value>
<value id="{7f8d2709-bf8c-46ab-83f0-36fc620b0d56}" mode="4" >0.005</value>
<value id="{0f9b569d-7f5b-4540-a415-6fd6762f6fe9}" mode="1" >0.66600001</value>
<value id="{df4e20a1-b9a6-46ca-bb02-911779f6b4b5}" mode="1" >0.09956787</value>
<value id="{df4e20a1-b9a6-46ca-bb02-911779f6b4b5}" mode="4" >0.100</value>
<value id="{cb90b71f-234b-4c3e-875b-ce04075ae3ee}" mode="1" >0.10000000</value>
<value id="{54d08872-94cf-49c9-b64f-605fddc65867}" mode="1" >0.10000000</value>
<value id="{54d08872-94cf-49c9-b64f-605fddc65867}" mode="4" >0.100</value>
<value id="{6ef7cd84-2fc3-4cb0-b69d-4d037f7406af}" mode="1" >0.95800000</value>
<value id="{9481489d-99dd-43af-8282-21a31584dd71}" mode="1" >1.45400441</value>
<value id="{9481489d-99dd-43af-8282-21a31584dd71}" mode="4" >1.454</value>
<value id="{fd55c818-d471-4651-9897-987cd1ad2797}" mode="4" >0</value>
<value id="{7cab7fde-7c56-4940-bef7-cb79e979fbc4}" mode="4" >1</value>
<value id="{0c604f4c-26b3-4cf9-84a2-7d962e5b21b6}" mode="4" >0</value>
<value id="{56984bf7-2754-4d29-a8c2-5f1f99ab744a}" mode="4" >0</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

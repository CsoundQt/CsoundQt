;Written by Iain McCurdy, 2009
; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	i3 is activated by event in i10
;	Add Browser for audio file

;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 1024		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkDly	invalue	"Delay"		;init 1.175
		gkGain	invalue	"Gain"		;init 0.7
		gkMix	invalue	"Mix"		;init 0.17
		gkinput	invalue	"Input"
		gkfile	invalue	"File"
		
		ktrigger	changed	gkfile
		if	ktrigger	= 1	then					;IF ktrigger IS 1
				event	"i", 3, 0, 0			;CHANGE DELAY TIME SETTING WITH INSTRUMENT 3
		endif								;END OF CONDITIONAL BRANCHING		
	endif
endin

instr	1	;GENERATE INPUT AUDIO INDEPENDENTLY OF REVERBERATING INSTRUMENT
	if	gkinput=0	then							;IF 'Sound File' IS SELECTED...
		Sfile	invalue	"_Browse1"		
		gaL, gaR	diskin2	Sfile, 1, 0, 1			;READ AUDIO FROM SOUND FILE ON HARD DISC
	elseif	gkinput=1	then						;IF 'Live Input' IS SELECTED
		gaL	inch	1							;READ AUDIO FROM SOUND CARD'S FIRST (LEFT) INPUT
		gaR	= gaL							;MONO INPUT THEREFORE ASSIGN RIGHT CHANNEL TO LEFT CHANNEL ALSO 
	endif
endin

instr	2	;CONVOLUTION REVERB INSTRUMENT (ALWAYS ON)
	if	gkfile=0	then							;IF 'STAIRWELL' IS CHOSEN AS CONVOLUTION FILE...
		ar1 	convolve  gaL, "StairwellL.cv"		;PERFORM CONVOLUTION BETWEEN AUDIO INPUT FROM INSTR 1 AND SOUNDFILE STORED ON DISK (LEFT CHANNEL) 
		ar2 	convolve  gaR, "StairwellR.cv"		;PERFORM CONVOLUTION BETWEEN AUDIO INPUT FROM INSTR 1 AND SOUNDFILE STORED ON DISK (RIGHT CHANNEL)
	elseif	gkfile=1	then						;IF 'DISH' IS CHOSEN AS CONVOLUTION FILE...
		ar1	convolve  gaL, "dishL.cv"			;PERFORM CONVOLUTION BETWEEN AUDIO INPUT FROM INSTR 1 AND SOUNDFILE STORED ON DISK (LEFT CHANNEL)
		ar2	convolve  gaR, "dishR.cv"			;PERFORM CONVOLUTION BETWEEN AUDIO INPUT FROM INSTR 1 AND SOUNDFILE STORED ON DISK (RIGHT CHANNEL)
	endif


outs	ar1*gkGain, ar2*gkGain


	aDlyL	vdelay	gaL, gkDly*1000, 3000		;CREATE A DELAYED VERSION OF THE INPUT SIGNAL TO TEMPORALLY CORRELATE WITH THE CONVOLUTION OUTPUT SO THAT IT CAN BE USED IN A DRY/WET MIX
	aDlyR	vdelay	gaR, gkDly*1000, 3000		;CREATE A DELAYED VERSION OF THE INPUT SIGNAL TO TEMPORALLY CORRELATE WITH THE CONVOLUTION OUTPUT SO THAT IT CAN BE USED IN A DRY/WET MIX
	aL		ntrpol	aDlyL, ar1*0.1, gkMix		;CREATE DRY/WET MIX (LEFT CHANNEL)  
	aR		ntrpol	aDlyR, ar2*0.1, gkMix		;CREATE DRY/WET MIX (RIGHT CHANNEL)
;			outs		aL*gkGain, aR*gkGain		;SEND AUDIO TO OUTPUTS
	gaL = 0									;CLEAR GLOBAL AUDIO SIGNAL FROM INSTR 1 (LEFT CHANNEL) 
	gaR = 0									;CLEAR GLOBAL AUDIO SIGNAL FROM INSTR 1 (RIGHT CHANNEL)
endin

instr	3	;CHANGE DELAY TIME SETTING
	if	i(gkfile)=0	then						;IF 'STAIRWELL' IS CHOSEN AS CONVOLUTION FILE...
		ilen filelen	"StairwellL.cv"
			outvalue	"Delay", ilen				;UPDATE DELAY TIME SLIDER ACCORDINGLY
	elseif	i(gkfile)=1	then					;IF 'DISH' IS CHOSEN AS CONVOLUTION FILE...
		ilen filelen	"dishL.cv"
			outvalue	"Delay", ilen				;UPDATE DELAY TIME SLIDER ACCORDINGLY
	endif									;END OF CONDITIONAL BRANCHING
endin
</CsInstruments>
<CsScore>
i 10 0 3600	;GUI
i  2 0 3600	;INSTRUMENT 2 (CONVOLUTION INSTRUMENT) RUNS FOR 1 HOUR (AND KEEPS REAL-TIME PERFORMANCE GOING) 
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>269</x>
 <y>195</y>
 <width>1120</width>
 <height>407</height>
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
  <width>520</width>
  <height>321</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Convolve</label>
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
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>5</x>
  <y>5</y>
  <width>100</width>
  <height>30</height>
  <uuid>{487d5181-d838-4cce-9628-317fefc350cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>   ON / OFF</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Delay</objectName>
  <x>10</x>
  <y>55</y>
  <width>500</width>
  <height>27</height>
  <uuid>{086a860c-b45b-47f3-978f-2f6daac6338b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>3.00000000</maximum>
  <value>1.59646800</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>72</y>
  <width>100</width>
  <height>30</height>
  <uuid>{109a592d-ca0d-4b82-bf17-3b42c0ff503a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay</label>
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
  <objectName>Delay</objectName>
  <x>454</x>
  <y>72</y>
  <width>57</width>
  <height>30</height>
  <uuid>{30f36f54-9085-46d0-8f1f-4a4b89881919}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.596</label>
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
  <objectName>Gain</objectName>
  <x>10</x>
  <y>90</y>
  <width>500</width>
  <height>27</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.12800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>107</y>
  <width>100</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
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
  <objectName>Gain</objectName>
  <x>454</x>
  <y>109</y>
  <width>57</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.128</label>
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
  <x>523</x>
  <y>2</y>
  <width>388</width>
  <height>321</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Convolve</label>
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
  <x>527</x>
  <y>23</y>
  <width>383</width>
  <height>292</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------
convolve performs convolution between an input signal and an impulse file created using Csound's cvanal utility.
I have provided two impulse files to work with in this example. convolve is rather CPU intensive and depending upon the computer system used, may struggle to run in real-time.
Adjustment of buffer sizes and of ksmps (and kr) might assist real-time performance.
The output of the convolve opcode will be delayed by a duration equal to the duration of the impulse file. It is therefore necessary to delay the input signal if it is used as part of a Dry/Wet mix after convolution.
For this reason convolve is probably less useful when applied to the live input. (pconvolve is better suited to real-time situations.)
Furthermore there does not seem to be a noticable drop in fidelity in pconvolve.</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Mix</objectName>
  <x>454</x>
  <y>147</y>
  <width>57</width>
  <height>30</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.420</label>
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
  <x>10</x>
  <y>147</y>
  <width>100</width>
  <height>30</height>
  <uuid>{b57ba536-8f28-4986-9bf7-8eb84262d8ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry / Wet Mix</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Mix</objectName>
  <x>10</x>
  <y>130</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b8fa76b9-3d04-4156-a2f2-a413d3864da3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.42000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>86</x>
  <y>185</y>
  <width>120</width>
  <height>30</height>
  <uuid>{9b81a1f2-bcb8-4582-925b-9ae56def3865}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Sound File</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Live Input</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>File</objectName>
  <x>358</x>
  <y>185</y>
  <width>120</width>
  <height>30</height>
  <uuid>{4f12eb6a-c071-4199-8bad-bfe11a917032}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Stairwell</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Dish</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>185</y>
  <width>72</width>
  <height>30</height>
  <uuid>{62eeb695-9b83-42da-81cd-8000c232d9b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input</label>
  <alignment>right</alignment>
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
  <x>229</x>
  <y>185</y>
  <width>127</width>
  <height>30</height>
  <uuid>{f0042687-944f-4ab5-a258-074f2aca5510}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Convolution file</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>5</x>
  <y>250</y>
  <width>170</width>
  <height>30</height>
  <uuid>{c678b2fb-b1ce-4b9c-b45c-c297eeab2e2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/moi/Samples/808loop.wav</stringvalue>
  <text>Browse Stereo Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>177</x>
  <y>250</y>
  <width>330</width>
  <height>28</height>
  <uuid>{aabef4b4-4458-4810-b57a-85c5336535f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/moi/Samples/808loop.wav</label>
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
   <r>240</r>
   <g>235</g>
   <b>226</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

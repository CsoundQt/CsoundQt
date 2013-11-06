;Written by Iain McCurdy, 2009
; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 815

;Notes on modifications from original csd:
;	Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials
</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 512		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


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

		gkGain	invalue	"Gain"		;init 0.7
		gkMix	invalue	"Mix"		;init 0.17

		gkinput	invalue	"Input"
		gkfile	invalue	"File"
	endif
endin

instr	1	;GENERATE INPUT AUDIO INDEPENDENTLY OF REVERBERATING INSTRUMENT
	kon invalue "on"

	if	gkinput=0	then								;IF 'Sound File' IS SELECTED...
		Sfile	invalue	"_Browse1"
		gaL, gaR	FilePlay2	Sfile, 1, 0, 1				;READ AUDIO FROM SOUND FILE ON HARD DISC
	elseif	gkinput=1	then							;IF 'Live Input' IS SELECTED
		gaL	inch	 1								;READ AUDIO FROM SOUND CARD'S FIRST (LEFT) INPUT
		gaR	=	gaL								;MONO INPUT THEREFORE ASSIGN RIGHT CHANNEL TO LEFT CHANNEL ALSO 
	endif
	gaL = gaL *kon
	gaR = gaR *kon
endin

instr	2	;CONVOLUTION REVERB INSTRUMENT
			
			
		 Sir invalue "_Browse2"
		 kSwitch = changed(gkfile) + changed(Sir) ;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then								;IF I-RATE VARIABLE IS CHANGED...
		reinit	UPDATE							;BEGIN A REINITIALISATION PASS IN ORDER TO EFFECT THIS CHANGE. BEGIN THIS PASS AT LABEL ENTITLED 'UPDATE' AND CONTINUE UNTIL rireturn OPCODE 
	endif										;END OF CONDITIONAL BRANCHING
	UPDATE:										;LABEL
if	gkfile=0	then									;IF 'STAIRWELL' IS CHOSEN AS CONVOLUTION FILE...
		ar1	pconvolve gaL, "StairwellL.wav"			;PERFORM CONVOLUTION BETWEEN AUDIO INPUT FROM INSTR 1 AND SOUNDFILE STORED ON DISK (LEFT CHANNEL)
		ar2	pconvolve gaR, "StairwellR.wav"			;PERFORM CONVOLUTION BETWEEN AUDIO INPUT FROM INSTR 1 AND SOUNDFILE STORED ON DISK (RIGHT CHANNEL)
	elseif	gkfile=1	then							;IF 'DISH' IS CHOSEN AS CONVOLUTION FILE...
		ar1	pconvolve gaL, "dishL.wav"				;PERFORM CONVOLUTION BETWEEN AUDIO INPUT FROM INSTR 1 AND SOUNDFILE STORED ON DISK (LEFT CHANNEL)
		ar2	pconvolve gaR, "dishR.wav"				;PERFORM CONVOLUTION BETWEEN AUDIO INPUT FROM INSTR 1 AND SOUNDFILE STORED ON DISK (RIGHT CHANNEL)
	elseif gkfile==2 then
		ar1	pconvolve gaL, Sir, 0, 1
		ar2	pconvolve gaR, Sir, 0, 1
	endif										;END OF CONDITIONAL BRANCHING
	aL	ntrpol	gaL, ar1*0.1, gkMix					;CREATE DRY/WET MIX (LEFT CHANNEL)  
	aR	ntrpol	gaR, ar2*0.1, gkMix					;CREATE DRY/WET MIX (RIGHT CHANNEL)
		outs		aL*gkGain, aR*gkGain				;SEND AUDIO TO OUTPUTS
	gaL	= 0										;CLEAR GLOBAL AUDIO SIGNAL FROM INSTR 1 (LEFT CHANNEL) 
	gaR	= 0										;CLEAR GLOBAL AUDIO SIGNAL FROM INSTR 1 (RIGHT CHANNEL)
endin
</CsInstruments>
<CsScore>
i 10 0 3600	;GUI
i  1 0 3600	;INSTRUMENT 1 (SOURCE INSTRUMENT) RUNS FOR 1
i  2 0 3600	;INSTRUMENT 2 (CONVOLUTION INSTRUMENT) RUNS FOR 1 HOUR (AND KEEPS REAL-TIME PERFORMANCE GOING) 
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>967</width>
 <height>327</height>
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
  <width>525</width>
  <height>325</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pconvolve</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>on</objectName>
  <x>5</x>
  <y>5</y>
  <width>100</width>
  <height>30</height>
  <uuid>{487d5181-d838-4cce-9628-317fefc350cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>   ON / OFF</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Gain</objectName>
  <x>13</x>
  <y>58</y>
  <width>500</width>
  <height>27</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.47200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>13</x>
  <y>75</y>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Gain</objectName>
  <x>432</x>
  <y>75</y>
  <width>80</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.472</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>528</x>
  <y>2</y>
  <width>439</width>
  <height>323</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pconvolve</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>528</x>
  <y>16</y>
  <width>433</width>
  <height>300</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------------------------
pconvolve offers a computationally efficient method for performing convolution and is therefore ideally suited for real-time convolution reverbs. The input file for the convolution impulse is a sound file and is typically a short recording of the reverberant tail of of a sharp loud sound, sounding in the space.
The sounds used in these recordings is often a starting pistol or a balloon bursting. The aim is that all frequencies are present in the initial inpulse sound. For more accurate convolution a sine sweep is used but in this case further decoding is needed before the recording can be used. If too long an impulse sound is used the opcode will struggle to run in real-time as convolution is fundementally a computationally expensive procedure. Two user controls are included, 'Dry/Wet Mix' and 'Output Gain' (both dry and wet signals). There is no reason why the impulse file has to be that of a reverberant space. One of the options for 'Convolution File' in this example is a glass dish. Other possibilities might be vintage amplifiers and microphones.</label>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Mix</objectName>
  <x>433</x>
  <y>114</y>
  <width>80</width>
  <height>30</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>12</x>
  <y>113</y>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Mix</objectName>
  <x>12</x>
  <y>96</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b8fa76b9-3d04-4156-a2f2-a413d3864da3}</uuid>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Input</objectName>
  <x>93</x>
  <y>166</y>
  <width>120</width>
  <height>30</height>
  <uuid>{9b81a1f2-bcb8-4582-925b-9ae56def3865}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Audio File</name>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>File</objectName>
  <x>365</x>
  <y>166</y>
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
    <name>Dish</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>File</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>12</x>
  <y>166</y>
  <width>80</width>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>264</x>
  <y>166</y>
  <width>100</width>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse1</objectName>
  <x>6</x>
  <y>218</y>
  <width>170</width>
  <height>30</height>
  <uuid>{83beaac6-3457-44f5-befb-b2f51175fa55}</uuid>
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
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse1</objectName>
  <x>177</x>
  <y>219</y>
  <width>330</width>
  <height>28</height>
  <uuid>{b2716d73-fb2d-45af-8ce0-404d5e48d00d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>808loop.wav</label>
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
   <r>242</r>
   <g>241</g>
   <b>240</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>177</x>
  <y>246</y>
  <width>330</width>
  <height>30</height>
  <uuid>{a63909ac-6fa4-41c8-a84b-ba08e76132ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Restart the instrument after changing the audio file.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse2</objectName>
  <x>7</x>
  <y>278</y>
  <width>170</width>
  <height>30</height>
  <uuid>{181e4355-4514-4f64-90ad-846857e32fc3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/andres/Desktop/convolution/EMT 244 (A. Bernhard)/4,5s High_2.wav</stringvalue>
  <text>Browse IR File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse2</objectName>
  <x>178</x>
  <y>279</y>
  <width>330</width>
  <height>28</height>
  <uuid>{c8be82af-1985-49e4-ba13-2927447697c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/andres/Desktop/convolution/EMT 244 (A. Bernhard)/4,5s High_2.wav</label>
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
   <r>242</r>
   <g>241</g>
   <b>240</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

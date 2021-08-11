;Written by Iain McCurdy, 2006


; Modified for QuteCsound by René, November 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine		ftgen	1,0,4097,10,1						;A SINE WAVE
gitri		ftgen	2,0,4097,7,0,1024,-1,2048,1,1024,0		;A TRIANGLE WAVE
giExp10000	ftgen	0, 0, 129, -25, 0, 1.0, 128, 10000.0	;TABLE FOR EXP SLIDER
giExp15000	ftgen	0, 0, 129, -25, 0, 1.0, 128, 15000.0	;TABLE FOR EXP SLIDER


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
		gkInGain		invalue 	"Input_Gain"
		kOscFrq		invalue 	"Sine_Tone_Frequency"
		gkOscFrq		tablei	kOscFrq, giExp10000, 1
					outvalue	"Sine_Tone_Frequency_Value", gkOscFrq
		kModFrq		invalue 	"Modulation_Frequency"
		gkModFrq		tablei	kModFrq, giExp15000, 1
					outvalue	"Modulation_Frequency_Value", gkModFrq
		gkDryWet		invalue 	"Mix"
		gkOutGain		invalue 	"Output_Gain"

		gkinput		invalue	"Input"
		gkAM_RM		invalue	"AM_RM"
		gkwave		invalue 	"Wave"

		Sfile_new		strcpy	""											;INIT TO EMPTY STRING
		gSfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	gSfile
		gkfile 		strcmpk	Sfile_new, Sfile_old
	endif
endin

instr	1	;GENERATES AN AUDIO STREAM
	if 		gkinput=0		then												;IF MENU 1 IS SELECTED (LIVE AUDIO IN)
		asig		inch		1												;READ AUDIO FROM INPUT CHANNEL 1 (LEFT)
		asig		=		asig * gkInGain									;RESCALE LIVE AUDIO INPUT AUDIO WITH 'InGain' SLIDER
	elseif	gkinput=1		then												;IF MENU 2 IS SELECTED (SINE TONE)
		asig		oscili	0.6,gkOscFrq,gisine									;CREATE A SINE TONE OSCILLATOR
	else																	;ONLY OTHER OPTION IS IF MENU 4 IS SELECTED (AUDIO FILE)
		kNew_file		changed	gkfile										;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
		if	kNew_file=1	then												;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
			reinit	NEW_FILE												;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
		endif
		NEW_FILE:
		;OUTPUTS		OPCODE	FILE  | SPEED | INSKIP | LOOPING (0=OFF 1=ON)
		asig, aR		FilePlay2	gSfile,  1,      0,         1						;GENERATE 2 AUDIO SIGNALS FROM A STEREO SOUND FILE
					rireturn												;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
	endif																;END OF CONDITIONAL BRANCHING
	
	if	gkAM_RM=0		then													;IF 'Amplitude Modulation' IS SELECTED
		amod		oscilikt	0.5,gkModFrq,gkwave+1								;CREATE 'Amplitude Modulation' WAVEFORM
		amod		=	amod + 0.5											;OFFSET 'Amplitude Modulation' WAVEFORM
	else																	;ONLY OTHER OPTION IS IF 'Ring Modulation' IS SELECTED
		amod		oscilikt	1,gkModFrq,gkwave+1									;CREATE RING MODULATION OSCILLATOR
	endif																;END OF CONDITIONAL BRANCHING
	
	aModSig		=		asig*amod											;MULTIPLY INPUT SIGNAL BY MODULATION SIGNAL
	amix			ntrpol	asig, aModSig, gkDryWet								;CREATE DRY/WET MIXED SIGNAL
				outs		amix * gkOutGain, amix * gkOutGain						;SEND DRY/WET MIXED AUDIO SIGNAL TO OUTPUTS AND RESCALE USING 'gkOutGain' ON-SCREEN SLIDER
endin

</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		3600		;GUI
i 1		0.2		3600		;AUDIO STREAM
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>274</x>
 <y>286</y>
 <width>1091</width>
 <height>476</height>
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
  <height>470</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude Modulation / Ring Modulation</label>
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
  <x>514</x>
  <y>2</y>
  <width>565</width>
  <height>470</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude Modulation / Ring Modulation</label>
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
  <x>520</x>
  <y>21</y>
  <width>552</width>
  <height>447</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------------------------
When the frequency of amplitude modulation of an audio signal enters the domain of audible frequecies we cease to perceive a rising and falling amplitude but instead perceive the emergence of sideband tones. The frequencies of these tones will be determined by the frequencies of the two input signals and by the waveform used for modulation. These sideband tones will be most clearly discernible when the source sound (carrier) and modulating waveforms are both sine tones. Ring modulation is a variation of amplitude modulation in which the modulating signal is bipolar as opposed to unipolar. In ring modulation the amplitude of the input signal is effectively being modulated by a rectified sine wave (the perceived modulations in amplitude therefore being twice the frequency of those from a unipolar modulating signal) - but the signal also becomes inverted when the modulating signal enters the negative domain. Ring modulation derives its name from the 'ring' formation of four diodes in its original analog implementation, not from its ability to imbue a source signal with a 'ringing' characteristic. In amplitude modulation between sine waves the frequency of the carrier wave is present at the output and just a single sideband is created equivalent to the sum of the input frequencies. In ring modulation the frequency of the carrier wave is not present at the output and two sidebands are created equivalent to the sum and difference of the input frequencies. In amplitude modulation and ring modulation synthesis and signal processing, the source signal is referred to as the 'carrier' and the modulation waveform as the 'modulator'. In this example the user can choose between an amplitude modulation effect and a ring modulation effect. The user can also choose between one of four source signals. As well as modulating the source signal with a sine wave, which is the more common practice, the user can also choose a triangle wave as the modulating waveform. Ring modulation is a classic electronic effect employed in the past by some of the giants of electronic music such as Karlheinz Stockhausen and the Daleks.</label>
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
  <y>40</y>
  <width>500</width>
  <height>190</height>
  <uuid>{53a95371-23f7-4d54-a6c6-63bbabdb388d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input Signal (Carrier)</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>95</y>
  <width>180</width>
  <height>30</height>
  <uuid>{541ace1b-b1de-4c04-8d84-1de90288dded}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input Gain</label>
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
  <objectName>Input_Gain</objectName>
  <x>13</x>
  <y>72</y>
  <width>490</width>
  <height>27</height>
  <uuid>{eac88081-deaa-45c0-b896-32a3ffedc74a}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Input_Gain</objectName>
  <x>443</x>
  <y>95</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3be43919-ad18-4aef-b554-03c4b4d991c3}</uuid>
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
  <objectName>Sine_Tone_Frequency_Value</objectName>
  <x>443</x>
  <y>138</y>
  <width>60</width>
  <height>30</height>
  <uuid>{11dfc416-5a1d-40f4-bbaa-6b1b2e2bb7c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>476.204</label>
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
  <objectName>Sine_Tone_Frequency</objectName>
  <x>13</x>
  <y>115</y>
  <width>490</width>
  <height>27</height>
  <uuid>{5e37a418-576c-419e-817f-2002fc5b805b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.66938776</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>138</y>
  <width>180</width>
  <height>30</height>
  <uuid>{afc5d077-588e-4d40-92cf-761ea81eb1da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sine Tone Frequency</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>180</x>
  <y>157</y>
  <width>110</width>
  <height>28</height>
  <uuid>{e33bbdf6-2b76-4b63-b5b0-86b10a74777f}</uuid>
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
    <name>Sine Tone</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Audio File</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>12</x>
  <y>188</y>
  <width>170</width>
  <height>30</height>
  <uuid>{f625e668-4993-42d8-a5dc-f840e40874de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>808loop.wav</stringvalue>
  <text>Browse Stereo Audio File</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>182</x>
  <y>189</y>
  <width>320</width>
  <height>28</height>
  <uuid>{110749e3-ae06-4174-84b3-7a12000896b5}</uuid>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>232</y>
  <width>500</width>
  <height>110</height>
  <uuid>{1fbf2df5-2fd3-4ca1-b2e5-8933e45cb526}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulator</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>313</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7e72caae-d5e3-48e8-9285-1cbd12c5347c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Modulation Frequency</label>
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
  <objectName>Modulation_Frequency</objectName>
  <x>13</x>
  <y>290</y>
  <width>490</width>
  <height>27</height>
  <uuid>{254004da-2c79-4209-bf6e-0f8cdd5fafcc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.60816324</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Modulation_Frequency_Value</objectName>
  <x>443</x>
  <y>313</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f6bcb14a-ad2e-4303-9aab-c49730db24d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>346.659</label>
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
  <objectName>AM_RM</objectName>
  <x>180</x>
  <y>249</y>
  <width>100</width>
  <height>28</height>
  <uuid>{a155ab8f-ca5c-4308-834d-f563b3e9a3aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Amp Mod</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Ring Mod</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Wave</objectName>
  <x>300</x>
  <y>249</y>
  <width>100</width>
  <height>28</height>
  <uuid>{1fceb5fa-f31b-4507-9d73-2100cf426aec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Sine</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Triangle</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>345</y>
  <width>500</width>
  <height>120</height>
  <uuid>{b00b8612-bd44-4f23-9da5-baea23ff4648}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>435</y>
  <width>180</width>
  <height>30</height>
  <uuid>{ffb0a5ee-ba0c-4308-b51d-892e1d37bd87}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Output_Gain</objectName>
  <x>13</x>
  <y>412</y>
  <width>490</width>
  <height>27</height>
  <uuid>{64abd1d0-ef34-49d8-bbc4-0b1103c02d8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.60000002</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Output_Gain</objectName>
  <x>443</x>
  <y>435</y>
  <width>60</width>
  <height>30</height>
  <uuid>{da0544f6-bf20-4d77-bc1e-92be4a463d95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.600</label>
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
  <objectName>Mix</objectName>
  <x>443</x>
  <y>392</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b7304e5e-85f4-43ab-85b3-76ff2664d3e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.806</label>
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
  <objectName>Mix</objectName>
  <x>13</x>
  <y>369</y>
  <width>490</width>
  <height>27</height>
  <uuid>{2f8b24c3-b597-4e5d-a3fc-0e388dc5cab4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.80612242</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>392</y>
  <width>180</width>
  <height>30</height>
  <uuid>{523f1aa4-a5ac-4b2a-a389-8b68340ce13b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry / Wet Mix</label>
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
</bsbPanel>
<bsbPresets>
<preset name="Init" number="0" >
<value id="{eac88081-deaa-45c0-b896-32a3ffedc74a}" mode="1" >0.20000000</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="1" >0.20000000</value>
<value id="{3be43919-ad18-4aef-b554-03c4b4d991c3}" mode="4" >0.200</value>
<value id="{11dfc416-5a1d-40f4-bbaa-6b1b2e2bb7c2}" mode="1" >476.20458984</value>
<value id="{11dfc416-5a1d-40f4-bbaa-6b1b2e2bb7c2}" mode="4" >476.205</value>
<value id="{5e37a418-576c-419e-817f-2002fc5b805b}" mode="1" >0.66938776</value>
<value id="{e33bbdf6-2b76-4b63-b5b0-86b10a74777f}" mode="1" >1.00000000</value>
<value id="{f625e668-4993-42d8-a5dc-f840e40874de}" mode="4" >808loop.wav</value>
<value id="{110749e3-ae06-4174-84b3-7a12000896b5}" mode="4" >808loop.wav</value>
<value id="{254004da-2c79-4209-bf6e-0f8cdd5fafcc}" mode="1" >0.60816324</value>
<value id="{f6bcb14a-ad2e-4303-9aab-c49730db24d0}" mode="1" >346.65887451</value>
<value id="{f6bcb14a-ad2e-4303-9aab-c49730db24d0}" mode="4" >346.659</value>
<value id="{a155ab8f-ca5c-4308-834d-f563b3e9a3aa}" mode="1" >0.00000000</value>
<value id="{1fceb5fa-f31b-4507-9d73-2100cf426aec}" mode="1" >0.00000000</value>
<value id="{64abd1d0-ef34-49d8-bbc4-0b1103c02d8b}" mode="1" >0.60000002</value>
<value id="{da0544f6-bf20-4d77-bc1e-92be4a463d95}" mode="1" >0.60000002</value>
<value id="{da0544f6-bf20-4d77-bc1e-92be4a463d95}" mode="4" >0.600</value>
<value id="{b7304e5e-85f4-43ab-85b3-76ff2664d3e4}" mode="1" >0.80599999</value>
<value id="{b7304e5e-85f4-43ab-85b3-76ff2664d3e4}" mode="4" >0.806</value>
<value id="{2f8b24c3-b597-4e5d-a3fc-0e388dc5cab4}" mode="1" >0.80612242</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

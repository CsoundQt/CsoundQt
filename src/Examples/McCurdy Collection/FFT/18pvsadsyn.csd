;Written by Iain McCurdy 2009

; Modified for QuteCsound by René, October 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio files


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 256	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)


;TABLES THAT STORE FFT ANALYSIS ATTRIBUTES DATA
giFFTattributes0	ftgen	1, 0, 4, -2,  512, 256, 1024, 1
giFFTattributes1	ftgen	2, 0, 4, -2, 1024, 256, 1024, 1
giFFTattributes2	ftgen	3, 0, 4, -2, 2048, 256, 2048, 1
giFFTattributes3	ftgen	4, 0, 4, -2, 4096, 256, 4096, 1

;TABLE FOR EXP SLIDER
giExp2			ftgen	0, 0, 129, -25, 0, 0.25, 128, 2.0


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		kfmod			invalue 	"Rescale_Frequencies"
		gkfmod			tablei	kfmod, giExp2, 1
						outvalue	"Rescale_Frequencies_Value", gkfmod	;init 1.0	
		gknoscs			invalue  "No_Oscs"
		gkbinoffset		invalue  "Bin_Offset"
		gkbinincr			invalue  "Bin_Increment"

		gkinput			invalue	"Input"
		gkFFTattributes	invalue	"FFTattributes"	
	endif
endin

instr 	1
	if	gkinput=0	then																		;IF 'INPUT' SWITCH IS SET TO 'Live Input' THEN IMPLEMENT THE NEXT LINE OF CODE
		asig		inch		1																;READ AUDIO FROM THE COMPUTER'S LIVE INPUT CHANNEL 1 (LEFT)
	else																					;IF 'INPUT' SWITCH IS SET TO 'Sound File' THEN IMPLEMENT THE NEXT LINE OF CODE
		Sfile	invalue	"_Browse"
		;OUTPUT	OPCODE	FILE_PATH| SPEED | INSKIP | WRAPAROUND (1=ON)
		asig, aR	diskin2	Sfile,       1,      0,        1										;READ A STORED AUDIO FILE FROM THE HARD DRIVE
	endif																				;END OF 'IF'...'THEN' BRANCHING

	iFFTsize	table	0, i(gkFFTattributes)+1													;READ FFT SIZE FROM APPROPRIATE TABLE    
	kSwitch	changed	gkFFTattributes, gknoscs, gkbinoffset, gkbinincr								;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)

	if	kSwitch=1	then																		;IF I-RATE VARIABLE IS CHANGED...
		reinit	UPDATE																	;BEGIN A REINITIALISATION PASS IN ORDER TO EFFECT THIS CHANGE. BEGIN THIS PASS AT LABEL ENTITLED 'UPDATE' AND CONTINUE UNTIL rireturn OPCODE 
	endif																				;END OF CONDITIONAL BRANCHING

	UPDATE:																				;LABEL - BEGIN RE-INITIALIZATION PASS FROM HERE
	iFFTsize	table	0, i(gkFFTattributes)+1													;READ FFT SIZE FROM APPROPRIATE TABLE    
	ioverlap	table	1, i(gkFFTattributes)+1													;READ OVERLAP SIZE FROM APPROPRIATE TABLE
	iwinsize	table	2, i(gkFFTattributes)+1														;READ WINDOW SIZE FROM APPROPRIATE TABLE 
	iwintype	table	3, i(gkFFTattributes)+1													;READ WINDOW TYPE FROM APPROPRIATE TABLE 	

	fsig1  	pvsanal	asig, iFFTsize, ioverlap, iwinsize, iwintype									;ANALYSE THE AUDIO SIGNAL. OUTPUT AN F-SIGNAL.

	;THE limit OPCODE IS USED TO LIMIT THE VALUE USED FOR NUMBER OF OSCILLATORS (inoscs)
	;AS IF THIS EXCEEDS THE NUMBER OF BINS USED IN THE ORIGINAL ANALYSIS CSOUND WILL CRASH.
	;THE NUMBER OF BINS IS FFTsize DIVIDED BY 2, + 1
	;BIN OFFSET (binoffset) AND BIN INCREMENT (binincr) MUST ALSO BE TAKEN INTO ACCOUNT AS
	;THEY WILL INFLUENCE TO WHAT HIGHEST FFT BIN pvsadsyn ATTEMPTS TO READ FROM
	inoscs	limit	i(gknoscs), 0, (((iFFTsize*0.5)+1)-i(gkbinoffset))/i(gkbinincr)

;	print	inoscs																		;FOR THE USERS INFORMATION THE ACTUAL NUMBER OF OSCILLATORS
	aresyn 	pvsadsyn fsig1, inoscs, gkfmod , i(gkbinoffset), i(gkbinincr)							;RESYNTHESIZE FROM THE fsig USING pvsadsyn
	;OUTPUT	OPCODE		INPUT
			outs		aresyn, aresyn															;SEND THE RESYNTHESIZED SIGNAL TO THE AUDIO OUTPUTS
			rireturn																		;RETURN TO NORMAL PERFORMANCE TIME AFTER A RE-INITIALIZATION PASS
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0	   3600	;GUI
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>319</x>
 <y>189</y>
 <width>1246</width>
 <height>482</height>
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
  <width>514</width>
  <height>420</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvsadsyn</label>
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
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>517</x>
  <y>2</y>
  <width>601</width>
  <height>420</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvsadsyn</label>
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
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>520</x>
  <y>18</y>
  <width>595</width>
  <height>402</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------------------------------
pvsadsyn resynthesizes an fsig into an audio signal with some interesting user adjustable parameters that define how that resynthesis is performed. pvsadsyn is quite similar the the opcode pvadd. The principle innovation is that pvsadsyn can operate upon a streaming f-signal and therefore a live stream of audio. Most of pvsadsyn's input parameters must be defined at initialization time. To allow realtime modulation of these parameters I have designed the instrument to perform a re-initialization pass through the relevant code if any of these parameters are changed in the GUI. 'No. Oscs.' (number of oscillators) defines the number of oscillators that will be used in the resynthesis. As this number is reduced the result is simlar to lowering the cutoff frequency of a low-pass filter. 'Bin Offset' defines the lowest FFT bin which will be read from. As this value is increased the result is similar to raising the cutoff frequency of a high-pass filter. Setting 'Bin Increment' to values higher than '1' means that pvsadsyn will not read from every consecutive FFT bin but will instead skip the defined number of bins before reading again for each oscillator. If pvsadsyn is forced to read from a bin that doesn't exist Csound will crash. The highest bin that can be read from is dictated by the number of bins available from the original analysis carried out, in this case, by 'pvsanal'. It will be (FFTsize/2)+1. The highest bin that pvsadsyn will attempt to read from is dependent upon 'No. Oscs.', 'Bin Offset' and 'Bin Increment'. To prevent the annoyance of crashes while modulating these parameters I have included a line of code that limits the actual number of oscillators to prevent read attempts from non existant FFT bins. The actual number of oscillators used by pvsadsyn is output to the terminal each time it changes. 'Rescale Frequencies' modulates the frequencies of all FFT bins at k-rate. The user can select between a variety of combinations of parameters for the FFT analysis. Larger values for FFT size will give better harmonic reproduction but greater time smearing effects and higher computational cost. Lower values will result in less time smearing but greater harmonic distortion.</label>
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
  <text>  ON / OFF</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>341</y>
  <width>506</width>
  <height>70</height>
  <uuid>{f0c4875d-4e35-4d37-b043-9c1476025645}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FFT Attributes</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
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
  <x>169</x>
  <y>347</y>
  <width>300</width>
  <height>30</height>
  <uuid>{c2cdd204-e32b-488e-b5c2-70688fb2defa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FFT Size - Overlap - Window Size - Window Type</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>FFTattributes</objectName>
  <x>169</x>
  <y>367</y>
  <width>274</width>
  <height>32</height>
  <uuid>{c8c311f9-c1b7-4bbb-becf-9c9f1fa862c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>512         256       1024            1</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>1024       256       1024            1</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2048       256       2048            1</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4096       256       4096            1</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Rescale_Frequencies_Value</objectName>
  <x>449</x>
  <y>93</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.003</label>
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
  <objectName>Rescale_Frequencies</objectName>
  <x>9</x>
  <y>76</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.66800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>93</y>
  <width>180</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rescale Frequencies</label>
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
  <x>6</x>
  <y>222</y>
  <width>506</width>
  <height>95</height>
  <uuid>{cdc434d0-b9e7-4f6f-aa90-800ec76dced6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>280</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/moi/Samples/Songpan.wav</stringvalue>
  <text>Browse Stereo Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>180</x>
  <y>244</y>
  <width>120</width>
  <height>30</height>
  <uuid>{cc64e047-7e82-416c-9753-d010ddefabe4}</uuid>
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
    <name>Sound File</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>179</x>
  <y>281</y>
  <width>330</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/moi/Samples/Songpan.wav</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>162</x>
  <y>153</y>
  <width>80</width>
  <height>30</height>
  <uuid>{dc1bccf4-d23b-4470-9c3f-5e576f314662}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bin Offset</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Bin_Offset</objectName>
  <x>242</x>
  <y>153</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ba683795-bc00-46ba-8540-c6c32edb8bd5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <minimum>0</minimum>
  <maximum>2048</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>No_Oscs</objectName>
  <x>120</x>
  <y>153</y>
  <width>60</width>
  <height>30</height>
  <uuid>{90b425e6-cc7a-4b70-bd54-52c1a629ce97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <minimum>1</minimum>
  <maximum>2048</maximum>
  <randomizable group="0">false</randomizable>
  <value>256</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>40</x>
  <y>153</y>
  <width>80</width>
  <height>30</height>
  <uuid>{0c5a5f45-e32e-4e9c-b277-3c4e6c3cc04d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>No. Oscs</label>
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
  <x>303</x>
  <y>153</y>
  <width>80</width>
  <height>30</height>
  <uuid>{c7b8f937-676e-40dd-99c4-9aadc4aafe48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bin Increment</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Bin_Increment</objectName>
  <x>383</x>
  <y>153</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f83a5be2-dec4-4c9f-a1c9-b584b0a8c120}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <minimum>1</minimum>
  <maximum>2048</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

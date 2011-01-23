;Written by Iain McCurdy

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 January 2011 and QuteCsound svn rev 805

;Notes on modifications from original csd:
;	Add audio file browser

;my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 --expression-opt -+rtmidi=null
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 64		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkatt		invalue	"Attack"
		gkrel		invalue	"Release"
		gksensitivity	invalue	"Sensitivity"
		gkoffset		invalue	"Filter_Cutoff"
		gkres		invalue	"Filter_Resonance"
		gkspeed		invalue	"File_Speed"
		gkmix		invalue	"Filter_Mix"
		gkamp		invalue   "Output_Gain"
		gkingain		invalue 	"Input_Gain"
		gkinput		invalue	"Input"
	endif
endin

instr	1
		Sfile_new		strcpy	""									;INIT TO EMPTY STRING
		Sfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	Sfile
		kfile 		strcmpk	Sfile_new, Sfile_old

		if	kfile != 0	then										;IF A BANG HAD BEEN GENERATED IN THE LINE ABOVE
				reinit	NEW_FILE									;REINITIALIZE FROM LABEL 'NEW_FILE'
		endif

	if	gkinput=0	then												;IF INPUT SWITCH IS SET TO 'LIVE INPUT' THEN... 
		aL, aR	ins												;READ THE LIVE AUDIO INPUT TO THE COMPUTER
		aL	=	aL * gkingain										;SCALE LIVE INPUT WITH FLTK SLIDER	
		aR	=	aR * gkingain       							  	;SCALE LIVE INPUT WITH FLTK SLIDER
	else
		NEW_FILE:
		;OUTPUT	OPCODE	FILE_PATH | SPEED  | INSKIP | LOOPING_0=OFF/1=ON
		aL		diskin2	Sfile,      gkspeed,   0,        1				;CREATE AN AUDIO SIGNAL
		aR		=	aL											;ASSIGN RIGHT CHANNEL TO BE THE SAME AS THE LEFT CHANNEL SIGNAL
				rireturn
	endif														;END OF CONDITIONAL BRANCHING

	;LEFT CHANNEL===========================================================================================================================================================
	afollowL		follow2		aL, gkatt, gkrel						;CREATE AN ENVELOPE FOLLOWING SIGNAL FROM THE AUDIO SIGNAL
	kfollowL		downsamp		afollowL								;DOWNSAMPLE AMPLITUDE FOLLOWING SIGNAL DOWN TO K-RATE					
	kcfoctL		=			(kfollowL * gksensitivity) + gkoffset		;RE-SCALE THIS SIGNAL USING THE SENSITIVITY AND OFFSET SETTINGS - OUTPUT WILL BE USED AS A FILTER CUTOFF VALUE IN OCT FORMAT
	kcfoctL		limit		kcfoctL, 4, 14							;LIMIT THE RANGE OF THE CUTOFF FREQUENCY (REMEMBER: OCT FORMAT)
	afiltL		moogladder	aL, cpsoct(kcfoctL), gkres				;FILTER THE AUDIO SIGNAL USING THE moogladder RESONANT LOWPASS FILTER
	amixL		ntrpol		aL, afiltL, gkmix						;CREATE A DRY/WET MIX BETWEEN THE ORIGINAL SIGNAL AND THE FILTERED SIGNAL
	;=======================================================================================================================================================================

	;RIGHT CHANNEL==========================================================================================================================================================
	afollowR		follow2		aR, gkatt, gkrel						;CREATE AN ENVELOPE FOLLOWING SIGNAL FROM THE AUDIO SIGNAL
	kfollowR		downsamp		afollowR								;DOWNSAMPLE AMPLITUDE FOLLOWING SIGNAL DOWN TO K-RATE					
	kcfoctR		=			(kfollowR * gksensitivity) + gkoffset		;RE-SCALE THIS SIGNAL USING THE SENSITIVITY AND OFFSET SETTINGS - OUTPUT WILL BE USED AS A FILTER CUTOFF VALUE IN OCT FORMAT
	kcfoctR		limit		kcfoctR, 4, 14							;LIMIT THE RANGE OF THE CUTOFF FREQUENCY (REMEMBER: OCT FORMAT)
	afiltR		moogladder	aR, cpsoct(kcfoctR), gkres				;FILTER THE AUDIO SIGNAL USING THE moogladder RESONANT LOWPASS FILTER
	amixR		ntrpol		aR, afiltR, gkmix						;CREATE A DRY/WET MIX BETWEEN THE ORIGINAL SIGNAL AND THE FILTERED SIGNAL
	;=======================================================================================================================================================================

				outs			amixL * gkamp, amixR * gkamp				;SEND DRY/WET MIX TO THE SPEAKERS - RESCALE WITH GAIN CONTROL
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0	   3600	;GUI
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>649</x>
 <y>355</y>
 <width>795</width>
 <height>451</height>
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
  <height>444</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>follow2 Envelope Filter</label>
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
   <r>158</r>
   <g>220</g>
   <b>158</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>519</x>
  <y>2</y>
  <width>276</width>
  <height>444</height>
  <uuid>{cebe7e5c-304d-4db6-8da2-0e27c0616bab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>follow2 Envelope Filter</label>
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
   <r>158</r>
   <g>220</g>
   <b>158</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>521</x>
  <y>35</y>
  <width>272</width>
  <height>395</height>
  <uuid>{c24a85f3-363e-476e-81da-37729ad65bb7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------
The follow2 opcode outputs an amplitude following signal based on an imput audio signal.
The output signal will be unipolar (i.e. only positive values) and the response of the envelope follower to dynamic transients can be tailored using follow2's input arguments for attack time and release time.
This example demonstrates a very common use of this control signal in that it is used to derive the cutoff frequency of a lowpass filter.
Therefore as the amplitude of the input signal increases the cutoff frequency of the filter also rises.
Some additional controls are offered to allow the user to further refine the envelope follower response and some other aspects of the effect.
The user can choose between using a stored file or the live input as the source signal for the envelope follower.</label>
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
   <r>158</r>
   <g>220</g>
   <b>158</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>277</y>
  <width>150</width>
  <height>30</height>
  <uuid>{63ab529c-3f14-4886-8215-fd6e8f1a37ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Filter Cutoff Offset</label>
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
  <objectName>Filter_Cutoff</objectName>
  <x>8</x>
  <y>260</y>
  <width>500</width>
  <height>27</height>
  <uuid>{a7c37920-a18a-446b-8b66-6a1119503da0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>4.00000000</minimum>
  <maximum>14.00000000</maximum>
  <value>11.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Filter_Cutoff</objectName>
  <x>448</x>
  <y>277</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b453c0e4-809f-4074-94fd-506ebb68f3b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>11.100</label>
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
  <x>8</x>
  <y>313</y>
  <width>150</width>
  <height>30</height>
  <uuid>{760945fc-2052-4408-8344-abdb00ead7b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Filter Resonance</label>
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
  <objectName>Filter_Resonance</objectName>
  <x>8</x>
  <y>296</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d5b42e3d-c45f-4288-bb9c-16eb365124bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.67400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Filter_Resonance</objectName>
  <x>448</x>
  <y>313</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3837993c-b043-4b23-a36f-83ea6a2f2d2b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.674</label>
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
  <x>8</x>
  <y>349</y>
  <width>150</width>
  <height>30</height>
  <uuid>{7e59b44f-2b3b-4941-9e17-c56369f9316a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>File Playback Speed</label>
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
  <objectName>File_Speed</objectName>
  <x>8</x>
  <y>332</y>
  <width>500</width>
  <height>27</height>
  <uuid>{84d39e8a-7044-4434-92fd-919cc03f9d01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.12500000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.99875000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>File_Speed</objectName>
  <x>448</x>
  <y>349</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a4a174c2-d21c-4f3b-a485-d396bc7e9495}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.999</label>
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
  <x>6</x>
  <y>6</y>
  <width>100</width>
  <height>30</height>
  <uuid>{a8382df2-0753-4bc1-808e-285e963e4b7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>    On / Off</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>40</y>
  <width>506</width>
  <height>110</height>
  <uuid>{9c1c687c-f53f-4376-b25d-f216e6129c08}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input</label>
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
  <bordermode>border</bordermode>
  <borderradius>4</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>85</y>
  <width>100</width>
  <height>30</height>
  <uuid>{abb53681-f4b6-418c-b881-9ed47c033f3c}</uuid>
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
  <objectName>Input_Gain</objectName>
  <x>7</x>
  <y>68</y>
  <width>350</width>
  <height>27</height>
  <uuid>{8efe4d81-20fc-42b8-b8fe-e1f0051c8ea1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.77428571</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Input_Gain</objectName>
  <x>297</x>
  <y>85</y>
  <width>60</width>
  <height>30</height>
  <uuid>{eb287858-6115-4ae8-9ecf-3c6296873215}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.774</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>386</x>
  <y>69</y>
  <width>120</width>
  <height>30</height>
  <uuid>{c1af7da4-91c7-49f0-9701-eaba056328f0}</uuid>
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
    <name> Sound File</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>9</x>
  <y>114</y>
  <width>170</width>
  <height>30</height>
  <uuid>{6fba1bc1-9996-4b96-9193-2f29e6d42e07}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/moi/Samples/808loopMono.wav</stringvalue>
  <text>Browse Mono Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>181</x>
  <y>115</y>
  <width>326</width>
  <height>28</height>
  <uuid>{2eaa14cd-5cc8-47b3-b88a-5e778e01082b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/moi/Samples/808loopMono.wav</label>
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
   <r>240</r>
   <g>235</g>
   <b>226</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>170</y>
  <width>150</width>
  <height>30</height>
  <uuid>{93cc32a5-c161-4212-baeb-c28b120f89a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Envelope Follow Attack</label>
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
  <x>8</x>
  <y>153</y>
  <width>500</width>
  <height>27</height>
  <uuid>{107836e5-a726-4a83-83b5-c368481d9a48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.06187800</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Attack</objectName>
  <x>448</x>
  <y>170</y>
  <width>60</width>
  <height>30</height>
  <uuid>{71f0e6eb-f79d-4cd7-80f7-a22cc355e64f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.062</label>
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
  <x>8</x>
  <y>206</y>
  <width>150</width>
  <height>30</height>
  <uuid>{e193ffd3-920b-40d4-9eaa-bd11dad75bff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Envelope Follow Release</label>
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
  <x>8</x>
  <y>189</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e4aa4e7b-5b74-4a61-8bd7-4beea2c0bb93}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.31038000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Release</objectName>
  <x>448</x>
  <y>206</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dc879380-3a9e-4939-b482-a0b4ee46dac5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.310</label>
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
  <x>8</x>
  <y>242</y>
  <width>150</width>
  <height>30</height>
  <uuid>{866a933e-0c0d-493a-84af-29f3557f8e4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Envelope Follow Sensitivity</label>
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
  <objectName>Sensitivity</objectName>
  <x>8</x>
  <y>225</y>
  <width>500</width>
  <height>27</height>
  <uuid>{fbbd0dd3-c206-4214-aa5e-10d42b909252}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>50.00000000</maximum>
  <value>3.60000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Sensitivity</objectName>
  <x>448</x>
  <y>242</y>
  <width>60</width>
  <height>30</height>
  <uuid>{31c3cb1b-308f-47cd-9396-c81d85a1c30a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3.600</label>
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
  <x>8</x>
  <y>385</y>
  <width>150</width>
  <height>30</height>
  <uuid>{79ce92b4-456d-4a0a-aa5d-813238d5011c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Filter Dry / Wet Mix</label>
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
  <objectName>Filter_Mix</objectName>
  <x>8</x>
  <y>368</y>
  <width>500</width>
  <height>27</height>
  <uuid>{012823fb-e024-44a5-9eb4-a410da52002b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.89400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Filter_Mix</objectName>
  <x>448</x>
  <y>385</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d1263e0c-e9f9-4f7c-9ca5-77d2bf37a5d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.894</label>
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
  <x>8</x>
  <y>421</y>
  <width>150</width>
  <height>30</height>
  <uuid>{4f19afc5-41f2-4e4f-902a-4a2efcaab9c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Gain</label>
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
  <objectName>Output_Gain</objectName>
  <x>8</x>
  <y>404</y>
  <width>500</width>
  <height>27</height>
  <uuid>{bc4e33c3-ccd3-40ef-a74d-677666d109ff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.90400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Output_Gain</objectName>
  <x>448</x>
  <y>421</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b61a9062-7122-4334-8e11-151993d154a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.904</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

;Written by Iain McCurdy 2011

;Modified for QuteCsound by René, May 2011
;Tested on Ubuntu 10.04 with csound-float (git csound5-3c6d155, May 31 2011) and QuteCsound svn rev 848


;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio files, accept mono or stereo wav files
;	Instrument 1 is activated by MIDI and by the GUI, added pitchbend
;	Removed ifftsize, default to 2048


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0 --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


giExp1		ftgen	0, 0, 129, -25, 0, 0.125, 128, 4.0			;TABLE FOR EXP SLIDER


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		kfreeze		invalue	"Freeze"
		gkfreeze		= (kfreeze + 1)%2
		gktimescal	invalue	"TimeScaling"
		kpitch		invalue	"Pitch"
		gkpitch		tablei	kpitch, giExp1, 1
					outvalue	"Pitch_Value", gkpitch
		gkamp		invalue	"Amp"

		;AUDIO FILE CHANGE / LOAD IN POWER OF 2 TABLES **********************************************************************************************
		Sfile_new		strcpy	""										;INIT TO EMPTY STRING

		Sfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	Sfile
		kfile 		strcmpk	Sfile_new, Sfile_old

		gkfile_new	init		0
		if	kfile != 0	then											;IF A BANG HAD BEEN GENERATED IN THE LINE ABOVE
			gkfile_new	=	1										;Flag to inform instr 1 that a new file is loaded
				reinit	NEW_FILE										;REINITIALIZE FROM LABEL 'NEW_FILE'
		endif
		NEW_FILE:
		;FUNCTION TABLES NUMBERS OF THE SOUND FILE THAT WILL BE GRANULATED
		ichn			filenchnls	Sfile
		if ichn == 1 then
			giFileL	ftgentmp	0, 0, 0, 1, Sfile, 0, 0, 1				;READ MONO AUDIO FILE CHANNEL 1
			giFileR	=		giFileL
		else
			giFileL	ftgentmp	0, 0, 0, 1, Sfile, 0, 0, 1				;READ STEREO AUDIO FILE CHANNEL 1
			giFileR	ftgentmp	0, 0, 0, 1, Sfile, 0, 0, 2				;READ STEREO AUDIO FILE CHANNEL 2
		endif
;*******************************************************************************************************************************************
	endif
endin

instr 1
	if p4!=0 then														;MIDI
		ioct		=	p4												;READ OCT VALUE FROM MIDI INPUT
		;PITCH BEND=============================================================================================
		iSemitoneBendRange = 12											;PITCH BEND RANGE IN SEMITONES
		imin		= 0													;EQUILIBRIUM POSITION
		imax		= iSemitoneBendRange * .0833333							;MAX PITCH DISPLACEMENT (IN oct FORMAT)
		kbend	pchbend	imin, imax									;PITCH BEND VARIABLE (IN oct FORMAT)
		kcps		=	cpsoct(ioct + kbend)								;SET FUNDAMENTAL
		;=======================================================================================================
	endif

	kporttime	linseg	0, 0.001, 0.02										;CREATE A VARIABLE FUNCTION THAT RAPIDLY RAMPS UP TO A SET VALUE	

	if p4!=0 then														;IF THIS IS A MIDI ACTIVATED NOTE... 
		kpitch	=		kcps/cpsoct(8)									;MAP TO MIDI NOTE VALUE TO PITCH (CONVERT TO RATIO: MIDDLE C IS POINT OF UNISON)
	else																;OTHERWISE...
		kpitch	portk	gkpitch, kporttime								;USE THE GUI SLIDER VALUE
	endif															;END OF THIS CONDITIONAL BRANCH

	kamp		portk	gkamp, kporttime									;APPLY PORTAMENTO SMOOTHING TO AMPLITUDE SLIDER VALUE

	if	gkfile_new = 1	then												;test if a new file is loaded by instr 10
		gkfile_new = 0													;flag to zero for next file change
		reinit	UPDATE2												;REINITIALIZE FROM LABEL 'NEW_FILE1'
	endif

	UPDATE2:															;LABEL CALLED 'UPDATE2'
	fsigL	pvstanal	gktimescal*gkfreeze,kamp,kpitch,giFileL
	fsigR	pvstanal	gktimescal*gkfreeze,kamp,kpitch,giFileR

	asigL	pvsynth	fsigL
	asigR	pvsynth	fsigR
	
	aenv		linsegr	0, 0.05, 1, 0.05, 0									;DE-CLICKING ENVELOPE
			outs		asigL*aenv, asigR*aenv								;SEND AUDIO TO OUTPUTS
endin

instr	2	;SET TIME SCALING SLIDER TO P4 DETERMINED VALUES
		outvalue	"TimeScaling", p4
endin

instr	3	;SET TIME SCALING SLIDER TO P4 DETERMINED VALUES
		outvalue	"Pitch", p4
endin

instr	11	;INIT
		outvalue	"TimeScaling"	, 1.0
		outvalue	"Pitch"		, 0.6
		outvalue	"Amp"		, 1.0
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0	   3600	;GUI
i 11		0		0	;INIT
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>240</x>
 <y>198</y>
 <width>1107</width>
 <height>282</height>
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
  <height>280</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvstanal</label>
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
  <width>590</width>
  <height>280</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvstanal</label>
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
  <y>21</y>
  <width>583</width>
  <height>258</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------------------------------------------------------
'pvstanal' is very similar to the 'temposcal' opcode. Its priniciple difference is that it outputs an fsig as opposed to an audio signal as is the case with temposcal. An fsig might be a preferrable output if you are wanting to perform further processing using other pvs opcodes. pvstanal does not include the phase locking feature of temposcal. pvstanal uses phase vocoding to resynthesize a sound file stored in a GEN 1 function table. Movement through the sound file is controlled using a time scaling control. On screen switches allow the user to instantly freeze the sound or restore normal speed. Pitch can be controlled independently using a pitch ratio control. Unison can be restored using an on screen switch. The user can choose between four input sound file options. A variety of FFT sizes can be explored - smaller sizes will will result in less time smearing by more spectral distortion larger sizes will result in less spectral distortion but more time smearing. This example can also be activated from a MIDI keyboard in which case MIDI pitch is mapped to the the pitch ratio used by pvstanal. In this mode the GUI slider for pitch will be ignored. Middle C is the point of no transposition.</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
  <y>8</y>
  <width>120</width>
  <height>30</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>TimeScaling</objectName>
  <x>448</x>
  <y>73</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-0.720</label>
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
  <objectName>TimeScaling</objectName>
  <x>8</x>
  <y>51</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>-0.72000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>73</y>
  <width>150</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Time Scaling</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>7</x>
  <y>205</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>AndItsAll.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>177</x>
  <y>206</y>
  <width>330</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>AndItsAll.wav</label>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch_Value</objectName>
  <x>448</x>
  <y>121</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e18e15d6-c58d-4c38-a766-79602b72f947}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
  <objectName>Pitch</objectName>
  <x>8</x>
  <y>99</y>
  <width>500</width>
  <height>27</height>
  <uuid>{36779c76-0b42-4e18-819b-e02bf72d22dd}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>121</y>
  <width>150</width>
  <height>30</height>
  <uuid>{b74148fe-3ba3-4d62-b507-64eb27627e65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch</label>
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
  <objectName>Amp</objectName>
  <x>448</x>
  <y>169</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3c299cf9-f5e6-4902-9f6c-4d3802f1beb8}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Amp</objectName>
  <x>8</x>
  <y>147</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b96a19b5-e2ff-4bc8-9d9c-e1878dc2c7ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>169</y>
  <width>150</width>
  <height>30</height>
  <uuid>{3f67483e-a5a5-4c55-8c4c-802b8cb45fcb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>308</x>
  <y>73</y>
  <width>70</width>
  <height>18</height>
  <uuid>{eae817a3-8fa5-472e-86fa-a19ee5f5199d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Normal</text>
  <image>/</image>
  <eventLine>i 2 0 0.01 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>378</x>
  <y>121</y>
  <width>70</width>
  <height>18</height>
  <uuid>{a671a876-7584-4a8c-9438-d9aa42ba31f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Unisson</text>
  <image>/</image>
  <eventLine>i 3 0 0.01 0.6</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Freeze</objectName>
  <x>378</x>
  <y>73</y>
  <width>70</width>
  <height>18</height>
  <uuid>{5054e50c-733d-4f88-ae43-edf85e623ebe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  Freeze</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

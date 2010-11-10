;Written by Iain McCurdy 2009

; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 1		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


giphasor			ftgen	0, 0, 65536, 7, 0, 65536, 1		;WAVE SHAPE FOR A MOVING PHASE POINTER

giFFTattributes0	ftgen	1, 0, 4, -2,  512, 256, 1024, 1
giFFTattributes1	ftgen	2, 0, 4, -2, 1024, 256, 1024, 1
giFFTattributes2	ftgen	3, 0, 4, -2, 2048, 256, 2048, 1
giFFTattributes3	ftgen	4, 0, 4, -2, 2048, 128, 2048, 1
giFFTattributes4	ftgen	5, 0, 4, -2, 4096, 128, 4096, 1


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkInGain			invalue	"Input_Gain"		;init 1.0
		gkbuflen			invalue	"Buffer_Length"	;init 1.0
		gkphrange			invalue	"Phasor_Range"		;init 1.0
		gkspeed			invalue	"Phasor_Speed"		;init 1.0
		gkPhOffset		invalue	"Phasor_Offset"	;init 0.0
		gkscal			invalue	"Pitch_Rescale"	;init 0.0
		gkfbratio			invalue	"Feedback_Ratio"	;init 0.0
		gkdirect			invalue	"Direct"			;init 0.0
		gkOutGain			invalue	"Output_Gain"		;init 1.0
		gkwrite			invalue 	"Write_Pointer"	
		gkread			invalue 	"Read_Pointer"

		gkWriteEnable		invalue	"Write_Buffer"		;init 1
		gkSyncToWrite		invalue	"Sync_Write"
		gkFFTattributes	invalue	"FFTattributes"	;init 1
	endif
endin

instr	1
	kSwitch		changed		gkFFTattributes, gkbuflen				;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then
		reinit	UPDATE
	endif
	UPDATE:
	afeedback		init		0										;INITIALISE FEEDBACK SIGNAL (FOR FIRST PASS)
	ain			inch		1										;READ AUDIO FROM 1ST INPUT CHANNEL (LEFT)
	ain			= ain*gkInGain										;SCALE INPUT WITH 'Input Gain' SLIDER
	ain			= ain + afeedback									;ADD FEEDBACK SIGNAL TO INPUT SIGNAL
	ibuflen		= i(gkbuflen)										;CREATE I-RATE VERSION OF BUFFER LENGTH

	iFFTsize		table	0, i(gkFFTattributes)+1
	ioverlap		table	1, i(gkFFTattributes)+1
	iwinsize		table	2, i(gkFFTattributes)+1
	iwintype		table	3, i(gkFFTattributes)+1	

	fsig1  		pvsanal	ain, iFFTsize, ioverlap, iwinsize, iwintype		;ANALYSE THE AUDIO SIGNAL THAT WAS CREATED IN INSTRUMENT 1. OUTPUT AN F-SIGNAL.

	if	gkWriteEnable=1	then
		ibuffer,ktime  	pvsbuffer   fsig1, ibuflen					;BUFFER FSIG
	endif
	khandle		init 	ibuffer									;INITIALISE HANDLE TO BUFFER
	if	gkSyncToWrite=0	then
		aread 	osciliktp gkspeed/ibuflen, giphasor, gkPhOffset			;CREATE MOVING POINTER TO READ FROM BUFFER
		kread	downsamp	aread									;DOWNSAMPLE BUFFER TO K-RATE, pvsbufread ONLY ACCEPTS A K-RATE POINTER
		kread	= kread * gkphrange * ibuflen							;RESCALE READ POINTER WITH PHASOR RANGE SLIDER
	elseif	gkSyncToWrite=1	then
		kread	=	ktime										;SYNC TO WRITE POINTER
		kread	=	kread + (gkPhOffset * ibuflen)					;ADD PHASE OFFSET AND SCALE ACCORDING TO BUFFER LENGTH
		kread	wrap	kread, 0, ibuflen								;WRAP-AROUND READ POINTER VALUE TO PREVENT OUT OF RANGE VALUES 
	endif
	fsig2  		pvsbufread  	kread , khandle						;READ BUFFER
	kscal		= cpsoct(gkscal+8)/cpsoct(8)							;CREATE PITCH RESCALING VARIABLE

	;OUTPUT		OPCODE	INPUT | RESCALE_VALUE | FORMANT_MODE |   GAIN
	fsig3 		pvscale 	fsig2,      kscal							;RESCALE THE FREQUENCY VALUES ACCORDING TO THE INPUT ARGUMENT gkscal.	

	aresyn 		pvsynth  	fsig3                  					 	;RESYNTHESIZE THE f-SIGNAL AS AN AUDIO SIGNAL	
	afeedback		= aresyn * gkfbratio								;CREATE FEEDBACK SIGNAL FOR NEXT PASS THROUGH THE CODE	
	aout			= (aresyn*gkOutGain*2)+(ain*gkdirect)					;CREATE OUTPUT SIGNAL
				outs		aout, aout

	ktrigger		metro	10
	if ktrigger == 1 then
		outvalue	"Write_Pointer", ktime
		outvalue	"Read_Pointer", kread
	endif
			rireturn
endin

instr	2	;FREEZE POINTER
	;THIS INSTRUMENT FREEZES POINTER MOVEMENT BY SIMPLY SETTING READ POINTER FREQUENCY TO ZERO 
	outvalue	"Phasor_Speed", 0
endin

instr	3	;SET READ POINTER PHASE OFFSET TO ZERO
	outvalue	"Phasor_Offset", 0
endin

instr	4	;SET PITCH RESCALE TO ZERO
	outvalue	"Pitch_Rescale", 0
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0	   3600	;GUI
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>945</width>
 <height>700</height>
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
  <height>614</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvsbuffer pvsbufread</label>
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
  <width>348</width>
  <height>614</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvsbuffer pvsbufread</label>
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
  <x>519</x>
  <y>19</y>
  <width>343</width>
  <height>594</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------
pvsbuffer writes an fsig into a circular buffer (of user definable duration using the 'Buffer Length' slider). Progress of writing into the buffer is displayed by the moving red bar. pvsbufread reads the fsig from this buffer using a k-rate pointer. This pointer can be moved freely so playback can be slower, faster, frozen or backwards. In this example a moving phase pointer has been created using the oscilktp opcode to read from the buffer. The user can vary the range, speed and offset of the pointer. The progress of the read pointer is displayed by the moving green bar. Clicking the 'Freeze' button is simply an easy way of setting 'Read Phasor Speed' to zero. Selecting 'Sync To Write' will synchronise the read pointer to the write pointer. Adjusting 'Read Phasor Offset' will shift the read pointer's location with respect to the write pointer. 'Read Phasor Speed' and 'Read Phasor Range' will have no effect when this mode is active. De-selecting the 'Write To Buffer' button will deactivate writing to the buffer.
This will therefore prevent overwriting of the buffer allowing the user to manipulate a fixed chunk of sound. This switch needs to initially be active in order to first fill the buffer. The output fsig from the pvsbufread is passed through a pvscale opcode which allows the pitch to be rescaled before being resynthesized and sent to the outputs. Additionally a feedback loop permits some or all of the output signal to be fed back into the input. The user can select between a variety of combinations of parameters for the FFT analysis. Larger values for FFT size will give better harmonic reproduction but greater time smearing effects and higher computational cost. Lower values will result in less time smearing but greater harmonic distortion. This example uses the computer's live input (channel 1/left) as input.</label>
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
  <objectName>ON_OFF</objectName>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Input_Gain</objectName>
  <x>450</x>
  <y>71</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5ba6647c-7395-493b-94fb-2e39de38cae6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.190</label>
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
  <objectName>Input_Gain</objectName>
  <x>10</x>
  <y>54</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2440dba1-0ca3-473e-9e1c-590341c95eaf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.19000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>71</y>
  <width>150</width>
  <height>30</height>
  <uuid>{40ab6aec-b542-473a-97c1-8e1d3da00a5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input Gain</label>
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
  <objectName>Buffer_Length</objectName>
  <x>450</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7760eb6e-e14b-485f-a2f6-46a3fb79fa71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.010</label>
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
  <objectName>Buffer_Length</objectName>
  <x>10</x>
  <y>95</y>
  <width>500</width>
  <height>27</height>
  <uuid>{daf328f8-0158-459b-9ed0-2f3c65031ad0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.01000000</minimum>
  <maximum>20.00000000</maximum>
  <value>1.00950000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>112</y>
  <width>150</width>
  <height>30</height>
  <uuid>{ca0b021c-8ec2-4628-ad65-be1b22eea34d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Buffer Length (i-rate)</label>
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
  <x>10</x>
  <y>536</y>
  <width>500</width>
  <height>70</height>
  <uuid>{f0c4875d-4e35-4d37-b043-9c1476025645}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FFT Attributes</label>
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
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>169</x>
  <y>542</y>
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
  <y>562</y>
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
    <name>2048       128       2048            1</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4096       128       4096            1</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>192</y>
  <width>150</width>
  <height>30</height>
  <uuid>{c5a959e6-b181-47c7-950c-1b5f1b071d1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Read Phasor Speed</label>
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
  <objectName>Phasor_Speed</objectName>
  <x>10</x>
  <y>175</y>
  <width>500</width>
  <height>27</height>
  <uuid>{70b7db2b-b555-44b0-ad55-80890f452ebd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-5.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Phasor_Speed</objectName>
  <x>450</x>
  <y>192</y>
  <width>60</width>
  <height>30</height>
  <uuid>{063807ca-da21-4e11-a78a-a60b3271ad0c}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>152</y>
  <width>150</width>
  <height>30</height>
  <uuid>{a560559b-2cc6-4f8a-aa5f-72c133e739ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Read Phasor Range</label>
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
  <objectName>Phasor_Range</objectName>
  <x>10</x>
  <y>135</y>
  <width>500</width>
  <height>27</height>
  <uuid>{99363b37-c4e4-409f-a17d-07f383f5698e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.90600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Phasor_Range</objectName>
  <x>450</x>
  <y>152</y>
  <width>60</width>
  <height>30</height>
  <uuid>{58be2bf8-bcdd-44ef-b4a5-68d454edcae5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.906</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>174</x>
  <y>201</y>
  <width>120</width>
  <height>21</height>
  <uuid>{80fc2cb9-9f75-49b7-bab9-b55e2180b5f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Freeze</text>
  <image>/</image>
  <eventLine>i 2 0 0</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Sync_Write</objectName>
  <x>318</x>
  <y>201</y>
  <width>120</width>
  <height>21</height>
  <uuid>{4e16311f-445a-4c4d-bbe8-632d9a729c8e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Sync to Write</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Write_Buffer</objectName>
  <x>390</x>
  <y>8</y>
  <width>120</width>
  <height>30</height>
  <uuid>{2ad28f56-7ad5-4284-a284-d53424731e68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  Write to Buffer</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>318</x>
  <y>298</y>
  <width>120</width>
  <height>21</height>
  <uuid>{c301949e-9ef0-4ee5-b06b-1b2105b5ed08}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Set to Zero</text>
  <image>/</image>
  <eventLine>i 4 0 0</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Phasor_Offset</objectName>
  <x>450</x>
  <y>242</y>
  <width>60</width>
  <height>30</height>
  <uuid>{527a33d3-9b62-47bf-8b20-34c2bc33a28a}</uuid>
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
  <objectName>Phasor_Offset</objectName>
  <x>10</x>
  <y>225</y>
  <width>500</width>
  <height>27</height>
  <uuid>{9c99b0ca-36dc-4039-bc0d-a22a34550faa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>242</y>
  <width>150</width>
  <height>30</height>
  <uuid>{0cc3d539-10a5-46f7-8103-18276dd3f687}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Read Phasor Offset</label>
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
  <objectName>Pitch_Rescale</objectName>
  <x>450</x>
  <y>292</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e93947bb-b0f0-4fbd-a759-a5040ae43187}</uuid>
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
  <objectName>Pitch_Rescale</objectName>
  <x>10</x>
  <y>275</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b40d90ab-8baf-4a1c-b777-9c0c6fc85466}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>292</y>
  <width>150</width>
  <height>30</height>
  <uuid>{ab675e24-1897-41de-bda8-0284bfbd2e40}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch Rescale (octaves)</label>
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
  <x>318</x>
  <y>248</y>
  <width>120</width>
  <height>21</height>
  <uuid>{e9d95e57-8c27-4a74-8c7b-af3df79c7ac2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Set to Zero</text>
  <image>/</image>
  <eventLine>i 3 0 0</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>343</y>
  <width>150</width>
  <height>30</height>
  <uuid>{a4db22d6-0671-4e61-9d77-0ffaaa70869d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feedback Ratio</label>
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
  <objectName>Feedback_Ratio</objectName>
  <x>10</x>
  <y>326</y>
  <width>500</width>
  <height>27</height>
  <uuid>{4c4301d3-1442-4360-86e3-70f653b007b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.50000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Feedback_Ratio</objectName>
  <x>450</x>
  <y>343</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ae071395-0b57-418a-a019-371cc32eef38}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Direct</objectName>
  <x>450</x>
  <y>382</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5bf4b300-6cfc-4d08-a2c2-00f6d7af81e7}</uuid>
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
  <objectName>Direct</objectName>
  <x>10</x>
  <y>365</y>
  <width>500</width>
  <height>27</height>
  <uuid>{a3ec44bb-be40-464f-bf7d-bf0a2bf72ecf}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>382</y>
  <width>150</width>
  <height>30</height>
  <uuid>{0f91372a-83ee-498f-adf3-275d1dc4115d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Direct</label>
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
  <objectName>Output_Gain</objectName>
  <x>450</x>
  <y>422</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e4e9e272-3a95-4f12-a0c1-116ccae1afda}</uuid>
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
  <objectName>Output_Gain</objectName>
  <x>10</x>
  <y>405</y>
  <width>500</width>
  <height>27</height>
  <uuid>{a59fac78-7280-4b5d-8f97-67320e172a6d}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>422</y>
  <width>150</width>
  <height>30</height>
  <uuid>{8f8f00e1-a7bd-4e91-ad0c-d7a6871afc95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Gain</label>
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
  <x>10</x>
  <y>466</y>
  <width>150</width>
  <height>30</height>
  <uuid>{94580bf4-87b4-409f-b3e2-db84dc1c9210}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Write Pointer</label>
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
  <objectName>Write_Pointer</objectName>
  <x>450</x>
  <y>465</y>
  <width>60</width>
  <height>30</height>
  <uuid>{40cc07f7-e527-4814-b062-443b165d39a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.296</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Write_Pointer</objectName>
  <x>10</x>
  <y>451</y>
  <width>500</width>
  <height>15</height>
  <uuid>{e32eeb8f-72e6-4ca6-88e0-6b337650892b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>20.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.29605442</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>Read_Pointer</objectName>
  <x>10</x>
  <y>488</y>
  <width>500</width>
  <height>15</height>
  <uuid>{5e292afb-45e9-4aa8-b7d1-da1d885ed4dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>20.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.01831282</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Read_Pointer</objectName>
  <x>450</x>
  <y>503</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d3c87e47-f966-4da3-8792-03363523d908}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.018</label>
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
  <y>503</y>
  <width>150</width>
  <height>30</height>
  <uuid>{fdc080f9-17c6-43bb-a9a0-751149a62c11}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Read Pointer</label>
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
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

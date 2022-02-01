;Written by Iain McCurdy 2011

;Modified for QuteCsound by René, May 2011
;Tested on Ubuntu 10.04 with csound-float (git csound5-3c6d155, May 31 2011) and QuteCsound svn rev 848


;Notes on modifications from original csd:
;	Add table(s) for exp slider


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SADIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 1		;NUMBER OF CHANNELS (2=STEREO)


giExp1	ftgen	0, 0, 129, -25, 0, 0.125, 128, 4.0		;TABLE FOR EXP SLIDER

		strset	1, "Write"
		strset	2, "Read"

#define	ANALYSISFILE	#"pvswriteFile.pvx"#

instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		;BUTTONS
		gkwrite		invalue	"Write"
		gkread		invalue	"Read"				;lance i 2 0 3600
		;SLIDERS
		gkptr		invalue	"Pointer"
		gkspeed		invalue	"Speed"
		ktrans		invalue	"Transpose"
		gktrans		tablei	ktrans, giExp1, 1
					outvalue	"Transpose_Value", gktrans
		gkGain		invalue	"Gain"
		;MENU
		gkPtrMode		invalue	"Mode"
	endif
endin

instr	1	;WRITE PVS FILE
			event_i		"i", 3, 0, 0.01, 2, 2				;to prevent to read while writing				
	
	asigin	inch			1								;READ AUDIO FROM THE LIVE AUDIO INPUT
	fsigin 	pvsanal		asigin, 1024, 256, 1024, 1			;ANALYSE THE AUDIO SIGNAL THAT WAS CREATED IN INSTRUMENT 1. OUTPUT AN F-SIGNAL.      	
			pvsfwrite 	fsigin, $ANALYSISFILE
endin

instr	2	;READ PVS FILE
			event_i		"i", 3, 0, 0.01, 1, 1				;to prevent to write while reading

	ilen		filelen		$ANALYSISFILE
	kporttime	linseg		0,0.001,0.05

	if gkPtrMode==0 then
		kptr		portk	gkptr, kporttime
	else
		kptr		phasor	gkspeed/ilen
	endif

	fsig1	pvsfread		kptr*ilen,$ANALYSISFILE
	fsig2	pvscale		fsig1, gktrans

	aresyn 	pvsynth		fsig2							;RESYNTHESIZE THE f-SIGNAL AS AN AUDIO SIGNAL
			out			aresyn*gkGain
endin

instr	3	;CONTROLS
	Str	strget	p5
		turnoff2	p4, 0, 0
		outvalue	Str, 0
		turnoff
endin

instr	11	;INIT
		outvalue	"Gain"		, 0.5
		outvalue	"Mode"		, 1
		outvalue	"Speed"		, 1
		outvalue	"Pointer"		, 0.5
		outvalue	"Transpose"	, 0.6
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
 <x>73</x>
 <y>206</y>
 <width>865</width>
 <height>362</height>
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
  <height>360</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvswrite</label>
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
  <width>348</width>
  <height>360</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvswrite</label>
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
  <width>342</width>
  <height>336</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------
'pvswrite' allows you to write a streaming f-sig to a pvx file stored on disk. The stored pvx file can be accessed later during that performance or in a completely new performance. In this example the user first records a pvx file to disk using the 'Write' button to start and then stop this procedure. The audio for this pvx file is taken from the computer's live input. This stored file can then be replayed using the 'play' button. 'pvsfread' is used to replay the file and the user can choose between two modes of playback:
one in which a pointer through the file is controlled manually and another in which the user controls the playback speed. The user can also modulate the transposition of the file - this is implemented using the 'pvscale' opcode. As the file is loaded once during playback, re-recording a new file will not overwrite the original file loaded into memory, instead performance will need to be restarted.</label>
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
  <objectName>Write</objectName>
  <x>8</x>
  <y>55</y>
  <width>80</width>
  <height>30</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     Write</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pointer</objectName>
  <x>448</x>
  <y>133</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.674</label>
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
  <objectName>Pointer</objectName>
  <x>8</x>
  <y>111</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>133</y>
  <width>150</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>File Pointer</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Speed</objectName>
  <x>448</x>
  <y>181</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e18e15d6-c58d-4c38-a766-79602b72f947}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.736</label>
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
  <objectName>Speed</objectName>
  <x>8</x>
  <y>159</y>
  <width>500</width>
  <height>27</height>
  <uuid>{36779c76-0b42-4e18-819b-e02bf72d22dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.73600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>181</y>
  <width>150</width>
  <height>30</height>
  <uuid>{b74148fe-3ba3-4d62-b507-64eb27627e65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pointer Speed</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Transpose_Value</objectName>
  <x>448</x>
  <y>229</y>
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
  <objectName>Transpose</objectName>
  <x>8</x>
  <y>207</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b96a19b5-e2ff-4bc8-9d9c-e1878dc2c7ea}</uuid>
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
  <y>229</y>
  <width>150</width>
  <height>30</height>
  <uuid>{3f67483e-a5a5-4c55-8c4c-802b8cb45fcb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Transpose</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Gain</objectName>
  <x>448</x>
  <y>277</y>
  <width>60</width>
  <height>30</height>
  <uuid>{44e73856-6869-4340-96a9-e5a61ecd5938}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.752</label>
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
  <x>8</x>
  <y>255</y>
  <width>500</width>
  <height>27</height>
  <uuid>{484ef1b1-d231-454a-b908-cadd3e9dcbc1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.75200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>277</y>
  <width>150</width>
  <height>30</height>
  <uuid>{07143124-f11e-43ad-9bad-2a731b719732}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>Read</objectName>
  <x>90</x>
  <y>55</y>
  <width>80</width>
  <height>30</height>
  <uuid>{ff846fa2-9bfa-40c6-a470-b3b3bf2811f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>     Read</text>
  <image>/</image>
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Mode</objectName>
  <x>240</x>
  <y>55</y>
  <width>162</width>
  <height>30</height>
  <uuid>{faecd829-2f06-4c0e-b683-f5de4235022b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Manual Pointer</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Speed Control</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

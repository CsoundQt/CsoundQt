;Written by Iain McCurdy, 2009


; Modified for QuteCsound by René, November 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio file


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)


;TABLES FOR EXP SLIDER
giExp10000	ftgen	0, 0, 129, -25, 0, 0.1, 128, 10000.0
giExp20000	ftgen	0, 0, 129, -25, 0, 20.0, 128, 20000.0


instr	1	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then

		Sfile_new	strcpy	""						;INIT TO EMPTY STRING

		kbf			invalue 	"Base_Frequency"
		gkbf			tablei	kbf, giExp20000, 1
					outvalue	"Base_Frequency_Value", gkbf

		kbw			invalue 	"Bandwidth"
		gkbw			tablei	kbw, giExp10000, 1
					outvalue	"Bandwidth_Value", gkbw

		gkgain		invalue 	"Output_Gain"

		gksepmode		invalue	"Separation_Mode"
		gkscl		invalue	"Scaling_Mode"
		gknum		invalue	"Number_Filters"
		gkskip		invalue	"Initialisation"

		;IF SEPARATION MODE IS 'HERTZ' THEN SEPARATION SHOULD NOT BE LESS THAT 0, THE FOLLOWING LINES OF CODE PROTECT AGAINST THIS 
		gksep		invalue 	"Separation"
		if	gksepmode==1	then														;IF gksepmode IS 'HERTZ'...
			gksep	=	abs(gksep)												;...FINAL SEPARATION VALUE IS AN ABSOLUTE VERSION OF gksep (I.E. CANNOT BE NEGATIVE)
		endif																	;END OF CONDITIONAL BRANCHING
					outvalue	"Separation_Value", gksep								;UPDATE SEPARATION DISPLAY BOX IF VALUE HAS CHANGED

		gSfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	gSfile
		gkfile 		strcmpk	Sfile_new, Sfile_old
	endif
endin

instr	2
	kporttime		linseg	0,0.001,0.005,1,0.005										;CREATE A VARIABLE FUNCTION THAT RAPIDLY RAMPS UP TO A SET VALUE	
	kbf			portk	gkbf, kporttime											;SMOOTH MOVEMENT OF SLIDER VARIABLE


	kNew_file		changed	gkfile													;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kNew_file=1	then															;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	NEW_FILE															;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
	endif
	NEW_FILE:
	;OUTPUTS		OPCODE	FILE  | SPEED | INSKIP | LOOPING (0=OFF 1=ON)
	asigL, asigR	diskin2	gSfile,  1,      0,         1									;GENERATE 2 AUDIO SIGNALS FROM A STEREO SOUND FILE
				rireturn															;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES

	kSwitch		changed	gkscl, gkskip, gknum, gksepmode								;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)	
	if	kSwitch=1	then																;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	START															;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
	endif
	START:
	ksep			lineto	gksep, 0.05												;SMOOTH MOVEMENT OF SLIDER VARIABLE
	aresL 		resony 	asigL, kbf, gkbw, i(gknum), ksep , i(gksepmode), i(gkscl), i(gkskip)
	aresR 		resony 	asigR, kbf, gkbw, i(gknum), ksep , i(gksepmode), i(gkscl), i(gkskip)
				rireturn															;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
				outs		aresL * gkgain, aresR * gkgain								;SEND FILTER OUTPUT TO THE AUDIO OUTPUTS AND SCALE USING THE FLTK SLIDER VARIABLE gkgain
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 1		0	   3600		;GUI
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>389</x>
 <y>118</y>
 <width>1080</width>
 <height>602</height>
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
  <height>410</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>resony</label>
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
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>515</x>
  <y>2</y>
  <width>527</width>
  <height>493</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>resony</label>
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
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>517</x>
  <y>15</y>
  <width>523</width>
  <height>479</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------------
Resony is an implementation of a stack of second-order band--pass filters whose centre frequencies are arithmetically related. The 'bandwidth', 'scaling mode' and 'skip initialisation' parameters are as they are in the reson opcode. 'inum' (number of filters) defines the number of filters in the stack. 'ksep' (separation) defines the separation between the lowest and highest filter in the stack in octaves. How this relates to what the actual centre frequencies of filters differs depending upon which separation mode has been selected and is explained below. 'kbf' (base frequency) defines the centre frequency of the lowest filter. In 'octave' separation mode the pitch interval between the base frequency and (base frequency + separation) is divided into equal intervals according to the number of filters that have been selected. Note that no filter is created at the frequency of (base frequency + separation). For example: if separation=1 and num.filters=2 filters will be created at the base frequency and a tritone above the base frequency (i.e. a interval of 1/2 and octave). If 'hertz' separation mode is selected behaviour is somewhat curious. A filter is never created at the base frequency, this is probably a bug but a simple workaround would be to create a filter separately using a single instance of the reson opcode. Therefore if num.filters=1 no filters are actually created! num.filters=2 creates a single filter and so on. The frequency relationship between filters in the stack always follows the harmonic series. num.filters defines how many stages up the harmonic series are created - remember the fundemental will always be absent! In 'hertz' mode, 'base frequency' and 'separation' have the same effect of moving the entire stack of filters up and down the frequency domain. Negative values for 'separation' are allowed whenever 'separation mode' is 'octaves' (if this is the case, the stack of frequencies will extend below the base frequency). Negative values for 'separation' when 'separation mode' is 'hertz' will cause filters to 'explode'. The code in this example allows negative values for 'separation' whenever 'separation mode' is 'octaves' but prevents them whenever 'separation mode' is 'hertz'.</label>
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
  <y>6</y>
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
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Base_Frequency_Value</objectName>
  <x>448</x>
  <y>63</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>998.129</label>
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
  <objectName>Base_Frequency</objectName>
  <x>8</x>
  <y>46</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.56600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>63</y>
  <width>180</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Base Frequency</label>
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
  <objectName>Bandwidth</objectName>
  <x>8</x>
  <y>84</y>
  <width>500</width>
  <height>27</height>
  <uuid>{42fe25e5-e98f-4f00-872c-f791822a1b3e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.49800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Bandwidth_Value</objectName>
  <x>448</x>
  <y>101</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a8f35453-f236-447d-88d9-1a0b135383b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>30.926</label>
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
  <objectName>Initialisation</objectName>
  <x>380</x>
  <y>6</y>
  <width>130</width>
  <height>30</height>
  <uuid>{88395e38-ecab-4818-bef3-1a18b504f914}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  No Initialisation</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>369</y>
  <width>170</width>
  <height>30</height>
  <uuid>{43341095-bc3a-4607-bd0e-01254da7bc67}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/moi/Samples/Seashore.wav</stringvalue>
  <text>Browse Stereo Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>178</x>
  <y>370</y>
  <width>330</width>
  <height>28</height>
  <uuid>{b66f3878-dfd0-4290-9b9d-73be88197222}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/moi/Samples/Seashore.wav</label>
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
  <x>8</x>
  <y>347</y>
  <width>160</width>
  <height>30</height>
  <uuid>{7e1e7af4-88dd-4046-a781-fa2dc828b980}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>File Input</label>
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
  <objectName>Scaling_Mode</objectName>
  <x>184</x>
  <y>142</y>
  <width>250</width>
  <height>30</height>
  <uuid>{b8bfe659-5312-49a2-9638-79871f93a3c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>None</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Peak Response Factor = 1</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Overall RMS Response Factor = 1</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>85</x>
  <y>142</y>
  <width>100</width>
  <height>30</height>
  <uuid>{ce8e6e3a-e84e-4ef0-9084-00ec44afb9ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Scaling Mode</label>
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
  <x>8</x>
  <y>214</y>
  <width>160</width>
  <height>30</height>
  <uuid>{84df1cbe-b2a7-4a3c-bb4c-91bd48efb2ea}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Output_Gain</objectName>
  <x>8</x>
  <y>197</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f4302743-9d62-480e-823e-48caef584b70}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.99000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Output_Gain</objectName>
  <x>448</x>
  <y>214</y>
  <width>60</width>
  <height>30</height>
  <uuid>{64e46c55-ba7a-4cc6-9b81-55365860a8f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.990</label>
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
  <x>8</x>
  <y>101</y>
  <width>180</width>
  <height>30</height>
  <uuid>{027163fb-bbfe-488e-9351-1c1cd9a9d626}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bandwidth</label>
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
  <objectName>Separation_Mode</objectName>
  <x>353</x>
  <y>247</y>
  <width>120</width>
  <height>30</height>
  <uuid>{edca663b-aea2-4040-a052-1423ca8e65f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>octaves</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>hertz</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>233</x>
  <y>247</y>
  <width>120</width>
  <height>30</height>
  <uuid>{085c151c-ba9a-438e-9df9-6dcdd371e566}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Separation Mode</label>
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
  <objectName>Number_Filters</objectName>
  <x>163</x>
  <y>247</y>
  <width>50</width>
  <height>28</height>
  <uuid>{4d8bed66-a9e2-4f11-8986-61bdee1b18aa}</uuid>
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
  <maximum>80</maximum>
  <randomizable group="0">false</randomizable>
  <value>10</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>44</x>
  <y>247</y>
  <width>120</width>
  <height>30</height>
  <uuid>{5f394325-ca74-40c3-8169-7b02bcf8c0a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number of Filters</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Separation_Value</objectName>
  <x>448</x>
  <y>317</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0e422740-2e35-443f-8155-a638a91368a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2.728</label>
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
  <objectName>Separation</objectName>
  <x>8</x>
  <y>300</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f50b9c64-0279-4a4a-8493-5a5b19c7d087}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-11.00000000</minimum>
  <maximum>11.00000000</maximum>
  <value>2.72800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>317</y>
  <width>160</width>
  <height>30</height>
  <uuid>{49c5b0ff-6255-4fcd-8858-dbc13373e145}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Separation (octaves)</label>
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

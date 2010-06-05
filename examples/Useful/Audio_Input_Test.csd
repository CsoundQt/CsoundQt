<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

/*****INPUT TEST*****/
;example for qutecsound
;written by joachim heintz
;jan 2009

sr = 44100
ksmps = 128
nchnls = 2 ; change here if your input device has more channels
0dbfs = 1

	opcode	ShowLED_a, 0, Sakik
;Shows an audio signal in an outvalue channel.
;You can choose to show the value in dB or in raw amplitudes.
;
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;idb: 1 = show in dB, 0 = show in raw amplitudes (both in the range 0-1)
;idbrange: if idb=1: how many db-steps are shown (e.g. if 36 you will not see anything from a signal below -36 dB)

Soutchan, asig, ktrig, idb, kdbrange	xin
kdispval	max_k	asig, ktrig, 1
	if idb != 0 then
kdb 		= 		dbfsamp(kdispval)
kval 		= 		(kdbrange + kdb) / kdbrange
	else
kval		=		kdispval
	endif
	if ktrig == 1 then
			outvalue	Soutchan, kval
	endif
	endop

	opcode	ShowValue_a, 0, Sak
;Shows an audio signal in an outvalue channel.
;You can choose to show the value in dB or in raw amplitudes.
;
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)

Soutchan, asig, ktrig	xin
krms rms asig, 0.07
asig upsamp krms
kdispval	max_k	asig, ktrig, 1
kdb 		= 		dbfsamp(kdispval)
	if ktrig == 1 then
		Stext sprintfk "%.1f", kdb
		outvalue Soutchan, Stext
	endif
	endop

	opcode ShowOver_a, 0, Sakk
;Shows if the incoming audio signal was more than 1 and stays there for some time
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;khold: time in seconds to "hold the red light"

Soutchan, asig, ktrig, khold	xin
kon		init		0
ktim		times
kstart		init		0
kend		init		0
khold		=		(khold < .01 ? .01 : khold); avoiding too short hold times
kmax		max_k		asig, ktrig, 1
	if kon == 0 && kmax > 1 && ktrig == 1 then
kstart		=		ktim
kend		=		kstart + khold
		outvalue	Soutchan, kmax
kon		=		1
	endif
	if kon == 1 && ktim > kend && ktrig == 1 then
		outvalue	Soutchan, 0
kon		=		0
	endif
	endop


instr 1

kdbrange invalue "dbrange"  ;dB range for the meters
kpeakhold invalue "peakhold"  ;Duration of clip indicator hold in seconds

;input channels
a1		inch		1
a2		inch		2
a3		inch		3
a4		inch		4
a5		inch		5
a6		inch		6
a7		inch		7
a8		inch		8
a9		inch		9
a10		inch		10
a11		inch		11
a12		inch		12
a13		inch		13
a14		inch		14
a15		inch		15
a16		inch		16
a17		inch		17
a18		inch		18
a19		inch		19
a20		inch		20
a21		inch		21
a22		inch		22
a23		inch		23
a24		inch		24
;GUI
kTrigDisp	metro		10; refresh rate of display
		ShowLED_a	"in1", a1, kTrigDisp, 1, kdbrange
		ShowLED_a	"in2", a2, kTrigDisp, 1, kdbrange
		ShowLED_a	"in3", a3, kTrigDisp, 1, kdbrange
		ShowLED_a	"in4", a4, kTrigDisp, 1, kdbrange
		ShowLED_a	"in5", a5, kTrigDisp, 1, kdbrange
		ShowLED_a	"in6", a6, kTrigDisp, 1, kdbrange
		ShowLED_a	"in7", a7, kTrigDisp, 1, kdbrange
		ShowLED_a	"in8", a8, kTrigDisp, 1, kdbrange
		ShowLED_a	"in9", a9, kTrigDisp, 1, kdbrange
		ShowLED_a	"in10", a10, kTrigDisp, 1, kdbrange
		ShowLED_a	"in11", a11, kTrigDisp, 1, kdbrange
		ShowLED_a	"in12", a12, kTrigDisp, 1, kdbrange
		ShowLED_a	"in13", a13, kTrigDisp, 1, kdbrange
		ShowLED_a	"in14", a14, kTrigDisp, 1, kdbrange
		ShowLED_a	"in15", a15, kTrigDisp, 1, kdbrange
		ShowLED_a	"in16", a16, kTrigDisp, 1, kdbrange
		ShowLED_a	"in17", a17, kTrigDisp, 1, kdbrange
		ShowLED_a	"in18", a18, kTrigDisp, 1, kdbrange
		ShowLED_a	"in19", a19, kTrigDisp, 1, kdbrange
		ShowLED_a	"in20", a20, kTrigDisp, 1, kdbrange
		ShowLED_a	"in21", a21, kTrigDisp, 1, kdbrange
		ShowLED_a	"in22", a22, kTrigDisp, 1, kdbrange
		ShowLED_a	"in23", a23, kTrigDisp, 1, kdbrange
		ShowLED_a	"in24", a24, kTrigDisp, 1, kdbrange
		ShowValue_a	"db1", a1, kTrigDisp
		ShowValue_a	"db2", a2, kTrigDisp
		ShowValue_a	"db3", a3, kTrigDisp
		ShowValue_a	"db4", a4, kTrigDisp
		ShowValue_a	"db5", a5, kTrigDisp
		ShowValue_a	"db6", a6, kTrigDisp
		ShowValue_a	"db7", a7, kTrigDisp
		ShowValue_a	"db8", a8, kTrigDisp
		ShowValue_a	"db9", a9, kTrigDisp
		ShowValue_a	"db10", a10, kTrigDisp
		ShowValue_a	"db11", a11, kTrigDisp
		ShowValue_a	"db12", a12, kTrigDisp
		ShowValue_a	"db13", a13, kTrigDisp
		ShowValue_a	"db14", a14, kTrigDisp
		ShowValue_a	"db15", a15, kTrigDisp
		ShowValue_a	"db16", a16, kTrigDisp
		ShowValue_a	"db17", a17, kTrigDisp
		ShowValue_a	"db18", a18, kTrigDisp
		ShowValue_a	"db19", a19, kTrigDisp
		ShowValue_a	"db20", a20, kTrigDisp
		ShowValue_a	"db21", a21, kTrigDisp
		ShowValue_a	"db22", a22, kTrigDisp
		ShowValue_a	"db23", a23, kTrigDisp
		ShowValue_a	"db24", a24, kTrigDisp
		ShowOver_a	"in1over", a1, kTrigDisp, kpeakhold
		ShowOver_a	"in2over", a2, kTrigDisp, kpeakhold
		ShowOver_a	"in3over", a3, kTrigDisp, kpeakhold
		ShowOver_a	"in4over", a4, kTrigDisp, kpeakhold
		ShowOver_a	"in5over", a5, kTrigDisp, kpeakhold
		ShowOver_a	"in6over", a6, kTrigDisp, kpeakhold
		ShowOver_a	"in7over", a7, kTrigDisp, kpeakhold
		ShowOver_a	"in8over", a8, kTrigDisp, kpeakhold
		ShowOver_a	"in9over", a9, kTrigDisp, kpeakhold
		ShowOver_a	"in10over", a10, kTrigDisp, kpeakhold
		ShowOver_a	"in11over", a11, kTrigDisp, kpeakhold
		ShowOver_a	"in12over", a12, kTrigDisp, kpeakhold
		ShowOver_a	"in13over", a13, kTrigDisp, kpeakhold
		ShowOver_a	"in14over", a14, kTrigDisp, kpeakhold
		ShowOver_a	"in15over", a15, kTrigDisp, kpeakhold
		ShowOver_a	"in16over", a16, kTrigDisp, kpeakhold
		ShowOver_a	"in17over", a17, kTrigDisp, kpeakhold
		ShowOver_a	"in18over", a18, kTrigDisp, kpeakhold
		ShowOver_a	"in19over", a19, kTrigDisp, kpeakhold
		ShowOver_a	"in20over", a20, kTrigDisp, kpeakhold
		ShowOver_a	"in21over", a21, kTrigDisp, kpeakhold
		ShowOver_a	"in22over", a22, kTrigDisp, kpeakhold
		ShowOver_a	"in23over", a23, kTrigDisp, kpeakhold
		ShowOver_a	"in24over", a24, kTrigDisp, kpeakhold
endin
</CsInstruments>
<CsScore>
i 1 0 3660
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>352</x>
 <y>175</y>
 <width>591</width>
 <height>612</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>359</y>
  <width>543</width>
  <height>58</height>
  <uuid>{e827ab0d-6f6b-416e-93a5-5671105847e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This file tests whether your inputs are working. Please adjust it at the following places to your needs:</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>147</x>
  <y>-1</y>
  <width>299</width>
  <height>44</height>
  <uuid>{63b531ec-f575-4bc2-a2f7-7c84e640aae4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>INPUT TESTER</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>26</fontsize>
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
  <x>14</x>
  <y>417</y>
  <width>546</width>
  <height>56</height>
  <uuid>{0054fba7-f236-436e-8963-a8cb42fe48f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1. Change the nchnls (number of channels) parameter in the orchestra header to the value you wish and your output device can.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>474</y>
  <width>546</width>
  <height>59</height>
  <uuid>{07c73fd7-6c11-4aad-a117-f74ce7eba95e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2. Make sure you are using the appropriate device by selecting it on the Configure dialog</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>13</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{938ab04a-f691-44c4-b0d6-42fa15bcc945}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.07594776</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>13</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{df43a983-2047-4c7c-bedf-4ca691c4eed1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>35</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{4af2b75b-e36c-4d23-895b-5c0080282473}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>0.07594776</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>35</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{2e8c4e91-d8af-4e4d-9a56-2190e401f78b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in2over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>57</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{bb479c4e-0a9b-461c-b71a-92b2554238df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>57</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{03900327-5fcf-49db-8498-695ffdfbd398}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in3over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>79</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{874da1bd-5dff-42e3-8ea3-fbe785c45b0e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>79</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{aabc58a6-ad28-4868-84e6-4b064b02ae7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in4over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>101</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{b37ece90-1af4-4be2-8c1d-0634ec21c8e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in5</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>101</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{56d95a8b-7fa5-499e-aeef-eaa7191f53e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in5over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>123</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{3b232963-4d08-472f-b0b3-039a8d41c06c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>123</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{590bfc8e-7f1f-4dfb-9602-d4a563c30374}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in6over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>145</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{213ef6f9-9ef2-4d41-a679-0b114b76eb95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in7</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>145</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{dc76973b-8a55-449e-b4be-347fdc6dc018}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in7over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>167</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{41874088-48c6-4d0f-b018-abaf4b506311}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
  <yValue>-inf</yValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>167</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{5b9aef62-52b5-4027-89ef-6ca5652441cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in8over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>200</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{a2fdf869-44c3-493f-97a4-f168653e109f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out9</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>200</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{3966692e-ea15-4212-be40-99a19ef4beb7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out9over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>222</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{3e6c7e02-d1db-4938-ba01-959b1a4f3e11}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out10</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>222</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{ce3daf9e-38e8-41c7-8538-c07bc31d91d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out10over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>244</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{add43f3a-6e7a-4e93-a9d6-f2d4dac83ada}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out11</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>244</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{98ce6154-ab6c-490d-a616-d0e475e5a5bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out11over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>266</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{372b91e6-0afd-4d84-9382-3022b5f8d1bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out12</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>266</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{318dd67c-53f1-43c0-b27e-e874023e98ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out12over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>288</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{4dd522c3-d724-4136-8f5c-b99b7fad4b5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out13</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>288</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{86f6d139-00f9-43ba-8782-2a2818d0c4d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out13over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>310</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{68f5e23d-5bc5-43da-95af-cb10aa625270}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out14</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>310</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{eebca19f-1a12-432a-b1da-36b620358881}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out14over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>332</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{493ed577-dbb0-4af8-9512-bb003f17ad95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out15</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>332</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{010542a0-c5cd-4fb1-8fac-0bfb7d5ca01b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out15over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>354</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{0c611701-8190-46d1-b941-94c53756ee58}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out16</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>354</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{a4703e1d-b986-422c-8e53-6418d6bc1373}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out16over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>388</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{003a4329-b9c9-453d-95f3-8a4a7f0fc67c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out17</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>388</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{9fffa10e-23d7-49b8-91a9-cc8a812d5e1e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out17over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>410</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{978a4bef-60d8-4431-8a2b-10d56d4c0d10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out18</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>410</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{7ea8c868-5c0c-4976-aa9f-06b98a51486b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out18over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>432</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{a58689b0-d57d-4cb0-9462-b52c774fe511}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out19</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>432</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{5a3d56c2-e210-44b2-93e1-2c411b1ee9ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out19over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>454</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{b5b5958f-3ba8-401b-b4c2-aea29553718b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out20</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>454</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{23cd866d-36bf-4855-9b7d-8a8fa2c86eb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out20over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>476</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{b5745bf5-b764-476e-92ee-81cf83dbc378}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out21</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>476</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{d521ae37-ca57-48a8-bbe7-23584a1636e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out21over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>498</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{3188bf86-de2a-4c98-aed5-9f5510295ae3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out22</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>498</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{6ce84026-4da8-45ea-98ba-df6586a8a81d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out22over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>520</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{289de6d1-1cc1-4ccf-9196-ede93c4e44b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out23</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>520</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{a450211d-0498-4fb5-85aa-1f2f4d5cff8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out23over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>542</x>
  <y>87</y>
  <width>20</width>
  <height>169</height>
  <uuid>{ce42b036-09b9-456e-8576-dbc22089f4d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out24</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.45000000</xValue>
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
 <bsbObject version="2" type="BSBController">
  <objectName>DelayMute</objectName>
  <x>542</x>
  <y>69</y>
  <width>20</width>
  <height>20</height>
  <uuid>{77cb9363-6da0-488e-b15a-46ed65702380}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out24over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.60000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>49</y>
  <width>25</width>
  <height>23</height>
  <uuid>{ef0cd9d0-65e2-451a-8882-3f0c23208eda}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>32</x>
  <y>49</y>
  <width>25</width>
  <height>23</height>
  <uuid>{24dbc461-0c8f-46b6-8c61-50a5a9a4ed96}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>55</x>
  <y>49</y>
  <width>25</width>
  <height>23</height>
  <uuid>{a5bedd3d-120a-4f44-aa7b-bf3c4202513b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>77</x>
  <y>49</y>
  <width>25</width>
  <height>23</height>
  <uuid>{28576e95-8f83-4934-bc07-20739020c38c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>99</x>
  <y>49</y>
  <width>25</width>
  <height>23</height>
  <uuid>{2e4ee2b4-8fa5-44cc-85ce-60bbd84e390f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>5</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>121</x>
  <y>49</y>
  <width>25</width>
  <height>23</height>
  <uuid>{1ab11fa8-2110-450a-b4e0-127200912fc0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>6</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>143</x>
  <y>49</y>
  <width>25</width>
  <height>23</height>
  <uuid>{094114ed-f819-431d-a814-91ac88addd3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>7</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>165</x>
  <y>49</y>
  <width>25</width>
  <height>23</height>
  <uuid>{5498615d-e69a-423e-861f-7813cc0458c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>8</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>194</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{da3b9fe9-1fb0-40a9-a408-1e156f5c6168}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>9</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>217</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{2e765f56-3809-43f9-93cd-661c92cd00bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>10</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>240</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{0e4548c9-1901-47da-9c07-01252dcb0927}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>11</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>263</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{c3ca5e66-f297-49f1-89f1-6f1dba9a9d8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>12</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>285</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{c35e83f8-81b1-47b8-9dda-d5145fbb147d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>13</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>307</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{b4feb515-9232-44c8-8a64-ef1801fe0c30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>14</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>329</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{36d85d53-e889-4349-b510-6e04a5c3554f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>15</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>351</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{086f056d-db24-4875-92d1-b586ca7f6d61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>16</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>384</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{c392e613-cbf6-4fc1-a23c-67a2c9cbf871}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>17</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>406</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{14b58e85-ad8e-49ed-84c7-4f915b5b3072}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>18</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>428</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{272e1f26-6cfd-40db-992d-00d819a81c97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>19</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>450</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{3a725634-e1a1-4e06-8a35-dd4ad14565c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>20</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>472</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{beaac2a1-c4bd-48bf-930e-5fc8cc0b53c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>21</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>494</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{08d4a1e7-dd79-48a3-867e-b67b3deead79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>22</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{304b6c13-2ef2-4956-863a-d9bc431c1e45}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>23</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>538</x>
  <y>49</y>
  <width>29</width>
  <height>23</height>
  <uuid>{4169fd2b-b291-4bf9-941b-0643bb4db99b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>24</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>dbrange</objectName>
  <x>183</x>
  <y>326</y>
  <width>62</width>
  <height>29</height>
  <uuid>{36eef67d-17c0-4db9-9d19-a98e72ceaf72}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
  <resolution>0.10000000</resolution>
  <minimum>0</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>60</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>85</x>
  <y>326</y>
  <width>93</width>
  <height>30</height>
  <uuid>{88dece71-3aab-478c-9347-55684c2d86be}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>dB Range</label>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>peakhold</objectName>
  <x>425</x>
  <y>327</y>
  <width>51</width>
  <height>29</height>
  <uuid>{c96d5f20-b90b-4e74-bcab-317ac5a426f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
  <maximum>10</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>317</x>
  <y>327</y>
  <width>104</width>
  <height>29</height>
  <uuid>{bc556111-6c70-4b47-bd85-b44fae5decf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Peak Hold time</label>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db1</objectName>
  <x>2</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{904a3a8b-37a4-46f8-bcbf-3ffda9e183e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-26.2</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db2</objectName>
  <x>25</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{e11afe51-36b9-46ab-98cb-ab10c6257b49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-26.2</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db3</objectName>
  <x>48</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{c21a121c-c427-40d0-ad19-2808e3a9833c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db4</objectName>
  <x>71</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{c86cbfc0-3c0a-42eb-b297-3d55a648bf0e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db5</objectName>
  <x>93</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{e68ea98b-f8d5-4e9a-8c2d-cc2ee2d2d8a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db6</objectName>
  <x>115</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{66787810-85a9-4f8b-9c09-ab8fc99466d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db7</objectName>
  <x>137</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{f39ffc11-438e-4b2b-9ef9-b3a7aa3677ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db8</objectName>
  <x>159</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{584c1479-978c-4f5a-b930-1d3f3aaa23ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db9</objectName>
  <x>191</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{fa62add0-677f-4f0a-9a65-7d1953fa0595}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db10</objectName>
  <x>214</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{142a0f41-0e55-42c7-8d16-8870dfeb3fee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db11</objectName>
  <x>237</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{8519c290-8c8e-4dc9-b720-d2d3b3170a56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db12</objectName>
  <x>260</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{65ac8a14-88fc-4c4c-b28e-7fbd4c8b60c8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db13</objectName>
  <x>282</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{72f58f3c-17b3-4f1c-be95-8d9b5f41ce88}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db14</objectName>
  <x>304</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{c863ea10-de35-4064-a82e-26f1de88e6e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db15</objectName>
  <x>326</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{47d1758a-381d-4f9a-99d0-e04db29efc7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db16</objectName>
  <x>348</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{5027b63c-0218-42b1-aa3e-6299dd4c9ffb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db17</objectName>
  <x>379</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{cee50746-719a-472a-b114-3e1891445f95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db18</objectName>
  <x>402</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{0fabba3f-9ddd-4009-a3d8-97d20b612628}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db19</objectName>
  <x>425</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{64ed6d18-8ecb-4fab-8d7d-a21ae94c96cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db20</objectName>
  <x>448</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{e76433c2-0240-4d0d-b25c-5370a7bc910d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db21</objectName>
  <x>470</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{59f78099-184d-4f8b-8c3a-73e43c3fd47a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db22</objectName>
  <x>492</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{23073f07-b709-4027-a8ab-121c543ddee0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db23</objectName>
  <x>514</x>
  <y>261</y>
  <width>39</width>
  <height>22</height>
  <uuid>{557253fd-a977-4f2a-887f-28ccb6738fc2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db24</objectName>
  <x>536</x>
  <y>285</y>
  <width>39</width>
  <height>22</height>
  <uuid>{a5b5efaa-a56f-437a-9a4d-c3bb29b063e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-inf</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
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
  <x>14</x>
  <y>535</y>
  <width>546</width>
  <height>59</height>
  <uuid>{e89c7c22-d239-4277-9711-933f89fea435}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The white boxes show smoothed RMS values in dB FS.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <objectName/>
 <x>352</x>
 <y>175</y>
 <width>591</width>
 <height>612</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 352 175 591 612
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {14, 359} {543, 58} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This file tests whether your inputs are working. Please adjust it at the following places to your needs:
ioText {147, -1} {299, 44} label 0.000000 0.00100 "" center "Lucida Grande" 26 {0, 0, 0} {65280, 65280, 65280} nobackground noborder INPUT TESTER
ioText {14, 417} {546, 56} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1. Change the nchnls (number of channels) parameter in the orchestra header to the value you wish and your output device can.
ioText {14, 474} {546, 59} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2. Make sure you are using the appropriate device by selecting it on the Configure dialog
ioMeter {13, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in1" 0.075948 fill 1 0 mouse
ioMeter {13, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in1over" 0.000000 fill 1 0 mouse
ioMeter {35, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in2" 0.075948 fill 1 0 mouse
ioMeter {35, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in2over" 0.000000 fill 1 0 mouse
ioMeter {57, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in3" -inf fill 1 0 mouse
ioMeter {57, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in3over" 0.000000 fill 1 0 mouse
ioMeter {79, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in4" -inf fill 1 0 mouse
ioMeter {79, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in4over" 0.000000 fill 1 0 mouse
ioMeter {101, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in5" -inf fill 1 0 mouse
ioMeter {101, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in5over" 0.000000 fill 1 0 mouse
ioMeter {123, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in6" -inf fill 1 0 mouse
ioMeter {123, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in6over" 0.000000 fill 1 0 mouse
ioMeter {145, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in7" -inf fill 1 0 mouse
ioMeter {145, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in7over" 0.000000 fill 1 0 mouse
ioMeter {167, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "in8" -inf fill 1 0 mouse
ioMeter {167, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "in8over" 0.000000 fill 1 0 mouse
ioMeter {200, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out9" 0.000000 fill 1 0 mouse
ioMeter {200, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out9over" 0.000000 fill 1 0 mouse
ioMeter {222, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out10" 0.000000 fill 1 0 mouse
ioMeter {222, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out10over" 0.000000 fill 1 0 mouse
ioMeter {244, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out11" 0.000000 fill 1 0 mouse
ioMeter {244, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out11over" 0.000000 fill 1 0 mouse
ioMeter {266, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out12" 0.000000 fill 1 0 mouse
ioMeter {266, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out12over" 0.000000 fill 1 0 mouse
ioMeter {288, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out13" 0.000000 fill 1 0 mouse
ioMeter {288, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out13over" 0.000000 fill 1 0 mouse
ioMeter {310, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out14" 0.000000 fill 1 0 mouse
ioMeter {310, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out14over" 0.000000 fill 1 0 mouse
ioMeter {332, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out15" 0.000000 fill 1 0 mouse
ioMeter {332, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out15over" 0.000000 fill 1 0 mouse
ioMeter {354, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out16" 0.000000 fill 1 0 mouse
ioMeter {354, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out16over" 0.000000 fill 1 0 mouse
ioMeter {388, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out17" 0.000000 fill 1 0 mouse
ioMeter {388, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out17over" 0.000000 fill 1 0 mouse
ioMeter {410, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out18" 0.000000 fill 1 0 mouse
ioMeter {410, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out18over" 0.000000 fill 1 0 mouse
ioMeter {432, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out19" 0.000000 fill 1 0 mouse
ioMeter {432, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out19over" 0.000000 fill 1 0 mouse
ioMeter {454, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out20" 0.000000 fill 1 0 mouse
ioMeter {454, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out20over" 0.000000 fill 1 0 mouse
ioMeter {476, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out21" 0.000000 fill 1 0 mouse
ioMeter {476, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out21over" 0.000000 fill 1 0 mouse
ioMeter {498, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out22" 0.000000 fill 1 0 mouse
ioMeter {498, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out22over" 0.000000 fill 1 0 mouse
ioMeter {520, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out23" 0.000000 fill 1 0 mouse
ioMeter {520, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out23over" 0.000000 fill 1 0 mouse
ioMeter {542, 87} {20, 169} {0, 59904, 0} "hor8" 0.450000 "out24" 0.000000 fill 1 0 mouse
ioMeter {542, 69} {20, 20} {50176, 3584, 3072} "DelayMute" 0.600000 "out24over" 0.000000 fill 1 0 mouse
ioText {9, 49} {25, 23} label 1.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1
ioText {32, 49} {25, 23} label 2.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2
ioText {55, 49} {25, 23} label 3.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3
ioText {77, 49} {25, 23} label 4.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4
ioText {99, 49} {25, 23} label 5.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 5
ioText {121, 49} {25, 23} label 6.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 6
ioText {143, 49} {25, 23} label 7.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 7
ioText {165, 49} {25, 23} label 8.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 8
ioText {194, 49} {29, 23} label 9.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 9
ioText {217, 49} {29, 23} label 10.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 10
ioText {240, 49} {29, 23} label 11.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 11
ioText {263, 49} {29, 23} label 12.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 12
ioText {285, 49} {29, 23} label 13.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 13
ioText {307, 49} {29, 23} label 14.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 14
ioText {329, 49} {29, 23} label 15.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 15
ioText {351, 49} {29, 23} label 16.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 16
ioText {384, 49} {29, 23} label 17.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 17
ioText {406, 49} {29, 23} label 18.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 18
ioText {428, 49} {29, 23} label 19.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 19
ioText {450, 49} {29, 23} label 20.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 20
ioText {472, 49} {29, 23} label 21.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 21
ioText {494, 49} {29, 23} label 22.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 22
ioText {516, 49} {29, 23} label 23.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 23
ioText {538, 49} {29, 23} label 24.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 24
ioText {183, 326} {62, 29} editnum 60.000000 0.100000 "dbrange" left "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 60.000000
ioText {85, 326} {93, 30} label 0.000000 0.00100 "" left "DejaVu Sans" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB Range
ioText {425, 327} {51, 29} editnum 2.000000 1.000000 "peakhold" left "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioText {317, 327} {104, 29} label 0.000000 0.00100 "" left "DejaVu Sans" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Peak Hold time
ioText {2, 261} {39, 22} display -26.200000 0.00100 "db1" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -26.2
ioText {25, 285} {39, 22} display -26.200000 0.00100 "db2" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -26.2
ioText {48, 261} {39, 22} display -inf 0.00100 "db3" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {71, 285} {39, 22} display -inf 0.00100 "db4" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {93, 261} {39, 22} display -inf 0.00100 "db5" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {115, 285} {39, 22} display -inf 0.00100 "db6" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {137, 261} {39, 22} display -inf 0.00100 "db7" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {159, 285} {39, 22} display -inf 0.00100 "db8" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {191, 261} {39, 22} display -inf 0.00100 "db9" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {214, 285} {39, 22} display -inf 0.00100 "db10" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {237, 261} {39, 22} display -inf 0.00100 "db11" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {260, 285} {39, 22} display -inf 0.00100 "db12" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {282, 261} {39, 22} display -inf 0.00100 "db13" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {304, 285} {39, 22} display -inf 0.00100 "db14" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {326, 261} {39, 22} display -inf 0.00100 "db15" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {348, 285} {39, 22} display -inf 0.00100 "db16" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {379, 261} {39, 22} display -inf 0.00100 "db17" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {402, 285} {39, 22} display -inf 0.00100 "db18" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {425, 261} {39, 22} display -inf 0.00100 "db19" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {448, 285} {39, 22} display -inf 0.00100 "db20" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {470, 261} {39, 22} display -inf 0.00100 "db21" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {492, 285} {39, 22} display -inf 0.00100 "db22" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {514, 261} {39, 22} display -inf 0.00100 "db23" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {536, 285} {39, 22} display -inf 0.00100 "db24" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -inf
ioText {14, 535} {546, 59} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The white boxes show smoothed RMS values in dB FS.
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="392" y="275" width="612" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

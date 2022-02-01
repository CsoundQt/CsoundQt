<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

/*****Playing a soundfile 2b: Play from a buffer with more features*****/
;written by joachim heintz and andres cabrera
;mar 2009

	opcode 	PlayBuf, ak, iiikiki
/*Plays a buffer (function table) with a known length,
and gives the time in the range 0-1.*/
/*input:
ifn: name or nummer of the function table
ifnlen: its length in samples resp. indices
ifnsr: its samplerate
kspeed: speed of reading (1 = normal)
iskip: skiptime in seconds
kvol: volume multiplier (1 = normal)
icnvrt: 1 = samplerate conversion if the sr of the soundfile is not the same as in the orchestra; 0 = no conversion
*/
/*output:
asig: audio signal reading the table
ktimout: time in the table in seconds
*/
	ifn, ifnlen, ifnsr, kspeed, iskip, kvol, icnvrt	 xin
  if ifnsr != sr then
			setksmps	1; if sr is different, set local ksmps to 1 for best quality
  endif
  if icnvrt == 1 then
irel			=		ifnlen / ifnsr
  else
irel			=		ifnlen / sr
  endif
kcps			=		kspeed / irel
iphs			=		iskip / irel
asig			poscil3 	kvol, kcps, ifn, iphs
ktim			phasor		kcps, iphs
ktimout		=		ktim * irel
  	xout	asig, ktimout
	endop

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



instr 1; always on
gkpaus		init		0; status of the pause button
gkspeed	init		1; speed for reading the buffer
gkconvertsr	invalue	"convertsr"
kdb		invalue	"db"; gain value in dB
gkskip		invalue	"skip"; skiptime in sec
gkloop		invalue	"loop"; value 1 if checked
   ;volume display
gkmult		=		ampdbfs(kdb)
Sdb_disp	sprintfk	"%+.2f dB", kdb
		outvalue	"db_disp", Sdb_disp
endin

instr 2  ;play
Sfile		invalue	"_Browse1"; get the name (look at the example  in Examples->Reserved Channels)
gilen		filelen	Sfile; duration of the file
gichn		filenchnls	Sfile; is the file mono or stereo
gifilesr	filesr		Sfile

   ;reading the data in the buffers (function tables)
giL		ftgen		0, 0, 0, -1, Sfile, 0, 0, 1
gilenbuf	=		ftlen(giL)
  if gichn == 2 then		
giR		ftgen		0, 0, 0, -1, Sfile, 0, 0, 2
  endif

   ;send a message if the sr of the file doesn't match the sr of the orchestra
  if gifilesr != sr then
    if i(gkconvertsr) == 1 then
Swarn		sprintf	"Warning:\nSamplerate of the file is %d, but samplerate of the orchestra is %d. Samplerate will be converted by changing speed of reading.", gifilesr, sr
		outvalue	"message", Swarn
    else
Swarn		sprintf	"Warning:\nSamplerate of the file is %d, but samplerate of the orchestra is %d. Samplerate will not be converted, so you will have changes in tempo and pitch.", gifilesr, sr
		outvalue	"message", Swarn
    endif
  else
Smess		sprintf	"Length = %.3f\nSamplerate = %d\nChannels = %d", gilen, gifilesr, gichn
		outvalue	"message", Smess 
 endif


  if gkpaus == 1 then	;if pause
		event		"i", 4, 0, .1; call the pause instr
  else
		event		"i", 10, 0, 1
  endif
		turnoff
endin

instr 3; stop
turnoff2 1, 0,0
endin

instr 4; pause/resume
  if gkpaus == 0 then
gkspeed	=		0
gkpaus		=		1
  else
gkspeed	=		1
gkpaus		=		0
  endif
		turnoff
endin


instr 10; playing
iloop		=		i(gkloop)
iskip		=		i(gkskip)
icnvrt		=		i(gkconvertsr)

kdbrange	invalue	"dbrange"  ;dB range for the meters
kpeakhold	invalue	"peakhold"  ;Duration of clip indicator hold in seconds

idur		=		(iloop == 1 ? 9999 : gilen - iskip)
p3		=		idur
  if gichn == 1 then
aL, ktimout	PlayBuf		giL, gilenbuf, gifilesr, gkspeed, iskip, gkmult, icnvrt
aR		=			aL		
  else
aL, ktimout	PlayBuf		giL, gilenbuf, gifilesr, gkspeed, iskip, gkmult, icnvrt
aR, knix	PlayBuf		giR, gilenbuf, gifilesr, gkspeed, iskip, gkmult, icnvrt
  endif
   ;show output
kTrigDisp	metro		10
		ShowLED_a	"outL", aL, kTrigDisp, 1, kdbrange
		ShowLED_a	"outR", aR, kTrigDisp, 1, kdbrange
		ShowOver_a	"outLover", aL, kTrigDisp, kpeakhold
		ShowOver_a	"outRover", aR, kTrigDisp, kpeakhold
   ;read and show time
ktimouthor	=		int(ktimout / 3600)
Shor		sprintfk	"%02d", ktimouthor
ktimoutmin	=		int(ktimout / 60)
Smin		sprintfk	"%02d", ktimoutmin
ktimoutsec	=		int(ktimout % 60)
Ssec		sprintfk	"%02d", ktimoutsec
ktimoutms	=		frac(ktimout) * 1000
Sms		sprintfk	"%03d", ktimoutms
		outvalue	"hor", Shor
		outvalue	"min", Smin
		outvalue	"sec", Ssec
		outvalue	"ms", Sms

		outs		aL, aR
endin


</CsInstruments>
<CsScore>
i 1 0 36000; don't listen to music longer than 10 hours
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>483</width>
 <height>539</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>120</r>
  <g>138</g>
  <b>170</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>15</x>
  <y>95</y>
  <width>345</width>
  <height>24</height>
  <uuid>{16aca12d-8e44-4b5c-9e02-6db2c75f57e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>362</x>
  <y>92</y>
  <width>100</width>
  <height>30</height>
  <uuid>{903e3360-4b33-4c1e-8063-1d4c05bb242a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/PassageMono.aiff</stringvalue>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>db</objectName>
  <x>110</x>
  <y>235</y>
  <width>160</width>
  <height>31</height>
  <uuid>{79bc1456-4022-44f7-8e0d-225f5e96526b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-18.00000000</minimum>
  <maximum>18.00000000</maximum>
  <value>-0.45000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db_disp</objectName>
  <x>270</x>
  <y>235</y>
  <width>120</width>
  <height>31</height>
  <uuid>{0150cd3e-fcf9-4433-a8a2-e43791847383}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-0.45 dB</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
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
  <x>13</x>
  <y>138</y>
  <width>78</width>
  <height>26</height>
  <uuid>{a291df2a-9d8b-4a45-ab3d-c4bb52537abb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine>i 2 0 .1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Stop</objectName>
  <x>221</x>
  <y>138</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e3508832-4264-4f71-becd-61be2a132d5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine>i 3 0 .1</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>skip</objectName>
  <x>13</x>
  <y>203</y>
  <width>87</width>
  <height>25</height>
  <uuid>{d6f2a1f3-eb8b-4082-8b03-eca92a7db848}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>115</x>
  <y>137</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0e7e868a-bb71-4ed9-9f5c-8a5168d53620}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Pause</text>
  <image>/</image>
  <eventLine>i 4 0 .1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>loop</objectName>
  <x>141</x>
  <y>200</y>
  <width>20</width>
  <height>20</height>
  <uuid>{18e70fdf-dbab-4cf7-9c33-f7e5db09ad56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>min</objectName>
  <x>331</x>
  <y>296</y>
  <width>37</width>
  <height>30</height>
  <uuid>{427186bf-14a9-4b64-8a19-d22cce59633d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>00</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <objectName>sec</objectName>
  <x>378</x>
  <y>296</y>
  <width>35</width>
  <height>31</height>
  <uuid>{5d54bf1a-4ba9-4a73-8b1c-821429894ba6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>09</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
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
  <x>366</x>
  <y>296</y>
  <width>14</width>
  <height>29</height>
  <uuid>{ad04bd24-c15e-48bd-b79a-aef90a60f8c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <x>11</x>
  <y>172</y>
  <width>88</width>
  <height>30</height>
  <uuid>{0989bcfd-9791-4812-b5c8-9d564434be8d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>skiptime</label>
  <alignment>center</alignment>
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
  <x>120</x>
  <y>174</y>
  <width>59</width>
  <height>30</height>
  <uuid>{8a1f863a-148c-4eea-897d-f8c4ae5bb01f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>loop</label>
  <alignment>center</alignment>
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
  <x>12</x>
  <y>234</y>
  <width>88</width>
  <height>30</height>
  <uuid>{e58f4db9-254f-430c-9d75-6f57d504fbe5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>volume</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <objectName>message</objectName>
  <x>9</x>
  <y>399</y>
  <width>464</width>
  <height>131</height>
  <uuid>{a5c41213-116d-4c3b-b779-b0f2db33cb7b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>197</r>
   <g>197</g>
   <b>197</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>11</x>
  <y>364</y>
  <width>462</width>
  <height>30</height>
  <uuid>{057ac2d1-8533-4178-a423-87cdc6ea13fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Messages</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <objectName>outL</objectName>
  <x>10</x>
  <y>273</y>
  <width>250</width>
  <height>19</height>
  <uuid>{41760197-5e26-4055-8358-c6a1e7d58fa3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out1_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.50617135</xValue>
  <yValue>0.52631600</yValue>
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
  <objectName>outLover</objectName>
  <x>258</x>
  <y>273</y>
  <width>21</width>
  <height>19</height>
  <uuid>{e082e5d1-8e6a-4662-8b3f-2e8cb50814e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>outLover</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
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
  <objectName>outR</objectName>
  <x>10</x>
  <y>300</y>
  <width>250</width>
  <height>19</height>
  <uuid>{9530a3d5-9c8f-4e3f-a369-37d31ce808d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.50617135</xValue>
  <yValue>0.52631600</yValue>
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
  <objectName>outRover</objectName>
  <x>258</x>
  <y>300</y>
  <width>21</width>
  <height>19</height>
  <uuid>{8487174c-0be1-472d-bbd7-3910cb0ee79b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>outRover</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>dbrange</objectName>
  <x>96</x>
  <y>330</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e56c5ecf-8dd6-4ab6-a692-0d0af432ec5e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>48</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>11</x>
  <y>329</y>
  <width>81</width>
  <height>27</height>
  <uuid>{fdb9a176-d48a-47d5-a4f5-8d8206a668f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>dB Range</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
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
  <x>348</x>
  <y>331</y>
  <width>57</width>
  <height>25</height>
  <uuid>{2eec9b56-b85e-4c82-8b51-e852c51d13f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>218</x>
  <y>329</y>
  <width>131</width>
  <height>27</height>
  <uuid>{a2a86f3a-03d7-4069-b13c-aa66c4e1a1f2}</uuid>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>convertsr</objectName>
  <x>216</x>
  <y>201</y>
  <width>20</width>
  <height>20</height>
  <uuid>{9a016013-437a-42fb-bec6-c8b6b26161cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>192</x>
  <y>174</y>
  <width>62</width>
  <height>30</height>
  <uuid>{877b025c-3d7a-4143-b0b2-8bffe7ae7591}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>convert</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>hor</objectName>
  <x>289</x>
  <y>295</y>
  <width>32</width>
  <height>32</height>
  <uuid>{728567e2-f821-4f99-bc41-86d8d09ca29f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>00</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <objectName>ms</objectName>
  <x>424</x>
  <y>297</y>
  <width>44</width>
  <height>30</height>
  <uuid>{bdf71544-8723-4843-aa62-5bd7463479fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>147</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
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
  <x>320</x>
  <y>297</y>
  <width>14</width>
  <height>29</height>
  <uuid>{c5db02d0-f14f-491a-85e3-0ae9a9fb2e17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <x>411</x>
  <y>296</y>
  <width>14</width>
  <height>29</height>
  <uuid>{3be38656-011b-4f94-b4b4-4aaf49e4c2f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <x>286</x>
  <y>268</y>
  <width>39</width>
  <height>29</height>
  <uuid>{1defe710-4b95-4b28-a441-add693fb143b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>hh</label>
  <alignment>center</alignment>
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
  <x>331</x>
  <y>268</y>
  <width>39</width>
  <height>29</height>
  <uuid>{3e752ddf-02ab-4d1e-a8b6-75166f26b6c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>min</label>
  <alignment>center</alignment>
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
  <x>377</x>
  <y>268</y>
  <width>39</width>
  <height>29</height>
  <uuid>{f51e465c-fa73-4ab7-861d-310f7f1cdb90}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>sec</label>
  <alignment>center</alignment>
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
  <x>426</x>
  <y>268</y>
  <width>39</width>
  <height>29</height>
  <uuid>{28af6ecc-132b-43f2-a5df-4bafbc2e9716}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>ms</label>
  <alignment>center</alignment>
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
  <x>256</x>
  <y>173</y>
  <width>218</width>
  <height>54</height>
  <uuid>{b4ded076-4eba-4e14-a816-056de35c4eaa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>(sample rate conversion if the sr of the file doesn't match the sr of the orchestra)</label>
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
  <x>15</x>
  <y>9</y>
  <width>450</width>
  <height>46</height>
  <uuid>{d03f29ef-2f75-435d-922b-27d8b592105d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>SOUNDFILE PLAYER</label>
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
  <y>51</y>
  <width>450</width>
  <height>46</height>
  <uuid>{17681a9f-a482-46f8-8a5e-77ad193c08ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>(playing from a buffer)</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>22</fontsize>
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

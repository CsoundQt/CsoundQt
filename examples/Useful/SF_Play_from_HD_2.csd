<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

/*****Playing a soundfile 2a: Play from the Harddisk with more features*****/
;written by joachim heintz, andres cabrera and victor lazzarini
;mar 2009 / dec 2011

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



instr 1; stop
		turnoff2	4, 0, 0
		turnoff2	10, 0, 0
		outvalue "outL", 0
		outvalue "outR", 0
		outvalue "outLover", 0
		outvalue "outRover", 0
gktimi10k	=		0; reset the clock
gkpaus		=		0; reset pause status
		turnoff
endin


instr 2 ;read file info and play
gSfile		invalue	"_Browse1"; get the name (look at the example in Examples->Reserved Channels)

gilen		filelen	gSfile; duration of the file
gichn		filenchnls	gSfile; is the file mono or stereo
gifilesr		filesr		gSfile
kconvertsr	invalue	"convertsr"
giconvrt	=		i(kconvertsr)
gktimi10k		=		p4; time instr 10 has performed in k-cycles
gkpaus		=		0; status of the pause button
imaxlen	=		36000; maximum length of loop play 

   ;send a message if the sr of the file doesn't match the sr of the orchestra
  if gifilesr != sr then
    if giconvrt == 1 then
Swarn	sprintf	"Warning:\nSamplerate of the file is %d, but samplerate of the orchestra is %d. Samplerate will be converted by changing speed of reading.", gifilesr, sr
		outvalue	"message", Swarn
    else
Swarn	sprintf	"Warning:\nSamplerate of the file is %d, but samplerate of the orchestra is %d. Samplerate will not be converted, so you will have changes in tempo and pitch.", gifilesr, sr
		outvalue	"message", Swarn
    endif
  else
Smess	sprintf	"Length = %.3f\nSamplerate = %d\nChannels = %d", gilen, gifilesr, gichn
		outvalue	"message", Smess 
 endif
		event_i "i", 4, 0, imaxlen
		turnoff
endin

instr 3; pause and resume
  if gkpaus == 0 then
		turnoff2	4, 0, 0
		turnoff2	10, 0, 0
gkpaus		=		1
  else
		turnoff2	10, 0, 0
		event		"i", 2, 0, 1, gktimi10k
gkpaus		=		0
  endif
		turnoff
endin



instr 4
ilen		=		gilen
ilenk		=		ilen * kr; duration of the file in k-cycles
ichn		=		gichn
gkdb		invalue	"db"; gain value in dB
kskip	invalue	"skip"; skiptime in sec
iskip		=		i(kskip)
itimi10k	=		i(gktimi10k) % ilenk; time instr 10 was active in control cycles in respect to the loops
kloop	invalue	"loop"; value 1 if checked
iloop		=		i(kloop)
istart		=		iskip + (itimi10k / kr)

;playing
iplaylen	=		(iloop == 1 ? p3 : ilen)
   
		event_i	"i", 10, 0, iplaylen, istart, ichn, giconvrt

   ;time output
ktimout	=		(gktimi10k / kr + iskip) % ilen; position in the soundfile in seconds
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

   ;turnoff if no loop and end of file is reached
  if iloop == 0 && ktimout > ilen then
		event		"i", 1, 0, .1
		turnoff
  endif
endin


instr 10
iskip	=		p4
ichn		=		p5
iconvrt	=		(p6 == 1 ? 0 : 1)
k1 = 1

kdbrange	invalue	"dbrange"  ;dB range for the meters
kpeakhold	invalue	"peakhold"  ;Duration of clip indicator hold in seconds;
	if ichn == 1 then
aL		diskin2	gSfile, 1, iskip, 1, 0, iconvrt
aR		=		aL
	else
printk2  k1
aL, aR	diskin2	gSfile, 1, iskip, 1, 0, iconvrt
	endif

   ;Volume
kmult		=		ampdbfs(gkdb)
Sdb_disp	sprintfk	"%+.2f dB", gkdb
		outvalue	"db_disp", Sdb_disp
aL		=		aL * kmult
aR		=		aR * kmult

   ;show output
kTrigDisp	metro		10
		ShowLED_a		"outL", aL, kTrigDisp, 1, kdbrange
		ShowLED_a		"outR", aR, kTrigDisp, 1, kdbrange
		ShowOver_a	"outLover", aL, kTrigDisp, kpeakhold
		ShowOver_a	"outRover", aR, kTrigDisp, kpeakhold

		outs		aL, aR
gktimi10k	=		gktimi10k + 1; count the time instr 10 was active
endin

</CsInstruments>
<CsScore>
f 0 36000; don't listen to music longer than 10 hours
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>129</r>
  <g>170</g>
  <b>164</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>19</x>
  <y>113</y>
  <width>351</width>
  <height>23</height>
  <uuid>{e34d9fad-e494-4adc-a38c-41fd0dd4cd22}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/TrommelStereo.aiff</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>378</x>
  <y>111</y>
  <width>100</width>
  <height>30</height>
  <uuid>{f8cc5a8e-5d74-4e6a-b0ef-14b3536bee69}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/TrommelStereo.aiff</stringvalue>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>db</objectName>
  <x>117</x>
  <y>262</y>
  <width>136</width>
  <height>31</height>
  <uuid>{10f84ac4-d6cc-468a-87f8-92cf47247d27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-18.00000000</minimum>
  <maximum>18.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db_disp</objectName>
  <x>258</x>
  <y>262</y>
  <width>98</width>
  <height>31</height>
  <uuid>{d5d4423c-8a1f-45f4-bff6-99b8c93ac27c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>+0.00 dB</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>20</x>
  <y>148</y>
  <width>78</width>
  <height>26</height>
  <uuid>{c0de047a-de03-4e6d-a942-b71b2821460d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine>i 2 0 1 0</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>223</x>
  <y>150</y>
  <width>80</width>
  <height>25</height>
  <uuid>{539bf852-6d92-4e53-a7ce-a478772c8a44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine>i 1 0 .1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>skip</objectName>
  <x>21</x>
  <y>216</y>
  <width>87</width>
  <height>25</height>
  <uuid>{d697a9c4-6c99-4f8a-b884-8d537fc7a24b}</uuid>
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
  <value>1.409</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>122</x>
  <y>149</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ae8f2ca0-5960-4a9b-853d-22682c1c7916}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Pause</text>
  <image>/</image>
  <eventLine>i 3 0 .1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>loop</objectName>
  <x>152</x>
  <y>216</y>
  <width>20</width>
  <height>20</height>
  <uuid>{855b6884-ed0d-41cc-9a8d-0f3c0315c598}</uuid>
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
  <x>344</x>
  <y>348</y>
  <width>37</width>
  <height>30</height>
  <uuid>{e1155724-576d-4aae-8754-ae799eb0c75f}</uuid>
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
  <x>391</x>
  <y>348</y>
  <width>35</width>
  <height>31</height>
  <uuid>{6058c806-9a20-44fa-8bf8-90de2a58b2df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>06</label>
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
  <x>379</x>
  <y>348</y>
  <width>14</width>
  <height>29</height>
  <uuid>{e9e4b8b3-f548-4ced-919a-5f6c720396f2}</uuid>
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
  <x>21</x>
  <y>190</y>
  <width>88</width>
  <height>30</height>
  <uuid>{bd6fb429-6df6-4f5a-8c1c-4f6dc140ba25}</uuid>
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
  <x>130</x>
  <y>192</y>
  <width>59</width>
  <height>30</height>
  <uuid>{7a8c2d5d-63af-4119-a8fe-ef9729ae54d7}</uuid>
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
  <x>22</x>
  <y>261</y>
  <width>88</width>
  <height>30</height>
  <uuid>{aa0fbe1b-dc9c-4327-aea7-150a02671a6c}</uuid>
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
  <x>24</x>
  <y>456</y>
  <width>460</width>
  <height>93</height>
  <uuid>{060268f7-354f-4607-9414-e03dde72fec9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Length = 151.951
Samplerate = 44100
Channels = 2</label>
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
   <r>217</r>
   <g>217</g>
   <b>217</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>25</x>
  <y>422</y>
  <width>460</width>
  <height>35</height>
  <uuid>{6f1c335f-3050-4a5f-9064-b548712251e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Messages</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBController">
  <objectName>outL</objectName>
  <x>24</x>
  <y>328</y>
  <width>250</width>
  <height>19</height>
  <uuid>{e53212e6-26b1-4255-8dd1-29982a5f376d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out1_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.57894700</yValue>
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
  <x>271</x>
  <y>328</y>
  <width>21</width>
  <height>19</height>
  <uuid>{1ac98e63-ff22-42c2-b9b4-211a3387ff55}</uuid>
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
  <x>24</x>
  <y>355</y>
  <width>250</width>
  <height>19</height>
  <uuid>{5cbb1b94-11b9-40e7-9138-067e4f80499c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>1.00000000</yValue>
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
  <x>271</x>
  <y>355</y>
  <width>21</width>
  <height>19</height>
  <uuid>{b7f5355c-78ed-416f-ac68-29ae4c154f8a}</uuid>
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
  <x>109</x>
  <y>390</y>
  <width>80</width>
  <height>25</height>
  <uuid>{6d740e31-aaaf-436a-9453-71580162329e}</uuid>
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
  <x>24</x>
  <y>389</y>
  <width>131</width>
  <height>27</height>
  <uuid>{9fc8a154-0fe8-4fde-bb06-8dba5528d450}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>dB Range</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
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
  <x>357</x>
  <y>390</y>
  <width>57</width>
  <height>25</height>
  <uuid>{b473b128-28a5-4d0d-9b45-72c54f2ed380}</uuid>
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
  <x>235</x>
  <y>389</y>
  <width>131</width>
  <height>27</height>
  <uuid>{a867c3ca-9514-41aa-aa8d-9ff0601663b5}</uuid>
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
  <x>224</x>
  <y>216</y>
  <width>20</width>
  <height>20</height>
  <uuid>{57f660c3-d691-455f-adc2-8dc2b9ad37dc}</uuid>
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
  <x>202</x>
  <y>192</y>
  <width>62</width>
  <height>30</height>
  <uuid>{3c00cb24-4168-42b6-9712-2c3b164a713f}</uuid>
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
  <x>302</x>
  <y>347</y>
  <width>32</width>
  <height>32</height>
  <uuid>{87ddb84f-bf28-4d96-873e-a0c53debc142}</uuid>
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
  <x>437</x>
  <y>349</y>
  <width>44</width>
  <height>30</height>
  <uuid>{8779b080-2fdf-4bbe-bf88-7ae8b8498fa6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>075</label>
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
  <x>333</x>
  <y>349</y>
  <width>14</width>
  <height>29</height>
  <uuid>{9984c1e1-e917-4c01-83ab-2abc74e18727}</uuid>
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
  <x>424</x>
  <y>348</y>
  <width>14</width>
  <height>29</height>
  <uuid>{12212202-7a08-49ad-ab9a-a782c1cc583f}</uuid>
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
  <x>299</x>
  <y>320</y>
  <width>39</width>
  <height>29</height>
  <uuid>{cb2a8386-7d8a-48dc-9054-c28ee0f3f3a2}</uuid>
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
  <x>344</x>
  <y>320</y>
  <width>39</width>
  <height>29</height>
  <uuid>{f0b3453f-2fed-4ad0-9770-5b4f474bb9c0}</uuid>
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
  <x>390</x>
  <y>320</y>
  <width>39</width>
  <height>29</height>
  <uuid>{072b078f-ff66-412c-acf3-e3d3947ef197}</uuid>
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
  <x>439</x>
  <y>320</y>
  <width>39</width>
  <height>29</height>
  <uuid>{f1be4380-79a4-40f9-a994-cef2cee3b3c1}</uuid>
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
  <x>277</x>
  <y>194</y>
  <width>187</width>
  <height>54</height>
  <uuid>{39ddd5a0-7219-4007-b12b-0c8269b25eab}</uuid>
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
  <x>49</x>
  <y>18</y>
  <width>398</width>
  <height>43</height>
  <uuid>{b6052bac-c509-4ba4-bcea-1249daef98d7}</uuid>
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
  <x>48</x>
  <y>60</y>
  <width>398</width>
  <height>43</height>
  <uuid>{45328377-9c80-4d16-b4fa-470ce623a64f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>(playing from the hard disk)</label>
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

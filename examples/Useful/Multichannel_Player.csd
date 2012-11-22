<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

/*****multi channel soundfile player*****/
;example for CsoundQt
;written by joachim heintz
;jul 2010
;please send bug reports and suggestions
;to jh at joachimheintz.de

ga1		init		0
ga2		init		0
ga3		init		0
ga4		init		0
ga5		init		0
ga6		init		0
ga7		init		0
ga8		init		0

  opcode ShowLED_a, 0, Sakkk
;Shows an audio signal in an outvalue channel. You can choose to show the value in dB or in raw amplitudes.
;;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;kdb: 1 = show in dB, 0 = show in raw amplitudes (both in the range 0-1)
;kdbrange: if idb=1: how many db-steps are shown (e.g. if 36 you will not see anything from a signal below -36 dB)
Soutchan, asig, kdispfreq, kdb, kdbrange	xin
kdispval	max_k	asig, kdispfreq, 1
	if kdb != 0 then
kdb 		= 		dbfsamp(kdispval)
kval 		= 		(kdbrange + kdb) / kdbrange
	else
kval		=		kdispval
	endif
			outvalue	Soutchan, kval
  endop


  opcode ShowOver_a, 0, Sakk
;Shows if the incoming audio signal was more than 1 and stays there for some time
;;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;khold: time in seconds to "hold the red light"
Soutchan, asig, kdispfreq, khold	xin
kon		init		0
ktim		times
kstart		init		0
kend		init		0
khold		=		(khold < .01 ? .01 : khold); avoiding too short hold times
kmax		max_k		asig, kdispfreq, 1
	if kon == 0 && kmax > 1 then
kstart		=		ktim
kend		=		kstart + khold
		outvalue	Soutchan, kmax
kon		=		1
	endif
	if kon == 1 && ktim > kend then
		outvalue	Soutchan, 0
kon		=		0
	endif
  endop


instr 1
;;gui input
gSfile		invalue	"_Browse1"
kskip		invalue	"skiptime"
inchnls	filenchnls	gSfile
kdb		invalue	"db"
gkamp		=		ampdb(kdb)
gkloop		invalue	"loop"
gkchn1		invalue	"chn1"
gkchn2		invalue	"chn2"
gkchn3		invalue	"chn3"
gkchn4		invalue	"chn4"
gkchn5		invalue	"chn5"
gkchn6		invalue	"chn6"
gkchn7		invalue	"chn7"
gkchn8		invalue	"chn8"

;;give a message about orc and file nchnls
 if inchnls > nchnls then
Swarn		sprintf	"WARNING! File channels = %d but output channels = %d!\n", inchnls, nchnls
 else	
Swarn		sprintf	"File channels = %d, output channels = %d.\n", inchnls, nchnls
 endif
 
;;call instr 3-8 if file has at least 3 and not more than 8 channels
 if inchnls < 3 then
Swarn		sprintf	"NOT POSSIBLE!\nThe file '%s' has just %d channels!", gSfile, inchnls
             outvalue	"msg", Swarn
             turnoff
 elseif inchnls > 8 then
Swarn		sprintf	"NOT POSSIBLE!\nThe file '%s' has more than 8 (= %d) channels!", gSfile, inchnls
             outvalue	"msg", Swarn
             turnoff
 else
		event_i	"i", inchnls, 0, p3, i(kskip)
		event_i	"i", 9, 0, p3, i(kskip), inchnls
             outvalue	"msg", Swarn
 endif
 
;;give a warning if orc and file sr are not the same
ifilesr	filesr		gSfile
 if ifilesr != sr then
Swarn2		sprintf	"WARNING! File sample rate = %d but orchestra sample rate = %d. If possible, change the sr value in the orchestra header. If not, the samplerate will be converted.", ifilesr, sr
Swarnout	strcat		Swarn, Swarn2
             outvalue	"msg", Swarnout
 endif
 
;;give file length
ilen		filelen	gSfile
Slen		sprintf	"%.02d : %.02d ", ilen/60, ilen%60
		outvalue	"len", Slen
endin

instr 3
a1, a2, a3	diskin2	gSfile, 1, p4, i(gkloop)
ga1		=		a1*gkamp
ga2		=		a2*gkamp
ga3		=		a3*gkamp
outch gkchn1, ga1, gkchn2, ga2, gkchn3, ga3
endin

instr 4
a1, a2, a3, a4 diskin2	gSfile, 1, p4, i(gkloop)
ga1		=		a1*gkamp
ga2		=		a2*gkamp
ga3		=		a3*gkamp
ga4		=		a4*gkamp
outch gkchn1, ga1, gkchn2, ga2, gkchn3, ga3, gkchn4, ga4
endin

instr 5
a1, a2, a3, a4, a5 diskin2 gSfile, 1, p4, i(gkloop)
ga1		=		a1*gkamp
ga2		=		a2*gkamp
ga3		=		a3*gkamp
ga4		=		a4*gkamp
ga5		=		a5*gkamp
outch gkchn1, ga1, gkchn2, ga2, gkchn3, ga3, gkchn4, ga4, gkchn5, ga5
endin

instr 6
a1, a2, a3, a4, a5, a6 diskin2 gSfile, 1, p4, i(gkloop)
ga1		=		a1*gkamp
ga2		=		a2*gkamp
ga3		=		a3*gkamp
ga4		=		a4*gkamp
ga5		=		a5*gkamp
ga6		=		a6*gkamp
outch gkchn1, ga1, gkchn2, ga2, gkchn3, ga3, gkchn4, ga4, gkchn5, ga5, gkchn6, ga6
endin

instr 7
a1, a2, a3, a4, a5, a6, a7 diskin2 gSfile, 1, p4, i(gkloop)
ga1		=		a1*gkamp
ga2		=		a2*gkamp
ga3		=		a3*gkamp
ga4		=		a4*gkamp
ga5		=		a5*gkamp
ga6		=		a6*gkamp
ga7		=		a7*gkamp
outch gkchn1, ga1, gkchn2, ga2, gkchn3, ga3, gkchn4, ga4, gkchn5, ga5, gkchn6, ga6, gkchn7, ga7
endin

instr 8
a1, a2, a3, a4, a5, a6, a7, a8 diskin2 gSfile, 1, p4, i(gkloop)
ga1		=		a1*gkamp
ga2		=		a2*gkamp
ga3		=		a3*gkamp
ga4		=		a4*gkamp
ga5		=		a5*gkamp
ga6		=		a6*gkamp
ga7		=		a7*gkamp
ga8		=		a8*gkamp
outch gkchn1, ga1, gkchn2, ga2, gkchn3, ga3, gkchn4, ga4, gkchn5, ga5, gkchn6, ga6, gkchn7, ga7, gkchn8, ga8
endin

instr 9; collect global audio signals and show them
iskip		=		p4
iplayins	=		p5; number of playing instrument
ktrigdisp	metro		10
idboramp	=		1; 0=raw amps, 1=db
idbrange	=		48
icliphold	=		2
		ShowLED_a	"out1", ga1, ktrigdisp, idboramp, idbrange
		ShowOver_a	"over1", ga1, ktrigdisp, icliphold
		ShowLED_a	"out2", ga2, ktrigdisp, idboramp, idbrange
		ShowOver_a	"over2", ga2, ktrigdisp, icliphold
		ShowLED_a	"out3", ga3, ktrigdisp, idboramp, idbrange
		ShowOver_a	"over3", ga3, ktrigdisp, icliphold
		ShowLED_a	"out4", ga4, ktrigdisp, idboramp, idbrange
		ShowOver_a	"over4", ga4, ktrigdisp, icliphold
		ShowLED_a	"out5", ga5, ktrigdisp, idboramp, idbrange
		ShowOver_a	"over5", ga5, ktrigdisp, icliphold
		ShowLED_a	"out6", ga6, ktrigdisp, idboramp, idbrange
		ShowOver_a	"over6", ga6, ktrigdisp, icliphold
		ShowLED_a	"out7", ga7, ktrigdisp, idboramp, idbrange
		ShowOver_a	"over7", ga7, ktrigdisp, icliphold
		ShowLED_a	"out8", ga8, ktrigdisp, idboramp, idbrange
		ShowOver_a	"over8", ga8, ktrigdisp, icliphold
;;display time
ktim		timeinsts
kplaypos	=		iskip + ktim
kposmin	=		floor(kplaypos/60)
kpossec	=		floor(kplaypos%60)
Smin		sprintfk	"%02d", kposmin
Ssec		sprintfk	"%02d", kpossec
		outvalue	"min", Smin
		outvalue	"sec", Ssec
endin

</CsInstruments>
<CsScore>
i 1 0 36000
e
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>966</x>
 <y>203</y>
 <width>440</width>
 <height>609</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>skiptime</objectName>
  <x>116</x>
  <y>208</y>
  <width>80</width>
  <height>25</height>
  <uuid>{cb3713f7-e95e-4e71-b4a6-3b0c4e9b85cc}</uuid>
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
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>13</x>
  <y>137</y>
  <width>297</width>
  <height>27</height>
  <uuid>{195c15e5-027a-464a-9a32-1b22bd86be73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>207</y>
  <width>114</width>
  <height>30</height>
  <uuid>{fb3305a5-9d5b-4f81-9dec-ace2f3726a5d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Skiptime (sec)</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>309</x>
  <y>135</y>
  <width>100</width>
  <height>30</height>
  <uuid>{560e2167-ad1b-4b82-bc09-cd3212457222}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/Joachim/Csound/Hui/8kanaltest/7chnls.aiff</stringvalue>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>49</x>
  <y>168</y>
  <width>96</width>
  <height>30</height>
  <uuid>{16c03da3-8186-42bd-b16e-2de364934a9e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Stop</objectName>
  <x>265</x>
  <y>168</y>
  <width>100</width>
  <height>30</height>
  <uuid>{4928c1d8-3ab9-457a-ac0a-1c4b08103132}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>8</y>
  <width>403</width>
  <height>67</height>
  <uuid>{2d23372e-361c-47fe-9cdf-0b8967f6782f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>MULTI CHANNEL
SOUNDFILE PLAYER</label>
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
  <x>6</x>
  <y>76</y>
  <width>403</width>
  <height>55</height>
  <uuid>{675dfc88-8d95-4a42-9d12-5a6bc6e41c06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Here you can play 3- to 8-channel (intervleaved) files.
For mono files, see the Mixdown_Player example.</label>
  <alignment>center</alignment>
  <font>Helvetica</font>
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
 <bsbObject version="2" type="BSBController">
  <objectName>over8</objectName>
  <x>260</x>
  <y>395</y>
  <width>25</width>
  <height>25</height>
  <uuid>{85b38a7f-e962-4601-bced-83da2ddb45fd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>over8</objectName2>
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
   <r>155</r>
   <g>3</g>
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
  <objectName>out8</objectName>
  <x>260</x>
  <y>419</y>
  <width>25</width>
  <height>100</height>
  <uuid>{99e658f1-d30b-415a-8a60-528f39dfd1e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-inf</xValue>
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
  <objectName>over7</objectName>
  <x>228</x>
  <y>395</y>
  <width>25</width>
  <height>25</height>
  <uuid>{6d0b2991-eed8-4871-947f-67bc67313855}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>over7</objectName2>
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
   <r>155</r>
   <g>3</g>
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
  <objectName>out7</objectName>
  <x>228</x>
  <y>419</y>
  <width>25</width>
  <height>100</height>
  <uuid>{dc9eba00-b83d-4179-802b-b91532fd134a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out7</objectName2>
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
  <objectName>over6</objectName>
  <x>195</x>
  <y>395</y>
  <width>25</width>
  <height>25</height>
  <uuid>{8714d646-5805-4fc5-848c-00eb7e3dc30e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>over6</objectName2>
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
   <r>155</r>
   <g>3</g>
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
  <objectName>out6</objectName>
  <x>195</x>
  <y>419</y>
  <width>25</width>
  <height>100</height>
  <uuid>{e83b3c5d-c1bc-4d3f-85c5-856165c8bb9d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out6</objectName2>
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
  <objectName>over5</objectName>
  <x>163</x>
  <y>395</y>
  <width>25</width>
  <height>25</height>
  <uuid>{8db2e10f-1624-4d72-b4fe-1778191df70e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>over5</objectName2>
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
   <r>155</r>
   <g>3</g>
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
  <objectName>out5</objectName>
  <x>163</x>
  <y>419</y>
  <width>25</width>
  <height>100</height>
  <uuid>{81470802-54bd-4a6c-be49-daa9a478552d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out5</objectName2>
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
  <objectName>over4</objectName>
  <x>129</x>
  <y>395</y>
  <width>25</width>
  <height>25</height>
  <uuid>{26355726-dad2-44a1-8043-e4620741fd15}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>over4</objectName2>
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
   <r>155</r>
   <g>3</g>
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
  <objectName>out4</objectName>
  <x>129</x>
  <y>419</y>
  <width>25</width>
  <height>100</height>
  <uuid>{9e16567b-0059-4f86-9b4d-300aa5bf2afe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out4</objectName2>
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
  <objectName>over3</objectName>
  <x>97</x>
  <y>395</y>
  <width>25</width>
  <height>25</height>
  <uuid>{48db23f6-2e0d-4d1e-974e-c9487c4c3138}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>over3</objectName2>
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
   <r>155</r>
   <g>3</g>
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
  <objectName>out3</objectName>
  <x>97</x>
  <y>419</y>
  <width>25</width>
  <height>100</height>
  <uuid>{605082ea-44b3-4aed-9dad-b54709f3b8f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out3</objectName2>
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
  <objectName>over2</objectName>
  <x>64</x>
  <y>395</y>
  <width>25</width>
  <height>25</height>
  <uuid>{a8e39457-553c-41c5-bf44-ccf3379bc584}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>over2</objectName2>
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
   <r>155</r>
   <g>3</g>
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
  <objectName>out2</objectName>
  <x>64</x>
  <y>419</y>
  <width>25</width>
  <height>100</height>
  <uuid>{b8737139-8ae2-4743-98db-a80e11912ca3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out2</objectName2>
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
  <objectName>over1</objectName>
  <x>32</x>
  <y>395</y>
  <width>25</width>
  <height>25</height>
  <uuid>{37e14c1d-f864-4d2d-a955-3ef825e77185}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>over1</objectName2>
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
   <r>155</r>
   <g>3</g>
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
  <objectName>out1</objectName>
  <x>32</x>
  <y>419</y>
  <width>25</width>
  <height>100</height>
  <uuid>{496461c8-c3d7-47f7-8492-0468174480e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out1</objectName2>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>db</objectName>
  <x>63</x>
  <y>242</y>
  <width>237</width>
  <height>28</height>
  <uuid>{25d39018-0dcb-4f63-a4b6-519ef8219aa7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db</objectName>
  <x>299</x>
  <y>242</y>
  <width>52</width>
  <height>28</height>
  <uuid>{b91f69a5-a47c-4ea1-9d0f-046e44defbd8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.000</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>349</x>
  <y>242</y>
  <width>47</width>
  <height>27</height>
  <uuid>{940a92e4-9d25-4003-9578-7ca125f0b716}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>dB</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <x>13</x>
  <y>242</y>
  <width>51</width>
  <height>28</height>
  <uuid>{06c607cd-5822-47bb-9ecf-977bebb09709}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Gain</label>
  <alignment>right</alignment>
  <font>Arial</font>
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
  <x>302</x>
  <y>440</y>
  <width>94</width>
  <height>26</height>
  <uuid>{a82a80c2-a91d-4602-b7b9-f7a43bf27c9f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Time</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>min</objectName>
  <x>311</x>
  <y>463</y>
  <width>33</width>
  <height>26</height>
  <uuid>{0e9ebddd-002b-4d81-9f3e-31d8174a9824}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>00</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>sec</objectName>
  <x>357</x>
  <y>463</y>
  <width>33</width>
  <height>26</height>
  <uuid>{a3a1342d-dd5b-419c-8b75-982f9d4c9592}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>00</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>342</x>
  <y>463</y>
  <width>17</width>
  <height>27</height>
  <uuid>{a9d9274f-379f-4db8-86a2-1d04781b8628}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>311</x>
  <y>486</y>
  <width>37</width>
  <height>28</height>
  <uuid>{52f700e3-1b22-4bc9-b53f-f1125ea6f976}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>min</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <x>353</x>
  <y>486</y>
  <width>37</width>
  <height>28</height>
  <uuid>{d7ca2aae-1384-4486-9c52-8c527b828211}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>sec</label>
  <alignment>center</alignment>
  <font>Arial</font>
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
  <x>302</x>
  <y>439</y>
  <width>96</width>
  <height>76</height>
  <uuid>{1bfffffe-61dc-4355-8d70-96591bf074a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>296</x>
  <y>517</y>
  <width>109</width>
  <height>50</height>
  <uuid>{689683d6-a7a4-4c43-9cdc-e64b44632884}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Route Output
Channels</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>chn1</objectName>
  <x>31</x>
  <y>525</y>
  <width>25</width>
  <height>27</height>
  <uuid>{abbccb45-e575-452c-842b-120f8f0b261f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <value>1.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>124.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>chn2</objectName>
  <x>63</x>
  <y>525</y>
  <width>25</width>
  <height>27</height>
  <uuid>{22d246a4-58e1-441b-91de-a0449329f3bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <value>2.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>124.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>chn3</objectName>
  <x>97</x>
  <y>525</y>
  <width>25</width>
  <height>27</height>
  <uuid>{e544b844-d839-4e74-be1c-e6e996ebf55f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <value>3.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>124.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>chn4</objectName>
  <x>129</x>
  <y>525</y>
  <width>25</width>
  <height>27</height>
  <uuid>{69be0b1a-1dbc-407d-a5d7-8ab83723c48e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <value>4.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>124.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>chn5</objectName>
  <x>162</x>
  <y>525</y>
  <width>25</width>
  <height>27</height>
  <uuid>{91ecac0e-e94c-47e4-8d67-387230ecd3db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <value>5.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>124.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>chn6</objectName>
  <x>194</x>
  <y>525</y>
  <width>25</width>
  <height>27</height>
  <uuid>{cc4f58ba-8238-48a6-96d7-ffe701f898e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <value>6.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>124.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>chn7</objectName>
  <x>228</x>
  <y>525</y>
  <width>25</width>
  <height>27</height>
  <uuid>{996f7210-d303-480e-9808-df84a924bcc5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <value>7.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>124.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>chn8</objectName>
  <x>260</x>
  <y>525</y>
  <width>25</width>
  <height>27</height>
  <uuid>{93b32f9d-7f6a-4a97-93c6-b2fd7fc2537e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <value>8.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>124.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>msg</objectName>
  <x>24</x>
  <y>280</y>
  <width>377</width>
  <height>112</height>
  <uuid>{ccdd7f25-f748-4f33-b8ec-a0d555cabe3d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>No messages yet ...</label>
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
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>loop</objectName>
  <x>307</x>
  <y>215</y>
  <width>20</width>
  <height>20</height>
  <uuid>{d062a033-8ed8-4598-9a51-0181c0621710}</uuid>
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
  <x>328</x>
  <y>212</y>
  <width>68</width>
  <height>27</height>
  <uuid>{4830e3ab-8055-4a68-b804-c03657adf9d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Loop</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>len</objectName>
  <x>301</x>
  <y>412</y>
  <width>96</width>
  <height>25</height>
  <uuid>{c6a3c4ee-ce4d-41ef-9236-a53d56328fc8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>301</x>
  <y>390</y>
  <width>97</width>
  <height>27</height>
  <uuid>{a0b3b822-b9e1-48bb-8aa5-e4c4832c813a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File Length</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Pause</objectName>
  <x>157</x>
  <y>168</y>
  <width>100</width>
  <height>30</height>
  <uuid>{f6ece404-0165-4189-9e96-e40c6f8726cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Pause</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 966 203 440 609
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {92, 209} {80, 25} editnum 0.000000 0.001000 "skiptime" left "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000000
ioText {13, 137} {297, 27} edit 0.000000 0.00100 "_Browse1"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 
ioText {2, 206} {92, 30} label 0.000000 0.00100 "" right "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Skiptime (sec)
ioButton {309, 135} {100, 30} value 1.000000 "_Browse1" "Open File" "/" 
ioButton {49, 168} {96, 30} value 1.000000 "_Play" "Play" "/" 
ioButton {265, 168} {100, 30} value 1.000000 "_Stop" "Stop" "/" 
ioText {7, 8} {403, 67} label 0.000000 0.00100 "" center "Lucida Grande" 26 {0, 0, 0} {65280, 65280, 65280} nobackground noborder MULTI CHANNELÂ¬SOUNDFILE PLAYER
ioText {6, 76} {403, 55} label 0.000000 0.00100 "" center "Helvetica" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Here you can play 3- to 8-channel (intervleaved) files.Â¬For mono files, see the Mixdown_Player example.
ioMeter {260, 395} {25, 25} {39680, 768, 0} "over8" 0.000000 "over8" 0.000000 fill 1 0 mouse
ioMeter {260, 419} {25, 100} {0, 59904, 0} "out8" -inf "out8" -inf fill 1 0 mouse
ioMeter {228, 395} {25, 25} {39680, 768, 0} "over7" 0.000000 "over7" 0.000000 fill 1 0 mouse
ioMeter {228, 419} {25, 100} {0, 59904, 0} "out7" 0.000000 "out7" 0.000000 fill 1 0 mouse
ioMeter {195, 395} {25, 25} {39680, 768, 0} "over6" 0.000000 "over6" 0.000000 fill 1 0 mouse
ioMeter {195, 419} {25, 100} {0, 59904, 0} "out6" 0.000000 "out6" 0.000000 fill 1 0 mouse
ioMeter {163, 395} {25, 25} {39680, 768, 0} "over5" 0.000000 "over5" 0.000000 fill 1 0 mouse
ioMeter {163, 419} {25, 100} {0, 59904, 0} "out5" 0.000000 "out5" 0.000000 fill 1 0 mouse
ioMeter {129, 395} {25, 25} {39680, 768, 0} "over4" 0.000000 "over4" 0.000000 fill 1 0 mouse
ioMeter {129, 419} {25, 100} {0, 59904, 0} "out4" 0.000000 "out4" 0.000000 fill 1 0 mouse
ioMeter {97, 395} {25, 25} {39680, 768, 0} "over3" 0.000000 "over3" 0.000000 fill 1 0 mouse
ioMeter {97, 419} {25, 100} {0, 59904, 0} "out3" 0.000000 "out3" 0.000000 fill 1 0 mouse
ioMeter {64, 395} {25, 25} {39680, 768, 0} "over2" 0.000000 "over2" 0.000000 fill 1 0 mouse
ioMeter {64, 419} {25, 100} {0, 59904, 0} "out2" 0.000000 "out2" 0.000000 fill 1 0 mouse
ioMeter {32, 395} {25, 25} {39680, 768, 0} "over1" 0.000000 "over1" 0.000000 fill 1 0 mouse
ioMeter {32, 419} {25, 100} {0, 59904, 0} "out1" 0.000000 "out1" 0.000000 fill 1 0 mouse
ioSlider {63, 242} {237, 28} -12.000000 12.000000 0.000000 db
ioText {299, 242} {52, 28} display 0.000000 0.00100 "db" left "Arial" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000
ioText {349, 242} {47, 27} label 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB
ioText {13, 242} {51, 28} label 0.000000 0.00100 "" right "Arial" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Gain
ioText {302, 440} {94, 26} label 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Time
ioText {311, 463} {33, 26} display 0.000000 0.00100 "min" right "Arial" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 00
ioText {357, 463} {33, 26} display 0.000000 0.00100 "sec" left "Arial" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 00
ioText {342, 463} {17, 27} label 0.000000 0.00100 "" center "Arial" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder :
ioText {311, 486} {37, 28} label 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder min
ioText {353, 486} {37, 28} label 0.000000 0.00100 "" center "Arial" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder sec
ioText {302, 439} {96, 76} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {296, 517} {109, 50} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Route OutputÂ¬Channels
ioText {31, 525} {25, 27} scroll 1.000000 1.000000 "chn1" center "Arial" 14 {0, 0, 0} {65280, 65280, 65280} background noborder 
ioText {63, 525} {25, 27} scroll 2.000000 1.000000 "chn2" center "Arial" 14 {0, 0, 0} {65280, 65280, 65280} background noborder 
ioText {97, 525} {25, 27} scroll 3.000000 1.000000 "chn3" center "Arial" 14 {0, 0, 0} {65280, 65280, 65280} background noborder 
ioText {129, 525} {25, 27} scroll 4.000000 1.000000 "chn4" center "Arial" 14 {0, 0, 0} {65280, 65280, 65280} background noborder 
ioText {162, 525} {25, 27} scroll 5.000000 1.000000 "chn5" center "Arial" 14 {0, 0, 0} {65280, 65280, 65280} background noborder 
ioText {194, 525} {25, 27} scroll 6.000000 1.000000 "chn6" center "Arial" 14 {0, 0, 0} {65280, 65280, 65280} background noborder 
ioText {228, 525} {25, 27} scroll 7.000000 1.000000 "chn7" center "Arial" 14 {0, 0, 0} {65280, 65280, 65280} background noborder 
ioText {260, 525} {25, 27} scroll 8.000000 1.000000 "chn8" center "Arial" 14 {0, 0, 0} {65280, 65280, 65280} background noborder 
ioText {24, 280} {377, 112} display 0.000000 0.00100 "msg" left "Arial" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder No messages yet ...
ioCheckbox {307, 215} {20, 20} off loop
ioText {329, 209} {68, 32} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Loop
ioText {301, 412} {96, 25} display 0.000000 0.00100 "len" center "Arial" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {301, 390} {97, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder File Length
ioButton {157, 168} {100, 30} value 1.000000 "_Pause" "Pause" "/" 
</MacGUI>

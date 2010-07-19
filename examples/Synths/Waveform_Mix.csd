<CsoundSynthesizer>
<CsOptions>
-odac --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>
<CsInstruments>
/*****WAVEFORM MIX*****/
;example for qutecsound
;written by joachim heintz
;feb 2010

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

massign 0, 2; assigns all incoming MIDI to instr 2

  opcode SinesToSSTI, i, pooo
;produces the waveforms saw (iwf=1, which is also the default), square (iwf=2), triangle (3), impulse (4) by the addition of inparts sinusoides (default = 10) and returns the result in a function table of itabsiz length (must be a power-of-2 or a power-of-2 plus 1, the default is 1024 points) with number ifno (default = 0 which means the number is given automatically)
iwf, inparts, itabsiz, ifno xin
inparts	=		(inparts == 0 ? 10 : inparts)
itabsiz	=		(itabsiz == 0 ? 1024 : itabsiz)
iftemp		ftgen		0, 0, -(inparts * 3), -2, 0;temp ftab for writing the str-pna-phas vals
indx		=		1
loop:
if iwf == 1 then ; saw = 1, 1/2, 1/3, ... as strength of partials
		tabw_i		1/indx, (indx-1)*3, iftemp; writes strength of partial
		tabw_i		indx, (indx-1)*3+1, iftemp; writes partial number
elseif iwf == 2 then ; square = 1, 1/3, 1/5, ... for odd partials
		tabw_i		1/(indx*2-1), (indx-1)*3, iftemp; writes strength of partial
		tabw_i		indx*2-1, (indx-1)*3+1, iftemp; writes partial number
elseif iwf == 3 then ; triangle = 1, -1/9, 1/25, -1/49, 1/81, ... for odd partials
ieven		=		indx % 2; 0 = even index, 1 = odd index
istr		=		(ieven == 0 ? -1/(indx*2-1)^2 : 1/(indx*2-1)^2); results in 1, -1/9, 1/25, ...
		tabw_i		istr, (indx-1)*3, iftemp; writes strength of partial
		tabw_i		indx*2-1, (indx-1)*3+1, iftemp; writes partial number
elseif iwf == 4 then ; impulse = 1, 1, 1, ... for all partials
		tabw_i		1, (indx-1)*3, iftemp; writes strength of partial (always 1)
		tabw_i		indx, (indx-1)*3+1, iftemp; writes partial number
endif

		loop_le	indx, 1, inparts, loop

iftout	ftgen		ifno, 0, itabsiz, 34, iftemp, inparts, 1; write table with GEN34 
		ftfree		iftemp, 0; remove iftemp
		xout		iftout
  endop

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


instr 1;;RECEIVE GUI INPUT AN GENERATE WAVEFORMS
iftlen		=		4097; length of a function table with the shape of a waveform
;GENERATE SINE WAVEFORM
giftsin	ftgen		1, 0, iftlen, 10, 1
;RECEIVE NUMBER OF PARTIALS FOR SAW, SQUARE, TRIANGLE AN IMPULSE
knp_saw	invalue	"np_saw"
knp_squ	invalue	"np_squ"
knp_tri	invalue	"np_tri"
knp_imp	invalue	"np_imp"

;LOOK IF AN OF THIS VALUES HAS CHANGED
knewsaw		changed	knp_saw
knewsqu		changed	knp_squ
knewtri		changed	knp_tri
knewimp		changed	knp_imp

;IF YES GO AGAIN TO THE "new" BLOCK AND RECALCULATE THE WAVEFORMS
 if knewsaw == 1 then
		reinit		newsaw
 endif
 if knewsqu == 1 then
		reinit		newsqu
 endif
 if knewtri == 1 then
		reinit		newtri
 endif
 if knewimp == 1 then
		reinit		newimp
 endif
;CALCULATION OF SAW, SQUARE, TRIANGLE AN IMPULSE ACCORDING TO THE DESIRED NUMBER OF PARTIALS
newsaw:
inp_saw	=		i(knp_saw)
giftsaw	SinesToSSTI	1, inp_saw, iftlen, 2
		rireturn

newsqu:
inp_squ	=		i(knp_squ)
giftsqu	SinesToSSTI	2, inp_squ, iftlen, 3
		rireturn

newtri:
inp_tri	=		i(knp_tri)
gifttri	SinesToSSTI	3, inp_tri, iftlen, 4
		rireturn

newimp:
inp_imp	=		i(knp_imp)
giftimp	SinesToSSTI	4, inp_imp, iftlen, 5
		rireturn

;RECEIVE RELATIVE AMPLITUDES, AND MASTER VOLUME FROM THE GUI
gkamp_sin	invalue	"amp_sin"
gkamp_saw	invalue	"amp_saw"
gkamp_squ	invalue	"amp_squ"
gkamp_tri	invalue	"amp_tri"
gkamp_imp	invalue	"amp_imp"
gk_vol		invalue	"vol"; master volume
;SMOOTH AMPLTUDE CHANGES
gkamp_sin	port		gkamp_sin, .1
gkamp_saw	port		gkamp_saw, .1
gkamp_squ	port		gkamp_squ, .1
gkamp_tri	port		gkamp_tri, .1
gkamp_imp	port		gkamp_imp, .1
gk_vol		port		gk_vol, .1
;LET THE GRAPH WIDGET SHOW THE WAVEFORMS (and be happy if it happens)
		outvalue	"sine", -1
		outvalue	"saw", -2
		outvalue	"square", -3
		outvalue	"triangle", -4
		outvalue	"impulse", -5
endin

instr 2;;PLAY ONE NOTE
;GENERATE THE FIVE AUDIO SIGNALS
print p4,p5
asin		oscil3		p5, p4, giftsin
asaw		oscil3		p5, p4, giftsaw
asqu		oscil3		p5, p4, giftsqu
atri		oscil3		p5, p4, gifttri
aimp		oscil3		p5, p4, giftimp
;MIX THEM, APPLY A SIMPLE ENVELOPE AND SEND THE MIX OUT
amix		sum		asin*gkamp_sin, asaw*gkamp_saw, asqu*gkamp_squ, atri*gkamp_tri, aimp*gkamp_imp
kenv		linsegr	0, .1, 1, p3-.1, 1, .1, 0; simple envelope
aenv		=		amix*kenv*gk_vol; apply alo master volume
		outs		aenv, aenv
endin

instr 3; SHOW THE SUM OF ALL SINGLE NOTES TO SEE CLIPPING
aout		monitor
kTrigDisp	metro		10
		ShowLED_a	"out", aout, kTrigDisp, 1, 50
		ShowOver_a	"outover", aout/0dbfs, kTrigDisp, 1
endin

</CsInstruments>
<CsScore>
i 1 0 36000; play 10 hours
i 3 0 36000
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>737</x>
 <y>267</y>
 <width>1134</width>
 <height>629</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>34</x>
  <y>265</y>
  <width>1028</width>
  <height>44</height>
  <uuid>{c78fe040-5e65-420d-b2e9-6a5a1c246a82}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>73</x>
  <y>116</y>
  <width>91</width>
  <height>35</height>
  <uuid>{88e79c48-0673-477d-a115-f7d04204ceed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Sine</label>
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
 <bsbObject version="2" type="BSBGraph">
  <objectName>sine</objectName>
  <x>35</x>
  <y>161</y>
  <width>178</width>
  <height>96</height>
  <uuid>{68005a17-b635-4078-be03-673ffa62bade}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>0</value>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>auto</modex>
  <modey>auto</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>290</x>
  <y>116</y>
  <width>91</width>
  <height>35</height>
  <uuid>{91e8697e-5aaf-48d2-a95f-defaadd72ba2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Saw</label>
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
 <bsbObject version="2" type="BSBGraph">
  <objectName>saw</objectName>
  <x>252</x>
  <y>161</y>
  <width>178</width>
  <height>96</height>
  <uuid>{3140cb8b-1f05-4840-8595-32029e2eca6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>0</value>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>auto</modex>
  <modey>auto</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>509</x>
  <y>115</y>
  <width>91</width>
  <height>35</height>
  <uuid>{56cf2d07-56f6-49fe-abc7-3ce66f6b2a83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Square</label>
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
 <bsbObject version="2" type="BSBGraph">
  <objectName>square</objectName>
  <x>471</x>
  <y>160</y>
  <width>178</width>
  <height>96</height>
  <uuid>{60aff4f8-815b-4521-b4ae-2b319cb36061}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>0</value>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>auto</modex>
  <modey>auto</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>713</x>
  <y>115</y>
  <width>91</width>
  <height>35</height>
  <uuid>{e2f82f20-56ac-44a8-b4cc-45cffd649263}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Triangle</label>
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
 <bsbObject version="2" type="BSBGraph">
  <objectName>triangle</objectName>
  <x>675</x>
  <y>160</y>
  <width>178</width>
  <height>96</height>
  <uuid>{8f679e7c-bf7c-4f0d-b94a-8bf64810686d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>0</value>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>auto</modex>
  <modey>auto</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>922</x>
  <y>114</y>
  <width>91</width>
  <height>35</height>
  <uuid>{1daab3c6-caf8-4eaa-91fe-870e8e734f92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Impulse</label>
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
 <bsbObject version="2" type="BSBGraph">
  <objectName>impulse</objectName>
  <x>884</x>
  <y>159</y>
  <width>178</width>
  <height>96</height>
  <uuid>{32dc8bf3-b96c-49a8-8170-a598ba708d3d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>0</value>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>auto</modex>
  <modey>auto</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>np_saw</objectName>
  <x>314</x>
  <y>272</y>
  <width>59</width>
  <height>28</height>
  <uuid>{ca28f6b6-0abe-49d3-8eda-2c18152c10da}</uuid>
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
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>np_squ</objectName>
  <x>533</x>
  <y>272</y>
  <width>59</width>
  <height>28</height>
  <uuid>{1c5e78fb-58f0-44c9-b827-d979c4f2a0fa}</uuid>
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
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>np_tri</objectName>
  <x>740</x>
  <y>272</y>
  <width>59</width>
  <height>28</height>
  <uuid>{07e0476d-82a2-43f1-b9e7-78fc4839c681}</uuid>
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
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>np_imp</objectName>
  <x>949</x>
  <y>272</y>
  <width>59</width>
  <height>28</height>
  <uuid>{792834f1-858e-4c59-8b6b-6098fdb9a549}</uuid>
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
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>26</x>
  <y>407</y>
  <width>766</width>
  <height>165</height>
  <uuid>{d218dd29-950b-46e9-9fa4-dbe79b43364c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-1.00000000</value>
  <type>scope</type>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor21</objectName>
  <x>824</x>
  <y>405</y>
  <width>31</width>
  <height>166</height>
  <uuid>{529f7ef1-188b-4816-a742-a00eb9eb314b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>amp_sin</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.32258100</xValue>
  <yValue>0.19277108</yValue>
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
  <objectName>hor21</objectName>
  <x>855</x>
  <y>405</y>
  <width>31</width>
  <height>166</height>
  <uuid>{001606e5-a61c-4861-8d9b-8f2245e92778}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>amp_saw</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.32258100</xValue>
  <yValue>0.16265060</yValue>
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
  <objectName>hor21</objectName>
  <x>886</x>
  <y>405</y>
  <width>31</width>
  <height>166</height>
  <uuid>{8df519d9-fceb-4bee-bab6-e8920dab3e9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>amp_squ</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.32258100</xValue>
  <yValue>0.26506024</yValue>
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
  <objectName>hor21</objectName>
  <x>917</x>
  <y>405</y>
  <width>31</width>
  <height>166</height>
  <uuid>{45360760-17bc-4a53-904b-ea9039ce6540}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>amp_tri</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.32258100</xValue>
  <yValue>0.40963855</yValue>
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
  <objectName>hor21</objectName>
  <x>947</x>
  <y>405</y>
  <width>31</width>
  <height>166</height>
  <uuid>{ec94c846-1373-4777-b0c6-74f7ce1c6855}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>amp_imp</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.32258100</xValue>
  <yValue>0.72289157</yValue>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>824</x>
  <y>345</y>
  <width>148</width>
  <height>54</height>
  <uuid>{30b21d15-4d8e-4a8a-b539-3c332d94cddb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Relative Strength of the Five Waveforms</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>vol</objectName>
  <x>1008</x>
  <y>406</y>
  <width>22</width>
  <height>165</height>
  <uuid>{0bd55494-42a9-46a4-b774-aaaa9267bd8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.64242424</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>1039</x>
  <y>424</y>
  <width>18</width>
  <height>147</height>
  <uuid>{adfe8e43-acf9-42b6-88ed-d02595ea2f7d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
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
  <objectName>in1over_pre</objectName>
  <x>1039</x>
  <y>406</y>
  <width>18</width>
  <height>23</height>
  <uuid>{e4f880e1-6ed1-415f-bac9-bab6acafe0cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>outover</objectName2>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>999</x>
  <y>346</y>
  <width>64</width>
  <height>55</height>
  <uuid>{844aa0e6-9920-48ca-98e9-0ea1a86a5053}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Master
Volume</label>
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
  <x>63</x>
  <y>368</y>
  <width>214</width>
  <height>33</height>
  <uuid>{4d4b0f09-79f1-4b34-a9ca-11c2330fb7ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Scope Resulting Waveform</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>372</x>
  <y>363</y>
  <width>91</width>
  <height>27</height>
  <uuid>{56f09abb-7aea-4e8b-b0ad-277959bb0509}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>START</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Stop</objectName>
  <x>486</x>
  <y>363</y>
  <width>91</width>
  <height>27</height>
  <uuid>{f614c0aa-47ce-4432-ae75-060ffcb50831}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>STOP</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>35</x>
  <y>273</y>
  <width>176</width>
  <height>29</height>
  <uuid>{a545b53f-b0fa-41b1-9ec1-779e5d7d29c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Number of Harmonics:</label>
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
  <x>91</x>
  <y>59</y>
  <width>903</width>
  <height>53</height>
  <uuid>{ecc85f21-bdeb-481a-b8d7-da7b9ac1a05b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Standard Waveforms are built here by superposition of harmonics. The higher the number of harmonics, the sharper the shape. You can change here in realtime the number of harmonics and the relative strength of the five shapes in the resulting mix.</label>
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
  <x>190</x>
  <y>11</y>
  <width>712</width>
  <height>43</height>
  <uuid>{ca9a41af-9fb7-4c38-afab-561d2b5b88aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Waveform Mix</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>592</x>
  <y>363</y>
  <width>199</width>
  <height>28</height>
  <uuid>{fcd042ab-a450-40eb-a76c-b68af24c380d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>MAKE AUDIO</text>
  <image>/</image>
  <eventLine>i2 0 3 440 0.2</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <objectName/>
 <x>737</x>
 <y>267</y>
 <width>1134</width>
 <height>629</height>
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
WindowBounds: 737 267 1134 629
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {34, 265} {1028, 44} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder 
ioText {73, 116} {91, 35} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Sine
ioGraph {35, 161} {178, 96} table 0.000000 1.000000 sine
ioText {290, 116} {91, 35} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Saw
ioGraph {252, 161} {178, 96} table 0.000000 1.000000 saw
ioText {509, 115} {91, 35} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Square
ioGraph {471, 160} {178, 96} table 0.000000 1.000000 square
ioText {713, 115} {91, 35} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Triangle
ioGraph {675, 160} {178, 96} table 0.000000 1.000000 triangle
ioText {922, 114} {91, 35} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Impulse
ioGraph {884, 159} {178, 96} table 0.000000 1.000000 impulse
ioText {314, 272} {59, 28} editnum 8.000000 1.000000 "np_saw" right "" 0 {0, 0, 0} {59392, 59392, 59392} nobackground noborder 8.000000
ioText {533, 272} {59, 28} editnum 8.000000 1.000000 "np_squ" right "" 0 {0, 0, 0} {59392, 59392, 59392} nobackground noborder 8.000000
ioText {740, 272} {59, 28} editnum 8.000000 1.000000 "np_tri" right "" 0 {0, 0, 0} {59392, 59392, 59392} nobackground noborder 8.000000
ioText {949, 272} {59, 28} editnum 8.000000 1.000000 "np_imp" right "" 0 {0, 0, 0} {59392, 59392, 59392} nobackground noborder 8.000000
ioGraph {26, 407} {766, 165} scope 1.000000 -1 
ioMeter {824, 405} {31, 166} {0, 59904, 0} "hor21" 0.322581 "amp_sin" 0.192771 fill 1 0 mouse
ioMeter {855, 405} {31, 166} {0, 59904, 0} "hor21" 0.322581 "amp_saw" 0.162651 fill 1 0 mouse
ioMeter {886, 405} {31, 166} {0, 59904, 0} "hor21" 0.322581 "amp_squ" 0.265060 fill 1 0 mouse
ioMeter {917, 405} {31, 166} {0, 59904, 0} "hor21" 0.322581 "amp_tri" 0.409639 fill 1 0 mouse
ioMeter {947, 405} {31, 166} {0, 59904, 0} "hor21" 0.322581 "amp_imp" 0.722892 fill 1 0 mouse
ioText {824, 345} {148, 54} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Relative Strength of the Five Waveforms
ioSlider {1008, 406} {22, 165} 0.000000 2.000000 0.642424 vol
ioMeter {1039, 424} {18, 147} {0, 59904, 0} "hor8" 0.592593 "out" 0.000000 fill 1 0 mouse
ioMeter {1039, 406} {18, 23} {50176, 3584, 3072} "in1over_pre" 0.000000 "outover" 0.000000 fill 1 0 mouse
ioText {999, 346} {64, 55} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder MasterÂ¬Volume
ioText {63, 368} {214, 33} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Scope Resulting Waveform
ioButton {372, 363} {91, 27} value 1.000000 "_Play" "START" "/" i1 0 10
ioButton {486, 363} {91, 27} value 1.000000 "_Stop" "STOP" "/" i1 0 10
ioText {35, 273} {176, 29} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Number of Harmonics:
ioText {91, 59} {903, 53} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Standard Waveforms are built here by superposition of harmonics. The higher the number of harmonics, the sharper the shape. You can change here in realtime the number of harmonics and the relative strength of the five shapes in the resulting mix.
ioText {190, 11} {712, 43} label 0.000000 0.00100 "" center "Lucida Grande" 22 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Waveform Mix
ioButton {592, 363} {199, 28} event 1.000000 "" "MAKE AUDIO" "/" i2 0 3 440 0.2
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="543" y="318" width="614" height="322" visible="true" loopStart="0" loopEnd="0">i 1 0 3 
    
    
    
    
    
    
    
    </EventPanel>

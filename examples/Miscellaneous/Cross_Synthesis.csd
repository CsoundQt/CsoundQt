<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

/*****DIFFERENT METHODS OF CROSS SYNTHESIS*****/
;example for CsoundQt
;written by joachim heintz
;jan 2010
;please send bug reports and suggestions
;to jh at joachimheintz.de

sr = 44100
nchnls = 2
ksmps = 64
0dbfs = 1

		seed		0

  opcode FileToPvsBuf1, iik, Siiii
;;writes the first channel of an audio file at the first k-cycle to a fft-buffer (via pvsbuffer)
Sfile, ifftsize, ioverlap, iwinsize, iwinshape xin
ktimek		timeinstk
if ktimek == 1 then
ilen		filelen	Sfile
kcycles	=		ilen * kr; number of k-cycles to write the fft-buffer
kcount		init		0
ichnls		filenchnls	Sfile
if ichnls == 1 then; Mono
loopmono:
ain		soundin	Sfile
fftin		pvsanal	ain, ifftsize, ioverlap, iwinsize, iwinshape
ibuf, ktim	pvsbuffer	fftin, ilen + (ifftsize / sr)
		loop_lt	kcount, 1, kcycles, loopmono
else; Stereo
loopstereo:
ain, anull	soundin	Sfile
fftin		pvsanal	ain, ifftsize, ioverlap, iwinsize, iwinshape
ibuf, ktim	pvsbuffer	fftin, ilen + (ifftsize / sr)
		loop_lt	kcount, 1, kcycles, loopstereo
endif
		xout		ibuf, ilen, ktim
endif
  endop

  opcode	ShowLED_a, 0, Sakkk
;shows an audiosignal in an outvalue channel, in dB or raw amplitudes
;Soutchan: string as name of the outvalue channel
;asig: audio signal to be shown
;kdispfreq: refresh frequency of the display (Hz)
;kdb: 1 = show as db, 0 = show as raw amplitudes (both in the range 0-1)
;kdbrange: if idb=1: which dB range is shown
Soutchan, asig, ktrig, kdb, kdbrange	xin
kdispval	max_k	asig, ktrig, 1
	if kdb != 0 then
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
;shows if asig has been larger than 1 and stays khold seconds
;Soutchan: string as name of the outvalue channel
;kdispfreq: refresh frequency of the display (Hz)
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
;;FILE INPUT AND FFT-BUFFER LOAD
Sfile1		invalue	"_Browse1"
Sfile2		invalue	"_Browse2"
ifftsize	=		1024
ioverlap	=		ifftsize / 4
iwinsize	=		ifftsize
iwinshape	=		1; von-Hann window
ibuffer1, ilen1, k01  FileToPvsBuf1  Sfile1, ifftsize, ioverlap, iwinsize, iwinshape
ibuffer2, ilen2, k02  FileToPvsBuf1  Sfile2, ifftsize, ioverlap, iwinsize, iwinshape
;;TIME POINTER IN BUFFER 1 AND 2
;Select method
ktimreadmeth	invalue	"timreadmeth"; 0=phasor, 1=gui, 2=random
 if ktimreadmeth == 0 then; 1) PHASOR
kphaspeed1	invalue	"phaspeed1"
kphaspeed2	invalue	"phaspeed2"
kphasfq1	=		kphaspeed1 / ilen1
kphasfq2	=		kphaspeed2 / ilen2
kphaspnt1	phasor		kphasfq1
kphaspnt2	phasor		kphasfq2
kpnt1		=		kphaspnt1 * ilen1
kpnt2		=		kphaspnt2 * ilen2
 elseif ktimreadmeth == 1 then; 2) CONTROLLER WIDGET (MOUSE)
kpos1		invalue	"livepos1"; horizontal (left to right) = position in file 1
kpos2		invalue	"livepos2"; vertical (bottom to top) = position in file 2
kpnt1		=		kpos1 * ilen1
kpnt2		=		kpos2 * ilen2
 else; 3) RANDOM POSITIONS AND INTERPOLATIONS
kfqnewval1	invalue	"fqnewval1"; frequency of new random values for file 1
kfqnewval2	invalue	"fqnewval2"; and for file 2
kpnt1		randomi	0, ilen1, kfqnewval1
kpnt2		randomi	0, ilen2, kfqnewval2
 endif
;show pointer positions
		outvalue	"kpnt1", kpnt1; time in seconds for display widget
		outvalue	"kpnt2", kpnt2
		outvalue	"showpos1", kpnt1/ilen1; time 0-1 for controller widget
		outvalue	"showpos2", kpnt2/ilen2
;;CREATE PVS STREAMS
kchangeorder	invalue	"changeorder"
kbuffer1	=		(kchangeorder == 0 ? ibuffer1 : ibuffer2)
kbuffer2	=		(kchangeorder == 0 ? ibuffer2 : ibuffer1)
fread1		pvsbufread	kpnt1, kbuffer1
fread2		pvsbufread	kpnt2, kbuffer2
;;PERFORM CROSS SYNTHESIS
kselcross	invalue	"selcross"
if kselcross == 0 then
;PVSCROSS: freqs from fread1, amps according crossamp from fread1 and fread2
kcrossamp2	invalue	"crossamp"; 0-1
kcrossamp1	=		1 - kcrossamp2
fcross		pvscross	fread1, fread2, kcrossamp1, kcrossamp2
elseif kselcross == 1 then
;PVSFILTER: freqs from fread1, amps from fread1 are multipied by those from fread2 scaled by kfiltdepth
kfiltdepth	invalue	"filtdepth"
fcross		pvsfilter	fread1, fread2, kfiltdepth
elseif kselcross == 2 then
;PVSVOC: amps from fread1, freqs from fread2 according to kvocdepth
kvocdepth	invalue	"vocdepth"; freqs from fread1 (0) or fread2 (1)
fcross		pvsvoc		fread1, fread2, kvocdepth, 1
else
;PVSMORPH: interpolates between the freqs and the amps from both streams according to kmorphfreq and kmorphamp
kmorphamp	invalue	"morphamp"
kmorphfreq	invalue	"morphfreq"
fcross		pvsmorph	fread1, fread2, kmorphamp, kmorphfreq
endif
;;RESYNTHESIZE 
across		pvsynth	fcross
kvol		invalue	"vol"
avol		=		across * kvol
		outs		avol, avol
;;SHOW OUTPUT
kshowdb	invalue	"showdb"; 0=raw amplitudes, 1=db as display in the widgets
kdbrange	invalue	"dbrange"; if kshowdb==1: which db range
kTrigDisp	metro		10
		ShowLED_a	"out", avol, kTrigDisp, kshowdb, kdbrange
		ShowOver_a	"outover", avol, kTrigDisp, 2
endin
</CsInstruments>
<CsScore>
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>147</x>
 <y>53</y>
 <width>992</width>
 <height>753</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>timreadmeth</objectName>
  <x>832</x>
  <y>69</y>
  <width>110</width>
  <height>25</height>
  <uuid>{2cbcd6fe-f4d6-4d9a-9710-df3bd7967c6d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Phasor</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Live</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Random</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>525</x>
  <y>64</y>
  <width>295</width>
  <height>32</height>
  <uuid>{168c30b1-7d68-4a87-8158-ea37ea82bd49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Select a Method of Time Reading</label>
  <alignment>left</alignment>
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
  <x>492</x>
  <y>96</y>
  <width>473</width>
  <height>98</height>
  <uuid>{081f0ad6-9f99-4c24-9ea4-49be2561e886}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>phaspeed1</objectName>
  <x>551</x>
  <y>126</y>
  <width>339</width>
  <height>28</height>
  <uuid>{2e02eb2b-d5df-4c0f-a804-1f02c8793592}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00884956</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>phaspeed1</objectName>
  <x>889</x>
  <y>128</y>
  <width>70</width>
  <height>26</height>
  <uuid>{4d97c9db-8f7f-42a8-81f8-59eba003b2e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1.009</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>phaspeed2</objectName>
  <x>550</x>
  <y>154</y>
  <width>339</width>
  <height>28</height>
  <uuid>{ccea15fb-2d06-4f1a-ba79-a11e881c1ac6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.03244838</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>phaspeed2</objectName>
  <x>888</x>
  <y>156</y>
  <width>70</width>
  <height>26</height>
  <uuid>{3abca60e-f8d0-4f35-90e2-8d05e4e5e21e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1.032</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>500</x>
  <y>125</y>
  <width>52</width>
  <height>30</height>
  <uuid>{56b2c881-3b85-47ad-aa0b-1356246164b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File 1</label>
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
  <x>499</x>
  <y>152</y>
  <width>52</width>
  <height>30</height>
  <uuid>{191a3830-1496-4beb-9c2d-6a9b4784837f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File 2</label>
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
  <x>8</x>
  <y>258</y>
  <width>479</width>
  <height>73</height>
  <uuid>{3b051ce0-aec5-45fe-a70a-0cbd563a3c60}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>pvscross</label>
  <alignment>left</alignment>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>397</y>
  <width>479</width>
  <height>70</height>
  <uuid>{be3417c3-109a-4eb5-b6b8-8a07e457cbf8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>pvsvoc</label>
  <alignment>left</alignment>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>330</y>
  <width>479</width>
  <height>68</height>
  <uuid>{f56027f7-40ef-45e3-a2cd-0bb4959f886c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>pvsfilter</label>
  <alignment>left</alignment>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>466</y>
  <width>479</width>
  <height>134</height>
  <uuid>{0bb4cf06-2b65-49d0-af53-827094c69029}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>pvsmorph</label>
  <alignment>left</alignment>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>crossamp</objectName>
  <x>74</x>
  <y>293</y>
  <width>275</width>
  <height>29</height>
  <uuid>{0d59f168-a4ec-4fae-8dac-a8e71b799f30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.68727273</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>crossamp</objectName>
  <x>406</x>
  <y>295</y>
  <width>70</width>
  <height>26</height>
  <uuid>{6f1df2fd-883f-4b37-98c8-dac8ef4e09dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.5709</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>17</x>
  <y>292</y>
  <width>52</width>
  <height>30</height>
  <uuid>{968f9b93-9265-4733-98fb-6f50e1c745ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File 1</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>146</x>
  <y>265</y>
  <width>160</width>
  <height>29</height>
  <uuid>{e1f81f66-6b32-4cf5-82fe-244f4e5c390a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amplitudes from </label>
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
  <x>351</x>
  <y>294</y>
  <width>52</width>
  <height>30</height>
  <uuid>{30652f9b-b5c4-4ca3-b506-d6b2a079bf8f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File 2</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>morphfreq</objectName>
  <x>79</x>
  <y>559</y>
  <width>275</width>
  <height>29</height>
  <uuid>{69d2e2c4-fd06-4522-beba-f80dcb6e3454}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.23636400</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>morphfreq</objectName>
  <x>411</x>
  <y>561</y>
  <width>70</width>
  <height>26</height>
  <uuid>{86a5c15f-c431-4c0f-9529-a69fd184ffb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.2364</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>558</y>
  <width>52</width>
  <height>30</height>
  <uuid>{1844ce57-7b46-45c8-9dd5-d4db3ef30c8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File 1</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>88</x>
  <y>531</y>
  <width>307</width>
  <height>29</height>
  <uuid>{50b36f81-7b94-4d77-a8b4-42f3acdc1796}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Frequencies from </label>
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
  <x>356</x>
  <y>560</y>
  <width>52</width>
  <height>30</height>
  <uuid>{8aeb7e20-1038-4d0d-b124-5f5b415bb4a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File 2</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>selcross</objectName>
  <x>357</x>
  <y>231</y>
  <width>108</width>
  <height>22</height>
  <uuid>{d2474762-8299-44f9-9ffb-54562c752970}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>pvscross</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>pvsfilter</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>pvsvoc</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>pvsmorph</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>45</x>
  <y>227</y>
  <width>325</width>
  <height>32</height>
  <uuid>{eb3b80e1-f6e8-44d6-8978-147b2c1d6bd1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Select a Method of Cross Synthesis</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>filtdepth</objectName>
  <x>73</x>
  <y>362</y>
  <width>275</width>
  <height>29</height>
  <uuid>{dac15923-90a6-42a3-ad56-5dbd0943441c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>filtdepth</objectName>
  <x>405</x>
  <y>364</y>
  <width>70</width>
  <height>26</height>
  <uuid>{eec0681a-631d-435b-b7a9-88f518b020dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>16</x>
  <y>361</y>
  <width>52</width>
  <height>30</height>
  <uuid>{45d8bfa5-61e5-4282-8013-e3e8bb3767a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>low</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>82</x>
  <y>336</y>
  <width>307</width>
  <height>29</height>
  <uuid>{d73cd00c-8161-4a9e-8d89-56d1df87f3c8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Depth of filtering</label>
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
  <x>350</x>
  <y>363</y>
  <width>52</width>
  <height>30</height>
  <uuid>{7b0b8888-a340-4ca1-8c89-94e57d45a0ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>high</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vocdepth</objectName>
  <x>71</x>
  <y>429</y>
  <width>275</width>
  <height>29</height>
  <uuid>{f21a4bb9-8efd-4893-9aec-0f61190df1bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>vocdepth</objectName>
  <x>403</x>
  <y>431</y>
  <width>70</width>
  <height>26</height>
  <uuid>{6deed02e-065f-451c-bf0f-e70b46672cc3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>428</y>
  <width>52</width>
  <height>30</height>
  <uuid>{18e960e1-b9f9-478c-b0a5-2d4320c52599}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>low</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>80</x>
  <y>403</y>
  <width>307</width>
  <height>29</height>
  <uuid>{9e0ea5b8-45ab-4bfb-8df1-8680d08cd749}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Depth of vocoding</label>
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
  <x>348</x>
  <y>430</y>
  <width>52</width>
  <height>30</height>
  <uuid>{b131b405-391f-4d5b-a189-5fe20c1aad57}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>high</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>morphamp</objectName>
  <x>79</x>
  <y>497</y>
  <width>275</width>
  <height>29</height>
  <uuid>{16fe1b07-104d-4d48-a58b-d73395aaec87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.72363600</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>morphamp</objectName>
  <x>411</x>
  <y>499</y>
  <width>70</width>
  <height>26</height>
  <uuid>{2ca1d067-43f7-4c2f-bc6f-0cf5b77e81aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.7236</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>496</y>
  <width>52</width>
  <height>30</height>
  <uuid>{f04744bb-222e-411a-b82f-9362ccb545e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File 1</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>90</x>
  <y>471</y>
  <width>307</width>
  <height>29</height>
  <uuid>{08bf5006-02cc-41f8-9424-e27db96acc6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amplitudes from </label>
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
  <x>356</x>
  <y>498</y>
  <width>52</width>
  <height>30</height>
  <uuid>{4d8b3e36-27f7-4b78-b828-3b956fa02b6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File 2</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>499</x>
  <y>101</y>
  <width>227</width>
  <height>27</height>
  <uuid>{4ef6c3a5-b6a5-48f3-b983-754b6b527625}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>For Method "Phasor": Set Speed</label>
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
  <x>492</x>
  <y>196</y>
  <width>474</width>
  <height>291</height>
  <uuid>{5e320d9a-d312-4c87-96d8-5720376186dc}</uuid>
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
  <x>502</x>
  <y>202</y>
  <width>98</width>
  <height>267</height>
  <uuid>{950bbec5-894b-471f-bb5b-42f8e7a6b607}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>For Method "Live":
Set Positions for File 1 from left to right and for File 2 from bottom to top</label>
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
  <objectName>livepos1</objectName>
  <x>631</x>
  <y>201</y>
  <width>313</width>
  <height>280</height>
  <uuid>{5e0ad7c5-d9a7-404d-8292-78249deb6ca2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>livepos2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.61980800</xValue>
  <yValue>0.67857100</yValue>
  <type>crosshair</type>
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
  <x>492</x>
  <y>490</y>
  <width>474</width>
  <height>110</height>
  <uuid>{fc78d3a5-b548-4e87-ad81-ebea05de93f2}</uuid>
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
  <x>498</x>
  <y>498</y>
  <width>464</width>
  <height>44</height>
  <uuid>{146ba05b-f69f-4edd-ae9f-330eda2ff550}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>For Method "Random":
Set Frequency for new Random Positions in File 1 and File 2</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>fqnewval1</objectName>
  <x>518</x>
  <y>542</y>
  <width>170</width>
  <height>27</height>
  <uuid>{32cf9b48-6de5-4d37-9fcb-ea555f6e1371}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.40000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>fqnewval1</objectName>
  <x>591</x>
  <y>565</y>
  <width>61</width>
  <height>28</height>
  <uuid>{550185bc-d9a3-4c3a-8a5a-2616e62234a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.4000</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>fqnewval2</objectName>
  <x>728</x>
  <y>541</y>
  <width>171</width>
  <height>28</height>
  <uuid>{7188a16f-e72b-4d38-a20f-e1374dc759ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.42105300</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>fqnewval2</objectName>
  <x>799</x>
  <y>565</y>
  <width>70</width>
  <height>29</height>
  <uuid>{ff509908-331c-4876-8717-d5c07cbe3d98}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.4211</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>536</x>
  <y>564</y>
  <width>52</width>
  <height>30</height>
  <uuid>{fe438499-51e2-44b5-871b-66dbe85c5ab1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File 1</label>
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
  <x>747</x>
  <y>564</y>
  <width>52</width>
  <height>30</height>
  <uuid>{7ef3ee21-b834-4fa0-9827-cbde14ed0437}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File 2</label>
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
  <x>8</x>
  <y>603</y>
  <width>736</width>
  <height>150</height>
  <uuid>{2ab6d209-e394-45a4-9fc1-f8d60aa437e5}</uuid>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kpnt1</objectName>
  <x>114</x>
  <y>656</y>
  <width>81</width>
  <height>28</height>
  <uuid>{4b7d9ba8-26d2-49ea-ace1-9a8ce6adbbca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2.528</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>642</y>
  <width>103</width>
  <height>43</height>
  <uuid>{d4301dbf-d28a-4e2e-bbe2-2e8d4c16f390}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Position (sec) in File 1</label>
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
  <objectName>kpnt2</objectName>
  <x>115</x>
  <y>708</y>
  <width>81</width>
  <height>28</height>
  <uuid>{e866aefe-21a1-4b31-b495-cdb2ede852c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2.650</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>693</y>
  <width>103</width>
  <height>43</height>
  <uuid>{e474027d-4dcc-4849-ac47-85ac0622bd9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Position (sec) in File 2</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>out</objectName>
  <x>372</x>
  <y>683</y>
  <width>336</width>
  <height>22</height>
  <uuid>{e55f4043-6c09-43a3-a29e-f305e09efac0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.35449717</xValue>
  <yValue>0.54545500</yValue>
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
  <objectName>outover</objectName>
  <x>706</x>
  <y>683</y>
  <width>27</width>
  <height>22</height>
  <uuid>{50fe09c2-8d24-4a19-83c5-af2f513a8598}</uuid>
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
  <x>654</x>
  <y>715</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ddde6659-b233-4f4d-a648-b40639b9a109}</uuid>
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
  <value>50</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>575</x>
  <y>714</y>
  <width>80</width>
  <height>26</height>
  <uuid>{9b50cfd2-c51b-45a3-9130-295d06d769c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>dB-Range</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>372</x>
  <y>714</y>
  <width>117</width>
  <height>25</height>
  <uuid>{f97232e1-a909-463b-b2f2-9d8131327613}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Show LED as</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>showdb</objectName>
  <x>489</x>
  <y>714</y>
  <width>84</width>
  <height>26</height>
  <uuid>{d115e7ab-2af9-48fb-a766-73c7bf646810}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Amplitudes</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>dB</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vol</objectName>
  <x>373</x>
  <y>642</y>
  <width>293</width>
  <height>31</height>
  <uuid>{ebcfb63c-0632-4c78-b7e1-150fc2f8747f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>4.00000000</maximum>
  <value>1.33788396</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>396</x>
  <y>618</y>
  <width>307</width>
  <height>29</height>
  <uuid>{8bdddf0f-ecc8-4e21-962d-47cdd560ad0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Volume</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>showpos1</objectName>
  <x>202</x>
  <y>612</y>
  <width>152</width>
  <height>130</height>
  <uuid>{f4530b8b-7c19-422c-a575-d893a308ba1a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>showpos2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.91703740</xValue>
  <yValue>0.96108993</yValue>
  <type>crosshair</type>
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
  <objectName>vol</objectName>
  <x>665</x>
  <y>645</y>
  <width>69</width>
  <height>27</height>
  <uuid>{71104e80-4151-4b49-b061-1499603d3481}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1.338</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>612</y>
  <width>147</width>
  <height>30</height>
  <uuid>{deaf3cae-bde6-4331-aefd-58404e4e50de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Output</label>
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
  <x>8</x>
  <y>96</y>
  <width>480</width>
  <height>123</height>
  <uuid>{b26bcd3f-601c-4261-84d3-81a13969175a}</uuid>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>14</x>
  <y>117</y>
  <width>358</width>
  <height>22</height>
  <uuid>{826e6a48-8782-47df-82d1-4111fbbe416f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>/home/linux/Quellen/csoundmanual/examples/fox.wav</label>
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
   <r>242</r>
   <g>241</g>
   <b>240</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>373</x>
  <y>115</y>
  <width>107</width>
  <height>29</height>
  <uuid>{0d65e94b-7973-4189-a45a-0d29fa5f60b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Quellen/csoundmanual/examples/fox.wav</stringvalue>
  <text>File 1</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse2</objectName>
  <x>14</x>
  <y>151</y>
  <width>358</width>
  <height>22</height>
  <uuid>{43019fb8-7d96-441c-933f-14cfa550a79e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>/home/linux/Joachim/Csound/FLOSS/FT_Spectral/wave.wav</label>
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
   <r>242</r>
   <g>241</g>
   <b>240</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse2</objectName>
  <x>373</x>
  <y>149</y>
  <width>107</width>
  <height>29</height>
  <uuid>{cb9b3b67-c25f-42cf-a2c4-4b3efb8d2754}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Joachim/Csound/FLOSS/FT_Spectral/wave.wav</stringvalue>
  <text>File 2</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>184</y>
  <width>311</width>
  <height>27</height>
  <uuid>{1030ef1f-618b-47ee-919d-588e04fa9869}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Let File 1 be File 2 and vice versa</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>changeorder</objectName>
  <x>324</x>
  <y>187</y>
  <width>27</width>
  <height>19</height>
  <uuid>{c29f5713-6ca8-4c41-8de8-c83b5668742f}</uuid>
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
  <x>43</x>
  <y>66</y>
  <width>190</width>
  <height>30</height>
  <uuid>{656b7160-e58b-4f79-ae41-aeaf91a60d79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Choose Files</label>
  <alignment>left</alignment>
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
  <x>8</x>
  <y>14</y>
  <width>958</width>
  <height>49</height>
  <uuid>{d3ecca91-b2d8-4fea-b8a2-0748e3685de4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>CROSS SYNTHESIS</label>
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
  <x>747</x>
  <y>603</y>
  <width>219</width>
  <height>150</height>
  <uuid>{ca373e1b-b47e-42c2-9a7f-9b5f84522b22}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Here you can perform four different methods of Cross Synthesis in Csound.
First, choose two files you want to cross. Second, select a method of cross synthesis (see the relevant manual pages for detailed descriptions).
Third, select a method of time reading: phasor (constant speed), mouse input or random. </label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

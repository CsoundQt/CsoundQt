<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

/*****Universal Convolution*****/
;example for CsoundQt
;written by joachim heintz
;jul 2009
;please send bug reports and suggestions
;to jh at joachimheintz.de

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

  opcode TakeAll2, aa, Skii
Sfil, kspeed, iskip, iloop	xin
ichn		filenchnls	Sfil
if ichn == 1 then
aL		diskin2	Sfil, kspeed, iskip, iloop
aR		=		aL
else
aL, aR		diskin2	Sfil, kspeed, iskip, iloop
endif
		xout		aL, aR
  endop

  opcode	ShowLED_k, 0, Skkik
Soutchan, kdispval, ktrig, idb, kdbrange	xin
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

  opcode ShowOver_k, 0, Skkk
Soutchan, kmax, ktrig, khold	xin
kon		init		0
ktim		times
kstart		init		0
kend		init		0
khold		=		(khold < .01 ? .01 : khold); avoiding too short hold times
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
;;values for file 1 (playback)
Sfile1		invalue	"_Browse1"; soundfile which is played back
kspeed		invalue	"speed"; playback speed (1 = original speed)
kskip		invalue	"skip"; skiptime in seconds
kloop		invalue	"loop"; 0 = no loop, 1 = loop
;;values and calculations for file 2 (convolution)
Sfile2		invalue	"_Browse2"; soundfile which is used as impulse response
kstartabs	invalue	"startabs"; 0-1
kirlen		invalue	"irlen"; length of selected impulse response in secs (0 = take the whole length)
kpartsiz	invalue	"partsiz"; partitionsize of convolution
kplen		=		(kpartsiz == 0 ? 256 : (kpartsiz == 1 ? 512 : (kpartsiz == 2 ? 1024 : (kpartsiz == 3 ? 2048 : 4096))))
iconvsr	filesr		Sfile2; sample rate of convolution file
iconvlen	filelen	Sfile2; length of convolution file in seconds ...
iconvlensmps	=		iconvlen * iconvsr; ... and in samples
kselstart	=		kstartabs * iconvlen; startpoint of selection for convolution in seconds ...
		outvalue	"start", kselstart
kskpsmps	=		kselstart * iconvsr; ... and in samples
kirlensmps	=		(kirlen == 0? (iconvlen - kselstart) * iconvsr : kirlen * iconvsr); length of selection in samples

;;creating two ftables (left and right channel) for ftconv
ichnlsfil2	filenchnls	Sfile2
if ichnlsfil2 == 2 then
iftlen		=		2 ^ ceil(log(iconvlensmps / 2) / log(2))
giftL		ftgen		0, 0, iftlen, 1, Sfile2, 0, 0, 1
giftR		ftgen		0, 0, iftlen, 1, Sfile2, 0, 0, 2
else; if mono impulse response, create two identical tables
iftlen		=		2 ^ ceil(log(iconvlensmps) / log(2))
giftL		ftgen		0, 0, iftlen, 1, Sfile2, 0, 0, 1
giftR		ftgen		0, 0, iftlen, 1, Sfile2, 0, 0, 1
endif

;;creating the playback audio stream as global audio
gaL, gaR	TakeAll2	Sfile1, kspeed, i(kskip), i(kloop)

;;calling a subinstrument with a release time (to avoid clicks) for performing the convolution 
ktrig		changed	kplen, kskpsmps, kirlensmps; if there are new values for the selection in file 2:
if ktrig == 1 then
		event		"i", -10, 0, 0; stop previous instance of instr 10
		event		"i", 10, 0, -p3, kplen, kskpsmps, kirlensmps; call new instance with new values
endif

;;show output
gkshowL	init		0
gkshowR	init		0
kTrigDisp	metro		10
		ShowLED_k	"outL", gkshowL, kTrigDisp, 0, 50
		ShowLED_k	"outR", gkshowR, kTrigDisp, 0, 50
		ShowOver_k	"outLover", gkshowL, kTrigDisp, 2
		ShowOver_k	"outRover", gkshowR, kTrigDisp, 2
endin

instr 10
;;input values
iplen		=		p4; partitionsize of convolution
iskpsmps	=		p5; how many samples to skip
iirlen		=		p6; length of selection for impulse response in samples
kwdmix		invalue	"wdmix"; 0 = dry (just playback stream), 1 = wet (just convoluted signal)
kgain		invalue	"gain"
;;performing convolution
acvL		ftconv  	gaL, giftL, iplen, iskpsmps, iirlen
acvR		ftconv  	gaR, giftR, iplen, iskpsmps, iirlen
;;mixing dry and wet parts
awetL		=		acvL * kwdmix
awetR		=		acvR * kwdmix
adryL		=		gaL * (1 - kwdmix)
adryR		=		gaR * (1 - kwdmix)
aL		=		(awetL + adryL) * kgain
aR		=		(awetR + adryR) * kgain
;;declicking envelope and output
aenv		linsegr	0, .01, 1, p3-.01, 1, .01, 0
aoutL		=		aL * aenv
aoutR		=		aR * aenv
		outs		aoutL, aoutR
gaL		=		0; zero global audio
gaR		=		0
;;send the peak information to the display
kTrigDisp	metro		10
gkshowL	max_k		aoutL, kTrigDisp, 1
gkshowR	max_k		aoutR, kTrigDisp, 1
endin

</CsInstruments>
<CsScore>
i 1 0 9999
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>286</x>
 <y>79</y>
 <width>532</width>
 <height>703</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>68</x>
  <y>6</y>
  <width>398</width>
  <height>43</height>
  <uuid>{0dfd9349-d4f3-44ba-9392-436787965358}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>UNIVERSAL CONVOLUTION</label>
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
  <x>23</x>
  <y>91</y>
  <width>472</width>
  <height>141</height>
  <uuid>{1b921b24-730c-404d-9d46-89e1854ef34f}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>23</x>
  <y>468</y>
  <width>474</width>
  <height>209</height>
  <uuid>{efd6b17f-4c09-4e23-ad57-5744401d6a82}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>23</x>
  <y>237</y>
  <width>474</width>
  <height>223</height>
  <uuid>{bfc8f118-c544-4857-bb8b-a1612fe3334c}</uuid>
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
  <x>39</x>
  <y>134</y>
  <width>346</width>
  <height>25</height>
  <uuid>{bf9e3246-29ee-46d2-a3f3-7de50d473ea5}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>389</x>
  <y>133</y>
  <width>100</width>
  <height>30</height>
  <uuid>{56887738-e5d6-4df8-8232-fbdef66f33aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Open File 1</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>150</x>
  <y>96</y>
  <width>192</width>
  <height>29</height>
  <uuid>{d76dc890-5021-4e65-a76a-423a9fceac95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Soundfile 1 for Playback</label>
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
  <x>55</x>
  <y>162</y>
  <width>63</width>
  <height>27</height>
  <uuid>{1f2442dd-02f4-4114-8e10-53936f7caa61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>speed</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>skip</objectName>
  <x>172</x>
  <y>199</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4f293280-0835-4944-8ace-9e355fab1f41}</uuid>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>166</x>
  <y>163</y>
  <width>85</width>
  <height>27</height>
  <uuid>{5fe3eed0-b448-4d85-a9eb-ee43242ea31c}</uuid>
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
  <x>295</x>
  <y>165</y>
  <width>85</width>
  <height>27</height>
  <uuid>{e8b4fc19-b152-414e-83d7-a18fe5ec2b18}</uuid>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>loop</objectName>
  <x>312</x>
  <y>199</y>
  <width>56</width>
  <height>22</height>
  <uuid>{6fe0f726-7021-4795-b5a4-35c1d8db2aee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>no</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>yes</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>speed</objectName>
  <x>49</x>
  <y>197</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0ed6e4f8-a586-459a-b882-ac734ca54253}</uuid>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse2</objectName>
  <x>39</x>
  <y>280</y>
  <width>348</width>
  <height>25</height>
  <uuid>{732ed584-df46-47ed-b98d-239c33707191}</uuid>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse2</objectName>
  <x>393</x>
  <y>279</y>
  <width>100</width>
  <height>30</height>
  <uuid>{133f0f35-a0e6-48b9-945b-d92a4b8bf5d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Open File 2</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>147</x>
  <y>242</y>
  <width>192</width>
  <height>29</height>
  <uuid>{4593c21f-d695-47ab-95c6-5be8156ba5f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Soundfile 2 for Convolution</label>
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
  <x>25</x>
  <y>331</y>
  <width>280</width>
  <height>29</height>
  <uuid>{f96477f6-1a88-4eb4-99aa-2b3d85b02539}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Selection in Soundfile 2 for Convolution</label>
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
  <x>78</x>
  <y>372</y>
  <width>63</width>
  <height>27</height>
  <uuid>{3f5d63e6-aea0-46fd-9270-b66473655ec2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>start</label>
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
  <x>250</x>
  <y>370</y>
  <width>63</width>
  <height>27</height>
  <uuid>{f2ee5559-ba39-454b-951d-af2053e1263a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>length</label>
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
  <y>333</y>
  <width>105</width>
  <height>29</height>
  <uuid>{f61b9803-c1d1-4420-b7bb-bdbdd7a838a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Partitionsize</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>partsiz</objectName>
  <x>357</x>
  <y>370</y>
  <width>84</width>
  <height>24</height>
  <uuid>{7495ceb2-acc3-42ef-9ea3-f18958e87542}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>256</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>512</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>1024</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2048</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4096</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>startabs</objectName>
  <x>34</x>
  <y>397</y>
  <width>156</width>
  <height>29</height>
  <uuid>{71469a99-1292-40c0-8709-97538dc3fd29}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.20512800</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>irlen</objectName>
  <x>204</x>
  <y>396</y>
  <width>156</width>
  <height>29</height>
  <uuid>{dd3fe5d5-9446-4332-82bf-f5108f9d4a7d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.08333300</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>start</objectName>
  <x>84</x>
  <y>430</y>
  <width>62</width>
  <height>34</height>
  <uuid>{a951505a-e910-470b-8e8a-9fb704ae8bbf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1.1627</label>
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
  <objectName>irlen</objectName>
  <x>229</x>
  <y>429</y>
  <width>55</width>
  <height>28</height>
  <uuid>{130f73fc-6a52-491b-95b0-b05dbe596ca2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.0833</label>
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
  <x>284</x>
  <y>429</y>
  <width>212</width>
  <height>29</height>
  <uuid>{e9c56d17-9b8c-48eb-8fcd-e2fb581dfd28}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0 = take the whole file length</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>wdmix</objectName>
  <x>113</x>
  <y>521</y>
  <width>282</width>
  <height>29</height>
  <uuid>{fa18f494-a9df-4ad5-ae0a-4723109db6fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.74822700</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>191</x>
  <y>483</y>
  <width>130</width>
  <height>30</height>
  <uuid>{d8a31d59-1afd-49f9-bf11-3360d83fafdc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Wet-Dry Mix</label>
  <alignment>center</alignment>
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
  <x>73</x>
  <y>521</y>
  <width>34</width>
  <height>27</height>
  <uuid>{90a871c4-2519-45eb-ba44-b742fa87438a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Dry</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>402</x>
  <y>522</y>
  <width>34</width>
  <height>27</height>
  <uuid>{1ac3bf90-8661-42b7-bbbd-2f8006716234}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Wet</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>308</x>
  <y>570</y>
  <width>130</width>
  <height>28</height>
  <uuid>{3def89e0-8953-4d4a-85bb-2e2e193a9331}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Output Gain</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>gain</objectName>
  <x>102</x>
  <y>566</y>
  <width>201</width>
  <height>34</height>
  <uuid>{1eef7045-2e40-475c-9543-8bbb1b26235d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.10000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.54427900</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>gain</objectName>
  <x>36</x>
  <y>566</y>
  <width>62</width>
  <height>34</height>
  <uuid>{4d3d0bad-8090-450e-b6e7-84dd8c07988c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.5537</label>
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
  <objectName>wdmix</objectName>
  <x>325</x>
  <y>481</y>
  <width>62</width>
  <height>34</height>
  <uuid>{0c2ae3bd-ee97-4699-96ef-4d1ff316e427}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.7553</label>
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
  <objectName>outL</objectName>
  <x>124</x>
  <y>614</y>
  <width>250</width>
  <height>19</height>
  <uuid>{52e33137-e648-4c88-81de-ebddb3f0905d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out1_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.10908000</xValue>
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
  <x>371</x>
  <y>614</y>
  <width>21</width>
  <height>19</height>
  <uuid>{729db991-6c0e-46d7-b7d6-7ba7efeae81f}</uuid>
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
  <x>124</x>
  <y>641</y>
  <width>250</width>
  <height>19</height>
  <uuid>{c68846ac-172c-49bd-8cd3-a9742c17d0e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.10908000</xValue>
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
  <x>371</x>
  <y>641</y>
  <width>21</width>
  <height>19</height>
  <uuid>{f56fef73-44c7-4e1f-a62b-a18512955ca3}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>23</x>
  <y>49</y>
  <width>472</width>
  <height>47</height>
  <uuid>{1812f769-c632-4bc3-9080-c213690435d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>You can convolve here any file with any other (or usually a selection of it). </label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 286 79 532 703
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {68, 6} {398, 43} label 0.000000 0.00100 "" center "Lucida Grande" 26 {0, 0, 0} {65280, 65280, 65280} nobackground noborder UNIVERSAL CONVOLUTION
ioText {23, 91} {472, 141} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {23, 468} {474, 209} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {23, 237} {474, 223} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {39, 134} {346, 25} edit 0.000000 0.00100 "_Browse1"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 
ioButton {389, 133} {100, 30} value 1.000000 "_Browse1" "Open File 1" "/" 
ioText {150, 96} {192, 29} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Soundfile 1 for Playback
ioText {55, 162} {63, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder speed
ioText {172, 199} {80, 25} editnum 0.000000 0.001000 "skip" left "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000000
ioText {166, 163} {85, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder skiptime
ioText {295, 165} {85, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder loop
ioMenu {312, 199} {56, 22} 1 303 "no,yes" loop
ioText {49, 197} {80, 25} editnum 1.000000 0.001000 "speed" left "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000000
ioText {39, 280} {348, 25} edit 0.000000 0.00100 "_Browse2"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 
ioButton {393, 279} {100, 30} value 1.000000 "_Browse2" "Open File 2" "/" 
ioText {147, 242} {192, 29} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Soundfile 2 for Convolution
ioText {25, 331} {280, 29} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Selection in Soundfile 2 for Convolution
ioText {78, 372} {63, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder start
ioText {250, 370} {63, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder length
ioText {344, 333} {105, 29} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Partitionsize
ioMenu {357, 370} {84, 24} 2 303 "256,512,1024,2048,4096" partsiz
ioSlider {34, 397} {156, 29} 0.000000 1.000000 0.205128 startabs
ioSlider {204, 396} {156, 29} 0.000000 1.000000 0.083333 irlen
ioText {84, 430} {62, 34} display 1.162700 0.00100 "start" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.1627
ioText {229, 429} {55, 28} display 0.083300 0.00100 "irlen" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.0833
ioText {284, 429} {212, 29} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0 = take the whole file length
ioSlider {113, 521} {282, 29} 0.000000 1.000000 0.748227 wdmix
ioText {191, 483} {130, 30} label 0.000000 0.00100 "" center "DejaVu Sans" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet-Dry Mix
ioText {73, 521} {34, 27} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dry
ioText {402, 522} {34, 27} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet
ioText {308, 570} {130, 28} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Output Gain
ioSlider {102, 566} {201, 34} 0.100000 2.000000 0.544279 gain
ioText {36, 566} {62, 34} display 0.553700 0.00100 "gain" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.5537
ioText {325, 481} {62, 34} display 0.755300 0.00100 "wdmix" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.7553
ioMeter {124, 614} {250, 19} {0, 59904, 0} "outL" 0.109080 "out1_post" 0.578947 fill 1 0 mouse
ioMeter {371, 614} {21, 19} {50176, 3584, 3072} "outLover" 0.000000 "outLover" 0.000000 fill 1 0 mouse
ioMeter {124, 641} {250, 19} {0, 59904, 0} "outR" 0.109080 "out2_post" 1.000000 fill 1 0 mouse
ioMeter {371, 641} {21, 19} {50176, 3584, 3072} "outRover" 0.000000 "outRover" 0.000000 fill 1 0 mouse
ioText {23, 49} {472, 47} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder You can convolve here any file with any other (or usually a selection of it). 
</MacGUI>

<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

/*****GRANULAR SYNTHESIS OF A SOUNDFILE*****/
;example for qutecsound
;written by joachim heintz (with thanks to Oeyvind Brandtsegg)
;jan 2010
;please send bug reports and suggestions
;to jh at joachimheintz.de


nchnls = 2
ksmps = 16
0dbfs = 1

giWin1		ftgen		1, 0, 4096, 20, 1, 1		; Hamming
giWin2		ftgen		2, 0, 4096, 20, 2, 1		; von Hann
giWin3		ftgen		3, 0, 4096, 20, 3, 1		; Triangle (Bartlett)
giWin4		ftgen		4, 0, 4096, 20, 4, 1		; Blackman (3-term)
giWin5		ftgen		5, 0, 4096, 20, 5, 1		; Blackman-Harris (4-term)
giWin6		ftgen		6, 0, 4096, 20, 6, 1		; Gauss
giWin7		ftgen		7, 0, 4096, 20, 7, 1, 6		; Kaiser
giWin8		ftgen		8, 0, 4096, 20, 8, 1		; Rectangle
giWin9		ftgen		9, 0, 4096, 20, 9, 1		; Sync
giDisttab	ftgen		0, 0, 32768, 7, 0, 32768, 1	; for kdistribution
giCosine	ftgen		0, 0, 8193, 9, 1, 1, 90		; cosine
giPan		ftgen		0, 0, 32768, -21, 1			; for panning (random values between 0 and 1)


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


instr 1; master instrument
;;write the soundfile to the buffer (ftable) giSound
Sfile		invalue	"_Browse1"
giFile		ftgen		0, 0, 0, -1, Sfile, 0, 0, 1

;;select shape of the grain envelope and show it
kwinshape	invalue	"winshape"; 0=Hamming, 1=von Hann, 2=Bartlett, 3=Triangle, 4=Blackman-Harris,
						;5=Gauss, 6=Kaiser, 7=Rectangle, 8=Sync
kwinshape	=		kwinshape+1; correct numbers according to the ftables
		event_i	"i", 10, 0, -1, i(kwinshape)
		outvalue	"ftab", -kwinshape; graph widget shows selected window shape

;;triggers i 10 at the beginning and whenever the grain envelope has changed
gksamplepos	init		0; position of the pointer through the sample
kchanged	changed	kwinshape; sends 1 if the windowshape has changed
 if kchanged == 1 then
		event		"i", -10, 0, -1; turn off previous instance of i10
		event		"i", 10, 0, -1, kwinshape, gksamplepos; turn on new instance
 endif
endin

instr 10; performs granular synthesis
;;used parameters for the partikkel opcode
iwin		=		p4; shape of the grain window 
igksamplepos	=		p5; pointer position at the beginning
ifiltab	=		giFile; buffer to read
kspeed		invalue	"speed"; speed of reading the buffer (1=normal)
kspeed0	invalue	"speed0"; set playback speed to 0
kspeed1	invalue	"speed1"; set playback speed to 1
kgrainrate	invalue	"grainrate"; grains per second
kgrainsize	invalue	"grainsize"; length of the grains in ms
kcent		invalue	"transp"; pitch transposition in cent
kgrainamp	invalue	"gain"; volume
kdist		invalue	"dist"; distribution (0=periodic, 1=scattered)
kposrand	invalue	"posrand"; time position randomness (offset) of the read pointer in ms
kcentrand	invalue	"centrand"; transposition randomness in cents (up and down)
kpan		invalue	"pan"; panning narrow (0) to wide (1)
icosintab	=		giCosine; ftable with a cosine waveform
idisttab	=		giDisttab; ftable with values for scattered distribution 
kwaveform	= 		giFile; source waveform
imax_grains	=		200; maximum number of grains per k-period

;;speed either by slider value or by checkbox
kspeed		=		(kspeed0==1 && kspeed1==1 ? 1 : (kspeed0==1 ? 0 : (kspeed1==1 ? 1 : kspeed)))

;;unused parameters for the partikkel opcode
async		= 		0; sync input (disabled)	
kenv2amt	= 		1; use only secondary envelope
ienv2tab 	= 		iwin; grain (secondary) envelope
ienv_attack	= 		-1; default attack envelope (flat)
ienv_decay	= 		-1; default decay envelope (flat)
ksustain_amount = 		0.5; no meaning in this case (use only secondary envelope, ienv2tab)
ka_d_ratio	= 		0.5; no meaning in this case (use only secondary envelope, ienv2tab)
igainmasks	= 		-1; (default) no gain masking
ksweepshape	= 		0; no frequency sweep
iwavfreqstarttab = 		-1; default frequency sweep start
iwavfreqendtab = 		-1; default frequency sweep end
awavfm		= 		0; no FM input
ifmamptab	= 		-1; default FM scaling (=1)
kfmenv		= 		-1; default FM envelope (flat)
icosine	= 		giCosine; cosine ftable
kTrainCps	= 		kgrainrate; set trainlet cps equal to grain rate
knumpartials	= 		1; number of partials in trainlet
kchroma	= 		1; balance of partials in trainlet
krandommask	= 		0; random gain masking (disabled)
iwaveamptab	=		-1; (default) equal mix of source waveforms and no amplitude for trainlets
kwavekey	= 		1; original key for each source waveform

;get length of source wave file, needed for both transposition and time pointer
ifilen		tableng	giFile
ifildur	= 		ifilen / sr
;amplitude
kamp		= 		kgrainamp * 0dbfs; grain amplitude
;transposition
kcentrand	rand 		kcentrand; random transposition
iorig		= 		1 / ifildur; original pitch
kwavfreq	= 		iorig * cent(kcent + kcentrand)
;panning, using channel masks
		tableiw	0, 0, giPan; change index 0 ...
		tableiw	32766, 1, giPan; ... and 1 for ichannelmasks
ichannelmasks = 		giPan; ftable for panning

;;time pointer
afilposphas		phasor kspeed / ifildur, igksamplepos; in general
;generate random deviation of the time pointer
kposrandsec		= kposrand / 1000	; ms -> sec
kposrand		= kposrandsec / ifildur	; phase values (0-1)
arndpos		linrand	 kposrand	; random offset in phase values
;add random deviation to the time pointer
asamplepos		= afilposphas + arndpos; resulting phase values (0-1)
gksamplepos		downsamp	asamplepos; export pointer position 
		outvalue	"posdisp", gksamplepos

agrL, agrR	partikkel kgrainrate, kdist, giDisttab, async, kenv2amt, ienv2tab, \
		ienv_attack, ienv_decay, ksustain_amount, ka_d_ratio, kgrainsize, kamp, igainmasks, \
		kwavfreq, ksweepshape, iwavfreqstarttab, iwavfreqendtab, awavfm, \
		ifmamptab, kfmenv, icosine, kTrainCps, knumpartials, \
		kchroma, ichannelmasks, krandommask, kwaveform, kwaveform, kwaveform, kwaveform, \
		iwaveamptab, asamplepos, asamplepos, asamplepos, asamplepos, \
		kwavekey, kwavekey, kwavekey, kwavekey, imax_grains

;panning, modifying the values of ichannelmasks
imid		= 		.5; center
kleft		= 		imid - kpan/2
kright		=		imid + kpan/2
apL1, apR1	pan2		agrL, kleft
apL2, apR2	pan2		agrR, kright
aL		=		apL1 + apL2
aR		=		apR1 + apR2
		outs		aL, aR

;;show output
kdbrange	invalue	"dbrange"  ;dB range for the meters
kpeakhold	invalue	"peakhold"  ;Duration of clip indicator hold in seconds
kTrigDisp	metro		10
		ShowLED_a	"outL", aL, kTrigDisp, 1, kdbrange
		ShowLED_a	"outR", aR, kTrigDisp, 1, kdbrange
		ShowOver_a	"outLover", aL, kTrigDisp, kpeakhold
		ShowOver_a	"outRover", aR, kTrigDisp, kpeakhold
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
 <x>350</x>
 <y>45</y>
 <width>906</width>
 <height>818</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>352</y>
  <width>873</width>
  <height>399</height>
  <uuid>{e0537137-cfa6-4441-8576-3fe2ab14d60f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>GRANULAR</label>
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
  <x>9</x>
  <y>130</y>
  <width>483</width>
  <height>72</height>
  <uuid>{17717d1a-dbf5-4814-95d0-39437215af3e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label> INPUT</label>
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
  <x>475</x>
  <y>386</y>
  <width>20</width>
  <height>25</height>
  <uuid>{e0700869-2c92-400f-a0c4-4f09f4626412}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1</label>
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
  <x>288</x>
  <y>386</y>
  <width>20</width>
  <height>25</height>
  <uuid>{081bb308-dc0b-4432-ad36-17573f136ffd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0</label>
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
  <objectName>speed1</objectName>
  <x>496</x>
  <y>388</y>
  <width>20</width>
  <height>20</height>
  <uuid>{c6f473d7-2310-42c4-a9e0-c839e2037e3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>speed0</objectName>
  <x>268</x>
  <y>388</y>
  <width>20</width>
  <height>20</height>
  <uuid>{b51c9dbe-8e6c-45a1-bff0-a29e081e8561}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>speed</objectName>
  <x>303</x>
  <y>439</y>
  <width>172</width>
  <height>29</height>
  <uuid>{8346eeff-42ae-480a-a87e-a04a8bbf6263}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.580</label>
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
  <objectName>speed</objectName>
  <x>269</x>
  <y>415</y>
  <width>245</width>
  <height>28</height>
  <uuid>{06660c1a-e37b-4058-a66e-662293199f71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.57959184</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>334</x>
  <y>386</y>
  <width>119</width>
  <height>27</height>
  <uuid>{b09ff3d9-2114-43ca-8afa-06a084083c46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Playback Speed</label>
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
  <x>149</x>
  <y>683</y>
  <width>71</width>
  <height>29</height>
  <uuid>{2339c577-b179-4e25-894b-8ff7c1bfb83b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>wide</label>
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
  <x>27</x>
  <y>683</y>
  <width>71</width>
  <height>29</height>
  <uuid>{fe94abf9-4e96-4baa-8838-aa2905330e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>narrow</label>
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
  <objectName>pan</objectName>
  <x>46</x>
  <y>663</y>
  <width>152</width>
  <height>25</height>
  <uuid>{937dd04a-9dc6-4236-a5ab-08529ed68e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50657900</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>51</x>
  <y>637</y>
  <width>143</width>
  <height>27</height>
  <uuid>{6790e8b2-4f34-431e-a2a0-f6fddd51c51d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Panning</label>
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
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>452</x>
  <y>254</y>
  <width>431</width>
  <height>82</height>
  <uuid>{3a37f45c-31f6-411d-89a9-a2500d0cb3f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>2.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>383</x>
  <y>160</y>
  <width>100</width>
  <height>30</height>
  <uuid>{00d370ee-10a7-480f-a12a-ed4b140b578d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>20</x>
  <y>163</y>
  <width>360</width>
  <height>25</height>
  <uuid>{6d1afe68-fe9b-45d5-a207-af0265d40304}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>634</x>
  <y>392</y>
  <width>217</width>
  <height>28</height>
  <uuid>{1203e7e5-3b2e-498e-9eef-820f953c2e68}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Select window function ...</label>
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
  <x>648</x>
  <y>442</y>
  <width>168</width>
  <height>27</height>
  <uuid>{1832987b-e31f-4de4-b7c9-72f731ce543c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>... and see its shape</label>
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
 <bsbObject version="2" type="BSBGraph">
  <objectName>ftab</objectName>
  <x>607</x>
  <y>470</y>
  <width>264</width>
  <height>176</height>
  <uuid>{ae60ca04-b53e-4a5a-b226-358ed138c70f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-2</value>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>auto</modex>
  <modey>auto</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>winshape</objectName>
  <x>664</x>
  <y>417</y>
  <width>144</width>
  <height>24</height>
  <uuid>{347c0175-ce76-48c2-ac77-85331be89dba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Hamming</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>von Hann</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Triangle</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Blackman</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Blackman-Harris</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Gauss</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Kaiser</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Rectangle</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sync</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>676</x>
  <y>366</y>
  <width>115</width>
  <height>28</height>
  <uuid>{31b41406-2e32-495a-be42-a822c0d1c281}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Window Shape</label>
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
  <x>143</x>
  <y>518</y>
  <width>71</width>
  <height>29</height>
  <uuid>{d44230ec-63ad-498a-b665-8a4ccb7d2d5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>scattered</label>
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
  <x>21</x>
  <y>518</y>
  <width>71</width>
  <height>29</height>
  <uuid>{8042a8ed-f5c6-4748-842e-529bb1808d2d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>periodic</label>
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
  <x>271</x>
  <y>638</y>
  <width>234</width>
  <height>25</height>
  <uuid>{3ede498a-f0bc-4805-aacf-73ede037006d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Transposition Randomness (Cent)</label>
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
  <objectName>centrand</objectName>
  <x>351</x>
  <y>688</y>
  <width>81</width>
  <height>26</height>
  <uuid>{102b6f01-2310-4198-8ebc-0d5ded52e7ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.000</label>
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
  <objectName>centrand</objectName>
  <x>271</x>
  <y>661</y>
  <width>242</width>
  <height>26</height>
  <uuid>{30f0d292-88f2-46ac-af20-9a2d1afec787}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>600.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>posrand</objectName>
  <x>312</x>
  <y>522</y>
  <width>148</width>
  <height>26</height>
  <uuid>{e6c2c0a9-906f-42ce-af8b-74204b5f17be}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.000</label>
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
  <objectName>posrand</objectName>
  <x>269</x>
  <y>500</y>
  <width>248</width>
  <height>26</height>
  <uuid>{7aae7c4c-5488-4212-9d69-d7800c74b523}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>264</x>
  <y>475</y>
  <width>258</width>
  <height>27</height>
  <uuid>{e603e9ea-3ea5-4308-9f4c-ad2aa1ed7280}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Position Randomness (ms)</label>
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
  <objectName>dist</objectName>
  <x>40</x>
  <y>498</y>
  <width>152</width>
  <height>25</height>
  <uuid>{bc72340b-5d10-4976-aa8f-d222c6188757}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>45</x>
  <y>472</y>
  <width>143</width>
  <height>27</height>
  <uuid>{816ebc5f-cba8-449a-af48-355c30a25f74}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Distribution</label>
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
  <objectName>grainrate</objectName>
  <x>74</x>
  <y>438</y>
  <width>81</width>
  <height>26</height>
  <uuid>{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>86.099</label>
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
  <objectName>grainrate</objectName>
  <x>42</x>
  <y>416</y>
  <width>152</width>
  <height>25</height>
  <uuid>{02a36a56-c7bb-42b4-ad6f-cf8e450de841}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>1.00000000</minimum>
  <maximum>200.00000000</maximum>
  <value>86.09868421</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>grainsize</objectName>
  <x>73</x>
  <y>603</y>
  <width>81</width>
  <height>26</height>
  <uuid>{471f7698-cee0-4cce-b367-c32f0590dd4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>29.007</label>
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
  <objectName>grainsize</objectName>
  <x>41</x>
  <y>580</y>
  <width>152</width>
  <height>25</height>
  <uuid>{9e02285d-69f1-4e00-be8f-dfa2d8af03a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>1.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>29.00657895</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>66</x>
  <y>558</y>
  <width>101</width>
  <height>25</height>
  <uuid>{5022e21c-c236-493b-a866-39c8bb38a905}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Grainsize (ms)</label>
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
  <objectName>transp</objectName>
  <x>307</x>
  <y>603</y>
  <width>169</width>
  <height>26</height>
  <uuid>{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.000</label>
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
  <objectName>transp</objectName>
  <x>269</x>
  <y>579</y>
  <width>242</width>
  <height>25</height>
  <uuid>{18461081-9d88-4948-a7a2-f78cacc1d6bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-1200.00000000</minimum>
  <maximum>1200.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>279</x>
  <y>555</y>
  <width>235</width>
  <height>25</height>
  <uuid>{f99b1872-a1ee-4fd9-a39d-e6abc167194d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Transposition (Cent)</label>
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
  <x>47</x>
  <y>389</y>
  <width>143</width>
  <height>27</height>
  <uuid>{79559e45-cb8f-4a81-9ba5-a16fb1083771}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Grains per Second</label>
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
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>9</x>
  <y>254</y>
  <width>432</width>
  <height>82</height>
  <uuid>{c6c00efe-b5d1-4ba5-aefe-b589731dfe41}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>1.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>showdb</objectName>
  <x>171</x>
  <y>208</y>
  <width>108</width>
  <height>28</height>
  <uuid>{bdedaf7e-e1f4-4bd1-99a3-ed326f980bc2}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>208</y>
  <width>163</width>
  <height>26</height>
  <uuid>{0c0a32f8-865c-49f8-a844-57969e8c1eba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Show LED's as</label>
  <alignment>right</alignment>
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
  <x>280</x>
  <y>209</y>
  <width>120</width>
  <height>28</height>
  <uuid>{088c57ee-a211-43cb-baf9-9bf4909a1e75}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>dB-Range</label>
  <alignment>right</alignment>
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
  <objectName>dbrange</objectName>
  <x>400</x>
  <y>209</y>
  <width>61</width>
  <height>28</height>
  <uuid>{75b03faf-7718-4827-b6b0-2353c2013cfa}</uuid>
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
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>50</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>58</y>
  <width>872</width>
  <height>66</height>
  <uuid>{3a700a79-958c-4530-85db-22fd656b4243}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Granulates a stored sound. You can use either a mono or stereo soundfile (from the latter just channel 1 is used).</label>
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
  <x>9</x>
  <y>9</y>
  <width>872</width>
  <height>43</height>
  <uuid>{73f2ed52-b197-4d83-a5da-4c05557273ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>GRANULAR SYNTHESIS OF A SOUNDFILE</label>
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
  <x>499</x>
  <y>129</y>
  <width>383</width>
  <height>119</height>
  <uuid>{6a974593-2ae3-47fd-a1e7-c53a5295a823}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label> OUTPUT</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>outL</objectName>
  <x>511</x>
  <y>197</y>
  <width>335</width>
  <height>18</height>
  <uuid>{fa64908d-5557-4436-ae9d-e6c3131c1385}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.87425840</xValue>
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
  <objectName>outLover</objectName>
  <x>844</x>
  <y>197</y>
  <width>26</width>
  <height>18</height>
  <uuid>{f813f37d-8db0-4bc3-b802-1a294c716337}</uuid>
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
  <x>510</x>
  <y>164</y>
  <width>95</width>
  <height>27</height>
  <uuid>{035cb071-b24a-4ffa-b835-1065cab0d936}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Output Gain</label>
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
  <objectName>gain</objectName>
  <x>606</x>
  <y>165</y>
  <width>205</width>
  <height>24</height>
  <uuid>{e58853c0-86f8-4e0c-a0ff-e9c0f2ea2239}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>gain</objectName>
  <x>812</x>
  <y>164</y>
  <width>61</width>
  <height>27</height>
  <uuid>{b7e21e98-3040-468e-9f1f-9c71e5502b88}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>outR</objectName>
  <x>511</x>
  <y>222</y>
  <width>335</width>
  <height>18</height>
  <uuid>{e0ed741c-9b75-48b4-b91a-62e483519a08}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.92437929</xValue>
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
  <objectName>outRover</objectName>
  <x>844</x>
  <y>222</y>
  <width>26</width>
  <height>18</height>
  <uuid>{8b872a2e-b013-4c43-b10e-a7a47f8e0068}</uuid>
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
 <bsbObject version="2" type="BSBController">
  <objectName>posdisp</objectName>
  <x>608</x>
  <y>706</y>
  <width>260</width>
  <height>31</height>
  <uuid>{5c334baa-687d-4daf-8a6c-e81209a7349e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>vert55</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.19870219</xValue>
  <yValue>0.00000000</yValue>
  <type>line</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>114</r>
   <g>49</g>
   <b>234</b>
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
  <x>634</x>
  <y>669</y>
  <width>215</width>
  <height>30</height>
  <uuid>{f665fc9d-8ec8-4f3a-82da-beb4a2c65961}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Position in the soundfile</label>
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
 <objectName/>
 <x>350</x>
 <y>45</y>
 <width>906</width>
 <height>818</height>
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
WindowBounds: 350 45 906 818
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioText {10, 352} {873, 399} label 0.000000 0.00100 "" left "Lucida Grande" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder GRANULAR
ioText {9, 130} {483, 72} label 0.000000 0.00100 "" left "Lucida Grande" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder  INPUT
ioText {475, 386} {20, 25} label 1.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1
ioText {288, 386} {20, 25} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0
ioCheckbox {496, 388} {20, 20} off speed1
ioCheckbox {268, 388} {20, 20} off speed0
ioText {303, 439} {172, 29} display 0.579592 0.00100 "speed" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.580
ioSlider {269, 415} {245, 28} -2.000000 2.000000 0.579592 speed
ioText {334, 386} {119, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Playback Speed
ioText {149, 683} {71, 29} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder wide
ioText {27, 683} {71, 29} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder narrow
ioSlider {46, 663} {152, 25} 0.000000 1.000000 0.506579 pan
ioText {51, 637} {143, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Panning
ioGraph {452, 254} {431, 82} scope 2.000000 2 
ioButton {383, 160} {100, 30} value 1.000000 "_Browse1" "Open File" "/" 
ioText {20, 163} {360, 25} edit 0.000000 0.00100 "_Browse1"  "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} falsenoborder 
ioText {634, 392} {185, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Select window function ...
ioText {648, 442} {168, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ... and see its shape
ioGraph {607, 470} {264, 176} table -2.000000 1.000000 ftab
ioMenu {664, 417} {144, 24} 1 303 "Hamming,von Hann,Triangle,Blackman,Blackman-Harris,Gauss,Kaiser,Rectangle,Sync" winshape
ioText {676, 366} {115, 28} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Window Shape
ioText {143, 518} {71, 29} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder scattered
ioText {21, 518} {71, 29} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder periodic
ioText {271, 638} {234, 25} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Transposition Randomness (Cent)
ioText {351, 688} {81, 26} display 0.000000 0.00100 "centrand" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000
ioSlider {271, 661} {242, 26} 0.000000 600.000000 0.000000 centrand
ioText {312, 522} {148, 26} display 0.000000 0.00100 "posrand" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000
ioSlider {269, 500} {248, 26} 0.000000 1000.000000 0.000000 posrand
ioText {264, 475} {258, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Position Randomness (ms)
ioSlider {40, 498} {152, 25} 0.000000 1.000000 1.000000 dist
ioText {45, 472} {143, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Distribution
ioText {74, 438} {81, 26} display 86.099000 0.00100 "grainrate" right "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 86.099
ioSlider {42, 416} {152, 25} 1.000000 200.000000 86.098684 grainrate
ioText {73, 603} {81, 26} display 29.007000 0.00100 "grainsize" right "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 29.007
ioSlider {41, 580} {152, 25} 1.000000 100.000000 29.006579 grainsize
ioText {66, 558} {101, 25} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Grainsize (ms)
ioText {307, 603} {169, 26} display 0.000000 0.00100 "transp" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.000
ioSlider {269, 579} {242, 25} -1200.000000 1200.000000 0.000000 transp
ioText {279, 555} {235, 25} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Transposition (Cent)
ioText {47, 389} {143, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Grains per Second
ioGraph {9, 254} {432, 82} scope 2.000000 1 
ioMenu {171, 208} {108, 28} 1 303 "Amplitudes,dB" showdb
ioText {9, 208} {163, 26} label 0.000000 0.00100 "" right "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Show LED's as
ioText {280, 209} {120, 28} label 0.000000 0.00100 "" right "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB-Range
ioText {400, 209} {61, 28} editnum 50.000000 1.000000 "dbrange" left "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 50.000000
ioText {9, 58} {872, 66} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Granulates a stored sound. You can use either a mono or stereo soundfile (from the latter just channel 1 is used).
ioText {9, 9} {872, 43} label 0.000000 0.00100 "" center "Lucida Grande" 26 {0, 0, 0} {65280, 65280, 65280} nobackground noborder GRANULAR SYNTHESIS OF A SOUNDFILE
ioText {499, 129} {383, 119} label 0.000000 0.00100 "" left "Lucida Grande" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder  OUTPUT
ioMeter {511, 197} {335, 18} {0, 59904, 0} "outL" 0.874258 "out2_post" 0.000000 fill 1 0 mouse
ioMeter {844, 197} {26, 18} {50176, 3584, 3072} "outLover" 0.000000 "outRover" 0.000000 fill 1 0 mouse
ioText {510, 164} {95, 27} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Output Gain
ioSlider {606, 165} {205, 24} 0.000000 5.000000 1.000000 gain
ioText {812, 164} {61, 27} display 1.000000 0.00100 "gain" right "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1.000
ioMeter {511, 222} {335, 18} {0, 59904, 0} "outR" 0.924379 "out2_post" 0.000000 fill 1 0 mouse
ioMeter {844, 222} {26, 18} {50176, 3584, 3072} "outRover" 0.000000 "outRover" 0.000000 fill 1 0 mouse
ioMeter {608, 706} {260, 31} {29184, 12544, 59904} "posdisp" 0.198702 "vert55" 0.000000 line 1 0 mouse
ioText {650, 668} {185, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Position in the soundfile
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="360" y="248" width="612" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

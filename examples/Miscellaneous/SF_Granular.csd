<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

/*****GRANULAR SYNTHESIS OF A SOUNDFILE*****/
;example for CsoundQt
;written by joachim heintz (with thanks to Oeyvind Brandtsegg)
;jan 2010 / mar 2011
;please send bug reports and suggestions
;to jh at joachimheintz.de


nchnls = 2
ksmps = 32
0dbfs = 1

giWin1     ftgen      1, 0, 4096, 20, 1, 1 ; Hamming
giWin2     ftgen      2, 0, 4096, 20, 2, 1 ; von Hann
giWin3     ftgen      3, 0, 4096, 20, 3, 1 ; Triangle (Bartlett)
giWin4     ftgen      4, 0, 4096, 20, 4, 1 ; Blackman (3-term)
giWin5     ftgen      5, 0, 4096, 20, 5, 1 ; Blackman-Harris (4-term)
giWin6     ftgen      6, 0, 4096, 20, 6, 1 ; Gauss
giWin7     ftgen      7, 0, 4096, 20, 7, 1, 6 ; Kaiser
giWin8     ftgen      8, 0, 4096, 20, 8, 1 ; Rectangle
giWin9     ftgen      9, 0, 4096, 20, 9, 1 ; Sync
giSigmoRise ftgen     0, 0, 8193, 19, 0.5, 1, 270, 1 ; rising sigmoid
giSigmoFall ftgen     0, 0, 8193, 19, 0.5, 1, 90, 1 ; falling sigmoid
giExpFall  ftgen      0, 0, 8193, 5, 1, 8193, 0.00001 ; exponential decay
giDisttab  ftgen      0, 0, 32768, 7, 0, 32768, 1 ; for kdistribution
giCosine   ftgen      0, 0, 8193, 9, 1, 1, 90 ; cosine
giPan      ftgen      0, 0, 32768, -21, 1 ; for panning (random values between 0 and 1)


  opcode	ShowLED_a, 0, Sakkk
;shows an audiosignal in an outvalue channel, in dB or raw amplitudes
;Soutchan: string as name of the outvalue channel
;asig: audio signal to be shown
;kdispfreq: refresh frequency of the display (Hz)
;kdb: 1 = show as db, 0 = show as raw amplitudes (both in the range 0-1)
;kdbrange: if idb=1: which dB range is shown
Soutchan, asig, ktrig, kdb, kdbrange xin
kdispval   max_k      asig, ktrig, 1
	if kdb != 0 then
kdb        =          dbfsamp(kdispval)
kval       =          (kdbrange + kdb) / kdbrange
           else
kval       =          kdispval
	endif
	if ktrig == 1 then
           outvalue   Soutchan, kval
	endif
  endop

  opcode ShowOver_a, 0, Sakk
;shows if asig has been larger than 1 and stays khold seconds
;Soutchan: string as name of the outvalue channel
;kdispfreq: refresh frequency of the display (Hz)
Soutchan, asig, ktrig, khold xin
kon        init       0
ktim       times
kstart     init       0
kend       init       0
khold      =          (khold < .01 ? .01 : khold); avoiding too short hold times
kmax       max_k      asig, ktrig, 1
	if kon == 0 && kmax > 1 && ktrig == 1 then
kstart     =          ktim
kend       =          kstart + khold
           outvalue   Soutchan, kmax
kon        =          1
	endif
	if kon == 1 && ktim > kend && ktrig == 1 then
           outvalue   Soutchan, 0
kon        =          0
	endif
  endop


instr 1; master instrument
;;write the soundfile to the buffer (ftable) giSound
Sfile      invalue    "_Browse1"
giFile     ftgen      0, 0, 0, -1, Sfile, 0, 0, 1

;;select shape of the grain envelope and show it
kwinshape  invalue    "winshape"; 0=Hamming, 1=von Hann, 2=Bartlett, 3=Triangle, 4=Blackman-Harris,
						;5=Gauss, 6=Kaiser, 7=Rectangle, 8=Sync
kwinshape  =          kwinshape+1; correct numbers according to the ftables
           event_i    "i", 10, 0, -1, i(kwinshape)
           outvalue   "ftab", -kwinshape; graph widget shows selected window shape

;;triggers i 10 at the beginning and whenever the grain envelope has changed
gksamplepos init      0; position of the pointer through the sample
kchanged   changed    kwinshape; sends 1 if the windowshape has changed
 if kchanged == 1 then
           event      "i", -10, 0, -1; turn off previous instance of i10
           event      "i", 10, 0, -1, kwinshape, gksamplepos; turn on new instance
 endif
endin

instr 10; performs granular synthesis
;;used parameters for the partikkel opcode
iwin       =          p4; shape of the grain window
igksamplepos =        p5; pointer position at the beginning
ifiltab    =          giFile; buffer to read
kspeed     invalue    "speed"; speed of reading the buffer (1=normal)
kspeed0    invalue    "speed0"; set playback speed to 0
kspeed1    invalue    "speed1"; set playback speed to 1
kgrainrate invalue    "grainrate"; grains per second
kgrainsize invalue    "grainsize"; length of the grains in ms
ksizrandev invalue    "sizrandev" ;addition random deviation in ms
kcent      invalue    "transp"; pitch transposition in cent
kgraindb   invalue    "db"; volume
kgrainamp  =          ampdb(kgraindb)
kdist      invalue    "dist"; distribution (0=periodic, 1=scattered)
kposrand   invalue    "posrand"; time position randomness (offset) of the read pointer in ms
kcentrand  invalue    "centrand"; transposition randomness in cents (up and down)
kpan       invalue    "pan"; panning narrow (0) to wide (1)
icosintab  =          giCosine; ftable with a cosine waveform
idisttab   =          giDisttab; ftable with values for scattered distribution
kwaveform  =          giFile; source waveform
imax_grains =         200; maximum number of grains per k-period

;;speed either by slider value or by checkbox
kspeed     =          (kspeed0==1 && kspeed1==1 ? 1 : (kspeed0==1 ? 0 : (kspeed1==1 ? 1 : kspeed)))

;;unused parameters for the partikkel opcode
async      =          0; sync input (disabled)
kenv2amt   =          1; use only secondary envelope
ienv2tab   =          iwin; grain (secondary) envelope
;ienv_attack	= 		-1; default attack envelope (flat)
;ienv_decay	= 		-1; default decay envelope (flat)
ienv_attack =         giSigmoRise; grain attack shape (from table)
ienv_decay =          giSigmoFall; grain decay shape (from table)

ksustain_amount =     0.5; no meaning in this case (use only secondary envelope, ienv2tab)
ka_d_ratio =          0.5; no meaning in this case (use only secondary envelope, ienv2tab)
igainmasks =          -1; (default) no gain masking
ksweepshape =         0; no frequency sweep
iwavfreqstarttab =    -1; default frequency sweep start
iwavfreqendtab =      -1; default frequency sweep end
awavfm     =          0; no FM input
ifmamptab  =          -1; default FM scaling (=1)
kfmenv     =          -1; default FM envelope (flat)
icosine    =          giCosine; cosine ftable
kTrainCps  =          kgrainrate; set trainlet cps equal to grain rate
knumpartials =        1; number of partials in trainlet
kchroma    =          1; balance of partials in trainlet
krandommask =         0; random gain masking (disabled)
iwaveamptab =         -1; (default) equal mix of source waveforms and no amplitude for trainlets
kwavekey   =          1; original key for each source waveform

;get length of source wave file, needed for both transposition and time pointer
ifilen     tableng    giFile
ifildur    =          ifilen / sr
;grainsize
ksizrandev random     0, ksizrandev
kgrainsize =          kgrainsize + ksizrandev
;amplitude
kamp       =          kgrainamp * 0dbfs; grain amplitude
;transposition
kcentrand  rand       kcentrand; random transposition
iorig      =          1 / ifildur; original pitch
kwavfreq   =          iorig * cent(kcent + kcentrand)
;panning, using channel masks
           tableiw    0, 0, giPan; change index 0 ...
           tableiw    32766, 1, giPan; ... and 1 for ichannelmasks
ichannelmasks =       giPan; ftable for panning

;;time pointer
afilposphas phasor    kspeed / ifildur, igksamplepos; in general
;generate random deviation of the time pointer
kposrandsec =         kposrand / 1000 ; ms -> sec
kposrand   =          kposrandsec / ifildur ; phase values (0-1)
arndpos1   random     0, kposrand ; random offset in phase values
arndpos2   random     0, kposrand
arndpos3   random     0, kposrand
arndpos4   random     0, kposrand
;add random deviation to the time pointer and make sure not to wrap around
asamplepos1 mirror    afilposphas+arndpos1, 0, 1
asamplepos2 mirror    afilposphas+arndpos2, 0, 1
asamplepos3 mirror    afilposphas+arndpos3, 0, 1
asamplepos4 mirror    afilposphas+arndpos4, 0, 1


gksamplepos downsamp  asamplepos1; export pointer position
           outvalue   "posdisp", gksamplepos

agrL, agrR partikkel  kgrainrate, kdist, giDisttab, async, kenv2amt, ienv2tab, \
ienv_attack, ienv_decay, ksustain_amount, ka_d_ratio, kgrainsize, kamp, igainmasks, \
kwavfreq, ksweepshape, iwavfreqstarttab, iwavfreqendtab, awavfm, \
ifmamptab, kfmenv, icosine, kTrainCps, knumpartials, \
kchroma, ichannelmasks, krandommask, kwaveform, kwaveform, kwaveform, kwaveform, \
iwaveamptab, asamplepos1, asamplepos2, asamplepos3, asamplepos4, \
kwavekey, kwavekey, kwavekey, kwavekey, imax_grains

;panning, modifying the values of ichannelmasks
imid       =          .5; center
kleft      =          imid - kpan/2
kright     =          imid + kpan/2
apL1, apR1 pan2       agrL, kleft
apL2, apR2 pan2       agrR, kright
aL         =          apL1 + apL2
aR         =          apR1 + apR2
           outs       aL, aR

;;show output
kdbrange   invalue    "dbrange" ;dB range for the meters
kTrigDisp  metro      10
           ShowLED_a  "outL", aL, kTrigDisp, 1, kdbrange
           ShowLED_a  "outR", aR, kTrigDisp, 1, kdbrange
           ShowOver_a "outLover", aL, kTrigDisp, 2
           ShowOver_a "outRover", aR, kTrigDisp, 2
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
 <x>64</x>
 <y>2</y>
 <width>912</width>
 <height>757</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>314</y>
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
  <y>91</y>
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
  <x>466</x>
  <y>349</y>
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
  <x>279</x>
  <y>349</y>
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
  <x>487</x>
  <y>351</y>
  <width>20</width>
  <height>20</height>
  <uuid>{c6f473d7-2310-42c4-a9e0-c839e2037e3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>speed0</objectName>
  <x>259</x>
  <y>351</y>
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
  <x>294</x>
  <y>402</y>
  <width>172</width>
  <height>29</height>
  <uuid>{8346eeff-42ae-480a-a87e-a04a8bbf6263}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.139</label>
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
  <x>260</x>
  <y>378</y>
  <width>245</width>
  <height>28</height>
  <uuid>{06660c1a-e37b-4058-a66e-662293199f71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.13877551</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>325</x>
  <y>349</y>
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
  <x>140</x>
  <y>646</y>
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
  <x>18</x>
  <y>646</y>
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
  <x>12</x>
  <y>625</y>
  <width>200</width>
  <height>25</height>
  <uuid>{937dd04a-9dc6-4236-a5ab-08529ed68e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>42</x>
  <y>600</y>
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
  <x>692</x>
  <y>216</y>
  <width>190</width>
  <height>82</height>
  <uuid>{3a37f45c-31f6-411d-89a9-a2500d0cb3f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
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
  <y>121</y>
  <width>100</width>
  <height>30</height>
  <uuid>{00d370ee-10a7-480f-a12a-ed4b140b578d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>fox.wav</stringvalue>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>20</x>
  <y>124</y>
  <width>360</width>
  <height>25</height>
  <uuid>{6d1afe68-fe9b-45d5-a207-af0265d40304}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>fox.wav</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>625</x>
  <y>355</y>
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
  <x>639</x>
  <y>405</y>
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
  <x>598</x>
  <y>433</y>
  <width>264</width>
  <height>176</height>
  <uuid>{ae60ca04-b53e-4a5a-b226-358ed138c70f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>-9</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>winshape</objectName>
  <x>655</x>
  <y>380</y>
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
  <selectedIndex>8</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>667</x>
  <y>329</y>
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
  <x>134</x>
  <y>481</y>
  <width>89</width>
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
  <x>12</x>
  <y>481</y>
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
  <x>262</x>
  <y>601</y>
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
  <x>342</x>
  <y>651</y>
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
  <x>262</x>
  <y>624</y>
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
  <x>259</x>
  <y>485</y>
  <width>65</width>
  <height>25</height>
  <uuid>{e6c2c0a9-906f-42ce-af8b-74204b5f17be}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>posrand</objectName>
  <x>260</x>
  <y>463</y>
  <width>248</width>
  <height>26</height>
  <uuid>{7aae7c4c-5488-4212-9d69-d7800c74b523}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>255</x>
  <y>438</y>
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
  <x>14</x>
  <y>459</y>
  <width>200</width>
  <height>25</height>
  <uuid>{bc72340b-5d10-4976-aa8f-d222c6188757}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>36</x>
  <y>435</y>
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
  <x>14</x>
  <y>401</y>
  <width>81</width>
  <height>26</height>
  <uuid>{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>100.000</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>grainrate</objectName>
  <x>14</x>
  <y>378</y>
  <width>200</width>
  <height>25</height>
  <uuid>{02a36a56-c7bb-42b4-ad6f-cf8e450de841}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>200.00000000</maximum>
  <value>100.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>grainsize</objectName>
  <x>24</x>
  <y>570</y>
  <width>81</width>
  <height>26</height>
  <uuid>{471f7698-cee0-4cce-b367-c32f0590dd4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>100.000</label>
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
  <x>12</x>
  <y>545</y>
  <width>128</width>
  <height>27</height>
  <uuid>{9e02285d-69f1-4e00-be8f-dfa2d8af03a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>200.00000000</maximum>
  <value>100.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>520</y>
  <width>128</width>
  <height>26</height>
  <uuid>{5022e21c-c236-493b-a866-39c8bb38a905}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grainsize (ms)</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>transp</objectName>
  <x>298</x>
  <y>566</y>
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
  <x>260</x>
  <y>542</y>
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
  <x>270</x>
  <y>518</y>
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
  <x>38</x>
  <y>352</y>
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
  <x>498</x>
  <y>216</y>
  <width>190</width>
  <height>82</height>
  <uuid>{c6c00efe-b5d1-4ba5-aefe-b589731dfe41}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
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
  <x>280</x>
  <y>170</y>
  <width>75</width>
  <height>26</height>
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
  <x>175</x>
  <y>170</y>
  <width>106</width>
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
  <x>355</x>
  <y>170</y>
  <width>76</width>
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
  <x>430</x>
  <y>170</y>
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
  <height>29</height>
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
  <y>90</y>
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
  <y>158</y>
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
  <xValue>0.58392580</xValue>
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
  <y>158</y>
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
  <y>125</y>
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
  <objectName>db</objectName>
  <x>606</x>
  <y>126</y>
  <width>205</width>
  <height>24</height>
  <uuid>{e58853c0-86f8-4e0c-a0ff-e9c0f2ea2239}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-60.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>-20.16585350</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db</objectName>
  <x>812</x>
  <y>125</y>
  <width>42</width>
  <height>25</height>
  <uuid>{b7e21e98-3040-468e-9f1f-9c71e5502b88}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-20.166</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>outR</objectName>
  <x>511</x>
  <y>183</y>
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
  <xValue>0.58392580</xValue>
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
  <y>183</y>
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
  <x>599</x>
  <y>669</y>
  <width>260</width>
  <height>31</height>
  <uuid>{5c334baa-687d-4daf-8a6c-e81209a7349e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>vert55</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.06342077</xValue>
  <yValue>0.00000000</yValue>
  <type>line</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
  <x>625</x>
  <y>632</y>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>137</x>
  <y>518</y>
  <width>112</width>
  <height>49</height>
  <uuid>{26ba043c-d257-4d0f-86f3-4af5d01cdab1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>plus random deviation</label>
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
  <objectName>sizrandev</objectName>
  <x>158</x>
  <y>567</y>
  <width>63</width>
  <height>26</height>
  <uuid>{9808aaf4-bd15-4400-a22f-f858fdadb810}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
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
  <resolution>0.10000000</resolution>
  <minimum>0</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>9</x>
  <y>169</y>
  <width>58</width>
  <height>29</height>
  <uuid>{87b80b9f-536f-47f4-8a45-2e677562611f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</stringvalue>
  <text>Start</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Stop</objectName>
  <x>73</x>
  <y>169</y>
  <width>58</width>
  <height>29</height>
  <uuid>{6df984e2-620b-4f41-b510-70890fd7284c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</stringvalue>
  <text>Stop</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>852</x>
  <y>124</y>
  <width>30</width>
  <height>27</height>
  <uuid>{a5e4c33e-ed37-41e1-a6c5-4a6ca04b592c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>dB</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>204</y>
  <width>486</width>
  <height>105</height>
  <uuid>{75ff4be9-8cc2-43e5-bfe9-74d5e5e77473}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>PRESETS</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>_SetPresetIndex</objectName>
  <x>15</x>
  <y>233</y>
  <width>47</width>
  <height>26</height>
  <uuid>{b00b7ada-e33c-40f3-985c-02844e9bb94f}</uuid>
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
  <minimum>0</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_GetPresetName</objectName>
  <x>12</x>
  <y>259</y>
  <width>121</width>
  <height>49</height>
  <uuid>{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>natural</label>
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
  <borderradius>0</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>134</x>
  <y>205</y>
  <width>362</width>
  <height>102</height>
  <uuid>{2759d324-5f3d-4b13-80ac-194638a7141c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Combination of the Parameters depend both on your ideas and on the qualities of the sound you are using. The presets here show some possibilities for a sound which can be downloaded here: 
http://joachimheintz.de/soft/softsamps/BratscheMono.wav</label>
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
  <x>321</x>
  <y>485</y>
  <width>159</width>
  <height>25</height>
  <uuid>{9c73c07a-58aa-4930-975e-08f26956a7e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>set larger values here</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>posrand</objectName>
  <x>478</x>
  <y>485</y>
  <width>63</width>
  <height>26</height>
  <uuid>{df284c15-f1c7-4108-82ec-db829ff67323}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
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
  <minimum>0</minimum>
  <maximum>100000</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>73</x>
  <y>404</y>
  <width>97</width>
  <height>24</height>
  <uuid>{f60618bc-d565-4ee9-b262-dfe69e0e9e9e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>or set here</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>grainrate</objectName>
  <x>169</x>
  <y>404</y>
  <width>63</width>
  <height>26</height>
  <uuid>{a04e2aaa-8c72-49e4-ac27-a48d1b4d19dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
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
  <minimum>0</minimum>
  <maximum>100000</maximum>
  <randomizable group="0">false</randomizable>
  <value>100</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>676</y>
  <width>570</width>
  <height>34</height>
  <uuid>{27ccabd3-8bd4-4f2b-a798-c34a9314290b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Note that the actual grain size is smaller than the value above because of multiple enveloping.</label>
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
</bsbPanel>
<bsbPresets>
<preset name="natural" number="1" >
<value id="{c6f473d7-2310-42c4-a9e0-c839e2037e3f}" mode="1" >1.00000000</value>
<value id="{b51c9dbe-8e6c-45a1-bff0-a29e081e8561}" mode="1" >0.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="1" >0.13900000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="4" >0.139</value>
<value id="{06660c1a-e37b-4058-a66e-662293199f71}" mode="1" >0.13877551</value>
<value id="{937dd04a-9dc6-4236-a5ab-08529ed68e86}" mode="1" >0.00000000</value>
<value id="{3a37f45c-31f6-411d-89a9-a2500d0cb3f5}" mode="1" >2.00000000</value>
<value id="{00d370ee-10a7-480f-a12a-ed4b140b578d}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{6d1afe68-fe9b-45d5-a207-af0265d40304}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{ae60ca04-b53e-4a5a-b226-358ed138c70f}" mode="1" >-9.00000000</value>
<value id="{347c0175-ce76-48c2-ac77-85331be89dba}" mode="1" >8.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="1" >0.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="4" >0.000</value>
<value id="{30f0d292-88f2-46ac-af20-9a2d1afec787}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="4" >0.000</value>
<value id="{7aae7c4c-5488-4212-9d69-d7800c74b523}" mode="1" >0.00000000</value>
<value id="{bc72340b-5d10-4976-aa8f-d222c6188757}" mode="1" >0.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="1" >100.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="4" >100.000</value>
<value id="{02a36a56-c7bb-42b4-ad6f-cf8e450de841}" mode="1" >100.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="1" >100.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="4" >100.000</value>
<value id="{9e02285d-69f1-4e00-be8f-dfa2d8af03a6}" mode="1" >100.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="1" >0.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="4" >0.000</value>
<value id="{18461081-9d88-4948-a7a2-f78cacc1d6bd}" mode="1" >0.00000000</value>
<value id="{c6c00efe-b5d1-4ba5-aefe-b589731dfe41}" mode="1" >1.00000000</value>
<value id="{bdedaf7e-e1f4-4bd1-99a3-ed326f980bc2}" mode="1" >1.00000000</value>
<value id="{75b03faf-7718-4827-b6b0-2353c2013cfa}" mode="1" >50.00000000</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="1" >0.74160630</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="2" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="1" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="2" >0.00000000</value>
<value id="{e58853c0-86f8-4e0c-a0ff-e9c0f2ea2239}" mode="1" >-20.16585350</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="1" >-20.16585350</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="4" >-20.166</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="1" >0.74160630</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="2" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="1" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="2" >0.00000000</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="1" >0.10693227</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="2" >0.00000000</value>
<value id="{9808aaf4-bd15-4400-a22f-f858fdadb810}" mode="1" >0.00000000</value>
<value id="{87b80b9f-536f-47f4-8a45-2e677562611f}" mode="4" >0</value>
<value id="{6df984e2-620b-4f41-b510-70890fd7284c}" mode="4" >0</value>
<value id="{b00b7ada-e33c-40f3-985c-02844e9bb94f}" mode="1" >1.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="1" >0.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="4" >Max</value>
<value id="{df284c15-f1c7-4108-82ec-db829ff67323}" mode="1" >0.00000000</value>
<value id="{a04e2aaa-8c72-49e4-ac27-a48d1b4d19dc}" mode="1" >100.00000000</value>
</preset>
<preset name="natural time strech" number="2" >
<value id="{c6f473d7-2310-42c4-a9e0-c839e2037e3f}" mode="1" >0.00000000</value>
<value id="{b51c9dbe-8e6c-45a1-bff0-a29e081e8561}" mode="1" >0.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="1" >0.13900000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="4" >0.139</value>
<value id="{06660c1a-e37b-4058-a66e-662293199f71}" mode="1" >0.13877551</value>
<value id="{937dd04a-9dc6-4236-a5ab-08529ed68e86}" mode="1" >0.15000001</value>
<value id="{3a37f45c-31f6-411d-89a9-a2500d0cb3f5}" mode="1" >2.00000000</value>
<value id="{00d370ee-10a7-480f-a12a-ed4b140b578d}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{6d1afe68-fe9b-45d5-a207-af0265d40304}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{ae60ca04-b53e-4a5a-b226-358ed138c70f}" mode="1" >-9.00000000</value>
<value id="{347c0175-ce76-48c2-ac77-85331be89dba}" mode="1" >8.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="1" >0.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="4" >0.000</value>
<value id="{30f0d292-88f2-46ac-af20-9a2d1afec787}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="1" >1.77419353</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="4" >1.774</value>
<value id="{7aae7c4c-5488-4212-9d69-d7800c74b523}" mode="1" >1.77419353</value>
<value id="{bc72340b-5d10-4976-aa8f-d222c6188757}" mode="1" >0.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="1" >200.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="4" >200.000</value>
<value id="{02a36a56-c7bb-42b4-ad6f-cf8e450de841}" mode="1" >200.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="1" >100.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="4" >100.000</value>
<value id="{9e02285d-69f1-4e00-be8f-dfa2d8af03a6}" mode="1" >100.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="1" >0.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="4" >0.000</value>
<value id="{18461081-9d88-4948-a7a2-f78cacc1d6bd}" mode="1" >0.00000000</value>
<value id="{c6c00efe-b5d1-4ba5-aefe-b589731dfe41}" mode="1" >1.00000000</value>
<value id="{bdedaf7e-e1f4-4bd1-99a3-ed326f980bc2}" mode="1" >1.00000000</value>
<value id="{75b03faf-7718-4827-b6b0-2353c2013cfa}" mode="1" >50.00000000</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="1" >0.95380324</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="2" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="1" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="2" >0.00000000</value>
<value id="{e58853c0-86f8-4e0c-a0ff-e9c0f2ea2239}" mode="1" >-20.16585350</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="1" >-20.16585350</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="4" >-20.166</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="1" >0.94774020</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="2" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="1" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="2" >0.00000000</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="1" >0.35033330</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="2" >0.00000000</value>
<value id="{9808aaf4-bd15-4400-a22f-f858fdadb810}" mode="1" >10.00000000</value>
<value id="{87b80b9f-536f-47f4-8a45-2e677562611f}" mode="4" >0</value>
<value id="{6df984e2-620b-4f41-b510-70890fd7284c}" mode="4" >0</value>
<value id="{b00b7ada-e33c-40f3-985c-02844e9bb94f}" mode="1" >1.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="1" >0.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="4" >Max</value>
<value id="{df284c15-f1c7-4108-82ec-db829ff67323}" mode="1" >1.77419353</value>
<value id="{a04e2aaa-8c72-49e4-ac27-a48d1b4d19dc}" mode="1" >200.00000000</value>
</preset>
<preset name="natural freeze" number="3" >
<value id="{c6f473d7-2310-42c4-a9e0-c839e2037e3f}" mode="1" >0.00000000</value>
<value id="{b51c9dbe-8e6c-45a1-bff0-a29e081e8561}" mode="1" >1.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="1" >0.13900000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="4" >0.139</value>
<value id="{06660c1a-e37b-4058-a66e-662293199f71}" mode="1" >0.13877551</value>
<value id="{937dd04a-9dc6-4236-a5ab-08529ed68e86}" mode="1" >0.00000000</value>
<value id="{3a37f45c-31f6-411d-89a9-a2500d0cb3f5}" mode="1" >2.00000000</value>
<value id="{00d370ee-10a7-480f-a12a-ed4b140b578d}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{6d1afe68-fe9b-45d5-a207-af0265d40304}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{ae60ca04-b53e-4a5a-b226-358ed138c70f}" mode="1" >-9.00000000</value>
<value id="{347c0175-ce76-48c2-ac77-85331be89dba}" mode="1" >8.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="1" >0.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="4" >0.000</value>
<value id="{30f0d292-88f2-46ac-af20-9a2d1afec787}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="1" >5.32258081</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="4" >5.323</value>
<value id="{7aae7c4c-5488-4212-9d69-d7800c74b523}" mode="1" >5.32258081</value>
<value id="{bc72340b-5d10-4976-aa8f-d222c6188757}" mode="1" >0.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="1" >200.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="4" >200.000</value>
<value id="{02a36a56-c7bb-42b4-ad6f-cf8e450de841}" mode="1" >200.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="1" >100.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="4" >100.000</value>
<value id="{9e02285d-69f1-4e00-be8f-dfa2d8af03a6}" mode="1" >100.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="1" >0.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="4" >0.000</value>
<value id="{18461081-9d88-4948-a7a2-f78cacc1d6bd}" mode="1" >0.00000000</value>
<value id="{c6c00efe-b5d1-4ba5-aefe-b589731dfe41}" mode="1" >1.00000000</value>
<value id="{bdedaf7e-e1f4-4bd1-99a3-ed326f980bc2}" mode="1" >1.00000000</value>
<value id="{75b03faf-7718-4827-b6b0-2353c2013cfa}" mode="1" >50.00000000</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="1" >0.86477876</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="2" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="1" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="2" >0.00000000</value>
<value id="{e58853c0-86f8-4e0c-a0ff-e9c0f2ea2239}" mode="1" >-20.16585350</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="1" >-20.16585350</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="4" >-20.166</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="1" >0.86477876</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="2" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="1" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="2" >0.00000000</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="1" >0.21293312</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="2" >0.00000000</value>
<value id="{9808aaf4-bd15-4400-a22f-f858fdadb810}" mode="1" >10.00000000</value>
<value id="{87b80b9f-536f-47f4-8a45-2e677562611f}" mode="4" >0</value>
<value id="{6df984e2-620b-4f41-b510-70890fd7284c}" mode="4" >0</value>
<value id="{b00b7ada-e33c-40f3-985c-02844e9bb94f}" mode="1" >1.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="1" >0.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="4" >Max</value>
<value id="{df284c15-f1c7-4108-82ec-db829ff67323}" mode="1" >5.32258081</value>
<value id="{a04e2aaa-8c72-49e4-ac27-a48d1b4d19dc}" mode="1" >200.00000000</value>
</preset>
<preset name="time compress" number="4" >
<value id="{c6f473d7-2310-42c4-a9e0-c839e2037e3f}" mode="1" >0.00000000</value>
<value id="{b51c9dbe-8e6c-45a1-bff0-a29e081e8561}" mode="1" >0.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="1" >2.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="4" >2.000</value>
<value id="{06660c1a-e37b-4058-a66e-662293199f71}" mode="1" >2.00000000</value>
<value id="{937dd04a-9dc6-4236-a5ab-08529ed68e86}" mode="1" >0.00000000</value>
<value id="{3a37f45c-31f6-411d-89a9-a2500d0cb3f5}" mode="1" >2.00000000</value>
<value id="{00d370ee-10a7-480f-a12a-ed4b140b578d}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{6d1afe68-fe9b-45d5-a207-af0265d40304}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{ae60ca04-b53e-4a5a-b226-358ed138c70f}" mode="1" >-9.00000000</value>
<value id="{347c0175-ce76-48c2-ac77-85331be89dba}" mode="1" >8.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="1" >0.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="4" >0.000</value>
<value id="{30f0d292-88f2-46ac-af20-9a2d1afec787}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="1" >2.78225803</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="4" >2.782</value>
<value id="{7aae7c4c-5488-4212-9d69-d7800c74b523}" mode="1" >2.78225803</value>
<value id="{bc72340b-5d10-4976-aa8f-d222c6188757}" mode="1" >0.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="1" >200.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="4" >200.000</value>
<value id="{02a36a56-c7bb-42b4-ad6f-cf8e450de841}" mode="1" >200.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="1" >200.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="4" >200.000</value>
<value id="{9e02285d-69f1-4e00-be8f-dfa2d8af03a6}" mode="1" >200.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="1" >0.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="4" >0.000</value>
<value id="{18461081-9d88-4948-a7a2-f78cacc1d6bd}" mode="1" >0.00000000</value>
<value id="{c6c00efe-b5d1-4ba5-aefe-b589731dfe41}" mode="1" >1.00000000</value>
<value id="{bdedaf7e-e1f4-4bd1-99a3-ed326f980bc2}" mode="1" >1.00000000</value>
<value id="{75b03faf-7718-4827-b6b0-2353c2013cfa}" mode="1" >50.00000000</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="1" >0.88569182</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="2" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="1" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="2" >0.00000000</value>
<value id="{e58853c0-86f8-4e0c-a0ff-e9c0f2ea2239}" mode="1" >-23.44390297</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="1" >-23.44390297</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="4" >-23.444</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="1" >0.88569182</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="2" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="1" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="2" >0.00000000</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="1" >0.46802402</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="2" >0.00000000</value>
<value id="{9808aaf4-bd15-4400-a22f-f858fdadb810}" mode="1" >10.00000000</value>
<value id="{87b80b9f-536f-47f4-8a45-2e677562611f}" mode="4" >0</value>
<value id="{6df984e2-620b-4f41-b510-70890fd7284c}" mode="4" >0</value>
<value id="{b00b7ada-e33c-40f3-985c-02844e9bb94f}" mode="1" >1.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="1" >0.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="4" >Max</value>
<value id="{df284c15-f1c7-4108-82ec-db829ff67323}" mode="1" >2.78225803</value>
<value id="{a04e2aaa-8c72-49e4-ac27-a48d1b4d19dc}" mode="1" >200.00000000</value>
</preset>
<preset name="medium granulated" number="5" >
<value id="{c6f473d7-2310-42c4-a9e0-c839e2037e3f}" mode="1" >1.00000000</value>
<value id="{b51c9dbe-8e6c-45a1-bff0-a29e081e8561}" mode="1" >0.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="1" >2.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="4" >2.000</value>
<value id="{06660c1a-e37b-4058-a66e-662293199f71}" mode="1" >2.00000000</value>
<value id="{937dd04a-9dc6-4236-a5ab-08529ed68e86}" mode="1" >1.00000000</value>
<value id="{3a37f45c-31f6-411d-89a9-a2500d0cb3f5}" mode="1" >2.00000000</value>
<value id="{00d370ee-10a7-480f-a12a-ed4b140b578d}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{6d1afe68-fe9b-45d5-a207-af0265d40304}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{ae60ca04-b53e-4a5a-b226-358ed138c70f}" mode="1" >-9.00000000</value>
<value id="{347c0175-ce76-48c2-ac77-85331be89dba}" mode="1" >8.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="1" >0.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="4" >0.000</value>
<value id="{30f0d292-88f2-46ac-af20-9a2d1afec787}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="4" >0.000</value>
<value id="{7aae7c4c-5488-4212-9d69-d7800c74b523}" mode="1" >0.00000000</value>
<value id="{bc72340b-5d10-4976-aa8f-d222c6188757}" mode="1" >1.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="1" >164.17999268</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="4" >164.180</value>
<value id="{02a36a56-c7bb-42b4-ad6f-cf8e450de841}" mode="1" >164.17999268</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="1" >47.64062500</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="4" >47.641</value>
<value id="{9e02285d-69f1-4e00-be8f-dfa2d8af03a6}" mode="1" >47.64062500</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="1" >0.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="4" >0.000</value>
<value id="{18461081-9d88-4948-a7a2-f78cacc1d6bd}" mode="1" >0.00000000</value>
<value id="{c6c00efe-b5d1-4ba5-aefe-b589731dfe41}" mode="1" >1.00000000</value>
<value id="{bdedaf7e-e1f4-4bd1-99a3-ed326f980bc2}" mode="1" >1.00000000</value>
<value id="{75b03faf-7718-4827-b6b0-2353c2013cfa}" mode="1" >50.00000000</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="1" >0.70957154</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="2" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="1" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="2" >0.00000000</value>
<value id="{e58853c0-86f8-4e0c-a0ff-e9c0f2ea2239}" mode="1" >-23.44390297</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="1" >-23.44390297</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="4" >-23.444</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="1" >0.70485604</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="2" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="1" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="2" >0.00000000</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="1" >0.38639462</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="2" >0.00000000</value>
<value id="{9808aaf4-bd15-4400-a22f-f858fdadb810}" mode="1" >10.00000000</value>
<value id="{87b80b9f-536f-47f4-8a45-2e677562611f}" mode="4" >0</value>
<value id="{6df984e2-620b-4f41-b510-70890fd7284c}" mode="4" >0</value>
<value id="{b00b7ada-e33c-40f3-985c-02844e9bb94f}" mode="1" >1.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="1" >0.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="4" >Max</value>
<value id="{df284c15-f1c7-4108-82ec-db829ff67323}" mode="1" >0.00000000</value>
<value id="{a04e2aaa-8c72-49e4-ac27-a48d1b4d19dc}" mode="1" >164.17999268</value>
</preset>
<preset name="short grains" number="6" >
<value id="{c6f473d7-2310-42c4-a9e0-c839e2037e3f}" mode="1" >1.00000000</value>
<value id="{b51c9dbe-8e6c-45a1-bff0-a29e081e8561}" mode="1" >0.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="1" >2.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="4" >2.000</value>
<value id="{06660c1a-e37b-4058-a66e-662293199f71}" mode="1" >2.00000000</value>
<value id="{937dd04a-9dc6-4236-a5ab-08529ed68e86}" mode="1" >1.00000000</value>
<value id="{3a37f45c-31f6-411d-89a9-a2500d0cb3f5}" mode="1" >2.00000000</value>
<value id="{00d370ee-10a7-480f-a12a-ed4b140b578d}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{6d1afe68-fe9b-45d5-a207-af0265d40304}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{ae60ca04-b53e-4a5a-b226-358ed138c70f}" mode="1" >-9.00000000</value>
<value id="{347c0175-ce76-48c2-ac77-85331be89dba}" mode="1" >8.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="1" >0.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="4" >0.000</value>
<value id="{30f0d292-88f2-46ac-af20-9a2d1afec787}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="4" >0.000</value>
<value id="{7aae7c4c-5488-4212-9d69-d7800c74b523}" mode="1" >0.00000000</value>
<value id="{bc72340b-5d10-4976-aa8f-d222c6188757}" mode="1" >1.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="1" >300.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="4" >300.000</value>
<value id="{02a36a56-c7bb-42b4-ad6f-cf8e450de841}" mode="1" >200.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="1" >16.54687500</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="4" >16.547</value>
<value id="{9e02285d-69f1-4e00-be8f-dfa2d8af03a6}" mode="1" >16.54687500</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="1" >0.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="4" >0.000</value>
<value id="{18461081-9d88-4948-a7a2-f78cacc1d6bd}" mode="1" >0.00000000</value>
<value id="{c6c00efe-b5d1-4ba5-aefe-b589731dfe41}" mode="1" >1.00000000</value>
<value id="{bdedaf7e-e1f4-4bd1-99a3-ed326f980bc2}" mode="1" >1.00000000</value>
<value id="{75b03faf-7718-4827-b6b0-2353c2013cfa}" mode="1" >50.00000000</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="1" >0.58902609</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="2" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="1" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="2" >0.00000000</value>
<value id="{e58853c0-86f8-4e0c-a0ff-e9c0f2ea2239}" mode="1" >-23.44390297</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="1" >-23.44390297</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="4" >-23.444</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="1" >0.59866405</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="2" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="1" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="2" >0.00000000</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="1" >0.14967759</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="2" >0.00000000</value>
<value id="{9808aaf4-bd15-4400-a22f-f858fdadb810}" mode="1" >1.00000000</value>
<value id="{87b80b9f-536f-47f4-8a45-2e677562611f}" mode="4" >0</value>
<value id="{6df984e2-620b-4f41-b510-70890fd7284c}" mode="4" >0</value>
<value id="{b00b7ada-e33c-40f3-985c-02844e9bb94f}" mode="1" >1.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="1" >0.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="4" >Max</value>
<value id="{df284c15-f1c7-4108-82ec-db829ff67323}" mode="1" >0.00000000</value>
<value id="{a04e2aaa-8c72-49e4-ac27-a48d1b4d19dc}" mode="1" >300.00000000</value>
</preset>
<preset name="position grain cloud" number="7" >
<value id="{c6f473d7-2310-42c4-a9e0-c839e2037e3f}" mode="1" >1.00000000</value>
<value id="{b51c9dbe-8e6c-45a1-bff0-a29e081e8561}" mode="1" >0.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="1" >0.22040816</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="4" >0.220</value>
<value id="{06660c1a-e37b-4058-a66e-662293199f71}" mode="1" >0.22040816</value>
<value id="{937dd04a-9dc6-4236-a5ab-08529ed68e86}" mode="1" >1.00000000</value>
<value id="{3a37f45c-31f6-411d-89a9-a2500d0cb3f5}" mode="1" >2.00000000</value>
<value id="{00d370ee-10a7-480f-a12a-ed4b140b578d}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{6d1afe68-fe9b-45d5-a207-af0265d40304}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{ae60ca04-b53e-4a5a-b226-358ed138c70f}" mode="1" >-9.00000000</value>
<value id="{347c0175-ce76-48c2-ac77-85331be89dba}" mode="1" >8.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="1" >0.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="4" >0.000</value>
<value id="{30f0d292-88f2-46ac-af20-9a2d1afec787}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="1" >1000.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="4" >1000.000</value>
<value id="{7aae7c4c-5488-4212-9d69-d7800c74b523}" mode="1" >10.00000000</value>
<value id="{bc72340b-5d10-4976-aa8f-d222c6188757}" mode="1" >1.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="1" >300.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="4" >300.000</value>
<value id="{02a36a56-c7bb-42b4-ad6f-cf8e450de841}" mode="1" >200.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="1" >16.54687500</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="4" >16.547</value>
<value id="{9e02285d-69f1-4e00-be8f-dfa2d8af03a6}" mode="1" >16.54687500</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="1" >0.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="4" >0.000</value>
<value id="{18461081-9d88-4948-a7a2-f78cacc1d6bd}" mode="1" >0.00000000</value>
<value id="{c6c00efe-b5d1-4ba5-aefe-b589731dfe41}" mode="1" >1.00000000</value>
<value id="{bdedaf7e-e1f4-4bd1-99a3-ed326f980bc2}" mode="1" >1.00000000</value>
<value id="{75b03faf-7718-4827-b6b0-2353c2013cfa}" mode="1" >50.00000000</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="1" >0.69184899</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="2" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="1" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="2" >0.00000000</value>
<value id="{e58853c0-86f8-4e0c-a0ff-e9c0f2ea2239}" mode="1" >-23.44390297</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="1" >-23.44390297</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="4" >-23.444</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="1" >0.60557264</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="2" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="1" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="2" >0.00000000</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="1" >0.64298904</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="2" >0.00000000</value>
<value id="{9808aaf4-bd15-4400-a22f-f858fdadb810}" mode="1" >1.00000000</value>
<value id="{87b80b9f-536f-47f4-8a45-2e677562611f}" mode="4" >0</value>
<value id="{6df984e2-620b-4f41-b510-70890fd7284c}" mode="4" >0</value>
<value id="{b00b7ada-e33c-40f3-985c-02844e9bb94f}" mode="1" >1.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="1" >0.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="4" >Max</value>
<value id="{df284c15-f1c7-4108-82ec-db829ff67323}" mode="1" >1000.00000000</value>
<value id="{a04e2aaa-8c72-49e4-ac27-a48d1b4d19dc}" mode="1" >300.00000000</value>
</preset>
<preset name="transposition grain cloud" number="8" >
<value id="{c6f473d7-2310-42c4-a9e0-c839e2037e3f}" mode="1" >1.00000000</value>
<value id="{b51c9dbe-8e6c-45a1-bff0-a29e081e8561}" mode="1" >0.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="1" >0.22040816</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="4" >0.220</value>
<value id="{06660c1a-e37b-4058-a66e-662293199f71}" mode="1" >0.22040816</value>
<value id="{937dd04a-9dc6-4236-a5ab-08529ed68e86}" mode="1" >1.00000000</value>
<value id="{3a37f45c-31f6-411d-89a9-a2500d0cb3f5}" mode="1" >2.00000000</value>
<value id="{00d370ee-10a7-480f-a12a-ed4b140b578d}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{6d1afe68-fe9b-45d5-a207-af0265d40304}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{ae60ca04-b53e-4a5a-b226-358ed138c70f}" mode="1" >-9.00000000</value>
<value id="{347c0175-ce76-48c2-ac77-85331be89dba}" mode="1" >8.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="1" >600.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="4" >600.000</value>
<value id="{30f0d292-88f2-46ac-af20-9a2d1afec787}" mode="1" >600.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="4" >0.000</value>
<value id="{7aae7c4c-5488-4212-9d69-d7800c74b523}" mode="1" >0.00000000</value>
<value id="{bc72340b-5d10-4976-aa8f-d222c6188757}" mode="1" >1.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="1" >300.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="4" >300.000</value>
<value id="{02a36a56-c7bb-42b4-ad6f-cf8e450de841}" mode="1" >200.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="1" >16.54687500</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="4" >16.547</value>
<value id="{9e02285d-69f1-4e00-be8f-dfa2d8af03a6}" mode="1" >16.54687500</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="1" >0.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="4" >0.000</value>
<value id="{18461081-9d88-4948-a7a2-f78cacc1d6bd}" mode="1" >0.00000000</value>
<value id="{c6c00efe-b5d1-4ba5-aefe-b589731dfe41}" mode="1" >1.00000000</value>
<value id="{bdedaf7e-e1f4-4bd1-99a3-ed326f980bc2}" mode="1" >1.00000000</value>
<value id="{75b03faf-7718-4827-b6b0-2353c2013cfa}" mode="1" >50.00000000</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="1" >0.62019593</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="2" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="1" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="2" >0.00000000</value>
<value id="{e58853c0-86f8-4e0c-a0ff-e9c0f2ea2239}" mode="1" >-23.44390297</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="1" >-23.44390297</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="4" >-23.444</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="1" >0.68111283</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="2" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="1" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="2" >0.00000000</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="1" >0.69203818</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="2" >0.00000000</value>
<value id="{9808aaf4-bd15-4400-a22f-f858fdadb810}" mode="1" >1.00000000</value>
<value id="{87b80b9f-536f-47f4-8a45-2e677562611f}" mode="4" >0</value>
<value id="{6df984e2-620b-4f41-b510-70890fd7284c}" mode="4" >0</value>
<value id="{b00b7ada-e33c-40f3-985c-02844e9bb94f}" mode="1" >1.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="1" >0.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="4" >Max</value>
<value id="{df284c15-f1c7-4108-82ec-db829ff67323}" mode="1" >0.00000000</value>
<value id="{a04e2aaa-8c72-49e4-ac27-a48d1b4d19dc}" mode="1" >300.00000000</value>
</preset>
<preset name="natural transposition" number="9" >
<value id="{c6f473d7-2310-42c4-a9e0-c839e2037e3f}" mode="1" >1.00000000</value>
<value id="{b51c9dbe-8e6c-45a1-bff0-a29e081e8561}" mode="1" >0.00000000</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="1" >0.22040816</value>
<value id="{8346eeff-42ae-480a-a87e-a04a8bbf6263}" mode="4" >0.220</value>
<value id="{06660c1a-e37b-4058-a66e-662293199f71}" mode="1" >0.22040816</value>
<value id="{937dd04a-9dc6-4236-a5ab-08529ed68e86}" mode="1" >0.00000000</value>
<value id="{3a37f45c-31f6-411d-89a9-a2500d0cb3f5}" mode="1" >2.00000000</value>
<value id="{00d370ee-10a7-480f-a12a-ed4b140b578d}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{6d1afe68-fe9b-45d5-a207-af0265d40304}" mode="4" >/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff</value>
<value id="{ae60ca04-b53e-4a5a-b226-358ed138c70f}" mode="1" >-9.00000000</value>
<value id="{347c0175-ce76-48c2-ac77-85331be89dba}" mode="1" >8.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="1" >0.00000000</value>
<value id="{102b6f01-2310-4198-8ebc-0d5ded52e7ce}" mode="4" >0.000</value>
<value id="{30f0d292-88f2-46ac-af20-9a2d1afec787}" mode="1" >0.00000000</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="1" >3.06451607</value>
<value id="{e6c2c0a9-906f-42ce-af8b-74204b5f17be}" mode="4" >3.065</value>
<value id="{7aae7c4c-5488-4212-9d69-d7800c74b523}" mode="1" >3.06451607</value>
<value id="{bc72340b-5d10-4976-aa8f-d222c6188757}" mode="1" >0.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="1" >300.00000000</value>
<value id="{e1990b56-329e-4ed0-9f41-cf43ad6e2b46}" mode="4" >300.000</value>
<value id="{02a36a56-c7bb-42b4-ad6f-cf8e450de841}" mode="1" >200.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="1" >200.00000000</value>
<value id="{471f7698-cee0-4cce-b367-c32f0590dd4e}" mode="4" >200.000</value>
<value id="{9e02285d-69f1-4e00-be8f-dfa2d8af03a6}" mode="1" >200.00000000</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="1" >644.62811279</value>
<value id="{b5f86b53-5f2a-4521-86d6-9bb4d225ba18}" mode="4" >644.628</value>
<value id="{18461081-9d88-4948-a7a2-f78cacc1d6bd}" mode="1" >644.62811279</value>
<value id="{c6c00efe-b5d1-4ba5-aefe-b589731dfe41}" mode="1" >1.00000000</value>
<value id="{bdedaf7e-e1f4-4bd1-99a3-ed326f980bc2}" mode="1" >1.00000000</value>
<value id="{75b03faf-7718-4827-b6b0-2353c2013cfa}" mode="1" >50.00000000</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="1" >0.76461089</value>
<value id="{fa64908d-5557-4436-ae9d-e6c3131c1385}" mode="2" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="1" >0.00000000</value>
<value id="{f813f37d-8db0-4bc3-b802-1a294c716337}" mode="2" >0.00000000</value>
<value id="{e58853c0-86f8-4e0c-a0ff-e9c0f2ea2239}" mode="1" >-25.90243912</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="1" >-25.90243912</value>
<value id="{b7e21e98-3040-468e-9f1f-9c71e5502b88}" mode="4" >-25.902</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="1" >0.76461089</value>
<value id="{e0ed741c-9b75-48b4-b91a-62e483519a08}" mode="2" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="1" >0.00000000</value>
<value id="{8b872a2e-b013-4c43-b10e-a7a47f8e0068}" mode="2" >0.00000000</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="1" >0.52014583</value>
<value id="{5c334baa-687d-4daf-8a6c-e81209a7349e}" mode="2" >0.00000000</value>
<value id="{9808aaf4-bd15-4400-a22f-f858fdadb810}" mode="1" >10.00000000</value>
<value id="{87b80b9f-536f-47f4-8a45-2e677562611f}" mode="4" >0</value>
<value id="{6df984e2-620b-4f41-b510-70890fd7284c}" mode="4" >0</value>
<value id="{b00b7ada-e33c-40f3-985c-02844e9bb94f}" mode="1" >1.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="1" >0.00000000</value>
<value id="{63ef1797-ed71-4fea-b7f3-0faf78a0e28a}" mode="4" >Max</value>
<value id="{df284c15-f1c7-4108-82ec-db829ff67323}" mode="1" >3.06451607</value>
<value id="{a04e2aaa-8c72-49e4-ac27-a48d1b4d19dc}" mode="1" >300.00000000</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="360" y="248" width="612" height="322" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

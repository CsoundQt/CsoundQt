<CsoundSynthesizer>
<CsInstruments>
ksmps = 64
A4    = 442

massign 0, 0

gaSpectrumOut = init(0)
gkSpectrumFFTSize = init(4096)

giFFTSizes[] = [2048, 4096, 8192]


instr AudioTest
  ; kon1, kon2, kon3, kon4, kon5,kon6, kon7, kon8 init 0
  ksignalFreq = init(A4)
  ilevelExp = 0.33
  iuiRefreshRate = 24
  irange = 48
  iminAmp = ampdb(-60)
  imeterUpLag = 0.01
  imeterDownLag = 0.1
  kdb = init(-999999)

  kSpectrumSelect = init(1)

  ; ; ----- UI input -----
  ktrig = metro(iuiRefreshRate)
  ksignal = chnget("signaltype")
  kfftSizeIndex = chnget("fftsize")
  kfftSize = giFFTSizes[kfftSizeIndex]
  if kfftSize != gkSpectrumFFTSize then
    gkSpectrumFFTSize = kfftSize
    reinit resetFFT
  endif

  kdb = chnget("leveldb")
  ; kdb = int(linlin(kleveldelta^ilevelExp, -60, 0, 0, 1))
  kamp = ampdb(kdb)
  ksignalOn = kamp > iminAmp ? 1 : 0

  if ksignalOn == 0 kgoto skipOutput

  if ktrig == 1 then
    kon1 = chnget("on1")
    kon2 = chnget("on2")
    kon3 = chnget("on3")
    kon4 = chnget("on4")
    kon5 = chnget("on5")
    kon6 = chnget("on6")
    kon7 = chnget("on7")
    kon8 = chnget("on8")
    kSpectrumSelect = chnget("spmenu")
    ksignalFreq = chnget("signalfreq")
  endif

  ; ; Output

  if ksignal == 0 then
    asig = noise(1, 0)
  elseif ksignal == 1 then
    asig = pinker()
  elseif ksignal == 2 then
    asig = oscili(1, ksignalFreq)
  elseif ksignal == 3 then
    asig = vco2(1, ksignalFreq)
  endif

  asig *= interp(lag(kamp, 0.1))
  ; output to graph
  display asig, ksmps/sr*2

  iswitchlag = 0.3

  aout1 = asig*interp(lag(kon1, iswitchlag))
  koutamp1 max_k aout1, ktrig, 1
  outch 1, aout1

  aout2 = asig*interp(lag(kon2, iswitchlag))
  koutamp2 max_k aout2, ktrig, 1
  outch 2, aout2

  if nchnls <= 2 goto skipOutput

  aout3 = asig*interp(lag(kon3, iswitchlag))
  koutamp3 max_k aout3, ktrig, 1
  outch 3, aout3

  aout4 = asig*interp(lag(kon4, iswitchlag))
  koutamp4 max_k aout4, ktrig, 1
  outch 4, aout4

  if nchnls <= 4 goto skipOutput

  aout5 = asig*interp(lag(kon5, iswitchlag))
  koutamp5 max_k aout5, ktrig, 1
  outch 5, aout5

  aout6 = asig*interp(lag(kon6, iswitchlag))
  koutamp6 max_k aout6, ktrig, 1
  outch 6, aout6

  if nchnls <= 6 goto skipOutput

  aout7 = asig*interp(lag(kon7, iswitchlag))
  koutamp7 max_k aout7, ktrig, 1
  outch 7, aout7

  aout8 = asig*interp(lag(kon8, iswitchlag))
  koutamp8 max_k aout8, ktrig, 1
  outch 8, aout8



skipOutput:

  ; ; Audio Input

  imin = ampdbfs(-irange)


  kamp1 max_k inch(1), ktrig, 1
  kamp1 = lagud(kamp1, imeterUpLag, imeterDownLag)

  kamp2 max_k inch(2), ktrig, 1
  kamp2 = lagud(kamp2, imeterUpLag, imeterDownLag)

  kamp3 max_k inch(3), ktrig, 1
  kamp3 = lagud(kamp3, imeterUpLag, imeterDownLag)

  kamp4 max_k inch(4), ktrig, 1
  kamp4 = lagud(kamp4, imeterUpLag, imeterDownLag)

  kamp5 max_k inch(5), ktrig, 1
  kamp5 = lagud(kamp5, imeterUpLag, imeterDownLag)

  kamp6 max_k inch(6), ktrig, 1
  kamp6 = lagud(kamp6, imeterUpLag, imeterDownLag)

  kamp7 max_k inch(7), ktrig, 1
  kamp7 = lagud(kamp7, imeterUpLag, imeterDownLag)

  kamp8 max_k inch(8), ktrig, 1
  kamp8 = lagud(kamp8, imeterUpLag, imeterDownLag)

  if ktrig == 0 kgoto skipDisplay
  chnset dbamp(kamp1), "in1"
  chnset linlin(dbamp(koutamp1), 0, 1, -irange, 0), "vu1"
  chnset dbamp(kamp2), "in2"
  chnset linlin(dbamp(koutamp2), 0, 1, -irange, 0), "vu2"
  if nchnls <= 2 goto skipDisplay

  chnset dbfsamp(kamp3), "in3"
  chnset linlin(dbamp(koutamp3), 0, 1, -irange, 0), "vu3"
  chnset dbamp(kamp4), "in4"
  chnset linlin(dbamp(koutamp4), 0, 1, -irange, 0), "vu4"
  if nchnls <= 4 goto skipDisplay

  chnset dbamp(kamp5), "in5"
  chnset linlin(dbamp(koutamp5), 0, 1, -irange, 0), "vu5"
  chnset dbamp(kamp6), "in6"
  chnset linlin(dbamp(koutamp6), 0, 1, -irange, 0), "vu6"
  if nchnls <= 6 goto skipDisplay

  chnset dbamp(kamp7), "in7"
  chnset linlin(dbamp(koutamp7), 0, 1, -irange, 0), "vu7"
  chnset dbamp(kamp8), "in8"
  chnset linlin(dbamp(koutamp8), 0, 1, -irange, 0), "vu8"

skipDisplay:

  ; update text display at slower rate
  ktrig2 = metro(iuiRefreshRate*0.33)

  if ktrig2 == 1 then
    chnset round(dbfsamp(kamp1)), "indb1"
    chnset round(dbfsamp(kamp2)), "indb2"
    chnset round(dbfsamp(kamp3)), "indb3"
    chnset round(dbfsamp(kamp4)), "indb4"
    chnset round(dbfsamp(kamp5)), "indb5"
    chnset round(dbfsamp(kamp6)), "indb6"
    chnset round(dbfsamp(kamp7)), "indb7"
    chnset round(dbfsamp(kamp8)), "indb8"
  endif

  if kSpectrumSelect == 0 then
    aSpectrumOut = 0
  else
    aSpectrumOut inch kSpectrumSelect
    ; low shelf
    aSpectrumOut = pareq(aSpectrumOut, 30, 0, 0.1, 1)
  endif
  ; without denorming the cpu usage shoots to 100% in some cases
  denorm aSpectrumOut

  ; gaSpectrumOut += aSpectrumOut
resetFFT:
  prints "fft size: %d \n", i(gkSpectrumFFTSize)
  dispfft aSpectrumOut, 0.04, i(gkSpectrumFFTSize), 1

endin

instr led
  Schan = p4
  chnset 1, Schan
  if lastcycle() == 1 then
    kOut = 0
    chnset kOut, Schan
  endif
endin


instr MidiNote  ; midi note input
  ichn = p4
  ikey = p5
  ivel = p6
  chnset 1, "notein"
  schedule "led", 0, 0.1, "notein"
  if timeinstk() == 1 then
    Smsg = sprintf("Note %d, vel=%d, chan=%d", ikey, ivel, ichn)
    chnset Smsg, "display"
  endif

  iamp = ampdb(ivel/127 * 48 - 48)
  aenv = linsegr(0, 0.05, 1, 0.05, 0)
  aout = oscili(iamp*aenv, mtof(ikey))
  outch 1, aout

endin

instr MidiCC
  ichan = p4
  icc   = p5
  ival  = p6
  schedule "led", 0, 0.1, "ccin"
  Smsg = sprintf("CC %d: %d (chan=%d)", icc, ival, ichan)
  if eventcycles() == 0 then
    chnset Smsg, "displaycc"
  endif

endin

instr 3
  ; generate midi note
  noteondur 1, 60, 100, p3
endin

instr MidiIn
  iMidiNote = nstrnum("MidiNote")
  kstatus   = init(0)
  kstatus, kchan, kdata1, kdata2 midiin
  if kstatus == 144 && kdata1 > 0 then
    schedulek iMidiNote + kdata1/1000, 0, -1, kchan, kdata1, kdata2
  elseif kstatus == 128 || (kstatus == 144 && kdata1 == 0) then
    turnoff2 iMidiNote+kdata1/1000, 4, 1
  elseif kstatus == 176 then
    schedulek "MidiCC", 0, 0.1, kchan, kdata1, kdata2
  endif
endin

instr Setup
  chnset 0, "graph-index"
  chnset 1, "spectrum-index"
  chnset "...", "display"
  chnset "...", "displaycc"
  chnset 0, "notein"
  chnset 0, "ccin"

  chnset 0, "vu1"
  chnset 0, "vu2"
  chnset 0, "vu3"
  chnset 0, "vu4"
  chnset 0, "vu5"
  chnset 0, "vu6"
  chnset 0, "vu7"
  chnset 0, "vu8"

  chnset -120, "in1"
  chnset -120, "in2"
  chnset -120, "in3"
  chnset -120, "in4"
  chnset -120, "in5"
  chnset -120, "in6"
  chnset -120, "in7"
  chnset -120, "in8"

  chnset 0, "indb1"
  chnset 0, "indb2"
  chnset 0, "indb3"
  chnset 0, "indb4"
  chnset 0, "indb5"
  chnset 0, "indb6"
  chnset 0, "indb7"
  chnset 0, "indb8"


  chnset sprintf("%d", sr), "samplerate"
  chnset sprintf("%d", nchnls), "nchnls"

  for i0 in [1 ... nchnls] do
    outvalue sprintf("on%d/enabled", i0), 1
    outvalue sprintf("vu%d/enabled", i0), 1
    outvalue sprintf("in%d/enabled", i0), 1
    outvalue sprintf("indb%d/enabled", i0), 1
  od

  for i0 in [nchnls+1 ... 8] do
    outvalue sprintf("on%d/enabled", i0), 0
    outvalue sprintf("vu%d/enabled", i0), 0
    outvalue sprintf("in%d/enabled", i0), 0
    outvalue sprintf("indb%d/enabled", i0), 0
  od
  turnoff
endin

</CsInstruments>
<CsScore>
i "AudioTest"   0.0  3600
i "MidiIn"      0.02 3600
i "Setup"       0.02 -1
e
</CsScore>
</CsoundSynthesizer>























































<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>702</width>
 <height>620</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>65</r>
  <g>65</g>
  <b>65</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>329</x>
  <y>89</y>
  <width>373</width>
  <height>328</height>
  <uuid>{f046b35f-13ea-4c0f-9282-b4b6007fc90e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Audio Output</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>true</locked>
  <color>
   <r>240</r>
   <g>240</g>
   <b>240</b>
  </color>
  <bgcolor mode="background">
   <r>99</r>
   <g>99</g>
   <b>99</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>4</x>
  <y>312</y>
  <width>322</width>
  <height>105</height>
  <uuid>{d25e4c33-85be-48ad-a3f4-b071e3baa5fe}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>MIDI I/O</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>true</locked>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>99</r>
   <g>99</g>
   <b>99</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>4</x>
  <y>9</y>
  <width>698</width>
  <height>44</height>
  <uuid>{dc5604fd-41c0-4189-abe2-55c72f10172b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label> Audio / MIDI Test</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>99</r>
   <g>99</g>
   <b>99</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>4</x>
  <y>89</y>
  <width>322</width>
  <height>220</height>
  <uuid>{6b0524fe-c62b-443e-a7cc-2786168abc62}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Audio Input</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>true</locked>
  <color>
   <r>243</r>
   <g>243</g>
   <b>243</b>
  </color>
  <bgcolor mode="background">
   <r>99</r>
   <g>99</g>
   <b>99</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>17</x>
  <y>254</y>
  <width>23</width>
  <height>25</height>
  <uuid>{cf92f08d-bb58-4a3d-acda-479165db96d4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>1</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>218</r>
   <g>218</g>
   <b>218</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button1</objectName>
  <x>204</x>
  <y>357</y>
  <width>100</width>
  <height>48</height>
  <uuid>{a3545b15-5470-4efb-9dfd-eee56bc47d2a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Generate note</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>9</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>74</r>
   <g>38</g>
   <b>0</b>
  </color>
  <pressedColor>#f5943f</pressedColor>
  <borderColor>#564341</borderColor>
  <textColor>#fdfdfd</textColor>
  <pressedTextColor>#ffffff</pressedTextColor>
  <borderWidth>0</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>18</x>
  <y>341</y>
  <width>25</width>
  <height>25</height>
  <uuid>{a4ab00b5-62ab-45b1-9b1f-2978742d4057}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>notein</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>255</r>
   <g>76</g>
   <b>17</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>25</r>
   <g>25</g>
   <b>25</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>signaltype</objectName>
  <x>547</x>
  <y>277</y>
  <width>110</width>
  <height>28</height>
  <uuid>{6d7e91db-0e40-4c78-8ff3-e01a436b45af}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>whitenoise</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>pinknoise</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>sine</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>saw</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>56</x>
  <y>254</y>
  <width>23</width>
  <height>25</height>
  <uuid>{00820929-c5f2-4b95-857d-8f65bc444510}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>2</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>218</r>
   <g>218</g>
   <b>218</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>95</x>
  <y>254</y>
  <width>23</width>
  <height>25</height>
  <uuid>{731bae72-8739-4e2d-bcf8-dac396e37ccc}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>3</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>218</r>
   <g>218</g>
   <b>218</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>134</x>
  <y>254</y>
  <width>23</width>
  <height>25</height>
  <uuid>{727c9851-0e1b-4fc9-8afc-fd6c62f253be}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>4</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>218</r>
   <g>218</g>
   <b>218</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>173</x>
  <y>254</y>
  <width>23</width>
  <height>25</height>
  <uuid>{2846ddf1-0e08-457a-8d28-e6dd839a2eb8}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>5</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>218</r>
   <g>218</g>
   <b>218</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>212</x>
  <y>254</y>
  <width>23</width>
  <height>25</height>
  <uuid>{f55bd16e-cd68-44a7-8b08-2f9e1183ab42}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>6</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>218</r>
   <g>218</g>
   <b>218</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>251</x>
  <y>254</y>
  <width>23</width>
  <height>25</height>
  <uuid>{34ecffc5-5d86-422e-97fc-e5c9fd0e0aa7}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>7</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>218</r>
   <g>218</g>
   <b>218</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>290</x>
  <y>254</y>
  <width>23</width>
  <height>25</height>
  <uuid>{4c976814-f547-431d-ab74-e9225f3aff12}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>8</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>218</r>
   <g>218</g>
   <b>218</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>on1</objectName>
  <x>338</x>
  <y>200</y>
  <width>48</width>
  <height>48</height>
  <uuid>{55747531-f2e1-4e50-9839-3e788d995014}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>1</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>24</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>74</r>
   <g>38</g>
   <b>0</b>
  </color>
  <pressedColor>#f5943f</pressedColor>
  <borderColor>#564341</borderColor>
  <textColor>#9a9a9a</textColor>
  <pressedTextColor>#ffffff</pressedTextColor>
  <borderWidth>0</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>582</x>
  <y>219</y>
  <width>80</width>
  <height>25</height>
  <uuid>{a498f284-9d66-4ec8-9c40-07632ace83b4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Level (dB)</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>223</r>
   <g>112</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>355</x>
  <y>117</y>
  <width>16</width>
  <height>80</height>
  <uuid>{738f62ff-0256-428d-826b-2e96fb28c483}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>vu1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>-38.90450678</yValue>
  <type>fill</type>
  <pointsize>3</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#3c332e</borderColor>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>39</r>
   <g>39</g>
   <b>39</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>on2</objectName>
  <x>388</x>
  <y>200</y>
  <width>48</width>
  <height>48</height>
  <uuid>{6fa42161-ada8-4ca1-a785-00e8d9ca3d0c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>2</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>24</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>74</r>
   <g>38</g>
   <b>0</b>
  </color>
  <pressedColor>#f5943f</pressedColor>
  <borderColor>#564341</borderColor>
  <textColor>#9a9a9a</textColor>
  <pressedTextColor>#ffffff</pressedTextColor>
  <borderWidth>0</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>405</x>
  <y>116</y>
  <width>16</width>
  <height>80</height>
  <uuid>{81589d71-6606-4fa8-b0fa-daeaf64b35ac}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>vu2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>-32.82672806</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>39</r>
   <g>39</g>
   <b>39</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>on3</objectName>
  <x>438</x>
  <y>200</y>
  <width>48</width>
  <height>48</height>
  <uuid>{aeb8b307-415d-4a1f-83a6-edd57e6e525d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>3</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>24</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>74</r>
   <g>38</g>
   <b>0</b>
  </color>
  <pressedColor>#f5943f</pressedColor>
  <borderColor>#564341</borderColor>
  <textColor>#9a9a9a</textColor>
  <pressedTextColor>#ffffff</pressedTextColor>
  <borderWidth>0</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>454</x>
  <y>117</y>
  <width>16</width>
  <height>80</height>
  <uuid>{47096117-b4df-4a57-9f63-43e4433b93d2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>vu3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>39</r>
   <g>39</g>
   <b>39</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>on4</objectName>
  <x>488</x>
  <y>200</y>
  <width>48</width>
  <height>48</height>
  <uuid>{28590fdc-f133-43b3-99b8-7d7c379d5f79}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>4</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>24</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>74</r>
   <g>38</g>
   <b>0</b>
  </color>
  <pressedColor>#f5943f</pressedColor>
  <borderColor>#564341</borderColor>
  <textColor>#9a9a9a</textColor>
  <pressedTextColor>#ffffff</pressedTextColor>
  <borderWidth>0</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>504</x>
  <y>118</y>
  <width>16</width>
  <height>80</height>
  <uuid>{1c265b1b-8455-4c2c-96e6-e6f5d5d97caf}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>vu4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>39</r>
   <g>39</g>
   <b>39</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>on5</objectName>
  <x>340</x>
  <y>357</y>
  <width>48</width>
  <height>48</height>
  <uuid>{7a266b0a-9e69-4579-b3d5-bf911c9ae383}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>5</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>24</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>74</r>
   <g>38</g>
   <b>0</b>
  </color>
  <pressedColor>#f5943f</pressedColor>
  <borderColor>#564341</borderColor>
  <textColor>#9a9a9a</textColor>
  <pressedTextColor>#ffffff</pressedTextColor>
  <borderWidth>0</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>356</x>
  <y>273</y>
  <width>16</width>
  <height>80</height>
  <uuid>{122c6052-83a6-4992-86e3-a44e37e9d19d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>vu5</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>39</r>
   <g>39</g>
   <b>39</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>on6</objectName>
  <x>390</x>
  <y>357</y>
  <width>48</width>
  <height>48</height>
  <uuid>{e04bef86-57d9-46fc-8e12-508e8b42f03f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>6</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>24</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>74</r>
   <g>38</g>
   <b>0</b>
  </color>
  <pressedColor>#f5943f</pressedColor>
  <borderColor>#564341</borderColor>
  <textColor>#9a9a9a</textColor>
  <pressedTextColor>#ffffff</pressedTextColor>
  <borderWidth>0</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>405</x>
  <y>273</y>
  <width>16</width>
  <height>80</height>
  <uuid>{ad1f2483-c122-4501-8e77-b1795091923d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>vu6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>39</r>
   <g>39</g>
   <b>39</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>on7</objectName>
  <x>440</x>
  <y>357</y>
  <width>48</width>
  <height>48</height>
  <uuid>{987ad683-ffda-4c02-ba76-fba80eef6f99}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>7</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>24</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>74</r>
   <g>38</g>
   <b>0</b>
  </color>
  <pressedColor>#f5943f</pressedColor>
  <borderColor>#564341</borderColor>
  <textColor>#9a9a9a</textColor>
  <pressedTextColor>#ffffff</pressedTextColor>
  <borderWidth>0</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>455</x>
  <y>273</y>
  <width>16</width>
  <height>80</height>
  <uuid>{831662dd-60f9-46a5-a8b2-6335223bf3ab}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>vu7</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>39</r>
   <g>39</g>
   <b>39</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>on8</objectName>
  <x>490</x>
  <y>357</y>
  <width>48</width>
  <height>48</height>
  <uuid>{eb86882f-def6-42b6-90ae-22f49f88a876}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>8</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>24</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>74</r>
   <g>38</g>
   <b>0</b>
  </color>
  <pressedColor>#f5943f</pressedColor>
  <borderColor>#564341</borderColor>
  <textColor>#9a9a9a</textColor>
  <pressedTextColor>#ffffff</pressedTextColor>
  <borderWidth>0</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>505</x>
  <y>273</y>
  <width>16</width>
  <height>80</height>
  <uuid>{2816aa9b-fa21-4b9c-a8ae-c29e6509d5b7}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>vu8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.23529400</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>39</r>
   <g>39</g>
   <b>39</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>14</x>
  <y>317</y>
  <width>82</width>
  <height>26</height>
  <uuid>{3112a9ff-3ad0-4640-be66-9c8f659b03c2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Note received</label>
  <alignment>left</alignment>
  <valignment>bottom</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>240</r>
   <g>240</g>
   <b>240</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBGraph" version="2">
  <objectName>graph-index</objectName>
  <x>547</x>
  <y>307</y>
  <width>142</width>
  <height>98</height>
  <uuid>{c1ed5763-b6f3-49fa-a32b-01e54082a604}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>false</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>false</showTableInfo>
  <showScrollbars>false</showScrollbars>
  <enableTables>false</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>17</x>
  <y>385</y>
  <width>25</width>
  <height>25</height>
  <uuid>{4226d3d7-ef78-4a0f-8d15-8cd322f71634}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>ccin</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <exponent>1.00000000</exponent>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>154</g>
   <b>231</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>25</r>
   <g>25</g>
   <b>25</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>14</x>
  <y>362</y>
  <width>82</width>
  <height>26</height>
  <uuid>{67bb9df3-11b5-4f60-a18d-7f0dd3cb6dd2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>CC received</label>
  <alignment>left</alignment>
  <valignment>bottom</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>240</r>
   <g>240</g>
   <b>240</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>displaycc</objectName>
  <x>43</x>
  <y>385</y>
  <width>140</width>
  <height>25</height>
  <uuid>{37470029-ec0e-4126-921e-eb82afe59857}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>...</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>243</r>
   <g>243</g>
   <b>243</b>
  </color>
  <bgcolor mode="background">
   <r>39</r>
   <g>39</g>
   <b>39</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>leveldb</objectName>
  <x>572</x>
  <y>116</y>
  <width>100</width>
  <height>100</height>
  <uuid>{f8080f9c-7129-4dca-882f-9a3d2607106b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-60.00000000</minimum>
  <maximum>0.00000000</maximum>
  <exponent>0.42000000</exponent>
  <value>-28.84818506</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#f57c00</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>true</integerMode>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>samplerate</objectName>
  <x>508</x>
  <y>20</y>
  <width>60</width>
  <height>26</height>
  <uuid>{650b8432-c87b-4a3c-8b0e-cbb2b482c252}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>48000</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>2</padding>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>nchnls</objectName>
  <x>660</x>
  <y>20</y>
  <width>30</width>
  <height>26</height>
  <uuid>{4fe7d33b-9e2f-41c1-9a8e-ef1d0f723b31}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>Set the number of channels in Edit/Configuration/Run</description>
  <label>2</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>420</x>
  <y>20</y>
  <width>90</width>
  <height>26</height>
  <uuid>{9abf6954-2dc5-492c-bfb6-d4d40850f9f9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Sample Rate</label>
  <alignment>right</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>205</r>
   <g>205</g>
   <b>205</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>580</x>
  <y>20</y>
  <width>80</width>
  <height>26</height>
  <uuid>{eaacf58e-e1b3-4a36-8cc7-18bc45a9d98f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Channels</label>
  <alignment>right</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>205</r>
   <g>205</g>
   <b>205</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBGraph" version="2">
  <objectName>spectrum-index</objectName>
  <x>4</x>
  <y>420</y>
  <width>698</width>
  <height>200</height>
  <uuid>{a99a03fb-0336-41b5-99f4-bc12ec8036c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>1</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>false</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>false</showScrollbars>
  <enableTables>false</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>spmenu</objectName>
  <x>622</x>
  <y>422</y>
  <width>80</width>
  <height>28</height>
  <uuid>{a8934883-bf45-4155-be13-834e1b5f9a9b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>None</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Input 1</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Input 2</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Input 3</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Input 4</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Input 5</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Input 6</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Input 7</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Input 8</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>547</x>
  <y>256</y>
  <width>97</width>
  <height>22</height>
  <uuid>{8afe76f5-61f5-4669-b921-f9520406a099}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Signal Type</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>171</r>
   <g>171</g>
   <b>171</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>signalfreq</objectName>
  <x>657</x>
  <y>278</y>
  <width>32</width>
  <height>26</height>
  <uuid>{53268cff-714e-423a-902b-7351141be7ec}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>39</r>
   <g>39</g>
   <b>39</b>
  </bgcolor>
  <value>1018.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>50.00000000</minimum>
  <maximum>4000.00000000</maximum>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>658</x>
  <y>256</y>
  <width>30</width>
  <height>22</height>
  <uuid>{ae79f074-43a6-4d48-965c-5f07fcc4d3ac}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Hz</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>164</r>
   <g>164</g>
   <b>164</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>fftsize</objectName>
  <x>622</x>
  <y>450</y>
  <width>80</width>
  <height>28</height>
  <uuid>{13bbe66e-eb51-4cd5-b44e-59eb1ee3e6dd}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description>FFT size</description>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>2048</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4096</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8192</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>55</y>
  <width>690</width>
  <height>32</height>
  <uuid>{f10e642f-7bf6-4bd6-8c2d-7d8a2fccfd06}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Set "Channels" in Configure/Run to match your hardware settings</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>205</r>
   <g>205</g>
   <b>205</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>display</objectName>
  <x>44</x>
  <y>341</y>
  <width>140</width>
  <height>25</height>
  <uuid>{23d21873-0a2e-49e7-826a-9c6e4613e89a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>...</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>243</r>
   <g>243</g>
   <b>243</b>
  </color>
  <bgcolor mode="background">
   <r>39</r>
   <g>39</g>
   <b>39</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>in2</objectName>
  <x>60</x>
  <y>108</y>
  <width>32</width>
  <height>155</height>
  <uuid>{dff5c758-6ef9-4c17-9096-68c25c5fafb8}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-90.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>compact</rulermode>
  <rulercolor>#aaaaaa</rulercolor>
  <exponent>0.30000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>179</r>
   <g>179</g>
   <b>179</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>in1</objectName>
  <x>22</x>
  <y>108</y>
  <width>32</width>
  <height>155</height>
  <uuid>{733f880f-dbe6-43bd-93dc-ec633a0f78c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-90.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>compact</rulermode>
  <rulercolor>#aaaaaa</rulercolor>
  <exponent>0.30000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>179</r>
   <g>179</g>
   <b>179</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>in3</objectName>
  <x>100</x>
  <y>115</y>
  <width>12</width>
  <height>140</height>
  <uuid>{00719c73-78e7-477c-89e0-027caab08d48}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-90.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>hide</rulermode>
  <rulercolor>#aaaaaa</rulercolor>
  <exponent>0.30000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>179</r>
   <g>179</g>
   <b>179</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>in4</objectName>
  <x>139</x>
  <y>115</y>
  <width>12</width>
  <height>140</height>
  <uuid>{fb742b82-b354-4ab5-8cee-d4579f1a1c98}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-90.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>hide</rulermode>
  <rulercolor>#aaaaaa</rulercolor>
  <exponent>0.30000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>179</r>
   <g>179</g>
   <b>179</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>in5</objectName>
  <x>178</x>
  <y>115</y>
  <width>12</width>
  <height>140</height>
  <uuid>{6afdf700-3d48-40e3-ab43-ea1f3679820f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-90.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>hide</rulermode>
  <rulercolor>#aaaaaa</rulercolor>
  <exponent>0.30000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>179</r>
   <g>179</g>
   <b>179</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>in6</objectName>
  <x>217</x>
  <y>115</y>
  <width>12</width>
  <height>140</height>
  <uuid>{826da4a0-55e9-4d35-99b4-b20e1f1d33c7}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-90.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>hide</rulermode>
  <rulercolor>#aaaaaa</rulercolor>
  <exponent>0.30000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>179</r>
   <g>179</g>
   <b>179</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>in7</objectName>
  <x>256</x>
  <y>115</y>
  <width>12</width>
  <height>140</height>
  <uuid>{27bf4ddf-2e7c-4b4f-8ca1-9b6ff75d697d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-90.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>hide</rulermode>
  <rulercolor>#aaaaaa</rulercolor>
  <exponent>0.30000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>179</r>
   <g>179</g>
   <b>179</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBVUMeter" version="2">
  <objectName>in8</objectName>
  <x>295</x>
  <y>115</y>
  <width>12</width>
  <height>140</height>
  <uuid>{92b27e66-4065-4726-816f-3752986b8659}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-90.00000000</minimum>
  <maximum>0.00000000</maximum>
  <objectName2/>
  <rulermode>hide</rulermode>
  <rulercolor>#aaaaaa</rulercolor>
  <exponent>0.30000000</exponent>
  <cursorcolor>#000000</cursorcolor>
  <cursorwidth>1</cursorwidth>
  <bgcolor>
   <r>20</r>
   <g>20</g>
   <b>20</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <bordercolor>
   <r>179</r>
   <g>179</g>
   <b>179</b>
  </bordercolor>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>indb2</objectName>
  <x>51</x>
  <y>279</y>
  <width>36</width>
  <height>21</height>
  <uuid>{647cc93d-f278-474f-9efe-397ef1e22adf}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-26</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>85</r>
   <g>255</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>indb1</objectName>
  <x>13</x>
  <y>279</y>
  <width>36</width>
  <height>21</height>
  <uuid>{6020d615-b765-4bca-97e3-810a3c0774f5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-26</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>85</r>
   <g>255</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>indb3</objectName>
  <x>89</x>
  <y>279</y>
  <width>36</width>
  <height>21</height>
  <uuid>{5cf612a7-df07-4cfe-9e01-c0c98c58bbf4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-inf</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>85</r>
   <g>255</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>indb4</objectName>
  <x>128</x>
  <y>279</y>
  <width>36</width>
  <height>21</height>
  <uuid>{da01e34b-57da-4892-987b-e7e485337a33}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-inf</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>85</r>
   <g>255</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>indb5</objectName>
  <x>167</x>
  <y>279</y>
  <width>36</width>
  <height>21</height>
  <uuid>{7f7b5c97-21e7-4d2e-9aae-ae28d9c742bf}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-inf</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>85</r>
   <g>255</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>indb6</objectName>
  <x>206</x>
  <y>279</y>
  <width>36</width>
  <height>21</height>
  <uuid>{21644b5f-836d-4ce7-9ea3-af25e6fbe72a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-inf</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>85</r>
   <g>255</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>indb7</objectName>
  <x>245</x>
  <y>279</y>
  <width>36</width>
  <height>21</height>
  <uuid>{47deccba-ed76-4ecc-8ec3-7dd1025ea175}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-inf</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>85</r>
   <g>255</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>indb8</objectName>
  <x>284</x>
  <y>279</y>
  <width>36</width>
  <height>21</height>
  <uuid>{880c3f40-c68f-4e45-ad37-c90f82946c9e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>false</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>-inf</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>85</r>
   <g>255</g>
   <b>127</b>
  </color>
  <bgcolor mode="background">
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

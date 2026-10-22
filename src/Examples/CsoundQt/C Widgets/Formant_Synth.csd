<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 
--midi-velocity=5
</CsOptions>
<CsInstruments>
; ************************************************************
; Formant synthesizer with glottal parameters
; Andreas Bergsland, 2009
; ************************************************************
sr     = 44100
ksmps  = 64
nchnls = 2
0dbfs = 32768


giSine ftgen 0, 0, 1024, 10, 1

; *****************************************************
; Trigger instrument
; ******************************************************

massign 1, 2

instr 1
  ; Get value for global source
  kOpenQ  chnget "OQ"
  kSpeedQ chnget "SQ"
  ; On value
  kon chnget "on"
  ; Trigger play instrument
  konchanged changed kon
  ktrig = kon * konchanged  ; only turn on when it's 1 and its just changed to 1
  schedkwhen ktrig, 0, 2, 10, 0, 100, kOpenQ, kSpeedQ

  if (konchanged == 1 && kon == 0) then
    turnoff2 10, 2, 0
  endif

  ; Turn off MIDI triggered note
  kstatus, kchan, kdata1, kdata2 midiin
  if (kstatus == 128) then
    turnoff2 10, 2, 0
  endif
endin

instr 2  ; MIDI trigger
  ; turn off sound from button
  chnset  0, "on"
  turnoff2 10, 1, 0

  icps cpsmidi
  chnset  icps, "f0"
  kOpenQ  chnget "OQ"
  kSpeedQ chnget "SQ"
  schedkwhen 1, 0, 2, 10, 0, 100, kOpenQ, kSpeedQ
  turnoff
endin

; *************************************************************
; Formant synthesizer instrument
instr 10

  ; Get formant parameters
  kcutoff1 chnget "Cutoff1"
  kreson1  chnget "Reson1"
  kcutoff2 chnget "Cutoff2"
  kreson2  chnget "Reson2"
  kcutoff3 chnget "Cutoff3"
  kreson3  chnget "Reson3"
  kcutoff4 chnget "Cutoff4"
  kreson4  chnget "Reson4"

  iflen = 4096

  ; Get glottal parameters
  iOpenQ = p4
  ; Speed quotient - compensate for the number of open vs closed segments in the ftable
  ; linseg
  iSQ = p5 * 12/14

  iOpen  = iOpenQ * iflen
  iClose = iflen - iOpen
  ip     = iOpen/26  ; Calculate duration for segments in the open phase
  iO     = ip * iSQ  ; Apply speed quotient for opening
  iC     = ip / iSQ  ; and closing phase

  iOp = 14*iO  ; Scale so that values fits the open phase
  iCl = 12*iC
  iT  = (iOp + iCl)/iOpen

  iO = iO / iT  ; Calulate open
  iC = iC / iT  ; and closed segments

  ; Values for a glottal waveform taken from Inger Karlsson (1988), "Glottal waveform
  ; parameters for different speaker types" (Could be mapped more accurately)
  i0  = 0  ; t1
  i1  = .02
  i2  = .05
  i3  = .1
  i4  = .15
  i5  = .24
  i6  = .33
  i7  = .45
  i8  = .575
  i9  = .645
  i10 = .775
  i11 = .845
  i12 = .945
  i13 = .985
  i14 = .99  ; ca.t2
  i15 = .95
  i16 = .8
  i17 = .57
  i18 = .3  ; ca.t3
  i19 = .11
  i20 = .06
  i21 = .04
  i22 = .02
  i23 = .01
  i24 = .002
  i25 = .001
  i26 = 0  ; t4

  ; Make ftable for glottal waveform
  isource ftgen 102, 0, iflen, 7, i0, iO, i1, iO, i2, iO, i3, iO, i4, iO, i5, iO, i6, iO, i7, iO, i8, \
    iO, i9, iO, i10, iO, i11, iO, i12, iO, i13, iO, i14, iC, i15, iC, i16, iC, i17, \
    iC, i18, iC, i19, iC, i20, iC, i21, iC, i22, iC, i23, iC, i24, iC, i25, iC, i26, iClose, 0

  kf0 chnget "f0"
  kamp linen 4000, .2, p3, .35


  ; ***************************************************************
  ; JITTER, three different opcodes
  kcpsMin = 8
  kcpsMax = 20
  kjitamp = .025
  kjit1 jspline kjitamp, kcpsMin, kcpsMax

  kjitamp = .027
  kcpsMin = 2
  kcpsMax = 20
  kjit2 jitter 2.7, 2, 20

  ktotamp = .027
  kamp1   = .2
  kcps1   = 1.5
  kamp2   = .25
  kcps2   = 4.5
  kamp3   = .3
  kcps3   = 15.5
  kjit3 jitter2 ktotamp, kamp1, kcps1, kamp2, kcps2, kamp3, kcps3

  kjitOn chnget "JitOn"
  kjit = kjit3 * kjitOn

  ; ***************************************************************
  ; Vibrato

  kvibamp expseg 0.001, p3*.3, 1.5, p3*.7, 2.5
  ivibfrek = 5.6
  kvibrand randh .1, ivibfrek
  kvibfrek = ivibfrek + kvibrand

  kvibOn chnget "Vib"
  kvib oscil kvibamp * kvibOn, kvibfrek, giSine



  ; ***************************************************************
  ; Shimmer

  kShimOn chnget "ShimOn"
  iavgshim = (ampdb(0.39)/ampdb(0))-1
  print iavgshim
  kshimamp = kamp * iavgshim * kShimOn
  kcpsMin  = 8
  kcpsMAx  = 20
  kshim jspline kshimamp, kcpsMin, kcpsMax
  ; *****************************************************************

  ; *****************************************************************
  ; Overshoot

  kOShoot chnget "OShoot"
  if0     = i(kf0)
  iOShoot = i(kOShoot)
  iamount = .08 * if0 * iOShoot

  kOShoot linseg iamount, .06, 0, p3-.05, 0
  ; ******************************************************************

  ; *****************************************************************
  ; Make source sound

  ; Noise
  kNoise chnget "Noise"
  anoise rand kamp * kNoise
  anoise butbp anoise, 4500, 4000

  ; Glottal pulses
  avoiced oscili kamp + kshim, kf0 + (kjit*kf0) + kvib + kOShoot, isource

  alyd = avoiced + anoise
  ; ******************************************************************
  ; FORMANT FILTERS - reson with double filtering

  aform1 reson alyd, kcutoff1, kreson1 * kcutoff1 / 100
  aform1 reson aform1, kcutoff1, kreson1 * kcutoff1 / 100
  aform2 reson alyd, kcutoff2, kreson2 * kcutoff2 / 100
  aform2 reson aform2, kcutoff2, kreson2 * kcutoff2 / 100
  aform3 reson alyd, kcutoff3, kreson3 * kcutoff3 / 100
  aform3 reson aform3, kcutoff3, kreson3 * kcutoff3 / 100
  aform4 reson alyd, kcutoff4, kreson4 * kcutoff4 / 100
  aform4 reson aform4, kcutoff4, kreson4 * kcutoff4 / 100

  ; add formant jitter (experimental)
  kcutoff1 = kcutoff1 + kcutoff1*kjit3*.3
  kcutoff2 = kcutoff2 + kcutoff2*kjit3*.3
  kcutoff3 = kcutoff3 + kcutoff3*kjit3*.3
  kcutoff4 = kcutoff4 + kcutoff4*kjit3*.3

  ; aform4 reson   alyd,   kcutoff4, kreson4 * kcutoff4 / 100
  ; aform3 reson   aform4, kcutoff3, kreson3 * kcutoff3 / 100
  ; aform2 reson   aform3, kcutoff2, kreson2 * kcutoff2 / 100
  ; aform1 reson   aform2, kcutoff1, kreson1 * kcutoff1 / 100

  ; balance
  abal1 balance aform1, alyd
  abal2 balance aform2, alyd
  abal3 balance aform3, alyd
  abal4 balance aform4, alyd

  ; get formant amps
  kFamp1 chnget "FormAmp1"
  kFamp2 chnget "FormAmp2"
  kFamp3 chnget "FormAmp3"
  kFamp4 chnget "FormAmp4"


  ; Mix
  afilt = abal1 * kFamp1 +abal2 * kFamp2 +abal3 * kFamp3 + abal4*kFamp4
  
  chnset afilt, "master"
  
endin

instr 100  ; master
  aout chnget "master"
  dispfft aout, 0.1, 2048, 1
  aout2 = aout * chnget("Vol")
  out aout2, aout2
  chnclear "master"
endin

instr Setup
  outvalue "graph/findfft", "aout"
  turnoff
endin  

</CsInstruments>
<CsScore>

i1 0 3600
i "Setup" 0.5 1
i 100 0 -1
</CsScore>
</CsoundSynthesizer>







<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>23</x>
 <y>44</y>
 <width>782</width>
 <height>592</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>14</x>
  <y>12</y>
  <width>755</width>
  <height>228</height>
  <uuid>{255f7a90-5a57-4d3c-8c1d-7c73df44b994}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Formant Graph</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBGraph" version="2">
  <objectName>graph</objectName>
  <x>21</x>
  <y>18</y>
  <width>740</width>
  <height>217</height>
  <uuid>{18cfa587-24cd-4d57-85a2-4fb149824822}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
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
  <showSelector>true</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>true</showScrollbars>
  <enableTables>true</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>on</objectName>
  <x>621</x>
  <y>337</y>
  <width>141</width>
  <height>29</height>
  <uuid>{e772e396-07d1-4fc7-a2ab-a7f75de51839}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>true</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>212</r>
   <g>198</g>
   <b>156</b>
  </color>
  <pressedColor/>
  <borderColor>#8d8468</borderColor>
  <textColor>#000000</textColor>
  <pressedTextColor/>
  <borderWidth>0</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>OQ</objectName>
  <x>19</x>
  <y>258</y>
  <width>120</width>
  <height>20</height>
  <uuid>{ed66615b-352c-4bba-86c0-047060bcb717}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.01000000</minimum>
  <maximum>0.99000000</maximum>
  <value>0.60616667</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>OQ</objectName>
  <x>140</x>
  <y>251</y>
  <width>62</width>
  <height>34</height>
  <uuid>{17ac5668-ce2d-4af9-b65e-e0e4612ae64f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.606</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>SQ</objectName>
  <x>16</x>
  <y>297</y>
  <width>120</width>
  <height>20</height>
  <uuid>{d7218969-08b1-4bd7-a9a0-b628bc11de92}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.80000000</minimum>
  <maximum>4.00000000</maximum>
  <value>3.33333333</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>SQ</objectName>
  <x>139</x>
  <y>291</y>
  <width>64</width>
  <height>34</height>
  <uuid>{0d2e784e-c496-48c0-b1e7-24f7372bf098}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>3.333</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>208</x>
  <y>252</y>
  <width>188</width>
  <height>35</height>
  <uuid>{110eea63-47f6-4b77-8618-75983accf0e2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Open Quotient (OQ)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>209</x>
  <y>292</y>
  <width>189</width>
  <height>34</height>
  <uuid>{6b2d94b8-9878-4d4d-a9fb-40ad4a7f2591}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Speed Quotient (SQ)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>17</x>
  <y>374</y>
  <width>178</width>
  <height>200</height>
  <uuid>{fcb57829-45a8-4dcb-b308-c9759c5116a5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Formant 1</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>208</x>
  <y>374</y>
  <width>180</width>
  <height>200</height>
  <uuid>{b49cbccf-29fa-4e5d-a241-976f70d0bc96}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Formant 2</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>402</x>
  <y>374</y>
  <width>173</width>
  <height>200</height>
  <uuid>{c9090fc2-e24b-4f9a-a61e-0df7be4a4a56}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Formant 3</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>586</x>
  <y>374</y>
  <width>178</width>
  <height>200</height>
  <uuid>{3eaa3afc-6844-4d09-b916-e3216228e124}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Formant 4</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>634</x>
  <y>306</y>
  <width>39</width>
  <height>30</height>
  <uuid>{3eefe31b-44dd-4ad9-be42-9bab11c88426}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Vol</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName/>
  <x>560</x>
  <y>306</y>
  <width>39</width>
  <height>30</height>
  <uuid>{8d4841bd-9c74-449f-9f83-a536ba65d3f2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>f0</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>Vib</objectName>
  <x>405</x>
  <y>252</y>
  <width>20</width>
  <height>20</height>
  <uuid>{578bf449-45b0-4a38-a845-d8f0fdeb40a4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>428</x>
  <y>249</y>
  <width>78</width>
  <height>31</height>
  <uuid>{8f2ea0c8-50aa-4c3e-a4be-2dd68e87a370}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Vibr</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>JitOn</objectName>
  <x>405</x>
  <y>280</y>
  <width>20</width>
  <height>20</height>
  <uuid>{41210d11-ef8e-495a-8b5b-8eb153e98144}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>ShimOn</objectName>
  <x>405</x>
  <y>308</y>
  <width>20</width>
  <height>20</height>
  <uuid>{daac4edc-6702-4f9b-a209-edf0e249dad1}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>429</x>
  <y>276</y>
  <width>78</width>
  <height>31</height>
  <uuid>{3615fe9d-802f-4ec7-9994-19b7cc60e99d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Jit</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>429</x>
  <y>303</y>
  <width>84</width>
  <height>31</height>
  <uuid>{14eeb36a-51d4-4b86-9f99-5a974e89bf14}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Shim</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>OShoot</objectName>
  <x>405</x>
  <y>336</y>
  <width>20</width>
  <height>20</height>
  <uuid>{512c9266-c506-4055-b72c-1e87eec9b966}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>429</x>
  <y>330</y>
  <width>113</width>
  <height>31</height>
  <uuid>{8bb809a5-548c-47a7-90cf-852b385c12d0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Overshoot</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Noise</objectName>
  <x>17</x>
  <y>339</y>
  <width>120</width>
  <height>20</height>
  <uuid>{af7dfd5c-edac-486c-8b48-ae459f14e99b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.20000000</maximum>
  <value>0.19000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Noise</objectName>
  <x>140</x>
  <y>331</y>
  <width>64</width>
  <height>34</height>
  <uuid>{38733e9e-6260-4ebc-9124-6042c99729d2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.190</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>211</x>
  <y>332</y>
  <width>187</width>
  <height>33</height>
  <uuid>{cd341f6c-b306-496b-9fbe-71553da12e00}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Aspiration noise</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Cutoff1</objectName>
  <x>43</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{06d7238c-0da6-40ea-bf08-cb6e4bc79f8b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>250.00000000</minimum>
  <maximum>1200.00000000</maximum>
  <value>943.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Cutoff1</objectName>
  <x>20</x>
  <y>435</y>
  <width>68</width>
  <height>33</height>
  <uuid>{3295fa38-6aed-4320-b28d-151213868426}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>944</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Reson1</objectName>
  <x>93</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3d0983f2-affa-44a2-b42f-218508a858cb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.50000000</minimum>
  <maximum>30.00000000</maximum>
  <value>12.59500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Reson1</objectName>
  <x>80</x>
  <y>435</y>
  <width>57</width>
  <height>34</height>
  <uuid>{61fe088c-82b2-46d4-bfa2-d72f54632d12}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>12.6</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>1</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Cutoff2</objectName>
  <x>232</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{981b6cc8-b6a4-4a7a-9fad-016cb38601c0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>800.00000000</minimum>
  <maximum>3200.00000000</maximum>
  <value>2600.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Cutoff2</objectName>
  <x>216</x>
  <y>435</y>
  <width>60</width>
  <height>32</height>
  <uuid>{f14e8678-9689-4206-adbf-0f82d47ed2da}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>2600</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Reson2</objectName>
  <x>289</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{14e724be-7c83-437a-ad88-ffbb3c3b9b6c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.50000000</minimum>
  <maximum>30.00000000</maximum>
  <value>10.82500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Reson2</objectName>
  <x>278</x>
  <y>435</y>
  <width>54</width>
  <height>34</height>
  <uuid>{9dc7d65d-2f09-42e6-a83c-9153878380a5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>10.8</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>1</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Cutoff3</objectName>
  <x>420</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a6388325-f9d1-495d-8d33-3ff029b25a55}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>2400.00000000</minimum>
  <maximum>3500.00000000</maximum>
  <value>3379.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Cutoff3</objectName>
  <x>404</x>
  <y>435</y>
  <width>60</width>
  <height>33</height>
  <uuid>{c0b9c7e9-5f92-4310-8aeb-1b984ee0debe}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>3379</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Reson3</objectName>
  <x>472</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{85b92dec-b319-4f02-ab73-4693be8979bb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.50000000</minimum>
  <maximum>30.00000000</maximum>
  <value>22.62500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Reson3</objectName>
  <x>465</x>
  <y>435</y>
  <width>55</width>
  <height>34</height>
  <uuid>{105784c1-a8e2-4e8f-ad99-0491246dc4fb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>22.6</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>1</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>FormAmp1</objectName>
  <x>144</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{ec3d8b89-15db-4786-a099-88e621fef341}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.68000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>FormAmp1</objectName>
  <x>125</x>
  <y>435</y>
  <width>56</width>
  <height>33</height>
  <uuid>{b0004b3d-ef72-41d0-854d-25082740501a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.680</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>FormAmp2</objectName>
  <x>343</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{0f16e259-5c2c-4a3d-933b-b87d6c06a17c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.96000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>FormAmp2</objectName>
  <x>328</x>
  <y>435</y>
  <width>54</width>
  <height>34</height>
  <uuid>{30851580-6fe8-4404-b504-3646495d35ac}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.960</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>FormAmp3</objectName>
  <x>530</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{ae3d1154-81df-47e7-8a75-98fc07158a53}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.66000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>FormAmp3</objectName>
  <x>516</x>
  <y>435</y>
  <width>55</width>
  <height>34</height>
  <uuid>{5dbae9d9-e74f-428e-a1da-6dd0a25db71f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.660</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Cutoff4</objectName>
  <x>608</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{666af323-63a7-40c5-87ce-0acf2c8cab2d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>3500.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>4280.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Cutoff4</objectName>
  <x>592</x>
  <y>435</y>
  <width>60</width>
  <height>33</height>
  <uuid>{e67f966b-a299-43d8-a1da-a9d54f9a7f22}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>4280</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>0</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>Reson4</objectName>
  <x>665</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{f42d227d-07ac-4ab8-9f7b-a5920a581e61}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.50000000</minimum>
  <maximum>50.00000000</maximum>
  <value>34.65500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Reson4</objectName>
  <x>655</x>
  <y>435</y>
  <width>55</width>
  <height>34</height>
  <uuid>{01add204-7be3-46ff-804b-af16f1de134c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>34.7</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>1</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBVSlider" version="2">
  <objectName>FormAmp4</objectName>
  <x>718</x>
  <y>464</y>
  <width>20</width>
  <height>100</height>
  <uuid>{7d904e2d-9815-4119-85c7-f5516527c8c5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.67000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>FormAmp4</objectName>
  <x>699</x>
  <y>435</y>
  <width>55</width>
  <height>34</height>
  <uuid>{896bc826-afa3-47db-8cec-be0e37fbb120}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>0.670</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>25</x>
  <y>400</y>
  <width>53</width>
  <height>27</height>
  <uuid>{775d31bd-ce9f-4f98-bbc8-403c5345d1fa}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Frek</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>82</x>
  <y>400</y>
  <width>48</width>
  <height>27</height>
  <uuid>{825031fe-94ed-4dba-ac14-ff26ea11b26f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>BW</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>134</x>
  <y>400</y>
  <width>54</width>
  <height>27</height>
  <uuid>{2b1b8d42-0516-4daf-b2b7-258982817483}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>218</x>
  <y>400</y>
  <width>48</width>
  <height>27</height>
  <uuid>{e29b1f0c-e56f-44cc-a4b9-9344b486c88d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Frek</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>277</x>
  <y>400</y>
  <width>48</width>
  <height>27</height>
  <uuid>{5aace3fc-affa-417f-826a-9d4bed5e11ba}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>BW</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>328</x>
  <y>400</y>
  <width>54</width>
  <height>28</height>
  <uuid>{e1887999-61d6-4cf9-becf-cf6d8917ffe8}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>409</x>
  <y>400</y>
  <width>48</width>
  <height>27</height>
  <uuid>{7fc23e47-5d3c-451c-b4ea-ff35506fc17f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Frek</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>462</x>
  <y>400</y>
  <width>48</width>
  <height>27</height>
  <uuid>{fd2866c6-7291-4e6c-ae44-95e934d220d8}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>BW</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>514</x>
  <y>400</y>
  <width>57</width>
  <height>28</height>
  <uuid>{e1c8078e-70fc-4b20-947a-d7ac6c224c54}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>595</x>
  <y>400</y>
  <width>48</width>
  <height>27</height>
  <uuid>{4522d977-d119-4571-9ed6-6a1b13f1951c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Frek</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>648</x>
  <y>400</y>
  <width>48</width>
  <height>27</height>
  <uuid>{829b12ed-8e57-4c56-a9d5-c1504fc0a5bd}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>BW</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>700</x>
  <y>400</y>
  <width>58</width>
  <height>26</height>
  <uuid>{174cf681-ab04-4564-bd2a-17c7f141bc38}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>Vol</objectName>
  <x>618</x>
  <y>250</y>
  <width>67</width>
  <height>66</height>
  <uuid>{92ce6e66-959c-4008-b746-b3bf5ec58319}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.29270000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>220</r>
   <g>135</g>
   <b>48</b>
  </color>
  <textcolor>#492d10</textcolor>
  <border>0</border>
  <borderColor>#492d10</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>f0</objectName>
  <x>540</x>
  <y>250</y>
  <width>65</width>
  <height>68</height>
  <uuid>{c4e01276-4397-4738-883e-f55ed93c22aa}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>90.00000000</minimum>
  <maximum>800.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>391.97332475</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>220</r>
   <g>135</g>
   <b>48</b>
  </color>
  <textcolor>#492d10</textcolor>
  <border>0</border>
  <borderColor>#492d10</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 --midi-velocity=5
</CsOptions>
<CsInstruments>
;************************************************************
;        FORMANT SYNTHESIZER WITH GLOTTAL PARAMETERS
;                  Andreas Bergsland, 2009
;************************************************************
       sr     = 44100
       ksmps  = 16
       nchnls = 2

; *****************************************************
;                               TRIGGER INSTRUMENT
;******************************************************

instr 1 ; MIDI triggered instrument (channel 1)
icps cpsmidi
outvalue "f0", icps
kOpenQ  invalue "OQ"
kSpeedQ invalue "SQ"
schedule 10, 0, 3, i(kOpenQ), i(kSpeedQ)
turnoff
endin

instr   9
;               Get value for global source
kOpenQ  invalue "OQ"
kSpeedQ invalue "SQ"
;               On value
kon             invalue "on"

;               Trigger play instrument
schedkwhen      kon, 2, 1, 10, 0, 3, kOpenQ, kSpeedQ
kon=1

endin


; *************************************************************
;                       FORMANT SYNTHESIZER INSTRUMENT
instr   10

;                       Get formant parameters
kcutoff1        invalue "Cutoff1"
kreson1 invalue "Reson1"
kcutoff2        invalue "Cutoff2"
kreson2 invalue "Reson2"
kcutoff3        invalue "Cutoff3"
kreson3 invalue "Reson3"
kcutoff4        invalue "Cutoff4"
kreson4 invalue "Reson4"

iflen   =       4096

;               Get glottal parameters
iOpenQ  =       p4
iSQ             =       p5 * 12/14              ; Speed quotient - compensate for the number of open vs closed segments in the ftable linseg

iOpen   =       iOpenQ * iflen
iClose  =       iflen - iOpen
ip              =       iOpen/26                        ; Calculate duration for segments in the open phase
iO              =       ip * iSQ                        ; Apply speed quotient for opening
iC              =       ip / iSQ                        ; and closing phase

iOp     =       14*iO                           ; Scale so that values fits the open phase
iCl     =       12*iC
iT      =       (iOp + iCl)/iOpen

iO      =       iO / iT                         ; Calulate open
iC      =       iC / iT                         ; and closed segments

;       Values for a glottal waveform taken from Inger Karlsson (1988), "Glottal waveform parameters for different speaker types" (Could be mapped more accurately)
i0      =       0       ;t1
i1      =       .02
i2      =       .05
i3      =       .1
i4      =       .15
i5      =       .24
i6      =       .33
i7      =       .45
i8      =       .575
i9      =       .645
i10     =       .775
i11     =       .845
i12     =       .945
i13     =       .985
i14     =       .99     ; ca.t2
i15     =       .95
i16     =       .8
i17     =       .57
i18     =       .3      ;ca.t3
i19     =       .11
i20     =       .06
i21     =       .04
i22     =       .02
i23     =       .01
i24     =       .002
i25     =       .001
i26     =       0       ;t4

;               Make ftable for glottal waveform
isource ftgen   0, 0, iflen, 7, i0, iO, i1, iO, i2, iO, i3, iO, i4, iO, i5, iO, i6, iO, i7, iO, i8, \
                                       iO, i9, iO,i10,iO,i11,iO,i12,iO,i13,iO,i14,iC,i15, iC, i16, iC, i17,\
                                       iC,i18,iC,i19,iC,i20,iC,i21,iC,i22,iC,i23,iC,i24,iC,i25,iC, i26, iClose, 0

kf0     invalue "f0"
kamp    linen   4000, .2, p3, .35


;***************************************************************
;                       JITTER, three different opcodes
kcpsMin =       8
kcpsMax =       20
kjitamp =       .025
kjit1 jspline kjitamp, kcpsMin, kcpsMax

kjitamp =       .027
kcpsMin =       2
kcpsMax =       20
kjit2   jitter  2.7, 2, 20

ktotamp =       .027
kamp1   =       .2
kcps1   =       1.5
kamp2   =       .25
kcps2   =       4.5
kamp3   =       .3
kcps3   =       15.5
kjit3   jitter2 ktotamp, kamp1, kcps1, kamp2, kcps2, kamp3, kcps3

kjitOn  invalue "JitOn"
kjit            =       kjit3 * kjitOn

;***************************************************************
;               VIBRATO

iSine   ftgen   0, 0, 1024, 10, 1
kvibamp expseg  0.001, p3*.3, 1.5, p3*.7, 2.5
ivibfrek        =               5.6
kvibrand        randh   .1, ivibfrek
kvibfrek        =               ivibfrek + kvibrand

kvibOn  invalue "Vib"
kvib            oscil   kvibamp * kvibOn, kvibfrek, iSine



;***************************************************************
;                       SHIMMER

kShimOn invalue "ShimOn"
iavgshim        =       (ampdb(0.39)/ampdb(0))-1
print   iavgshim
kshimamp        =       kamp * iavgshim * kShimOn
kcpsMin =       8
kcpsMAx =       20
kshim jspline kshimamp, kcpsMin, kcpsMax
;*****************************************************************

;*****************************************************************
;               Overshoot

kOShoot invalue "OShoot"
if0             =       i(kf0)
iOShoot =       i(kOShoot)
iamount =       .08 * if0 * iOShoot

kOShoot linseg  iamount, .06, 0, p3-.05, 0
;******************************************************************

; *****************************************************************
;               MAKE SOURCE SOUND

; Noise
kNoise  invalue "Noise"
anoise  rand    kamp * kNoise
anoise  butbp   anoise, 4500, 4000

; Glottal pulses
avoiced oscili  kamp + kshim, kf0 + (kjit*kf0) + kvib + kOShoot, isource

alyd    =       avoiced  + anoise
;******************************************************************
;               FORMANT FILTERS - reson with double filtering

aform1  reson   alyd,   kcutoff1, kreson1 * kcutoff1 / 100
aform1  reson   aform1, kcutoff1, kreson1 * kcutoff1 / 100
aform2  reson   alyd,   kcutoff2, kreson2 * kcutoff2 / 100
aform2  reson   aform2, kcutoff2, kreson2 * kcutoff2 / 100
aform3  reson   alyd,   kcutoff3, kreson3 * kcutoff3 / 100
aform3  reson   aform3, kcutoff3, kreson3 * kcutoff3 / 100
aform4  reson   alyd,   kcutoff4, kreson4 * kcutoff4 / 100
aform4  reson   aform4, kcutoff4, kreson4 * kcutoff4 / 100

;               add formant jitter (experimental)
kcutoff1        =       kcutoff1 + kcutoff1*kjit3*.3
kcutoff2        =       kcutoff2 + kcutoff2*kjit3*.3
kcutoff3        =       kcutoff3 + kcutoff3*kjit3*.3
kcutoff4        =       kcutoff4 + kcutoff4*kjit3*.3

;aform4 reson   alyd,   kcutoff4, kreson4 * kcutoff4 / 100
;aform3 reson   aform4, kcutoff3, kreson3 * kcutoff3 / 100
;aform2 reson   aform3, kcutoff2, kreson2 * kcutoff2 / 100
;aform1 reson   aform2, kcutoff1, kreson1 * kcutoff1 / 100

;               balance
abal1   balance aform1, alyd
abal2   balance aform2, alyd
abal3   balance aform3, alyd
abal4   balance aform4, alyd

;               get formant amps
kFamp1  invalue "FormAmp1"
kFamp2  invalue "FormAmp2"
kFamp3  invalue "FormAmp3"
kFamp4  invalue "FormAmp4"


;               Mix
afilt   =       abal1 * kFamp1 +abal2 * kFamp2 +abal3 * kFamp3 + abal4*kFamp4

;               Master Volume
kMasterVol invalue      "Vol"
aout            =       afilt * kMasterVol

;               View spectrum
dispfft afilt, 1, 2048 , .05, 0

outs    aout, aout

endin


</CsInstruments>
<CsScore>

i9 0 3000
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>433</x>
 <y>146</y>
 <width>789</width>
 <height>621</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>212</r>
  <g>198</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBGraph">
  <objectName/>
  <x>6</x>
  <y>4</y>
  <width>754</width>
  <height>230</height>
  <uuid>{18cfa587-24cd-4d57-85a2-4fb149824822}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>auto</modex>
  <modey>auto</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>on</objectName>
  <x>654</x>
  <y>329</y>
  <width>104</width>
  <height>30</height>
  <uuid>{e772e396-07d1-4fc7-a2ab-a7f75de51839}</uuid>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>OQ</objectName>
  <x>7</x>
  <y>249</y>
  <width>120</width>
  <height>20</height>
  <uuid>{ed66615b-352c-4bba-86c0-047060bcb717}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.01000000</minimum>
  <maximum>0.99000000</maximum>
  <value>0.58166667</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>OQ</objectName>
  <x>128</x>
  <y>242</y>
  <width>62</width>
  <height>34</height>
  <uuid>{17ac5668-ce2d-4af9-b65e-e0e4612ae64f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.582</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>16</fontsize>
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
  <objectName>SQ</objectName>
  <x>4</x>
  <y>288</y>
  <width>120</width>
  <height>20</height>
  <uuid>{d7218969-08b1-4bd7-a9a0-b628bc11de92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.80000000</minimum>
  <maximum>4.00000000</maximum>
  <value>2.93333333</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>SQ</objectName>
  <x>127</x>
  <y>282</y>
  <width>64</width>
  <height>34</height>
  <uuid>{0d2e784e-c496-48c0-b1e7-24f7372bf098}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2.933</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>16</fontsize>
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
  <objectName/>
  <x>188</x>
  <y>242</y>
  <width>188</width>
  <height>35</height>
  <uuid>{110eea63-47f6-4b77-8618-75983accf0e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Open Quotient (OQ)</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>16</fontsize>
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
  <objectName/>
  <x>189</x>
  <y>282</y>
  <width>189</width>
  <height>34</height>
  <uuid>{6b2d94b8-9878-4d4d-a9fb-40ad4a7f2591}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Speed Quotient (SQ)</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>16</fontsize>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>Vol</objectName>
  <x>614</x>
  <y>234</y>
  <width>67</width>
  <height>66</height>
  <uuid>{92ce6e66-959c-4008-b746-b3bf5ec58319}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50505100</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>5</x>
  <y>365</y>
  <width>178</width>
  <height>200</height>
  <uuid>{fcb57829-45a8-4dcb-b308-c9759c5116a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Formant 1</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>196</x>
  <y>365</y>
  <width>180</width>
  <height>200</height>
  <uuid>{b49cbccf-29fa-4e5d-a241-976f70d0bc96}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Formant 2</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>390</x>
  <y>365</y>
  <width>173</width>
  <height>200</height>
  <uuid>{c9090fc2-e24b-4f9a-a61e-0df7be4a4a56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Formant 3</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>574</x>
  <y>365</y>
  <width>178</width>
  <height>200</height>
  <uuid>{3eaa3afc-6844-4d09-b916-e3216228e124}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Formant 4</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>629</x>
  <y>301</y>
  <width>39</width>
  <height>30</height>
  <uuid>{3eefe31b-44dd-4ad9-be42-9bab11c88426}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Vol</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>f0</objectName>
  <x>547</x>
  <y>234</y>
  <width>65</width>
  <height>68</height>
  <uuid>{c4e01276-4397-4738-883e-f55ed93c22aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>90.00000000</minimum>
  <maximum>800.00000000</maximum>
  <value>452.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>561</x>
  <y>302</y>
  <width>39</width>
  <height>30</height>
  <uuid>{8d4841bd-9c74-449f-9f83-a536ba65d3f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>f0</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <objectName>f0</objectName>
  <x>543</x>
  <y>325</y>
  <width>84</width>
  <height>29</height>
  <uuid>{0d162f00-d220-41c4-bb2c-a86310f8a725}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>452.100</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>Vib</objectName>
  <x>394</x>
  <y>242</y>
  <width>20</width>
  <height>20</height>
  <uuid>{578bf449-45b0-4a38-a845-d8f0fdeb40a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>416</x>
  <y>240</y>
  <width>78</width>
  <height>31</height>
  <uuid>{8f2ea0c8-50aa-4c3e-a4be-2dd68e87a370}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Vibr</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>JitOn</objectName>
  <x>393</x>
  <y>267</y>
  <width>20</width>
  <height>20</height>
  <uuid>{41210d11-ef8e-495a-8b5b-8eb153e98144}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>ShimOn</objectName>
  <x>394</x>
  <y>291</y>
  <width>20</width>
  <height>20</height>
  <uuid>{daac4edc-6702-4f9b-a209-edf0e249dad1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>417</x>
  <y>265</y>
  <width>78</width>
  <height>31</height>
  <uuid>{3615fe9d-802f-4ec7-9994-19b7cc60e99d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Jit</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>417</x>
  <y>288</y>
  <width>84</width>
  <height>31</height>
  <uuid>{14eeb36a-51d4-4b86-9f99-5a974e89bf14}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Shim</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>OShoot</objectName>
  <x>394</x>
  <y>315</y>
  <width>20</width>
  <height>20</height>
  <uuid>{512c9266-c506-4055-b72c-1e87eec9b966}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName/>
  <x>417</x>
  <y>313</y>
  <width>113</width>
  <height>31</height>
  <uuid>{8bb809a5-548c-47a7-90cf-852b385c12d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Overshoot</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Noise</objectName>
  <x>5</x>
  <y>330</y>
  <width>120</width>
  <height>20</height>
  <uuid>{af7dfd5c-edac-486c-8b48-ae459f14e99b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.20000000</maximum>
  <value>0.10833333</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Noise</objectName>
  <x>128</x>
  <y>322</y>
  <width>64</width>
  <height>34</height>
  <uuid>{38733e9e-6260-4ebc-9124-6042c99729d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.108</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>16</fontsize>
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
  <objectName/>
  <x>191</x>
  <y>322</y>
  <width>187</width>
  <height>33</height>
  <uuid>{cd341f6c-b306-496b-9fbe-71553da12e00}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Aspiration noise</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>16</fontsize>
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
  <objectName>Cutoff1</objectName>
  <x>31</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{06d7238c-0da6-40ea-bf08-cb6e4bc79f8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>250.00000000</minimum>
  <maximum>1200.00000000</maximum>
  <value>1143.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Cutoff1</objectName>
  <x>4</x>
  <y>419</y>
  <width>68</width>
  <height>33</height>
  <uuid>{3295fa38-6aed-4320-b28d-151213868426}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1143.000</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>Reson1</objectName>
  <x>81</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3d0983f2-affa-44a2-b42f-218508a858cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.50000000</minimum>
  <maximum>30.00000000</maximum>
  <value>30.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Reson1</objectName>
  <x>68</x>
  <y>418</y>
  <width>57</width>
  <height>34</height>
  <uuid>{61fe088c-82b2-46d4-bfa2-d72f54632d12}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>30.000</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>Cutoff2</objectName>
  <x>220</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{981b6cc8-b6a4-4a7a-9fad-016cb38601c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>800.00000000</minimum>
  <maximum>3200.00000000</maximum>
  <value>2816.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Cutoff2</objectName>
  <x>204</x>
  <y>418</y>
  <width>60</width>
  <height>32</height>
  <uuid>{f14e8678-9689-4206-adbf-0f82d47ed2da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2816.000</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>Reson2</objectName>
  <x>277</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{14e724be-7c83-437a-ad88-ffbb3c3b9b6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.50000000</minimum>
  <maximum>30.00000000</maximum>
  <value>30.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Reson2</objectName>
  <x>266</x>
  <y>418</y>
  <width>54</width>
  <height>34</height>
  <uuid>{9dc7d65d-2f09-42e6-a83c-9153878380a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>30.000</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>Cutoff3</objectName>
  <x>408</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a6388325-f9d1-495d-8d33-3ff029b25a55}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>2400.00000000</minimum>
  <maximum>3500.00000000</maximum>
  <value>3500.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Cutoff3</objectName>
  <x>394</x>
  <y>418</y>
  <width>60</width>
  <height>33</height>
  <uuid>{c0b9c7e9-5f92-4310-8aeb-1b984ee0debe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3500.000</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>Reson3</objectName>
  <x>460</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{85b92dec-b319-4f02-ab73-4693be8979bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.50000000</minimum>
  <maximum>30.00000000</maximum>
  <value>30.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Reson3</objectName>
  <x>449</x>
  <y>418</y>
  <width>55</width>
  <height>34</height>
  <uuid>{105784c1-a8e2-4e8f-ad99-0491246dc4fb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>30.000</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>FormAmp1</objectName>
  <x>132</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{ec3d8b89-15db-4786-a099-88e621fef341}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.68000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FormAmp1</objectName>
  <x>126</x>
  <y>418</y>
  <width>56</width>
  <height>33</height>
  <uuid>{b0004b3d-ef72-41d0-854d-25082740501a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.680</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>FormAmp2</objectName>
  <x>331</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{0f16e259-5c2c-4a3d-933b-b87d6c06a17c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FormAmp2</objectName>
  <x>318</x>
  <y>418</y>
  <width>54</width>
  <height>34</height>
  <uuid>{30851580-6fe8-4404-b504-3646495d35ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.100</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>FormAmp3</objectName>
  <x>518</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{ae3d1154-81df-47e7-8a75-98fc07158a53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.04000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FormAmp3</objectName>
  <x>506</x>
  <y>418</y>
  <width>55</width>
  <height>34</height>
  <uuid>{5dbae9d9-e74f-428e-a1da-6dd0a25db71f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.040</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>Cutoff4</objectName>
  <x>596</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{666af323-63a7-40c5-87ce-0acf2c8cab2d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>3500.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>4955.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Cutoff4</objectName>
  <x>582</x>
  <y>418</y>
  <width>60</width>
  <height>33</height>
  <uuid>{e67f966b-a299-43d8-a1da-a9d54f9a7f22}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4955.000</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>Reson4</objectName>
  <x>653</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{f42d227d-07ac-4ab8-9f7b-a5920a581e61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.50000000</minimum>
  <maximum>50.00000000</maximum>
  <value>50.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Reson4</objectName>
  <x>636</x>
  <y>418</y>
  <width>55</width>
  <height>34</height>
  <uuid>{01add204-7be3-46ff-804b-af16f1de134c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>50.000</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>FormAmp4</objectName>
  <x>706</x>
  <y>455</y>
  <width>20</width>
  <height>100</height>
  <uuid>{7d904e2d-9815-4119-85c7-f5516527c8c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.02000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FormAmp4</objectName>
  <x>689</x>
  <y>418</y>
  <width>55</width>
  <height>34</height>
  <uuid>{896bc826-afa3-47db-8cec-be0e37fbb120}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.020</label>
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
  <x>17</x>
  <y>398</y>
  <width>53</width>
  <height>27</height>
  <uuid>{775d31bd-ce9f-4f98-bbc8-403c5345d1fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Frek</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <x>74</x>
  <y>398</y>
  <width>48</width>
  <height>27</height>
  <uuid>{825031fe-94ed-4dba-ac14-ff26ea11b26f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>BW</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <x>126</x>
  <y>398</y>
  <width>54</width>
  <height>27</height>
  <uuid>{2b1b8d42-0516-4daf-b2b7-258982817483}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amp</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <x>210</x>
  <y>398</y>
  <width>48</width>
  <height>27</height>
  <uuid>{e29b1f0c-e56f-44cc-a4b9-9344b486c88d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Frek</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <x>269</x>
  <y>398</y>
  <width>48</width>
  <height>27</height>
  <uuid>{5aace3fc-affa-417f-826a-9d4bed5e11ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>BW</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <y>398</y>
  <width>54</width>
  <height>28</height>
  <uuid>{e1887999-61d6-4cf9-becf-cf6d8917ffe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amp</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <x>401</x>
  <y>398</y>
  <width>48</width>
  <height>27</height>
  <uuid>{7fc23e47-5d3c-451c-b4ea-ff35506fc17f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Frek</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <x>454</x>
  <y>398</y>
  <width>48</width>
  <height>27</height>
  <uuid>{fd2866c6-7291-4e6c-ae44-95e934d220d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>BW</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <x>506</x>
  <y>398</y>
  <width>57</width>
  <height>28</height>
  <uuid>{e1c8078e-70fc-4b20-947a-d7ac6c224c54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amp</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <x>587</x>
  <y>398</y>
  <width>48</width>
  <height>27</height>
  <uuid>{4522d977-d119-4571-9ed6-6a1b13f1951c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Frek</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <x>640</x>
  <y>398</y>
  <width>48</width>
  <height>27</height>
  <uuid>{829b12ed-8e57-4c56-a9d5-c1504fc0a5bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>BW</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
  <x>692</x>
  <y>398</y>
  <width>58</width>
  <height>26</height>
  <uuid>{174cf681-ab04-4564-bd2a-17c7f141bc38}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amp</label>
  <alignment>left</alignment>
  <font>MS Shell Dlg 2</font>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 433 146 789 621
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>
<MacGUI>
ioView background {54484, 50886, 40092}
ioGraph {6, 4} {754, 230} table 0.000000 1.000000 
ioButton {654, 329} {104, 30} value 1.000000 "on" "Play" "/" 
ioSlider {7, 249} {120, 20} 0.010000 0.990000 0.581667 OQ
ioText {128, 242} {62, 34} display 0.582000 0.00100 "OQ" left "Helvetica" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.582
ioSlider {4, 288} {120, 20} 0.800000 4.000000 2.933333 SQ
ioText {127, 282} {64, 34} display 2.933000 0.00100 "SQ" left "Helvetica" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.933
ioText {188, 242} {171, 36} display 0.000000 0.00100 "" left "Helvetica" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Open Quotient (OQ)
ioText {188, 282} {171, 36} display 0.000000 0.00100 "" left "Helvetica" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Speed Quotient (SQ)
ioKnob {614, 234} {67, 66} 1.000000 0.000000 0.010000 0.505051 Vol
ioText {5, 365} {178, 200} display 0.000000 0.00100 "" left "Helvetica" 22 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Formant 1
ioText {196, 365} {180, 200} display 0.000000 0.00100 "" left "Helvetica" 22 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Formant 2
ioText {390, 365} {173, 200} display 0.000000 0.00100 "" left "Helvetica" 22 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Formant 3
ioText {574, 365} {178, 209} display 0.000000 0.00100 "" left "MS Shell Dlg 2" 22 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Formant 4
ioText {613, 301} {39, 30} display 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Vol
ioKnob {547, 234} {65, 68} 800.000000 90.000000 0.010000 452.100000 f0
ioText {545, 302} {39, 30} display 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder f0
ioText {527, 325} {84, 29} display 452.100000 0.00100 "f0" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 452.100
ioCheckbox {394, 242} {20, 20} on Vib
ioText {389, 240} {78, 31} display 0.000000 0.00100 "" left "DejaVu Sans" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Vibr
ioCheckbox {393, 267} {20, 20} off JitOn
ioCheckbox {394, 291} {20, 20} off ShimOn
ioText {390, 265} {78, 31} display 0.000000 0.00100 "" left "DejaVu Sans" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Jit
ioText {390, 288} {84, 31} display 0.000000 0.00100 "" left "DejaVu Sans" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Shim
ioCheckbox {394, 315} {20, 20} off OShoot
ioText {390, 313} {113, 31} display 0.000000 0.00100 "" left "DejaVu Sans" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Overshoot
ioSlider {5, 330} {120, 20} 0.000000 0.200000 0.108333 Noise
ioText {128, 322} {64, 34} display 0.108000 0.00100 "Noise" left "Helvetica" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.108
ioText {190, 323} {171, 36} display 0.000000 0.00100 "" left "Helvetica" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Aspiration noise
ioSlider {31, 455} {20, 100} 250.000000 1200.000000 1143.000000 Cutoff1
ioText {4, 419} {68, 33} display 1143.000000 0.00100 "Cutoff1" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1143.000
ioSlider {81, 455} {20, 100} 0.500000 30.000000 30.000000 Reson1
ioText {68, 418} {57, 34} display 30.000000 0.00100 "Reson1" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 30.000
ioSlider {220, 455} {20, 100} 800.000000 3200.000000 2816.000000 Cutoff2
ioText {204, 418} {60, 32} display 2816.000000 0.00100 "Cutoff2" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2816.000
ioSlider {277, 455} {20, 100} 0.500000 30.000000 30.000000 Reson2
ioText {266, 418} {54, 34} display 30.000000 0.00100 "Reson2" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 30.000
ioSlider {408, 455} {20, 100} 2400.000000 3500.000000 3500.000000 Cutoff3
ioText {394, 416} {60, 33} display 3500.000000 0.00100 "Cutoff3" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3500.000
ioSlider {460, 455} {20, 100} 0.500000 30.000000 30.000000 Reson3
ioText {449, 418} {55, 34} display 30.000000 0.00100 "Reson3" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 30.000
ioSlider {132, 455} {20, 100} 0.000000 1.000000 0.680000 FormAmp1
ioText {124, 418} {56, 33} display 0.680000 0.00100 "FormAmp1" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.680
ioSlider {331, 455} {20, 100} 0.000000 1.000000 0.100000 FormAmp2
ioText {318, 418} {54, 34} display 0.100000 0.00100 "FormAmp2" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.100
ioSlider {518, 455} {20, 100} 0.000000 1.000000 0.040000 FormAmp3
ioText {501, 418} {55, 34} display 0.040000 0.00100 "FormAmp3" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.040
ioSlider {596, 455} {20, 100} 3500.000000 5000.000000 4955.000000 Cutoff4
ioText {582, 418} {60, 33} display 4955.000000 0.00100 "Cutoff4" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4955.000
ioSlider {653, 455} {20, 100} 0.500000 50.000000 50.000000 Reson4
ioText {636, 418} {55, 34} display 50.000000 0.00100 "Reson4" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 50.000
ioSlider {706, 455} {20, 100} 0.000000 1.000000 0.020000 FormAmp4
ioText {689, 418} {55, 34} display 0.020000 0.00100 "FormAmp4" left "Helvetica" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.020
ioText {21, 399} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frek
ioText {74, 398} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder BW
ioText {126, 398} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {210, 403} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frek
ioText {269, 402} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder BW
ioText {320, 403} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {401, 405} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frek
ioText {454, 404} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder BW
ioText {506, 404} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {587, 409} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frek
ioText {640, 408} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder BW
ioText {692, 408} {48, 27} label 0.000000 0.00100 "" left "MS Shell Dlg 2" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
</MacGUI>

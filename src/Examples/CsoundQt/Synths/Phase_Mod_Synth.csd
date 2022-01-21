<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 --midi-velocity=5
</CsOptions>
<CsInstruments>

; Make sure CsOptions are not ignored in the preferences,
; Otherwise Realtime MIDI input will not work.

sr = 44100
ksmps = 256
nchnls = 2
0dbfs = 1

chn_k "op7amp", 3
chn_k  "op7ratio", 3

chn_k  "op7att", 3
chn_k  "op7dec", 3
chn_k  "op7sus", 3
chn_k  "op7rel", 3

chn_k  "op6amp", 3
chn_k  "op6ratio", 3

chn_k  "op6att", 3
chn_k  "op6dec", 3
chn_k  "op6sus", 3
chn_k  "op6rel", 3

chn_k  "op5amp", 3
chn_k  "op5ratio", 3

chn_k  "op5att", 3
chn_k  "op5dec", 3
chn_k  "op5sus", 3
chn_k  "op5rel", 3

chn_k  "op4amp", 3
chn_k  "op4ratio", 3

chn_k  "op4att", 3
chn_k  "op4dec", 3
chn_k  "op4sus", 3
chn_k  "op4rel", 3

chn_k  "op3amp", 3
chn_k  "op3ratio", 3

chn_k  "op3att", 3
chn_k  "op3dec", 3
chn_k  "op3sus", 3
chn_k  "op3rel", 3

chn_k  "op2amp", 3
chn_k  "op2ratio", 3

chn_k  "op2att", 3
chn_k  "op2dec", 3
chn_k  "op2sus", 3
chn_k  "op2rel", 3

chn_k  "op1amp", 3
chn_k  "op1ratio", 3

chn_k  "op1att", 3
chn_k  "op1dec", 3
chn_k  "op1sus", 3
chn_k  "op1rel", 3

chn_k "fb1", 3

instr 1
;icps cpsmidi
icps = p4

kop7amp chnget "op7amp"
kop7ratio chnget "op7ratio"

kop7att chnget "op7att"
kop7dec chnget "op7dec"
kop7sus chnget "op7sus"
kop7rel chnget "op7rel"

kop6amp chnget "op6amp"
kop6ratio chnget "op6ratio"

kop6att chnget "op6att"
kop6dec chnget "op6dec"
kop6sus chnget "op6sus"
kop6rel chnget "op6rel"

kop5amp chnget "op5amp"
kop5ratio chnget "op5ratio"

kop5att chnget "op5att"
kop5dec chnget "op5dec"
kop5sus chnget "op5sus"
kop5rel chnget "op5rel"

kop4amp chnget "op4amp"
kop4ratio chnget "op4ratio"

kop4att chnget "op4att"
kop4dec chnget "op4dec"
kop4sus chnget "op4sus"
kop4rel chnget "op4rel"

kop3amp chnget "op3amp"
kop3ratio chnget "op3ratio"

kop3att chnget "op3att"
kop3dec chnget "op3dec"
kop3sus chnget "op3sus"
kop3rel chnget "op3rel"

kop2amp chnget "op2amp"
kop2ratio chnget "op2ratio"

kop2att chnget "op2att"
kop2dec chnget "op2dec"
kop2sus chnget "op2sus"
kop2rel chnget "op2rel"

kop1amp chnget "op1amp"
kop1ratio chnget "op1ratio"

kop1att chnget "op1att"
kop1dec chnget "op1dec"
kop1sus chnget "op1sus"
kop1rel chnget "op1rel"

kfb1 chnget "fb1"
aop6 init 0

afase7 phasor icps*kop7ratio 
aop7 table3 afase7+ (kfb1*aop6), 1, 1, 0, 1
aenv7 madsr i(kop7att), i(kop7dec), i(kop7sus), i(kop7rel)

afase6 phasor icps*kop6ratio
aop6 table3 afase6+(aop7*kop7amp*aenv7), 1, 1, 0, 1
aenv6 madsr i(kop6att), i(kop6dec), i(kop6sus), i(kop6rel)

afase5 phasor icps*kop5ratio
aop5 table3 afase5, 1, 1, 0, 1
aenv5 madsr i(kop5att), i(kop5dec), i(kop5sus), i(kop5rel)

afase4 phasor icps*kop4ratio
aop4 table3 afase4+(aop5*kop5amp*aenv5), 1, 1, 0, 1
aenv4 madsr i(kop4att), i(kop4dec), i(kop4sus), i(kop4rel)

afase3 phasor icps*kop3ratio
aop3 table3 afase3, 1, 1, 0, 1
aenv3 madsr i(kop3att), i(kop3dec), i(kop3sus), i(kop3rel)

afase2 phasor icps*kop2ratio
aop2 table3 afase2+(aop3*kop3amp*aenv3), 1, 1, 0, 1
aenv2 madsr i(kop2att), i(kop2dec), i(kop2sus), i(kop2rel)

afase1 phasor icps*kop1ratio
aop1 table3 afase1+(aop2*kop2amp*aenv2)+(aop4*kop4amp*aenv4), 1, 1, 0, 1
aenv1 madsr i(kop1att), i(kop1dec), i(kop1sus), i(kop1rel)

outs (aop1*kop1amp*aenv1) + (aop6*kop6amp*aenv6), (aop1*kop1amp*aenv1) + (aop6*kop6amp*aenv6)
endin

instr 99 ; randomize harmonic
krand random 0, 1
chnset  krand, "op7amp"
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
chnset  krand, "op7ratio"

krand random 0.01, 2
chnset  krand, "op7att"
krand random 0.01, 1
chnset  krand, "op7dec"
krand random 0.01, 1
chnset  krand, "op7sus"
krand random 0.01, 2
chnset  krand, "op7rel"

krand random 0, 1
chnset  krand, "op6amp"
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
chnset  krand, "op6ratio"

krand random 0.01, 2
chnset  krand, "op6att"
krand random 0.01, 1
chnset  krand, "op6dec"
krand random 0.01, 1
chnset  krand, "op6sus"
krand random 0.01, 2
chnset  krand, "op6rel"

krand random 0, 1
chnset  krand, "op5amp"
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
chnset  krand, "op5ratio"

krand random 0.01, 2
chnset  krand, "op5att"
krand random 0.01, 1
chnset  krand, "op5dec"
krand random 0.01, 1
chnset  krand, "op5sus"
krand random 0.01, 2
chnset  krand, "op5rel"

krand random 0, 1
chnset  krand, "op4amp"
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
chnset  krand, "op4ratio"

krand random 0.01, 2
chnset  krand, "op4att"
chnset  krand, "op4dec"
chnset  krand, "op4sus"
krand random 0.01, 2
chnset  krand, "op4rel"

krand random 0, 1
chnset  krand, "op3amp"
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
chnset  krand, "op3ratio"

krand random 0.01, 2
chnset  krand, "op3att"
krand random 0.01, 1
chnset  krand, "op3dec"
krand random 0.01, 1
chnset  krand, "op3sus"
krand random 0.01, 2
chnset  krand, "op3rel"

krand random 0, 1
chnset  krand, "op2amp"
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
chnset  krand, "op2ratio"

krand random 0.01, 2
chnset  krand, "op2att"
krand random 0.01, 1
chnset  krand, "op2dec"
krand random 0.01, 1
chnset  krand, "op2sus"
krand random 0.01, 2
chnset  krand, "op2rel"

krand random 0, 1
chnset  krand, "op1amp"
krand random -6, 6
krand = int(krand)
krand = (krand < 0 ? 1/krand : krand)
krand = (krand == 0 ? 1 : abs(krand))
chnset  krand, "op1ratio"

krand random 0.01, 2
chnset  krand, "op1att"
krand random 0.01, 1
chnset  krand, "op1dec"
krand random 0.01, 1
chnset  krand, "op1sus"
krand random 0.01, 2
chnset  krand, "op1rel"
krand random 0, 0.05
chnset  krand, "fb1"

turnoff
endin

instr 100 ; randomize
krand random 0, 1
chnset  krand, "op7amp"
krand random 0.1, 6
chnset  krand, "op7ratio"

krand random 0.01, 2
chnset  krand, "op7att"
krand random 0.01, 1
chnset  krand, "op7dec"
krand random 0.01, 1
chnset  krand, "op7sus"
krand random 0.01, 2
chnset  krand, "op7rel"

krand random 0, 1
chnset  krand, "op6amp"
krand random 0.1, 6
chnset  krand, "op6ratio"

krand random 0.01, 2
chnset  krand, "op6att"
krand random 0.01, 1
chnset  krand, "op6dec"
krand random 0.01, 1
chnset  krand, "op6sus"
krand random 0.01, 2
chnset  krand, "op6rel"

krand random 0, 1
chnset  krand, "op5amp"
krand random 0.1, 6
chnset  krand, "op5ratio"

krand random 0.01, 2
chnset  krand, "op5att"
krand random 0.01, 1
chnset  krand, "op5dec"
krand random 0.01, 1
chnset  krand, "op5sus"
krand random 0.01, 2
chnset  krand, "op5rel"

krand random 0, 1
chnset  krand, "op4amp"
krand random 0.1, 6
chnset  krand, "op4ratio"

krand random 0.01, 2
chnset  krand, "op4att"
chnset  krand, "op4dec"
chnset  krand, "op4sus"
krand random 0.01, 2
chnset  krand, "op4rel"

krand random 0, 1
chnset  krand, "op3amp"
krand random -6, 6
chnset  krand, "op3ratio"

krand random 0.01, 2
chnset  krand, "op3att"
krand random 0.01, 1
chnset  krand, "op3dec"
krand random 0.01, 1
chnset  krand, "op3sus"
krand random 0.01, 2
chnset  krand, "op3rel"

krand random 0, 1
chnset  krand, "op2amp"
krand random 0.1, 6
chnset  krand, "op2ratio"

krand random 0.01, 2
chnset  krand, "op2att"
krand random 0.01, 1
chnset  krand, "op2dec"
krand random 0.01, 1
chnset  krand, "op2sus"
krand random 0.01, 2
chnset  krand, "op2rel"

krand random 0, 1
chnset  krand, "op1amp"
krand random 0.1, 6
chnset  krand, "op1ratio"

krand random 0.01, 2
chnset  krand, "op1att"
krand random 0.01, 1
chnset  krand, "op1dec"
krand random 0.01, 1
chnset  krand, "op1sus"
krand random 0.01, 2
chnset  krand, "op1rel"
krand random 0, 0.1
chnset  krand, "fb1"

turnoff
endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1
f 0 3600
e
</CsScore>
</CsoundSynthesizer>













<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>96</x>
 <y>81</y>
 <width>782</width>
 <height>648</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>125</r>
  <g>162</g>
  <b>160</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>5</y>
  <width>653</width>
  <height>64</height>
  <uuid>{b3786a91-65c2-4a82-aca2-9c3c6cf79bb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Phase ModulationSynth</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>40</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>176</r>
   <g>174</g>
   <b>127</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>8</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>118</x>
  <y>229</y>
  <width>20</width>
  <height>36</height>
  <uuid>{79ded5ea-d436-477d-bea5-e060d85e7ce8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>342</x>
  <y>228</y>
  <width>20</width>
  <height>36</height>
  <uuid>{89ab4214-a85b-4e6b-816a-edeab338e238}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>23</x>
  <y>77</y>
  <width>207</width>
  <height>157</height>
  <uuid>{77b2a162-a2a2-42a6-8f0e-c561dc532f65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP3</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op3amp</objectName>
  <x>35</x>
  <y>102</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a4d4c497-04d4-4b7d-ad51-0f8832cb64bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.60793877</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op3att</objectName>
  <x>130</x>
  <y>100</y>
  <width>20</width>
  <height>100</height>
  <uuid>{b418386f-afe6-4d3c-b8d6-c6c96885e9ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>3.00000000</maximum>
  <value>0.87604076</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op3dec</objectName>
  <x>154</x>
  <y>99</y>
  <width>20</width>
  <height>100</height>
  <uuid>{f2ac6272-b33d-44fc-bb1e-fe52087e3a2b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>2.00000000</maximum>
  <value>0.68532342</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op3sus</objectName>
  <x>177</x>
  <y>100</y>
  <width>20</width>
  <height>100</height>
  <uuid>{8052b29d-d6ae-4249-b9cd-1788a2faf77c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.87491655</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op3rel</objectName>
  <x>201</x>
  <y>100</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3efde0c1-5828-4875-a997-174989989aa9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>4.00000000</maximum>
  <value>0.24683115</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>op3ratio</objectName>
  <x>57</x>
  <y>134</y>
  <width>67</width>
  <height>25</height>
  <uuid>{fa34129e-d983-460c-bd0e-89fb3e798bcb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Noto Sans</font>
  <fontsize>8</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>251</x>
  <y>78</y>
  <width>205</width>
  <height>154</height>
  <uuid>{a29dadfa-06d3-42ff-9be7-2c2b665c6457}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP5</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op5amp</objectName>
  <x>265</x>
  <y>102</y>
  <width>20</width>
  <height>100</height>
  <uuid>{17b249bd-27ed-44c7-9bac-a847a81165e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.71242875</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op5att</objectName>
  <x>357</x>
  <y>100</y>
  <width>20</width>
  <height>100</height>
  <uuid>{cba3fee2-d2a5-41b2-8842-34be212fa82a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>3.00000000</maximum>
  <value>1.51931179</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op5dec</objectName>
  <x>380</x>
  <y>100</y>
  <width>20</width>
  <height>100</height>
  <uuid>{f0305ec9-814b-4107-a9b5-55a5a13f0118}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>2.00000000</maximum>
  <value>0.76090300</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op5sus</objectName>
  <x>403</x>
  <y>100</y>
  <width>20</width>
  <height>100</height>
  <uuid>{9f495b69-cdca-43c7-bc92-f26d9995caed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.27295068</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op5rel</objectName>
  <x>428</x>
  <y>100</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3f29a847-8cf1-4076-9a69-e88b5360a810}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>4.00000000</maximum>
  <value>0.61171556</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>op5ratio</objectName>
  <x>288</x>
  <y>130</y>
  <width>66</width>
  <height>25</height>
  <uuid>{2ea377f7-6c31-4556-8e26-e47d9b6c000a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Noto Sans</font>
  <fontsize>8</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>129</x>
  <y>201</y>
  <width>20</width>
  <height>24</height>
  <uuid>{ef04fec4-5097-41de-b84c-782d4c63ae2f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>154</x>
  <y>200</y>
  <width>20</width>
  <height>24</height>
  <uuid>{dc9bad3e-fad8-4dc0-b647-422ed5adde6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>177</x>
  <y>201</y>
  <width>20</width>
  <height>24</height>
  <uuid>{66e15fa8-27eb-46e1-9cdb-f830f097d031}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>201</x>
  <y>201</y>
  <width>20</width>
  <height>24</height>
  <uuid>{c7195432-9a95-4ffe-a035-6d524879cf6d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>30</x>
  <y>206</y>
  <width>41</width>
  <height>23</height>
  <uuid>{3c15890b-b431-4e39-ad32-10d6aec01137}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>57</x>
  <y>160</y>
  <width>69</width>
  <height>24</height>
  <uuid>{50d05735-5c47-4ef0-90be-4a5c28c26b38}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>357</x>
  <y>201</y>
  <width>20</width>
  <height>24</height>
  <uuid>{890cf939-2a60-45f7-bf80-ced55467d308}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>381</x>
  <y>201</y>
  <width>20</width>
  <height>24</height>
  <uuid>{8bc430eb-9120-43ae-bc3d-43bbab4d845c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>404</x>
  <y>201</y>
  <width>20</width>
  <height>24</height>
  <uuid>{4e94aaf2-e19a-4f03-8395-077ac582c51c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>429</x>
  <y>201</y>
  <width>20</width>
  <height>24</height>
  <uuid>{9d569d13-5bbd-4898-9be6-8b31eddb51b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>258</x>
  <y>201</y>
  <width>41</width>
  <height>23</height>
  <uuid>{9f5f34a2-6968-464b-8e67-76c9d61ade3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>287</x>
  <y>155</y>
  <width>69</width>
  <height>24</height>
  <uuid>{0f8604e0-9429-4fdd-89be-0315b4a8193e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>105</x>
  <y>414</y>
  <width>20</width>
  <height>36</height>
  <uuid>{c40e8881-b4e1-4180-b2fb-b50db212908f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>346</x>
  <y>414</y>
  <width>20</width>
  <height>36</height>
  <uuid>{28d08405-51a5-4985-894a-343524746511}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>227</x>
  <y>441</y>
  <width>20</width>
  <height>36</height>
  <uuid>{b5b54ae5-3252-4061-a01b-a7049dcac1db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>105</x>
  <y>434</y>
  <width>262</width>
  <height>16</height>
  <uuid>{3ad14511-0d96-408a-b822-cc3dc6f02115}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>23</x>
  <y>262</y>
  <width>204</width>
  <height>157</height>
  <uuid>{dd32f942-5cbb-4f95-9825-913f98789a9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP2</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op2amp</objectName>
  <x>35</x>
  <y>285</y>
  <width>20</width>
  <height>100</height>
  <uuid>{a6a5a56d-13c6-4c09-b6e8-74086df6e352}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.82246149</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>op2ratio</objectName>
  <x>56</x>
  <y>316</y>
  <width>67</width>
  <height>26</height>
  <uuid>{dde869a9-5d2a-454c-bff8-b8d407d19e87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Noto Sans</font>
  <fontsize>8</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op2att</objectName>
  <x>127</x>
  <y>284</y>
  <width>20</width>
  <height>100</height>
  <uuid>{623cf6cd-548c-4212-ac65-a4761cfb5b7f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>3.00000000</maximum>
  <value>1.93253195</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op2dec</objectName>
  <x>150</x>
  <y>284</y>
  <width>20</width>
  <height>100</height>
  <uuid>{833bd2f5-fae9-441b-82ad-9117ffd29877}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>2.00000000</maximum>
  <value>0.21393649</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op2sus</objectName>
  <x>174</x>
  <y>284</y>
  <width>20</width>
  <height>100</height>
  <uuid>{d520e71a-b3e2-46d4-b0c6-688085fe5742}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.91956383</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op2rel</objectName>
  <x>197</x>
  <y>284</y>
  <width>20</width>
  <height>100</height>
  <uuid>{ced1a494-71e9-4bc0-9973-a872920a4473}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>4.00000000</maximum>
  <value>1.47231400</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>130</x>
  <y>471</y>
  <width>207</width>
  <height>148</height>
  <uuid>{38b062a3-b02c-46a8-8b6a-e6cab196bb10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP1</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op1amp</objectName>
  <x>145</x>
  <y>490</y>
  <width>20</width>
  <height>100</height>
  <uuid>{16c48afd-7c15-4e07-beee-ce56c7b61c80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.41843128</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>op1ratio</objectName>
  <x>167</x>
  <y>523</y>
  <width>67</width>
  <height>25</height>
  <uuid>{e1aa96cf-3e30-4ad2-93ec-1494a0d60079}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Noto Sans</font>
  <fontsize>8</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op1att</objectName>
  <x>237</x>
  <y>487</y>
  <width>20</width>
  <height>100</height>
  <uuid>{1a074887-a3a3-43ee-8de2-34b8e6a7a5a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>3.00000000</maximum>
  <value>0.25791028</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op1dec</objectName>
  <x>260</x>
  <y>487</y>
  <width>20</width>
  <height>100</height>
  <uuid>{e1352cbc-9c2a-4650-8957-fb055156903b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>2.00000000</maximum>
  <value>0.32575035</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op1sus</objectName>
  <x>283</x>
  <y>487</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3f7ea94f-e14d-4b53-8bbd-53563d0c23c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.26118517</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op1rel</objectName>
  <x>308</x>
  <y>487</y>
  <width>20</width>
  <height>100</height>
  <uuid>{9c657ab3-a738-40e2-92ae-b1128863fd78}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>4.00000000</maximum>
  <value>1.78432512</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>252</x>
  <y>263</y>
  <width>206</width>
  <height>155</height>
  <uuid>{356606cf-01fa-442e-a9ab-fb459546b3fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP4</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op4amp</objectName>
  <x>265</x>
  <y>286</y>
  <width>20</width>
  <height>100</height>
  <uuid>{56e321a8-c542-420c-a494-e759e36ea78a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.02822053</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>op4ratio</objectName>
  <x>289</x>
  <y>320</y>
  <width>66</width>
  <height>25</height>
  <uuid>{77ce606f-b1c5-4911-bf36-79ea1b8f50ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Noto Sans</font>
  <fontsize>8</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op4att</objectName>
  <x>359</x>
  <y>285</y>
  <width>20</width>
  <height>100</height>
  <uuid>{fec79e7f-6c43-482f-9fff-cedfc13eaea7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>3.00000000</maximum>
  <value>1.85546792</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op4dec</objectName>
  <x>382</x>
  <y>285</y>
  <width>20</width>
  <height>100</height>
  <uuid>{964db287-6df1-4fa8-baba-1e387d1fac12}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>2.00000000</maximum>
  <value>1.85546792</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op4sus</objectName>
  <x>405</x>
  <y>285</y>
  <width>20</width>
  <height>100</height>
  <uuid>{7844fda3-a049-4ec6-885f-cba693b160c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op4rel</objectName>
  <x>429</x>
  <y>285</y>
  <width>20</width>
  <height>100</height>
  <uuid>{37d2f1f5-7da1-460a-a8a0-9d70e19e7da0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>4.00000000</maximum>
  <value>0.80882120</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>126</x>
  <y>385</y>
  <width>20</width>
  <height>24</height>
  <uuid>{b1dc4c67-cba3-42ce-adb9-c6b944168df2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>150</x>
  <y>385</y>
  <width>20</width>
  <height>24</height>
  <uuid>{4b3fa88c-42bb-4680-85b5-6af3c93f5c2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>174</x>
  <y>385</y>
  <width>20</width>
  <height>24</height>
  <uuid>{e66791e9-d9d8-4304-827e-d759f1490bf2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>197</x>
  <y>385</y>
  <width>20</width>
  <height>24</height>
  <uuid>{4fd5c980-8bd6-410c-87a2-894ae57ccdf4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>30</x>
  <y>388</y>
  <width>41</width>
  <height>23</height>
  <uuid>{afe5eb18-768e-4717-b3da-a23ae0086a93}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>55</x>
  <y>342</y>
  <width>69</width>
  <height>24</height>
  <uuid>{185f48d8-f6d2-42de-a2a0-ad606ea9123b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>359</x>
  <y>387</y>
  <width>20</width>
  <height>24</height>
  <uuid>{d1dd7fa0-fecf-48de-bfb9-f1f2f936f9ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>383</x>
  <y>387</y>
  <width>20</width>
  <height>24</height>
  <uuid>{24f48f2a-cb3a-4366-9299-fe719719f4fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>406</x>
  <y>388</y>
  <width>20</width>
  <height>24</height>
  <uuid>{8956f647-16c2-4c0d-988b-7a5453b6a284}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>430</x>
  <y>387</y>
  <width>20</width>
  <height>24</height>
  <uuid>{80cafd39-6361-455e-9959-4bd6506f3ecf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>261</x>
  <y>390</y>
  <width>41</width>
  <height>23</height>
  <uuid>{16d50ce9-d0cb-45ba-b551-d6180c0038fa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>289</x>
  <y>345</y>
  <width>69</width>
  <height>24</height>
  <uuid>{06c3ffcc-53de-41e6-83df-c430abc944a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>236</x>
  <y>588</y>
  <width>20</width>
  <height>24</height>
  <uuid>{7889c373-cc15-4136-ace9-7be2d2d9e3db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>260</x>
  <y>588</y>
  <width>20</width>
  <height>24</height>
  <uuid>{ba42364c-3715-4f27-b15f-5bb18503f651}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>283</x>
  <y>588</y>
  <width>20</width>
  <height>24</height>
  <uuid>{e32346e4-bdef-4880-bce0-dcdfdc1dd403}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>307</x>
  <y>588</y>
  <width>20</width>
  <height>24</height>
  <uuid>{dfbf72b3-90bc-4cfa-9586-c8df21bae761}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>138</x>
  <y>591</y>
  <width>41</width>
  <height>23</height>
  <uuid>{b81b0da7-0b90-4e67-a963-420104b771a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>166</x>
  <y>546</y>
  <width>69</width>
  <height>24</height>
  <uuid>{14cbfca6-cc9f-40f5-acaf-e28ffcf88ad3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>560</x>
  <y>391</y>
  <width>19</width>
  <height>76</height>
  <uuid>{a0e2c705-7a10-4cf4-a414-37c078c2c6e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>470</x>
  <y>264</y>
  <width>205</width>
  <height>154</height>
  <uuid>{65ccd9f6-1c48-4bf7-8d28-276edfe01589}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP7</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op7amp</objectName>
  <x>484</x>
  <y>288</y>
  <width>20</width>
  <height>100</height>
  <uuid>{1713b2f6-0778-43b4-b81a-725331e94260}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.88287294</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op7att</objectName>
  <x>576</x>
  <y>286</y>
  <width>20</width>
  <height>100</height>
  <uuid>{608ebd5c-d7b3-4c9a-8075-2204844bc42c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>3.00000000</maximum>
  <value>1.85216427</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op7dec</objectName>
  <x>599</x>
  <y>286</y>
  <width>20</width>
  <height>100</height>
  <uuid>{5f20cb6a-ad07-4210-aaa1-a0ee628ee2d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>2.00000000</maximum>
  <value>0.12375984</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op7sus</objectName>
  <x>622</x>
  <y>286</y>
  <width>20</width>
  <height>100</height>
  <uuid>{dc16cdf0-7371-4027-bac0-7d26d9d21433}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.01545162</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op7rel</objectName>
  <x>647</x>
  <y>286</y>
  <width>20</width>
  <height>100</height>
  <uuid>{c211de7a-2f05-44f9-b09f-51523639dd8e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>4.00000000</maximum>
  <value>1.01258862</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>op7ratio</objectName>
  <x>507</x>
  <y>316</y>
  <width>66</width>
  <height>25</height>
  <uuid>{da8941a6-25be-42bd-9fc4-eb3bf5e4e6e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Noto Sans</font>
  <fontsize>8</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>576</x>
  <y>387</y>
  <width>20</width>
  <height>24</height>
  <uuid>{62723170-853a-42d9-accd-7cf9a518c320}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>600</x>
  <y>387</y>
  <width>20</width>
  <height>24</height>
  <uuid>{cd0ede53-3fef-457e-9c59-6402ddf446ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>623</x>
  <y>387</y>
  <width>20</width>
  <height>24</height>
  <uuid>{f1206157-bfe2-47c1-b418-e3f844eee27c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>648</x>
  <y>387</y>
  <width>20</width>
  <height>24</height>
  <uuid>{fb2bd17b-4623-48ff-abba-45d04cbb24b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>477</x>
  <y>387</y>
  <width>41</width>
  <height>23</height>
  <uuid>{487c01cb-9480-4278-8434-77f5f4b2bbbe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>506</x>
  <y>341</y>
  <width>69</width>
  <height>24</height>
  <uuid>{44e5ef22-46b1-4909-9c86-3398087f608e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>464</x>
  <y>458</y>
  <width>206</width>
  <height>155</height>
  <uuid>{f5bb3b25-c36a-4327-9f77-927b0ce11f84}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OP6</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op6amp</objectName>
  <x>477</x>
  <y>481</y>
  <width>20</width>
  <height>100</height>
  <uuid>{8ade719c-f9d9-4348-91cc-a50077821391}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.61456019</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>op6ratio</objectName>
  <x>501</x>
  <y>515</y>
  <width>66</width>
  <height>25</height>
  <uuid>{aaa01bed-d7bb-4690-a71e-1ae6f64afc5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Noto Sans</font>
  <fontsize>8</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op6att</objectName>
  <x>571</x>
  <y>480</y>
  <width>20</width>
  <height>100</height>
  <uuid>{21c7e2af-f1a0-41c0-be87-b103ea56c714}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>3.00000000</maximum>
  <value>1.79552197</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op6dec</objectName>
  <x>594</x>
  <y>480</y>
  <width>20</width>
  <height>100</height>
  <uuid>{32c4cf2e-a76a-46b1-89bf-a4e4d2924309}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>2.00000000</maximum>
  <value>0.56583136</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op6sus</objectName>
  <x>617</x>
  <y>480</y>
  <width>20</width>
  <height>100</height>
  <uuid>{b52b40e8-cd42-4060-8d22-cf0c9e0859f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.70409799</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>op6rel</objectName>
  <x>641</x>
  <y>480</y>
  <width>20</width>
  <height>100</height>
  <uuid>{e9d2c154-945a-4024-b053-8e4c510f5ba3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000100</minimum>
  <maximum>4.00000000</maximum>
  <value>0.91626638</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>571</x>
  <y>582</y>
  <width>20</width>
  <height>24</height>
  <uuid>{57e2ba8d-56ab-446c-b6d5-90a6547d5849}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>A</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>595</x>
  <y>582</y>
  <width>20</width>
  <height>24</height>
  <uuid>{a54ea4bb-1dcf-4a8a-a042-f10b96ff22e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>D</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>618</x>
  <y>583</y>
  <width>20</width>
  <height>24</height>
  <uuid>{8e6c9cd4-2394-4645-9332-f3354bb795d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>S</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>642</x>
  <y>582</y>
  <width>20</width>
  <height>24</height>
  <uuid>{acb5d727-95ad-4287-8c48-ad656963e58a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>R</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>473</x>
  <y>585</y>
  <width>41</width>
  <height>23</height>
  <uuid>{6f390510-787a-4ffb-85c3-ff6436f1691a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Amp</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>501</x>
  <y>540</y>
  <width>69</width>
  <height>24</height>
  <uuid>{0e91e9f9-0262-4996-9ebc-ead23dabd4e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Ratio</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>470</x>
  <y>78</y>
  <width>205</width>
  <height>154</height>
  <uuid>{91a10171-8774-4e43-96c8-a398504d70ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Control</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>62</r>
   <g>165</g>
   <b>167</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>476</x>
  <y>100</y>
  <width>190</width>
  <height>28</height>
  <uuid>{72d91f82-8446-4985-8a6c-7617db96ad59}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>0</stringvalue>
  <text>Randomize harmonic</text>
  <image>/</image>
  <eventLine>i 99 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>476</x>
  <y>129</y>
  <width>190</width>
  <height>28</height>
  <uuid>{beca3791-f6ef-4ca6-8b17-b074357951d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>0</stringvalue>
  <text>Randomize</text>
  <image>/</image>
  <eventLine>i 100 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>_SetPreset</objectName>
  <x>478</x>
  <y>193</y>
  <width>42</width>
  <height>30</height>
  <uuid>{2edd913b-e4ed-497b-95a1-b45578fdcea6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>8</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_GetPresetName</objectName>
  <x>526</x>
  <y>193</y>
  <width>139</width>
  <height>29</height>
  <uuid>{df2a583c-d11a-4e3f-8f22-c20c945ad4b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Default</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>536</x>
  <y>166</y>
  <width>80</width>
  <height>25</height>
  <uuid>{57e15c83-d89d-4e51-bd27-c31e156cf9f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Presets</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>737</x>
  <y>333</y>
  <width>16</width>
  <height>216</height>
  <uuid>{df6725b5-7a67-4d71-a249-1407de631f8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>667</x>
  <y>531</y>
  <width>84</width>
  <height>18</height>
  <uuid>{81a4bc39-f596-4db2-b0b9-d65885a5fa56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>672</x>
  <y>332</y>
  <width>81</width>
  <height>18</height>
  <uuid>{65c9c9ad-86e2-4c79-9b70-9b2471380fbe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>8</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>51</r>
   <g>167</g>
   <b>125</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>fb1</objectName>
  <x>680</x>
  <y>419</y>
  <width>57</width>
  <height>53</height>
  <uuid>{465a3cbf-594b-494d-9b1b-9ffdbe806def}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>label109</objectName>
  <x>675</x>
  <y>471</y>
  <width>80</width>
  <height>25</height>
  <uuid>{d622018b-608c-4d90-bbb6-94a8fdd5986b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Feedback</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="Default" number="0" >
<value id="{a4d4c497-04d4-4b7d-ad51-0f8832cb64bf}" mode="1" >0.60793877</value>
<value id="{b418386f-afe6-4d3c-b8d6-c6c96885e9ab}" mode="1" >0.87604076</value>
<value id="{f2ac6272-b33d-44fc-bb1e-fe52087e3a2b}" mode="1" >0.68532342</value>
<value id="{8052b29d-d6ae-4249-b9cd-1788a2faf77c}" mode="1" >0.87491655</value>
<value id="{3efde0c1-5828-4875-a997-174989989aa9}" mode="1" >0.24683115</value>
<value id="{fa34129e-d983-460c-bd0e-89fb3e798bcb}" mode="1" >3.00000000</value>
<value id="{17b249bd-27ed-44c7-9bac-a847a81165e3}" mode="1" >0.71242875</value>
<value id="{cba3fee2-d2a5-41b2-8842-34be212fa82a}" mode="1" >1.51931179</value>
<value id="{f0305ec9-814b-4107-a9b5-55a5a13f0118}" mode="1" >0.76090300</value>
<value id="{9f495b69-cdca-43c7-bc92-f26d9995caed}" mode="1" >0.27295068</value>
<value id="{3f29a847-8cf1-4076-9a69-e88b5360a810}" mode="1" >0.61171556</value>
<value id="{2ea377f7-6c31-4556-8e26-e47d9b6c000a}" mode="1" >0.20000000</value>
<value id="{a6a5a56d-13c6-4c09-b6e8-74086df6e352}" mode="1" >0.82246149</value>
<value id="{dde869a9-5d2a-454c-bff8-b8d407d19e87}" mode="1" >1.00000000</value>
<value id="{623cf6cd-548c-4212-ac65-a4761cfb5b7f}" mode="1" >1.93253195</value>
<value id="{833bd2f5-fae9-441b-82ad-9117ffd29877}" mode="1" >0.21393649</value>
<value id="{d520e71a-b3e2-46d4-b0c6-688085fe5742}" mode="1" >0.91956383</value>
<value id="{ced1a494-71e9-4bc0-9973-a872920a4473}" mode="1" >1.47231400</value>
<value id="{16c48afd-7c15-4e07-beee-ce56c7b61c80}" mode="1" >0.41843128</value>
<value id="{e1aa96cf-3e30-4ad2-93ec-1494a0d60079}" mode="1" >2.00000000</value>
<value id="{1a074887-a3a3-43ee-8de2-34b8e6a7a5a5}" mode="1" >0.25791028</value>
<value id="{e1352cbc-9c2a-4650-8957-fb055156903b}" mode="1" >0.32575035</value>
<value id="{3f7ea94f-e14d-4b53-8bbd-53563d0c23c1}" mode="1" >0.26118517</value>
<value id="{9c657ab3-a738-40e2-92ae-b1128863fd78}" mode="1" >1.78432512</value>
<value id="{56e321a8-c542-420c-a494-e759e36ea78a}" mode="1" >0.02822053</value>
<value id="{77ce606f-b1c5-4911-bf36-79ea1b8f50ef}" mode="1" >1.00000000</value>
<value id="{fec79e7f-6c43-482f-9fff-cedfc13eaea7}" mode="1" >1.85546792</value>
<value id="{964db287-6df1-4fa8-baba-1e387d1fac12}" mode="1" >1.85546792</value>
<value id="{7844fda3-a049-4ec6-885f-cba693b160c9}" mode="1" >1.00000000</value>
<value id="{37d2f1f5-7da1-460a-a8a0-9d70e19e7da0}" mode="1" >0.80882120</value>
<value id="{1713b2f6-0778-43b4-b81a-725331e94260}" mode="1" >0.88287294</value>
<value id="{608ebd5c-d7b3-4c9a-8075-2204844bc42c}" mode="1" >1.85216427</value>
<value id="{5f20cb6a-ad07-4210-aaa1-a0ee628ee2d4}" mode="1" >0.12375984</value>
<value id="{dc16cdf0-7371-4027-bac0-7d26d9d21433}" mode="1" >0.01545162</value>
<value id="{c211de7a-2f05-44f9-b09f-51523639dd8e}" mode="1" >1.01258862</value>
<value id="{da8941a6-25be-42bd-9fc4-eb3bf5e4e6e1}" mode="1" >0.50000000</value>
<value id="{8ade719c-f9d9-4348-91cc-a50077821391}" mode="1" >0.61456019</value>
<value id="{aaa01bed-d7bb-4690-a71e-1ae6f64afc5a}" mode="1" >4.00000000</value>
<value id="{21c7e2af-f1a0-41c0-be87-b103ea56c714}" mode="1" >1.79552197</value>
<value id="{32c4cf2e-a76a-46b1-89bf-a4e4d2924309}" mode="1" >0.56583136</value>
<value id="{b52b40e8-cd42-4060-8d22-cf0c9e0859f9}" mode="1" >0.70409799</value>
<value id="{e9d2c154-945a-4024-b053-8e4c510f5ba3}" mode="1" >0.91626638</value>
<value id="{72d91f82-8446-4985-8a6c-7617db96ad59}" mode="4" >0</value>
<value id="{beca3791-f6ef-4ca6-8b17-b074357951d5}" mode="4" >0</value>
</preset>
<preset name="Fairy Dust" number="1" >
<value id="{a4d4c497-04d4-4b7d-ad51-0f8832cb64bf}" mode="1" >0.60793877</value>
<value id="{b418386f-afe6-4d3c-b8d6-c6c96885e9ab}" mode="1" >0.87604076</value>
<value id="{f2ac6272-b33d-44fc-bb1e-fe52087e3a2b}" mode="1" >0.68532342</value>
<value id="{8052b29d-d6ae-4249-b9cd-1788a2faf77c}" mode="1" >0.87491655</value>
<value id="{3efde0c1-5828-4875-a997-174989989aa9}" mode="1" >0.24683115</value>
<value id="{fa34129e-d983-460c-bd0e-89fb3e798bcb}" mode="1" >3.61637497</value>
<value id="{17b249bd-27ed-44c7-9bac-a847a81165e3}" mode="1" >0.71242875</value>
<value id="{cba3fee2-d2a5-41b2-8842-34be212fa82a}" mode="1" >1.51931179</value>
<value id="{f0305ec9-814b-4107-a9b5-55a5a13f0118}" mode="1" >0.76090300</value>
<value id="{9f495b69-cdca-43c7-bc92-f26d9995caed}" mode="1" >0.27295068</value>
<value id="{3f29a847-8cf1-4076-9a69-e88b5360a810}" mode="1" >0.61171556</value>
<value id="{2ea377f7-6c31-4556-8e26-e47d9b6c000a}" mode="1" >0.17211232</value>
<value id="{a6a5a56d-13c6-4c09-b6e8-74086df6e352}" mode="1" >0.82246149</value>
<value id="{dde869a9-5d2a-454c-bff8-b8d407d19e87}" mode="1" >2.73157001</value>
<value id="{623cf6cd-548c-4212-ac65-a4761cfb5b7f}" mode="1" >1.93253195</value>
<value id="{833bd2f5-fae9-441b-82ad-9117ffd29877}" mode="1" >0.21393649</value>
<value id="{d520e71a-b3e2-46d4-b0c6-688085fe5742}" mode="1" >0.91956383</value>
<value id="{ced1a494-71e9-4bc0-9973-a872920a4473}" mode="1" >1.47231400</value>
<value id="{16c48afd-7c15-4e07-beee-ce56c7b61c80}" mode="1" >0.41843128</value>
<value id="{e1aa96cf-3e30-4ad2-93ec-1494a0d60079}" mode="1" >4.45120955</value>
<value id="{1a074887-a3a3-43ee-8de2-34b8e6a7a5a5}" mode="1" >0.25791028</value>
<value id="{e1352cbc-9c2a-4650-8957-fb055156903b}" mode="1" >0.32575035</value>
<value id="{3f7ea94f-e14d-4b53-8bbd-53563d0c23c1}" mode="1" >0.26118517</value>
<value id="{9c657ab3-a738-40e2-92ae-b1128863fd78}" mode="1" >1.78432512</value>
<value id="{56e321a8-c542-420c-a494-e759e36ea78a}" mode="1" >0.02822053</value>
<value id="{77ce606f-b1c5-4911-bf36-79ea1b8f50ef}" mode="1" >3.40845633</value>
<value id="{fec79e7f-6c43-482f-9fff-cedfc13eaea7}" mode="1" >1.85546792</value>
<value id="{964db287-6df1-4fa8-baba-1e387d1fac12}" mode="1" >1.85546792</value>
<value id="{7844fda3-a049-4ec6-885f-cba693b160c9}" mode="1" >1.00000000</value>
<value id="{37d2f1f5-7da1-460a-a8a0-9d70e19e7da0}" mode="1" >0.80882120</value>
<value id="{1713b2f6-0778-43b4-b81a-725331e94260}" mode="1" >0.88287294</value>
<value id="{608ebd5c-d7b3-4c9a-8075-2204844bc42c}" mode="1" >1.85216427</value>
<value id="{5f20cb6a-ad07-4210-aaa1-a0ee628ee2d4}" mode="1" >0.12375984</value>
<value id="{dc16cdf0-7371-4027-bac0-7d26d9d21433}" mode="1" >0.01545162</value>
<value id="{c211de7a-2f05-44f9-b09f-51523639dd8e}" mode="1" >1.01258862</value>
<value id="{da8941a6-25be-42bd-9fc4-eb3bf5e4e6e1}" mode="1" >1.81891644</value>
<value id="{8ade719c-f9d9-4348-91cc-a50077821391}" mode="1" >0.61456019</value>
<value id="{aaa01bed-d7bb-4690-a71e-1ae6f64afc5a}" mode="1" >5.21777058</value>
<value id="{21c7e2af-f1a0-41c0-be87-b103ea56c714}" mode="1" >1.79552197</value>
<value id="{32c4cf2e-a76a-46b1-89bf-a4e4d2924309}" mode="1" >0.56583136</value>
<value id="{b52b40e8-cd42-4060-8d22-cf0c9e0859f9}" mode="1" >0.70409799</value>
<value id="{e9d2c154-945a-4024-b053-8e4c510f5ba3}" mode="1" >0.91626638</value>
<value id="{72d91f82-8446-4985-8a6c-7617db96ad59}" mode="4" >0</value>
<value id="{beca3791-f6ef-4ca6-8b17-b074357951d5}" mode="4" >0</value>
</preset>
<preset name="Shock" number="2" >
<value id="{a4d4c497-04d4-4b7d-ad51-0f8832cb64bf}" mode="1" >0.09924940</value>
<value id="{b418386f-afe6-4d3c-b8d6-c6c96885e9ab}" mode="1" >0.99000067</value>
<value id="{f2ac6272-b33d-44fc-bb1e-fe52087e3a2b}" mode="1" >0.32000083</value>
<value id="{8052b29d-d6ae-4249-b9cd-1788a2faf77c}" mode="1" >0.06253843</value>
<value id="{3efde0c1-5828-4875-a997-174989989aa9}" mode="1" >0.97072107</value>
<value id="{fa34129e-d983-460c-bd0e-89fb3e798bcb}" mode="1" >1.00000000</value>
<value id="{17b249bd-27ed-44c7-9bac-a847a81165e3}" mode="1" >0.54646546</value>
<value id="{cba3fee2-d2a5-41b2-8842-34be212fa82a}" mode="1" >1.13128877</value>
<value id="{f0305ec9-814b-4107-a9b5-55a5a13f0118}" mode="1" >0.13656585</value>
<value id="{9f495b69-cdca-43c7-bc92-f26d9995caed}" mode="1" >0.34610736</value>
<value id="{3f29a847-8cf1-4076-9a69-e88b5360a810}" mode="1" >1.85934544</value>
<value id="{2ea377f7-6c31-4556-8e26-e47d9b6c000a}" mode="1" >2.00000000</value>
<value id="{a6a5a56d-13c6-4c09-b6e8-74086df6e352}" mode="1" >0.99779081</value>
<value id="{dde869a9-5d2a-454c-bff8-b8d407d19e87}" mode="1" >0.33333334</value>
<value id="{623cf6cd-548c-4212-ac65-a4761cfb5b7f}" mode="1" >0.00000100</value>
<value id="{833bd2f5-fae9-441b-82ad-9117ffd29877}" mode="1" >0.44000077</value>
<value id="{d520e71a-b3e2-46d4-b0c6-688085fe5742}" mode="1" >0.36350498</value>
<value id="{ced1a494-71e9-4bc0-9973-a872920a4473}" mode="1" >1.70886242</value>
<value id="{16c48afd-7c15-4e07-beee-ce56c7b61c80}" mode="1" >0.82670689</value>
<value id="{e1aa96cf-3e30-4ad2-93ec-1494a0d60079}" mode="1" >1.00000000</value>
<value id="{1a074887-a3a3-43ee-8de2-34b8e6a7a5a5}" mode="1" >0.00000100</value>
<value id="{e1352cbc-9c2a-4650-8957-fb055156903b}" mode="1" >1.00000048</value>
<value id="{3f7ea94f-e14d-4b53-8bbd-53563d0c23c1}" mode="1" >0.34000000</value>
<value id="{9c657ab3-a738-40e2-92ae-b1128863fd78}" mode="1" >0.60559916</value>
<value id="{56e321a8-c542-420c-a494-e759e36ea78a}" mode="1" >0.41786775</value>
<value id="{77ce606f-b1c5-4911-bf36-79ea1b8f50ef}" mode="1" >0.25000000</value>
<value id="{fec79e7f-6c43-482f-9fff-cedfc13eaea7}" mode="1" >0.69873726</value>
<value id="{964db287-6df1-4fa8-baba-1e387d1fac12}" mode="1" >0.00000100</value>
<value id="{7844fda3-a049-4ec6-885f-cba693b160c9}" mode="1" >0.69873726</value>
<value id="{37d2f1f5-7da1-460a-a8a0-9d70e19e7da0}" mode="1" >1.42871964</value>
<value id="{1713b2f6-0778-43b4-b81a-725331e94260}" mode="1" >0.52680331</value>
<value id="{608ebd5c-d7b3-4c9a-8075-2204844bc42c}" mode="1" >1.08000064</value>
<value id="{5f20cb6a-ad07-4210-aaa1-a0ee628ee2d4}" mode="1" >0.00000100</value>
<value id="{dc16cdf0-7371-4027-bac0-7d26d9d21433}" mode="1" >0.12058064</value>
<value id="{c211de7a-2f05-44f9-b09f-51523639dd8e}" mode="1" >1.48647273</value>
<value id="{da8941a6-25be-42bd-9fc4-eb3bf5e4e6e1}" mode="1" >2.00000000</value>
<value id="{8ade719c-f9d9-4348-91cc-a50077821391}" mode="1" >0.10895189</value>
<value id="{aaa01bed-d7bb-4690-a71e-1ae6f64afc5a}" mode="1" >1.00000000</value>
<value id="{21c7e2af-f1a0-41c0-be87-b103ea56c714}" mode="1" >0.00000100</value>
<value id="{32c4cf2e-a76a-46b1-89bf-a4e4d2924309}" mode="1" >0.91890037</value>
<value id="{b52b40e8-cd42-4060-8d22-cf0c9e0859f9}" mode="1" >0.31571576</value>
<value id="{e9d2c154-945a-4024-b053-8e4c510f5ba3}" mode="1" >0.06035645</value>
<value id="{72d91f82-8446-4985-8a6c-7617db96ad59}" mode="4" >0</value>
<value id="{beca3791-f6ef-4ca6-8b17-b074357951d5}" mode="4" >0</value>
<value id="{2edd913b-e4ed-497b-95a1-b45578fdcea6}" mode="1" >2.00000000</value>
<value id="{df2a583c-d11a-4e3f-8f22-c20c945ad4b9}" mode="1" >0.00000000</value>
<value id="{df2a583c-d11a-4e3f-8f22-c20c945ad4b9}" mode="4" >Shock</value>
</preset>
<preset name="Wobbly Bass" number="3" >
<value id="{a4d4c497-04d4-4b7d-ad51-0f8832cb64bf}" mode="1" >0.35183150</value>
<value id="{b418386f-afe6-4d3c-b8d6-c6c96885e9ab}" mode="1" >1.16110826</value>
<value id="{f2ac6272-b33d-44fc-bb1e-fe52087e3a2b}" mode="1" >0.05349947</value>
<value id="{8052b29d-d6ae-4249-b9cd-1788a2faf77c}" mode="1" >0.49104589</value>
<value id="{3efde0c1-5828-4875-a997-174989989aa9}" mode="1" >1.94538844</value>
<value id="{fa34129e-d983-460c-bd0e-89fb3e798bcb}" mode="1" >1.00000000</value>
<value id="{17b249bd-27ed-44c7-9bac-a847a81165e3}" mode="1" >0.58744889</value>
<value id="{cba3fee2-d2a5-41b2-8842-34be212fa82a}" mode="1" >0.88966805</value>
<value id="{f0305ec9-814b-4107-a9b5-55a5a13f0118}" mode="1" >0.22458993</value>
<value id="{9f495b69-cdca-43c7-bc92-f26d9995caed}" mode="1" >0.92106187</value>
<value id="{3f29a847-8cf1-4076-9a69-e88b5360a810}" mode="1" >1.16434824</value>
<value id="{2ea377f7-6c31-4556-8e26-e47d9b6c000a}" mode="1" >2.00000000</value>
<value id="{a6a5a56d-13c6-4c09-b6e8-74086df6e352}" mode="1" >0.84130728</value>
<value id="{dde869a9-5d2a-454c-bff8-b8d407d19e87}" mode="1" >2.00000000</value>
<value id="{623cf6cd-548c-4212-ac65-a4761cfb5b7f}" mode="1" >0.26269972</value>
<value id="{833bd2f5-fae9-441b-82ad-9117ffd29877}" mode="1" >0.40164155</value>
<value id="{d520e71a-b3e2-46d4-b0c6-688085fe5742}" mode="1" >0.02464281</value>
<value id="{ced1a494-71e9-4bc0-9973-a872920a4473}" mode="1" >0.82045412</value>
<value id="{16c48afd-7c15-4e07-beee-ce56c7b61c80}" mode="1" >0.65424937</value>
<value id="{e1aa96cf-3e30-4ad2-93ec-1494a0d60079}" mode="1" >4.00000000</value>
<value id="{1a074887-a3a3-43ee-8de2-34b8e6a7a5a5}" mode="1" >0.03000099</value>
<value id="{e1352cbc-9c2a-4650-8957-fb055156903b}" mode="1" >0.26000088</value>
<value id="{3f7ea94f-e14d-4b53-8bbd-53563d0c23c1}" mode="1" >0.52906078</value>
<value id="{9c657ab3-a738-40e2-92ae-b1128863fd78}" mode="1" >1.66721201</value>
<value id="{56e321a8-c542-420c-a494-e759e36ea78a}" mode="1" >0.47983685</value>
<value id="{77ce606f-b1c5-4911-bf36-79ea1b8f50ef}" mode="1" >0.50000000</value>
<value id="{fec79e7f-6c43-482f-9fff-cedfc13eaea7}" mode="1" >0.76768428</value>
<value id="{964db287-6df1-4fa8-baba-1e387d1fac12}" mode="1" >0.76768428</value>
<value id="{7844fda3-a049-4ec6-885f-cba693b160c9}" mode="1" >0.76768428</value>
<value id="{37d2f1f5-7da1-460a-a8a0-9d70e19e7da0}" mode="1" >1.12945914</value>
<value id="{1713b2f6-0778-43b4-b81a-725331e94260}" mode="1" >0.24956867</value>
<value id="{608ebd5c-d7b3-4c9a-8075-2204844bc42c}" mode="1" >1.23290610</value>
<value id="{5f20cb6a-ad07-4210-aaa1-a0ee628ee2d4}" mode="1" >0.48934624</value>
<value id="{dc16cdf0-7371-4027-bac0-7d26d9d21433}" mode="1" >0.55785310</value>
<value id="{c211de7a-2f05-44f9-b09f-51523639dd8e}" mode="1" >0.01865082</value>
<value id="{da8941a6-25be-42bd-9fc4-eb3bf5e4e6e1}" mode="1" >5.00000000</value>
<value id="{8ade719c-f9d9-4348-91cc-a50077821391}" mode="1" >0.34645078</value>
<value id="{aaa01bed-d7bb-4690-a71e-1ae6f64afc5a}" mode="1" >5.00000000</value>
<value id="{21c7e2af-f1a0-41c0-be87-b103ea56c714}" mode="1" >0.24000092</value>
<value id="{32c4cf2e-a76a-46b1-89bf-a4e4d2924309}" mode="1" >0.26000088</value>
<value id="{b52b40e8-cd42-4060-8d22-cf0c9e0859f9}" mode="1" >0.34000000</value>
<value id="{e9d2c154-945a-4024-b053-8e4c510f5ba3}" mode="1" >0.57990128</value>
<value id="{72d91f82-8446-4985-8a6c-7617db96ad59}" mode="4" >0</value>
<value id="{beca3791-f6ef-4ca6-8b17-b074357951d5}" mode="4" >0</value>
</preset>
<preset name="Outer Space" number="4" >
<value id="{a4d4c497-04d4-4b7d-ad51-0f8832cb64bf}" mode="1" >0.52880144</value>
<value id="{b418386f-afe6-4d3c-b8d6-c6c96885e9ab}" mode="1" >1.92315161</value>
<value id="{f2ac6272-b33d-44fc-bb1e-fe52087e3a2b}" mode="1" >0.40721342</value>
<value id="{8052b29d-d6ae-4249-b9cd-1788a2faf77c}" mode="1" >0.51781482</value>
<value id="{3efde0c1-5828-4875-a997-174989989aa9}" mode="1" >1.48892212</value>
<value id="{fa34129e-d983-460c-bd0e-89fb3e798bcb}" mode="1" >1.00000000</value>
<value id="{17b249bd-27ed-44c7-9bac-a847a81165e3}" mode="1" >0.09598406</value>
<value id="{cba3fee2-d2a5-41b2-8842-34be212fa82a}" mode="1" >1.14999413</value>
<value id="{f0305ec9-814b-4107-a9b5-55a5a13f0118}" mode="1" >0.78067654</value>
<value id="{9f495b69-cdca-43c7-bc92-f26d9995caed}" mode="1" >0.80435246</value>
<value id="{3f29a847-8cf1-4076-9a69-e88b5360a810}" mode="1" >1.88658834</value>
<value id="{2ea377f7-6c31-4556-8e26-e47d9b6c000a}" mode="1" >4.00000000</value>
<value id="{a6a5a56d-13c6-4c09-b6e8-74086df6e352}" mode="1" >0.52892101</value>
<value id="{dde869a9-5d2a-454c-bff8-b8d407d19e87}" mode="1" >5.00000000</value>
<value id="{623cf6cd-548c-4212-ac65-a4761cfb5b7f}" mode="1" >0.57236409</value>
<value id="{833bd2f5-fae9-441b-82ad-9117ffd29877}" mode="1" >0.02315990</value>
<value id="{d520e71a-b3e2-46d4-b0c6-688085fe5742}" mode="1" >0.83943599</value>
<value id="{ced1a494-71e9-4bc0-9973-a872920a4473}" mode="1" >0.25039724</value>
<value id="{16c48afd-7c15-4e07-beee-ce56c7b61c80}" mode="1" >0.33299038</value>
<value id="{e1aa96cf-3e30-4ad2-93ec-1494a0d60079}" mode="1" >0.50000000</value>
<value id="{1a074887-a3a3-43ee-8de2-34b8e6a7a5a5}" mode="1" >0.43360656</value>
<value id="{e1352cbc-9c2a-4650-8957-fb055156903b}" mode="1" >0.44469181</value>
<value id="{3f7ea94f-e14d-4b53-8bbd-53563d0c23c1}" mode="1" >0.40249717</value>
<value id="{9c657ab3-a738-40e2-92ae-b1128863fd78}" mode="1" >1.95878458</value>
<value id="{56e321a8-c542-420c-a494-e759e36ea78a}" mode="1" >0.23041101</value>
<value id="{77ce606f-b1c5-4911-bf36-79ea1b8f50ef}" mode="1" >5.00000000</value>
<value id="{fec79e7f-6c43-482f-9fff-cedfc13eaea7}" mode="1" >1.32098460</value>
<value id="{964db287-6df1-4fa8-baba-1e387d1fac12}" mode="1" >1.32098460</value>
<value id="{7844fda3-a049-4ec6-885f-cba693b160c9}" mode="1" >1.00000000</value>
<value id="{37d2f1f5-7da1-460a-a8a0-9d70e19e7da0}" mode="1" >1.64780557</value>
<value id="{1713b2f6-0778-43b4-b81a-725331e94260}" mode="1" >0.41363844</value>
<value id="{608ebd5c-d7b3-4c9a-8075-2204844bc42c}" mode="1" >0.26922104</value>
<value id="{5f20cb6a-ad07-4210-aaa1-a0ee628ee2d4}" mode="1" >0.72871375</value>
<value id="{dc16cdf0-7371-4027-bac0-7d26d9d21433}" mode="1" >0.76807946</value>
<value id="{c211de7a-2f05-44f9-b09f-51523639dd8e}" mode="1" >1.28383279</value>
<value id="{da8941a6-25be-42bd-9fc4-eb3bf5e4e6e1}" mode="1" >0.20000000</value>
<value id="{8ade719c-f9d9-4348-91cc-a50077821391}" mode="1" >0.36287013</value>
<value id="{aaa01bed-d7bb-4690-a71e-1ae6f64afc5a}" mode="1" >5.00000000</value>
<value id="{21c7e2af-f1a0-41c0-be87-b103ea56c714}" mode="1" >0.97215766</value>
<value id="{32c4cf2e-a76a-46b1-89bf-a4e4d2924309}" mode="1" >0.49834982</value>
<value id="{b52b40e8-cd42-4060-8d22-cf0c9e0859f9}" mode="1" >0.89931619</value>
<value id="{e9d2c154-945a-4024-b053-8e4c510f5ba3}" mode="1" >1.38783407</value>
<value id="{72d91f82-8446-4985-8a6c-7617db96ad59}" mode="4" >0</value>
<value id="{beca3791-f6ef-4ca6-8b17-b074357951d5}" mode="4" >0</value>
</preset>
<preset name="Gong" number="5" >
<value id="{a4d4c497-04d4-4b7d-ad51-0f8832cb64bf}" mode="1" >0.09924940</value>
<value id="{b418386f-afe6-4d3c-b8d6-c6c96885e9ab}" mode="1" >0.01480771</value>
<value id="{f2ac6272-b33d-44fc-bb1e-fe52087e3a2b}" mode="1" >0.05123077</value>
<value id="{8052b29d-d6ae-4249-b9cd-1788a2faf77c}" mode="1" >1.00000000</value>
<value id="{3efde0c1-5828-4875-a997-174989989aa9}" mode="1" >0.97072107</value>
<value id="{fa34129e-d983-460c-bd0e-89fb3e798bcb}" mode="1" >1.00000000</value>
<value id="{17b249bd-27ed-44c7-9bac-a847a81165e3}" mode="1" >0.54646546</value>
<value id="{cba3fee2-d2a5-41b2-8842-34be212fa82a}" mode="1" >1.13128877</value>
<value id="{f0305ec9-814b-4107-a9b5-55a5a13f0118}" mode="1" >0.13656585</value>
<value id="{9f495b69-cdca-43c7-bc92-f26d9995caed}" mode="1" >0.63000000</value>
<value id="{3f29a847-8cf1-4076-9a69-e88b5360a810}" mode="1" >1.85934544</value>
<value id="{2ea377f7-6c31-4556-8e26-e47d9b6c000a}" mode="1" >2.00000000</value>
<value id="{a6a5a56d-13c6-4c09-b6e8-74086df6e352}" mode="1" >0.99779081</value>
<value id="{dde869a9-5d2a-454c-bff8-b8d407d19e87}" mode="1" >0.33333334</value>
<value id="{623cf6cd-548c-4212-ac65-a4761cfb5b7f}" mode="1" >1.21385181</value>
<value id="{833bd2f5-fae9-441b-82ad-9117ffd29877}" mode="1" >0.31246525</value>
<value id="{d520e71a-b3e2-46d4-b0c6-688085fe5742}" mode="1" >1.00000000</value>
<value id="{ced1a494-71e9-4bc0-9973-a872920a4473}" mode="1" >1.70886242</value>
<value id="{16c48afd-7c15-4e07-beee-ce56c7b61c80}" mode="1" >0.82670689</value>
<value id="{e1aa96cf-3e30-4ad2-93ec-1494a0d60079}" mode="1" >0.20000000</value>
<value id="{1a074887-a3a3-43ee-8de2-34b8e6a7a5a5}" mode="1" >0.72617590</value>
<value id="{e1352cbc-9c2a-4650-8957-fb055156903b}" mode="1" >0.58649164</value>
<value id="{3f7ea94f-e14d-4b53-8bbd-53563d0c23c1}" mode="1" >0.93524820</value>
<value id="{9c657ab3-a738-40e2-92ae-b1128863fd78}" mode="1" >0.60559916</value>
<value id="{56e321a8-c542-420c-a494-e759e36ea78a}" mode="1" >0.41786775</value>
<value id="{77ce606f-b1c5-4911-bf36-79ea1b8f50ef}" mode="1" >0.25000000</value>
<value id="{fec79e7f-6c43-482f-9fff-cedfc13eaea7}" mode="1" >0.69873726</value>
<value id="{964db287-6df1-4fa8-baba-1e387d1fac12}" mode="1" >0.69873726</value>
<value id="{7844fda3-a049-4ec6-885f-cba693b160c9}" mode="1" >0.69873726</value>
<value id="{37d2f1f5-7da1-460a-a8a0-9d70e19e7da0}" mode="1" >1.42871964</value>
<value id="{1713b2f6-0778-43b4-b81a-725331e94260}" mode="1" >0.52680331</value>
<value id="{608ebd5c-d7b3-4c9a-8075-2204844bc42c}" mode="1" >1.72767055</value>
<value id="{5f20cb6a-ad07-4210-aaa1-a0ee628ee2d4}" mode="1" >0.54525268</value>
<value id="{dc16cdf0-7371-4027-bac0-7d26d9d21433}" mode="1" >0.92000002</value>
<value id="{c211de7a-2f05-44f9-b09f-51523639dd8e}" mode="1" >1.48647273</value>
<value id="{da8941a6-25be-42bd-9fc4-eb3bf5e4e6e1}" mode="1" >3.00000000</value>
<value id="{8ade719c-f9d9-4348-91cc-a50077821391}" mode="1" >0.10895189</value>
<value id="{aaa01bed-d7bb-4690-a71e-1ae6f64afc5a}" mode="1" >0.25000000</value>
<value id="{21c7e2af-f1a0-41c0-be87-b103ea56c714}" mode="1" >1.67256188</value>
<value id="{32c4cf2e-a76a-46b1-89bf-a4e4d2924309}" mode="1" >0.91890037</value>
<value id="{b52b40e8-cd42-4060-8d22-cf0c9e0859f9}" mode="1" >1.00000000</value>
<value id="{e9d2c154-945a-4024-b053-8e4c510f5ba3}" mode="1" >0.06035645</value>
<value id="{72d91f82-8446-4985-8a6c-7617db96ad59}" mode="4" >0</value>
<value id="{beca3791-f6ef-4ca6-8b17-b074357951d5}" mode="4" >0</value>
</preset>
<preset name="Alien" number="6" >
<value id="{a4d4c497-04d4-4b7d-ad51-0f8832cb64bf}" mode="1" >0.77549207</value>
<value id="{b418386f-afe6-4d3c-b8d6-c6c96885e9ab}" mode="1" >1.33936346</value>
<value id="{f2ac6272-b33d-44fc-bb1e-fe52087e3a2b}" mode="1" >0.36569735</value>
<value id="{8052b29d-d6ae-4249-b9cd-1788a2faf77c}" mode="1" >0.79167455</value>
<value id="{3efde0c1-5828-4875-a997-174989989aa9}" mode="1" >0.62001997</value>
<value id="{fa34129e-d983-460c-bd0e-89fb3e798bcb}" mode="1" >-1.40429783</value>
<value id="{17b249bd-27ed-44c7-9bac-a847a81165e3}" mode="1" >0.61443049</value>
<value id="{cba3fee2-d2a5-41b2-8842-34be212fa82a}" mode="1" >0.60574394</value>
<value id="{f0305ec9-814b-4107-a9b5-55a5a13f0118}" mode="1" >0.82539755</value>
<value id="{9f495b69-cdca-43c7-bc92-f26d9995caed}" mode="1" >0.36829379</value>
<value id="{3f29a847-8cf1-4076-9a69-e88b5360a810}" mode="1" >0.15290628</value>
<value id="{2ea377f7-6c31-4556-8e26-e47d9b6c000a}" mode="1" >0.76484829</value>
<value id="{a6a5a56d-13c6-4c09-b6e8-74086df6e352}" mode="1" >0.12198304</value>
<value id="{dde869a9-5d2a-454c-bff8-b8d407d19e87}" mode="1" >5.74750662</value>
<value id="{623cf6cd-548c-4212-ac65-a4761cfb5b7f}" mode="1" >0.43798280</value>
<value id="{833bd2f5-fae9-441b-82ad-9117ffd29877}" mode="1" >0.08567286</value>
<value id="{d520e71a-b3e2-46d4-b0c6-688085fe5742}" mode="1" >0.56523472</value>
<value id="{ced1a494-71e9-4bc0-9973-a872920a4473}" mode="1" >1.46649480</value>
<value id="{16c48afd-7c15-4e07-beee-ce56c7b61c80}" mode="1" >0.60636872</value>
<value id="{e1aa96cf-3e30-4ad2-93ec-1494a0d60079}" mode="1" >4.75232697</value>
<value id="{1a074887-a3a3-43ee-8de2-34b8e6a7a5a5}" mode="1" >1.34307921</value>
<value id="{e1352cbc-9c2a-4650-8957-fb055156903b}" mode="1" >0.95924777</value>
<value id="{3f7ea94f-e14d-4b53-8bbd-53563d0c23c1}" mode="1" >0.39933148</value>
<value id="{9c657ab3-a738-40e2-92ae-b1128863fd78}" mode="1" >1.27394211</value>
<value id="{56e321a8-c542-420c-a494-e759e36ea78a}" mode="1" >0.74402839</value>
<value id="{77ce606f-b1c5-4911-bf36-79ea1b8f50ef}" mode="1" >4.48528576</value>
<value id="{fec79e7f-6c43-482f-9fff-cedfc13eaea7}" mode="1" >0.37414643</value>
<value id="{964db287-6df1-4fa8-baba-1e387d1fac12}" mode="1" >0.37414643</value>
<value id="{7844fda3-a049-4ec6-885f-cba693b160c9}" mode="1" >0.37414643</value>
<value id="{37d2f1f5-7da1-460a-a8a0-9d70e19e7da0}" mode="1" >1.69390988</value>
<value id="{1713b2f6-0778-43b4-b81a-725331e94260}" mode="1" >0.57565117</value>
<value id="{608ebd5c-d7b3-4c9a-8075-2204844bc42c}" mode="1" >1.83773160</value>
<value id="{5f20cb6a-ad07-4210-aaa1-a0ee628ee2d4}" mode="1" >0.97878075</value>
<value id="{dc16cdf0-7371-4027-bac0-7d26d9d21433}" mode="1" >0.93248534</value>
<value id="{c211de7a-2f05-44f9-b09f-51523639dd8e}" mode="1" >0.09797703</value>
<value id="{da8941a6-25be-42bd-9fc4-eb3bf5e4e6e1}" mode="1" >4.98669291</value>
<value id="{8ade719c-f9d9-4348-91cc-a50077821391}" mode="1" >0.42223135</value>
<value id="{aaa01bed-d7bb-4690-a71e-1ae6f64afc5a}" mode="1" >5.98625231</value>
<value id="{21c7e2af-f1a0-41c0-be87-b103ea56c714}" mode="1" >0.66106582</value>
<value id="{32c4cf2e-a76a-46b1-89bf-a4e4d2924309}" mode="1" >0.37456763</value>
<value id="{b52b40e8-cd42-4060-8d22-cf0c9e0859f9}" mode="1" >0.32205558</value>
<value id="{e9d2c154-945a-4024-b053-8e4c510f5ba3}" mode="1" >1.07847786</value>
<value id="{72d91f82-8446-4985-8a6c-7617db96ad59}" mode="4" >0</value>
<value id="{beca3791-f6ef-4ca6-8b17-b074357951d5}" mode="4" >0</value>
</preset>
<preset name="Chimes" number="7" >
<value id="{a4d4c497-04d4-4b7d-ad51-0f8832cb64bf}" mode="1" >0.00821707</value>
<value id="{b418386f-afe6-4d3c-b8d6-c6c96885e9ab}" mode="1" >0.36902127</value>
<value id="{f2ac6272-b33d-44fc-bb1e-fe52087e3a2b}" mode="1" >0.66646159</value>
<value id="{8052b29d-d6ae-4249-b9cd-1788a2faf77c}" mode="1" >0.42549533</value>
<value id="{3efde0c1-5828-4875-a997-174989989aa9}" mode="1" >1.20048034</value>
<value id="{fa34129e-d983-460c-bd0e-89fb3e798bcb}" mode="1" >1.00000000</value>
<value id="{17b249bd-27ed-44c7-9bac-a847a81165e3}" mode="1" >0.03101001</value>
<value id="{cba3fee2-d2a5-41b2-8842-34be212fa82a}" mode="1" >1.11113417</value>
<value id="{f0305ec9-814b-4107-a9b5-55a5a13f0118}" mode="1" >0.62771147</value>
<value id="{9f495b69-cdca-43c7-bc92-f26d9995caed}" mode="1" >0.63929707</value>
<value id="{3f29a847-8cf1-4076-9a69-e88b5360a810}" mode="1" >0.29363316</value>
<value id="{2ea377f7-6c31-4556-8e26-e47d9b6c000a}" mode="1" >1.00000000</value>
<value id="{a6a5a56d-13c6-4c09-b6e8-74086df6e352}" mode="1" >0.28083172</value>
<value id="{dde869a9-5d2a-454c-bff8-b8d407d19e87}" mode="1" >1.00000000</value>
<value id="{623cf6cd-548c-4212-ac65-a4761cfb5b7f}" mode="1" >1.83537996</value>
<value id="{833bd2f5-fae9-441b-82ad-9117ffd29877}" mode="1" >0.07710903</value>
<value id="{d520e71a-b3e2-46d4-b0c6-688085fe5742}" mode="1" >0.28639463</value>
<value id="{ced1a494-71e9-4bc0-9973-a872920a4473}" mode="1" >1.08602405</value>
<value id="{16c48afd-7c15-4e07-beee-ce56c7b61c80}" mode="1" >0.16538025</value>
<value id="{e1aa96cf-3e30-4ad2-93ec-1494a0d60079}" mode="1" >1.00000000</value>
<value id="{1a074887-a3a3-43ee-8de2-34b8e6a7a5a5}" mode="1" >0.00000100</value>
<value id="{e1352cbc-9c2a-4650-8957-fb055156903b}" mode="1" >0.16000092</value>
<value id="{3f7ea94f-e14d-4b53-8bbd-53563d0c23c1}" mode="1" >0.29407570</value>
<value id="{9c657ab3-a738-40e2-92ae-b1128863fd78}" mode="1" >1.98959291</value>
<value id="{56e321a8-c542-420c-a494-e759e36ea78a}" mode="1" >0.10801291</value>
<value id="{77ce606f-b1c5-4911-bf36-79ea1b8f50ef}" mode="1" >0.33333334</value>
<value id="{fec79e7f-6c43-482f-9fff-cedfc13eaea7}" mode="1" >1.26772940</value>
<value id="{964db287-6df1-4fa8-baba-1e387d1fac12}" mode="1" >1.26772940</value>
<value id="{7844fda3-a049-4ec6-885f-cba693b160c9}" mode="1" >1.00000000</value>
<value id="{37d2f1f5-7da1-460a-a8a0-9d70e19e7da0}" mode="1" >1.07506883</value>
<value id="{1713b2f6-0778-43b4-b81a-725331e94260}" mode="1" >0.67707473</value>
<value id="{608ebd5c-d7b3-4c9a-8075-2204844bc42c}" mode="1" >1.73355865</value>
<value id="{5f20cb6a-ad07-4210-aaa1-a0ee628ee2d4}" mode="1" >0.76444215</value>
<value id="{dc16cdf0-7371-4027-bac0-7d26d9d21433}" mode="1" >0.35109249</value>
<value id="{c211de7a-2f05-44f9-b09f-51523639dd8e}" mode="1" >1.18131566</value>
<value id="{da8941a6-25be-42bd-9fc4-eb3bf5e4e6e1}" mode="1" >3.00000000</value>
<value id="{8ade719c-f9d9-4348-91cc-a50077821391}" mode="1" >0.22447671</value>
<value id="{aaa01bed-d7bb-4690-a71e-1ae6f64afc5a}" mode="1" >5.00000000</value>
<value id="{21c7e2af-f1a0-41c0-be87-b103ea56c714}" mode="1" >0.09000097</value>
<value id="{32c4cf2e-a76a-46b1-89bf-a4e4d2924309}" mode="1" >0.08000096</value>
<value id="{b52b40e8-cd42-4060-8d22-cf0c9e0859f9}" mode="1" >0.76972228</value>
<value id="{e9d2c154-945a-4024-b053-8e4c510f5ba3}" mode="1" >1.56563008</value>
<value id="{72d91f82-8446-4985-8a6c-7617db96ad59}" mode="4" >0</value>
<value id="{beca3791-f6ef-4ca6-8b17-b074357951d5}" mode="4" >0</value>
</preset>
<preset name="Fluty" number="8" >
<value id="{a4d4c497-04d4-4b7d-ad51-0f8832cb64bf}" mode="1" >0.98524410</value>
<value id="{b418386f-afe6-4d3c-b8d6-c6c96885e9ab}" mode="1" >1.64796364</value>
<value id="{f2ac6272-b33d-44fc-bb1e-fe52087e3a2b}" mode="1" >0.52427548</value>
<value id="{8052b29d-d6ae-4249-b9cd-1788a2faf77c}" mode="1" >0.38627648</value>
<value id="{3efde0c1-5828-4875-a997-174989989aa9}" mode="1" >0.00000100</value>
<value id="{fa34129e-d983-460c-bd0e-89fb3e798bcb}" mode="1" >1.00000000</value>
<value id="{17b249bd-27ed-44c7-9bac-a847a81165e3}" mode="1" >0.70595562</value>
<value id="{cba3fee2-d2a5-41b2-8842-34be212fa82a}" mode="1" >1.38320804</value>
<value id="{f0305ec9-814b-4107-a9b5-55a5a13f0118}" mode="1" >0.58946502</value>
<value id="{9f495b69-cdca-43c7-bc92-f26d9995caed}" mode="1" >0.71020597</value>
<value id="{3f29a847-8cf1-4076-9a69-e88b5360a810}" mode="1" >0.00000100</value>
<value id="{2ea377f7-6c31-4556-8e26-e47d9b6c000a}" mode="1" >2.00000000</value>
<value id="{a6a5a56d-13c6-4c09-b6e8-74086df6e352}" mode="1" >0.07000000</value>
<value id="{dde869a9-5d2a-454c-bff8-b8d407d19e87}" mode="1" >3.00000000</value>
<value id="{623cf6cd-548c-4212-ac65-a4761cfb5b7f}" mode="1" >0.70741987</value>
<value id="{833bd2f5-fae9-441b-82ad-9117ffd29877}" mode="1" >0.48335540</value>
<value id="{d520e71a-b3e2-46d4-b0c6-688085fe5742}" mode="1" >0.49383950</value>
<value id="{ced1a494-71e9-4bc0-9973-a872920a4473}" mode="1" >0.00000100</value>
<value id="{16c48afd-7c15-4e07-beee-ce56c7b61c80}" mode="1" >0.38029835</value>
<value id="{e1aa96cf-3e30-4ad2-93ec-1494a0d60079}" mode="1" >3.00000000</value>
<value id="{1a074887-a3a3-43ee-8de2-34b8e6a7a5a5}" mode="1" >0.33000088</value>
<value id="{e1352cbc-9c2a-4650-8957-fb055156903b}" mode="1" >0.34000084</value>
<value id="{3f7ea94f-e14d-4b53-8bbd-53563d0c23c1}" mode="1" >0.10513637</value>
<value id="{9c657ab3-a738-40e2-92ae-b1128863fd78}" mode="1" >0.04000099</value>
<value id="{56e321a8-c542-420c-a494-e759e36ea78a}" mode="1" >0.00000000</value>
<value id="{77ce606f-b1c5-4911-bf36-79ea1b8f50ef}" mode="1" >1.00000000</value>
<value id="{fec79e7f-6c43-482f-9fff-cedfc13eaea7}" mode="1" >0.09399924</value>
<value id="{964db287-6df1-4fa8-baba-1e387d1fac12}" mode="1" >0.09399924</value>
<value id="{7844fda3-a049-4ec6-885f-cba693b160c9}" mode="1" >0.09399924</value>
<value id="{37d2f1f5-7da1-460a-a8a0-9d70e19e7da0}" mode="1" >0.00000100</value>
<value id="{1713b2f6-0778-43b4-b81a-725331e94260}" mode="1" >0.16000000</value>
<value id="{608ebd5c-d7b3-4c9a-8075-2204844bc42c}" mode="1" >0.35776818</value>
<value id="{5f20cb6a-ad07-4210-aaa1-a0ee628ee2d4}" mode="1" >0.46415842</value>
<value id="{dc16cdf0-7371-4027-bac0-7d26d9d21433}" mode="1" >0.58610016</value>
<value id="{c211de7a-2f05-44f9-b09f-51523639dd8e}" mode="1" >0.00000100</value>
<value id="{da8941a6-25be-42bd-9fc4-eb3bf5e4e6e1}" mode="1" >4.00000000</value>
<value id="{8ade719c-f9d9-4348-91cc-a50077821391}" mode="1" >0.52810043</value>
<value id="{aaa01bed-d7bb-4690-a71e-1ae6f64afc5a}" mode="1" >1.00000000</value>
<value id="{21c7e2af-f1a0-41c0-be87-b103ea56c714}" mode="1" >0.10946730</value>
<value id="{32c4cf2e-a76a-46b1-89bf-a4e4d2924309}" mode="1" >0.14234683</value>
<value id="{b52b40e8-cd42-4060-8d22-cf0c9e0859f9}" mode="1" >0.04914349</value>
<value id="{e9d2c154-945a-4024-b053-8e4c510f5ba3}" mode="1" >0.00000100</value>
<value id="{72d91f82-8446-4985-8a6c-7617db96ad59}" mode="4" >0</value>
<value id="{beca3791-f6ef-4ca6-8b17-b074357951d5}" mode="4" >0</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="381" y="517" width="655" height="346" visible="false" loopStart="0" loopEnd="0">i 1 0 1 440 100 </EventPanel>

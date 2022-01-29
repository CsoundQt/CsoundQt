<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; This file implements as UDOs the basic parametric equalizers from
; Zoelzer's DAFX book (Chapter 2).
; They are a set of calculations for biquad filter coefficients to
; produce controllable second order filters.

opcode lpf2pole, a, ak
ain,kfc xin
ktrig changed kfc
if ktrig == 1 then
	kvalue = tan($M_PI * kfc / sr)
	kdenom = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
	knumb0 = (kvalue^2)
	kb0 = knumb0/kdenom
	knumb1 = 2 * (kvalue^2)
	kb1 = knumb1/kdenom
	knumb2 = (kvalue^2)
	kb2 = knumb2/kdenom
	knuma1 = 2 *((kvalue^2) - 1)
	ka1 = knuma1/kdenom
	knuma2 = 1 - ($M_SQRT2 * kvalue) + (kvalue^2)
	ka2 = knuma2/kdenom
	Sdisp sprintfk "b0=%.3f      b1=%.3f      b2=%.3f\n\na1=%.3f      a2=%.3f", kb0, kb1, kb2, ka1, ka2
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, kb2, 1, ka1, ka2 
xout afilt
endop

opcode hpf2pole, a, ak
ain,kfc xin
ktrig changed kfc
if ktrig == 1 then
	kvalue = tan($M_PI * kfc / sr)
	kdenom = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
	knum0 = 1
	kb0 = knum0/kdenom
	knumb1 = -2
	kb1 = knumb1/kdenom
	knumb2 = 1
	kb2 = knumb2/kdenom
	knuma1 = 2 *((kvalue^2) - 1)
	ka1 = knuma1/kdenom
	knuma2 = 1 - ($M_SQRT2 * kvalue) + (kvalue^2)
	ka2 = knuma2/kdenom
	Sdisp sprintfk "b0=%.3f      b1=%.3f      b2=%.3f\n\na1=%.3f      a2=%.3f", kb0, kb1, kb2, ka1, ka2
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, kb2, 1, ka1, ka2 
xout afilt
endop

opcode loshelf, a, akk
ain,kfc, kgain xin

ktrig changed kfc, kgain
if ktrig == 1 then
	kvalue = tan($M_PI * kfc / sr)
	if kgain >= 0 then
		kV0 = 10^(kgain/20)
		kdenom = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
		knumb0 = 1 + (sqrt(2*kV0) * kvalue) + (kV0 * kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kV0 * kvalue^2) - 1)
		kb1 = knumb1/kdenom
		knumb2 = 1 - (sqrt(2*kV0) * kvalue) + (kV0 * kvalue^2)
		kb2 = knumb2/kdenom
		knuma1 = 2 *((kvalue^2) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - ($M_SQRT2 * kvalue) + (kvalue^2)
		ka2 = knuma2/kdenom
	else
		kV0 = 10^(-kgain/20)
		kdenom = 1 + (sqrt(2*kV0) * kvalue) + (kV0 * kvalue^2)
		knumb0 = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kvalue^2) - 1 )
		kb1 = knumb1/kdenom
		knumb2 = 1 - (sqrt(2*kV0) * kvalue) + (kvalue^2)
		kb2 = knumb2/kdenom
		knuma1 = 2 *((kV0 * kvalue^2) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - (sqrt(2*kV0) * kvalue) + (kV0 * kvalue^2)
		ka2 = knuma2/kdenom

	endif
	Sdisp sprintfk "b0=%.3f      b1=%.3f      b2=%.3f\n\na1=%.3f      a2=%.3f", kb0, kb1, kb2, ka1, ka2
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, kb2, 1, ka1, ka2 
xout afilt
endop

opcode hishelf, a, akk
ain,kfc, kgain xin
ktrig changed kfc, kgain

if ktrig == 1 then
	kvalue = tan($M_PI * kfc / sr)
	kV0 = 10^(kgain/20)
	if kgain >= 0 then
		kV0 = 10^(kgain/20)
		kdenom = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
		knumb0 = kV0 + (sqrt(2*kV0) * kvalue) + (kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kvalue^2) - kV0)
		kb1 = knumb1/kdenom
		knumb2 = kV0 - (sqrt(2*kV0) * kvalue) + (kvalue^2)
		kb2 = knumb2/kdenom
		knuma1 = 2 *((kvalue^2) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - ($M_SQRT2 * kvalue) + (kvalue^2)
		ka2 = knuma2/kdenom
	else
		kV0 = 10^(-kgain/20)
		kdenom = kV0 + (sqrt(2*kV0) * kvalue) + (kvalue^2)
		knumb0 = 1 + ($M_SQRT2 * kvalue) + (kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kvalue^2) - 1 )
		kb1 = knumb1/kdenom
		knumb2 = 1 - ($M_SQRT2 * kvalue) + (kvalue^2)
		kb2 = knumb2/kdenom
		kdenom = 1 + (sqrt(2/kV0) * kvalue) + ((kvalue^2)/ kV0)
		knuma1 = 2 *(((kvalue^2)/ kV0) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - (sqrt(2/kV0) * kvalue) + ((kvalue^2)/ kV0)
		ka2 = knuma2/kdenom

	endif
	Sdisp sprintfk "b0=%.3f      b1=%.3f      b2=%.3f\n\na1=%.3f      a2=%.3f", kb0, kb1, kb2, ka1, ka2
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, kb2, 1, ka1, ka2 
xout afilt
endop

opcode eq2pole, a, akkk
ain,kfc, kgain, kQ xin

ktrig changed kfc, kgain, kQ
if ktrig == 1 then
	kvalue = tan($M_PI * kfc / sr)
	kV0 = 10^(kgain/20)
	if kgain >= 0 then
		kV0 = 10^(kgain/20)
		kdenom = 1 + (kvalue / kQ) + (kvalue^2)
		knumb0 = 1 + (kV0 * kvalue / kQ) + (kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kvalue^2) - 1)
		kb1 = knumb1/kdenom
		knumb2 = 1 - (kV0 * kvalue / kQ) + (kvalue^2)
		kb2 = knumb2/kdenom
		knuma1 = 2 *((kvalue^2) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - (kvalue / kQ) + (kvalue^2)
		ka2 = knuma2/kdenom
	else
		kV0 = 10^(-kgain/20)
		kdenom = 1 + (kV0 * kvalue / kQ) + (kvalue^2)
		knumb0 = 1 + (kvalue / kQ) + (kvalue^2)
		kb0 = knumb0/kdenom
		knumb1 = 2 * ((kvalue^2) - 1)
		kb1 = knumb1/kdenom
		knumb2 = 1 - (kvalue / kQ) + (kvalue^2)
		kb2 = knumb2/kdenom
		knuma1 = 2 *((kvalue^2) - 1)
		ka1 = knuma1/kdenom
		knuma2 = 1 - (kV0 * kvalue / kQ) + (kvalue^2)
		ka2 = knuma2/kdenom

	endif
	Sdisp sprintfk "b0=%.3f      b1=%.3f      b2=%.3f\n\na1=%.3f      a2=%.3f", kb0, kb1, kb2, ka1, ka2
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, kb2, 1, ka1, ka2 
xout afilt
endop

opcode allpass1, a, ak
ain,kfc xin
ktrig changed kfc
if ktrig == 1 then
	kvalue = tan($M_PI * kfc / sr)
	kc = (kvalue  - 1) / (kvalue + 1)
	kd = - cos(2* $M_PI* kfc / sr)
	kb0 = kc
	kb1 = 1
	ka0 = 1
	ka1 = kc
	Sdisp sprintfk "b0=%.3f      b1=%.3f\n\na1=%.3f", kb0, kb1, ka1
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, 0, ka0, ka1, 0
xout afilt
endop

opcode allpass2, a, akk
ain,kfc, kfb xin
ktrig changed kfc, kfb
if ktrig == 1 then
	kvalue = tan($M_PI * kfb / sr)
	kc = (kvalue  - 1) / (kvalue + 1)
	kd = - cos(2* $M_PI* kfc / sr)
	kb0 = - kc
	kb1 = kd * ( 1 - kc )
	kb2 = 1
	ka0 = 1
	ka1 = kd * ( 1 - kc )
	ka2 = - kc
	Sdisp sprintfk "b0=%.3f      b1=%.3f      b2=%.3f\n\na1=%.3f      a2=%.3f", kb0, kb1, kb2, ka1, ka2
	outvalue "coef", Sdisp
endif
afilt biquad ain, kb0, kb1, kb2, ka0, ka1, ka2
xout afilt
endop


instr 1
anoise noise 1, 0
ktype invalue "type"
kfreq invalue "freq"
kgain invalue "gain"
kQ invalue "Q"

if ktype == 0 then
	afilt lpf2pole anoise, kfreq
elseif ktype == 1 then
	afilt hpf2pole anoise, kfreq
elseif ktype == 2 then
	afilt loshelf anoise, kfreq, kgain
elseif ktype == 3 then
	afilt hishelf anoise, kfreq, kgain
elseif ktype == 4 then
	afilt eq2pole anoise, kfreq, kgain, kQ
elseif ktype == 5 then
	afilt allpass1 anoise, kfreq
elseif ktype == 6 then
	afilt allpass2 anoise, kfreq, kQ
else
	afilt = anoise
endif

dispfft afilt, 0.1, 4096
aout = afilt*0.02
aout clip aout, 0, 0.3 ; For ear and speaker protection from unstable filters
outs aout, aout
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
 <x>808</x>
 <y>138</y>
 <width>755</width>
 <height>510</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>204</r>
  <g>204</g>
  <b>204</b>
 </bgcolor>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>freq</objectName>
  <x>9</x>
  <y>205</y>
  <width>709</width>
  <height>35</height>
  <uuid>{0bd0d91d-2f3a-441f-a01b-6d78738906f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>1.00000000</minimum>
  <maximum>22050.00000000</maximum>
  <value>11631.92524683</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName/>
  <x>8</x>
  <y>262</y>
  <width>709</width>
  <height>386</height>
  <uuid>{8dcfe636-a222-4950-9553-5dd30cd898c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>0</value>
  <objectName2/>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>393</x>
  <y>234</y>
  <width>41</width>
  <height>24</height>
  <uuid>{1f0cb546-0de6-44c0-b80a-6a098d0fd56d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Hz</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Helvetica</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>freq</objectName>
  <x>327</x>
  <y>234</y>
  <width>69</width>
  <height>24</height>
  <uuid>{01ad6a68-ac02-42bb-8bb2-50451a11a288}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>11631.9</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Nimbus Sans [urw]</font>
  <fontsize>12</fontsize>
  <precision>1</precision>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>411</x>
  <y>67</y>
  <width>190</width>
  <height>26</height>
  <uuid>{a7205100-c056-490d-afc0-c38e7300043b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Biquad Coefficients</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Helvetica</font>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>type</objectName>
  <x>213</x>
  <y>121</y>
  <width>176</width>
  <height>30</height>
  <uuid>{0479174b-721c-44ca-9e46-0bc62bc7ebe2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>2nd order low-pass</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2nd order hi-pass</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2nd order low shelving</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2nd order high shelving</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Parametric eq</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>First order All Pass</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Second Order All Pass</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Bypass</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>gain</objectName>
  <x>12</x>
  <y>87</y>
  <width>80</width>
  <height>80</height>
  <uuid>{3d171c0d-cb02-4d2c-8388-0961068b8e4e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-20.00000000</minimum>
  <maximum>36.00000000</maximum>
  <value>25.29840000</value>
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
  <objectName/>
  <x>14</x>
  <y>59</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8c0420dc-4fcb-499f-9317-517e837c038a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Gain</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Helvetica</font>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>gain</objectName>
  <x>18</x>
  <y>171</y>
  <width>69</width>
  <height>24</height>
  <uuid>{66349cae-8fcb-4efe-b691-46c3a667d1f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>25.298</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Helvetica</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>341</x>
  <y>180</y>
  <width>80</width>
  <height>25</height>
  <uuid>{a2bdce04-8f5e-40fb-a743-e09d6a8eec89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Frequency</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Helvetica</font>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Q</objectName>
  <x>102</x>
  <y>88</y>
  <width>80</width>
  <height>80</height>
  <uuid>{ddba3cab-bc78-416b-b421-8fb9d8b845b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.10000000</minimum>
  <maximum>20.00000000</maximum>
  <value>14.69665000</value>
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
  <objectName/>
  <x>104</x>
  <y>60</y>
  <width>80</width>
  <height>25</height>
  <uuid>{81820bef-c5cc-45b0-8ded-49e9160158e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Q</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Helvetica</font>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>Q</objectName>
  <x>108</x>
  <y>172</y>
  <width>69</width>
  <height>24</height>
  <uuid>{094450ee-6000-47b1-a738-91ee9a291e4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>14.697</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Helvetica</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>213</x>
  <y>94</y>
  <width>130</width>
  <height>25</height>
  <uuid>{f7d12575-56ae-49e5-b37f-8661a728d2bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Filter type</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Helvetica</font>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>5</y>
  <width>709</width>
  <height>49</height>
  <uuid>{5cd431c8-1032-4c45-8ddf-beaaaa72f1dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Biquad Filter Lab</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Noto Sans</font>
  <fontsize>28</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>179</r>
   <g>179</g>
   <b>179</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>coef</objectName>
  <x>410</x>
  <y>91</y>
  <width>310</width>
  <height>80</height>
  <uuid>{64a3dc1c-c9d4-484c-a939-5c207787c41f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>b0=0.319      b1=0.637      b2=0.319

a1=0.101      a2=0.173</label>
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
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="557" y="270" width="608" height="322" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

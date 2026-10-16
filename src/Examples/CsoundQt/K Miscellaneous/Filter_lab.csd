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

















<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="557" y="270" width="608" height="322" visible="false" loopStart="0" loopEnd="0">    </EventPanel>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>freq</objectName>
  <x>9</x>
  <y>205</y>
  <width>709</width>
  <height>35</height>
  <uuid>{0bd0d91d-2f3a-441f-a01b-6d78738906f2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>1.00000000</minimum>
  <maximum>22050.00000000</maximum>
  <value>8055.57122708</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">true</randomizable>
 </bsbObject>
 <bsbObject type="BSBGraph" version="2">
  <objectName/>
  <x>8</x>
  <y>262</y>
  <width>709</width>
  <height>386</height>
  <uuid>{8dcfe636-a222-4950-9553-5dd30cd898c0}</uuid>
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
  <showSelector>true</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>true</showScrollbars>
  <enableTables>true</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>397</x>
  <y>234</y>
  <width>41</width>
  <height>24</height>
  <uuid>{1f0cb546-0de6-44c0-b80a-6a098d0fd56d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Hz</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>0</r>
   <g>0</g>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>411</x>
  <y>67</y>
  <width>190</width>
  <height>26</height>
  <uuid>{a7205100-c056-490d-afc0-c38e7300043b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Biquad Coefficients</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>0</r>
   <g>0</g>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>type</objectName>
  <x>213</x>
  <y>121</y>
  <width>176</width>
  <height>30</height>
  <uuid>{0479174b-721c-44ca-9e46-0bc62bc7ebe2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
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
  <selectedIndex>4</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>gain</objectName>
  <x>12</x>
  <y>87</y>
  <width>80</width>
  <height>80</height>
  <uuid>{3d171c0d-cb02-4d2c-8388-0961068b8e4e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-20.00000000</minimum>
  <maximum>36.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>16.40000000</value>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>14</x>
  <y>59</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8c0420dc-4fcb-499f-9317-517e837c038a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Gain</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>0</r>
   <g>0</g>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>341</x>
  <y>180</y>
  <width>80</width>
  <height>25</height>
  <uuid>{a2bdce04-8f5e-40fb-a743-e09d6a8eec89}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Frequency</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>0</r>
   <g>0</g>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>Q</objectName>
  <x>102</x>
  <y>88</y>
  <width>80</width>
  <height>80</height>
  <uuid>{ddba3cab-bc78-416b-b421-8fb9d8b845b1}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.10000000</minimum>
  <maximum>100.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>28.43164000</value>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>104</x>
  <y>60</y>
  <width>80</width>
  <height>25</height>
  <uuid>{81820bef-c5cc-45b0-8ded-49e9160158e1}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Q</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>0</r>
   <g>0</g>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>213</x>
  <y>94</y>
  <width>130</width>
  <height>25</height>
  <uuid>{f7d12575-56ae-49e5-b37f-8661a728d2bb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Filter type</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>0</r>
   <g>0</g>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>13</x>
  <y>5</y>
  <width>709</width>
  <height>49</height>
  <uuid>{5cd431c8-1032-4c45-8ddf-beaaaa72f1dd}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Biquad Filter Lab</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Noto Sans</font>
  <fontsize>28</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <objectName>coef</objectName>
  <x>410</x>
  <y>91</y>
  <width>310</width>
  <height>80</height>
  <uuid>{64a3dc1c-c9d4-484c-a939-5c207787c41f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>b0=1.084      b1=-0.973      b2=0.885

a1=-0.973      a2=0.970</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <color>
   <r>0</r>
   <g>0</g>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>freq</objectName>
  <x>317</x>
  <y>234</y>
  <width>80</width>
  <height>25</height>
  <uuid>{346e0238-dc71-49e2-a8e5-f2a54a8ef489}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>8056</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>0</precision>
  <padding>3</padding>
  <color>
   <r>34</r>
   <g>34</g>
   <b>34</b>
  </color>
  <bgcolor mode="background">
   <r>245</r>
   <g>245</g>
   <b>245</b>
  </bgcolor>
  <bordercolor>
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bordercolor>
  <bordermode>true</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

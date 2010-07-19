<CsoundSynthesizer>
<CsOptions>
;-+rtaudio=jack -idac -odac -+jack_client=Csound
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 128
nchnls = 1
0dbfs = 1

turnon 1
fsig2  pvsinit   1024, 256, 1024, 0

instr 1
klearning init 0
ifftsize = 1024
ioverlap = 256
iwinsize = 1024
iwintype = 0

kratio invalue "ratio"
kgain invalue "gain"
klearn invalue "learn"
kbypass invalue "bypass"

ain inch 1

if kbypass == 1 then
	aout = ain
else
	fsig  pvsanal  ain, ifftsize, ioverlap, iwinsize, iwintype
	ffilt pvstencil fsig, kratio, kgain, 1
	aout  pvsynth  ffilt
endif
	
out aout

if klearn == 1 then
	krms rms ain
	if krms > 0.00000001 then
		klearning = klearning + 1
		kflag pvsftw fsig, 2
		vaddv  1, 2, 1024
	endif
elseif klearning > 0 then
	vmult 1, 1/klearning, 1024
	klearning = 0
endif

outvalue  "learning", (klearning == 0 ? 0:1)
endin

instr 2 ;clear mask table
	gin  ftgen  1, 0, 1024, 2, 0
	turnoff
endin

instr 3 ;mask white noise
	gin  ftgen  1, 0, 1024, -7, 0.006, 1024, 0.006
	turnoff
endin

</CsInstruments>
<CsScore>
f 1 0 1024 -7 0.006 1024 0.006
f 2 0 1024 2 0 ;temp amp table
f 0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>454</x>
 <y>149</y>
 <width>352</width>
 <height>267</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>ratio</objectName>
  <x>5</x>
  <y>5</y>
  <width>20</width>
  <height>200</height>
  <uuid>{a4c39f46-4d94-4530-af01-0bb3554759ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>gain</objectName>
  <x>45</x>
  <y>5</y>
  <width>20</width>
  <height>200</height>
  <uuid>{7144b550-cd89-4a26-850d-eabccac898f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1</x>
  <y>200</y>
  <width>34</width>
  <height>23</height>
  <uuid>{aa008cf6-defc-48c0-b4d7-48d301fa8852}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>ratio</label>
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
  <y>200</y>
  <width>39</width>
  <height>24</height>
  <uuid>{8a12090d-fad7-476d-8051-e46377cd9e65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Gain</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>learn</objectName>
  <x>75</x>
  <y>180</y>
  <width>30</width>
  <height>30</height>
  <uuid>{1dad9308-a031-4e4e-b182-315c289338f3}</uuid>
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
  <x>90</x>
  <y>183</y>
  <width>60</width>
  <height>25</height>
  <uuid>{d6b0e393-3d46-477f-b320-a353c5984eb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Learn</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>147</r>
   <g>52</g>
   <b>14</b>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>75</x>
  <y>158</y>
  <width>100</width>
  <height>25</height>
  <uuid>{6adaeefc-4f17-486a-9bff-61607dbf5ea8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Clear mask</text>
  <image>/</image>
  <eventLine>i2 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName/>
  <x>75</x>
  <y>130</y>
  <width>30</width>
  <height>30</height>
  <uuid>{ef9646a0-ea0e-4bda-a05d-4d8c5748f646}</uuid>
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
  <x>90</x>
  <y>135</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b87655c4-4638-45ba-9b03-453c1448e630}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Bypass</label>
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
  <x>75</x>
  <y>5</y>
  <width>160</width>
  <height>125</height>
  <uuid>{e5158635-d1f0-4070-b7bd-e8f413701a70}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This noise reduction unit can sample a noise print and then remove it through spectral masking. First clear the mask then activate the learn while the noise is playing. Deactivate the learn button and the noise will be removed.</label>
  <alignment>left</alignment>
  <font>Helvetica</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>127</r>
   <g>112</g>
   <b>94</b>
  </color>
  <bgcolor mode="background">
   <r>194</r>
   <g>194</g>
   <b>194</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>4</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>learning</objectName>
  <x>236</x>
  <y>191</y>
  <width>30</width>
  <height>30</height>
  <uuid>{2d1b5c28-1a8c-447a-8d3b-a8ab34394597}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>white</objectName>
  <x>190</x>
  <y>158</y>
  <width>132</width>
  <height>25</height>
  <uuid>{b5c9f013-75ca-4caa-8b31-c7fbb0bb01b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Mask white noise</text>
  <image>/</image>
  <eventLine>i3 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
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
WindowBounds: 454 149 352 267
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {43690, 43690, 32639}
ioSlider {5, 5} {20, 200} 0.000000 1.000000 0.000000 ratio
ioSlider {45, 5} {20, 200} 0.000000 0.100000 0.100000 gain
ioText {1, 200} {34, 23} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ratio
ioText {38, 200} {33, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Gain
ioCheckbox {75, 180} {30, 30} off learn
ioText {90, 183} {60, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {37632, 13312, 3584} {65280, 65280, 65280} nobackground noborder Learn
ioButton {75, 158} {100, 25} event 1.000000 "button1" "Clear mask" "/" i2 0 1
ioCheckbox {75, 130} {30, 30} off 
ioText {90, 135} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Bypass
ioText {75, 5} {160, 125} label 0.000000 0.00100 "" left "Helvetica" 10 {32512, 28672, 24064} {49664, 49664, 49664} nobackground noborder This noise reduction unit can sample a noise print and then remove it through spectral masking. First clear the mask then activate the learn while the noise is playing. Deactivate the learn button and the noise will be removed.
ioCheckbox {236, 191} {30, 30} off learning
ioButton {190, 158} {132, 25} event 1.000000 "white" "Mask white noise" "/" i3 0 1
</MacGUI>

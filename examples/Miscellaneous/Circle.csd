<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
kfreq invalue "freq"
kamp invalue "amp"
kx oscil 0.4*kamp, kfreq*2, 1
ky oscil 0.4*kamp, kfreq*2, 1, 0.25
outvalue "x", kx + 0.5
outvalue "y", ky + 0.5
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 100
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>740</x>
 <y>303</y>
 <width>618</width>
 <height>194</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>94</r>
  <g>166</g>
  <b>170</b>
 </bgcolor>
 <bsbObject version="2" type="BSBController">
  <objectName>y</objectName>
  <x>449</x>
  <y>11</y>
  <width>150</width>
  <height>150</height>
  <uuid>{6a83a789-228c-44f1-8a26-6558d2e760d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>x</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.31112137</xValue>
  <yValue>0.64370799</yValue>
  <type>point</type>
  <pointsize>10</pointsize>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>269</x>
  <y>161</y>
  <width>35</width>
  <height>25</height>
  <uuid>{fb601758-0de8-440e-ae38-2bd4127c6ec4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Freq</label>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>freq</objectName>
  <x>262</x>
  <y>11</y>
  <width>150</width>
  <height>150</height>
  <uuid>{8fa2948b-cd3c-4e06-9e00-aa68396a8a7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>amp</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.42000000</xValue>
  <yValue>0.59333333</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>234</r>
   <g>82</g>
   <b>65</b>
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
  <x>232</x>
  <y>131</y>
  <width>35</width>
  <height>25</height>
  <uuid>{577c7acd-d16e-4c30-bfab-15bb6fd2f56b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amp</label>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>17</x>
  <y>15</y>
  <width>210</width>
  <height>72</height>
  <uuid>{8fa66891-785d-49bf-ba37-e37006cffbf8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Watch the rotation of the point change its rotation properties when you move the controller</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>75</x>
  <y>109</y>
  <width>100</width>
  <height>30</height>
  <uuid>{d6099110-a561-4c5a-a686-04283523faf3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Run</text>
  <image>/</image>
  <eventLine/>
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
WindowBounds: 740 303 618 194
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {24158, 42662, 43690}
ioMeter {449, 11} {150, 150} {0, 59904, 0} "y" 0.311121 "x" 0.643708 point 10 0 mouse
ioText {225, 160} {35, 25} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Freq
ioMeter {262, 11} {150, 150} {59904, 20992, 16640} "freq" 0.420000 "amp" 0.593333 crosshair 1 0 mouse
ioText {190, 130} {35, 25} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Amp
ioText {95, 70} {80, 25} label 0.000000 0.00100 "" left "Arial" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Watch the rotation of the point change its rotation properties when you move the controller
ioButton {75, 109} {100, 30} value 1.000000 "_Play" "Run" "/" 
</MacGUI>

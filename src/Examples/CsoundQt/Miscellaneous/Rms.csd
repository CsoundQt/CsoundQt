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

	outvalue "freq", kfreq
	ainput inch 1
	krms rms ainput
	outvalue "rms", krms
	
	alow butlp  ainput, kfreq
	krmslow rms alow
	outvalue "low", krmslow
	
	ahi buthp  ainput, kfreq
	krmshi rms ahi
	outvalue "hi", krmshi
endin

</CsInstruments>
<CsScore>
i 1 0 9600
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>624</x>
 <y>230</y>
 <width>313</width>
 <height>218</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>195</r>
  <g>198</g>
  <b>199</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName>chann</objectName>
  <x>134</x>
  <y>20</y>
  <width>140</width>
  <height>100</height>
  <uuid>{c67c31d2-9e30-4092-bb24-a1a8b40b7528}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Rms values for the complete signal and for two separate parts of the spectrum. Use the knob to select crossover frequency</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>39</x>
  <y>20</y>
  <width>30</width>
  <height>150</height>
  <uuid>{19ad6187-b142-45ce-98fd-835004f905cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>rms</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00003200</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>234</r>
   <g>71</g>
   <b>128</b>
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
  <x>39</x>
  <y>170</y>
  <width>40</width>
  <height>20</height>
  <uuid>{3ba5f2aa-74d1-474a-b335-3eedf90b8c6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Rms</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>79</x>
  <y>20</y>
  <width>15</width>
  <height>150</height>
  <uuid>{dabef942-d7a0-4f55-ad58-27c248892842}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>low</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00001900</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>170</r>
   <g>85</g>
   <b>255</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName/>
  <x>109</x>
  <y>20</y>
  <width>15</width>
  <height>150</height>
  <uuid>{a1e351b4-9225-48df-b2e0-4c305c5b5d3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>hi</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00002600</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>234</r>
   <g>229</g>
   <b>63</b>
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
  <x>79</x>
  <y>170</y>
  <width>25</width>
  <height>20</height>
  <uuid>{c26fc2d2-a713-4ece-b7c7-ee5251d46f78}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Lo</label>
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
  <x>109</x>
  <y>170</y>
  <width>25</width>
  <height>20</height>
  <uuid>{d7b0a663-0979-4aaf-956b-6a947d25a3e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Hi</label>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>freq</objectName>
  <x>151</x>
  <y>125</y>
  <width>50</width>
  <height>50</height>
  <uuid>{0b3529e7-a1e7-4d37-8303-ff64b6e949e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>100.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>600.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>134</x>
  <y>170</y>
  <width>81</width>
  <height>22</height>
  <uuid>{9a777856-ad48-4915-a0a5-2650bf2f1e11}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Crossover</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>freq</objectName>
  <x>207</x>
  <y>136</y>
  <width>70</width>
  <height>26</height>
  <uuid>{10aa0bfc-cc59-499e-9758-2f8eedff1a77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>600.0000</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <bordermode>border</bordermode>
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
WindowBounds: 624 230 313 218
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {50115, 50886, 51143}
ioText {100, 5} {140, 100} label 0.000000 0.00100 "chann" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Rms values for the complete signal and for two separate parts of the spectrum. Use the knob to select crossover frequency
ioMeter {39, 20} {30, 150} {59904, 18176, 32768} "" 0.000000 "rms" 0.000032 fill 1 0 mouse
ioText {5, 155} {40, 20} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Rms
ioMeter {79, 20} {15, 150} {43520, 21760, 65280} "" 0.000000 "low" 0.000019 fill 1 0 mouse
ioMeter {109, 20} {15, 150} {59904, 58624, 16128} "" 0.000000 "hi" 0.000026 fill 1 0 mouse
ioText {45, 155} {25, 20} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Lo
ioText {75, 155} {25, 20} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Hi
ioKnob {151, 125} {50, 50} 1000.000000 100.000000 0.010000 600.000000 freq
ioText {100, 155} {60, 20} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Crossover
ioText {160, 120} {80, 25} display 600.000000 0.00100 "freq" left "Arial" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 600.0000
</MacGUI>

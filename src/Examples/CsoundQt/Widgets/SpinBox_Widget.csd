<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
kamp invalue "amp"
kfreq invalue "freq"
aout oscil kamp/ 10, kfreq, 1
outs aout, aout
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 3600
</CsScore>
</CsoundSynthesizer>







<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>635</x>
 <y>201</y>
 <width>303</width>
 <height>219</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>138</r>
  <g>149</g>
  <b>156</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>35</x>
  <y>8</y>
  <width>218</width>
  <height>40</height>
  <uuid>{0df0bb40-d88d-4022-a006-19902725d853}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>SpinBox Widget</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>51</y>
  <width>269</width>
  <height>56</height>
  <uuid>{fb0b903a-20d0-4307-b80b-69ddd86d4e33}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>SpinBox widgets allow insertion of numbers with the keyboard and the mouse. They work in a similar way to other text or value widgets.</label>
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
   <r>191</r>
   <g>204</g>
   <b>234</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>freq</objectName>
  <x>138</x>
  <y>113</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0cc03e61-cc21-4839-983f-4de92e55cd2d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
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
  <resolution>10.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>440</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>amp</objectName>
  <x>138</x>
  <y>148</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ee8084d6-7831-4975-8cac-acd49502e1d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
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
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>56</x>
  <y>114</y>
  <width>80</width>
  <height>25</height>
  <uuid>{96332145-309f-415d-aa55-16c7240bc9b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Freq</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>56</x>
  <y>147</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8cadb868-6f73-4336-9628-1bb720666234}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amp</label>
  <alignment>right</alignment>
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
 <objectName/>
 <x>635</x>
 <y>201</y>
 <width>303</width>
 <height>219</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {35466, 38293, 40092}
ioText {35, 8} {218, 40} display 0.000000 0.00100 "" center "Arial" 24 {0, 0, 0} {59392, 59392, 59392} nobackground noborder SpinBox Widget
ioText {7, 51} {269, 53} display 0.000000 0.00100 "" left "Arial" 12 {0, 0, 0} {48896, 52224, 59904} nobackground noborder SpinBox widgets allow insertion of numbers with the keyboard and the mouse. They work in a similar way to other text or value widgets.
ioText {138, 114} {80, 25} editnum 440.000000 10.000000 "freq" left "" 0 {0, 0, 0} {59392, 59392, 59392} nobackground noborder 440.000000
ioText {138, 148} {80, 25} editnum 0.300000 0.100000 "amp" left "" 0 {0, 0, 0} {59392, 59392, 59392} nobackground noborder 0.300000
ioText {56, 114} {80, 25} display 0.000000 0.00100 "" right "Arial" 12 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Freq
ioText {56, 147} {80, 25} display 0.000000 0.00100 "" right "Arial" 12 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Amp
</MacGUI>

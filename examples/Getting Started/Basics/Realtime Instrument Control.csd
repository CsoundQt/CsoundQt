/*Getting started.. 1.7 Realtime Instrument Control

This instrument provides two control possibilities to a sine oscillator from the graphical user interface (GUI). 

Open the widget window, press 'Run' and move the sliders!

You can set the channel on which widgets receive by right-clicking on the widget and choosing 'Properties'
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
kFreq invalue "freq" 	; userdefined channel: freq
kAmp invalue "amp" 	; userdefined channel: amp
kAmp port kAmp, .02 	; this smoothes the incoming slider values
kFreq port kFreq, .02    ; smoothing is usually required to avoid 'zipper noise'
aSine poscil3 kAmp, kFreq, 1
outs aSine, aSine
endin

</CsInstruments>

<CsScore>
f 1 0 1024 10 1
i 1 0 3600 			;calls the instrument, and plays for 3600 seconds
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Nov. 2009) - Incontri HMT-Hannover
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1013</x>
 <y>279</y>
 <width>563</width>
 <height>397</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>160</r>
  <g>158</g>
  <b>162</b>
 </bgcolor>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>16</x>
  <y>234</y>
  <width>266</width>
  <height>147</height>
  <uuid>{546018a6-f10c-4f00-b707-593b7713dd57}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>freq</objectName>
  <x>16</x>
  <y>45</y>
  <width>257</width>
  <height>38</height>
  <uuid>{40fda0db-fe7a-4e5e-83b7-efb1aa9fdd7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>200.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>433.46303500</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>amp</objectName>
  <x>17</x>
  <y>149</y>
  <width>267</width>
  <height>43</height>
  <uuid>{923df544-20e6-4881-a63e-e1d5cbacb793}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.17603000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>16</x>
  <y>12</y>
  <width>231</width>
  <height>31</height>
  <uuid>{2f6e0bb1-0572-4de2-a4a7-f0cff14be5e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Frequency: 200-1000 Hz</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
  <x>16</x>
  <y>118</y>
  <width>231</width>
  <height>31</height>
  <uuid>{248a601f-2231-437b-bd55-306f2dd67c1a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amplitude: 0-1</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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

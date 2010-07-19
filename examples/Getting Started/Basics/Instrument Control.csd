/*Getting started.. 1.6 Instrument Control from the Score

Instrument no. 1 provides two control possibilities for a sine oscillator. 
Volume and pitch can be determined from the score. The different values for a score instruction are called parameter-fields. For example the score below uses 5 p-fields:
i1 	0 	2 	0.8 	440

When used inside an instrument, the values from the score are referenced using a 'p' and the number of the p-field.
p1, p2 & p3 are required arguments for each instrument, and they have fixed meaning. All values after that can be freely assigned.

p1 - instrument number
p2 - start time
p3 - duration
---
p4 - amplitude (0-1)
p5 - frequency (Hz)

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
aSine poscil3 p4, p5, 1 		; Here, a different oscillator type is used, which has more flexibility and higher precision.
	outs aSine, aSine
endin

</CsInstruments>

<CsScore>
f 1 0 1024 10 1
;ins strt dur  amp  freq  
i 1 	0 	2 	0.8 	440		; loud
i 1 	3 	2	0.1	554.365	; quiet
i 1 	6 	2	0.4	659.255	

i 1 	9 	3	0.1	440  		; you can layer more instances of the same instrument easily
i 1 	9.5 	3.5	0.2	554.365
i 1 	10 	3	0.1	659.255
i 1 	10.2 	2.5	0.15	783.991
i 1 	10.8 	2	0.3	932.328
e
; Keep in mind, that in "realtime mode", the number of layers is limited by your machines CPU power.
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Nov. 2009) - Incontri HMT-Hannover

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>980</x>
 <y>299</y>
 <width>321</width>
 <height>461</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>160</r>
  <g>158</g>
  <b>162</b>
 </bgcolor>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>28</x>
  <y>282</y>
  <width>255</width>
  <height>150</height>
  <uuid>{d7080d2c-9587-414f-bd0d-3f9d6f393a49}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>29</x>
  <y>230</y>
  <width>254</width>
  <height>53</height>
  <uuid>{ede4c1b4-2e64-4b98-98f8-f6179b09cb0f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The scope shows the current output-waveform.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBGraph">
  <objectName/>
  <x>29</x>
  <y>80</y>
  <width>251</width>
  <height>109</height>
  <uuid>{1c65da94-898d-49f2-b94f-472fb9a72903}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>29</x>
  <y>20</y>
  <width>251</width>
  <height>61</height>
  <uuid>{3c3dcb27-288d-4ae0-8022-28c33c7021c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The pure waveform used by the oscillator is displayed in this Graph widget.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 980 299 321 461
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41120, 40606, 41634}
ioGraph {28, 282} {255, 150} scope 2.000000 -255 
ioText {30, 229} {254, 53} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The scope shows the current output-waveform.
ioGraph {29, 80} {251, 109} table 0.000000 1.000000 
ioText {29, 21} {251, 61} label 0.000000 0.00100 "" left "DejaVu Sans" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The pure waveform used by the oscillator is displayed in this Graph widget.
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="604" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

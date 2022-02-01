/*Getting started.. 1.4 Basic Elements: Constants and Variables

Variables are named 'cells' or 'slots' which contain data. They may be updated at one of the available update rates: i, k and a, which stand for initialization, control and audio.
The type of variable is determined by the first letter of its name (i,k,a). The names can be easier to read, if you start new words with big letters.

For example:
aMyAudioVariable
kMyControlVariable
iThisIsTheInitVariable

Numeric Value types: (From: An Overview of Csound Variable Types by Andres Cabrera (Csound Journal Issue 10 on www.csounds.com)) 
	a-type: These variables hold audio samples, or control signals that are 
		calculated and updated every audio sample.

	k-type: These variables hold scalar values which are updated only 
		once per control period. 

	i-type: Initialization variables are only updated on every note's 
		initialization pass.

More detailed information can be found here:
-Constants and Variables (Menu: Help->Csound Manual->1. Overview - Syntax of the orchestra->Constants and Variables)
-An Overview of Csound Variable Types by Andres Cabrera (Csound Journal Issue 10 on www.csounds.com)
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 2
kFreq expon 100, 5, 1000 	; kFreq is used to carry the 'expon' output as k-type
aOut  oscili 0.2, kFreq, 1 	; aOut carries the 'oscil' output as a-type 
	outvalue "freqsweep", kFreq  ; k-type values can be displayed on widgets
	outs aOut, aOut 			; a-type values can be played by the computers audio output
endin


</CsInstruments>
<CsScore>
f 1 0 1024 10 1 			; this function table contains the sine information
i 2 0 5 				; the instrument is called and plays for 5 seconds
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
  <r>162</r>
  <g>143</g>
  <b>151</b>
 </bgcolor>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>freqsweep</objectName>
  <x>108</x>
  <y>37</y>
  <width>144</width>
  <height>29</height>
  <uuid>{e0798988-168d-430b-a9b7-b8f2313ca7bf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>999.1507</label>
  <alignment>center</alignment>
  <font>Helvetica</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>109</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>22</x>
  <y>365</y>
  <width>255</width>
  <height>150</height>
  <uuid>{98a4c895-a461-408e-9ab2-543b97475130}</uuid>
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
  <x>21</x>
  <y>7</y>
  <width>248</width>
  <height>71</height>
  <uuid>{6b72ecb9-3089-4674-b08a-8adc73a46b3e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This label displays the current frequency:</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>313</y>
  <width>254</width>
  <height>53</height>
  <uuid>{5f31db51-4df9-4b43-8f7d-340609938c13}</uuid>
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
  <x>21</x>
  <y>165</y>
  <width>251</width>
  <height>109</height>
  <uuid>{8ca94d8e-b7f1-42ea-8842-6971bea7aa46}</uuid>
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
  <x>21</x>
  <y>105</y>
  <width>251</width>
  <height>61</height>
  <uuid>{78869346-10bb-48e9-91c8-84e4b7e3e2f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The pure waveform used by the oscillator is visable in the Graph display.</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>freqsweep</objectName>
  <x>108</x>
  <y>37</y>
  <width>144</width>
  <height>29</height>
  <uuid>{2a0e9cca-d3b3-4fbc-8e24-374c23d39941}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>999.1507</label>
  <alignment>center</alignment>
  <font>Helvetica</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>109</g>
   <b>0</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>22</x>
  <y>365</y>
  <width>255</width>
  <height>150</height>
  <uuid>{a1a2b99b-4f02-465a-8725-e03da3c9c551}</uuid>
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
  <x>21</x>
  <y>7</y>
  <width>248</width>
  <height>71</height>
  <uuid>{17ce6c00-b473-4ea4-9bf4-44a0304a85a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This label displays the current frequency:</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>313</y>
  <width>254</width>
  <height>53</height>
  <uuid>{ee5ec7fb-9af7-44f6-b84e-3a7d91d19d68}</uuid>
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
  <x>21</x>
  <y>165</y>
  <width>251</width>
  <height>109</height>
  <uuid>{ef1ce543-98ba-4cf3-8f83-7404ec9981e1}</uuid>
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
  <x>21</x>
  <y>105</y>
  <width>251</width>
  <height>61</height>
  <uuid>{8ac76c90-0fcc-4387-a913-ee6318a09765}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The pure waveform used by the oscillator is visable in the Graph display.</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

/*Getting started.. 1.3 Basic Elements: Opcodes

The fundamental building blocks of a Csound instrument is the opcode. 
Each opcode can be seen as little program itself, that does a specific task. Opcodes get a bold-blue highlighting in the CsoundQt editor. In this example 'line', 'expon', 'oscil', 'outvalue' and 'outs', are the opcodes used.

The names of opcodes are usually a short form of their functionality.
'line' -  generates a linear changing value between specified points
'expon' - generates a exponential curve between two points
'oscil' - is a tone generator (an oscillator)
'outvalue' - sends a value to a user defined channel, in this case to the widget display
'outs' - writes stereo audio data to an external audio device

It is important to remember that opcodes receive their input arguments on the right and output their results on the left, like this:

output Opcode input1, input2

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
kFreq line 100, 5, 1000 		; 'line' generates a linear ramp, from 100-1000 Hz, taking 5 seconds
aOut  oscili 0.2, kFreq, 1	; an oscillator whose frequency is taken from the value produced by 'line'
	outvalue "freqsweep", kFreq   ; show the value from 'line' in a widget
     outs aOut, aOut			 ; send the oscillator's audio to the audio output
endin


instr 2
kFreq expon 100, 5, 1000 		; the 'expon' exponential curve is more useful when working with frequencies
aOut  oscili 0.2, kFreq, 1
	outvalue "freqsweep", kFreq
	outs aOut, aOut
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1 				; the basic sine waveform for the oscillator is generated here 
i 1 0 5
i 2 5 5					; the exponential curve goes more even thought the octaves
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>21</x>
  <y>7</y>
  <width>248</width>
  <height>71</height>
  <uuid>{8a703a13-1bbf-4338-8e0a-993e086a405e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>This label displays the current frequency:</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>freqsweep</objectName>
  <x>108</x>
  <y>37</y>
  <width>144</width>
  <height>29</height>
  <uuid>{30e5e14c-4c4b-46a1-8584-d8d488ec61e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>409.663</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Sans Serif</font>
  <fontsize>16</fontsize>
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
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>22</x>
  <y>365</y>
  <width>255</width>
  <height>150</height>
  <uuid>{3e0a7775-89a7-4f52-85ea-52e3ff2348b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>22</x>
  <y>313</y>
  <width>254</width>
  <height>53</height>
  <uuid>{f47b80f1-e5e6-4020-9065-17df4bb3ed44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The scope shows the current output-waveform.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBGraph" version="2">
  <objectName/>
  <x>20</x>
  <y>180</y>
  <width>251</width>
  <height>109</height>
  <uuid>{17cbc48e-c1f3-4cae-aabc-d738a68aa532}</uuid>
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
  <modex>auto</modex>
  <modey>auto</modey>
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
  <x>21</x>
  <y>105</y>
  <width>251</width>
  <height>69</height>
  <uuid>{9e3bc813-428f-4648-b9cd-5084a7fbe634}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The pure waveform used by the oscillator is visable in the Graph display.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

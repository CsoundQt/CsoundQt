/*Getting started.. Realtime Interaction: Live Audio Input

Two very common live-electronic uscases are modifying an incoming signal in realtime, or analysing it. 
To avoid acoustic feedbacks, this example, does not output the input-signal!

Here, the input's frequency and amplitude are analysed in realtime and displayed on the Widget-Panel. 
The second instrument can be started, which uses these information to control an oscillator.

(If this is using to much CPU power and does crackle, increase the buffersize in the Preferences Menu(->Run->Buffer Size). 
A good startingpoint is  Buffersize (-b)=128; HW Buffersize(-B)=512.)

More information concerning realtime-audio can be found in the Csound-Manual: Using Csound-> Optimizing Audio I/O Latency
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps =  32
nchnls = 1
0dbfs = 1

instr 1
aInput inch 1						; read audiohardware channel 1
ifftsize = 1024						; set the buffersize for later fft-analysis
iwtype = 1   						; hanning window
fsig pvsanal   aInput, ifftsize, ifftsize/4, ifftsize, iwtype	; generate an fsig from the mono audio source
gkFreq, gkAmp pvspitch fsig, 0.01			; pitch and amplitude analysis tool
outvalue "pitch", gkFreq				; send pitch-values to Widget
outvalue "amp", gkAmp					; send amplitude-values to Widget
endin



instr 2
aSrc oscili gkAmp, gkFreq, 1			; instrument 1 used global k-variables, so they can be read-out here..
kFeedback=0.6					; feedback-amount for the delay
aDelay delayr 1						
aWet	deltapi 0.2
	delayw aSrc+(aWet*kFeedback)
aOut = aSrc+(aWet*0.3)				; mixing the oscillator with the delay
out aOut
endin

</CsInstruments>
<CsScore>
f 1 0 256 7 0 128 1 0 -1 128 0
i 1 0 3600						; instrument 1 runs for one hour				
e					
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 




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
  <r>132</r>
  <g>162</g>
  <b>8</b>
 </bgcolor>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>pitch</objectName>
  <x>22</x>
  <y>81</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2ed22600-54f1-40bd-84c6-8a0812cbfa4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act="continuous"/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>23</x>
  <y>45</y>
  <width>135</width>
  <height>23</height>
  <uuid>{6fda8591-4b9d-4494-8336-304c3e3f492b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Input Pitch Detection in Hz</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>24</x>
  <y>257</y>
  <width>100</width>
  <height>30</height>
  <uuid>{4d130bbd-90c2-4a9c-9c3c-038cbfd4a569}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play Synth</text>
  <image>/</image>
  <eventLine>i2 0 20</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>amp</objectName>
  <x>190</x>
  <y>81</y>
  <width>80</width>
  <height>25</height>
  <uuid>{fbe6c4b8-1663-496e-bc07-a60795aa5223}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <value>0.00551000</value>
  <resolution>0.00001000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act="continuous"/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>188</x>
  <y>45</y>
  <width>135</width>
  <height>23</height>
  <uuid>{f49d0afd-2282-4d02-aff1-fbc7140454f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Amplitude Detection (0-1)</label>
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
  <x>23</x>
  <y>162</y>
  <width>151</width>
  <height>31</height>
  <uuid>{db5447c5-b354-4549-962f-ce336996a6a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Instrument 2</label>
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
  <x>23</x>
  <y>7</y>
  <width>151</width>
  <height>31</height>
  <uuid>{86023008-0f06-43e0-b9e9-54af7eb61e2c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Instrument 1</label>
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
  <x>21</x>
  <y>196</y>
  <width>156</width>
  <height>61</height>
  <uuid>{8fc51e65-a83f-47b5-9b87-02f6a84812b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This button plays a synth for 20 seconds, which gets the frequency, from the input-analysis.</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="513" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

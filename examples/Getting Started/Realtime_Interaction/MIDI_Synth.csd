/*Getting started.. Realtime Interaction: MIDI Notes / MIDI Synth

Generating the frequency for one voice, has to become computed individually for each midi note. So a new instance of instr 1 is started for every key pressed on the keyboard.  

Instruments 101 (Feedback Delay) and 102 (Reverb) are global effects, which are not necessary to compute for each individual voice independently. So started once from the score, one instance each runs constantly whether a note is played or not. The Widget Panel, gives access to some of their parameters. You can add more..
*/

<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 --midi-velocity=5
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

gaOut init 0.0						; a global audio variable is initialised, this can be seen as an "global audio Bus" (g.a.Bus), where audiodata can be send and read from, but first it is NULL

instr 1 						; Sawthooth Oscillator triggered with notes on MIDI CH: 1
icps = p4
iamp = p5/127						; MIDI received velocity (from 0-127), becomes devided by 127 -> amplitude-range is now 0-1 
kFfreq invalue "filter_freq"
kFfreq port kFfreq, 0.05

aSrc oscili iamp, icps, 1				; reads form f-table 1, containing a sawthooth waveform
aFiltered moogvcf aSrc, kFfreq, 0.1			; the source signal becomes low pass filtered
aEnv madsr 0.01, 0.1, 0.9, 0.01			; defining the envelope
gaOut =  (aFiltered*aEnv) + gaOut 			; the signal becomes scaled by the envelope and is added to the "g.a.Bus" 
							; that no information (from other sources, or simultaneous voices) which already exists on the global variable will be lost, itself needs to become added as well
endin

instr 2 						; Sine Oscillator triggered with notes on MIDI CH: 2
icps = p4
iamp = p5/127
aSrc oscili iamp, icps, 2				; this instrument reads from f-table 2, containing a sinus waveform
aEnv madsr 0.01, 0.1, 0.9, 0.01			; defining the envelope
gaOut = (aSrc*aEnv) + gaOut
endin


instr 101					 ; Global Feedback Delay
kDryWet invalue "d_w_delay"			; receive values from the Widget Panel
kDelTime invalue "time_delay"
kFeedback invalue "feedb_delay"
aDelay delayr 1					;  a delayline, with 1 second maximum delay-time is initialised
aWet	deltapi kDelTime				; data at a flexible position is read from the delayline 
	delayw gaOut+(aWet*kFeedback)	; the "g.a.Bus" is written to the delayline, - to get a feedbackdelay, the delaysignal (aWet) is also added, but scaled by kFeedback 
gaOut	= (1-kDryWet) * gaOut + (kDryWet * aWet)	; the amount of pure-signal and delayed-signal is mixed, and written to the "g.a.Bus"
endin

instr 102					 			; Global Reverb
kroomsize init 0.4						; fixed values for reverb-roomsize and damp, but you can add knobs or faders on the Widget Panel and invalue the data here...
khfdamp init  0.8
kDryWet invalue "d_w_reverb"
aWetL, aWetR freeverb gaOut, gaOut, kroomsize, khfdamp		; the freeverb opcode works with stereo input, so we read twice the "g.a.Bus"
aOutL	 = (1-kDryWet) * gaOut + (kDryWet * aWetL)			; the amount of pure-signal (g.a.Bus) and reverbed-signal for the left side is mixed, and written to a local variable
aOutR	 = (1-kDryWet) * gaOut + (kDryWet * aWetR)
outs aOutL, aOutR								; main output of the final signal
gaOut = 0.0									; clear the global audio channel for the next k-loop
endin


</CsInstruments>
<CsScore>
f 1 0 1024 7 0 512 1 0 -1 512 0
f 2 0 1024 10 1
i 101 0 3600						; the delay runs for one hour
i 102 0 3600						; the reverb runs for one hour
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>700</x>
 <y>218</y>
 <width>389</width>
 <height>553</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>182</r>
  <g>109</g>
  <b>0</b>
 </bgcolor>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>d_w_reverb</objectName>
  <x>22</x>
  <y>458</y>
  <width>311</width>
  <height>38</height>
  <uuid>{965ddedd-20e0-4abd-859a-dfd4ff860060}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.18971100</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>421</y>
  <width>131</width>
  <height>35</height>
  <uuid>{26d8fbb2-0a09-4332-9b18-5cc0250b8cf2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Reverb Mix</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>d_w_delay</objectName>
  <x>22</x>
  <y>277</y>
  <width>311</width>
  <height>38</height>
  <uuid>{b8bc48f2-c2b1-4687-85e7-1066b06a33c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.07074000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>240</y>
  <width>131</width>
  <height>35</height>
  <uuid>{1c5ee867-4ad1-434f-a5e0-6ea3dafd89b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Delay Mix</label>
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
 <bsbObject version="2" type="BSBVSlider">
  <objectName>time_delay</objectName>
  <x>244</x>
  <y>147</y>
  <width>20</width>
  <height>100</height>
  <uuid>{8dbbbd5a-8e3f-48ad-9b17-4d4ec077d56f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.05000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.26850000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>feedb_delay</objectName>
  <x>313</x>
  <y>148</y>
  <width>20</width>
  <height>100</height>
  <uuid>{60c2bf77-6001-4508-98c7-9b589819aee1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.05000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.52500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>235</x>
  <y>121</y>
  <width>45</width>
  <height>23</height>
  <uuid>{db1823ae-b35e-452a-9d18-71821c7feb40}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Time</label>
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
  <x>294</x>
  <y>121</y>
  <width>57</width>
  <height>23</height>
  <uuid>{d7b1bce9-3493-4b44-81cb-6fe3917d3e79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Feedback</label>
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
  <x>22</x>
  <y>116</y>
  <width>184</width>
  <height>35</height>
  <uuid>{bff2f5ef-9393-4a63-be7d-f9ba7f9e6ed9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>DELAY SECTION</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>22</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>21</x>
  <y>313</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f1ea1508-3b35-40d8-8a18-b3866212a5cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Dry</label>
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
  <x>294</x>
  <y>315</y>
  <width>37</width>
  <height>27</height>
  <uuid>{8e7b41c0-8c87-4bea-ad04-4b8cf886cd69}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Wet</label>
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
  <x>22</x>
  <y>494</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0e2fb652-9ae9-43f4-b61e-b22ab50a5607}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Dry</label>
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
  <x>296</x>
  <y>494</y>
  <width>37</width>
  <height>25</height>
  <uuid>{6dbb3852-766d-478f-a270-db1249eca234}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Wet</label>
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
  <x>20</x>
  <y>381</y>
  <width>184</width>
  <height>35</height>
  <uuid>{2c94e6b7-a8b7-4a2c-a420-a95fc5a7fd7a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>REVERB SECTION</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>22</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>223</x>
  <y>250</y>
  <width>69</width>
  <height>24</height>
  <uuid>{71d02974-0a9e-46d9-9bf5-13f597e24907}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>50-1000 ms</label>
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
  <x>300</x>
  <y>251</y>
  <width>69</width>
  <height>24</height>
  <uuid>{9805b83f-cbfb-4f90-bc8a-4fb9d0cf4bc4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0-100 %</label>
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
  <x>19</x>
  <y>44</y>
  <width>273</width>
  <height>25</height>
  <uuid>{93d0d968-20d9-4e1a-b1c0-224bf6a4f360}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Filterfrequency Control for Instr 1</label>
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
  <x>19</x>
  <y>9</y>
  <width>184</width>
  <height>35</height>
  <uuid>{f8582472-2877-4113-8834-13da608069b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>SYNTH SECTION</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>22</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>filter_freq</objectName>
  <x>18</x>
  <y>68</y>
  <width>311</width>
  <height>38</height>
  <uuid>{b868baaf-46dd-40eb-8b7b-f7afa7925c6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>10.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>1919.35691300</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
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
WindowBounds: 700 218 389 553
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {46774, 28013, 0}
ioSlider {22, 458} {311, 38} 0.000000 1.000000 0.189711 d_w_reverb
ioText {22, 421} {131, 35} label 0.000000 0.00100 "" left "Lucida Grande" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Reverb Mix
ioSlider {22, 277} {311, 38} 0.000000 1.000000 0.070740 d_w_delay
ioText {22, 240} {131, 35} label 0.000000 0.00100 "" left "Lucida Grande" 18 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Delay Mix
ioSlider {244, 147} {20, 100} 0.050000 1.000000 0.268500 time_delay
ioSlider {313, 148} {20, 100} 0.050000 1.000000 0.525000 feedb_delay
ioText {235, 121} {45, 23} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Time
ioText {294, 121} {57, 23} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Feedback
ioText {22, 116} {184, 35} label 0.000000 0.00100 "" left "Lucida Grande" 22 {0, 0, 0} {65280, 65280, 65280} nobackground noborder DELAY SECTION
ioText {21, 313} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dry
ioText {294, 315} {37, 27} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet
ioText {22, 494} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dry
ioText {296, 494} {37, 25} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet
ioText {20, 381} {184, 35} label 0.000000 0.00100 "" left "Lucida Grande" 22 {0, 0, 0} {65280, 65280, 65280} nobackground noborder REVERB SECTION
ioText {223, 250} {69, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 50-1000 ms
ioText {300, 251} {69, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0-100 %
ioText {19, 44} {273, 25} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Filterfrequency Control for Instr 1
ioText {19, 9} {184, 35} label 0.000000 0.00100 "" left "Lucida Grande" 22 {0, 0, 0} {65280, 65280, 65280} nobackground noborder SYNTH SECTION
ioSlider {18, 68} {311, 38} 10.000000 5000.000000 1919.356913 filter_freq
</MacGUI>
<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" x="60" y="304" width="604" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

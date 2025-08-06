/*Getting started.. Realtime Interaction: MIDI Controller 01 (Modulation)

The quickest way to control instruments with MIDI control-data (Modulation, Aftertouch, etc.) can be set up, by using 'ctrl7' opcode. It can be used  directly in an instrument definition, and outputs the desired k-rate data. 
..
kMidiCC ctrl7 1, 1, 10, 5000   	; read 7-bit MIDI CC data from Ch.1, CC 01, and map to a range between 10-5000 
aSrc oscili 0.8, kMidiCC, 1	; now CC 01 controlls the frequency of this oscillator
..
The disadvantage of that method would be, that you have no communication with the Widget-GUI.

In the example below, a separate instrument (instr 100) is built to receive the MIDI CC 01 (Modulation) constantly and send its values on channel "filter_freq". 
In Instrument 101 the data from this channel is read and mapped to the filters frequency input. 

By sending MIDI-Control-Data 01 on Channel 1 (CC 01 - with your keyboards modualtion wheel, or any other MIDI faderbox) you see the Widget-fader moving and can hear the filter adjustments in realtime, when playing a note. Adjusting the fader with the mouse is also still possible.
*/

<CsoundSynthesizer>
<CsOptions>
--midi-key-cps=4 --midi-velocity=5
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

massign 1, 101				; send notes on MIDI Ch.1 to instr 101
gaOut init 0.0

instr 100				; MIDI Controller Receive Instrument
kFilterCC1 ctrl7 1, 1, 10, 5000		; read 7-bit MIDI CC data from Ch.1, CC1, and map to a range between 10-5000 
printk2 kFilterCC1				; print the value to the console
kChanged changed kFilterCC1		; check if new values are incoming
if kChanged == 1 then			; so if, update the chanel..
	outvalue "filter_freq", kFilterCC1	; send the value to the widgetpanel
endif
endin


instr 101  				; Sawthooth Oscillator triggered by notes on MIDI CH: 1
icps = p4
iamp = p5/127
kFfreq invalue "filter_freq"
kFfreq port kFfreq, 0.05
aSrc oscili iamp, icps, 1
aFiltered moogvcf aSrc, kFfreq, 0.1
aEnv madsr 0.01, 0.1, 0.9, 0.01
gaOut = gaOut + aFiltered*aEnv
endin

instr 102 				; Global Feedback Delay
kDryWet invalue "d_w_delay"
kDelTime invalue "time_delay"
kFeedback invalue "feedb_delay"
kDelTime port kDelTime, 0.05
aDelTime = a(kDelTime)
aDelay delayr 1
aWet	deltapi aDelTime
	delayw gaOut+(aWet*kFeedback)
gaOut		=	(1-kDryWet) * gaOut + (kDryWet * aWet)
endin

instr 103 				; Global Reverb
kroomsize init 0.4
khfdamp init  0.8
kDryWet invalue "d_w_reverb"
aWetL, aWetR freeverb gaOut, gaOut, kroomsize, khfdamp
aOutL	= (1-kDryWet) * gaOut + (kDryWet * aWetL)
aOutR	= (1-kDryWet) * gaOut + (kDryWet * aWetR)
outs aOutL, aOutR
gaOut = 0.0
endin



</CsInstruments>
<CsScore>
f 1 0 256 7 0 128 1 0 -1 128 0
i 100 0 3600					; the MIDI CC 01will become received  for one hour
i 102 0 3600					; the delay runs for one hour
i 103 0 3600					; the reverb runs for one hour				
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>599</width>
 <height>453</height>
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
  <uuid>{a933ecca-4f6f-4c37-8612-e80ccaeab1ff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.24437300</value>
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
  <uuid>{8c2bf2d5-2f2a-4aa8-95f5-fd459644d3b3}</uuid>
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
  <uuid>{252c3435-b659-4c63-a7eb-6d8ba725081a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.25723500</value>
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
  <uuid>{b2a47e2f-a70f-4ac8-afd0-89ebec44cf27}</uuid>
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
  <uuid>{9eda359f-2e35-416a-9486-75e2b8609bac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.05000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.40150000</value>
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
  <uuid>{9b9faa01-b3b1-42b6-b3ea-942190c61015}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.05000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.31600000</value>
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
  <uuid>{a34714d9-8caa-4e71-993d-adc95b6d4ef6}</uuid>
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
  <uuid>{38d17cf1-8311-44a5-bbcd-e89f2a0a341e}</uuid>
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
  <uuid>{00c81148-ef01-44bb-af39-743e7597a9a3}</uuid>
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
  <uuid>{ff2f6506-d383-4b73-8cc8-325a13c76301}</uuid>
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
  <uuid>{deb507a6-bbc9-4875-ab32-b98d0fd9ca21}</uuid>
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
  <uuid>{1a2bb9cb-d541-4c5f-8c71-07b4c279ed43}</uuid>
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
  <uuid>{c0a097a0-f5e0-4041-a760-cb8edbe42625}</uuid>
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
  <uuid>{6a214d2b-c15f-4749-81a6-00a359668d41}</uuid>
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
  <uuid>{c6be046b-6565-487b-82aa-7153da5ce460}</uuid>
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
  <uuid>{9dcc5341-ac6e-4568-b661-9a08ffa7bafd}</uuid>
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
  <uuid>{5f7f6f96-32f1-47ba-a896-ca4f6e4eaf11}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Filterfrequency Control with CC 01 (Modulation)</label>
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
  <y>10</y>
  <width>184</width>
  <height>35</height>
  <uuid>{2f8d8395-c26a-4531-a1a5-d94df807fac9}</uuid>
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
  <uuid>{e0262b2c-5f78-4d11-9b16-1fd70b8bbefd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>10.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>2288.39228300</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" x="383" y="237" width="513" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

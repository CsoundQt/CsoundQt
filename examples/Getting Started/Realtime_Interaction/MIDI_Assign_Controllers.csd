/*Getting started.. Realtime Interaction: MIDI Assign Controllers

In the example below, instrument 100 (which is "always on") receives the MIDI control data and sends it as global k-variables (gk...). You can choose the MIDI channel number and the controller numbers via the spinboxes in the widget panel. You can even change these numbers during the performance. As they are i-values, the opcodes 'reinit' and 'rireturn' are used to put the changes into force (for another examples, see Examples->Reinit_Example).

In comparison to the example before, the sliders are not 'invalue'-ed to the instruments, so the only way to control the synth is via MIDI-CC's. The GUI is just for displaying, so 'outvalue' is used to send the CC-values to the Widget GUI. 

All the note-on-/note-off-messages must be sent on MIDI channel 1 (or you have to change the massign statement in the orchestra header). The statement massign 1, 101 sends all these messages to instrument 101. Each note here is added to the global audio variable -gaOut-.

Instrument 102 adds the global feedback delay and the reverb, and finally zeros the -gaOut- variable for the next k-cycle.
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

gaOut init 0.0
massign 1, 101		; assign all incoming midi from midi-chn 1 (= keyboard) to instr 101 (Sawthooth Oscillator)


instr 100; MIDI CONTROLLER RECEIVE INSTRUMENT
; Get information for MIDI Channel and Controller Numbers from the Widget Panel
	kMidiChn_slider invalue "#midichn_slider"							; receive midi channel for the sliders
	kCtrlNo_filt_freq invalue "ctrl#filt_freq"							; receive controller number for filter frequency
	kCtrlNo_DelTime invalue "ctrl#_time_delay"							; receive controller number for delay time
	kCtrlNo_Feedback invalue "ctrl#_feedb_delay"						; receive controller number for delay time
	kCtrlNo_d_w_delay invalue "ctrl#_d_w_delay"						; receive controller number for delay wet-dry-mix
	kCtrlNo_d_w_reverb invalue "ctrl#_d_w_reverb"						; receive controller number for reverb wet-dry-mix
; Receive Values from the MIDI Sliders as global k-Variables
midivalues: ;begin of a possible reinit section
	gkFilterCC1 ctrl7 i(kMidiChn_slider), i(kCtrlNo_filt_freq), 10, 5000				; read 7-bit MIDI CC data and map to a range between 10-5000 
	gkDelTime ctrl7 i(kMidiChn_slider), i(kCtrlNo_DelTime), 0.05, 1
	gkFeedback ctrl7 i(kMidiChn_slider), i(kCtrlNo_Feedback), 0.05, 1
	gkDryWetDelay ctrl7 i(kMidiChn_slider), i(kCtrlNo_d_w_delay), 0, 1
	gkDryWetReverb ctrl7 i(kMidiChn_slider), i(kCtrlNo_d_w_reverb), 0, 1
rireturn; end of a possible reinit section

; Reinit the label "midivalues" only, when a MIDI Channel or any of the CC Number assignments  have changed
kchanged changed kMidiChn_slider, kCtrlNo_filt_freq, kCtrlNo_DelTime, kCtrlNo_Feedback, kCtrlNo_d_w_delay, kCtrlNo_d_w_reverb
	if kchanged == 1 then
		reinit midivalues
	endif
; Send the MIDI-Values to the Widget Panel
outvalue "filter_freq", gkFilterCC1
outvalue "feedb_delay", gkFeedback
outvalue "d_w_delay", gkDryWetDelay
outvalue "time_delay", gkDelTime
outvalue "d_w_reverb", gkDryWetReverb
endin

instr 101	; Sawthooth Oscillator triggered with notes on MIDI CH: 1
icps = p4
iamp = p5/127
kFfreq port gkFilterCC1, 0.05
aSrc oscili iamp, icps, 1
aFiltered moogvcf aSrc, kFfreq, 0.1
aEnv madsr 0.01, 0.1, 0.9, 0.01
gaOut = gaOut + aFiltered*aEnv
endin

instr 102; Global Feedback Delay and Reverb
; DELAY Section
kDelTime port gkDelTime, 0.05
aDelTime = a(kDelTime)
aDelay delayr 1
aWet	deltapi aDelTime
	delayw gaOut+(aWet*gkFeedback)
gaOut		=	(1-gkDryWetDelay) * gaOut + (gkDryWetDelay * aWet)

; REVERB Section
kroomsize init 0.4
khfdamp init  0.8
aWetL, aWetR freeverb gaOut, gaOut, kroomsize, khfdamp
aOutL	= (1-gkDryWetReverb) * gaOut + (gkDryWetReverb * aWetL)
aOutR	= (1-gkDryWetReverb) * gaOut + (gkDryWetReverb * aWetR)
outs aOutL, aOutR
gaOut = 0.0
endin

</CsInstruments>
<CsScore>
f 1 0 256 7 0 128 1 0 -1 128 0
i 100 0 3600					; the MIDI CCs will be received  for one hour
i 102 0 3600					; feedback-delay and reverb run for one hour
e
</CsScore>
</CsoundSynthesizer>
; written by Joachim Heintz & Alex Hofmann (Dec. 2009) - Incontri HMT-Hannover 

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>612</width>
 <height>448</height>
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
  <y>555</y>
  <width>311</width>
  <height>38</height>
  <uuid>{c076d729-6955-41f6-ac73-629c2cab5f0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>518</y>
  <width>131</width>
  <height>35</height>
  <uuid>{0cea1de3-74da-4524-a540-23addd966011}</uuid>
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
  <y>374</y>
  <width>311</width>
  <height>38</height>
  <uuid>{922a0a2a-8eed-4e80-91e5-3aadcb71a060}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>337</y>
  <width>131</width>
  <height>35</height>
  <uuid>{3ff84f21-e00d-4675-ab60-662f75bd60c1}</uuid>
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
  <y>244</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3d18f824-aa11-4227-b986-1e2c8e12b0b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.05000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.60100000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>feedb_delay</objectName>
  <x>313</x>
  <y>245</y>
  <width>20</width>
  <height>100</height>
  <uuid>{392d91e1-4001-4d09-b521-3467c922dbe2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.05000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>235</x>
  <y>218</y>
  <width>45</width>
  <height>23</height>
  <uuid>{106d943f-998f-4d9e-a300-9f3c91b38e30}</uuid>
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
  <y>218</y>
  <width>57</width>
  <height>23</height>
  <uuid>{f871526f-50dd-46ec-852a-01f39b0692a9}</uuid>
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
  <y>213</y>
  <width>184</width>
  <height>35</height>
  <uuid>{d56458a9-29ed-45b4-816f-2db8b87ffdf7}</uuid>
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
  <y>410</y>
  <width>80</width>
  <height>25</height>
  <uuid>{0fd32071-b415-4c8d-a9b7-455744370f58}</uuid>
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
  <y>412</y>
  <width>37</width>
  <height>27</height>
  <uuid>{257153de-9a52-48ae-8aab-4f0fb204a66b}</uuid>
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
  <y>591</y>
  <width>80</width>
  <height>25</height>
  <uuid>{d5652849-5d18-495b-bc7a-a81d2f15316d}</uuid>
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
  <y>591</y>
  <width>37</width>
  <height>25</height>
  <uuid>{120e4e24-568b-4bbe-a3a7-43ed34089d17}</uuid>
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
  <y>478</y>
  <width>184</width>
  <height>35</height>
  <uuid>{f566b738-ccc0-4283-8287-be91e3b9a351}</uuid>
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
  <y>347</y>
  <width>69</width>
  <height>24</height>
  <uuid>{9d25d798-954f-4549-9d48-e10369807683}</uuid>
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
  <y>348</y>
  <width>69</width>
  <height>24</height>
  <uuid>{3ee1d5a4-b581-4319-a8de-26fabbe95d40}</uuid>
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
  <y>141</y>
  <width>273</width>
  <height>25</height>
  <uuid>{b2f8fd33-54ec-4ff9-8803-dcb89ec05e3c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>LP-Filter Cutoff-frequency</label>
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
  <y>107</y>
  <width>184</width>
  <height>35</height>
  <uuid>{172b8328-7006-487e-87da-27b3695a1a45}</uuid>
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
  <y>165</y>
  <width>311</width>
  <height>38</height>
  <uuid>{574b3b76-4995-4fb1-b9e1-31ad77c029d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>10.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>1454.05144700</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>382</x>
  <y>107</y>
  <width>319</width>
  <height>64</height>
  <uuid>{d18ce470-11ed-434a-bbd8-98477e376bd9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>CONTROLLER NUMBERS FOR THE DIFFERENT SLIDERS</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>ctrl#filt_freq</objectName>
  <x>513</x>
  <y>178</y>
  <width>54</width>
  <height>27</height>
  <uuid>{8d5f2d0a-0776-4d15-9eea-69841987be31}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>333</x>
  <y>169</y>
  <width>169</width>
  <height>35</height>
  <uuid>{4c09e980-3cfb-47df-a7e5-ed4952f1eb6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>----------></label>
  <alignment>center</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>ctrl#_time_delay</objectName>
  <x>513</x>
  <y>257</y>
  <width>54</width>
  <height>27</height>
  <uuid>{de29e58d-a982-423b-8c5a-f2aa46523c0f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>21</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>278</x>
  <y>252</y>
  <width>221</width>
  <height>36</height>
  <uuid>{5bb15b6f-9d48-4021-9771-8353d6e1b3e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>----------------></label>
  <alignment>center</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>ctrl#_feedb_delay</objectName>
  <x>513</x>
  <y>312</y>
  <width>54</width>
  <height>27</height>
  <uuid>{08b9db07-a9c2-4719-a643-ebd0aadb87eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>342</x>
  <y>304</y>
  <width>162</width>
  <height>39</height>
  <uuid>{7e4a0c4a-3301-4dca-89d2-b51ab69d96db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>----------></label>
  <alignment>center</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>ctrl#_d_w_delay</objectName>
  <x>513</x>
  <y>385</y>
  <width>54</width>
  <height>27</height>
  <uuid>{97d48604-93d4-45b3-abaa-f75e27f5f6a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>4</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>338</x>
  <y>376</y>
  <width>169</width>
  <height>35</height>
  <uuid>{e7548a16-df22-4177-ab2e-e892cd84e95f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>----------></label>
  <alignment>center</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>ctrl#_d_w_reverb</objectName>
  <x>513</x>
  <y>565</y>
  <width>54</width>
  <height>27</height>
  <uuid>{2e8f79eb-a3f8-42c6-8b25-4a37e47cdac9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>6</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>339</x>
  <y>556</y>
  <width>169</width>
  <height>35</height>
  <uuid>{de76f066-3e92-479d-9be3-c263c8e042f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>----------></label>
  <alignment>center</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>404</x>
  <y>6</y>
  <width>267</width>
  <height>64</height>
  <uuid>{77d50ce2-bf4f-44b5-94ba-39526c642042}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>CHANNEL NUMBER FOR ALL SLIDERS</label>
  <alignment>center</alignment>
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
  <x>17</x>
  <y>7</y>
  <width>304</width>
  <height>64</height>
  <uuid>{a65a4b68-8a30-4af3-92bd-4eacbe852b09}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>MIDI KEYBOARD MUST SEND ON MIDI CHANNEL 1!</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>#midichn_slider</objectName>
  <x>511</x>
  <y>76</y>
  <width>54</width>
  <height>27</height>
  <uuid>{384ec463-4788-4797-8e68-7878f406121e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>70</y>
  <width>410</width>
  <height>25</height>
  <uuid>{b7d7027d-fa3d-4b6b-b631-f3cf5d65cfbc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>(or you must change the massign statement in the orc header)</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" x="410" y="239" width="604" height="322" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

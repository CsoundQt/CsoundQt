/*Getting started.. Realtime Interaction: Open Sound Control

Open Sound Control (OSC) is a network protocol format for musical control data communication. A few of its advantages compared to MIDI are, that it's more accurate, quicker and much more flexible. With OSC you can easily send messages to other software like Max/Msp, Chuck or SuperCollider.

In this example, two instruments are built, which show OSC usage with CsoundQt. 

Instrument 1000 will send OSC messages to an IP-adress. You can generate values on two different channels, on the yellow side of the Widget-Panel.
Instrument 1001 will receive the OSC data from an this IP-adress. When Csound is running, you can see the reactions on the blue side of the Widget-Panel.

Macros are used, to define the send and receive ports, so you can change them at the top of the example-file.

1. open the widget panel
2. press run, to start csound and its OSC responders
3. change the left slider value 


*/
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

#define IPADDRESS	# "localhost" #
#define S_PORT 		# 47120 #
#define R_PORT 		# 47120 #

turnon 1000															; starts instrument 1000 immediately
turnon 1001															; starts instrument 1001 immediately
	

instr	1000
	kNumber 	invalue "sendNumber"										; receive data from the Widget
	kSlider		invalue "sendSlider"	
	Stext sprintf "%i", $S_PORT									
	outvalue "sndPortNum", Stext											; show the macro defined send-port-number on the Widget 
	OSCsend   kNumber+kSlider, $IPADDRESS, $S_PORT, "/CsoundQt", "ff", kNumber, kSlider			; send data to the IP-adress, and port, when slider or number change
endin


instr 1001	
	kNumRcv 	init 0
	kSldRcv	init 0
	Stext sprintf "%i", $R_PORT
	outvalue "rcvPortNum", Stext											; show the macro defined receive-port-number on the Widget 
	ihandle OSCinit $R_PORT ;												; start the listening process for OSC messages on the defined receive port
	kAction  OSClisten	ihandle, "/CsoundQt", "ff", kNumRcv, kSldRcv						; you must define the kind of data to receive, in this case (ff) both are floating point numbers
		if (kAction == 1) then												; if data is received, then...											
			outvalue "rcvNumber", kNumRcv									; send the value to the channel, to update the Widgets right side
			outvalue "rcvSlider", kSldRcv
		endif														; ends the "if" part
endin
	

</CsInstruments>
<CsScore>
e 3600
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
  <r>125</r>
  <g>162</g>
  <b>160</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>320</x>
  <y>9</y>
  <width>286</width>
  <height>407</height>
  <uuid>{954fadd5-cce1-413e-8112-89e726e598da}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Instr 1001 receives OSC messages from port:</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>96</r>
   <g>219</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>8</y>
  <width>286</width>
  <height>407</height>
  <uuid>{0e2ba158-c297-43ef-a8c0-97ee46884040}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Instr 1000 send values via OSC to port:</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>246</r>
   <g>255</g>
   <b>17</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>sendNumber</objectName>
  <x>16</x>
  <y>154</y>
  <width>80</width>
  <height>25</height>
  <uuid>{054cd8e1-4a4f-44a5-9668-70e87bff0d9b}</uuid>
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
  <value>7.80000000</value>
  <resolution>0.10000000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>sendSlider</objectName>
  <x>22</x>
  <y>245</y>
  <width>20</width>
  <height>100</height>
  <uuid>{10bd35db-21e2-4728-9b72-49ccd89f4343}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.48000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>16</x>
  <y>128</y>
  <width>104</width>
  <height>25</height>
  <uuid>{0ce4364a-da5a-4e7a-ba83-1557f1fb9857}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Send this value</label>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>rcvNumber</objectName>
  <x>329</x>
  <y>143</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c548dd30-0a6b-4914-ab04-38fcedf9b1da}</uuid>
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
  <value>7.80000019</value>
  <resolution>0.00100000</resolution>
  <minimum>-999999999999.00000000</minimum>
  <maximum>99999999999999.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>325</x>
  <y>113</y>
  <width>108</width>
  <height>24</height>
  <uuid>{f90b1400-53b9-4b93-b88d-09ab8f2bf22a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Receive the value</label>
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
  <x>17</x>
  <y>217</y>
  <width>80</width>
  <height>25</height>
  <uuid>{32dde0b5-87c9-4230-bb82-453cc2cce1bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Send this value</label>
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
  <x>329</x>
  <y>225</y>
  <width>109</width>
  <height>25</height>
  <uuid>{b77c687c-f1e7-4a12-99d6-3cb8db6ac855}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Receive the value</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>sndPortNum</objectName>
  <x>219</x>
  <y>10</y>
  <width>58</width>
  <height>24</height>
  <uuid>{31b2e623-6866-4939-a2ce-6d0057dfbe8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>47120</label>
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
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>rcvPortNum</objectName>
  <x>548</x>
  <y>11</y>
  <width>51</width>
  <height>24</height>
  <uuid>{daa3b24a-6504-4f71-b8c1-adc5b21f5ae9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>47120</label>
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
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>16</x>
  <y>32</y>
  <width>281</width>
  <height>70</height>
  <uuid>{4569ab26-f769-4f4a-8519-1b075ec54720}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>You can set the send port in the orc, by changing the macro S_PORT. The messages can be received by other OSC software like Pd, Max/Msp or SuperCollider, if Csound is not receiving the same port.</label>
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
  <x>321</x>
  <y>33</y>
  <width>281</width>
  <height>70</height>
  <uuid>{a1f95929-e6b8-4062-8eeb-0f95cb1c26c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>You can set the receive port in the orc by the macro R_PORT. Pay attention that no other software (like Pd or SuperCollider) is already bound to the same Port, otherwhise Csound will crash.</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>sendSlider</objectName>
  <x>17</x>
  <y>350</y>
  <width>80</width>
  <height>25</height>
  <uuid>{98463a56-ef4a-4b20-b396-a8a64441ae16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.480</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>rcvSlider</objectName>
  <x>325</x>
  <y>359</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b123860f-78bb-4fdf-a8c2-318cd7ce69ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.480</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>rcvSlider</objectName>
  <x>332</x>
  <y>253</y>
  <width>22</width>
  <height>99</height>
  <uuid>{17bc5558-e8b2-4705-9b4c-417fe548d1d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.47999999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>95</x>
  <y>155</y>
  <width>151</width>
  <height>24</height>
  <uuid>{23b1c772-14d1-4112-ae09-010b4f8c51de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-> Channel "sendNumber"</label>
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
  <x>92</x>
  <y>278</y>
  <width>151</width>
  <height>24</height>
  <uuid>{f79c35f4-b208-4337-9c1b-7d98e98c8a3f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-> Channel "sendSlider"</label>
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
  <x>413</x>
  <y>296</y>
  <width>151</width>
  <height>24</height>
  <uuid>{375a1727-8231-45e4-bd40-8896b0c9fbe7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Channel "rcvSlider"</label>
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
  <x>415</x>
  <y>144</y>
  <width>151</width>
  <height>24</height>
  <uuid>{8ba9eac0-f85d-4121-8bbd-d31bb788f056}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Channel "rcvNumber"</label>
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
<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="604" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

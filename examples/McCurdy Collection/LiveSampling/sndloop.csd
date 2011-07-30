;Written by Iain McCurdy, 2009

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817


;Notes on modifications from original csd:


;my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 --expression-opt -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)then
		gktrig		invalue		"Play_Stop"
		ktrigOn		trigger		gktrig, 0.5, 0
					schedkwhen	ktrigOn, 0, 0, 2, 0, 0.01
		gkmute		invalue		"Mute_Live"
		gkdur		invalue 		"Duration"
		gkpitch		invalue 		"Pitch"
		gkfad		invalue 		"Crossfade"
		gkInGain		invalue 		"Input_Gain"
	endif
endin

instr	1	;MIDI ACTIVATED INSTRUMENT - READS MIDI NOTE VALUES
	icps			cpsmidi									;READ PITCH VALUES (IN HERTZ) FROM A CONNECTED MIDI KEYBOARD
	ifreqratio	=			icps/261.626					;DERIVE A FREQUENCY RATI0 (BASE FREQUENCY IS MIDDLE C)
				outvalue		"Pitch", ifreqratio				;SEND FREQUENCY RATIO VALUE TO 'Pitch' FADER.
	gkpitch		init			ifreqratio					;SET gkpitch TO ifreqratio.
endin

instr	2	;RESTARTS INSTR 3 WHEN RECORD-PLAY/STOP IS PRESSED
	turnon	3
endin

instr	3	;SOUND PRODUCING INSTRUMENT
	krecflag		init			0

	ain			inch			1							;READ AUDIO FROM LIVE INPUT CHANNEL 1
	asig, krec	sndloop		ain*gkInGain, gkpitch, gktrig, i(gkdur), i(gkfad)

	kupdate		changed		krec							;IF krec CHANGES, (I.E. STATE CHANGES FROM RECORDING TO PLAYBACK), kupdate WILL BE MOMENTARILY 1 

	if kupdate = 1 then
				outvalue		"Recording", krec				;UPDATE 'RECORDING' INDICATOR
	endif

	krecflag		max			krec, krecflag

	if	gkmute = 1 then
		if	(krecflag == 1 && krec == 0)	then
			outs	asig, asig								;SEND AUDIO TO OUTPUT
		endif
	else
		outs	asig, asig									;SEND AUDIO TO OUTPUT
	endif
endin
</CsInstruments>
<CsScore>
i 10 0 3600	;GUI

i  2 0 3600	;INSTRUMENT PLAYS FOR 1 HOUR (AND SUSTAINS REALTIME PERFORMANCE)      
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>657</x>
 <y>667</y>
 <width>1000</width>
 <height>327</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>202</r>
  <g>202</g>
  <b>202</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>512</width>
  <height>320</height>
  <uuid>{395a9956-93f5-441f-b0ef-3828f1b2da1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>sndloop</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Play_Stop</objectName>
  <x>8</x>
  <y>42</y>
  <width>130</width>
  <height>30</height>
  <uuid>{c54faf18-3b5b-4a78-b803-69b1c339890e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  Rec-Play / Stop</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>Mute_Live</objectName>
  <x>152</x>
  <y>42</y>
  <width>130</width>
  <height>30</height>
  <uuid>{63b09b32-866d-4b31-ba3c-fb6f456359dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text> Mute Live Input</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>516</x>
  <y>2</y>
  <width>480</width>
  <height>320</height>
  <uuid>{10e7ae72-c151-4c9d-9f49-e6b1585d8386}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>sndloop</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>517</x>
  <y>17</y>
  <width>477</width>
  <height>302</height>
  <uuid>{97dfe67c-26c1-4af5-b858-e301d6886c2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>---------------------------------------------------------------------------------------------------------------------
'sndloop' is an opcode that offers a straightforward method of sampling some live audio and immediately playing it back in a loop with pitch control. The duration of the recording to be undertaken must be defined before recording is activated. A crossfade time can be defined which will create a crossfade between the end and the beginning of the loop which may smooth the transition between the end and the beginning of the loop and therefore prevent clicks. In addition to the audio output from the opcode there is a k-rate switch which indicates when recording has begun and then when playback begins. In this example, this variable is used to activate the red 'RECORDING' indicator.
Negative values for 'Pitch' result in reverse playback. This instrument also allows the user to shift the pitch of the loop by playing keys on a connected MIDI keyboard. The 'Input Gain' control controls the level of audio reaching the sndloop opcode therefore must be greater than zero. When not in playback mode after recording the sndloop opcode normally outputs the audio reaching its input, if you wish to mute live audio while recording (and also before recording has first taken place) activate the 'Mute Live Input' button.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <x>8</x>
  <y>106</y>
  <width>210</width>
  <height>30</height>
  <uuid>{2c897206-0dbc-47b5-ba68-915d83839ab6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Duration of Recording (seconds)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Duration</objectName>
  <x>8</x>
  <y>87</y>
  <width>500</width>
  <height>27</height>
  <uuid>{304e78d8-b320-453a-b28f-86b0ca872b86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>4.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Duration</objectName>
  <x>448</x>
  <y>106</y>
  <width>60</width>
  <height>30</height>
  <uuid>{94c7e961-7981-4d21-942f-80bcc647daf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>8</x>
  <y>154</y>
  <width>120</width>
  <height>30</height>
  <uuid>{7186de75-bab8-4534-b81d-333dea34bde8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch (ratio)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Pitch</objectName>
  <x>8</x>
  <y>135</y>
  <width>500</width>
  <height>27</height>
  <uuid>{21c23ac4-26ce-4b74-88d5-8c36439204d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-4.00000000</minimum>
  <maximum>4.00000000</maximum>
  <value>1.00800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pitch</objectName>
  <x>448</x>
  <y>154</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0b0ea6ec-a2b7-48a8-beeb-ddc4a43ab18b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.008</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>8</x>
  <y>203</y>
  <width>310</width>
  <height>30</height>
  <uuid>{2e87e987-1738-4cb5-8758-71fae356afeb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Crossfade (seconds)            (cannot be longer than Duration)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Crossfade</objectName>
  <x>8</x>
  <y>184</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e984c4f5-5ed8-435f-912c-bd859309ae47}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <value>1.38000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Crossfade</objectName>
  <x>448</x>
  <y>203</y>
  <width>60</width>
  <height>30</height>
  <uuid>{75870351-61d9-4470-8865-f2b00c777ff0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.380</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
  <x>8</x>
  <y>252</y>
  <width>100</width>
  <height>30</height>
  <uuid>{e7ab5e78-0242-43d4-9a05-6d6260c10833}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input Gain</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Input_Gain</objectName>
  <x>8</x>
  <y>233</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3159a008-2bd8-4149-b211-649c65101258}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.80000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Input_Gain</objectName>
  <x>448</x>
  <y>252</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9fc48d5e-b81f-4891-8091-49fdb18566a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.800</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBController">
  <objectName>Recording</objectName>
  <x>408</x>
  <y>44</y>
  <width>100</width>
  <height>26</height>
  <uuid>{6418d1d7-3588-4191-bfff-af56034342ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>408</x>
  <y>46</y>
  <width>100</width>
  <height>30</height>
  <uuid>{56201220-76ed-4652-a7e7-e674208835a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>RECORDING</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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

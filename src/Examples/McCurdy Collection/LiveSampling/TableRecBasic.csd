; Written by Iain McCurdy, 2009

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Macro SWITCH and modifications in instruments to get the same behaviour as FLTK button
; Pause change to avoid high cpu load


; my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 --expression-opt
; -+rtmidi=null
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 16     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)


giaudio ftgen 0, 0, 1048576, -7, 0, 1048576, 0  ; Audio data storage

gkrecdur init 0


#define SWITCH(Name'Value'Instr_Led'Instr_Event)
#
; To have a latched+event+value button *****************************************
strset $Value, "$Name_L"
k$Name init 0

kButton invalue "$Name_B"
kB_ON trigger kButton, 0.5, 0

if (k$Name == 0) then
  schedkwhen kB_ON, 0, 0, $Instr_Led, 0, 0, $Value, 1  ; Led ON
  schedkwhen kB_ON, 0, 0, $Instr_Event, 0, -1          ; Start instr
else
  schedkwhen kB_ON, 0, 0, $Instr_Led, 0, 0, $Value, 0  ; Led off
  schedkwhen kB_ON, 0, 0, -$Instr_Event, 0, 1          ; Stop instr
endif
k$Name invalue "$Name_L"
; ******************************************************************************
#


instr 1  ; GUI
  $SWITCH(Record'100'2'11)
  $SWITCH(PlayStop'200'2'13)

  gkPause   invalue "Pause"
  gkSpeed   invalue "Speed"
  gkLoopBeg invalue "LoopBeg"
  gkLoopEnd invalue "LoopEnd"
endin

instr 2  ; Led on/off
  Sp4 strget p4
  outvalue Sp4, p5
endin

instr 11               ; Record
  if gkPause = 1 then  ; If pause button is activated...
    kgoto END          ; Goto 'end' label
  endif                ; End of conditional branching

  itablelen tableng giaudio

  ain inch 1  ; Read audio from live input channel 1
  ; Create a pointer for writing to table - frequency of pointer is dependent upon table
  ; length and sample rate
  andx line 0, itablelen/sr, 1
  andx = andx * itablelen  ; Rescale pointer according to length of function table
  ; Create a k-rate global variable that will be used by the 'playback' instrument to
  ; determine the length of recorded data
  gkrecdur downsamp andx

  ; Opcode  input | index | table
  tablew ain, andx, giaudio  ; Write audio to audio storage table

  if gkrecdur >= itablelen then          ; If maximum record time is reached...
    schedkwhen 1, 0, 0, 2, 0, 0, 100, 0  ; Record Led OFF
    turnoff                              ; Turn off this instrument immediately.
  endif                                  ; End of conditional branching
END:
endin

instr 12               ; Playback looped instrument
  if gkPause = 1 then  ; If pause button is activated...
    kgoto END          ; Goto 'end' label
  endif                ; End of conditional branching

  iporttime = 0.02
  kporttime linseg 0, 0.001, iporttime, 1, iporttime
  kLoopBeg portk gkLoopBeg, kporttime
  kLoopEnd portk gkLoopEnd, kporttime

  ; Rescale gkloopbeg (range 0-1) to be within the range 0-file_length. New output
  ; variable kloopbeg.
  kLoopBeg = kLoopBeg * gkrecdur
  ; Rescale gkloopend (range 0-1) to be within the range 0-file_length. New output
  ; variable kloopend.
  kLoopEnd = kLoopEnd * gkrecdur
  kLoopLen = kLoopEnd - kLoopBeg  ; Derive loop length from loop start and end points

  ; Opcode  numerator | denominator | substution_value_(if_denominator=0)
  ; Safely divide, providing alternative value incase denominator is zero
  kPhasFrq divz gkSpeed, (kLoopLen/sr), .00001
  andx phasor kPhasFrq  ; Define phasor pointer for table index
  ; Check if loop-beginning and loop-end sliders have been reversed
  kLoopBeg = (kLoopBeg < kLoopEnd ? kLoopBeg : kLoopEnd)
  ; Rescale index pointer according to loop length and loop begining
  andx = (andx*abs(kLoopLen)) + kLoopBeg

  ; Out  opcode  index | function_table
  asig tablei andx, giaudio  ; Read audio from audio storage function table
  outs asig, asig            ; Send audio to outputs
END:
endin

instr 13               ; Play then stop
  if gkPause = 1 then  ; If pause button is activated...
    kgoto END          ; Goto 'end' label
  endif                ; End of conditional branching

  ; Rescale gkloopbeg (range 0-1) to be within the range 0-file_length. New output
  ; variable kloopbeg.
  kLoopBeg = gkLoopBeg * gkrecdur
  ; Rescale gkloopend (range 0-1) to be within the range 0-file_length. New output
  ; variable kloopend.
  kLoopEnd = gkLoopEnd * gkrecdur

  if kLoopEnd > kLoopBeg then
    andx line 0, 1, 1
    andx = (andx*gkSpeed*sr)+kLoopBeg
    kndx downsamp andx                     ; Create kndx, a k-rate version of andx
    if kndx > kLoopEnd then                ; If end of recording is reached...
      schedkwhen 1, 0, 0, 2, 0, 0, 200, 0  ; PlayStop Led OFF
      turnoff                              ; Turn off this instrument immediately.
    endif
  else
    andx line 0, 1, -1
    andx = (andx*gkSpeed*sr)+kLoopBeg
    kndx downsamp andx                     ; Create kndx, a k-rate version of andx
    if kndx < kLoopEnd then                ; If end of recording is reached...
      schedkwhen 1, 0, 0, 2, 0, 0, 200, 0  ; PlayStop Led OFF
      turnoff                              ; Turn off this instrument immediately.
    endif
  endif  ; End of conditional branching

  ; Out  opcode index | function_table
  asig tablei andx, giaudio  ; Read audio from audio storage function table
  outs asig, asig            ; Send audio to outputs
END:
endin
</CsInstruments>
<CsScore>
i 1 0 3600  ; GUI
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>202</r>
  <g>202</g>
  <b>202</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>512</width>
  <height>260</height>
  <uuid>{395a9956-93f5-441f-b0ef-3828f1b2da1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Record Audio to Function Table With Playback</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>239</r>
   <g>239</g>
   <b>239</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>Record_B</objectName>
  <x>8</x>
  <y>42</y>
  <width>80</width>
  <height>30</height>
  <uuid>{c54faf18-3b5b-4a78-b803-69b1c339890e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Rec</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
  <flatStyle>true</flatStyle>
  <color>
   <r>203</r>
   <g>206</g>
   <b>255</b>
  </color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>Pause</objectName>
  <x>98</x>
  <y>42</y>
  <width>80</width>
  <height>30</height>
  <uuid>{63b09b32-866d-4b31-ba3c-fb6f456359dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Pause</text>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <latched>false</latched>
  <flatStyle>true</flatStyle>
  <color>
   <r>203</r>
   <g>206</g>
   <b>255</b>
  </color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>516</x>
  <y>2</y>
  <width>480</width>
  <height>260</height>
  <uuid>{10e7ae72-c151-4c9d-9f49-e6b1585d8386}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Record Audio to Function Table With Playback</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>181</r>
   <g>199</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>517</x>
  <y>17</y>
  <width>477</width>
  <height>244</height>
  <uuid>{97dfe67c-26c1-4af5-b858-e301d6886c2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>---------------------------------------------------------------------------------------------------------------------
This example records live audio to a function table which the user can then play back. A pause button pauses both record and playback.
If record is pressed for a second time the original recording is overwritten. Maximum record time is determined by function table size and sampling rate. In this example table size is 1048576 and sampling rate is 44100Hz therefore maximum record time is 1048576/44100 = 24 seconds (approx.) If maximum record time is reached, recording will cease and the record button is deactivated. Playback can be either 'one shot' (triangle + line button) or looped (triangle button). The recorded data is monophonic and live input is read from the first (left) input channel but this could easily be modified to record in stereo (or more). Included are controls for playback speed and for playback start and end points. If the start and end points are inverted playback will be reversed.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>65</r>
   <g>65</g>
   <b>65</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>112</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2c897206-0dbc-47b5-ba68-915d83839ab6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Speed</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Speed</objectName>
  <x>8</x>
  <y>93</y>
  <width>500</width>
  <height>27</height>
  <uuid>{304e78d8-b320-453a-b28f-86b0ca872b86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00060000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Speed</objectName>
  <x>448</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{94c7e961-7981-4d21-942f-80bcc647daf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.001</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b3960</objectName>
  <x>187</x>
  <y>42</y>
  <width>80</width>
  <height>30</height>
  <uuid>{6fe53ee7-bd5d-4064-80fb-2ea628a7c5ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine>i 12 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
  <flatStyle>true</flatStyle>
  <color>
   <r>203</r>
   <g>206</g>
   <b>255</b>
  </color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>PlayStop_B</objectName>
  <x>279</x>
  <y>42</y>
  <width>82</width>
  <height>30</height>
  <uuid>{f0ca6175-5df0-4532-a841-7dc3313ac41d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play Stop</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
  <flatStyle>true</flatStyle>
  <color>
   <r>203</r>
   <g>206</g>
   <b>255</b>
  </color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>LoopBeg</objectName>
  <x>8</x>
  <y>153</y>
  <width>500</width>
  <height>14</height>
  <uuid>{8ecd7788-78c9-479b-8364-3c4fc256ea10}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.20800000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>LoopEnd</objectName>
  <x>8</x>
  <y>176</y>
  <width>500</width>
  <height>14</height>
  <uuid>{5aab0f2a-2456-4053-a07d-5e70c1c3d0ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.87400000</xValue>
  <yValue>0.00000000</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>203</x>
  <y>189</y>
  <width>100</width>
  <height>30</height>
  <uuid>{995aad6e-4f08-434c-ab9b-1936b51e2b3a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Loop Points</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>15</x>
  <y>52</y>
  <width>10</width>
  <height>10</height>
  <uuid>{38085679-3d54-407a-ba33-8ccad19971ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Record_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.12389381</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>285</x>
  <y>52</y>
  <width>10</width>
  <height>10</height>
  <uuid>{5b3b05aa-35e7-4e25-ab6d-31fa61bf8b76}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PlayStop_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.12389381</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

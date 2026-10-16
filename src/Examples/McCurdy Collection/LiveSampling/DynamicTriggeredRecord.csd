; Written by Iain McCurdy, 2008

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 January 2011 and QuteCsound svn rev 805


; Notes on modifications from original csd:
; Macro SWITCH and modifications in instruments to get the same behaviour as FLTK button


; my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 --expression-opt
; -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 16     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)


giaudio ftgen 0, 0, 1048576, -7, 0, 1048576, 0  ; Audio data storage

gkrecdur init 0

strset 400, "Record_Led"


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


instr 10  ; GUI

  $SWITCH(RecReady'100'11'3)
  $SWITCH(PlayOnce'200'11'5)
  $SWITCH(LoopPlay'300'11'6)

  gkAutoPlayOnce  invalue "Auto_Play_Once"
  gkAutoLoopPlay  invalue "Auto_Play_Looped"
  gkResetRecReady invalue "Reset_Rec_Ready"

  gkOnThresh  invalue "On_Threshold"
  gkOffThresh invalue "Off_Threshold"
  gkSpeed     invalue "Speed"
  gkGain      invalue "Gain"
endin

instr 11  ; Led on/off
  Sp4 strget p4
  outvalue Sp4, p5
endin

instr 1                  ; MIDI playback
  icps cpsmidi           ; Read MIDI pitch data from MIDI input
  imlt = icps/cpsoct(8)  ; Middle c is base frequency
  iamp ampmidi 1
  ; Infinitely rising line used as starting point for file pointer
  andx line 0, 1, 1
  ; If gkspeed is positive (or zero), i.e. Forwards playback
  if gkSpeed >= 0 then
    andx = andx*sr*imlt                     ; Rescale pointer according to speed
    kndx downsamp andx                      ; Create kndx, a k-rate version of andx
    if kndx >= gkrecdur then                ; If end of recording is reached...
      schedkwhen 1, 0, 0, 11, 0, 0, 200, 0  ; TURN OFF PlayOnce Button Led &
      turnoff                               ; Turn off this instrument immediately.
    endif
  else
    andx = (andx*sr*imlt)+i(gkrecdur)       ; Rescale pointer according to speed
    kndx downsamp andx                      ; Create kndx, a k-rate version of andx
    if kndx < 0 then                        ; If end of recording is reached...
      schedkwhen 1, 0, 0, 11, 0, 0, 200, 0  ; TURN OFF PlayOnce Button Led &
      turnoff                               ; Turn off this instrument immediately.
    endif
  endif
  ; Out  opcode  index | function_table
  asig table3 andx, giaudio  ; Read audio from audio storage function table
  aenv linsegr 0, 0.001, 1, 0.01, 0
  asig = asig * gkGain * aenv * iamp
  outs asig, asig
endin

instr 2         ; Read rt audio in and create follow signal
  gasig inch 1  ; Read channel 1 (left channel if stereo)

  afollow follow2 gasig, .1, .1  ; Create a amplitude following unipolar signal
  ; Downsample to create a k-rate version of the amplitude following signal
  gkfollow downsamp afollow
  kmeter   downsamp afollow  ; Convert amplitude following signal to k-rate
  ; Smooth the movement of the amplitude following signal - this will make the meters
  ; easier to view
  kmeter portk kmeter, .1
  kmetertrig metro 30  ; Metronomic trigger
  if kmetertrig = 1 then
    outvalue "Meter", kmeter  ; Update meter
  endif
endin

instr 3  ; Record_ready
  ; If amplitude following signal is above 'on threshold'...
  if gkfollow > gkOnThresh then
    schedkwhen 1, 0, 0, 11, 0, 0, 400, 1  ; ...Turn on 'recording' red light...
    schedkwhen 1, 0, 0, 11, 0, 0, 100, 0  ; ...Turn off 'record ready' button light
    ; Schedkwhen  ktrigger, kmintim, kmaxnum, kinsnum, kwhen, kdur
    schedkwhen 1, 0, 1, 4, 0, -1  ; And trigger record
    ; And turn off this instrument immediately (we don't want to retrigger recording until
    ; the current one has completed)
    turnoff
  endif  ; End of conditional branching
endin

instr 4  ; Record
  ; Interrogate function table used for audio recording to determine its length - this
  ; will be used to control the movement of the write pointer
  itablen tableng giaudio
  ; Create a write pointer using phasor. Frequency will be dependent upon sampling rate
  ; (sr) and the length of the table used for storage
  andx phasor sr / itablen
  andx = andx * itablen   ; Rescale the scope of the pointer
  gkrecdur downsamp andx  ; Create a global k-rate version of the write pointer
  ; Create 'anti-click' amplitude envelope for audio that is written to the function table
  aenv linsegr 0, .005, 1, .005, 0
  ; 'Anti-click' amplitude envelope is applied to audio before it is written to the table
  asig = gasig * aenv
  tablew asig, andx, giaudio  ; Write audio to audio storage table

  ; If our amplitude following variable has dropped below the 'off threshold'...
  if gkfollow < gkOffThresh then
    schedkwhen 1, 0, 0, 11, 0, 0, 400, 0    ; ...Turn off 'recording' red light
    if gkAutoLoopPlay = 1 then              ; IF 'Auto Play Looped' IS ON...
      schedkwhen 1, 0, 0, 11, 0, 0, 300, 1  ; Turn on play looped button light
      schedkwhen 1, 0, 0, 6, 0, -1          ; Start play_looped
    elseif gkAutoPlayOnce = 1 then          ; IF 'Auto Play Once' IS ON...
      schedkwhen 1, 0, 0, 11, 0, 0, 200, 1  ; ...Turn on 'play once' button light
      schedkwhen 1, 0, 0, 5, 0, -1          ; Start play_once
    endif                                   ; End of current conditional branch
    if gkResetRecReady = 1 then             ; IF 'Reset Rec. Ready' IS ON...
      schedkwhen 1, 0, 0, 11, 0, 0, 100, 1  ; ...Turn on 'rec. Ready' button light
      schedkwhen 1, 0, 0, 3, 0, -1          ; Start record_ready
    endif                                   ; End of current conditional branch
    turnoff                                 ; Turnoff this instrument immediately
  endif                                     ; End of conditional branching
endin

instr 5  ; Play_once
  ; Infinitely rising line used as starting point for file pointer
  andx line 0, 1, 1
  ; If skspeed is positive (or zero), i.e. Forwards playback
  if gkSpeed >= 0 then
    andx = andx*sr*gkSpeed                  ; Rescale pointer according to speed
    kndx downsamp andx                      ; Create kndx, a k-rate version of andx
    if kndx >= gkrecdur then                ; If end of recording is reached...
      schedkwhen 1, 0, 0, 11, 0, 0, 200, 0  ; ...Deactivate "play once" button &
      turnoff                               ; Turn off this instrument immediately.
    endif
  else
    andx = (andx*sr*gkSpeed)+i(gkrecdur)    ; Rescale pointer according to speed
    kndx downsamp andx                      ; Create kndx, a k-rate version of andx
    if kndx < 0 then                        ; If end of recording is reached...
      schedkwhen 1, 0, 0, 11, 0, 0, 200, 0  ; ...Deactivate "play once" button &
      turnoff                               ; Turn off this instrument immediately.
    endif
  endif
  ; Out  opcode  index | function_table
  asig table3 andx, giaudio  ; Read audio from audio storage function table
  outs asig*gkGain, asig*gkGain
endin

instr 6  ; Play_looped
  ; Define irecdur, an i-rate version of the most recent value of gkrecdur (recording
  ; duration in sample frames / table point values)
  irecdur = i(gkrecdur)
  ; Create read pointer frequency dependent upon sampling rate, 'speed' slider, and
  ; irecdur
  aptr phasor (sr * gkSpeed) / irecdur
  ; Rescale read pointer acccording to irecdur value so that the entire duration of the
  ; last recording will be played
  aptr = aptr * irecdur
  asig table3 aptr, giaudio  ; Read audio from function table using table3 opcode
  ; Create an amplitude envelope release fade out to prevent clicks if playback is
  ; terminated
  aenv linsegr 1, 3600, 1, .01, 0
  outs asig*aenv*gkGain, asig*aenv*gkGain
endin
</CsInstruments>
<CsScore>
i 10 0 3600  ; GUI
i 2 0 3600   ; Read rt audio in and create follow signal
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>498</x>
 <y>607</y>
 <width>995</width>
 <height>342</height>
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
  <width>510</width>
  <height>335</height>
  <uuid>{395a9956-93f5-441f-b0ef-3828f1b2da1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dynamic Triggered Recording</label>
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
  <objectName>RecReady_B</objectName>
  <x>8</x>
  <y>33</y>
  <width>120</width>
  <height>26</height>
  <uuid>{0a44e1b8-fab4-40c8-8fa1-f1d1d743c45c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Record Ready</text>
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
  <objectName>PlayOnce_B</objectName>
  <x>194</x>
  <y>42</y>
  <width>120</width>
  <height>26</height>
  <uuid>{92fe2dde-2f95-4c3b-8088-27e8231c20f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play Once</text>
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
  <objectName>LoopPlay_B</objectName>
  <x>194</x>
  <y>80</y>
  <width>120</width>
  <height>26</height>
  <uuid>{5d0ee36e-ffdb-4662-8831-cab2fad8ffab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play Looped</text>
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
  <objectName>Reset_Rec_Ready</objectName>
  <x>9</x>
  <y>89</y>
  <width>120</width>
  <height>26</height>
  <uuid>{199ec560-95d2-407d-b90e-6dcbead11ec2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Reset Rec Ready</text>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>Auto_Play_Once</objectName>
  <x>320</x>
  <y>42</y>
  <width>140</width>
  <height>26</height>
  <uuid>{c54faf18-3b5b-4a78-b803-69b1c339890e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Auto Play Once</text>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>Auto_Play_Looped</objectName>
  <x>320</x>
  <y>80</y>
  <width>140</width>
  <height>26</height>
  <uuid>{63b09b32-866d-4b31-ba3c-fb6f456359dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Auto Play Loop</text>
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
  <x>515</x>
  <y>2</y>
  <width>480</width>
  <height>335</height>
  <uuid>{10e7ae72-c151-4c9d-9f49-e6b1585d8386}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dynamic Triggered Recording</label>
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
  <x>518</x>
  <y>26</y>
  <width>474</width>
  <height>308</height>
  <uuid>{97dfe67c-26c1-4af5-b858-e301d6886c2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------
This example tracks the dynamics of the live incoming audio and triggers a recording function (writing to a function table) when the signal rises above a user defined amplitude threshold. When the signal subsequently drops below another user defined threshold recording ceases. What is stored in he function table is a topped and tailed sound fragment without silence at the begging or end of the recording.
The 'Rec. Ready' button must be on to begin scanning the input signal amplitude for threshold crossing. The user then has the option of playing back the recording either once ('Play (Once)') or looped  ('Play (Looped)'). If 'Auto Play Once' is selected the recording begins playing immediately the recording process ceases. 'Auto Play Looped' acts in a similar fashion but on the 'Play (Looped)' function. If 'Reset Rec. Ready' is selected the 'Rec. Ready' button is automatically switched on again as soon as recording has completed. The user can also modulate the speed of playback. Negative values here result in reverse direction playback. Recorded material can also be played back via a MIDI keyboard. MIDI pitch and velocity are interpretted appropriately.</label>
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
  <y>266</y>
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
  <y>249</y>
  <width>500</width>
  <height>27</height>
  <uuid>{304e78d8-b320-453a-b28f-86b0ca872b86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Speed</objectName>
  <x>448</x>
  <y>266</y>
  <width>60</width>
  <height>30</height>
  <uuid>{94c7e961-7981-4d21-942f-80bcc647daf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>305</y>
  <width>100</width>
  <height>30</height>
  <uuid>{0609a258-bba4-43bb-849c-b8709a47f1ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Gain</label>
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
  <objectName>Gain</objectName>
  <x>8</x>
  <y>288</y>
  <width>500</width>
  <height>27</height>
  <uuid>{49415594-5e61-46ce-b9f8-3adcf2b957c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.70000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Gain</objectName>
  <x>448</x>
  <y>305</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6a4ff02e-3d5e-4143-855e-95b4c2614157}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.700</label>
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
 <bsbObject type="BSBController" version="2">
  <objectName>Meter</objectName>
  <x>8</x>
  <y>129</y>
  <width>500</width>
  <height>16</height>
  <uuid>{268666a1-c814-494e-af5c-fe2a391dee5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>5000.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>144</y>
  <width>80</width>
  <height>30</height>
  <uuid>{f04b1289-6b5e-4fe4-9d72-b77fcf39045b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Meter</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>177</y>
  <width>100</width>
  <height>30</height>
  <uuid>{feb05e56-b1b1-4494-8c71-ce9e40994fb9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On Threshold</label>
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
  <objectName>On_Threshold</objectName>
  <x>8</x>
  <y>160</y>
  <width>500</width>
  <height>27</height>
  <uuid>{88f53f0d-44d4-4847-8885-c15e934a8109}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>3910.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>On_Threshold</objectName>
  <x>448</x>
  <y>177</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dd0574f3-9876-4c0e-b747-f61dee837c94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3910.000</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>216</y>
  <width>100</width>
  <height>30</height>
  <uuid>{bf3e8a57-4a8a-4a9d-b67d-9521542ae93d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Off Threshold</label>
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
  <objectName>Off_Threshold</objectName>
  <x>8</x>
  <y>199</y>
  <width>500</width>
  <height>27</height>
  <uuid>{8ff8f945-02c5-4ac9-a2e7-f20a8a28a2a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>5000.00000000</maximum>
  <value>2410.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Off_Threshold</objectName>
  <x>448</x>
  <y>216</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4b684f89-629e-4f7a-974d-7dd7165f85a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2410.000</label>
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
 <bsbObject type="BSBController" version="2">
  <objectName>Record_Led</objectName>
  <x>9</x>
  <y>63</y>
  <width>120</width>
  <height>22</height>
  <uuid>{176ac5c2-764e-4f67-a38d-a62f6bf6007b}</uuid>
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
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName/>
  <x>202</x>
  <y>50</y>
  <width>10</width>
  <height>10</height>
  <uuid>{0a052ce7-7ffd-491c-8eef-a839264c578a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>PlayOnce_L</objectName2>
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
  <x>13</x>
  <y>41</y>
  <width>10</width>
  <height>10</height>
  <uuid>{7cb52cfd-3962-4238-906f-dcfd23cf02d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>RecReady_L</objectName2>
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
  <x>202</x>
  <y>87</y>
  <width>10</width>
  <height>10</height>
  <uuid>{7cc8023e-7a6a-4896-a4ef-f90c90ede07f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>LoopPlay_L</objectName2>
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
  <x>19</x>
  <y>64</y>
  <width>100</width>
  <height>22</height>
  <uuid>{2158640e-3fbe-4baa-89d4-444bcea8e421}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>RECORDING</label>
  <alignment>center</alignment>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

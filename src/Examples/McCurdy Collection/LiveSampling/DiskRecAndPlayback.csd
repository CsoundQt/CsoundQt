; Written by Iain McCurdy, 2008

; Modified for QuteCsound by René, January 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Use wav header
; Pause change to avoid high cpu load


; my flags on Ubuntu: -dm0 -iadc -odac -+rtaudio=jack -b16 -B4096 --expression-opt
; -+rtmidi=null
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 256    ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)


gkrecdur  init 0
gkplaydur init 0

instr 1  ; GUI
  gkPause invalue "Pause"
  kPlay   invalue "Play"
  kPlayOn trigger kPlay, 0.5, 0
  chnset kPlayOn, "PlayOn"
  kInstr2 active 2
  kInstr3 active 3

  if kPlayOn = 1 && kInstr2 = 0 && kInstr3 = 0 then
    event "i", 2, 0, 3600  ; start playback for one hour maximum
  endif

  outvalue "RecDur", gkrecdur
  outvalue "PlayDur", gkplaydur
endin

instr 2                ; Playback
  if gkPause = 1 then  ; If pause button is activated...
    kgoto END          ; Goto 'end' label
  endif                ; End of conditional branching

  asig diskin2 "32BitRecording.wav", 1
  outs asig, asig  ; Send audio to outputs

  kPlayOn chnget "PlayOn"
  kPlay_Led invalue "Play_Led"

  gkplaydur line 0, 1, 1


  ; If end of recording is reached...
  if (gkplaydur >= gkrecdur) || (kPlayOn == 1 && kPlay_Led == 1) then
    outvalue "Play_Led", 0  ; ...Deactivate play button led &
    turnoff                 ; Turn off this instrument immediately.
  else
    outvalue "Play_Led", 1  ; ...Activate play button led &
  endif                     ; End of conditional branching
END:
endin

instr 3                ; Record
  if gkPause = 1 then  ; If pause button is activated...
    kgoto END          ; Goto 'end' label
  endif                ; End of conditional branching

  ain inch 1  ; Read audio from live input channel 1
  fout "32BitRecording.wav", 16, ain
  gkrecdur line 0, 1, 1  ; record duration

END:
endin
</CsInstruments>
<CsScore>
i 1 0 3600
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>598</x>
 <y>247</y>
 <width>477</width>
 <height>379</height>
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
  <width>475</width>
  <height>370</height>
  <uuid>{395a9956-93f5-441f-b0ef-3828f1b2da1c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Record Audio to Disk With Playback (Once)</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>4</x>
  <y>140</y>
  <width>471</width>
  <height>239</height>
  <uuid>{63943056-81b7-4daa-acef-5ee3932bad61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------
When it is required to record long sections of audio for playback or for storage for later retrieval, then recording to function tables will not be sufficient.
In this situation it is necessary to record audio to the computers hard disk (function table are merely stored temporarily in RAM).
In this example recording audio to disk is implemented using the fout opcode. Playback is implemented using the diskin2 opcode.
Playback will play the entire recording back once (unless playback is deactivated).
The recording will be stored as '32BitRecording.wav' in the default location for file output storage.
In this example file format is 32 bit floats at 44100. Care always needs to be taken that file storage format and playback format correspond.</label>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>b6743</objectName>
  <x>62</x>
  <y>44</y>
  <width>100</width>
  <height>30</height>
  <uuid>{0a44e1b8-fab4-40c8-8fa1-f1d1d743c45c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Record</text>
  <image>/</image>
  <eventLine>i 3 0 -1</eventLine>
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
  <objectName>Pause</objectName>
  <x>182</x>
  <y>44</y>
  <width>100</width>
  <height>30</height>
  <uuid>{d25d9765-65f0-40fa-87b8-30ba88ad9bd2}</uuid>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>Play</objectName>
  <x>302</x>
  <y>44</y>
  <width>100</width>
  <height>30</height>
  <uuid>{7924627d-9546-4acd-91a0-41c8282cf300}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
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
  <objectName/>
  <x>312</x>
  <y>54</y>
  <width>10</width>
  <height>10</height>
  <uuid>{2c1634b2-9b4f-4c8e-a392-f4bcdc4aa4eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Play_Led</objectName2>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>RecDur</objectName>
  <x>221</x>
  <y>94</y>
  <width>60</width>
  <height>25</height>
  <uuid>{f4a5dac8-b31b-4480-bd5c-73d3e5228c38}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.516</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>86</x>
  <y>94</y>
  <width>135</width>
  <height>25</height>
  <uuid>{c3e4f957-74ef-427b-8d53-37abaf75a236}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Record Duration (sec)</label>
  <alignment>right</alignment>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>PlayDur</objectName>
  <x>221</x>
  <y>120</y>
  <width>60</width>
  <height>25</height>
  <uuid>{4cf51312-2ac5-4893-8f13-48eb831ca14f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.516</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>86</x>
  <y>120</y>
  <width>135</width>
  <height>25</height>
  <uuid>{99de1d28-1025-42ff-9d47-de31d15793ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Play Duration (sec)</label>
  <alignment>right</alignment>
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

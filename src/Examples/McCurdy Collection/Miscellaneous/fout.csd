; Written by Iain McCurdy, 2008

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add table for exp slider
; No Button Bank in QuteCsound, change i2 to i11, i12, i13 and i14


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 10     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


gasig init 0  ; Initialise global audio variable to silence

gisine ftgen 0, 0, 65536, 10, 1                     ; A sine wave function table
giExp1 ftgen 0, 0, 129, -25, 0, 20.0, 128, 20000.0  ; Table for exp slider


instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    kfreq invalue "Freq"
    gkfreq tablei kfreq, giExp1, 1
    outvalue "Freq_Value", gkfreq
    gkamp   invalue "OscAmp"
    gkPBamp invalue "PlayAmp"
  endif
endin

instr 11  ; Button Stop
  outvalue "Record_L", 0
  outvalue "Play_L", 0
  outvalue "Pause_L", 0
  outvalue "Stop_L", 1
  gkFunction init 0
endin

instr 12  ; Button Record
  outvalue "Stop_L", 0
  outvalue "Play_L", 0
  outvalue "Record_L", 1
  gkFunction init 1
  event_i "i", 3, 0, 3600  ; Trigger 'record'instrument

endin

instr 13  ; Button Playback
  outvalue "Stop_L", 0
  outvalue "Record_L", 0
  outvalue "Play_L", 1
  gkFunction init 2
  event_i "i", 4, 0, 0.01  ; Trigger 'playback' instrument

endin

instr 14  ; Button Pause
  kPause invalue "Pause_L"
  kPause = (kPause+1) % 2
  outvalue "Pause_L", kPause
  gkPause = kPause
  turnoff
endin

instr 1  ; Oscillator
  iporttime = 0.05
  kporttime linseg 0, 0.01, iporttime, 1, iporttime
  kfreq portk gkfreq, kporttime
  kamp  portk gkamp, kporttime

  ; Output  opcode amplitude | frequency | function_table
  ; Create an oscillator based on the sine wave created in function table gisine
  gasig oscil kamp, kfreq, gisine
  outs gasig, gasig  ; Output oscillator signal to the speakers
endin

instr 3  ; Record sound using fout
  ; Sense if 'record' switch is not off (in which case skip the next line)
  if gkFunction != 1 then
    turnoff  ; Turn this instrument off immediately
  endif

  if gkPause = 1 goto SKIP
  ; Opcode filename     | format | out1  | out2 etc...
  ; Format '4' creates a 16 bit wav file. See the csound manual for information regarding
  ; other formats available.
  fout "output.wav", 4, gasig
SKIP:
  ; Global audio variable is reset to zero (to prevent, frozen non-zero values when
  ; instrument 1 is switched off)
  gasig = 0
endin

instr 4  ; Playback
  ; Sense if 'function' switch is not off (in which case skip the next line)
  if gkFunction != 2 then
    turnoff  ; Turn this instrument off immediately
  endif
  ifilelen filelen "output.wav"  ; Derive ifilelen from recorded file
  ; P3 (note duration) will be equal to duration of recorded file
  p3 = ifilelen

  asig soundin "output.wav", 0         ; Read sound from stored file using soundin
  outs asig * gkPBamp, asig * gkPBamp  ; Send audio to outputs
  event_i "i", 5, p3, 0.001            ; Trigger instrument to deactivate play button
endin

instr 5                  ; Deactivate play button
  event_i "i", 11, 0, 0  ; Trigger instrument 11 to deactivate play button
endin
</CsInstruments>
<CsScore>
i 10 0 3600  ; GUI
i 11 0 0     ; init
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>656</x>
 <y>281</y>
 <width>1023</width>
 <height>333</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>518</x>
  <y>2</y>
  <width>500</width>
  <height>326</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>fout: rendering realtime output</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="background">
   <r>28</r>
   <g>33</g>
   <b>62</b>
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
  <x>523</x>
  <y>36</y>
  <width>490</width>
  <height>288</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------------------------------------
This example illustrates a method of rendering a realtime performance to the hard disc whilst simultaneously monitoring it in the computer's speakers. It uses the fout opcode. The source signal (a sine wave with frequency slider) is kept simple to clarify the demonstration. Soundfile recording is dealt with in a separate instrument (instr 3) which is activated using the on screen record button. An output file called 'output.wav' will be created. The output file can be played back using the on-screen 'play' button. If the user wants to record the output of any of the examples in this collection then this is the recommended method. It should not prove too difficult to copy and paste the required code from this example into any of the other examples. If an example involves multiple sound sources then these will need to be mixed together before being passed as a global audio variable to the fout opcode. An alternative method in this situation would involve Csound's zak patching system. fout permits recording in a variety of formats and bit depths and also permits rendering multi-channel sound files.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <x>2</x>
  <y>2</y>
  <width>514</width>
  <height>326</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>fout: rendering realtime output</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="background">
   <r>28</r>
   <g>33</g>
   <b>62</b>
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
  <objectName>b7585</objectName>
  <x>33</x>
  <y>78</y>
  <width>150</width>
  <height>30</height>
  <uuid>{9d29ab85-85e6-462e-8761-1ac91e1af325}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Oscillator ON / OFF</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
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
  <x>9</x>
  <y>231</y>
  <width>200</width>
  <height>30</height>
  <uuid>{1c02d7bd-4198-417f-a816-a560f4133e23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Oscillator Amplitude</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>OscAmp</objectName>
  <x>9</x>
  <y>208</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e5fa660d-82a5-412a-a76a-500a0632ee0c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.49000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>OscAmp</objectName>
  <x>449</x>
  <y>231</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8341c14a-4acb-4d3d-824f-675147975768}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.490</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <x>9</x>
  <y>178</y>
  <width>200</width>
  <height>30</height>
  <uuid>{fd3ea893-7f4f-4d74-a6c6-2ed00b696056}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Freq</objectName>
  <x>9</x>
  <y>155</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3911e6c3-0337-45b0-81d8-e63c67cae1f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.42400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Freq_Value</objectName>
  <x>449</x>
  <y>178</y>
  <width>60</width>
  <height>30</height>
  <uuid>{78473677-bb47-45c2-bf88-fa6930dca759}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>374.245</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <x>9</x>
  <y>283</y>
  <width>200</width>
  <height>30</height>
  <uuid>{971d5005-5825-4041-82b3-337e677b3f17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Playback Amplitude</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>PlayAmp</objectName>
  <x>9</x>
  <y>260</y>
  <width>500</width>
  <height>27</height>
  <uuid>{efb2995a-4ef2-403a-b994-9661bc9f673e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.79400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>PlayAmp</objectName>
  <x>449</x>
  <y>283</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bd5a62e2-69ce-4c42-84cc-52f949326806}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.794</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>b8477</objectName>
  <x>329</x>
  <y>64</y>
  <width>15</width>
  <height>15</height>
  <uuid>{d7b37038-0bab-44be-b031-39a2c1123681}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 11 0 0</eventLine>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>253</x>
  <y>58</y>
  <width>60</width>
  <height>24</height>
  <uuid>{6d8682ed-864d-4ba6-81ce-76f14d3ef4d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Stop</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <x>253</x>
  <y>82</y>
  <width>60</width>
  <height>24</height>
  <uuid>{d6828b91-b42a-499a-8c11-34d15fca2bf0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Record</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <x>253</x>
  <y>106</y>
  <width>60</width>
  <height>24</height>
  <uuid>{aad1fc89-095c-49ab-9a5d-41db48d4be48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Play</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <x>368</x>
  <y>82</y>
  <width>60</width>
  <height>24</height>
  <uuid>{3c5244bc-0b2e-4001-9e5f-6d5ae427f251}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pause</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <x>318</x>
  <y>66</y>
  <width>10</width>
  <height>10</height>
  <uuid>{9cf2b60d-050a-4ea5-b4e1-232961e4a622}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Stop_L</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>1.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>124</r>
   <g>56</g>
   <b>56</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b8645</objectName>
  <x>329</x>
  <y>87</y>
  <width>15</width>
  <height>15</height>
  <uuid>{f4db60b8-ec92-4401-896d-6c19de173980}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 12 0 0</eventLine>
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
  <x>318</x>
  <y>89</y>
  <width>10</width>
  <height>10</height>
  <uuid>{6ceb7981-68e4-4d1a-a267-47181e963f26}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Record_L</objectName2>
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
   <r>124</r>
   <g>56</g>
   <b>56</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b1513</objectName>
  <x>329</x>
  <y>110</y>
  <width>15</width>
  <height>15</height>
  <uuid>{88f2e36e-806c-402e-93eb-9d421fa20d6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 13 0 0</eventLine>
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
  <x>318</x>
  <y>112</y>
  <width>10</width>
  <height>10</height>
  <uuid>{88d47f44-3557-4f89-b21c-2cb19f86f184}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Play_L</objectName2>
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
   <r>124</r>
   <g>56</g>
   <b>56</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b8243</objectName>
  <x>444</x>
  <y>87</y>
  <width>15</width>
  <height>15</height>
  <uuid>{e8663387-8992-4980-922f-b1f81a7e4480}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 14 0 0.01</eventLine>
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
  <x>433</x>
  <y>89</y>
  <width>10</width>
  <height>10</height>
  <uuid>{5f50e07c-86cb-4875-8a36-3f2acdd65ac9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>Pause_L</objectName2>
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
   <r>124</r>
   <g>56</g>
   <b>56</b>
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
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

; Written by Iain McCurdy, 2010


; Modified for QuteCsound by René, April 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add table for exp slider
; Add INIT instrument
; Use of QuteCsound internal midi for Pulse Width widget control by CC#1
; Add vco2init for user defined waveform


; my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 64     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum sound intensity level regardless of bit depth


; Table that stores a single cycle of a sine wave
gisine ftgen 0, 0, 4096, 10, 1
giExp1 ftgen 0, 0, 129, -25, 0, 2.0, 128, 10000.0  ; Table for exp slider


; user defined waveform -1: trapezoid wave with default parameters
itmp ftgen 1, 0, 16384, 7, 0, 2048, 1, 4096, 1, 4096, -1, 4096, -1, 2048, 0
ift vco2init -1, 10000, 0, 0, 0, 1


instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    ; Switches
    gkKPhs invalue "Phase"
    kmode  invalue "Waveform"
    ; Sliders
    gkamp invalue "Amplitude"
    kcps  invalue "Frequency"
    gkcps tablei kcps, giExp1, 1
    outvalue "Frequency_Value", gkcps
    gknyx    invalue "Harmonics"
    gkpw     invalue "PW"
    gkphs    invalue "InitPhase"
    gkphsDep invalue "PhaseDepth"
    gkphsRte invalue "PhaseRate"

    gkmode = (kmode*2)+ gkKPhs
  endif
endin

instr 11  ; Init
  outvalue "Amplitude", 0.1
  outvalue "Frequency", 0.45927
  outvalue "Harmonics", 0.25
  outvalue "PW", 0.5
  outvalue "InitPhase", 0.0
  outvalue "PhaseDepth", 0.0
  outvalue "PhaseRate", 0.001
endin

instr 1           ; MIDI input instrument
  icps cpsmidi    ; Read cycles per second value from MIDI input
  iamp ampmidi 1  ; Read in a note velocity value from the MIDI input

  ; Pitch
  ; bend===========================================================================================================================================================
  iSemitoneBendRange = 2                        ; Pitch bend range in semitones
  imin               = 0                        ; Equilibrium position
  imax               = iSemitoneBendRange / 12  ; Max pitch displacement (in oct format)
  kbend pchbend imin, imax                      ; Pitch bend variable (in oct format)
  ioct = octcps(icps)
  kcps = cpsoct(ioct + kbend)
  ; =====================================================================================================================================================================

  iporttime = 0.05  ; Portamento time variable
  ; Create a ramping up function to represent portamento time
  kporttime linseg 0, 0.001, iporttime
  kpw portk gkpw, kporttime         ; Apply portamento smoothing
  kenv linsegr 0, 0.01, 1, 0.01, 0  ; Anti-click envelope
  if gkmode = 2 then                ; If 'sawtooth/triangle/ramp' has been selected...
    gkpw limit gkpw, 0.01, 0.99     ; Limit pulse width to be between 0.01 and 0.99
  endif                             ; End of conditional branch
  kSwitch changed gknyx, gkmode
  if kSwitch = 1 then  ; If i-rate variable change trigger is '1'...
    reinit UPDATE      ; Begin a reinitialisation pass from label 'update'
  endif
UPDATE:
  if i(gkKPhs) = 0 then
    kphs = gkphs  ; Initial phase slider used
  else
    kphs poscil gkphsDep*0.5, gkphsRte, gisine  ; Phase modulation
    kphs = kphs + 0.5                           ; Phase depth
  endif
  ; Create vco2 oscillator
  asig vco2 kenv*iamp*gkamp, kcps, i(gkmode), kpw, kphs, i(gknyx)
  rireturn         ; Return from reinitialisation pass to performance time passes
  outs asig, asig  ; Send audio to outputs
endin

instr 2             ; Vco2 instrument
  iporttime = 0.05  ; Portamento time variable
  ; Create a ramping up function to represent portamento time
  kporttime linseg 0, 0.001, iporttime

  ; Set fundemental to GUI slider gkcps and apply portamento smoothing
  kcps portk gkcps, kporttime
  kpw  portk gkpw, kporttime        ; Apply portamento smoothing
  kenv linsegr 0, 0.01, 1, 0.01, 0  ; Anti-click envelope
  if gkmode = 2 then                ; If 'sawtooth/triangle/ramp' has been selected...
    gkpw limit gkpw, 0.01, 0.99     ; Limit pulse width to be between 0.01 and 0.99
  endif                             ; End of conditional branch
  kSwitch changed gknyx, gkmode
  if kSwitch = 1 then  ; If i-rate variable change trigger is '1'...
    reinit UPDATE      ; Begin a reinitialisation pass from label 'update'
  endif
UPDATE:
  if i(gkKPhs) = 0 then
    kphs = gkphs  ; Initial phase slider used
  else
    kphs poscil gkphsDep*0.5, gkphsRte, gisine  ; Phase modulation
    kphs = kphs + 0.5                           ; Phase depth
  endif
  asig vco2 kenv*gkamp, kcps, i(gkmode), kpw, kphs, i(gknyx)  ; Create vco2 oscillator
  ; Return from reinitialisation pass to performance time passes
  rireturn
  outs asig, asig  ; Send audio to outputs
endin
</CsInstruments>
<CsScore>
; Instr | start | duration
i 10 0.0 3600  ; GUI
i 11 0.0 0.01  ; Init
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>275</x>
 <y>313</y>
 <width>400</width>
 <height>200</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>0</x>
  <y>2</y>
  <width>512</width>
  <height>450</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>vco2 </label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
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
  <x>8</x>
  <y>270</y>
  <width>160</width>
  <height>30</height>
  <uuid>{b066c36d-a132-4a1a-aee4-e421b02bca48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pulse Width (CC#1)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>PW</objectName>
  <x>448</x>
  <y>270</y>
  <width>60</width>
  <height>30</height>
  <uuid>{262729b5-3e13-43d4-af01-99d1e8aabf34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>PW</objectName>
  <x>8</x>
  <y>254</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f4910f7d-2341-46e1-aa20-a4d3db351c24}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>308</y>
  <width>160</width>
  <height>30</height>
  <uuid>{5a8c0afb-17da-4ca7-a331-f3ef38db1431}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Initial Phase</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>InitPhase</objectName>
  <x>448</x>
  <y>308</y>
  <width>60</width>
  <height>30</height>
  <uuid>{12d2c823-daba-4a56-9f0c-462a6c951992}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>InitPhase</objectName>
  <x>8</x>
  <y>292</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5442ecac-367f-413c-a49e-5f42a2727519}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>347</y>
  <width>220</width>
  <height>30</height>
  <uuid>{d1ad1809-ed86-4ecd-b6c9-15b4c9686e35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Phase Mod. Depth</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>PhaseDepth</objectName>
  <x>448</x>
  <y>347</y>
  <width>60</width>
  <height>30</height>
  <uuid>{39d4f770-c1eb-4c2d-9b6d-41b78e8955f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>PhaseDepth</objectName>
  <x>8</x>
  <y>331</y>
  <width>500</width>
  <height>27</height>
  <uuid>{37911dd5-758c-4ec8-9871-ce3f5cd67670}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Waveform</objectName>
  <x>226</x>
  <y>68</y>
  <width>280</width>
  <height>26</height>
  <uuid>{fd321c7c-a7e3-49dd-9c35-b4d1a0054c73}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Sawtooth</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Square / PWM</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Sawtooth / Triangle / Ramp</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Pulse</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4 * x * (1 - x) (i.e. integrated sawtooth)</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Square Wave (no PWM - faster)</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Triangle (no ramp - faster) </name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>User Defined Waveform</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b4902</objectName>
  <x>10</x>
  <y>16</y>
  <width>120</width>
  <height>26</height>
  <uuid>{c4c1aae5-edb9-47d9-94a7-8d15578e0bf2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On / Off - MIDI</text>
  <image>/</image>
  <eventLine>i 2 0 -1</eventLine>
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
  <x>146</x>
  <y>68</y>
  <width>80</width>
  <height>26</height>
  <uuid>{e192d1b0-4e18-4b7a-97cb-800767992d7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Waveform :</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <x>516</x>
  <y>2</y>
  <width>620</width>
  <height>450</height>
  <uuid>{9798823d-b60e-424f-a3c4-1a43d5e0312d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Miscellaneous Waveforms
vco2 </label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
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
  <x>520</x>
  <y>47</y>
  <width>613</width>
  <height>400</height>
  <uuid>{66493881-548a-48d2-bdb6-08aad6d0fe91}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------------------------------------------------------------------
vco2 is similar to vco in that it models a variety of waveforms based on the integration of band-limited impulses. A key difference with vco2 is that it precalculates the tables that it will use and therefore requires less realtime computation. It will however require additional RAM for the storage of these precalculated tables. Optional use of the vco2init will allow stored tables to be shared between instruments and voices therefore saving RAM and computation of the tables each time the opcode is initialized - this might prove useful where a high level of polyphony and instrument reiteraction is required. vco2 offers more waveforms than vco and higher quality waveforms. vco2 also allows k-rate modulation of phase which vco does not. This example can be manipulated entirely using the GUI widgets or it can be partially controlled using a MIDI keyboard in which case it will respond to MIDI note numbers, key velocity and pitch bend. Modulation wheel (controller 1) can be used to manipulate pulse width. Some of vco2's waveform options offer improved efficiency by removing options which might not be needed such as pulse width modulation. Waveform options that offer multiple types (such as options 2 and 3) can morph between the waveforms offered by modulating 'Pulse Width'. Choosing the 'User Defined Opcode' option requires the use of the 'vco2init' opcode.
There are additional advantages to using vco2init, even when using vco2's other waveforms:
* Waveforms are loaded at the beginning of the performance as opposed to when the opcode is initialized. This might offer realtime performance adavantages.
* Waveforms can be shared between instances of vco2. This will provide an efficiency advantage if multiple instances of vco2 are begin used.
* By using vco2init we can access vco2's internal waveforms from other opcodes.
The appropriate table numbers can be derived by using the vco2ft opcode. If 'k-rate phase' has been activated, phase is modulated by a sine wave LFO, the depth and rate of which can be changed by the user using the two short sliders at the bottom of the GUI. If 'k-rate phase' is not activated, initial phase is set using the 'Initial Phase' slider. It will be heard that phase modulation is heard as a modulation of pitch.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>2</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>Phase</objectName>
  <x>10</x>
  <y>68</y>
  <width>120</width>
  <height>26</height>
  <uuid>{d7e69bb1-02fe-42ed-a9db-a578ece9b691}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>16.00000000</pressedValue>
  <stringvalue/>
  <text>k-rate Phase</text>
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
  <x>8</x>
  <y>155</y>
  <width>160</width>
  <height>30</height>
  <uuid>{6089425b-bdef-4a75-9cf7-e1f298ad9d5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>155</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1d38ea29-bbe3-45e2-b37c-02af9787d0e7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>139</y>
  <width>500</width>
  <height>27</height>
  <uuid>{dd3dce47-c107-46e8-90ae-f06422cb97cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>193</y>
  <width>160</width>
  <height>30</height>
  <uuid>{07bf36b2-367f-4332-8200-0b6d7017afe1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency (Hertz)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>Frequency_Value</objectName>
  <x>448</x>
  <y>193</y>
  <width>60</width>
  <height>30</height>
  <uuid>{600f5f27-7f32-4cbc-9402-6bbb7415c568}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>100.004</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>Frequency</objectName>
  <x>8</x>
  <y>177</y>
  <width>500</width>
  <height>27</height>
  <uuid>{859b8f24-fbc4-4127-9432-95e0e467cbab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.45927000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>232</y>
  <width>220</width>
  <height>30</height>
  <uuid>{739c0de4-0e99-4a68-9011-c90835b376ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number of Harmonics</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>Harmonics</objectName>
  <x>448</x>
  <y>232</y>
  <width>60</width>
  <height>30</height>
  <uuid>{01641a65-23d8-4e33-932e-417c9b9dbe6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.250</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>Harmonics</objectName>
  <x>8</x>
  <y>216</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e251ff65-9564-4e72-aa03-739f0cc74de4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.50000000</maximum>
  <value>0.25000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>385</y>
  <width>160</width>
  <height>30</height>
  <uuid>{1338d825-15af-4e81-80f6-f224913a4ac9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Phase Mod. Rate</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>PhaseRate</objectName>
  <x>448</x>
  <y>385</y>
  <width>60</width>
  <height>30</height>
  <uuid>{08fe63ca-841f-46f6-97dc-f5f82273211e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.001</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>244</r>
   <g>244</g>
   <b>72</b>
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
  <objectName>PhaseRate</objectName>
  <x>8</x>
  <y>369</y>
  <width>500</width>
  <height>27</height>
  <uuid>{c18eed49-061a-498b-a0b1-6e38ba9a1975}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>50.00000000</maximum>
  <value>0.00100000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

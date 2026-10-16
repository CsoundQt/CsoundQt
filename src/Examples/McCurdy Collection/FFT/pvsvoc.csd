; Written by iain mccurdy, 2006

; Modified for QuteCsound by René, September 2010, updated Feb 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add table(s) for exp slider
; ksmps changed from 100 to 10 to avoid the message pvsfread: analysis frame overlap must
; be >= ksmps
; Instrument 1 is activated by MIDI and by the GUI
; Add Browser for analysis files


; my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
; --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>
--env:SADIR+ = ../../SourceMaterials
</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 32     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum sound intensity level regardless of bit depth

; Initialise global audio (excitation signal) variable to zero
gaexc init 0
gisine ftgen 0, 0, 65536, 10, 1  ; Sine wave

; Table for exp slider
giExp2000 ftgen 0, 0, 129, -25, 0, 20.0, 128, 2000.0


instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    kcps invalue "CPS"
    gkcps tablei kcps, giExp2000, 1
    outvalue "CPS_Value", gkcps
    gkptr   invalue "Pointer"
    gkspd   invalue "Speed"
    gkdepth invalue "Depth"
    gkgain  invalue "Gain"
    gkmix   invalue "Mixer"
    gkinput invalue "Input"
    gkwave  invalue "Wave"
    gkGate  invalue "Gate"
  endif
endin

instr 1            ; Signal generator
  if p4 != 0 then  ; MIDI
    ioct = p4      ; Read MIDI pitch information from a MIDI keyboard
    iamp = p5

    ; Pitch bend information is read
    ; Pitch bend range in semitones (will be defined further later)
    iSemitoneBendRange = 2
    imin               = 0  ; Equilibrium position
    ; Max pitch displacement (in oct format)
    imax = iSemitoneBendRange * .0833333
    ; Pitch bend variable (in oct format)
    kbend pchbend imin, imax

    kcps = cpsoct(ioct + kbend)
    ; Create an amplitude envelope to prevent clicks. Includes a MIDI-release stage
    kenv linsegr 0, .01, iamp, .01, 0
  else               ; GUI
    iporttime = .01  ; Create a ramping up value that will be used for portamento time
    ; Create a ramping up value that will be used for portamento time
    kporttime linseg 0, .001, iporttime, 1, iporttime
    kcps portk gkcps, kporttime  ; Apply portamento to gkcps
    ; Create an amplitude envelope to prevent clicks. Includes a MIDI-release stage
    kenv linsegr 0, .01, 1, .01, 0
  endif

  if gkwave = 0 then
    asine oscili kenv, kcps, gisine
    ; Add sine tone to the global audio variable gaexc. This mechanism facilitates MIDI
    ; polyphony
    gaexc = gaexc + asine
  elseif gkwave <= 3 && gkwave > 0 then
    avco vco kenv, kcps, i(gkwave), 0.5, gisine, 1, 0, 22054/sr, 0  ; Sawtooth waveform
    ; Add vco tone to the global audio variable gaexc. This mechanism facilitates MIDI
    ; polyphony
    gaexc = gaexc + avco
  else
    anoise noise kenv, 0
    ; Add noise signal to the global audio variable gaexc. This mechanism facilitates MIDI
    ; polyphony
    gaexc = gaexc + anoise
  endif
endin

instr 3
  ; If 'input' switch is set to 'stored file' then implement the next line of code
  if gkinput >= 1 then
    if gkinput != 1 kgoto SKIP1

    SAnalysisFile1 invalue "_Browse1"
    ; Derive the file length (in seconds) of the chosen analysis file
    ilen1 filelen SAnalysisFile1
    ; Output  opcode  frequency
    ; Create a moving phase value (0-1) that will be used as a file pointer. Frequency of
    ; phasor will be directly proportional to speed slider and inversely proportional to
    ; the length of the analysis file
    kptr phasor gkspd/ilen1
    ; Create a trigger (momentary 1 value) each time variable kptr changes
    ktrig changed kptr

    if ktrig = 1 then
      ; Update 'pointer' slider whenever trigger is '1' using value held in the 'value'
      ; column
      outvalue "Pointer", kptr
    endif

    ; Output  opcode  pointer     |   file
    ; Read an analysis file from the hard drive according to the given file pointer
    ; location. Output an f-signal.
    famp pvsfread gkptr * ilen1, SAnalysisFile1
    kgoto SKIP2
SKIP1:
    SAnalysisFile2 invalue "_Browse2"
    ; Derive the file length (in seconds) of the chosen analysis file
    ilen2 filelen SAnalysisFile2
    ; Output  opcode  frequency
    ; Create a moving phase value (0-1) that will be used as a file pointer. Frequency of
    ; phasor will be directly proportional to speed slider and inversely proportional to
    ; the length of the analysis file
    kptr phasor gkspd/ilen2
    ; Create a trigger (momentary 1 value) each time variable kptr changes
    ktrig changed kptr

    if ktrig = 1 then
      ; Update 'pointer' slider whenever trigger is '1' using value held in the 'value'
      ; column
      outvalue "Pointer", kptr
    endif

    ; Output  opcode  pointer     |   file
    ; Read an analysis file from the hard drive according to the given file pointer
    ; location. Output an f-signal.
    famp pvsfread gkptr * ilen2, SAnalysisFile2
SKIP2:
    ; If 'input' switch is not set to 'stored file' then implement the next line of code
  else
    ; Read audio from the computer's live input (left input only is read, right channel is
    ; ignored in subsequent code. A stereo version could easily be built but this would
    ; double cpu demands!)
    asig, aignore ins
    ; Output opcode input | fftsize | overlap | winsize | wintype
    famp pvsanal asig, 1024, 256, 1024, 1  ; Analyse the audio signal
  endif                                    ; End of 'if'...'then' branching

  fexc pvsanal gaexc, 1024, 256, 1024, 1  ; Analyse the excitation audio signal
  ; Create a cross-synthesis between the two f-signals
  fsig pvsvoc famp, fexc, gkdepth, gkgain

  asig pvsynth fsig  ; Resynthesize the new f-signal into an audio signal

  if gkGate = 1 then
    ; Create an amplitude following signal that follows the dynamic envelope of the
    ; excitation signal - this will be used to gate the cross synthesised signal
    afollow follow2 gaexc, 0.1, 0.1
    ; Create a wet dry mix between the cross synthesis and the excitation signal
    amix ntrpol gaexc*0.2, asig*afollow, gkmix
  else
    ; Create a wet dry mix between the cross synthesis and the excitation signal
    amix ntrpol gaexc*0.2, asig, gkmix
  endif
  outs amix, amix  ; Send the wet/dry mix audio signal to the outputs
  ; Reset the global audio signal to zero - this prevents a stuck, non-zero value for
  ; gaexc in the situation where no excitation signal is playing
  gaexc = 0
endin

instr 4  ; Set speed slider to zero
  outvalue "Speed", 0.0
endin
</CsInstruments>
<CsScore>
; Instr | start |   duration
i 10 0 3600  ; GUI
i 3 0 3600   ; Activate instrument 3 for 1 hour - also sustains realtime performance
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>433</x>
 <y>139</y>
 <width>860</width>
 <height>623</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>521</width>
  <height>616</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvsvoc</label>
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
  <x>524</x>
  <y>2</y>
  <width>325</width>
  <height>615</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvsvoc</label>
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
  <x>528</x>
  <y>26</y>
  <width>313</width>
  <height>589</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------
Pvsvoc combines the spectral envelope of one signal (referred to as the input signal) with the frequencies of another signal (referred to as the excitation signal). This capability can be used to imitate the functioning of the traditional vocoder. This is what has been implemented in this example. An input signal of either a stored analysis file (voice or drum loop) or a live input can be combined with a variety of synthesized tones. This signal generator can also be triggered from a connected MIDI keyboard thus allowing the playing of chords of excitation signals. When playing from a MIDI keyboard the 'Signal Generator' switch should be deactivated. Pitch bend is also implemented. The 'Gate Amplitude' switch forces the output sound to follow the amplitude of the excitation sound.
The 'Depth of Cross Synthesis' slider allows the user to vary the amount of cross synthesis that will be applied. If this control is at zero then the output signal of pvsvoc will be simply the 'input' signal, if 'Depth...' is at 1 then the frequencies in the output signal will be entirely those of the excitation signal. The 'Mixer' slider allows the user to crossfade between the excitation signal and the output of pvsvoc. When using a stored analysis file (either voice or drums) as input the speed of playback can be varied using the 'Speed' slider. A value of 1 represents normal playback speed, 2 represents double speed and so on. File pointer movement is monitored by the 'File Pointer' slider. Manual file pointer adjustment is possible by first reducing 'Speed' to zero by clicking the 'Speed to Zero' button and then using the 'File Pointer' slider.</label>
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
  <y>16</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b3560c14-84be-4876-9100-5807ffe16e97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input</label>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Input</objectName>
  <x>69</x>
  <y>16</y>
  <width>120</width>
  <height>30</height>
  <uuid>{cdb2d3b2-5a09-4e13-865e-8501e33b9d35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Live Input</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Vocal Sample</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Drum Loop</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>7</x>
  <y>165</y>
  <width>510</width>
  <height>127</height>
  <uuid>{c23f1867-583e-4e16-b094-1ce102f86873}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Signal Generator</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>11</x>
  <y>206</y>
  <width>160</width>
  <height>30</height>
  <uuid>{090b86ec-158a-4f6a-abf8-78660fc5c107}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CPS (if No MIDI)</label>
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
  <objectName>CPS</objectName>
  <x>11</x>
  <y>189</y>
  <width>500</width>
  <height>27</height>
  <uuid>{7414f1af-bc65-42bb-a972-115e0eeae202}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>CPS_Value</objectName>
  <x>451</x>
  <y>206</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bb1d774f-0ab7-400b-9a57-a8243856eee9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>200.000</label>
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
  <x>290</x>
  <y>250</y>
  <width>80</width>
  <height>30</height>
  <uuid>{217e252e-ab29-4b66-aff6-86e28505d5ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Wave</label>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Wave</objectName>
  <x>371</x>
  <y>250</y>
  <width>130</width>
  <height>30</height>
  <uuid>{76d7136c-5124-44ec-9ba4-7d0cb0e8c6eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Sine</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sawtooth</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Square</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Triangle</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Noise</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b6560</objectName>
  <x>23</x>
  <y>250</y>
  <width>210</width>
  <height>30</height>
  <uuid>{16cf4cec-b8d2-48a8-8cbe-e36230f9d26c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On / Off   (Use if No MIDI)</text>
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
  <x>7</x>
  <y>296</y>
  <width>510</width>
  <height>140</height>
  <uuid>{68d4f34d-931a-4ea7-b688-77724021f7a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Source Signal</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>Pointer</objectName>
  <x>11</x>
  <y>336</y>
  <width>500</width>
  <height>15</height>
  <uuid>{e55fdc2d-0bbe-479a-a3d8-525e73353a9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2/>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.43013632</xValue>
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
  <objectName>Pointer</objectName>
  <x>451</x>
  <y>350</y>
  <width>60</width>
  <height>30</height>
  <uuid>{450cce93-cd69-4e55-97ec-5d2f88014dd2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.430</label>
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
  <x>11</x>
  <y>351</y>
  <width>160</width>
  <height>30</height>
  <uuid>{fe34f976-e5bc-4408-a62a-5fa5026da416}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>File Pointer</label>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Speed</objectName>
  <x>451</x>
  <y>400</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0286ec15-8443-4ab3-9f65-fdf6bbee6a17}</uuid>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Speed</objectName>
  <x>11</x>
  <y>383</y>
  <width>500</width>
  <height>27</height>
  <uuid>{cf784473-dd45-4074-9571-b6264bf289af}</uuid>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>11</x>
  <y>400</y>
  <width>120</width>
  <height>30</height>
  <uuid>{eea58f50-29cc-4f4b-982a-1f030bf01966}</uuid>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>b1684</objectName>
  <x>251</x>
  <y>413</y>
  <width>120</width>
  <height>21</height>
  <uuid>{014685d3-5101-4dd5-b4ef-62a64ecf195b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Speed to Zero</text>
  <image>/</image>
  <eventLine>i 4 0 0</eventLine>
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
  <x>7</x>
  <y>440</y>
  <width>510</width>
  <height>170</height>
  <uuid>{f5f026fd-f603-4578-befa-7395826dd95a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pvsvoc Vocoder</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>Gate</objectName>
  <x>251</x>
  <y>447</y>
  <width>120</width>
  <height>21</height>
  <uuid>{0933c911-abe9-4fd8-8760-11d20dc84ceb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Amplitude Gate</text>
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
  <x>10</x>
  <y>573</y>
  <width>280</width>
  <height>30</height>
  <uuid>{0ebe866f-225c-4117-8271-e894e7d7684d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Exitation Signal &lt;--- Mixer ---> Source Signal</label>
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
  <objectName>Mixer</objectName>
  <x>11</x>
  <y>556</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e5e47039-15c3-4936-9d86-6d62cb86416e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Mixer</objectName>
  <x>450</x>
  <y>573</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7a609e50-3748-4446-8cf2-4b0b31d3f966}</uuid>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Gain</objectName>
  <x>451</x>
  <y>533</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c3d52355-34d5-4a67-bd02-e62b51a8837c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.020</label>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Gain</objectName>
  <x>11</x>
  <y>516</y>
  <width>500</width>
  <height>27</height>
  <uuid>{45ab0ca9-cd12-4f97-a412-052d26fe0fa0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.02000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>11</x>
  <y>533</y>
  <width>120</width>
  <height>30</height>
  <uuid>{0f727a6c-af68-43e5-b072-19c367c98e6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gain</label>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Depth</objectName>
  <x>451</x>
  <y>492</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3cd27781-8800-437d-9276-baee8eff1eb1}</uuid>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Depth</objectName>
  <x>11</x>
  <y>475</y>
  <width>500</width>
  <height>27</height>
  <uuid>{f5491987-1bc3-463b-bc73-66fcd58ecedc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>11</x>
  <y>492</y>
  <width>180</width>
  <height>30</height>
  <uuid>{ec7b74e0-0c5b-4069-9fbd-d284336eaa92}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Depth of Cross Synthesis</label>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse1</objectName>
  <x>11</x>
  <y>78</y>
  <width>170</width>
  <height>30</height>
  <uuid>{626c95e2-b30f-4940-8d9e-bb115ff573ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>AndItsAll.pvx</stringvalue>
  <text>Browse Analysis File</text>
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
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse1</objectName>
  <x>182</x>
  <y>79</y>
  <width>330</width>
  <height>28</height>
  <uuid>{600e1a77-3d18-4bc8-a6a3-f7074112f7e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>AndItsAll.pvx</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>11</x>
  <y>59</y>
  <width>120</width>
  <height>30</height>
  <uuid>{f2432220-3ca1-4436-97e0-72950b71797b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vocal pvx</label>
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
  <x>11</x>
  <y>108</y>
  <width>120</width>
  <height>30</height>
  <uuid>{20e8a45b-14ce-431a-a7ab-c9986c580333}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Drump Loop pvx</label>
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
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse2</objectName>
  <x>182</x>
  <y>128</y>
  <width>330</width>
  <height>28</height>
  <uuid>{c8ec4c98-1b48-432f-97df-a52559fa94e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>loop.pvx</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse2</objectName>
  <x>11</x>
  <y>127</y>
  <width>170</width>
  <height>30</height>
  <uuid>{3814ae80-f0e5-4cc6-912f-b16b1b8a04f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>loop.pvx</stringvalue>
  <text>Browse Analysis File</text>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>182</x>
  <y>55</y>
  <width>330</width>
  <height>30</height>
  <uuid>{a63909ac-6fa4-41c8-a84b-ba08e76132ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Restart the instrument after changing the analysis  file(s).</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

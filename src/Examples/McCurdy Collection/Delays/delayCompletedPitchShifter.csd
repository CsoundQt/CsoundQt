; Written by Iain McCurdy, 2006

; Modified for QuteCsound by René, September 2010, updated Feb 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files


; my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 32     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum sound intensity level regardless of bit depth


; Half sine window function used for amplitude enveloping
gihalfsine ftgen 0, 0, 1025, 9, 0.5, 1, 0


opcode FilePlay2, aa, Skoo  ; Credit to Joachim Heintz
  ; gives stereo output regardless your soundfile is mono or stereo
  Sfil, kspeed, iskip, iloop xin
  ichn filenchnls Sfil
  if ichn == 1 then
    aL diskin2 Sfil, kspeed, iskip, iloop
    aR = aL
  else
    aL, aR diskin2 Sfil, kspeed, iskip, iloop
  endif
  xout aL, aR
endop


instr 10                           ; GUI
  gkGain  invalue "Gain"           ; init .5
  gktrans invalue "Transposition"  ; init 0
  gkdlt   invalue "Delay_Time"     ; init .05
  gkFB    invalue "Feedback"       ; init 0
  gkinput invalue "Input"
  gkMix   invalue "Mix"  ; init 1
endin

instr 1  ; Plays file
  if gkinput = 0 then
    Sfile invalue "_Browse1"
    ; Output  opcode file   | speed | inskip | looping (0=off 1=on)
    asigL, asigR FilePlay2 Sfile, 1, 0, 1
  else
    asigL, asigR ins
  endif
  aenv linsegr 0, 0.01, 1, 0.01, 0  ; Anti click envelope with release stage
  gasigL = asigL * gkGain * aenv    ; Rescale audio signal with on-screen gain slider
  gasigR = asigR * gkGain * aenv    ; Rescale audio signal with on-screen gain slider
endin

instr 2  ; Pitch shifter
  ; Create a variable function that rapidly ramps up to a set value
  kporttime linseg 0, 0.001, 0.005, 1, 0.005
  ktrans portk gktrans, kporttime  ; Smooth changes in slider variable
  kdlt   portk gkdlt, kporttime    ; Smooth changes in slider variable
  adlt interp kdlt                 ; Create a-rate version of kdlt
  koctfract = ktrans/12            ; Transposition as fraction of an octave
  ; Ratio of new freq to a declared base frequency (middle c)
  kratio = cpsoct(8+koctfract)/cpsoct(8)
  krate  = (kratio-1)/kdlt  ; Subtract 1/1 speed

  aphase1 phasor -krate      ; Moving phase 1-0
  aphase2 phasor -krate, .5  ; Moving phase 1-0 - phase offset by 180 degrees (.5 radians)

  agate1 tablei aphase1, gihalfsine, 1, 0, 1  ; Window func =half sine
  agate2 tablei aphase2, gihalfsine, 1, 0, 1  ; Window func =half sine

  ; Left
  ; channel===========================================================================================================================================================
  aignore delayr 2                  ; Declare delay buffer
  adelsig1L deltap3 aphase1 * adlt  ; Variable tap
  aGatedSig1L = adelsig1L * agate1
  ; Write audio to the beginning of the delay buffer, mix in feedback signal - proportion
  ; defined by gkfb
  delayw gasigL + (aGatedSig1L*gkFB)

  aignore delayr 2                  ; Declare delay buffer
  adelsig2L deltap3 aphase2 * adlt  ; Variable tap
  aGatedSig2L = adelsig2L * agate2
  ; Write audio to the beginning of the delay buffer, mix in feedback signal - proportion
  ; defined by gkfb
  delayw gasigL + (aGatedSig2L*gkFB)
  ; =======================================================================================================================================================================

  ; Right
  ; channel==========================================================================================================================================================
  aignore delayr 2                  ; Declare delay buffer
  adelsig1R deltap3 aphase1 * adlt  ; Variable tap
  aGatedSig1R = adelsig1R * agate1
  ; Write audio to the beginning of the delay buffer, mix in feedback signal - proportion
  ; defined by gkfb
  delayw gasigR + (aGatedSig1R*gkFB)

  aignore delayr 2                  ; Declare delay buffer
  adelsig2R deltap3 aphase2 * adlt  ; Variable tap
  aGatedSig2R = adelsig2R * agate2
  ; Write audio to the beginning of the delay buffer, mix in feedback signal - proportion
  ; defined by gkfb
  delayw gasigR + (aGatedSig2R*gkFB)
  ; =======================================================================================================================================================================
  ; Sum and rescale pitch shifter outputs (left channel)
  aGatedMixL = (aGatedSig1L + aGatedSig2L) * .5
  ; Sum and rescale pitch shifter outputs (right channel)
  aGatedMixR = (aGatedSig1R + aGatedSig2R) * .5
  aL ntrpol gasigL, aGatedMixL, gkMix
  aR ntrpol gasigR, aGatedMixR, gkMix
  outs aL, aR           ; Send audio to outputs
  clear gasigL, gasigR  ; Clear global audio variables
endin
</CsInstruments>
<CsScore>
; Instr | start | duration
i 10 0 -1  ; GUI
i 2 0 -1   ; Instrument 2 plays a held note

f 0 3600  ; Dummy score event keeps realtime performance going for 1 hour
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>1134</width>
 <height>413</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#efefef</bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>3</x>
  <y>2</y>
  <width>513</width>
  <height>396</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Completed Pitch Shifter</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="background">#9edcd9</bgcolor>
  <bordercolor>#9e9e9e</bordercolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b7039</objectName>
  <x>8</x>
  <y>7</y>
  <width>118</width>
  <height>29</height>
  <uuid>{487d5181-d838-4cce-9628-317fefc350cb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>ON / OFF</text>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>true</latched>
  <fontsize>10</fontsize>
  <font/>
  <flatStyle>true</flatStyle>
  <color>#cbceff</color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Gain</objectName>
  <x>9</x>
  <y>63</y>
  <width>500</width>
  <height>20</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.38000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f0f0f0</bgcolor>
  <foreground>#34393a</foreground>
  <fillcolor>#dfdfdf</fillcolor>
  <bordercolor>#aebcd2</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>78</y>
  <width>100</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Gain</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Gain</objectName>
  <x>449</x>
  <y>77</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.380</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <format/>
  <padding>5</padding>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>520</x>
  <y>2</y>
  <width>370</width>
  <height>396</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Completed Pitch Shifter</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="background">#9edcd9</bgcolor>
  <bordercolor>#9e9e9e</bordercolor>
  <bordermode>true</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>526</x>
  <y>19</y>
  <width>358</width>
  <height>380</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>
This example is an refinement of the 'Delay: Simple Pitch Shifter' example in that amplitude enveloping is employed to prevent glitching in the sound output whenever the sawtooth LFO waveform that modulates delay time instantaneously jumps from a maximum to a minimum (or vice versa). Two modulated delay taps (180 degrees out of phase with each other) are employed and are enveloped individually.
The outputs of the two delay taps are mixed to create an - as smooth as possible - pitch shifted output. Pitch shifting effects can also be produced using any of the granular synthesis opcodes but this method has the advantage that it can be applied to a streamed live audio input or a signal generated within Csound and it does not rely upon a stored function table.
Some experimentation with the setting for 'Delay Time' can enhance the resultant sound quality. An appropriate setting for 'Delay Time' is partially dependent upon the type of sound material being processed. Most hardware implementations of pitch shifters do not include this parameter. Large values for 'Delay Time' tend to temporally smear the processed sound whereas excessively small values for 'Delay Time' tend to distort the harmonic content of the original sound. The 'Feedback' control allows some of the pitch shifted output to be fed back into the input thus allowing the creation of arpeggiation effects.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>11</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#414141</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Transposition</objectName>
  <x>449</x>
  <y>117</y>
  <width>60</width>
  <height>30</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>1.536</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <format/>
  <padding>5</padding>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>159</y>
  <width>120</width>
  <height>30</height>
  <uuid>{b57ba536-8f28-4986-9bf7-8eb84262d8ca}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Delay Time</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Transposition</objectName>
  <x>9</x>
  <y>103</y>
  <width>500</width>
  <height>20</height>
  <uuid>{b8fa76b9-3d04-4156-a2f2-a413d3864da3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-24.00000000</minimum>
  <maximum>24.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>1.53600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f0f0f0</bgcolor>
  <foreground>#34393a</foreground>
  <fillcolor>#dfdfdf</fillcolor>
  <bordercolor>#aebcd2</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Delay_Time</objectName>
  <x>448</x>
  <y>157</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5f670bb1-e411-4f17-94a3-2321fdf5742b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.185</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <format/>
  <padding>5</padding>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Delay_Time</objectName>
  <x>9</x>
  <y>143</y>
  <width>500</width>
  <height>20</height>
  <uuid>{1920efdc-fe11-4010-a22c-50efec0c27d3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00100000</minimum>
  <maximum>2.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.18490800</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f0f0f0</bgcolor>
  <foreground>#34393a</foreground>
  <fillcolor>#dfdfdf</fillcolor>
  <bordercolor>#aebcd2</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>118</y>
  <width>160</width>
  <height>30</height>
  <uuid>{aea841b2-29e6-42d6-ac23-02439b1cc47f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Transposition (semitones)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>98</x>
  <y>261</y>
  <width>80</width>
  <height>30</height>
  <uuid>{429fca04-6933-4c2e-9e1a-301edbfcdc10}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Source</label>
  <alignment>right</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Input</objectName>
  <x>180</x>
  <y>263</y>
  <width>120</width>
  <height>30</height>
  <uuid>{45d19438-752c-4ed6-a700-3a764c5ab185}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Audio File</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Live</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <flatStyle>true</flatStyle>
  <bgcolor>#eff0f1</bgcolor>
  <foreground>#34393a</foreground>
  <bordercolor>#adbdc2</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>0</borderRadius>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Feedback</objectName>
  <x>10</x>
  <y>183</y>
  <width>500</width>
  <height>20</height>
  <uuid>{afe11ed2-eb11-423d-a391-3677ebeda4f1}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.72800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f0f0f0</bgcolor>
  <foreground>#34393a</foreground>
  <fillcolor>#dfdfdf</fillcolor>
  <bordercolor>#aebcd2</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Feedback</objectName>
  <x>449</x>
  <y>197</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d6bd3764-66b6-499b-8028-0113ff526003}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.728</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <format/>
  <padding>5</padding>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>199</y>
  <width>120</width>
  <height>30</height>
  <uuid>{4100a5b8-76c3-4420-9229-a606f4defaf9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Feedback</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse1</objectName>
  <x>10</x>
  <y>302</y>
  <width>170</width>
  <height>30</height>
  <uuid>{2f6cb425-0ff4-4d5c-8417-9ec219e24182}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>AndItsAll.wav</stringvalue>
  <text>Browse Audio File</text>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <font/>
  <flatStyle>true</flatStyle>
  <color>#cbceff</color>
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
  <y>302</y>
  <width>330</width>
  <height>30</height>
  <uuid>{408db175-49b4-461e-81e8-fd44ab10814b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.000</label>
  <instant>true</instant>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>#202020</color>
  <bgcolor mode="nobackground">#cecece</bgcolor>
  <background>nobackground</background>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>182</x>
  <y>332</y>
  <width>330</width>
  <height>30</height>
  <uuid>{cc4ee995-e25a-4871-bb14-477ea340315b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Restart the instrument after changing the audio file.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Mix</objectName>
  <x>8</x>
  <y>219</y>
  <width>500</width>
  <height>20</height>
  <uuid>{4789481d-2dc3-4414-9c94-80e2ff95c3cd}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.81600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f0f0f0</bgcolor>
  <foreground>#34393a</foreground>
  <fillcolor>#dfdfdf</fillcolor>
  <bordercolor>#aebcd2</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>241</y>
  <width>80</width>
  <height>25</height>
  <uuid>{be3fcf6a-e523-4700-9b94-375bc6583a14}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Dry / Wet Mix</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

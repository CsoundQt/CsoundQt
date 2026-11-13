; Written by iain mccurdy, 2008

; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:


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


gisine ftgen 0, 0, 4096, 10, 1  ; A sine wave function table is defined


instr 10                                   ; GUI
  gkfreq     invalue "Frequency_Rotation"  ; init 0.2
  gkAmpDepth invalue "Central_Edge"        ; init .7
  gkAmpPhase invalue "Orientation"         ; init 0.5
  gkPanDepth invalue "Panning_Width"       ; init 1
  gkDopDep   invalue "Doppler_Depth"       ; init .003
  gkOutGain  invalue "Output_Gain"         ; init 0.7
endin

instr 1
  iporttime = 0.1  ; Create 'portamento time' constant value
  ; Create 'portamento time' rising function
  kporttime linseg 0, 0.001, iporttime, 1, iporttime
  ; Apply portamento to gkampphase. Create new output variable kampphase (global variables
  ; can't be both input and output)
  kAmpPhase portk gkAmpPhase, kporttime
  ; Apply portamento to gkdopdep. Create new output variable kdopdep (global variables
  ; can't be both input and output)
  kDopDep portk gkDopDep, kporttime
  aDopDep interp kDopDep
  asig pinkish 0.3  ; Define sound source (pink noise) for this example
  ; Bandpass filter pink noise to give asig a 'whistling' characteristic. This filtering
  ; causes a loss of signal power which must later be compensated for
  asig butbp asig, 500, 10

  ; An LFO defines a variable used to modulate amplitude (note: variable phase). This
  ; models the location within the circle from which we are listening. No amplitude
  ; modulation represent represents our listening position being exactly central, maximum
  ; modulation represents us being near to the edge of a large circle. The control over
  ; phase of this LFO represents which edge we are closer to.
  aAmp osciliktp gkfreq, gisine, kAmpPhase
  aAmp = (aAmp * 0.5 * gkAmpDepth) + 0.5  ; Rescale and offset amplitude modulation LFO

  ; An LFO defines a variable for panning control - i.e. Whether sound is currently to out
  ; left or to out right. Note that phase is 0.75 and therefore 0.75 radians (or 270
  ; degrees out of phase) with the delay modulation
  aPan oscili (gkPanDepth * 0.5), gkfreq, gisine, 0.75
  aPan = aPan + 0.5  ; Offset panning LFO

  ; Define a variable that will be use for 'maximum delay time' (buffer length)
  iMaxDelay = 1
  ; An LFO defines a variable for delay time (note phase at zero)
  aDelay oscili aDopDep, gkfreq, gisine, 0
  ; Delay time variable 'adelay' is offset to stay within the positive domain
  aDelay = aDelay + aDopDep
  aBuff delayr iMaxDelay       ; Define delay buffer stating its length
  aDelay deltap3 aDelay+0.001  ; Tap delay buffer
  delayw asig                  ; Signal written into begining of delay buffer

  ; Apply amplitude modulation rescaling constant and outpu gain slider to signal output
  ; by delay
  asig = aDelay * aAmp * 100 * gkOutGain

  ; Apply panning to signal output from amplitude modualtion stage using pan2 opcode
  aL, aR pan2 asig, aPan, 1
  outs aL, aR  ; Send audio to outputs
endin
</CsInstruments>
<CsScore>
; Instr | start | duration
i 10 0 -1  ; GUI

f 0 3600  ; Dummy score event keeps realtime performance going for 1 hour
</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>1255</width>
 <height>491</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#efefef</bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>515</width>
  <height>323</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Doppler Effect</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="background">#9edcd9</bgcolor>
  <bordercolor>#9e9e9e</bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b8968</objectName>
  <x>11</x>
  <y>5</y>
  <width>112</width>
  <height>30</height>
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
  <objectName>Frequency_Rotation</objectName>
  <x>9</x>
  <y>60</y>
  <width>500</width>
  <height>20</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-5.00000000</minimum>
  <maximum>5.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.32000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f3f3f3</bgcolor>
  <foreground>#7a7a7a</foreground>
  <fillcolor>#fffcd0</fillcolor>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>78</y>
  <width>180</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Frequency of Rotation (Hertz)</label>
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
  <objectName>Frequency_Rotation</objectName>
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
  <label>0.320</label>
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
  <x>518</x>
  <y>2</y>
  <width>390</width>
  <height>435</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Doppler EffectCircular Motion Doppler Effect  </label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <padding>10</padding>
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
  <x>523</x>
  <y>37</y>
  <width>381</width>
  <height>394</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>This example uses three sine-wave LFOs to simulate a sound moving in a circle around the listener by modulating amplitude, panning and delay time. Delay-time modulation also affects pitch, creating the Doppler effect.

All three LFOs must share the same frequency. Negative values reverse the direction of movement. Their phase relationships determine the sound source's position around the listener. The panning and delay-time LFOs must have a phase difference of 90° or 270°, depending on the direction of rotation.

Amplitude modulation simulates the listener's position relative to the circle. The closer the listener is to its edge, the stronger the modulation. The amplitude LFO's phase (set using the 'Orientation' slider) determines which side of the circle is closest. A small amount of amplitude modulation is recommended, as sounds directly to the left or right are perceived as louder. In this case, the 'Orientation' value should be 0.5 radians.

Using sine waves creates circular motion, while other waveforms can simulate different movement patterns, offering further possibilities for experimentation.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>12</fontsize>
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
  <objectName>Central_Edge</objectName>
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
  <label>0.376</label>
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
  <width>180</width>
  <height>30</height>
  <uuid>{b57ba536-8f28-4986-9bf7-8eb84262d8ca}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Orientation (radians)</label>
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
  <objectName>Central_Edge</objectName>
  <x>9</x>
  <y>100</y>
  <width>500</width>
  <height>20</height>
  <uuid>{b8fa76b9-3d04-4156-a2f2-a413d3864da3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.37600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f3f3f3</bgcolor>
  <foreground>#7a7a7a</foreground>
  <fillcolor>#fffcd0</fillcolor>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Orientation</objectName>
  <x>449</x>
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
  <label>0.610</label>
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
  <objectName>Orientation</objectName>
  <x>9</x>
  <y>140</y>
  <width>500</width>
  <height>20</height>
  <uuid>{1920efdc-fe11-4010-a22c-50efec0c27d3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.61000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f3f3f3</bgcolor>
  <foreground>#7a7a7a</foreground>
  <fillcolor>#fffcd0</fillcolor>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>118</y>
  <width>180</width>
  <height>30</height>
  <uuid>{aea841b2-29e6-42d6-ac23-02439b1cc47f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Central / Edge</label>
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
  <objectName>Panning_Width</objectName>
  <x>9</x>
  <y>180</y>
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
  <value>0.70000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f3f3f3</bgcolor>
  <foreground>#7a7a7a</foreground>
  <fillcolor>#fffcd0</fillcolor>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Panning_Width</objectName>
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
  <label>0.700</label>
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
  <y>199</y>
  <width>140</width>
  <height>30</height>
  <uuid>{4100a5b8-76c3-4420-9229-a606f4defaf9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Panning Width</label>
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
  <x>9</x>
  <y>279</y>
  <width>140</width>
  <height>30</height>
  <uuid>{5dbe2a97-91d9-45ba-b3b0-a0d135cdf78a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Output Gain</label>
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
  <objectName>Output_Gain</objectName>
  <x>9</x>
  <y>261</y>
  <width>500</width>
  <height>20</height>
  <uuid>{17e22bca-803e-49a8-8356-5bad11f10d5f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.39400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f3f3f3</bgcolor>
  <foreground>#7a7a7a</foreground>
  <fillcolor>#fffcd0</fillcolor>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Output_Gain</objectName>
  <x>449</x>
  <y>279</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e6133655-7970-45ca-9827-07d680a3d593}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.394</label>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Doppler_Depth</objectName>
  <x>449</x>
  <y>238</y>
  <width>60</width>
  <height>30</height>
  <uuid>{54ac276d-3b29-4d80-bbeb-a86bdb760fe3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.081</label>
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
  <y>239</y>
  <width>140</width>
  <height>30</height>
  <uuid>{224170e9-6fd8-4117-9cb2-a90d433639ec}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Doppler Depth</label>
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
  <objectName>Doppler_Depth</objectName>
  <x>9</x>
  <y>221</y>
  <width>500</width>
  <height>20</height>
  <uuid>{f188ef98-8516-4b91-9a8e-7bf3a39b6227}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.10000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.08120000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f3f3f3</bgcolor>
  <foreground>#7a7a7a</foreground>
  <fillcolor>#fffcd0</fillcolor>
  <bordercolor>#adadad</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#6d6d6d</rulercolor>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

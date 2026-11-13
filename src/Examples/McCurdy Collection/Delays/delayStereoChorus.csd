; Written by Iain McCurdy, 2006

; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add table(s) for exp slider


; my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 10     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum sound intensity level regardless of bit depth


gilfoshape ftgen 0, 0, 131072, 19, 0.5, 1, 180, 1       ; U-shape parabola
giExp3000  ftgen 0, 0, 129, -25, 0, 20.0, 128, 3000.0   ; Table for exp slider
giExp20000 ftgen 0, 0, 129, -25, 0, 20.0, 128, 20000.0  ; Table for exp slider


instr 10                               ; GUI
  gkOscGain invalue "Oscillator_Gain"  ; init 0.3
  kOscFrq   invalue "Oscillator_Freq"
  gkOscFrq tablei kOscFrq, giExp3000, 1
  outvalue "Oscillator_Freq_Value", gkOscFrq  ; init 100.0
  kOscLPF invalue "Tone"
  gkOscLPF tablei kOscLPF, giExp20000, 1
  outvalue "Tone_Value", gkOscLPF               ; init 4000.0
  gkOscRes   invalue "Resonance"                ; init 0.4
  gkmix      invalue "Mix"                      ; init 0.5
  gkChoDepth invalue "Chorus_Modulation_Depth"  ; init 0.001
  gkChoRate  invalue "Chorus_Modulation_Rate"   ; init 0.8
  gkphs      invalue "Right_Channel_Phase"      ; init 0.5
endin

instr 1                          ; Generates audio signal
  asig vco2 gkOscGain, gkOscFrq  ; Generate a sawtooth wave audio signal
  ; Low-pass filter audio signal (create a global variable output to be used in instrument
  ; 2)
  gasig moogladder asig, gkOscLPF, gkOscRes
endin

instr 2             ; Chorus-delay instrument
  iporttime = 0.01  ; I-rate variable definition of portamento time
  ; Ramping up from zero version of portamento time variable
  kporttime linseg 0, 0.01, iporttime, 1, iporttime
  kChoDepth portk gkChoDepth, kporttime  ; Smooth variable changes with portk
  ; Interpolate to create a-rate version of k-rate variable
  aChoDepth interp kChoDepth

  amodL osciliktp gkChoRate, gilfoshape, 0
  amodL = (((amodL*aChoDepth)+aChoDepth)*.5)+.01

  ; The phase of the right channel is adjustable
  amodR osciliktp gkChoRate, gilfoshape, gkphs
  amodR = (((amodR*kChoDepth)+kChoDepth)*.5)+.01

  ; Remember that the length of the delay buffer defined will have to take account of the
  ; summed maximum of the static constant value and modulating delay time

  ; ;;Left channel
  ; delay;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Create a delay buffer of 1.2 seconds duration (equivalent to the maximum delay time
  ; possible using this example)
  abufferL delayr 1.2
  adelsigL deltap3 amodL  ; Tap the delay line at gkdlt seconds
  delayw gasig            ; Write audio source into the beginning of the buffer

  ; ;;Right channel
  ; delay;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Create a delay buffer of 1.2 seconds duration (equivalent to the maximum delay time
  ; possible using this example)
  abufferR delayr 1.2
  adelsigR deltap3 amodR  ; Tap the delay line at gkdlt seconds
  delayw gasig            ; Write audio source into the beginning of the buffer

  aL ntrpol gasig, adelsigL, gkmix  ; Create dry/wet mix
  aR ntrpol gasig, adelsigR, gkmix  ; Create dry/wet mix

  outs aL, aR  ; Create a mix between the wet and the dry signals at the output
  clear gasig  ; Clear the global audio send variable
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
 <width>400</width>
 <height>200</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#efefef</bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>520</width>
  <height>390</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Stereo Chorus</label>
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
  <objectName>b6571</objectName>
  <x>5</x>
  <y>5</y>
  <width>127</width>
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
  <objectName>Oscillator_Gain</objectName>
  <x>10</x>
  <y>53</y>
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
  <value>0.51400000</value>
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
  <thumbWidth>12</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>4</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>68</y>
  <width>120</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Oscillator Gain</label>
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
  <objectName>Oscillator_Gain</objectName>
  <x>450</x>
  <y>67</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.514</label>
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
  <x>523</x>
  <y>2</y>
  <width>330</width>
  <height>390</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Stereo Chorus</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>525</x>
  <y>36</y>
  <width>325</width>
  <height>351</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>------------------------------------------------------------------------------
Using the same basic algorithm as the flanger implementation a chorus effect is implemented.
A chorus effect uses the pitch bending effect of a modulating delay to create an imitation of an ensemble of voices from a single voice source sound.
Typically the delay time offset is larger than in a flanger implementation and a sine wave LFO (low frequency oscillator) shape is used in the delay time modulation.
This example uses independent LFOs on the left and right channels. The user can change the phase of the right hand side LFO (the left is permanently set at 0 radians).
Offsetting the phase of the right hand LFO creates a broad stereo effect. Giving it a value of 0 radians will render the effect monophonic.
If the Dry/Wet control is set at 100% wet, and the phase of right hand channel LFO is set at 0 radians then a simple vibrato effect results.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#414141</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Oscillator_Freq_Value</objectName>
  <x>450</x>
  <y>107</y>
  <width>60</width>
  <height>30</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>157.632</label>
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
  <x>10</x>
  <y>149</y>
  <width>120</width>
  <height>30</height>
  <uuid>{b57ba536-8f28-4986-9bf7-8eb84262d8ca}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Tone</label>
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
  <objectName>Oscillator_Freq</objectName>
  <x>10</x>
  <y>93</y>
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
  <value>0.41200000</value>
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
  <thumbWidth>12</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>4</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Chorus_Modulation_Rate</objectName>
  <x>10</x>
  <y>293</y>
  <width>500</width>
  <height>20</height>
  <uuid>{b7e7b8ab-140d-45bf-8c52-607bbf726f46}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00100000</minimum>
  <maximum>14.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.72894800</value>
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
  <thumbWidth>12</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>4</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Chorus_Modulation_Rate</objectName>
  <x>449</x>
  <y>307</y>
  <width>60</width>
  <height>30</height>
  <uuid>{cd171d26-552e-4958-b526-275d452ec385}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.729</label>
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
  <objectName>Mix</objectName>
  <x>450</x>
  <y>227</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5cd56315-4bac-452e-92eb-a031b288b36f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.658</label>
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
  <objectName>Mix</objectName>
  <x>10</x>
  <y>213</y>
  <width>500</width>
  <height>20</height>
  <uuid>{ac0fd134-af88-448c-8e28-0198f559ba34}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.65800000</value>
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
  <thumbWidth>12</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>4</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Right_Channel_Phase</objectName>
  <x>450</x>
  <y>347</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c14cc927-5ac1-4f6a-8181-6a50801accaa}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.606</label>
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
  <objectName>Right_Channel_Phase</objectName>
  <x>10</x>
  <y>333</y>
  <width>500</width>
  <height>20</height>
  <uuid>{432d4976-cb71-4373-943b-6378da54ddb5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.60600000</value>
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
  <thumbWidth>12</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>4</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Chorus_Modulation_Depth</objectName>
  <x>10</x>
  <y>253</y>
  <width>500</width>
  <height>20</height>
  <uuid>{3e2b62e8-f887-4073-8258-caac477a80b0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>0.05000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.04420000</value>
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
  <thumbWidth>12</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>4</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Chorus_Modulation_Depth</objectName>
  <x>450</x>
  <y>267</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5fdf1ae1-cf86-495a-b201-685173b6ff11}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.044</label>
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
  <objectName>Resonance</objectName>
  <x>10</x>
  <y>173</y>
  <width>500</width>
  <height>20</height>
  <uuid>{17b52b50-8667-43d1-9ae2-525b8b09c2aa}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.64400000</value>
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
  <thumbWidth>12</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>4</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Resonance</objectName>
  <x>450</x>
  <y>187</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7ef2c727-39e9-4eee-a8ea-81af0d36ba36}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.644</label>
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
  <objectName>Tone_Value</objectName>
  <x>450</x>
  <y>147</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5f670bb1-e411-4f17-94a3-2321fdf5742b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>1618.763</label>
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
  <objectName>Tone</objectName>
  <x>10</x>
  <y>133</y>
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
  <value>0.63600000</value>
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
  <thumbWidth>12</thumbWidth>
  <thumbPadding>2</thumbPadding>
  <thumbRadius>4</thumbRadius>
  <fillMode>thumb</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>108</y>
  <width>120</width>
  <height>30</height>
  <uuid>{aea841b2-29e6-42d6-ac23-02439b1cc47f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Oscillator Freq</label>
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
  <x>10</x>
  <y>188</y>
  <width>120</width>
  <height>30</height>
  <uuid>{cff238dd-67bf-4076-8ef0-fcd04a5518cb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Resonance</label>
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
  <x>10</x>
  <y>348</y>
  <width>180</width>
  <height>30</height>
  <uuid>{e5eead26-8354-4500-b09b-a328b60d5f7f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Right Channel Phase (radians)</label>
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
  <x>10</x>
  <y>228</y>
  <width>120</width>
  <height>30</height>
  <uuid>{13be73ea-e45f-492b-813b-41f0f6977e56}</uuid>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>268</y>
  <width>170</width>
  <height>30</height>
  <uuid>{88fb913a-baf9-46fb-b040-a557d8d2ba14}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Chorus Modulation Depth</label>
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
  <x>10</x>
  <y>308</y>
  <width>170</width>
  <height>30</height>
  <uuid>{248489be-7cec-478a-b2a4-5a1258803f06}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Chorus Modulation Rate</label>
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

; Written by Iain McCurdy, 2006

; The delay opcode is placed in a separate, always on, instrument from the source sound
; producing instrument.
; The is a commonly used technique with time smearing opcodes and effects like reverbs and
; delays.

; Ksmps may need to be low (and kr therefore high) when working with short delay times
; defined initially at krate

; Modified for QuteCsound by René, September 2010, updated Feb 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add table(s) for exp slider
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


giExp1 ftgen 0, 0, 129, -25, 0, 0.001, 128, 1.0  ; Table for exp slider


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


instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    gkingain invalue "Live_Input_Gain"
    kdlt     invalue "Delay_Time"
    gkdlt tablei kdlt, giExp1, 1
    outvalue "Delay_Time_Value", gkdlt               ; init 0.5
    gkmix      invalue "Mix"                         ; init 0.5
    gkfeedamt  invalue "Feedback_Ratio"              ; init 0.7
    gkamp      invalue "Output_Amplitude_Rescaling"  ; init 0.7
    gkporttime invalue "Portamento_Time"             ; init 0.3
    gkinput    invalue "Input"
  endif
endin

instr 1                 ; Plays file
  if gkinput == 0 then  ; If file input is selected...
    Sfile invalue "_Browse1"
    ; Generate 2 audio signals from a sound file (note the use of global variables)
    gasigL, gasigR FilePlay2 Sfile, 1, 0, 1
  else                         ; Otherwise
    asigL, asigR ins           ; Take input from computer's audio input
    gasigL = asigL * gkingain  ; Scale using 'input gain' slider
    gasigR = asigR * gkingain  ; Scale using 'input gain' slider
  endif                        ; End of conditional branching
endin

instr 2  ; Delay instrument
  ; Use of an envelope value that quickly ramps up from zero to 1. This prevents variables
  ; gliding to their required values each time the instrument is started.
  kporttime linseg 0, .001, 1, 1, 1
  kporttime = kporttime * gkporttime  ; Scale portamento function with FLTK slider value
  ; Portamento is applied to the variable 'gkdlt'. A new variable 'kdlt' is created.
  kdlt portk gkdlt, kporttime
  ; A new a-rate variable 'adlt' is created by interpolating the k-rate variable 'kdlt'
  adlt interp kdlt

  ; ;;Left channel
  ; delay;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Create a delay buffer of 5 seconds duration (equivalent to the maximum delay time
  ; possible using this example)
  abufferL delayr 1
  adelsigL deltap3 adlt  ; Tap the delay line at gkdlt seconds
  ; Write audio source and feedback signal into the beginning of the buffer
  delayw gasigL + (adelsigL * gkfeedamt)

  ; ;;Right channel
  ; delay;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Create a delay buffer of 5 seconds duration (equivalent to the maximum delay time
  ; possible using this example)
  abufferR delayr 1
  adelsigR deltap3 adlt  ; Tap the delay line at gkdlt seconds
  ; Write audio source and feedback signal into the beginning of the buffer
  delayw gasigR + (adelsigR * gkfeedamt)

  aL ntrpol gasigL, adelsigL, gkmix
  aR ntrpol gasigR, adelsigR, gkmix

  ; Create a mix between the wet and the dry signals at the output
  outs aL * gkamp, aR * gkamp
  clear gasigL, gasigR  ; Clear the global audio send variables
endin
</CsInstruments>
<CsScore>
; Instr | start | duration
i 10 0 3600  ; GUI
i 2 0 3600   ; Instrument 2 plays for one hour
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>804</width>
 <height>488</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#efefef</bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>514</width>
  <height>436</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Delay with feedback</label>
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
  <objectName>b123</objectName>
  <x>5</x>
  <y>5</y>
  <width>100</width>
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
  <objectName>Live_Input_Gain</objectName>
  <x>10</x>
  <y>51</y>
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
  <value>0.28600000</value>
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
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>65</y>
  <width>120</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Live input Gain</label>
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
  <objectName>Live_Input_Gain</objectName>
  <x>450</x>
  <y>65</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.286</label>
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
  <x>517</x>
  <y>2</y>
  <width>274</width>
  <height>436</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Delay with feedback</label>
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
  <x>519</x>
  <y>38</y>
  <width>268</width>
  <height>382</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>---------------------------------------------------------------
This example adds a feedback loop. Some of the audio signal present at the delay tap is fed back into the input of the delay buffer.
The amount of signal fed back is controlled by the 'Feedback Ratio' slider. A value of zero represents 0% of the signal being fed back and a value of 1 represents 100% of the signal being fed value.
Negative values are also allowed and represent the signal being inverted as it is fed back.
The audible effect of this is most evident when working with very short delay times.
In this example the user can choose between a sound file as input or the computer's live input.
A gain control is provided to control the gain of the live input.</label>
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
  <objectName>Delay_Time_Value</objectName>
  <x>449</x>
  <y>115</y>
  <width>60</width>
  <height>30</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.026</label>
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
  <y>115</y>
  <width>120</width>
  <height>30</height>
  <uuid>{b57ba536-8f28-4986-9bf7-8eb84262d8ca}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Delay Time (sec)</label>
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
  <objectName>Delay_Time</objectName>
  <x>9</x>
  <y>101</y>
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
  <value>0.47200000</value>
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
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Input</objectName>
  <x>179</x>
  <y>343</y>
  <width>120</width>
  <height>30</height>
  <uuid>{9b81a1f2-bcb8-4582-925b-9ae56def3865}</uuid>
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
    <name> Live Input</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>97</x>
  <y>343</y>
  <width>80</width>
  <height>30</height>
  <uuid>{62eeb695-9b83-42da-81cd-8000c232d9b9}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Input</label>
  <alignment>right</alignment>
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
  <objectName>Output_Amplitude_Rescaling</objectName>
  <x>9</x>
  <y>248</y>
  <width>500</width>
  <height>20</height>
  <uuid>{b7e7b8ab-140d-45bf-8c52-607bbf726f46}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.71400000</value>
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
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>262</y>
  <width>160</width>
  <height>30</height>
  <uuid>{92773515-22ba-4f64-b658-78264fc33aba}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Output Amplitude Rescaling</label>
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
  <objectName>Output_Amplitude_Rescaling</objectName>
  <x>449</x>
  <y>262</y>
  <width>60</width>
  <height>30</height>
  <uuid>{cd171d26-552e-4958-b526-275d452ec385}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.714</label>
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
  <x>449</x>
  <y>162</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5cd56315-4bac-452e-92eb-a031b288b36f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.558</label>
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
  <y>162</y>
  <width>120</width>
  <height>30</height>
  <uuid>{e2cef5dc-8935-405f-98da-e8a167a68d8a}</uuid>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Mix</objectName>
  <x>9</x>
  <y>148</y>
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
  <value>0.55800000</value>
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
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Portamento_Time</objectName>
  <x>449</x>
  <y>309</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c14cc927-5ac1-4f6a-8181-6a50801accaa}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.848</label>
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
  <y>309</y>
  <width>120</width>
  <height>30</height>
  <uuid>{f4b96abf-8cf5-4456-a057-6b785e9c4b8d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Portamento Time</label>
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
  <objectName>Portamento_Time</objectName>
  <x>9</x>
  <y>295</y>
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
  <maximum>2.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.84800000</value>
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
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Feedback_Ratio</objectName>
  <x>9</x>
  <y>197</y>
  <width>500</width>
  <height>20</height>
  <uuid>{3e2b62e8-f887-4073-8258-caac477a80b0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.67200000</value>
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
  <thumbPadding>0</thumbPadding>
  <thumbRadius>2</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>211</y>
  <width>120</width>
  <height>30</height>
  <uuid>{41296e1f-c3d7-4fef-83aa-c850d5b4e198}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Feedback Ratio</label>
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
  <objectName>Feedback_Ratio</objectName>
  <x>449</x>
  <y>211</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5fdf1ae1-cf86-495a-b201-685173b6ff11}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.672</label>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse1</objectName>
  <x>6</x>
  <y>383</y>
  <width>170</width>
  <height>30</height>
  <uuid>{0534c3c0-4141-44e5-aad5-62b492a96265}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>808loop.wav</stringvalue>
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
  <x>178</x>
  <y>384</y>
  <width>330</width>
  <height>28</height>
  <uuid>{73d2df26-e1ac-47b8-89c0-4d641c4dcf5f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>808loop.wav</label>
  <instant>true</instant>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>#202020</color>
  <bgcolor mode="nobackground">#efebe7</bgcolor>
  <background>nobackground</background>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>178</x>
  <y>410</y>
  <width>330</width>
  <height>30</height>
  <uuid>{a63909ac-6fa4-41c8-a84b-ba08e76132ab}</uuid>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

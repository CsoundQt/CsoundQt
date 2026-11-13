; Written by Iain McCurdy, 2006

; Modified for QuteCsound by René, September 2010, updated Feb 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add table(s) for exp slider
; Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files


<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 2      ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum sound intensity level regardless of bit depth


gitri  ftgen 0, 0, 131072, 7, 0, 65536, 1, 65536, 0  ; Positive domain triangle wave
giExp1 ftgen 0, 0, 129, -25, 0, 0.0001, 128, 1.0     ; Table for exp slider

outvalue "onoff", 0


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
    outvalue "Delay_Time_Value", gkdlt               ; init 0.0001
    gkmix      invalue "Mix"                         ; init 0.5
    gkfeedamt  invalue "Feedback_Amount"             ; init 0.0
    gkamp      invalue "Output_Amplitude_Rescaling"  ; init 0.7
    gkFlaDepth invalue "Flanger_Modulation_Depth"    ; init 0.005
    gkFlaRate  invalue "Flanger_Modulation_Rate"     ; init 0.05
    gkinput    invalue "Input"
    gkmode     invalue "Mode"

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

instr 2           ; Flanger-delay instrument
  iporttime = .1  ; Portamento time
  ; Use of an envelope value that quickly ramps up from zeron to the required value
  ; prevents variables gliding to their required values each time the instrument is
  ; started
  kporttime linseg 0, .001, iporttime, 1, iporttime
  ; Portamento is applied to the variable 'gkdlt'. A new variable 'kdlt' is created.
  kdlt portk gkdlt, kporttime
  ; A new a-rate variable 'adlt' is created by interpolating the k-rate variable 'kdlt'
  adlt interp kdlt

  ; Oscillator that makes use of the positive domain only triangle wave in function table
  ; 1
  amod oscil gkFlaDepth, gkFlaRate, gitri

  adlt sum adlt, amod  ; Static delay time and modulating delay time are summed
  ; Remember that the length of the delay buffer defined will have to take account of the
  ; summed maximum of the static delay time and modulating delay time

  ; ;;Left channel
  ; delay;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Create a delay buffer of 1.2 seconds duration (equivalent to the maximum delay time
  ; possible using this example)
  abufferL delayr 1.2
  adelsigL deltap3 adlt  ; Tap the delay line at gkdlt seconds
  ; Write audio source and feedback signal into the beginning of the buffer
  delayw gasigL + (adelsigL*gkfeedamt)

  ; ;;Right channel
  ; delay;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Create a delay buffer of 1.2 seconds duration (equivalent to the maximum delay time
  ; possible using this example)
  abufferR delayr 1.2
  adelsigR deltap3 adlt  ; Tap the delay line at gkdlt seconds
  ; Write audio source and feedback signal into the beginning of the buffer
  delayw gasigR + (adelsigR*gkfeedamt)

  aL ntrpol gasigL, -adelsigL, gkmix  ; Create dry/wet mix
  aR ntrpol gasigR, -adelsigR, gkmix  ; Create dry/wet mix

  ; Create a mix between the wet and the dry signals at the output
  outs aL * gkamp, aR * gkamp
  clear gasigL, gasigR  ; Clear the global audio send variables
endin
</CsInstruments>
<CsScore>
; Instr | start | duration
i 10 0 -1  ; GUI
i 2 0 -1   ; Instrument 2 plays a held note

f 0 3600  ; 'Dummy' score event keeps realtime performance going for 1 hour
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
  <width>513</width>
  <height>460</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>    Through Zero Flanger Implementation</label>
  <alignment>right</alignment>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Live_Input_Gain</objectName>
  <x>8</x>
  <y>50</y>
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
  <value>0.59200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#dfdfdf</bgcolor>
  <foreground>#0d78dc</foreground>
  <fillcolor>#9cdcff</fillcolor>
  <bordercolor>#68b4dc</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>64</y>
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
  <x>251</x>
  <y>50</y>
  <width>50</width>
  <height>20</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.592</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <format/>
  <padding>5</padding>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>516</x>
  <y>2</y>
  <width>329</width>
  <height>460</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Through Zero Flanger Implementation</label>
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
  <x>521</x>
  <y>41</y>
  <width>320</width>
  <height>417</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>---------------------------------------------------------------------
This example is very similar to the previous flanger example but with two modifications made to implement what is referred to as a 'through the zero' flanger.
At the minimum point of its modulation, when the time difference between the dry signal and the delayed signal is zero, the sound is completely cancelled out by the flanger.
In order for this to happen the delayed signal must also be inverted.
Delay opcodes will not allow setting a delay time of zero so the way round this is to delay the dry signal by an amount of time equal to the minimum delay time of the flanger modulations.
For the through the zero flanger cancelling effect to work feedback should be kept at zero.
In this example the user can choose between a sound file as input or the computer's live input.
A gain control is provided to control the gain of the live input.</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>107</y>
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
  <x>8</x>
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
  <value>0.14000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#dfdfdf</bgcolor>
  <foreground>#0d78dc</foreground>
  <fillcolor>#9cdcff</fillcolor>
  <bordercolor>#68b4dc</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Input</objectName>
  <x>176</x>
  <y>360</y>
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
  <x>94</x>
  <y>360</y>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Output_Amplitude_Rescaling</objectName>
  <x>8</x>
  <y>222</y>
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
  <value>0.62800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#dfdfdf</bgcolor>
  <foreground>#0d78dc</foreground>
  <fillcolor>#9cdcff</fillcolor>
  <bordercolor>#68b4dc</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>236</y>
  <width>180</width>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>150</y>
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
  <x>8</x>
  <y>136</y>
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
  <value>0.63800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#dfdfdf</bgcolor>
  <foreground>#0d78dc</foreground>
  <fillcolor>#9cdcff</fillcolor>
  <bordercolor>#68b4dc</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>279</y>
  <width>180</width>
  <height>30</height>
  <uuid>{f4b96abf-8cf5-4456-a057-6b785e9c4b8d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Flanger Modulation Depth (sec)</label>
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
  <objectName>Flanger_Modulation_Depth</objectName>
  <x>8</x>
  <y>265</y>
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
  <maximum>0.01000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.00836000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#dfdfdf</bgcolor>
  <foreground>#0d78dc</foreground>
  <fillcolor>#9cdcff</fillcolor>
  <bordercolor>#68b4dc</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Feedback_Amount</objectName>
  <x>8</x>
  <y>179</y>
  <width>500</width>
  <height>20</height>
  <uuid>{3e2b62e8-f887-4073-8258-caac477a80b0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-0.99000000</minimum>
  <maximum>0.99000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.72072000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#dfdfdf</bgcolor>
  <foreground>#0d78dc</foreground>
  <fillcolor>#9cdcff</fillcolor>
  <bordercolor>#68b4dc</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>193</y>
  <width>120</width>
  <height>30</height>
  <uuid>{41296e1f-c3d7-4fef-83aa-c850d5b4e198}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Feedback Amount</label>
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
  <x>8</x>
  <y>322</y>
  <width>180</width>
  <height>30</height>
  <uuid>{5bd7d99f-d95b-4a22-9761-42252820286b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Flanger Modulation Rate (hz)</label>
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
  <objectName>Flanger_Modulation_Rate</objectName>
  <x>8</x>
  <y>308</y>
  <width>500</width>
  <height>20</height>
  <uuid>{25c8b61d-77ce-4cdd-97e2-44086cffb042}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>0.17200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#dfdfdf</bgcolor>
  <foreground>#0d78dc</foreground>
  <fillcolor>#9cdcff</fillcolor>
  <bordercolor>#68b4dc</bordercolor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
  <thumbWidth>4</thumbWidth>
  <thumbPadding>0</thumbPadding>
  <thumbRadius>0</thumbRadius>
  <fillMode>fill</fillMode>
  <backgroundMode>jump</backgroundMode>
  <rulermode>hide</rulermode>
  <rulerscale>linear</rulerscale>
  <rulercolor>#aebcd2</rulercolor>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse1</objectName>
  <x>8</x>
  <y>403</y>
  <width>166</width>
  <height>30</height>
  <uuid>{9d013036-66ec-454c-a4a6-f080b6d2cf04}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>loop.wav</stringvalue>
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
  <x>176</x>
  <y>404</y>
  <width>330</width>
  <height>28</height>
  <uuid>{f91c734f-d0b2-4a22-86a6-a310114f10f5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>loop.wav</label>
  <instant>true</instant>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <precision>3</precision>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e5e5e5</bgcolor>
  <background>nobackground</background>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>176</x>
  <y>432</y>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>onoff</objectName>
  <x>10</x>
  <y>10</y>
  <width>115</width>
  <height>26</height>
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
  <font>Liberation Sans</font>
  <flatStyle>true</flatStyle>
  <color>#cbceff</color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Delay_Time_Value</objectName>
  <x>252</x>
  <y>93</y>
  <width>50</width>
  <height>20</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.000</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <format/>
  <padding>5</padding>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Output_Amplitude_Rescaling</objectName>
  <x>252</x>
  <y>222</y>
  <width>50</width>
  <height>20</height>
  <uuid>{cd171d26-552e-4958-b526-275d452ec385}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.628</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <format/>
  <padding>5</padding>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Mix</objectName>
  <x>252</x>
  <y>136</y>
  <width>50</width>
  <height>20</height>
  <uuid>{5cd56315-4bac-452e-92eb-a031b288b36f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.638</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <format/>
  <padding>5</padding>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Flanger_Modulation_Depth</objectName>
  <x>252</x>
  <y>265</y>
  <width>50</width>
  <height>20</height>
  <uuid>{c14cc927-5ac1-4f6a-8181-6a50801accaa}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.008</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <format/>
  <padding>5</padding>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Feedback_Amount</objectName>
  <x>252</x>
  <y>179</y>
  <width>50</width>
  <height>20</height>
  <uuid>{5fdf1ae1-cf86-495a-b201-685173b6ff11}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.721</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <format/>
  <padding>5</padding>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Flanger_Modulation_Rate</objectName>
  <x>252</x>
  <y>307</y>
  <width>50</width>
  <height>20</height>
  <uuid>{a0bed878-0b29-4c88-b71f-5f3d2d4fb83d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.172</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <format/>
  <padding>5</padding>
  <color>#202020</color>
  <bgcolor mode="nobackground">#e0e0e0</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

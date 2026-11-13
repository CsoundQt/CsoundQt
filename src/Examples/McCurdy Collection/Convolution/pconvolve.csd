; Written by Iain McCurdy, 2009
; Modified for QuteCsound by René, September 2010
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 815

; Notes on modifications from original csd:
; Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files


; my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 128    ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum sound intensity level regardless of bit depth


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

    gkGain invalue "Gain"  ; init 0.7
    gkMix  invalue "Mix"   ; init 0.17

    gkinput invalue "Input"
    gkfile  invalue "File"
  endif
endin

instr 1  ; Generate input audio independently of reverberating instrument
  kon invalue "on"

  if gkinput = 0 then  ; If 'sound file' is selected...
    Sfile invalue "_Browse1"
    gaL, gaR FilePlay2 Sfile, 1, 0, 1  ; Read audio from sound file on hard disc
  elseif gkinput = 1 then              ; If 'live input' is selected
    gaL inch 1                         ; Read audio from sound card's first (left) input
    ; Mono input therefore assign right channel to left channel also
    gaR = gaL
  endif
  gaL = gaL *kon
  gaR = gaR *kon
endin

instr 2  ; Convolution reverb instrument


  Sir invalue "_Browse2"
  ; Generate a momentary '1' pulse in output 'kswitch' if any of the scanned input
  ; variables change. (output 'kswitch' is normally zero)
  kSwitch = changed(gkfile) + changed(Sir)
  if kSwitch = 1 then  ; If i-rate variable is changed...
    ; Begin a reinitialisation pass in order to effect this change. Begin this pass at
    ; label entitled 'update' and continue until rireturn opcode
    reinit UPDATE
  endif               ; End of conditional branching
UPDATE:               ; Label
  if gkfile = 0 then  ; If 'stairwell' is chosen as convolution file...
    ; Perform convolution between audio input from instr 1 and soundfile stored on disk
    ; (left channel)
    ar1 pconvolve gaL, "StairwellL.wav"
    ; Perform convolution between audio input from instr 1 and soundfile stored on disk
    ; (right channel)
    ar2 pconvolve gaR, "StairwellR.wav"
  elseif gkfile = 1 then  ; If 'dish' is chosen as convolution file...
    ; Perform convolution between audio input from instr 1 and soundfile stored on disk
    ; (left channel)
    ar1 pconvolve gaL, "dishL.wav"
    ; Perform convolution between audio input from instr 1 and soundfile stored on disk
    ; (right channel)
    ar2 pconvolve gaR, "dishR.wav"
  elseif gkfile == 2 then
    ar1 pconvolve gaL, Sir, 0, 1
    ar2 pconvolve gaR, Sir, 0, 1
  endif                          ; End of conditional branching
  aL ntrpol gaL, ar1*0.1, gkMix  ; Create dry/wet mix (left channel)
  aR ntrpol gaR, ar2*0.1, gkMix  ; Create dry/wet mix (right channel)
  outs aL*gkGain, aR*gkGain      ; Send audio to outputs
  gaL = 0                        ; Clear global audio signal from instr 1 (left channel)
  gaR = 0                        ; Clear global audio signal from instr 1 (right channel)
endin
</CsInstruments>
<CsScore>
i 10 0 3600  ; GUI
i 1 0 3600   ; Instrument 1 (source instrument) runs for 1
; Instrument 2 (convolution instrument) runs for 1 hour (and keeps real-time performance
; going)
i 2 0 3600
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>235</x>
 <y>68</y>
 <width>967</width>
 <height>327</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#efefef</bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>525</width>
  <height>325</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>pconvolve</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="background">#f4f8c8</bgcolor>
  <bordercolor>#9e9e9e</bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>on</objectName>
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
  <type>value</type>
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
  <x>13</x>
  <y>58</y>
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
  <value>0.38800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f3f3f3</bgcolor>
  <foreground>#7a7a7a</foreground>
  <fillcolor>#d4eaff</fillcolor>
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
  <x>13</x>
  <y>75</y>
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
  <x>432</x>
  <y>75</y>
  <width>80</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.388</label>
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
  <x>528</x>
  <y>2</y>
  <width>439</width>
  <height>323</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>pconvolve</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#202020</color>
  <bgcolor mode="background">#f4f8c8</bgcolor>
  <bordercolor>#9e9e9e</bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>528</x>
  <y>16</y>
  <width>433</width>
  <height>300</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>----------------------------------------------------------------------------------------------------------------------------------------
pconvolve offers a computationally efficient method for performing convolution and is therefore ideally suited for real-time convolution reverbs. The input file for the convolution impulse is a sound file and is typically a short recording of the reverberant tail of of a sharp loud sound, sounding in the space.
The sounds used in these recordings is often a starting pistol or a balloon bursting. The aim is that all frequencies are present in the initial inpulse sound. For more accurate convolution a sine sweep is used but in this case further decoding is needed before the recording can be used. If too long an impulse sound is used the opcode will struggle to run in real-time as convolution is fundementally a computationally expensive procedure. Two user controls are included, 'Dry/Wet Mix' and 'Output Gain' (both dry and wet signals). There is no reason why the impulse file has to be that of a reverberant space. One of the options for 'Convolution File' in this example is a glass dish. Other possibilities might be vintage amplifiers and microphones.</label>
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
  <objectName>Mix</objectName>
  <x>433</x>
  <y>114</y>
  <width>80</width>
  <height>30</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.822</label>
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
  <x>12</x>
  <y>113</y>
  <width>100</width>
  <height>30</height>
  <uuid>{b57ba536-8f28-4986-9bf7-8eb84262d8ca}</uuid>
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
  <x>12</x>
  <y>96</y>
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
  <value>0.82200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
  <flatStyle>true</flatStyle>
  <bgcolor>#f3f3f3</bgcolor>
  <foreground>#7a7a7a</foreground>
  <fillcolor>#ffdeea</fillcolor>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Input</objectName>
  <x>93</x>
  <y>166</y>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>File</objectName>
  <x>365</x>
  <y>166</y>
  <width>120</width>
  <height>30</height>
  <uuid>{4f12eb6a-c071-4199-8bad-bfe11a917032}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Stairwell</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Dish</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>File</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
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
  <x>12</x>
  <y>166</y>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>264</x>
  <y>166</y>
  <width>100</width>
  <height>30</height>
  <uuid>{f0042687-944f-4ab5-a258-074f2aca5510}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Convolution file</label>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse1</objectName>
  <x>6</x>
  <y>218</y>
  <width>170</width>
  <height>30</height>
  <uuid>{83beaac6-3457-44f5-befb-b2f51175fa55}</uuid>
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
  <x>177</x>
  <y>219</y>
  <width>330</width>
  <height>28</height>
  <uuid>{b2716d73-fb2d-45af-8ce0-404d5e48d00d}</uuid>
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
  <bgcolor mode="nobackground">#cecece</bgcolor>
  <background>nobackground</background>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>177</x>
  <y>246</y>
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
  <objectName>_Browse2</objectName>
  <x>7</x>
  <y>278</y>
  <width>170</width>
  <height>30</height>
  <uuid>{181e4355-4514-4f64-90ad-846857e32fc3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>StairwellL.wav</stringvalue>
  <text>Browse IR File</text>
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
  <objectName>_Browse2</objectName>
  <x>178</x>
  <y>279</y>
  <width>330</width>
  <height>28</height>
  <uuid>{c8be82af-1985-49e4-ba13-2927447697c6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>StairwellL.wav</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

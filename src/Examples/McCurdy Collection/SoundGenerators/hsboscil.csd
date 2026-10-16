; Written by Iain McCurdy, 2009


; Modified for QuteCsound by René, April 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Use QuteCsound internal midi interface for Brightness (Channel 1, CC#1)
; Removed instr 2


; my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 64     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum sound intensity level regardless of bit depth


giwfn   ftgen 0, 0, 131072, 10, 1                ; A sine wave
gioctfn ftgen 0, 0, 1024, -19, 1, 0.5, 270, 0.5  ; A hanning-type window


instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    gkoctcnt   invalue "BlendRange"
    gkShepFreq invalue "Rate"
    gkamp      invalue "Amplitude"
    gktone     invalue "Tone"
    gkbrite    invalue "Brightness"
    gkbasfreq  invalue "Frequency"
    gkphs      invalue "Phase"
    gkMIDI     invalue "MIDI"
  endif
endin

instr 1                ; MIDI activated hsboscil instrument
  if gkMIDI != 1 then  ; If switch bank is *not* 1 then...
    turnoff            ; Turn this instrument off
  endif                ; End of conditional branching

  iporttime = 0.1  ; Portamento time (constant)
  ; Portamento time (an envelope function that ramps up from zero)
  kporttime linseg 0, 0.001, iporttime, 1, iporttime
  kamp   portk gkamp, kporttime    ; Apply portamento
  kbrite portk gkbrite, kporttime  ; Apply portamento
  ktone  portk gktone, kporttime   ; Apply portamento
  ibasfreq cpsmidi                 ; Read MIDI note values (in hertz/cps) from MIDI input

  outvalue "Frequency", ibasfreq  ; Send MIDI note values to 'base frequency' slider

  ; Generate a momentary '1' pulse in output 'kswitch' if any of the scanned input
  ; variables change. (output 'kswitch' is normally zero)
  kSwitch changed gkoctcnt, gkphs
  if kSwitch = 1 then
    reinit START
  endif
START:
  ; CREATE AN hsboscil TONE
  ares hsboscil kamp, ktone, kbrite, ibasfreq, giwfn, gioctfn, i(gkoctcnt), i(gkphs)
  rireturn
  ; Create a basic envelope to prevent clicks at the start and ends of notes
  aenv linsegr 0, 0.01, 1, 3600, 1, 0.01, 0
  outs ares*aenv, ares*aenv  ; Send audio to outputs, apply envelope
endin

instr 3            ; Hsboscil instrument - slider controls base frequency
  iporttime = 0.1  ; Portamento time (constant)
  ; Portamento time (an envelope function that ramps up from zero)
  kporttime linseg 0, 0.001, iporttime, 1, iporttime
  kamp   portk gkamp, kporttime    ; Apply portamento
  kbrite portk gkbrite, kporttime  ; Apply portamento
  ktone  portk gktone, kporttime   ; Apply portamento
  ; Create a basic envelope to prevent clicks at the start and ends of notes
  aenv linsegr 0, 0.001, 1, 3600, 1, 0.01, 0
  ; Generate a momentary '1' pulse in output 'kswitch' if any of the scanned input
  ; variables change. (output 'kswitch' is normally zero)
  kSwitch changed gkbasfreq, gkoctcnt, gkphs

  if kSwitch = 1 then
    reinit START
  endif
START:
  ; CREATE AN hsboscil TONE
  ares hsboscil kamp, ktone, kbrite, i(gkbasfreq), giwfn, gioctfn, i(gkoctcnt), i(gkphs)
  rireturn
  outs ares*aenv, ares*aenv  ; Send audio to outputs, apply envelope
endin

instr 4            ; Hsboscil instrument - shepard glissando
  iporttime = 0.1  ; Portamento time (constant)
  ; Portamento time (an envelope function that ramps up from zero)
  kporttime linseg 0, 0.001, iporttime, 1, iporttime
  kamp   portk gkamp, kporttime    ; Apply portamento
  kbrite portk gkbrite, kporttime  ; Apply portamento
  ; Create a moving phase value that will be used to modulate 'tone' parameter
  ktone phasor gkShepFreq

  ktrigger metro 10  ; Create a metronic pulse of '1' values. 50 per second
  if ktrigger == 1 then
    outvalue "Tone", ktone  ; Update 'tone; slider (this will be for visual feedback only)
  endif

  ; Create a basic envelope to prevent clicks at the start and ends of notes
  aenv linsegr 0, 0.001, 1, 3600, 1, 0.01, 0
  ; Generate a momentary '1' pulse in output 'kswitch' if any of the scanned input
  ; variables change. (output 'kswitch' is normally zero)
  kSwitch changed gkbasfreq, gkoctcnt, gkphs
  if kSwitch = 1 then
    reinit START
  endif
START:
  ; CREATE AN hsboscil TONE
  ares hsboscil kamp, ktone, kbrite, i(gkbasfreq), giwfn, gioctfn, i(gkoctcnt), i(gkphs)
  rireturn
  outs ares * aenv, ares * aenv  ; Send audio to outputs, apply envelope
endin
</CsInstruments>
<CsScore>
; Instr | start | duration
i 10 0.0 3600  ; GUI
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>617</x>
 <y>275</y>
 <width>1062</width>
 <height>405</height>
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
  <width>512</width>
  <height>400</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>hsboscil</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <y>129</y>
  <width>160</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Shepard Glissando Rate (Hz)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Rate</objectName>
  <x>448</x>
  <y>129</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.100</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>517</x>
  <y>2</y>
  <width>540</width>
  <height>400</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>hsboscil</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <x>522</x>
  <y>17</y>
  <width>533</width>
  <height>381</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>----------------------------------------------------------------------------------------------------------------------------------
hsboscil generates a tone composed of partials derived from a stack of octaves. 'Brightness' (gkbrite) controls the weighting of these partials: negative values favouring lower partials, positive values favouring higher partials. 'Blending Range' (ioctcnt) defines the number of partials in the tone. 'Tone' shifts partials up or down in parallel. At the same time the entire spectrum is enveloped according to a windowing function created in a function table. The range of this spectral window is dependent upon the value given for 'Blending Range'. If 'Tone' is modulated such that partials disappear beyond the edge of spectral window they are replaced by new partials at the opposite edge of the window. It is this behaviour that allows us to create the Shepard glissando effect in which a tone appears to simultaneously be constantly rising (or falling) but never actually get any higher (lower) in pitch. A visual analogue is that of the spinning barber-pole. hsboscil's octave spaced partials tends to produce organ-like tones. This example offers three methods of activating hsboscil. Firstly, via MIDI (in which case 'Base Frequency' is determined by the MIDI note number with the 'Base Frequency' slider becoming inoperative). Secondly, without MIDI (slider becomes operative again) and thirdly, a method which produces the Shepard glissando effect by modulating the 'Tone' control using an LFO. In the original Roger Shepard experiment the tones moved stepwise. Jean-Claude Risset introduced the idea of the tone moving smoothly leading to the name Shepard Glissando or Shepard-Risset Glissando. In MIDI mode the modulation wheel can be used to control 'Brightness' This opcode was written by Peter Neubacker who is also the author of the Melodyne software.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Rate</objectName>
  <x>8</x>
  <y>113</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2a8dc6e2-12f4-443d-af9b-59e4373cc24b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-1.00000000</minimum>
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
  <y>167</y>
  <width>150</width>
  <height>30</height>
  <uuid>{4fa545c6-e2f1-4387-8c9f-4a9dd388bb42}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Amplitude</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>167</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b0ad1916-b43e-44c2-be40-bca29f5cb1f4}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.342</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>151</y>
  <width>500</width>
  <height>27</height>
  <uuid>{9069e547-5638-4568-896f-980087c61de0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.34200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>284</x>
  <y>66</y>
  <width>169</width>
  <height>31</height>
  <uuid>{ada34c8d-83fe-4eae-b207-ac7e38c5251f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Blending Range (octaves) :</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>BlendRange</objectName>
  <x>455</x>
  <y>63</y>
  <width>50</width>
  <height>30</height>
  <uuid>{c37974b7-7a24-481d-8f02-a116324085e3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <resolution>1.00000000</resolution>
  <minimum>2</minimum>
  <maximum>10</maximum>
  <randomizable group="0">false</randomizable>
  <value>10</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>81</y>
  <width>180</width>
  <height>31</height>
  <uuid>{db9a7e63-ac06-40ee-b161-3012d7172005}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Shepard Glissando On / Off :</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b9624</objectName>
  <x>163</x>
  <y>85</y>
  <width>16</width>
  <height>16</height>
  <uuid>{326c4e41-c09d-41ac-98ea-9f603e424058}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 4 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
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
  <y>205</y>
  <width>150</width>
  <height>30</height>
  <uuid>{7db371e5-4bd3-46a9-a5e3-0aea92940a6a}</uuid>
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
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Tone</objectName>
  <x>448</x>
  <y>205</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2696e0c6-d92a-4577-9f7a-aef424e70a55}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.070</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Tone</objectName>
  <x>8</x>
  <y>189</y>
  <width>500</width>
  <height>27</height>
  <uuid>{c22c8f1f-06e2-4f93-90ef-76b20501e47f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.07002266</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>243</y>
  <width>150</width>
  <height>30</height>
  <uuid>{915965e7-61fd-429c-806c-afc107c02f1d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Brightness (CC#1)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Brightness</objectName>
  <x>448</x>
  <y>243</y>
  <width>60</width>
  <height>30</height>
  <uuid>{014166d8-823b-481c-b928-22acb9f85eab}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.000</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Brightness</objectName>
  <x>8</x>
  <y>227</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2b177c6b-fa1d-4592-845b-18e86d7a09f5}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>1</midichan>
  <midicc>1</midicc>
  <description/>
  <minimum>-7.00000000</minimum>
  <maximum>7.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>281</y>
  <width>150</width>
  <height>30</height>
  <uuid>{53bda1d9-5ee4-4ca6-a933-8a57351bde90}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Base Frequency (i-rate)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Frequency</objectName>
  <x>448</x>
  <y>281</y>
  <width>60</width>
  <height>30</height>
  <uuid>{6c54c71b-4092-4ae4-b3e5-8e48e0af32e1}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>146.828</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Frequency</objectName>
  <x>8</x>
  <y>265</y>
  <width>500</width>
  <height>27</height>
  <uuid>{11ece0ea-35e7-49e1-a8aa-1cf50108d494}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>20.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <value>146.82824707</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>319</y>
  <width>150</width>
  <height>30</height>
  <uuid>{8d94e0bf-d464-4f28-94b3-5883e7fd35a6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Initial Phase (i-rate)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Phase</objectName>
  <x>448</x>
  <y>319</y>
  <width>60</width>
  <height>30</height>
  <uuid>{546ac0d3-b04a-4c3d-be2d-5705a566e35b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.000</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Phase</objectName>
  <x>8</x>
  <y>303</y>
  <width>500</width>
  <height>27</height>
  <uuid>{075b6c1e-5c9b-4eb9-b058-2bf90b0e7ec8}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-1.00000000</minimum>
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
  <y>52</y>
  <width>180</width>
  <height>31</height>
  <uuid>{01f32bee-68b9-4ae4-9aef-1b14ea5ea216}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>HSBOSCIL Instr  On / Off :</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b9275</objectName>
  <x>163</x>
  <y>56</y>
  <width>16</width>
  <height>16</height>
  <uuid>{fac603b4-992a-4c52-9a5d-3dc031298ac1}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine>i 3 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
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
  <y>21</y>
  <width>180</width>
  <height>31</height>
  <uuid>{afe5727a-7833-4d95-a7fd-c8b2532b7d32}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>MIDI Instr  On / Off :</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>MIDI</objectName>
  <x>163</x>
  <y>25</y>
  <width>16</width>
  <height>16</height>
  <uuid>{feed3f3d-9dca-4f34-af94-60de6864a835}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

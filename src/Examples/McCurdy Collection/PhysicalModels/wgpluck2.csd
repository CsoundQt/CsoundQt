; Written by Iain McCurdy, 2006

; Demonstration of the wgpluck2 opcode which is an implementation of the karplus-strong
; physical model of a plucked string.
; It uses simple mathematical principles and an in-built delay line to imitate the sound
; of a string being plucked.
; The 'virtual bass' vst instrument that comes with cubase is based on this algorithm

; Taking an electric guitar or bass guitar as its cue this opcode offers input parameters
; for:

; Iplk - the position along the string's length at which it is plucked
; Values for iplk should be greater that 0 and less than 1
; 0 = The string being plucked at the nut (neck), 1 = the string being plucked at the
; bridge
; In actuality values of 0 and 1 will produce silence
; Values close to zero or close to 1 will produce a thin, hard sound (plucked near the
; neck end or near the bridge)
; A value of .5 will produce a soft flutey sound (string plucked halfway along its length,
; i.e. 12th fret)
; If you've a guitar or any stringed instrument handy, try it out.

; Kpick - location of the pick-up underneath the vibrating string
; Again values greater than 0 and less than 1 are expected here,
; 0 Meaning the pick-up is under the nut (neck end), 1 meaning it is under the bridge, .5
; meaning under the 12th fret for an open string
; Similar spectral results apply regarding whether the pick-up is close to the bridge or
; halfway alon the string and so on...
; This parameter can be varied at k-rate - i.e. The pick-up can move during a note!
; Moving the pick-up during a note causes a 'flanging' effect

; Krefl - coefficient of reflection, i.e. Amount of damping of the string at the bridge
; Imagine damping the string with the heel of your hand while plucking a string.
; Once again values should be greater than 0 and less than 1, don't actually use 0 or 1
; A value close to zero represents very little damping
; A value close to 1 represents a lot of damping
; When using large amounts of damping the sounding pitch of the plucked string can drop
; slightly

; Other opcodes that are also based on the same karplus-strong plucked string algorithm
; are pluck and wgpluck

; The pluck opcode also includes some physically modelled drum sounds that were used by
; some antique drum machines


; Modified for QuteCsound by René, March 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817


; Notes on modifications from original csd:
; Add tables for exp slider
; INIT instrument added
; Removed subinstr opcode in midi instrument 1


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps = 64    ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


gisine ftgen 0, 0, 131072, 10, 1                   ; Sine wave (used for vibrato)
giExp1 ftgen 0, 0, 129, -25, 0, 20.0, 128, 3000.0  ; Table for exp slider
giExp2 ftgen 0, 0, 129, -25, 0, 0.01, 128, 100.0   ; Table for exp slider


instr 2  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    gkplk  invalue "Pluck"
    gkpick invalue "Pick"
    gkrefl invalue "Refl"
    kcps   invalue "Pitch"
    gkcps tablei kcps, giExp1, 1
    outvalue "Pitch_Value", gkcps
    koutgain invalue "Gain"
    gkoutgain tablei koutgain, giExp2, 1
    outvalue "Gain_Value", gkoutgain
  endif
endin

instr 1           ; MIDI activated instrument
  icps cpsmidi    ; Frequency is read from incoming MIDI note
  iamp ampmidi 1  ; Amplitude is read from incoming MIDI note

  apluck wgpluck2 i(gkplk), iamp, icps, gkpick, gkrefl
  ; Create an amplitude envelope. This will be used to prevent clicks.
  aenv linsegr 1, 3600, 1, 0.1, 0
  outs apluck * aenv * gkoutgain, apluck * aenv * gkoutgain
endin

instr 3
  iamp = 1
  apluck wgpluck2 i(gkplk), iamp, i(gkcps), gkpick, gkrefl
  ; Create an amplitude envelope. This will be used to prevent clicks.
  aenv linsegr 1, 3600, 1, 0.1, 0
  outs apluck * aenv * gkoutgain, apluck * aenv * gkoutgain
endin

instr 4  ; Init
  outvalue "Pluck", .98
  outvalue "Pick", .1
  outvalue "Refl", .6
  outvalue "Pitch", 0.3213
  outvalue "Gain", 0.4
endin
</CsInstruments>
<CsScore>
; Instr | start | duration
i 2 0 3600  ; GUI
i 4 0 0.1   ; Init
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>545</x>
 <y>349</y>
 <width>1011</width>
 <height>291</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1</x>
  <y>2</y>
  <width>511</width>
  <height>286</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wgpluck2</label>
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
   <r>147</r>
   <g>154</g>
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
  <x>8</x>
  <y>76</y>
  <width>220</width>
  <height>30</height>
  <uuid>{640b50b7-7200-4f81-8394-89d9843ae939}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pluck Position (i-rate)</label>
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
  <objectName>Pluck</objectName>
  <x>8</x>
  <y>54</y>
  <width>500</width>
  <height>27</height>
  <uuid>{5585fa6f-0f63-4ac3-bf1b-809c2b1d9134}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.98000002</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Pluck</objectName>
  <x>448</x>
  <y>76</y>
  <width>60</width>
  <height>30</height>
  <uuid>{b731b52e-e14a-476a-a583-f3b2bd885539}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.980</label>
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
  <x>515</x>
  <y>2</y>
  <width>488</width>
  <height>286</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>wgpluck2</label>
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
   <r>147</r>
   <g>154</g>
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
  <x>517</x>
  <y>22</y>
  <width>488</width>
  <height>263</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------
wgpluck2 is another physical model implementation of a plucked string based the Karplus-Strong algorithm. wgpluck takes as its model an electric guitar or electric bass guitar. Pluck position is a value in the range 0 to 1 representing the fractional position along the string's length at which the string is plucked. (0 and 1 represent the string being plucked at the bridge or the nut, .5 represents the string being pluck exactly halfway along its length. Pick-up position is a value in the range 0 to 1 representing the fractional location of the pick-up along the strings length. Pick-up position is variable at k-rate. Coefficient of reflection should be a value between 0 and 1 (but not actually 0 or 1) and represents the amount of damping that is applied to the string as it resonates. Pitch in CPS (cycles per second) controls the intended pitch. Use of damping causes a slight drop in pitch so retuning may be necessary. This example can also be triggered via MIDI. MIDI note number and velocity are interpreted appropriately.</label>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>b7548</objectName>
  <x>8</x>
  <y>16</y>
  <width>120</width>
  <height>30</height>
  <uuid>{04d44ebe-12eb-4bb0-a3f5-9e4fd3e7830e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i 3 0 -1</eventLine>
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
  <y>121</y>
  <width>220</width>
  <height>30</height>
  <uuid>{6e0c35ca-d489-456c-a3c8-7b02cf334c36}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pick-up Position (k-rate)</label>
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
  <objectName>Pick</objectName>
  <x>8</x>
  <y>99</y>
  <width>500</width>
  <height>27</height>
  <uuid>{28514f48-2718-4dab-b43c-78c3cc4fba09}</uuid>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Pick</objectName>
  <x>448</x>
  <y>121</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1ad30bb1-9a2f-461a-bf9e-cc7cc6c9d678}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
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
  <x>8</x>
  <y>166</y>
  <width>220</width>
  <height>30</height>
  <uuid>{b6d928a2-0d92-4eaa-b1e8-9f3091c5794c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Coefficient of Reflection</label>
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
  <objectName>Refl</objectName>
  <x>8</x>
  <y>144</y>
  <width>500</width>
  <height>27</height>
  <uuid>{49a6777a-6ac7-430b-b827-547dc2686e49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>0.99900000</maximum>
  <value>0.60000002</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Refl</objectName>
  <x>448</x>
  <y>166</y>
  <width>60</width>
  <height>30</height>
  <uuid>{fca8b154-9112-4b23-8054-469dafd66230}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.600</label>
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
  <x>8</x>
  <y>211</y>
  <width>220</width>
  <height>30</height>
  <uuid>{55089f0d-6978-4aca-b682-ae666b30683e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch in CPS</label>
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
  <objectName>Pitch</objectName>
  <x>8</x>
  <y>189</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3439fd43-d6bf-41ba-88ab-efcbcda0122c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.32130000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Pitch_Value</objectName>
  <x>448</x>
  <y>211</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d78b9853-b96c-4bc2-a2d5-375b6a4869ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>100.057</label>
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
  <x>8</x>
  <y>256</y>
  <width>220</width>
  <height>30</height>
  <uuid>{d8273459-fbc3-40c2-b202-003f954906f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Gain</label>
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
  <objectName>Gain</objectName>
  <x>8</x>
  <y>234</y>
  <width>500</width>
  <height>27</height>
  <uuid>{ab819133-79c9-448f-a33b-8cbd65c8d6af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.40000001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Gain_Value</objectName>
  <x>448</x>
  <y>256</y>
  <width>60</width>
  <height>30</height>
  <uuid>{22ea767e-1d44-46df-a57d-1b39aeeeaa04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.398</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

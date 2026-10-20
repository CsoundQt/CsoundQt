; Written by Iain McCurdy 2011

; Modified for QuteCsound by René, May 2011
; Tested on Ubuntu 10.04 with csound-float (git csound5-3c6d155, May 31 2011) and
; QuteCsound svn rev 848


; Notes on modifications from original csd:
; Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SADIR+= ../../SourceMaterials --env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 16     ; Number of audio samples in each control cycle
nchnls = 1      ; Number of channels (2=stereo)


; Stencilling fft analysis is stored in a gen 43 function table (-ve gen number so that
; post normalisation is skipped)
; Table size shoudl be at least fft_size/2
ginoise ftgen 0, 0, 131072, -43, "noise.pvx", 0


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
    gkgain    invalue "Gain"
    gklevel   invalue "Level"
    gkDryWet  invalue "DryWet"
    gkOutGain invalue "OutGain"

    Sfile_new strcpy ""  ; Init to empty string
    gSfile invalue "_Browse"
    Sfile_old strcpyk Sfile_new
    Sfile_new strcpyk gSfile
    gkfile strcmpk Sfile_new, Sfile_old
  endif
endin

instr 1
  ; Generate a momentary '1' pulse in output 'kswitch' if any of the scanned input
  ; variables change. (output 'kswitch' is normally zero)
  kNew_file changed gkfile
  if kNew_file = 1 then  ; If i-rate variable change trigger is '1'...
    reinit NEW_FILE      ; Begin a reinitialisation pass from label 'start'
  endif

NEW_FILE:
  ; Generate 2 audio signals from a stereo sound file
  asigin, asigR FilePlay2 gSfile, 1, 0, 1
  rireturn  ; Return from reinitialisation pass to performance time passes

  ; Analyse the audio signal. Output an f-signal.
  fsigin pvsanal asigin, 1024, 256, 1024, 1

  /*
  ; Pvread on the sample file can also be used
  #define ANALYSISFILE # "sample.pvx" #
  ilen filelen $ANALYSISFILE
  gkspeed = 0.5
  kptr phasor gkspeed/ilen
  fsigin pvsfread kptr*ilen, $ANALYSISFILE
  */

  fres pvstencil fsigin, gkgain, gklevel, ginoise  ; Apply stencil gating
  ; Resynthesize the f-signal as an audio signal
  aresyn pvsynth fres
  ; Create a mix between the dry (unfiltered) and wet (filtered) sound
  amix ntrpol asigin, aresyn, gkDryWet
  out amix * gkOutGain  ; Send the rescaled, resynthesized signal to the audio outputs
endin

instr 11  ; Init
  outvalue "Gain", 0.0
  outvalue "Level", 10.0
  outvalue "DryWet", 1.0
  outvalue "OutGain", 1.0
endin
</CsInstruments>
<CsScore>
; Instr | start | duration
i 10 0 3600  ; GUI
i 11 0 0     ; Init
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>73</x>
 <y>206</y>
 <width>1107</width>
 <height>292</height>
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
  <height>290</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvstencil</label>
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
  <x>517</x>
  <y>2</y>
  <width>590</width>
  <height>290</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pvstencil</label>
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
  <x>520</x>
  <y>21</y>
  <width>583</width>
  <height>258</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-----------------------------------------------------------------------------------------------------------------------------------------------
pvstencil is performs masking of a streaming pvoc signal according to secondary pvoc data held in a GEN 43 function table. The most typical application for this would be to remove unwanted constant noise from a recording by first analysing a short isolated sample of that noise. The amplitude of each pvoc channel for a given instant is compared to the amplitude of the corresponding channel in the GEN 43 masking function. If the value falls below that of the masking function a user definable gain is applied. Values read from the masking function are first scaled by the parameter 'Level'. Increasing level will increase the threshold below which gain will be applied and therefore increase the influence of the masking function. Extreme values for 'Level' will result in extreme transformations of the input sound that go beyond noise reduction. By using samples other than noise samples as input for the masking function this opcode can have other creative uses. In this example a slider is provided that allows the user to compare the signal before filter with that after filtering.</label>
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
  <objectName>b9164</objectName>
  <x>8</x>
  <y>8</y>
  <width>80</width>
  <height>30</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On / Off</text>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Gain</objectName>
  <x>448</x>
  <y>73</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
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
  <x>8</x>
  <y>51</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
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
  <y>73</y>
  <width>150</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>247</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>sample.wav</stringvalue>
  <text>Browse Audio File</text>
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
  <objectName>_Browse</objectName>
  <x>178</x>
  <y>248</y>
  <width>330</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>sample.wav</label>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Level</objectName>
  <x>448</x>
  <y>121</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e18e15d6-c58d-4c38-a766-79602b72f947}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10.000</label>
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
  <objectName>Level</objectName>
  <x>8</x>
  <y>99</y>
  <width>500</width>
  <height>27</height>
  <uuid>{36779c76-0b42-4e18-819b-e02bf72d22dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>10.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>121</y>
  <width>150</width>
  <height>30</height>
  <uuid>{b74148fe-3ba3-4d62-b507-64eb27627e65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Level</label>
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
  <objectName>DryWet</objectName>
  <x>448</x>
  <y>169</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3c299cf9-f5e6-4902-9f6c-4d3802f1beb8}</uuid>
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
  <objectName>DryWet</objectName>
  <x>8</x>
  <y>147</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b96a19b5-e2ff-4bc8-9d9c-e1878dc2c7ea}</uuid>
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
  <x>8</x>
  <y>169</y>
  <width>150</width>
  <height>30</height>
  <uuid>{3f67483e-a5a5-4c55-8c4c-802b8cb45fcb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry/Wet Mix</label>
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
  <objectName>OutGain</objectName>
  <x>448</x>
  <y>217</y>
  <width>60</width>
  <height>30</height>
  <uuid>{44e73856-6869-4340-96a9-e5a61ecd5938}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.004</label>
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
  <objectName>OutGain</objectName>
  <x>8</x>
  <y>195</y>
  <width>500</width>
  <height>27</height>
  <uuid>{484ef1b1-d231-454a-b908-cadd3e9dcbc1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>217</y>
  <width>150</width>
  <height>30</height>
  <uuid>{07143124-f11e-43ad-9bad-2a731b719732}</uuid>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

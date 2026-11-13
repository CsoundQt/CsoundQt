; Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files


<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 64     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1

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


instr 1
  Sfile invalue "_Browse"
  kstatus, kchan, k1, k2 = midiin()
  if kstatus == 224 then
    kbend = (k2 * 128 + k1) / 8192 - 1
    kbend *= 2
  endif

  iporttime = .01
  kporttime linseg 0, .001, iporttime, 1, iporttime

  kbend = lag(kbend, kporttime)
  
  asigL, asigR FilePlay2 Sfile, kbend, 0, 1
  outs asigL, asigR
endin

schedule 1, 0, -1
</CsInstruments>
<CsScore>
f 0 86400  ; Allows realtime MIDI playing for 1 day
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>740</x>
 <y>414</y>
 <width>520</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#aaaaaa</bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>512</width>
  <height>233</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>pchbend - Diskin Playback Speed 1</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="background">#f4f8c8</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>17</y>
  <width>500</width>
  <height>160</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>--------------------------------------------------------------------------------------------------------------------------
In this example the pitch bend wheel is used to control the playback speed of a diskin file player. The range for playback speed is -2 to 2. Therefore at its maximum position the playback speed will be double normal speed and forwards (2) and at its minimum position the playback speed is double normal speed and backwards (-2). At the equilibrium position playback speed will be zero, therefore silence. A midi note needs to be played to activate the midi instrument.
At each note the audio file is loaded (init).</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>195</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
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
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <font/>
  <flatStyle>false</flatStyle>
  <color>#0c0c0c</color>
  <pressedColor>#3c3c3c</pressedColor>
  <borderColor>#525252</borderColor>
  <textColor>#dfdfdf</textColor>
  <pressedTextColor/>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse</objectName>
  <x>179</x>
  <y>196</y>
  <width>325</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>AndItsAll.wav</label>
  <instant>true</instant>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>#000000</color>
  <bgcolor mode="nobackground">#e5e5e5</bgcolor>
  <background>nobackground</background>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>174</y>
  <width>150</width>
  <height>30</height>
  <uuid>{936f6eb0-5225-4bd7-a5fe-a49df1c9c5ac}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Audio File</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#000000</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

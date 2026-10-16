; Written by Iain McCurdy, 2006

; Modified for QuteCsound by René, October 2010, updated Feb 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; An INIT preset is called at the start of csound (inst 2), a valid (mono or stereo) audio
; file have to be selected and preset 0 saved before playing.

; Notes on modifications from original csd:
; Add table(s) for exp slider
; Add Browser for audio files, accept mono or stereo wav files
; Instrument 1 is activated by MIDI and by the GUI
; Removed Recording instrument, included in QuteCsound
; Removed "Instructions and Info Panel" for the gui to fit in a 1200x800 screen

; syncgrain
; ----------------------------------------------------------------------------------------------------------------------------
; Syncgrain offers granular synthesis upon a stored sound file stored in a gen 1 function
; table.
; Syncgrain's strength lies in its use of k-rate control for its main input arguments
; which encourages real time manipulation.
; Another distinctive feature of syncgrain is the interaction between the density (kfreq),
; grain size (kgrsize) and progress
; rate (kprate). Density or grain frequency (kfreq) defines the number of grains per
; second. Higher values for grain density
; have the effect of increasing the progress rate through the sound file (kprate).
; Increasing the grain size also increases the
; rate of progress through the sound file.
; The progress rate (kprate) defines the location from where a grain will begin playback
; as a fraction of the previous grain's
; entire trajectory. If progress rate is given a value of 1 then a grain will begin
; exactly where the previous grain finished.
; If progress rate is given a value of 0.5 then it will begin at the halfway point of the
; previous grain's trajectory.
; Negative values for progress rate cause the progress pointer to move backwards through
; the file (but playback of each grain
; is still forwards).
; The user is required to provide an amplitude envelope which is stored in a function
; table. In this example the user is provided
; with six grain envelopes from which to choose.
; Details are provided on the interface. Some additional functions have been added that
; are not part of the original opcode:
; 'Grain Density' (frequency) and 'Grain Size' can be randomized. The 'Freeze' button sets
; the 'Progress Rate' slider to zero
; thereby effectively freezing progress through the sound file.
; This instrument can also be activated via MIDI. MIDI pitch values can be mapped to grain
; density and/or to the pitch of the
; material contained within the grain. In the latter mapping option, middle C is the point
; at which no transposition occurs.
; Using MIDI activation, polyphony is possible.
; The attack and release times of an amplitude envelope applied to the entire grain cloud
; can be modulated by the user using two
; on screen sliders. These controls are probably most useful when triggering this example
; via MIDI.


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma -m0
; --midi-key-oct=4 --midi-velocity-amp=5
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps = 64    ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


; Windowing functions used to dynamically shape the grains
; Num | init_time | size | gen_routine | partial_num | strength | phase
; Grain envelope window function tables:
giwfn1 ftgen 0, 0, 131072, 9, .5, 1, 0               ; Half sine
giwfn2 ftgen 0, 0, 131072, 7, 0, 3072, 1, 128000, 0  ; Percussive - straight segments
; Percussive - exponential segments
giwfn3 ftgen 0, 0, 131072, 5, .001, 3072, 1, 128000, .001
; Gate - with de-clicking ramp up and ramp down segments
giwfn4 ftgen 0, 0, 131072, 7, 0, 1536, 1, 128000, 1, 1536, 0
; Reverse percussive - straight segments
giwfn5 ftgen 0, 0, 131072, 7, 0, 128000, 1, 3072, 0
; Reverse percussive - exponential segments
giwfn6 ftgen 0, 0, 131072, 5, .001, 128000, 1, 3072, .001

; Table for exp slider
giExp1    ftgen 0, 0, 129, -25, 0, 0.001, 128, 1.0
giExp2000 ftgen 0, 0, 129, -25, 0, 1.0, 128, 2000.0

instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    gkMIDItoDensity invalue "MtoDensity"
    gkMIDItoPitch   invalue "MtoPitch"
    gkwfn           invalue "Grain_Envelope"
    kfreeze         invalue "Freeze"

    gkamp invalue "Amplitude"
    kfreq invalue "Density"
    gkfreq tablei kfreq, giExp2000, 1
    outvalue "Density_Value", gkfreq
    gkpitch invalue "Pitch"
    gkprate invalue "Progress_Rate"

    if kfreeze = 1 then
      outvalue "Progress_Rate", 0
    endif

    kgrsize invalue "Grain_Size"
    gkgrsize tablei kgrsize, giExp1, 1
    outvalue "Grain_Size_Value", gkgrsize
    gkfreqOS invalue "Grain_Density_Offset"
    gksizeOS invalue "Grain_Size_Rnd_Offset"
    gkAtt    invalue "Attack_Time"
    gkRel    invalue "Release_Time"

    ; Audio file change / load in tables
    ; ********************************************************************************************************
    ; Have put all this stuff in instr 10 to reduce the respons time when playing with
    ; midi

    Sfile_new strcpy ""  ; Init to empty string

    Sfile invalue "_Browse"
    Sfile_old strcpyk Sfile_new
    Sfile_new strcpyk Sfile
    kfile strcmpk Sfile_new, Sfile_old

    gkfile_new init 0
    if kfile != 0 then  ; If a bang had been generated in the line above
      gkfile_new = 1    ; Flag to inform instr 1 that a new file is loaded
      reinit NEW_FILE   ; Reinitialize from label 'new_file'
    endif
NEW_FILE:

    ; Function tables numbers of the sound file that will be granulated
    ichn filenchnls Sfile
    if ichn == 1 then
      giFileL ftgentmp 0, 0, 0, 1, Sfile, 0, 0, 1  ; Read mono audio file channel 1
      giFileR = giFileL
    else
      giFileL ftgentmp 0, 0, 0, 1, Sfile, 0, 0, 1  ; Read stereo audio file channel 1
      giFileR ftgentmp 0, 0, 0, 1, Sfile, 0, 0, 2  ; Read stereo audio file channel 2
    endif

    ; *******************************************************************************************************************************************
  endif
endin

instr 1                  ; Syncgrain instrument
  if p4 != 0 then        ; MIDI
    ioct = p4            ; Read oct value from MIDI input
    icps = cpsoct(ioct)  ; Convert to cps
    ; Pitch
    ; bend============================================================================================================
    iSemitoneBendRange = 12  ; Pitch bend range in semitones
    imin               = 0   ; Equilibrium position
    ; Max pitch displacement (in oct format)
    imax = iSemitoneBendRange * .0833333
    ; Pitch bend variable (in oct format)
    kbend pchbend imin, imax
    kcps = cpsoct(ioct + kbend)  ; Set fundamental
    ; =======================================================================================================================
  endif

  iporttime = 0.1  ; Portamento time
  ; Use of a ramping up envelope prevents gliding parameters each time a note is restarted
  kporttime linseg 0, 0.01, iporttime, 1, iporttime

  ; If this is a MIDI activated note and MIDI-to-pitch switch is on...
  if p4 != 0 && gkMIDItoPitch = 1 then
    ; Map to MIDI note value to pitch (convert to ratio: middle c is point of unison)
    kpitch = kcps/cpsoct(8)
  else                               ; Otherwise...
    kpitch portk gkpitch, kporttime  ; Use the slider value
  endif                              ; End of this conditional branch

  ; If this is a MIDI activated note and MIDI-to-pitch switch is on...
  if p4 != 0 && gkMIDItoDensity = 1 then
    kfreq = icps
  else                             ; Otherwise...
    kfreq portk gkfreq, kporttime  ; Use the GUI slider value
  endif                            ; End of this conditional branch

  if gkfile_new = 1 then  ; test if a new file is loaded by instr 10
    gkfile_new = 0        ; flag to zero for next file change
    reinit START          ; Reinitialize from label 'new_file1'
  endif

  kSwitch changed gkwfn
  if kSwitch = 1 then
    reinit START
  endif

  kgrsize portk gkgrsize, kporttime
  kprate  portk gkprate, kporttime
  ; Number of allowed overlaps - best just to give this a large constant value
  iolaps = 2000

  ; Kfreqos is a k-rate random number within the range -gkfreqos to gkfreqos
  kfreqOS rand gkfreqOS
  kfreqOS = kfreqOS * kfreq  ; Kfreqos is redefined relative to the current value of kfreq

  ; Kgrsizeos is a k-rate gaussian random number within the range -gksizeos to gksizeos
  kgrsizeOS gauss gksizeOS
  ; Kgrsizeos is redefined relative to the current value of kgrsize
  kgrsizeOS = kgrsizeOS * kgrsize

START:
  iwfn = giwfn1 + i(gkwfn)  ; Function table number for windowing function is derived
  ; Left channel
  asigL syncgrain gkamp, kfreq+kfreqOS, kpitch, kgrsize+kgrsizeOS, kprate, giFileL, iwfn, iolaps
  ; Right channel
  asigR syncgrain gkamp, kfreq+kfreqOS, kpitch, kgrsize+kgrsizeOS, kprate, giFileR, iwfn, iolaps
  rireturn
  aenv expsegr 0.0001, i(gkAtt), 1, i(gkRel), 0.0001  ; Cloud amplitude envelope
  asigL = asigL * aenv                                ; Apply amplitude envelope
  asigR = asigR * aenv                                ; Apply amplitude envelope
  outs asigL, asigR
endin

instr 2  ; Init
  outvalue "_SetPresetIndex", 0
endin
</CsInstruments>
<CsScore>
; Instr | start | duration
i 10 0 3600  ; GUI

i 2 0.1 0  ; Init
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>73</x>
 <y>206</y>
 <width>1030</width>
 <height>353</height>
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
  <width>1028</width>
  <height>346</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>syncgrain</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>85</g>
   <b>0</b>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>b9060</objectName>
  <x>8</x>
  <y>8</y>
  <width>120</width>
  <height>30</height>
  <uuid>{55273d97-d39a-441c-8da6-87ea139493b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On / Off (MIDI)</text>
  <image>/</image>
  <eventLine>i1 0 -1</eventLine>
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
  <x>547</x>
  <y>143</y>
  <width>144</width>
  <height>30</height>
  <uuid>{4e98b9a0-55c5-4aef-b473-1d0b761def5d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Envelope Type</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <x>521</x>
  <y>77</y>
  <width>170</width>
  <height>30</height>
  <uuid>{1757a18f-b418-4ef1-984d-bdee5e985805}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>ClassicalGuitar.wav</stringvalue>
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
  <x>691</x>
  <y>78</y>
  <width>330</width>
  <height>28</height>
  <uuid>{804f4f24-03f1-4ac2-8ba2-697f15df06cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ClassicalGuitar.wav</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>521</x>
  <y>56</y>
  <width>120</width>
  <height>30</height>
  <uuid>{a918d231-4dd1-4893-81ef-bf453535bda6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input File</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <y>106</y>
  <width>180</width>
  <height>30</height>
  <uuid>{93f3e274-799d-49e8-9392-4d8c6ad43ae2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Density (Grain per Sec)</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Density</objectName>
  <x>8</x>
  <y>83</y>
  <width>500</width>
  <height>27</height>
  <uuid>{89741b38-8333-4828-b8b8-656cff90d564}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.39399999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Density_Value</objectName>
  <x>448</x>
  <y>106</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>19.989</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <y>151</y>
  <width>180</width>
  <height>30</height>
  <uuid>{9d200fd9-5a42-4f87-89ab-14ef5ac064ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pitch</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <y>128</y>
  <width>500</width>
  <height>27</height>
  <uuid>{ecd7a8b0-5bb3-4479-b692-e56294223499}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Pitch</objectName>
  <x>448</x>
  <y>151</y>
  <width>60</width>
  <height>30</height>
  <uuid>{f275c8fd-3605-49e8-9090-67ca5f21a9f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <y>64</y>
  <width>200</width>
  <height>30</height>
  <uuid>{5cde19f3-b356-4945-9c8b-43dd67c604dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amplitude</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Amplitude</objectName>
  <x>8</x>
  <y>41</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d6d73a88-8d82-47de-a067-758f1917a3f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Amplitude</objectName>
  <x>448</x>
  <y>64</y>
  <width>60</width>
  <height>30</height>
  <uuid>{073ad371-9227-46fa-a005-ac10a210db79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <x>514</x>
  <y>262</y>
  <width>510</width>
  <height>80</height>
  <uuid>{b83b9228-3958-46d8-adf5-262b04a121c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Cloud Envelope</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>519</x>
  <y>308</y>
  <width>180</width>
  <height>30</height>
  <uuid>{489dc531-f476-4ca3-b56d-f970ee2c49aa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack Time</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Attack_Time</objectName>
  <x>519</x>
  <y>285</y>
  <width>250</width>
  <height>27</height>
  <uuid>{dbdbe7cb-a74d-45b2-9e47-e5c0594f3ea5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.05000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Attack_Time</objectName>
  <x>709</x>
  <y>308</y>
  <width>60</width>
  <height>30</height>
  <uuid>{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.050</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Release_Time</objectName>
  <x>959</x>
  <y>308</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.050</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Release_Time</objectName>
  <x>769</x>
  <y>285</y>
  <width>250</width>
  <height>27</height>
  <uuid>{cb664a0c-f84b-41f5-92e9-7deb5a672d56}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.05000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>769</x>
  <y>308</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7a8b8cb8-12e8-415d-b11c-fb0d460c9e6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release Time</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <y>281</y>
  <width>200</width>
  <height>30</height>
  <uuid>{b6afbe1e-677c-44a6-ba84-4c32dc21b0a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Density Offset</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Grain_Density_Offset</objectName>
  <x>8</x>
  <y>258</y>
  <width>500</width>
  <height>27</height>
  <uuid>{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.38600001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Grain_Density_Offset</objectName>
  <x>448</x>
  <y>281</y>
  <width>60</width>
  <height>30</height>
  <uuid>{95f6cb02-77ec-46fe-876b-a93efac3c5e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.386</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <y>239</y>
  <width>180</width>
  <height>30</height>
  <uuid>{7fd47947-fd0d-4964-85e5-682fed1916c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Size</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Grain_Size</objectName>
  <x>8</x>
  <y>216</y>
  <width>500</width>
  <height>27</height>
  <uuid>{475cdd64-a4ca-4ebc-a000-90448e932478}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.56599998</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Grain_Size_Value</objectName>
  <x>448</x>
  <y>239</y>
  <width>60</width>
  <height>30</height>
  <uuid>{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.050</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <y>323</y>
  <width>180</width>
  <height>30</height>
  <uuid>{1b53998a-9e9e-4067-8cee-83fc9f2f657b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Grain Size Random Offset</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Grain_Size_Rnd_Offset</objectName>
  <x>8</x>
  <y>301</y>
  <width>500</width>
  <height>27</height>
  <uuid>{4bea56a5-96d7-49d0-90a1-6d1dd17fc584}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.23800001</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Grain_Size_Rnd_Offset</objectName>
  <x>448</x>
  <y>323</y>
  <width>60</width>
  <height>30</height>
  <uuid>{225c97bc-f9f0-4085-94c4-f8de353f00cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.238</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <y>193</y>
  <width>200</width>
  <height>30</height>
  <uuid>{3ebc1139-1fdb-48dc-9150-49ee8dfdbd4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Progress Rate</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>Progress_Rate</objectName>
  <x>8</x>
  <y>170</y>
  <width>500</width>
  <height>27</height>
  <uuid>{2cf97843-5b49-438e-8034-62a459597e86}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2.00000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Progress_Rate</objectName>
  <x>448</x>
  <y>193</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e54486c5-f9aa-4d0e-9a67-6506dae3c790}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>9</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Grain_Envelope</objectName>
  <x>691</x>
  <y>140</y>
  <width>330</width>
  <height>30</height>
  <uuid>{5041c02a-c619-488c-8631-a3f9e1dab457}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Half Sine</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Percussive (straight segments)</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Percussive (exponential segments)</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Gate (with anti click ramp up and ramp down)</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Reverse Percussive (straight segments)</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Reverse Percussive (exponential segments)</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>514</x>
  <y>210</y>
  <width>510</width>
  <height>50</height>
  <uuid>{f083eb01-c7ae-40f6-9ac6-d7b32117fedd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>MIDI Notes</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>589</x>
  <y>221</y>
  <width>100</width>
  <height>28</height>
  <uuid>{9f6f0612-5f3c-4a18-9f40-6fb9ece10c64}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>to Density</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <x>721</x>
  <y>224</y>
  <width>100</width>
  <height>28</height>
  <uuid>{18bdb5ba-84f0-4561-8771-6792fe1b971f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>to Pitch</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
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
  <objectName>MtoDensity</objectName>
  <x>695</x>
  <y>223</y>
  <width>16</width>
  <height>16</height>
  <uuid>{c64b625e-c396-4f39-89fb-9c21b77affdd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>MtoPitch</objectName>
  <x>828</x>
  <y>225</y>
  <width>16</width>
  <height>16</height>
  <uuid>{cdf66a23-91bd-4fe3-987f-dfc531c78348}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text/>
  <image>/</image>
  <eventLine/>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>Freeze</objectName>
  <x>325</x>
  <y>192</y>
  <width>80</width>
  <height>20</height>
  <uuid>{bae47aa6-1bde-4095-a40b-9bcfbcd66ed7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Freeze</text>
  <image>/</image>
  <eventLine/>
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
</bsbPanel>
<bsbPresets>
<preset name="INIT" number="0" >
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="1" >0.00000000</value>
<value id="{55273d97-d39a-441c-8da6-87ea139493b6}" mode="4" >0</value>
<value id="{1757a18f-b418-4ef1-984d-bdee5e985805}" mode="4" >ClassicalGuitar.wav</value>
<value id="{804f4f24-03f1-4ac2-8ba2-697f15df06cf}" mode="4" >ClassicalGuitar.wav</value>
<value id="{89741b38-8333-4828-b8b8-656cff90d564}" mode="1" >0.39399999</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="1" >19.98900032</value>
<value id="{d1569d45-d5fa-452c-b69f-0b3e0b47cd01}" mode="4" >19.989</value>
<value id="{ecd7a8b0-5bb3-4479-b692-e56294223499}" mode="1" >1.00000000</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="1" >1.00000000</value>
<value id="{f275c8fd-3605-49e8-9090-67ca5f21a9f6}" mode="4" >1.000</value>
<value id="{d6d73a88-8d82-47de-a067-758f1917a3f2}" mode="1" >0.50000000</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="1" >0.50000000</value>
<value id="{073ad371-9227-46fa-a005-ac10a210db79}" mode="4" >0.500</value>
<value id="{dbdbe7cb-a74d-45b2-9e47-e5c0594f3ea5}" mode="1" >0.05000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="1" >0.05000000</value>
<value id="{2aea18ca-8a9a-457a-8de3-cb7c918a4e3b}" mode="4" >0.050</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="1" >0.05000000</value>
<value id="{ea7f84c3-e2da-4b1c-a79e-61c2a264d20c}" mode="4" >0.050</value>
<value id="{cb664a0c-f84b-41f5-92e9-7deb5a672d56}" mode="1" >0.05000000</value>
<value id="{859d1ded-b337-4ee7-ac9b-48a1b5f77d16}" mode="1" >0.38600001</value>
<value id="{95f6cb02-77ec-46fe-876b-a93efac3c5e5}" mode="1" >0.38600001</value>
<value id="{95f6cb02-77ec-46fe-876b-a93efac3c5e5}" mode="4" >0.386</value>
<value id="{475cdd64-a4ca-4ebc-a000-90448e932478}" mode="1" >0.56599998</value>
<value id="{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}" mode="1" >0.05000000</value>
<value id="{dc75acc2-c015-4b8d-8fb2-467b9fb96d42}" mode="4" >0.050</value>
<value id="{4bea56a5-96d7-49d0-90a1-6d1dd17fc584}" mode="1" >0.23800001</value>
<value id="{225c97bc-f9f0-4085-94c4-f8de353f00cc}" mode="1" >0.23800001</value>
<value id="{225c97bc-f9f0-4085-94c4-f8de353f00cc}" mode="4" >0.238</value>
<value id="{2cf97843-5b49-438e-8034-62a459597e86}" mode="1" >1.00000000</value>
<value id="{e54486c5-f9aa-4d0e-9a67-6506dae3c790}" mode="1" >1.00000000</value>
<value id="{e54486c5-f9aa-4d0e-9a67-6506dae3c790}" mode="4" >1.000</value>
<value id="{5041c02a-c619-488c-8631-a3f9e1dab457}" mode="1" >0.00000000</value>
<value id="{c64b625e-c396-4f39-89fb-9c21b77affdd}" mode="1" >0.00000000</value>
<value id="{c64b625e-c396-4f39-89fb-9c21b77affdd}" mode="4" >0</value>
<value id="{cdf66a23-91bd-4fe3-987f-dfc531c78348}" mode="1" >0.00000000</value>
<value id="{cdf66a23-91bd-4fe3-987f-dfc531c78348}" mode="4" >0</value>
<value id="{bae47aa6-1bde-4095-a40b-9bcfbcd66ed7}" mode="1" >0.00000000</value>
<value id="{bae47aa6-1bde-4095-a40b-9bcfbcd66ed7}" mode="4" >0</value>
</preset>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

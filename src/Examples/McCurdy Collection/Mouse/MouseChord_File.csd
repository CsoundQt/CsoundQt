; Written by Iain McCurdy, 2010

; Modified for QuteCsound by René, January 2011.
; Thanks to Andres CABRERA for the mouse channels names.

; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817 with "Widgets
; are an independent window" ON.


/*
Mouse Chord
-----------
This csd was originally written for use by someone who only had the use of a head-mouse for music performance.
If the mouse enters one of the coloured boxes the chord indicated by the Roman numeral is played.
Continuous dynamic control is possible by moving the mouse within the box: the dynamic is lowest at the edges of each box and highest at the centre of each box.
Dynamics are implemented with a changing tone (low-pass filter) as well as changing amplitude.
The user can choose between three different sounds using the radio buttons within the GUI.
Key and tonality (major/minor) can also be selected from within the GUI.
No clicking is required enabling better timing in performance. The GUI window needs to be in focus for this to work.
The mouse relative position is given by the channels _MouseRelX and _MouseRelY.

If the windows need to be resized, for example to accomodate use on a netbook, it is mandatory to manually update the values of boxes dimensions and positions in the csd file.

Professional head mouse or iris tracking software can be very expensive and requires practice.
iNavigate is a free option for Mac OS 10.5 if the user wants to experiment with this approach.
*/


; Notes on modifications from original csd:
; No automatic rescale
; Add Browser for audio file, accept mono or stereo wav files


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 16     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


; Define chords i-vii in pch format for major key
gichord1 ftgen 0, 0, 4, -2, 8.00, 8.04, 8.07, 9.00
gichord2 ftgen 0, 0, 4, -2, 8.02, 8.05, 8.09, 9.02
gichord3 ftgen 0, 0, 4, -2, 8.04, 8.07, 8.11, 9.04
gichord4 ftgen 0, 0, 4, -2, 8.00, 8.05, 8.09, 9.00
gichord5 ftgen 0, 0, 4, -2, 7.11, 8.02, 8.07, 8.11
gichord6 ftgen 0, 0, 4, -2, 8.00, 8.04, 8.09, 9.00
gichord7 ftgen 0, 0, 4, -2, 8.02, 8.05, 8.11, 9.02

; Define chords i-vii in pch format for minor key
gichord1m ftgen 0, 0, 4, -2, 8.00, 8.03, 8.07, 9.00
gichord2m ftgen 0, 0, 4, -2, 8.02, 8.05, 8.08, 9.02
gichord3m ftgen 0, 0, 4, -2, 8.03, 8.07, 8.11, 9.03
gichord4m ftgen 0, 0, 4, -2, 8.05, 8.08, 8.00, 9.05
gichord5m ftgen 0, 0, 4, -2, 8.07, 8.11, 8.02, 9.07
gichord6m ftgen 0, 0, 4, -2, 8.08, 8.00, 8.03, 9.08
gichord7m ftgen 0, 0, 4, -2, 8.02, 8.05, 8.11, 9.02

zakinit 4, 10
gkRvbSze init 0.85  ; Reverb size
gkRvbSnd init 0.2   ; Reverb amount


; Udos-(user defined
; opcodes)----------------------------------------------------------------------------------------------------------------------------------------------
; Reverb udo (use of a udo for reverb is to allow the setting of a k-rate independent of
; the global k-rate
opcode reverbsr, aa, aakk
  setksmps 1                                            ; Control rate within udo is 1
  ainsigL, ainsigR, kfblvl, kfco xin                    ; Name input variables
  arvbL, arvbR reverbsc ainsigL, ainsigR, kfblvl, kfco  ; USE reverbsc OPCODE
  xout arvbL, arvbR                                     ; Send audio to caller instrument
endop                                                   ; End of udo
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

instr 1
  ; Boxes dimensions, square isize x isize
  isize = 200

  ; Boxes positions
  ix1 = 50  ; I box
  iy1 = 105

  ix2 = 300  ; II box
  iy2 = 105

  ix3 = 550  ; III box
  iy3 = 105

  ix4 = 800  ; IV box
  iy4 = 105

  ix5 = 174  ; V box
  iy5 = 386

  ix6 = 424  ; VI box
  iy6 = 386

  ix7 = 674  ; VII box
  iy7 = 386

  krelx invalue "_MouseRelX"
  krely invalue "_MouseRelY"

  gkoct invalue "Octave"
  gkkey invalue "Key"
  gkton invalue "Ton"


  ; Audio file change / load in tables
  ; ********************************************************************************************************

  Sfile_new strcpy ""  ; Init to empty string
  Sfile invalue "_Browse"
  Sfile_old strcpyk Sfile_new
  Sfile_new strcpyk Sfile
  kfile strcmpk Sfile_new, Sfile_old

  if kfile != 0 then  ; If a bang had been generated in the line above
    reinit NEW_FILE   ; Reinitialize from label 'new_file'
  endif
NEW_FILE:
  ichn filenchnls Sfile
  if ichn == 1 then
    giFileL ftgentmp 0, 0, 0, 1, Sfile, 0, 0, 1  ; Read mono audio file channel 1
    giFileR = giFileL
  else
    giFileL ftgentmp 0, 0, 0, 1, Sfile, 0, 0, 1  ; Read stereo audio file channel 1
    giFileR ftgentmp 0, 0, 0, 1, Sfile, 0, 0, 2  ; Read stereo audio file channel 2
  endif
  rireturn
  ; *******************************************************************************************************************************************

  ; Define a macro for detection of mouse within each box
  #define CHORD_BOX_DETECT(N)
  #
  kinside$N init 0
  if (ix$N <= krelx && krelx <= ix$N+isize && iy$N <= krely && krely <= iy$N+isize) then
    kinside$N = 1

    ; origin change and scale to -1 to +1, zero at center of the box
    kx$N = (krelx - ix$N - isize*0.5)/(isize*0.5)
    ; origin change and scale to -1 to +1, zero at center of the box
    ky$N = (krely - iy$N - isize*0.5)/(isize*0.5)

    ; Mouse location define a value that will be zero if the mouse is on the circle of
    ; radius 1, and rise exponentially to a value of 1 at the centre of the box
    k$N = 1 - ((((kx$N^2) + (ky$N^2))*0.5)^0.5)
  else
    kinside$N = 0
    k$N       = 0  ; zero amplitude
  endif

  ; Create a trigger (momentary '1') if mouse enters or leaves this box
  ktrig$N changed kinside$N
  if ktrig$N = 1 then            ; If mouse has just entered or left this box...
    if kinside$N = 1 then        ; If mouse has just entered this box...
      event "i", 2, 0, 3600, $N  ; Play a long note instrument $n
    elseif kinside$N = 0 then    ; Or else if mouse has just left this box
      ; Turnoff instrument 2 allowing release stages to be completed
      turnoff2 2, 0, 1
    endif  ; End of conditional branching
  endif    ; End of conditional branching

  zkw k$N^3, $N-1  ; Write amplitude value to zak variable
  #

  ; Execute macro for each box...
  $CHORD_BOX_DETECT(1)
  $CHORD_BOX_DETECT(2)
  $CHORD_BOX_DETECT(3)
  $CHORD_BOX_DETECT(4)
  $CHORD_BOX_DETECT(5)
  $CHORD_BOX_DETECT(6)
  $CHORD_BOX_DETECT(7)
endin

instr 2
  ; ipch2 table 1, gichord1 + p4 - 1 ;PITCH OF FIRST NOTE OF CHORD
  ; ipch3 table 2, gichord1 + p4 - 1 ;PITCH OF SECOND NOTE OF CHORD
  ; ipch4 table 3, gichord1 + p4 - 1 ;PITCH OF THIRD NOTE OF CHORD

  aenv expsegr 0.001, 0.2, 1, 1, 0.001  ; Amplitude envelope

  ; Define macro of code to produce each note of the chord
  #define NOTE(N)
  #
  if i(gkton) = 0 then  ; If tonality is 'major'...
    ; Define pitch (pch format) for this note (major)
    ipch$N table $N-1, gichord1 + p4 - 1
  else  ; Otherwise tonality must be minor...
    ; Define pitch (pch format) for this note (minor)
    ipch$N table $N-1, gichord1m + p4 - 1
  endif  ; End of conditional branching

  ; Convert pch to a ratio
  imlt$N = cpspch(ipch$N + (i(gkkey)*0.01) + i(gkoct))/cpsoct(8.00)
  ilen   = nsamp(giFileL)/sr  ; Derive length of the sample
  ; Create audio signal using flooper2 opcode (left channel)
  aL$N flooper 0.3, imlt$N, 0, ilen-2, 1, giFileL
  ; Create audio signal using flooper2 opcode (right channel)
  aR$N flooper 0.3, imlt$N, 0, ilen-2, 1, giFileR
  #

  ; Execute macro for each note
  $NOTE(1)
  $NOTE(2)
  $NOTE(3)
  $NOTE(4)

  ; Sum (mix) the four notes
  aL sum aL1, aL2, aL3, aL4
  aR sum aR1, aR2, aR3, aR4

  kamp zkr p4 - 1       ; Read amplitude from zak variable
  kamp port kamp, 0.05  ; Apply portamento (to prevent quantisation / zipper noise)
  aamp interp kamp      ; Interpolate to create an audio rate version of this variable

  ; Define a filter cutoff frequency which is related to distance from the centre of the
  ; box
  kcfoct = (8*kamp)+6

  aL tone aL, cpsoct(kcfoct)  ; Apply low pass filtering (tone control)
  aR tone aR, cpsoct(kcfoct)  ; Apply low pass filtering (tone control)

  aL = aL * aenv * aamp  ; Scale audio signal with amplitiude envelope and
  aR = aR * aenv * aamp
  outs aL, aR
  ; Send some of the audio to the reverb via zak patching (left channel)
  zawm aL * gkRvbSnd, 0
  ; Send some of the audio to the reverb via zak patching (right channel)
  zawm aR * gkRvbSnd, 1
endin

instr 1000           ; Reverb
  ainL zar 0         ; Read in audio from zak channels
  ainR zar 1         ; Read in audio from zak channels
  denorm ainL, ainR  ; ...Denormalize both channels of audio signal

  ; Create reverberated signal (using udo defined above)
  arvbL, arvbR reverbsr ainL, ainR, gkRvbSze, 10000
  outs arvbL, arvbR  ; Send audio to outputs
  zacl 0, 3          ; Clear zak audio channels
endin
</CsInstruments>
<CsScore>
; Instr | start | duration
i 1 0 3600     ; Mouse position detection, plays a note for 1 hour
i 1000 0 3600  ; Reverb
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>333</x>
 <y>176</y>
 <width>1032</width>
 <height>586</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>3</x>
  <y>10</y>
  <width>189</width>
  <height>51</height>
  <uuid>{8696498c-ea5a-4002-80e2-b73942e10bb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mouse Chord</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
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
  <x>50</x>
  <y>105</y>
  <width>200</width>
  <height>200</height>
  <uuid>{1f07ff1d-0a47-40af-9185-de05106ee1af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>I</label>
  <alignment>center</alignment>
  <font>Liberation Serif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>100</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Ton</objectName>
  <x>201</x>
  <y>15</y>
  <width>80</width>
  <height>30</height>
  <uuid>{2d0597db-5154-49a3-8347-28766bf30a39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>C</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>C#</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>D</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>D#</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>E</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>F</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>F#</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>G</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>G#</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>A</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>A#</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>B</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>Key</objectName>
  <x>290</x>
  <y>15</y>
  <width>80</width>
  <height>30</height>
  <uuid>{9a9862cb-63a0-4ab9-80f7-b7def897c2eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Major</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>minor</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>Octave</objectName>
  <x>438</x>
  <y>15</y>
  <width>52</width>
  <height>30</height>
  <uuid>{055c3420-76d2-4887-8639-8aab364c2a29}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
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
  <minimum>-2</minimum>
  <maximum>2</maximum>
  <randomizable group="0">false</randomizable>
  <value>-1</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>370</x>
  <y>19</y>
  <width>68</width>
  <height>25</height>
  <uuid>{7d941c8e-e8aa-4692-8a56-4c39d8d95630}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Octave</label>
  <alignment>right</alignment>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>300</x>
  <y>105</y>
  <width>200</width>
  <height>200</height>
  <uuid>{34fa8ca4-1381-41a6-9c23-c3af053b7215}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>II</label>
  <alignment>center</alignment>
  <font>Liberation Serif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>100</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>550</x>
  <y>105</y>
  <width>200</width>
  <height>200</height>
  <uuid>{a6c7cb9e-55bc-4384-8825-4e3b3314411b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>III</label>
  <alignment>center</alignment>
  <font>Liberation Serif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>100</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>800</x>
  <y>105</y>
  <width>200</width>
  <height>200</height>
  <uuid>{2a7f1479-1b80-41f4-9ddb-27a4970f9b80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>IV</label>
  <alignment>center</alignment>
  <font>Liberation Serif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>100</r>
   <g>100</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>174</x>
  <y>386</y>
  <width>200</width>
  <height>200</height>
  <uuid>{f33eb5f2-beb2-4ece-a6cf-b54e26c14a80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>V</label>
  <alignment>center</alignment>
  <font>Liberation Serif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>100</g>
   <b>100</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>424</x>
  <y>386</y>
  <width>200</width>
  <height>200</height>
  <uuid>{906fee86-a6f7-47d0-b181-28bb94de1dd1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VI</label>
  <alignment>center</alignment>
  <font>Liberation Serif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>100</r>
   <g>255</g>
   <b>100</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>674</x>
  <y>386</y>
  <width>200</width>
  <height>200</height>
  <uuid>{6d570073-35b4-46f9-8b74-fb055707e525}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VII</label>
  <alignment>center</alignment>
  <font>Liberation Serif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>50</r>
   <g>120</g>
   <b>230</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse</objectName>
  <x>530</x>
  <y>15</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>choir.wav</stringvalue>
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
  <x>702</x>
  <y>16</y>
  <width>300</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>choir.wav</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

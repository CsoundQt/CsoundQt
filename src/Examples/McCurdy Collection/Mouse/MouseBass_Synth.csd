; Written by Iain McCurdy, 2010

; Modified for QuteCsound by René, January 2011.
; Thanks to Andres CABRERA for the mouse channels names.

; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817 with "Widgets
; are an independent window" ON.


/*
Mouse Bass
----------
This csd was originally written for use by someone who only had the use of a head-mouse for music performance.
The notes of the chromatic scale are arranged in coloured boxes according to the circle of fifths as this is perhaps the arrangement that is most useful to a bass guitarist.
If the mouse enters one of the boxes the note indicated by its label is played. If the mouse leaves the box the note is stopped (with a short release segment).
No clicking is required enabling better timing in performance. The GUI window needs to be in focus for this to work.
The mouse relative position is given by the channels _MouseRelX and _MouseRelY.

If the windows need to be resized, for example to accomodate use on a netbook, it is mandatory to manually update the values of boxes dimensions and positions in the csd file.

Professional head mouse or iris tracking software can be very expensive and requires practice.
iNavigate is a free option for Mac OS 10.5 if the user wants to experiment with this approach.
*/


; Notes on modifications from original csd:
; No automatic rescale
; Replaced audio file by an audio generator


; Depending on your platform and distribution, you might need to enable displays using the
; --displays command line flag.
; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 16     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


instr 1
  ; Boxes dimensions
  iwidth  = 100
  iheight = 100

  ; Boxes positions
  ix1 = 350  ; C box
  iy1 = 50

  ix2 = 490  ; G box
  iy2 = 110

  ix3 = 610  ; D box
  iy3 = 220

  ix4 = 650  ; A box
  iy4 = 350

  ix5 = 610  ; E box
  iy5 = 480

  ix6 = 490  ; B box
  iy6 = 600

  ix7 = 350  ; Gb box
  iy7 = 650

  ix8 = 220  ; Db box
  iy8 = 600

  ix9 = 90  ; Ab box
  iy9 = 480

  ix10 = 50  ; Eb box
  iy10 = 350

  ix11 = 90  ; Bb box
  iy11 = 220

  ix12 = 220  ; F box
  iy12 = 110

  krelx invalue "_MouseRelX"
  krely invalue "_MouseRelY"

  ; Define a macro for detection of mouse within each box - inputs for number and pitch
  ; (pch format)
  #define NOTE_BOX_DETECT(N'PCH)
  #
  kinside$N init 0
  if (ix$N <= krelx && krelx <= ix$N+iwidth && iy$N <= krely && krely <= iy$N+iheight) then
    kinside$N = 1
  else
    kinside$N = 0
  endif

  ; Create a trigger (momentary '1') if mouse enters or leaves this box
  ktrig$N changed kinside$N
  if ktrig$N = 1 then      ; If mouse has just entered or left this box...
    if kinside$N = 1 then  ; If mouse has just entered this box...
      ; Create a 5 second note event for instr 2. Pass pitch via p4
      event "i", 2, 0, 5, $PCH
    elseif kinside$N = 0 then  ; Or else if mouse has just left this box
      turnoff2 2, 0, 1         ; Turnoff instrument 2
    endif                      ; End of conditional branching
  endif                        ; End of conditional branching
  #

  ; Execute macro for each box...
  $NOTE_BOX_DETECT(1'8.00)
  $NOTE_BOX_DETECT(2'7.07)
  $NOTE_BOX_DETECT(3'8.02)
  $NOTE_BOX_DETECT(4'7.09)
  $NOTE_BOX_DETECT(5'8.04)
  $NOTE_BOX_DETECT(6'7.11)
  $NOTE_BOX_DETECT(7'8.06)
  $NOTE_BOX_DETECT(8'8.01)
  $NOTE_BOX_DETECT(9'7.08)
  $NOTE_BOX_DETECT(10'8.03)
  $NOTE_BOX_DETECT(11'7.10)
  $NOTE_BOX_DETECT(12'7.05)
endin

instr 2                    ; Bass
  aenv linsegr 1, 0.05, 0  ; Amplitude envelope (basically just the release stage)

  icps = cpspch(p4)

  k1 linseg 0.55, .2, 0.2, 0, 0.2
  k2 linseg 4, .2, 2, 0, 2

  a2 oscil k2, icps/2, 1
  a1 oscil k1, icps/2*a2, 1

  outs a1*aenv, a1*aenv
endin
</CsInstruments>
<CsScore>
f 1 0 1024 10 1  ; sin table

; Instr | start | duration
i 1 0 3600  ; Mouse position detection, plays a note for 1 hour
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
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>21</x>
  <y>47</y>
  <width>189</width>
  <height>51</height>
  <uuid>{8696498c-ea5a-4002-80e2-b73942e10bb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mouse Bass</label>
  <alignment>left</alignment>
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
  <x>350</x>
  <y>50</y>
  <width>100</width>
  <height>100</height>
  <uuid>{4ff1845d-670e-4f5a-ad22-f0da34a0c44b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>490</x>
  <y>110</y>
  <width>100</width>
  <height>100</height>
  <uuid>{b37c8e33-54bb-4f53-83b5-6b83cc09e6ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>G</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>200</g>
   <b>55</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>610</x>
  <y>220</y>
  <width>100</width>
  <height>100</height>
  <uuid>{2fc81349-9dc1-4bd5-894b-ec2bfbd045e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>D</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>200</r>
   <g>255</g>
   <b>200</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>650</x>
  <y>350</y>
  <width>100</width>
  <height>100</height>
  <uuid>{cfab6bf8-f61d-4c40-9e90-ae2ad4825b4b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>A</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
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
  <x>610</x>
  <y>480</y>
  <width>100</width>
  <height>100</height>
  <uuid>{2bdfd76e-2158-46b1-83f9-03daab95bb48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>E</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>105</r>
   <g>200</g>
   <b>55</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>490</x>
  <y>600</y>
  <width>100</width>
  <height>100</height>
  <uuid>{1b83334e-ab1b-4eb0-998c-0bda40dd8478}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>B</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>245</r>
   <g>53</g>
   <b>53</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>350</x>
  <y>650</y>
  <width>100</width>
  <height>100</height>
  <uuid>{fddbed6f-a446-4fbe-89fc-c9c644a5667b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gb</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
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
  <x>220</x>
  <y>600</y>
  <width>100</width>
  <height>100</height>
  <uuid>{5ddf806c-247b-4151-bcfd-42a82748e7bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Db</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>55</r>
   <g>200</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>90</x>
  <y>480</y>
  <width>100</width>
  <height>100</height>
  <uuid>{f282639e-421b-4715-9c45-99f21b1f84f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Ab</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>200</g>
   <b>55</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>50</x>
  <y>350</y>
  <width>100</width>
  <height>100</height>
  <uuid>{1f07ff1d-0a47-40af-9185-de05106ee1af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Eb</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
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
  <x>90</x>
  <y>220</y>
  <width>100</width>
  <height>100</height>
  <uuid>{7252cfc2-94e0-4989-8477-03aeb8979ab4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bb</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>39</r>
   <g>180</g>
   <b>109</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>220</x>
  <y>110</y>
  <width>100</width>
  <height>100</height>
  <uuid>{27944727-f486-4946-9ec7-372383e51123}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>F</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>155</r>
   <g>50</g>
   <b>230</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>_MouseRelX</objectName>
  <x>122</x>
  <y>105</y>
  <width>59</width>
  <height>25</height>
  <uuid>{eac032fa-9eec-4268-81a6-f6eb875d9517}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
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
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>_MouseRelY</objectName>
  <x>122</x>
  <y>133</y>
  <width>59</width>
  <height>25</height>
  <uuid>{e527159b-e21a-4f35-b4e3-525b6d4cf7b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
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
  <x>2</x>
  <y>105</y>
  <width>120</width>
  <height>25</height>
  <uuid>{55616170-a887-428f-ac65-3e612102334f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mouse Relative X</label>
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
  <x>2</x>
  <y>133</y>
  <width>120</width>
  <height>25</height>
  <uuid>{93bd69f1-40e2-4832-a787-a01f4a9f7de5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mouse Relative Y</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

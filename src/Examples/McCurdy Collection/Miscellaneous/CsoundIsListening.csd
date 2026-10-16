; Written by Iain McCurdy, 2011


; Modified for QuteCsound by René, May 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add Voices spinbox widget and Start button


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 64     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


zakinit 3, 3  ; Initialise zak variable storage space

; Initialise reverb send variables
gasendL init 0
gasendR init 0

; Define a udo for an oscillator voice
opcode vcomodule, 0, ii            ; Define opcode format
  icount, inum xin                 ; Define names for input arguments
  kvar jspline 15, 0.1, 0.2        ; Random jittering of pitch
  kpw rspline 0.05, 0.5, 0.4, 0.8  ; Random movement of pulse width for vco2
  ; Time to morph from gliding pitches to static pitches will differ slightly from voice
  ; to voice
  imorphtime random 5.5, 6.5
  ; Function defining morph from gliding to static voices is created
  kxfade linseg 0, 7, 0, imorphtime, 0.999, 2, 0.999
  ; Basic octave for each voice is derived from voice count number (wrapped between 0 and
  ; 8 to prevent ridiculously high tones)
  ioct wrap icount, 0, 8
  iinitoct random 0, 2  ; Defines the spread of voices during the gliding voices section
  ; Pitch (in cps) of each voice - morphing between a randomly gliding stage and a static
  ; stage
  kcps ntrpol 200*semitone(kvar)*octave(iinitoct), cpsoct(3+ioct+octpch(0.025)), kxfade
  koct = octcps(kcps)  ; Pitch converted to oct format
  ; Decibel value derived from oct value - this will be used for 'amplitude scaling' to
  ; prevent emphasis of higher pitched tones
  kdb = (5-koct)*4

  a1 vco2 ampdb(kdb)*0.12, kcps, 4, kpw, 0  ; The oscillator is created
  ; Random panning depth will move from zero (monophonic) to full stereo at the end of the
  ; note
  kPanDep linseg 0, 5, 0, 6, 0.5
  kpan rspline 0.5+kPanDep, 0.5-kPanDep, 0.3, 0.5  ; Random panning function
  ; Mono oscillator is randomly panned in a smooth gliding manner
  aL, aR pan2 a1, kpan
  zawm aL, 0  ; Left channel mixed into zak variable
  zawm aR, 1  ; Right channel mixed into zak variable

  icount = icount + 1       ; Increment voice count counter
  if icount <= inum then    ; If total voice limit has not yet been reached...
    vcomodule icount, inum  ; ...Call the udo again (with the incremented counter)
  endif                     ; End of this conditional branch
endop

instr 1                  ; Synth voices generating instrument
  knum invalue "Voices"  ; Number of voices
  icount init 0          ; Initialise voice counter

  ; Call vcomodule udo (subsequent calls will be made within the udo itself)
  vcomodule icount, i(knum)

  aoutL zar 0          ; Read zak channel (mix of all voices left channel)
  aoutR zar 1          ; Read zak channel (mix of all voices right channel)
  aoutL dcblock aoutL  ; Remove dc offset from audio (left channel)
  aoutR dcblock aoutR  ; Remove dc offset from audio (right channel)
  ; Amplitude envelope that will be applied to the mix of all voices
  kenv linseg -90, (1), -50, (6), -20, (6), 0, (p3-16), 0, (3), -90
  aoutL = aoutL*ampdb(kenv)  ; Apply envelope (left channel)
  aoutR = aoutR*ampdb(kenv)  ; Apply envelope (right channel)
  outs aoutL, aoutR          ; Send audio to outputs
  zacl 0, 3                  ; Clear zak audio variables
  ; Mix some audio into the reverb send variable (left channel)
  gasendL = gasendL+(aoutL*0.5)
  ; Mix some audio into the reverb send variable (right channel)
  gasendR = gasendR+(aoutR*0.5)
endin

instr 2  ; Reverb instrument
  aRvbL, aRvbR reverbsc gasendL, gasendR, 0.82, 10000
  outs aRvbL, aRvbR
  clear gasendL, gasendR
endin
</CsInstruments>
<CsScore>
i 2 0 3600  ; Reverb instrument
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>760</x>
 <y>256</y>
 <width>706</width>
 <height>379</height>
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
  <width>701</width>
  <height>375</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CsoundIsListening</label>
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
   <r>28</r>
   <g>33</g>
   <b>62</b>
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
  <x>7</x>
  <y>71</y>
  <width>692</width>
  <height>300</height>
  <uuid>{a22504a1-aa44-46e3-9ff9-60d7e5c3b024}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This example exemplifies the technique of opcode iteration using UDOs to create a mass of oscillators using a small amount of code.
This technique is introduced and explained in detail by Steven Yi in his article 'Control Flow - Part II' in the summer 2006 issue of the Csound Journal (http://www.csounds.com/journal/2006summer/controlFlow_part2.html).

In this example  a maximum of 1000 vco2 oscillators (voices) are created, you can change this number in the GUI, increasing it if your system permits it in realtime.
Each oscillator exhibits its own unique behaviour in terms of its pitch, pulse width and panning.
The entire mass morphs from a state in which the oscillator pitches slowly glide about randomly to a state in which they hold a fixed pitch across a range of octaves.

Some commercial synthesizers offer oscillators called 'mega-saws' or something similar. These are normally just clusters of detuned sawtooth waveforms so this is the way in which this could be emulated in Csound.
The example emulates a familiar sound ident. It is for educational purposes and no breach of copyright is intended.</label>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>19</x>
  <y>39</y>
  <width>140</width>
  <height>30</height>
  <uuid>{3277f9fb-691f-414c-8727-17951e27cba8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number of voices :</label>
  <alignment>right</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>Voices</objectName>
  <x>161</x>
  <y>39</y>
  <width>70</width>
  <height>30</height>
  <uuid>{e4a2b012-68dd-4120-b4f6-358ea0fcd693}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
  <minimum>10</minimum>
  <maximum>1000</maximum>
  <randomizable group="0">false</randomizable>
  <value>50</value>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b9674</objectName>
  <x>280</x>
  <y>39</y>
  <width>100</width>
  <height>30</height>
  <uuid>{4f7ff38a-67e3-4225-abd4-50ff8a4704eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Start</text>
  <image>/</image>
  <eventLine>i1 0 20</eventLine>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

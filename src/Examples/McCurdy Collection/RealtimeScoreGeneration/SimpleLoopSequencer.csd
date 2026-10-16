; Written by Iain McCurdy, 2011

; Modified for QuteCsound by René, March 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add Tempo SpinBox widget


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 10     ; Number of audio samples in each control cycle
nchnls = 1      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


; 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16
gi1    ftgen 0, 0, 16, 2, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0  ; Bass drum
gi2    ftgen 0, 0, 16, 2, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1  ; Kalimba
gi3    ftgen 0, 0, 16, 2, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0  ; Snare
gi4    ftgen 0, 0, 16, 2, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0  ; Closed hi-hat
gi5    ftgen 0, 0, 16, 2, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1  ; Open hi-hat
gi6    ftgen 0, 0, 16, 2, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0  ; Tambourine
gisine ftgen 0, 0, 4096, 10, 1                                            ; Sine

gindx init 0


instr 1
  ktempo invalue "Tempo"
  ktick metro (ktempo*4)/60
  schedkwhen ktick, 0, 0, 2, 0, 0.001, 0
endin

instr 2
  #define VOICE(N)
  #
  iOnOff$N table gindx, gi$N
  schedkwhen iOnOff$N, 0, 0, p1+$N, 0, 0.2
  #
  $VOICE(1)
  $VOICE(2)
  $VOICE(3)
  $VOICE(4)
  $VOICE(5)
  $VOICE(6)
  gindx wrap gindx+1, 0, 16
  turnoff
endin

instr 3                               ; Sound 1 - bass drum
  p3 = 0.2                            ; Define duration for this sound
  aenv expon rnd(0.5)+0.5, p3, 0.001  ; Amplitude envelope - percussive decay
  kcps expon 200, p3, 20              ; Pitch glissando
  asig oscil aenv*0.5, kcps, gisine   ; Oscillator
  out asig                            ; Send audio to outputs
endin

instr 4     ; Sound 2 - kalimba (bar model)
  p3 = 2.6  ; Define duration for this sound
  ; Kalimba sound created using barmodel opcode (see csound manual for more info.)
  asig barmodel 1, 1, 80, 1, 0, 2.6, 0.5, 6000, 0.07
  out asig*(rnd(0.5)+0.5)*0.1  ; Send audio to outputs and attenuate  using gain controls
endin

instr 5                               ; Sound 3 - snare
  p3 = 0.15                           ; Define duration for this sound
  aenv expon rnd(0.5)+0.5, p3, 0.001  ; Amplitude envelope - percussive decay
  anse noise 1, 0                     ; Create noise component for snare drum sound
  ; Create tone component frequency glissando for snare drum sound
  kcps expon 400, p3, 20
  ajit randomi 0.2, 1.8, 10000        ; Jitter on frequency for tone component
  atne oscil aenv, kcps*ajit, gisine  ; Create tone component
  asig sum anse*0.5, atne*5           ; Mix noise and tone sound components
  ; Pass signal through a comb filter to create static harmonic resonance
  ares comb asig, 0.02, 0.0035
  ; Send audio to outputs, apply envelope and attentuate using gain controls
  out ares*aenv*0.1
endin

instr 6                               ; Sound 4 - closed hi-hat
  turnoff2 7, 0, 0                    ; Turn off all instances of instr 7 (open hi-hat)
  p3 = 0.1                            ; Define duration for this sound
  aenv expon rnd(0.5)+0.5, p3, 0.001  ; Amplitude envelope - percussive decay
  asig noise aenv*0.3, 0              ; Create sound for closed hi-hat
  asig buthp asig, 7000               ; Highpass filter sound
  out asig                            ; Send audio to outputs
endin

instr 7                               ; Sound 5 - open hi-hat
  p3 = 1                              ; Define duration for this sound
  aenv expon rnd(0.5)+0.5, p3, 0.001  ; Amplitude envelope - percussive decay
  asig noise aenv*0.3, 0              ; Create sound for closed hi-hat
  asig buthp asig, 7000               ; Highpass filter sound
  out asig                            ; Send audio to outputs
endin

instr 8     ; Sound 6 - tambourine
  p3 = 0.5  ; Define duration for this sound
  ; Tambourine sound created using tambourine physical modelling opcode (see csound manual
  ; for more info.)
  asig tambourine 0.1, 0.01, 32, 0.47, 0, 2300, 5600, 8000
  out asig*(rnd(0.5)+0.5)  ; Send audio to outputs
endin
</CsInstruments>
<CsScore>
i 1 0 300
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1030</x>
 <y>237</y>
 <width>515</width>
 <height>284</height>
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
  <width>508</width>
  <height>280</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Simple Loop Sequencer</label>
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
   <r>244</r>
   <g>248</g>
   <b>200</b>
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
  <x>6</x>
  <y>84</y>
  <width>499</width>
  <height>195</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------
This example demonstrates a simple method for creating a looping step sequencer that doesn't used the 'timedseq' opcode.
Note triggers for each instrument are stored in GEN 2 function table, 1 meaning play a note, 0 meaning don't.
This example can easily be expanded to create more elaborate pattern but I have kept it simple so far to provide a basic starting point.

This method is less flexible than the method using timedseq but for simple rhythmical patterns will probably be adequate.</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>16</x>
  <y>52</y>
  <width>80</width>
  <height>30</height>
  <uuid>{ab2263b1-0628-47c5-9db6-34777794227c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tempo :</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>Tempo</objectName>
  <x>97</x>
  <y>52</y>
  <width>60</width>
  <height>30</height>
  <uuid>{163e9b1f-3627-4639-b0d1-b01a2d21e248}</uuid>
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
  <minimum>1</minimum>
  <maximum>240</maximum>
  <randomizable group="0">false</randomizable>
  <value>90</value>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

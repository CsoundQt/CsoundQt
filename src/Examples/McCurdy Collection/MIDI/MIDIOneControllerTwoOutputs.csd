; Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add scope for fun


; my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 2      ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


instr 1  ; Simple beep instrument - can be activated via a connected MIDI keyboard

  ; Output opcode channel | ctrlnumber | minimum | maximum
  ; Read controller information from continuous controller number 1 on MIDI channel 1 and
  ; rescale to be within the range 8 - 9. Both ctrl7s reference the same MIDI controller
  koct1 ctrl7 1, 1, 8, 9
  ; Read controller information from continuous controller number 1 on MIDI channel 1 and
  ; rescale to be within the range 8 - 7. Both ctrl7s reference the same MIDI controller
  koct2 ctrl7 1, 1, 8, 7

  ; Output opcode amplitude |  frequency   | f.n.
  ; Two oscillators are created with different frequencies - frequency variables must be
  ; converted into cps format from oct format
  asig1 oscili 0.25, cpsoct(koct1), 1
  ; Two oscillators are created with different frequencies - frequency variables must be
  ; converted into cps format from oct format
  asig2 oscili 0.25, cpsoct(koct2), 1

  ; The two oscillators are mixed and sent to the output
  outs (asig1 + asig2), (asig1 + asig2)
endin
</CsInstruments>
<CsScore>
f 1 0 129 10 1  ; Sine wave
i 1 0 3600      ; Instrument 1 plays a note for 1 hour
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1172</x>
 <y>505</y>
 <width>498</width>
 <height>298</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>170</r>
  <g>170</g>
  <b>170</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>492</width>
  <height>292</height>
  <uuid>{c37e13f6-7642-465f-9b2a-f059eef7bce8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>A Single MIDI controller creates two Csound variables</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>25</y>
  <width>484</width>
  <height>170</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------------------------------------
Move controller 1 on MIDI channel 1 or the modulation wheel on a MIDI keyboard set to channel 1. There is nothing to prevent you from using several instances of ctrl7 which reference the same MIDI controller. In this example the frequencies of two different oscillators are both driven by MIDI controller 1 on MIDI channel 1. The ranges of the two ctrl7s outputs are different however. As controller 1 is moved from minimum to maximum the pitch of oscillator 1 moves from C4 up to C5 but the pitch of oscillator 2 move from C4 down to C3.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>8</x>
  <y>193</y>
  <width>480</width>
  <height>94</height>
  <uuid>{eae32263-3d06-4f56-8de0-7386f6c41439}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

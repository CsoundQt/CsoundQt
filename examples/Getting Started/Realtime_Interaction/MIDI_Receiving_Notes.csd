/*Getting started.. Realtime Interaction: MIDI Notes

Select the MIDI input port in QuteCsounds "preferences" menu under the tab "run" -> "RT MIDI Module". Then you can choose between "portmidi" or "virtual". "portmidi" with option "a", enables all available midi-devices. "Virtual" enables the virtual midikeyboard, which you can play with your alphabetic computer keyboard.

Without modification, the MIDI-Channel-Number selects the Csound Instrument Number.  (MIDI Ch 1 = instr 1, MIDI Ch 2 = instr 2, ...)
To route the desired MIDI-information (note-number and velocity) to the p-arguments (4 and 5), it will be defined in CsOptions:
--midi-key-cps=4 --midi-velocity=5
Each instrument can be played polyphonic, and every voice has independent velocity.

The opcode 'massign' can be used, to make new connections between MIDI-Ch. and Csound Instruments. In this case, "massign 0, 1" assigns all MIDI-Channels to instrument 1.

*/
<CsoundSynthesizer>
<CsOptions>
 --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>
<CsInstruments>
massign 0, 1								; assign all midi-channels to instr 1

instr 1
anote     oscils     p5, p4, 0
kenv     madsr     0.01, 0.1, 0.9, 0.01					; defining the envelope
out     anote * kenv							; scaling the source-signal with the envelope
endin
</CsInstruments>
<CsScore>
e 3600
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann & Joachim Heintz (Dec. 2009) - Incontri HMT-Hannover 

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1013</x>
 <y>279</y>
 <width>563</width>
 <height>397</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>7</r>
  <g>95</g>
  <b>162</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>25</x>
  <y>24</y>
  <width>137</width>
  <height>53</height>
  <uuid>{9bdfe824-cf72-4d54-ad73-95b589534259}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>..nothing here!</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" x="60" y="304" width="513" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

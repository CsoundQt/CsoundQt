<CsoundSynthesizer>
<CsOptions>
-Ma
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

; By Joachim Heintz 2010
; This csd allows triggering multiple csound instruments from a single MIDI note.

         massign   0, 1; assign all incoming midi to instr 1
giInstrs  ftgen     0, 0, -5, -2, 2, 3, 4, 10, 100; instruments to be triggered

 opcode MidiTrig, 0, io
;triggers the first inum instruments in the function table ifn by a midi event, with fractional numbers containing channel and note number information
ifn, inum  xin; if inum=0 or not given, all instrument numbers in ifn are triggered
inum      =         (inum == 0 ? ftlen(ifn) : inum)
inote     notnum
ichn      midichn
iturnon   =         0
turnon:
iinstrnum tab_i     iturnon, ifn
 if iinstrnum > 0 then
ifracnum  =         iinstrnum + ichn/100 + inote/100000
         event_i   "i", ifracnum, 0, -1
 endif
         loop_lt   iturnon, 1, inum, turnon

kend      release
 if kend == 1 then
kturnoff  =         0
turnoff:
kinstrnum tab       kturnoff, ifn
 if kinstrnum > 0 then
kfracnum  =         kinstrnum + ichn/100 + inote/100000
         event     "i", -kfracnum, 0, 1
         loop_lt   kturnoff, 1, inum, turnoff
 endif
 endif
 endop

 instr 1; global midi instrument
         MidiTrig  giInstrs, 2; triggers the first two instruments in the giInstrs table
 endin

 instr 2
ichn      =         int(frac(p1)*100)
inote     =         round(frac(frac(p1)*100)*1000)
         prints    "instr %f: ichn = %f, inote = %f%n", p1, ichn, inote
         printks   "instr %f playing!%n", 1, p1
 endin

 instr 3
ichn      =         int(frac(p1)*100)
inote     =         round(frac(frac(p1)*100)*1000)
         prints    "instr %f: ichn = %f, inote = %f%n", p1, ichn, inote
         printks   "instr %f playing!%n", 1, p1
 endin


</CsInstruments>
<CsScore>
f 0 36000
e
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>757</x>
 <y>268</y>
 <width>253</width>
 <height>152</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>27</x>
  <y>12</y>
  <width>202</width>
  <height>127</height>
  <uuid>{4b805386-0c5c-4b8f-beb9-6464db5856f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This csd shows how to layer csound instruments triggered by a single MIDI note.</label>
  <alignment>center</alignment>
  <font>Times New Roman</font>
  <fontsize>20</fontsize>
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
<MacGUI>
ioView background {0, 0, 0}
ioText {23, 24} {184, 78} label 0.000000 0.00100 "" center "Times New Roman" 20 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder This csd shows how to layer csound instruments triggered by a single MIDI note.
</MacGUI>

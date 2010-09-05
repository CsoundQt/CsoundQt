see http://en.flossmanuals.net/bin/view/Csound/CONTROLSTRUCTURES

<CsoundSynthesizer>
<CsInstruments>

  instr 1
icount    =         0
Sname     =         ""; starts with an empty string
loop:
ichar     random    65, 90.999
Schar     sprintf   "%c", int(ichar); new character
Sname     strcat    Sname, Schar; append to Sname
          loop_lt   icount, 1, 10, loop; loop construction
          printf_i  "My name is '%s'!\n", 1, Sname; print result
  endin

</CsInstruments>
<CsScore>
; call instr 1 ten times
r 10
i 1 0 0
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>630</x>
 <y>260</y>
 <width>380</width>
 <height>205</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>230</r>
  <g>140</g>
  <b>36</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {59117, 36032, 9346}
</MacGUI>

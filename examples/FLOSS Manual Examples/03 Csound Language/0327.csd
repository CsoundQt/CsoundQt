see http://en.flossmanuals.net/bin/view/Csound/CONTROLSTRUCTURES

<CsoundSynthesizer>
<CsInstruments>

  instr 1 ;i-time loop: counts from 1 until 10 has been reached
icount    =         1
count:
          print     icount
icount    =         icount + 1
 if icount < 11 igoto count
          prints    "i-END!%n"
  endin

  instr 2 ;k-rate loop: counts in the 100th k-cycle from 1 to 11
kcount    init      0
ktimek    timeinstk ;counts k-cycle from the start of this instrument
 if ktimek == 100 kgoto loop
  kgoto noloop
loop:
          printks   "k-cycle %d reached!%n", 0, ktimek
kcount    =         kcount + 1
          printk2   kcount
 if kcount < 11 kgoto loop
          printks   "k-END!%n", 0
noloop:
  endin

</CsInstruments>
<CsScore>
i 1 0 0
i 2 0 1
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

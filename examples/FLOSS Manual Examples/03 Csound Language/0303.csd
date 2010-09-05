see http://en.flossmanuals.net/bin/view/Csound/InitAndPerfPass

<CsoundSynthesizer>
<CsInstruments>
sr = 44100
ksmps = 4410

instr 1
icount    init      0; set icount to 0 first
icount    =         icount + 1; increase
          print     icount; print the value
endin

</CsInstruments>
<CsScore>
i 1 0 1
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

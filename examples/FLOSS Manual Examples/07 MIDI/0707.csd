see http://en.flossmanuals.net/bin/view/Csound/TRIGGERINGINSTRUMENTINSTANCES

<CsoundSynthesizer>
<CsOptions>
-Ma
</CsOptions>
<CsInstruments>

;this example does not use audio so 'sr' and 'nchnls' have been omitted
ksmps = 32

  instr 1
kPchBnd pchbend; read in pitch bend information
kTrig1  changed kPchBnd; if 'kPchBnd' changes generate a trigger ('bang')
 if kTrig1=1 then
printks "Pitch Bend Value: %f%n", 0, kPchBnd; print kPchBnd to console only when its value changes
 endif

kAfttch aftouch; read in aftertouch information
kTrig2  changed kAfttch; if 'kAfttch' changes generate a trigger ('bang')
 if kTrig2=1 then
printks "Aftertouch Value: %d%n", 0, kAfttch; print kAfttch to console only when its value changes
 endif
  endin

</CsInstruments>
<CsScore>
f 0 300
e
</CsScore>
<CsoundSynthesizer>


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

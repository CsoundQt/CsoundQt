see http://www.flossmanuals.net/csound/ch046_c-working-with-controllers

<CsoundSynthesizer>
<CsOptions>
-Ma
</CsOptions>
<CsInstruments>
;Example by Iain McCurdy

;this example does not use audio so 'sr' and 'nchnls' have been omitted
ksmps = 32

  instr 1
kCtrl    ctrl7    1,1,0,127; read in midi controller #1 on channel 1
kTrigger changed  kCtrl; if 'kCtrl' changes generate a trigger ('bang')
 if kTrigger=1 then
printks "Controller Value: %d%n", 0, kCtrl; print kCtrl to console only when its value changes
 endif
  endin

</CsInstruments>
<CsScore>
i 1 0 300
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
ioView background {59110, 35980, 9252}
</MacGUI>

see http://www.flossmanuals.net/csound/ch047_e-midi-output

<CsoundSynthesizer>

<CsOptions>
; amend device number accordingly
-Q999
</CsOptions>

<CsInstruments>
;Example by Iain McCurdy

ksmps = 32 ;no audio so sr and nchnls omitted

  instr 1
; read values in from p-fields
kchn    =        p4
knum    random   48,72.99; note numbers will be chosen randomly across a 2 octave range
kvel    random   40, 115; velocities are chosen randomly
krate   randomi  1,2,1; rate at which new notes will be output
ktrig   metro    krate^2; 'new note' trigger
        midion2  kchn, int(knum), int(kvel), ktrig; send a midi note whenever ktrig=1
  endin

</CsInstruments>

<CsScore>
i 1 0 20 1
f 0 21; extending performance time prevents the final note-off from being lost
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
ioView background {59110, 35980, 9252}
</MacGUI>

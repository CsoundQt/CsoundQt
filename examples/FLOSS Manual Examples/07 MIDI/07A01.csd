see http://booki.flossmanuals.net/csound/

<CsoundSynthesizer>
<CsOptions>
-Ma ;activates all midi devices
</CsOptions>
<CsInstruments>
;Example by Iain McCurdy

;no audio so no 'sr' or 'nchnls'
ksmps = 32

 ;using massign with these arguments disables Csound's default instrument triggering
massign	0,0

  instr 1
kstatus, kchan, kdata1, kdata2  midiin; read in midi
ktrigger  changed  kstatus, kchan, kdata1, kdata2; trigger if midi data changes
 if	 ktrigger=1&&kstatus!=0	then; conditionally branch when trigger is received and when status byte is something other than zero
printks "status:%d%tchannel:%d%tdata1:%d%tdata2:%d%n", 0, kstatus, kchan, kdata1, kdata2; print midi data to the terminal with formatting
 endif
  endin

</CsInstruments>

<CsScore>
i 1 0 3600; run midi scanning for 1 hour
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

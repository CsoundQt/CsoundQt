<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -nm0
</CsOptions>
<CsInstruments>
ksmps = 32

instr 1
iArr[][] init   2,3
iArr     fillarray  1,2,3,7,6,5
iRow     =      0
until iRow == 2 do
iColumn  =      0
  until iColumn == 3 do
  prints "iArr[%d][%d] = %d\n", iRow, iColumn, iArr[iRow][iColumn]
  iColumn +=    1
enduntil
iRow      +=    1
od
endin

</CsInstruments>
<CsScore>
i 1 0 0
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>

<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -nm0
</CsOptions>
<CsInstruments>
ksmps = 32

gk_2d_Arr[][] init   2,3 ;two lines, three columns
gk_2d_Arr     fillarray  1,2,3,4,5,6


instr FirstContent
prints "First content of array gk_2d_arr:\n"
schedule "PrintContent", 0, 1
endin

instr ChangeRow
k_1d_Arr[] fillarray 7,8,9
gk_2d_Arr setrow k_1d_Arr, 0 ;change first row
prints "\nContent of gk_2d_Arr after having changed the first row:\n"
event "i", "PrintContent", 0, 1
turnoff
endin

instr GetRow
k_Row2[] getrow gk_2d_Arr, 1 ;second row as own array
prints "\nSecond row as own array:\n"
kColumn = 0
until kColumn == 3 do
 printf "k_Row2[%d] = %d\n", kColumn+1, kColumn, k_Row2[kColumn]
 kColumn +=    1
od

turnoff
endin

instr PrintContent
kRow     =      0
until kRow == 2 do
 kColumn  =      0
 until kColumn == 3 do
  printf "gk_2d_Arr[%d][%d] = %d\n", kColumn+1, kRow, kColumn, gk_2d_Arr[kRow][kColumn]
  kColumn +=    1
 od
kRow      +=    1
od
turnoff
endin

</CsInstruments>
<CsScore>
i "FirstContent" 0 1
i "ChangeRow" .1 1
i "GetRow" .2 1
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

<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../SourceMaterials -dnm0
</CsOptions>
<CsInstruments>
ksmps=32

pyinit
giInstanceLocal = 0
giInstanceGlobal = 0

instr 1 ;local python variable 'value'
kTime timeinstk
pylassigni "value", p4
giInstanceLocal = giInstanceLocal+1
if kTime == int(kr/2) then
kvalue pyleval "value"
printks "Python variable 'value' in instr %d, instance %d = %d\n", 0, p1, giInstanceLocal, kvalue
turnoff	
endif
endin

instr 2 ;global python variable 'value'
kTime timeinstk
pyassigni "value", p4
giInstanceGlobal = giInstanceGlobal+1
if kTime == int(kr/2) then
kvalue pyleval "value"
printks "Python variable 'value' in instr %d, instance %d = %d\n", 0, p1, giInstanceGlobal, kvalue
turnoff	
endif
endin

</CsInstruments>
<CsScore>
;        p4
i 1 0 1  100
i 1 0 1  200
i 1 0 1  300
i 1 0 1  400

i 2 2 1  1000
i 2 2 1  2000
i 2 2 1  3000
i 2 2 1  4000
</CsScore>
</CsoundSynthesizer>
;Example by Andrés Cabrera and Joachim Heintz
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

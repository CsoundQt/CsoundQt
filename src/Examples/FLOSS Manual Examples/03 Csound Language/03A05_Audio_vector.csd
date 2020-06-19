<CsoundSynthesizer>
<CsInstruments>
sr = 44100
ksmps = 5
0dbfs = 1

instr 1
aSine      oscils     1, 2205, 0
kVec1      vaget      0, aSine
kVec2      vaget      1, aSine
kVec3      vaget      2, aSine
kVec4      vaget      3, aSine
kVec5      vaget      4, aSine
           printks    "kVec1 = %f, kVec2 = %f, kVec3 = %f, kVec4 = %f, kVec5 = %f\n",
                      0, kVec1, kVec2, kVec3, kVec4, kVec5
endin
</CsInstruments>
<CsScore>
i 1 0 [1/2205]
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

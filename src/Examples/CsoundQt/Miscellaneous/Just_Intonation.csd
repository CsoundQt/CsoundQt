<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1  ; Equal temperament
; p4 in pitch class
xtratim 0.3
aenv linenr 0.4, 0.01, 0.3, 0.01
aout oscili aenv, cpspch(p4), 1
outs aout*p5, aout*(1-p5)
endin

instr 2  ; Just intonation
; p4 in interval fraction
xtratim 0.3
aenv linenr 0.4, 0.01, 0.3, 0.01
aout oscili aenv, p4 * cpspch(8.00), 1
outs aout*p5, aout*(1-p5)
endin


</CsInstruments>
<CsScore>
f 1 0 1024 10 1
; Equal tempered
i 1 0 3 8.00 0
i . 0 . 9.00 1
i . + . 8.00 0
i . ^+0 . 8.07 1
i . + . 8.00 0
i . ^+0 . 8.04 1
i . + . 8.00 0
i . ^+0 . 8.10 1
i . + . 8.00 0
i . ^+0 . 8.04 1
i . ^+0 . 8.07 0
i . ^+0 . 8.10 1
i . + . 8.00 1
i . ^+0 . 8.04 1
i . ^+0 . 8.07 0
i . ^+0 . 8.10 0
s
; Now with just intonation

i 2 0 3 [1/1] 0
i . 0 . [2/1] 1
i . + . [1/1] 0
i . ^+0 . [3/2] 1
i . + . [1/1] 0
i . ^+0 . [5/4] 1
i . + . [1/1] 0
i . ^+0 . [7/4] 1
i . + . [1/1] 0
i . ^+0 . [5/4] 1
i . ^+0 . [3/2] 0
i . ^+0 . [7/4] 1
i . + . [1/1] 1
i . ^+0 . [5/4] 1
i . ^+0 . [3/2] 0
i . ^+0 . [7/4] 0
e
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>656</x>
 <y>80</y>
 <width>620</width>
 <height>359</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>62</r>
  <g>162</g>
  <b>69</b>
 </bgcolor>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>9</x>
  <y>8</y>
  <width>290</width>
  <height>299</height>
  <uuid>{efed7bdd-1a9e-49ef-9f95-15ddcc36e9ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>-255.00000000</value>
  <type>lissajou</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>2.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>310</x>
  <y>10</y>
  <width>277</width>
  <height>255</height>
  <uuid>{bda8811b-e831-48b2-969a-5b571eb11896}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>
This file shows the difference for a few intervals with Equal temperament and Just Intonation. One note of the interval is placed on the left channel and the other note on the right. The lissajous scope on the left shows the correlation between the channels. Since just intonation intervals are more closely related the graphic display is cleaner.</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>TeX Gyre Heros</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Play</objectName>
  <x>310</x>
  <y>273</y>
  <width>278</width>
  <height>33</height>
  <uuid>{52bc96cf-049f-41b8-9103-1186aaea8fdd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Run</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

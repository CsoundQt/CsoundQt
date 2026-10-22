/* Getting started..  Control structures

In this example, we concentrate on doing the same thing, until a specific limit is reached. 

If I say: 
Put 5 T-Shirts into your bag, then you can start with this algorithm in your head.
	1. You take one T-Shirt and put it in the bag
	2. You count: One
	3. You compare one to five. Conclusion..you need more TShirts, so do it again..
	4. You start with 1., then do 2. and 3.
	..
	5. You count: Five
	6. You compare five to five. Conclusion..done, task fullfilled!


But why should we do that, if Csound could do this for us?

See:
Conditional Values (ControlConditional - Shift+F1)
Program Flow Control (ControlPgmctl - Shift+F1)
*/

<CsoundSynthesizer>
<CsOptions>
;-n -m0
</CsOptions>
<CsInstruments>

ksmps = 64


instr 1
  ; Csound 7 can do the counting for us. The end of the range is inclusive:
  for idx in [1 ... 5] do
    prints "Take a  T-Shirt and put it in the bag! \n"
    prints " Now we have %i T-Shirts in the bag..\n", idx
  od
endin



instr 2
  ; The same five iterations can start at zero. The range [0 ... 4]
  ; also ends inclusively, so it has five elements.
  for idx in [0 ... 4] do
    prints "Take a  T-Shirt and put it in the bag! \n"
    prints " Now we have %i T-Shirts in the bag..\n", idx+1
  od
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 0
i 2 1 1
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Mar. 2010) - Incontri HMT-Hannover 
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1013</x>
 <y>279</y>
 <width>563</width>
 <height>397</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>57</x>
  <y>46</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8f2703e4-5434-4ee1-8ddd-dd5a2a139033}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Nothing here...</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

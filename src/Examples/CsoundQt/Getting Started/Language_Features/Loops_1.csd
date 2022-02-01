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


instr 1
; Lets write this in Csound-Language using the "if" statement:
iIndex = 0							; Number of T-Shirts in the bag at the beginning
	loop:							; any label
	  prints "Take a  T-Shirt and put it in the bag! \n"
	  iIndex =  iIndex+1				; Count..one more
	  prints " Now we have %i T-Shirts in the bag..\n", iIndex
	if (iIndex < 5) igoto loop			; goes back to the label "loop", if there are less then 5 T-Shirts
endin



instr 2
; There is another way to do exactly the same by using "loop_lt":
iIndex = 0		 				; Number of T-Shirts in the bag at the beginning
	loop:	  
	  prints "Take a  T-Shirt and put it in the bag! \n"
	  prints " Now we have %i T-Shirts in the bag..\n", iIndex+1 
	loop_lt iIndex, 1, 5, loop 		; goes back to the label "loop", if there are less then 5 T-Shirts
endin 
/*
The advantage of this method is, that you save typing one line, because loop_lt  is increasing the counter for you. But you can't see so easily which condition is checked. Is it x<5 or x>5 or x=5 ? Here is a list of different loop-types, and their behavior:

loop_lt:  x < y
loop_gt: x > y
loop_ge: x >= y
loop_le : x <= y
*/

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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>57</x>
  <y>46</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8f2703e4-5434-4ee1-8ddd-dd5a2a139033}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Nothing here...</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="604" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

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
; There is an other way to do exactly the same by using "loop_lt":
iIndex = 0		 				; Number of T-Shirts in the bag at the beginning
	loop:	  
	  prints "Take a  T-Shirt and put it in the bag! \n"
	  prints " Now we have %i T-Shirts in the bag..\n", iIndex+1 
	loop_lt iIndex, 1, 5, loop 		; goes back to the label "loop", if there are less then 5 T-Shirts
endin 
/*
The advantage of this method is, that you save typing one line, because loop_lt  is increasing the counter for you. But you can't see so easily which condition is checked. Is it x<5 or x>5 or x=5 ? Here is a list of different loop-types, and their behavoir:

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

<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 883 62 400 489
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {65535, 65535, 65535}
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>
/* Getting started.. 1.1 Hello World

The 'Basics Chapter' of 'Getting started', will explain the root functionality of QuteCsound.
You find the descriptions as comments directly in the code. 

This first example is focused on the different comment-types and shows a simple program, which outputs the "Hello World" string to the console and a "Hello World - 440Hz beep" to the computers audio output.

To start it, press the RUN Button in the QuteCsound-toolbar, or choose "Control->RunCsound" from the menu. 
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; This is a comment!
; Comments describe how things are done, and help to explain the code.

/*
If you need more space than one line,
it's
no
problem, with those comment signs used here.
*/

instr 123 						; instr starts an instrument block and refers it to a number. In this case, it is 123.
							; You can put comments everywhere, they will not become compiled.
	
	      prints "Hello World!%n" 	; The 'prints', will print the following string to the Csound console.
	aSin	oscils 0dbfs/5, 440, 0 	; the opcode 'oscils' generates a 440 Hz sinetone
	      out aSin				; here the signal is assigned to the computer audio output
endin

</CsInstruments>

<CsScore>
i 123 0 1 						; the instrument is called by its number(123) to be evaluated
e 							; e - ends the score
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Nov. 2009) - Incontri HMT-Hannover 
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 573 94 306 359
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41120, 40606, 41634}
ioListing {24, 2} {250, 158}
ioText {25, 166} {249, 164} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This is a widget window. In this case, the Console Output is also visible here. More information about widgets can be found in the menu: Examples-> Widgets
</MacGUI>


/* Getting started..  Control structures

Let's add tones, the same way, as we've put T-Shirts into the bag!

*/
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

seed 0; makes the random choice each time different

instr 100  ; Oscillator
irand random 0, p4
kEnv     madsr     0.1, 0.1, 0.9, 0.1	
a1 oscils 0.1, 440*(2^(irand/12)), 0	; Sine-Osc, producing random freqs between 440 and 1760 hz
outs a1*kEnv, a1*kEnv
endin

; The "if" method..
instr 1
iIndex = 0						; index
iLimit = p4
loop1:							; label
	event_i "i",100, 0, 1, iLimit		; this generates a scoreline from the instrument..
	prints "Instance of instr 100 by loop1_%d created!%n", iIndex+1
	iIndex =  iIndex+1
if (iIndex < 5) igoto loop1
endin

; Using loop_lt..
instr 2
iIndex = 0							; index
iLimit = p4
loop2:								; label
	event_i "i",100, 0, 1, iLimit			; this generates a scoreline from the instrument..
	prints "Instance of instr 100 by loop2_%d created!%n", iIndex+1
loop_lt iIndex, 1, 5, loop2
endin
</CsInstruments>

<CsScore>
i 1 0 2 24
i 2 3 2 24
i 2 5 2 12
i 2 7 2 2
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
WindowBounds: 955 256 400 214
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {65535, 65535, 65535}
ioGraph {24, 26} {350, 150} scope 2.000000 -1.000000 
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>
/*Getting started.. Function-Tables

It is also possible to create and fill an f-table from within the orchestra. In this case, the 'ftgen' opcode is used.

Filling an f-table directly from within the orchestra looks like this:
giMyNumbers ftgen 12, 0, -7, -2, 1, 2, 3, 4, 5, 6, 7
Here the f-table No. 12 has the size 7 and is filled with this list of numbers: [1, 2, 3, 4, 5, 6, 7]


gir ftgen ifn, itime, isize, igen, iarga [, iargb ] [...] 
gir     - the number of the table created. Global variables can be read independent from the current instrument, useful here
ifn     - is the number of the F-Table, and will be your later keycode to read it out
	    If ifn is zero, the number is assigned automatically and the value placed in gir.
itime   - says when this becomes calculated
isize   - sets the size of the table
igen    - the number of the GEN ROUTINE
iaga..b - arguments used by the GEN ROUTINES to calculate the numbers

*/
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

giSine ftgen 1, 0, 4096, 10, 1		;a sinewave will be generated and stored into Table No. 1
giAdd7Sine ftgen 2, 0, 4096, 10, 1, 1, 1, 1, 1, 1, 1, 1	;a sinewave and 6 harmonics
giNoise ftgen 3, 0, 4096, 21, 1		; White Noise
giMyNumbers ftgen	 0, 0, -3, -2, 1, 2, 3 ; [1, 2, 3] - becomes automatically table number 4


instr 1
iLength = ftlen(giMyNumbers)
iMyNumber tab_i (p2%(iLength)), giMyNumbers
aEnv madsr 0.1, 0.1, 1, 0.3
aWavetablePlayer oscili p4, cpspch(p5), (iMyNumber)
outs aWavetablePlayer*aEnv, aWavetablePlayer*aEnv
endin

</CsInstruments>

<CsScore>
;ins strt dur  amp  freq  		table-number
t 0 220

i 1 1 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0

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
WindowBounds: 983 224 418 443
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {65535, 65535, 65535}
ioGraph {7, 61} {395, 120} table 0.000000 1.000000 
ioGraph {6, 223} {400, 158} scope 2.000000 -1.000000 
ioText {6, 5} {396, 58} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder In this graph, one can see the result of the  generated F-Table values.
ioText {7, 193} {398, 31} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder The output-waveform..
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>
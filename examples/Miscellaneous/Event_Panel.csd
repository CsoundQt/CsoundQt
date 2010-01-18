<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; This file introduces the Live Event Panel of QuteCsound
; First Run this file!
; Then open the Live Event Panel window from the View Menu
; (If it's not currently at the front, you may need to hide it first and then show it)
; Right click there on the cells to see actions.
; Try the "Send events" action when standing over one of the event lines

instr 1 ;simple sine wave
ifreq = p4 ; in cps
iamp = p5 ; in relation to 0dbfs
iatt = p6 ; in seconds
idec = p7 ; in seconds
aenv linenr iamp, iatt, idec, 0.01
aout oscil aenv, ifreq, 1
outs aout, aout
endin

instr 2 ;saw wave
ifreq = p4 ; in cps
iamp = p5 ; in relation to 0dbfs
iatt = p6 ; in seconds
idec = p7 ; in seconds
aenv linenr iamp, iatt, idec, 0.01
aout vco2 1, ifreq
outs aout*aenv, aout*aenv
endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1
e 3600
</CsScore>
</CsoundSynthesizer>







<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 517 162 548 373
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView nobackground {59110, 56797, 54741}
ioText {17, 65} {504, 224} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {65280, 65280, 65280} background border ; This file introduces the Live Event Panel of QuteCsoundÂ¬; First Run this file!Â¬; Then open the Live Event Panel window from the View MenuÂ¬; (If it's not currently at the front, you may need to hide it first and then show it)Â¬; Right click there on the cells to see actions.Â¬; Try the "Send events" action when standing over one of the event linesÂ¬
ioButton {117, 296} {318, 29} value 1.000000 "_Play" "Run" "/" 
ioText {17, 9} {503, 47} label 0.000000 0.00100 "" center "DejaVu Sans" 20 {0, 0, 0} {43520, 65280, 65280} background border New Label
</MacGUI>


<EventPanel name="Demo" tempo="60.00000000" loop="8.00000000" name="Demo" x="668" y="365" width="603" height="374"> 
i 1 0 1 440 0.2 0.3 1 
i 1 0 1 880 0.2 0.3 1 
i 1 0 1 220 0.2 0.3 1 
 
i 1 0 1 220 0.2 0.3 1 
i 1 1 1 220 0.2 0.3 1 
i 1 2 1 220 0.2 0.3 1 
 
 </EventPanel>

<EventPanel name="Demo" tempo="60.00000000" loop="8.00000000" name="Demo" x="464" y="149" width="762" height="583"> 
i 1 0 1 440 15000 0.3 1 
i 1 0 1 880 15000 0.3 1 
i 1 0 1 220 15000 0.3 1 
 
i 2 0 1 220 15000 0.3 1 
i 2 1 1 440 15000 0.3 1 
i 2 2 1 880 15000 0.3 1 
 
i 2 0 100 440 15000 0.3 1 
i -2 0 100 ;off 
 
 
 
 </EventPanel>

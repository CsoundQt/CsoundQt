<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1
kfreq line 300, abs(p3), 1000
aout oscil 0.2, kfreq, 1
outs aout, aout
endin

instr 2 ; Same as above but with envelope
kfreq line 300, abs(p3), 1000
kenv linenr 0.2, 1, 1, 0.01
aout oscil kenv, kfreq, 1
outs aout, aout
endin

</CsInstruments>
<CsScore>
f 1 0 1024 10 1

i 1 0 -30  ; Turn on held note

i -1 ^+1 1  ;Turn it off

i 1.1 ^+1 -20  ;Turn on note 1.1
i 1.2 ^+2 -20  ;Turn on note 1.2

i -1.2 ^+0.5 1  ;Turn off 1.2
i -1.1 ^+1 1  ;Turn off 1.1

i 2 ^+1 -20  ;Turn on instr 2
i -2 ^+3 1  ;Turn off instr 2

; For information on Score processing (e.g the ^character
; stand on the i character and press Shift+F1
; or stand on the i and go to Help->Show Opcode Entry
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 457 242 286 426
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {0, 0, 0}
ioButton {8, 306} {249, 66} value 1.000000 "_Play" "Play" "/" 
ioText {8, 12} {249, 290} label 0.000000 0.00100 "" center "DejaVu Sans" 12 {0, 65280, 0} {65280, 65280, 65280} nobackground border You can turn off an instrument with a negative number in an i statement in the score.Â¬To create a held use a negative number in the duration. Notice that you'll have to use abs() to get the line opcode to work.Â¬To an instrument, turning off a note from the score is equivalent to a noteoff event so all "r" opcodes like linenr will start the release phase when the note is turned off.
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" name="" x="0" y="0" width="596" height="322"> 








</EventPanel>
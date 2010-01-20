/*Getting started.. Realtime Interaction: MIDI Notes

Select the MIDI input port in QuteCsounds "preferences" menu under the tab "run" -> "RT MIDI Module". Then you can choose between "portmidi" or "virtual". "portmidi" with option "a", enables all available midi-devices. "Virtual" enables the virtual midikeyboard, which you can play with your alphabetic computer keyboard.

Without modification, the MIDI-Channel-Number selects the Csound Instrument Number.  (MIDI Ch 1 = instr 1, MIDI Ch 2 = instr 2, ...)
To route the desired MIDI-information (note-number and velocity) to the p-arguments (4 and 5), it will be defined in CsOptions:
--midi-key-cps=4 --midi-velocity=5
Each instrument can be played polyphonic, and every voice has independent velocity.

The opcode 'massign' can be used, to make new connections between MIDI-Ch. and Csound Instruments. In this case, "massign 0, 1" assigns all MIDI-Channels to instrument 1.

*/
<CsoundSynthesizer>
<CsOptions>
 --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>
<CsInstruments>
massign 0, 1								; assign all midi-channels to instr 1

instr 1
anote     oscils     p5, p4, 0
kenv     madsr     0.01, 0.1, 0.9, 0.01					; defining the envelope
out     anote * kenv							; scaling the source-signal with the envelope
endin
</CsInstruments>
<CsScore>
e 3600
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann & Joachim Heintz (Dec. 2009) - Incontri HMT-Hannover 

<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 611 164 296 321
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {1799, 24415, 41634}
ioText {25, 24} {137, 53} label 0.000000 0.00100 "" left "Lucida Grande" 16 {65280, 65280, 65280} {65280, 65280, 65280} nobackground noborder ..nothing here!
</MacGUI>

<EventPanel name="Events" tempo="60.00000000" loop="8.00000000" name="Events" x="60" y="304" width="513" height="322"> 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 </EventPanel>
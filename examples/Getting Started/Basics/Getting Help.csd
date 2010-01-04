/*Getting started.. 1.5 Getting Help

General information about QuteCsound's buttons and windows, can be found in the 'Open Quick Reference Guide' located in the Help Menu.

Help for most of the used Csound vocabulary is available, by marking the words with the cursor and selecting
Show Opcode Entry from the Help Menu (or with shortcut: Shift+F1)

A short definition about opcodes' inputs and outputs, can be found on the QuteCsound status bar at the bottom when the cursor is over an opcode. 
As an example, click on the opcode 'line' below:

kres line ia, idur, ib 

1. "kres" is the output, in this case a k-rate signal
2. "line" is the opcode itself, if you need more information about what it's doing -> 'Shift F1'
3. "ia" sets the initial value, the line starts with
4. "idur" sets the duration value
5. "ib" sets the destination value

Notice that line must use i-type variables (so you can't change its behavior inside a note!)

Direct links to Manual chapters can be provided in the comments. For example, click on the word below and press Shift+F1:
CommandUnifile

Further Reading:
In the help menu is a direkt link to the Csound Manual and also to it's second chapter 'Opcodes Overview'.
On 'http://www.Csounds.com/tutorials' there are more tutorials, some are also available in different languages.
*/
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


sr = 44100 ;doubleclick on sr and press 'Shift + F1' for help
ksmps = 128
nchnls = 2
0dbfs = 1

instr 1

kFreq expon 1000, 10, 500
aOut oscili 0.2, kFreq, 1
outvalue "freqsweep", kFreq
outs aOut, aOut
endin


</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 10
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Nov. 2009) - Incontri HMT-Hannover 
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 860 199 290 222
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {41120, 40606, 41634}
ioText {21, 17} {241, 137} label 0.000000 0.00100 "" left "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This is a widget window. More information about widgets can be found in the menu: Examples-> Widgets
</MacGUI>


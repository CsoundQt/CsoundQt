/*Getting started.. 1.5 Getting Help

General information about CsoundQt's buttons and windows, can be found in the 'Open Quick Reference Guide' located in the Help Menu.

Help for most of the used Csound vocabulary is available, by marking the words with the cursor and selecting
Show Opcode Entry from the Help Menu (or with shortcut: Shift+F1)

A short definition about opcodes' inputs and outputs, can be found on the CsoundQt status bar at the bottom when the cursor is over an opcode. 
As an example, click on the opcode line below:

kres line ia, idur, ib 

1. kres - is the output, in this case a k-rate signal
2. line - is the opcode itself, if you need more information about what it's doing -> 'Shift F1'
3. ia   -sets the initial value, the line starts with
4. idur - sets the duration value
5. ib   -sets the destination value

Notice that line must use i-type variables (so you can't change its behavior inside a note!)

Direct links to Manual chapters can be provided in the comments. For example, click on the word below and press Shift+F1:
CommandUnifile
PartOpcodesOverview

Further Reading:
In the help menu is a direkt link to the Csound Manual and also to it's second chapter 'Opcodes Overview'.
On 'http://www.Csounds.com/tutorials' there are more tutorials, some are also available in different languages.
*/
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


sr = 44100 		;doubleclick on sr and press 'Shift + F1' for help
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
  <r>160</r>
  <g>158</g>
  <b>162</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>21</x>
  <y>17</y>
  <width>241</width>
  <height>137</height>
  <uuid>{f643e4a3-2682-4978-afb1-0a55dfaa1063}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This is a widget window. More information about widgets can be found in the menu: Examples-> Widgets</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

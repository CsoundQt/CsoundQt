/*Getting started.. 1.5 Getting Help

CsoundQt's documentation is at https://csoundqt.github.io/doc/ (also linked in the Help Menu).

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
In the help menu is a direkt link to the Csound Manual and also to it's second chapter 'Opcode Overview'.
The Csound FLOSS Manual offers an in-depth intruduction at https://flossmanual.csound.com/
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



<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>


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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>33</x>
  <y>19</y>
  <width>241</width>
  <height>137</height>
  <uuid>{f643e4a3-2682-4978-afb1-0a55dfaa1063}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>This is a widget window. More information about widgets can be found in the menu: Examples-> Widgets</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>20</x>
  <y>200</y>
  <width>248</width>
  <height>71</height>
  <uuid>{17ce6c00-b473-4ea4-9bf4-44a0304a85a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>This label displays the current frequency:</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>freqsweep</objectName>
  <x>110</x>
  <y>235</y>
  <width>144</width>
  <height>29</height>
  <uuid>{2a0e9cca-d3b3-4fbc-8e24-374c23d39941}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>674.407</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Nimbus Sans [urw]</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>182</r>
   <g>109</g>
   <b>0</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

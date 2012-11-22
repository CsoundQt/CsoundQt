/* Getting started.. 1.1 Hello World

The 'Basics Chapter' of the Tutorials, will explain the root functionality of CsoundQt.
You will find the descriptions as comments directly in the code. 

This first example is focused on the different comment-types and shows a simple program, which outputs a "Hello World - 440Hz beep" to the computer's audio output and the "Hello World" string to the console.

To start it, press the RUN Button in the CsoundQt-toolbar, or choose "Control->Run Csound" from the menu. 
*/

<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; This is a comment!
; Comments describe how things are done, and help to explain the code.
; They are shown in green in CsoundQt.
; Anything after a semicolon will be ignored by Csound, so you can use it for human readable information.

/*
If you need more space than one line,
it's
no
problem, with those comment signs used here.
*/

instr 123 					; instr starts an instrument block and refers it to a number. In this case, it is 123.
							; You can put comments everywhere, they will not become compiled.
	prints "Hello World!%n" 	     ; 'prints' will print a string to the Csound console.
	aSin	oscils 0dbfs/4, 440, 0 	; the opcode 'oscils' here generates a 440 Hz sinetone signal at -12dB FS
	out aSin				     ; here the signal is assigned to the computer audio output
endin

</CsInstruments>
<CsScore>
i 123 0 1 					; the instrument is called by its number (123) to be played
e 							; e - ends the score
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
 <bsbObject version="2" type="BSBConsole">
  <objectName/>
  <x>24</x>
  <y>2</y>
  <width>250</width>
  <height>158</height>
  <uuid>{1802f52a-87e1-4b4e-8d07-4995b2f04435}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <font>Courier</font>
  <fontsize>8</fontsize>
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
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>25</x>
  <y>166</y>
  <width>249</width>
  <height>164</height>
  <uuid>{7f895e8a-7492-42e7-ac81-27023be7ff44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This is a widget window. In this case, the Console Output is also visible here. More information about widgets can be found in the menu: Examples-> Widgets</label>
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

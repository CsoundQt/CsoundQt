<CsoundSynthesizer>
<CsOptions>
-m128
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 4
0dbfs = 1

chn_S("display-output",2)


/* CSOUND 7 — What's new 4: User Defined Opcodes
   =============================================
   
   User Defined Opcodes are not new but 
   1. They have a new syntax, and
   2. If this syntax is being used, the arrays
      use pass-by-reference instead of pass-by-copy.
   
   The old syntax remains valid, and if used, 
   it works as before as pass-by-copy.
*/

// written by joachim heintz 2025

/* General Syntax
   ==============
   
   opcode name(inargs):(outargs)
*/


opcode Destructive(arr:i[]):()
  for v,i in arr do
    arr[i] = -v
  od
endop

instr TestDestructive

  myarr:i[] = [1,2,3,4,5]
  printarray(myarr)
  Destructive(myarr)
  printarray(myarr)
  turnoff
  schedule(Show_TestDestructive,0,1)
endin

instr Show_TestDestructive

  show:S = {{The syntax for the new UDOs in Csound 7 is:
  
  opcode name(inargs):(outargs)
    ...
  endop

The main difference to the old UDOs is: Now the input arguments
are referenced directly by the UDO, and not as a copy.

This means that any input can now be changed destructively.
 
opcode Destructive(arr:i[]):()
  for v,i in arr do
    arr[i] = -v
  od
endop

instr TestDestructive
  myarr:i[] = [1,2,3,4,5]
  printarray(myarr)
  Destructive(myarr)
  printarray(myarr)
  turnoff
endin

returns:

   1.0000 2.0000 3.0000 4.0000 5.0000 
   -1.0000 -2.0000 -3.0000 -4.0000 -5.0000 

showing that 'myarr' has been changed by the UDO.
}}

  chnset(show,"display-output")

endin


opcode NonDestructive, 0, i[]
  arr:i[] xin
  for v,i in arr do
    arr[i] = -v
  od  
endop

instr TestNonDestructive

  myarr:i[] = [1,2,3,4,5]
  printarray(myarr)
  NonDestructive(myarr)
  printarray(myarr)
  turnoff
  schedule(Show_TestNonDestructive,0,1)

endin

instr Show_TestNonDestructive

  show:S = {{The syntax for the old UDOs in Csound 6 remains valid:
  
  opcode name,outypes,intypes
    ...
  endop

If this old syntax is being used, the arguments are passed as
copy of the variable, so no destructive operations can apply.

 
opcode NonDestructive, 0, i[]
  arr:i[] xin
  for v,i in arr do
    arr[i] = -v
  od  
endop

instr TestNonDestructive
  myarr:i[] = [1,2,3,4,5]
  printarray(myarr)
  NonDestructive(myarr)
  printarray(myarr)
  turnoff
endin

returns:

   1.0000 2.0000 3.0000 4.0000 5.0000 
   1.0000 2.0000 3.0000 4.0000 5.0000 

showing that 'myarr' has not been changed by the UDO.
}}

  chnset(show,"display-output")

endin


opcode Route(asigs:a[],hwouts:k[]):()
  for h,i in hwouts do
    outch(h,asigs[i])
  od
endop

instr ArrayRouting

  // array of hardware output channels (starting at 1)
  hw_out_chnls:k[] = [1,4]
  
  // array of audio signals
  audio_sigs:a[] = [poscil:a(.2,500),poscil:a(.2,400)]
  
  // output
  Route(audio_sigs,hw_out_chnls)
  
  schedule(Show_ArrayRouting,0,1)
endin

instr Show_ArrayRouting

  show:S = {{As one of many examples what to do with UDOs:
This UDO takes an array of audio signals and an array of 
hardware output channels, and routes the audio signals to the channels.

(You need four channels for the following example to run properly.)
  
opcode Route(asigs:a[],hwouts:k[]):()
  for h,i in hwouts do
    outch(h,asigs[i])
  od
endop

instr ArrayRouting

  // array of hardware output channels (starting at 1)
  hw_out_chnls:k[] = [1,4]
  
  // array of audio signals
  audio_sigs:a[] = [poscil:a(.2,500),poscil:a(.2,400)]
  
  // output
  Route(audio_sigs,hw_out_chnls)
  
endin

So the 500 Hz tone will output to channel 1, and the 
400 Hz tone will output to channel 4.
}}

  chnset(show,"display-output")

endin



</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>








<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>233</x>
 <y>169</y>
 <width>1080</width>
 <height>809</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
 <bsbObject type="BSBButton" version="2">
  <objectName>button0</objectName>
  <x>17</x>
  <y>61</y>
  <width>283</width>
  <height>42</height>
  <uuid>{9c6b0259-6016-411d-b9c8-a14161cc2423}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Destructive</text>
  <image>/</image>
  <eventLine>i "TestDestructive" 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>16</fontsize>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>display-output</objectName>
  <x>304</x>
  <y>61</y>
  <width>753</width>
  <height>703</height>
  <uuid>{dca2180d-3708-4a41-8865-eee375f49ef0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>As one of many examples what to do with UDOs:
This UDO takes an array of audio signals and an array of 
hardware output channels, and routes the audio signals to the channels.

(You need four channels for the following example to run properly.)
  
opcode Route(asigs:a[],hwouts:k[]):()
  for h,i in hwouts do
    outch(h,asigs[i])
  od
endop

instr ArrayRouting

  // array of hardware output channels (starting at 1)
  hw_out_chnls:k[] = [1,4]
  
  // array of audio signals
  audio_sigs:a[] = [poscil:a(.2,500),poscil:a(.2,400)]
  
  // output
  Route(audio_sigs,hw_out_chnls)
  
endin

So the 500 Hz tone will output to channel 1, and the 
400 Hz tone will output to channel 4.
</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Mono</font>
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
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button0</objectName>
  <x>17</x>
  <y>110</y>
  <width>283</width>
  <height>42</height>
  <uuid>{d0f0f4c4-8aae-4855-918c-eda974cc7d04}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Non Destructive</text>
  <image>/</image>
  <eventLine>i "TestNonDestructive" 0 1</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>16</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button0</objectName>
  <x>17</x>
  <y>160</y>
  <width>283</width>
  <height>42</height>
  <uuid>{be92a551-06c7-48d7-884c-f6d975ab5ba1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Array Routing</text>
  <image>/</image>
  <eventLine>i "ArrayRouting" 0 3</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>16</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>16</x>
  <y>14</y>
  <width>1040</width>
  <height>38</height>
  <uuid>{321802e3-d5a0-407d-a4e1-df59e780d96b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>What's New in Csound 7: New UDOs</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Lato Heavy</font>
  <fontsize>24</fontsize>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

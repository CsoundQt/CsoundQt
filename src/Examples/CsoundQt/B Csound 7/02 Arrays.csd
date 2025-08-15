<CsoundSynthesizer>
<CsOptions>
-m128
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

chn_S("display-output",2)


/* CSOUND 7 — What's new 2: ARRAYS
   ===============================
   
   Arrays are in Csound since 2013 but Csound 7 offers many new features which
   make using arrays easier and more similar to other programming languages.
*/

// written by joachim heintz 2025

instr Arr_1

  myarray:i[] = [1,2,3,5,8]
  puts("Elements in myarray:",1)
  show:S = "  "
  for el in myarray do
    show = strcat(show,sprintf("%d ",el))
  od
  puts(show,1)
  schedule(ShowArr_1,0,1)

endin

instr ShowArr_1

  show:S = {{It is now possible to write an array in the way we know from other programming languages:
  
    myarray:type[] = [element 1, element 2, ...]
    
Where type is i, k, a, S, for i-rate, k-rate, a-rate or string arrays.
This is a simple example for an i-array:
  
  myarray:i[] = [1,2,3,5,8]
  puts("Elements in myarray:",1)
  show:S = "  "
  for el in myarray do
    show = strcat(show,sprintf("%d ",el))
  od
  puts(show,1)

returns:

  Elements in myarray:
    1 2 3 5 8}}

  chnset(show,"display-output")

endin

instr Arr_2

  myarray:S[] = ["one","two","three","five","eight"]
  puts("Elements in myarray:",1)
  show:S = "  "
  for el in myarray do
    show = strcat(show,sprintf("\"%s\" ",el))
  od
  puts(show,1)
  schedule(ShowArr_2,0,1)

endin

instr ShowArr_2

  show:S = {{This is a simple example for a string array.
It does not matter whether we give it a variable name, or write it directly into brackets. Both forms are possible:

  myarray:S[] = ["one","two","three","five","eight"]
  for el in myarray do
    ...
  od

or

  for el in ["one","two","three","five","eight"] do
    ...
  od

The code
  
  myarray:S[] = ["one","two","three","five","eight"]
  puts("Elements in myarray:",1)
  show:S = "  "
  for el in myarray do
    show = strcat(show,sprintf("\"%s\" ",el))
  od
  puts(show,1)

returns:

  Elements in myarray:
    "one" "two" "three" "five" "eight"}}

  chnset(show,"display-output")

endin

instr Arr_3

  // two random k-rate envelopes in an array
  env:k[] = [randomi:k(-20,0,15,3),randomi:k(-20,0,15,3)]

  // two mono sound streams
  a1 = diskin:a("fox.wav",randomi:k(.7,1.1,1,3),0,1)
  a2 = diskin:a("ClassGuitMono.flac",randomi:k(.8,1.3,1,3),0,1)
  
  // apply envelopes and put into array
  audio:a[] = [a1*ampdb(env[0]), a2*ampdb(env[1])]
  
  // sometimes swap the audio channels (clicks may occur)
  if (randomh:k(0,2,1,3) > 1) then
    audio = [audio[1], audio[0]]
  endif
  
  // output
  out(audio)
  
  schedule(ShowArr_3,0,1)

endin

instr ShowArr_3

  show:S = {{It is also possible to insert k- and a-variables in the [...] short form of array declaration. (Behind the curtain it is only another way of calling the opcode fillarray.)
  This example creates a k-array with to random envelopes, and also an audio array with two audio signals. As a proof of concept, the audio signals are swapped from time to time.

  // two random k-rate envelopes in an array
  env:k[] = [randomi:k(-20,0,15,3),randomi:k(-20,0,15,3)]

  // two mono sound streams with random speed 
  a1 = diskin:a("fox.wav",randomi:k(.7,1.1,1,3),0,1)
  a2 = diskin:a("ClassGuitMono.flac",randomi:k(.8,1.3,1,3),0,1)
  
  // apply envelopes and put into array
  audio:a[] = [a1*ampdb(env[0]),a2*ampdb(env[1])]
  
  // sometimes swap the audio channels (clicks may occur)
  if (randomh:k(0,2,1,3) > 1) then
    audio = [audio[1],audio[0]]
  endif
  
  // output
  out(audio)}}

  chnset(show,"display-output")

endin

instr Arr_4

  // integers from 1 to 10 (included)
  myarr1:i[] = [1 ... 10]
  // print the content
  puts("content of myarr1:",1)
  printarray(myarr1)
  
  // frequency values from 200 to 2000, in steps of 100
  myarr2:i[] = [200 ... 2000, 100]
  // print the content
  puts("\ncontent of myarr2:",1)
  printarray(myarr2)
  schedule(ShowArr_4,0,1)

endin

instr ShowArr_4

  show:S = {{Csound 7 offers a nice shortcut for the genarray opcode. The syntax is:
  
  [from ... to, increment]
  
If the increment is not specified, it is 1.
Here are two simple examples:

  // integers from 1 to 10 (included)
  myarr1:i[] = [1 ... 10]
  // print the content
  printarray(myarr1,"%d","Content of myarr1:")
  
  // frequency values from 200 to 2000, in steps of 100
  myarr2:i[] = [200 ... 2000, 100]
  // print the content
  printarray(myarr2,"%d","Content of myarr2:")
  
And this is the output:

  content of myarr1:
   1 2 3 4 5 6 7 8 9 10 

  content of myarr2:
   200 300 400 500 600 700 800 900 1000 1100
   1200 1300 1400 1500 1600 1700 1800 1900 2000}}

  chnset(show,"display-output")

endin


</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>










<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>263</x>
 <y>154</y>
 <width>1115</width>
 <height>833</height>
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
  <text>arr:i[] = [...] </text>
  <image>/</image>
  <eventLine>i "Arr_1" 0 0</eventLine>
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
  <label>It is now possible to write an array in the way we know from other programming languages:
  
    myarray:type[] = [element 1, element 2, ...]
    
Where type is i, k, a, S, for i-rate, k-rate, a-rate or string arrays.
This is a simple example for an i-array:
  
  myarray:i[] = [1,2,3,5,8]
  puts("Elements in myarray:",1)
  show:S = "  "
  for el in myarray do
    show = strcat(show,sprintf("%d ",el))
  od
  puts(show,1)

returns:

  Elements in myarray:
    1 2 3 5 8</label>
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
  <text>arr:S[] = [...]</text>
  <image>/</image>
  <eventLine>i "Arr_2" 0 0</eventLine>
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
  <text>[] for k- and a-arrays</text>
  <image>/</image>
  <eventLine>i "Arr_3" 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>16</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button0</objectName>
  <x>17</x>
  <y>210</y>
  <width>283</width>
  <height>42</height>
  <uuid>{0d48ac7b-aeef-4148-a6da-613ff90375a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>short form for genarray</text>
  <image>/</image>
  <eventLine>i "Arr_4" 0 0</eventLine>
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
  <label>What's New in Csound 7: Array Features</label>
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

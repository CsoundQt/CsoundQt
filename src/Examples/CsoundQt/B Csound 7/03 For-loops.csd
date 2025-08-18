<CsoundSynthesizer>
<CsOptions>
-m128
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

chn_S("display-output",2)


/* CSOUND 7 — What's new 3: FOR LOOPS
   ==================================
   
   One of the most important extensions of Csound 7 is the introduction of 
   for-loops. This simplifies many jobs which were a bit laborious before.
*/

// written by joachim heintz 2025

/* General Syntax
   ==============
   
1. for var in array do
     ...
   od

2. for var,i in array do
     ...
   od
   (were i is a counter starting at zero)
*/


/* Case 1:
   var is not specified in type
   -> will follow the array type
   running either at init- or performance time
*/

instr I_Loop_Simple
  
  // num is not specified: i-rate because of the i-rate array
  for num in [1,2,3,5,8] do
    print(num)
  od
  schedule(Show_I_Loop_Simple,0,1)

endin

instr Show_I_Loop_Simple

  show:S = {{The basic syntax of the for-loop in Csound 7 is:
  
  for var in array do
    ...
  od

If not specified, the variable will be of the same type as the array.
In this example, the variable 'num' will be i-rate as the array is i-rate.
 
  for num in [1,2,3,5,8] do
    print(num)
  od\n\nreturns:\n
  num = 1.000
  num = 2.000
  num = 3.000
  num = 5.000
  num = 8.000}}

  chnset(show,"display-output")

endin

instr I_Loop_With_Counter
  
  // the same but with loop counter 
  for num,i in [1,2,3,5,8] do
    print(num,i)
  od
  schedule(Show_I_Loop_With_Counter,0,1)
  
endin

instr Show_I_Loop_With_Counter

  show:S = {{If we do not set one but two variables in a for-loop, the second variable will count the number of loops, starting at zero.
  
  for var,i in array do
    ...
  od

This is the code for a simple example:

  for num,i in [1,2,3,5,8] do
    print(num,i)
  od\n\nIt returns:\n
  num = 1.000	i = 0.000
  num = 2.000	i = 1.000
  num = 3.000	i = 2.000
  num = 5.000	i = 3.000
  num = 8.000	i = 4.000}}

  chnset(show,"display-output")

endin

instr S_Loop_With_Counter
  
  // an array of strings
  arr:S[] = ["one","two","three","five","eight"]
  // create an empty array for the reversed array
  rev:S[] init lenarray(arr)
  // loop
  for s,i in arr do
    // show the element for each loop
    printf_i("i = %d, s = \"%s\"\n",i+1,i,s)
    // fill the second array
    rev[i] = arr[lenarray(arr)-1-i]
  od
  //print the reversed array
  puts("Reversed Array:",1)
  printarray(rev)
  turnoff
  schedule(Show_S_Loop_With_Counter,0,1)

endin

instr Show_S_Loop_With_Counter

  // string loop with loop counter 
  show:S = {{This is a for-loop which uses the counter to reverse a string array.\n
  // an array of strings
  arr:S[] = ["one","two","three","five","eight"]
  // create an empty array for the reversed array
  rev:S[] init lenarray(arr)
  // loop with string variable s and counter i
  for s,i in arr do
    // show the element for each loop
    printf_i("i = %d, s = \"%s\"\\n",i+1,i,s)
    // fill the second array in reverse order
    rev[i] = arr[lenarray(arr)-1-i]
  od
  //print the reversed array
  puts("Reversed Array:",1)
  printarray(rev)
\n\nreturns:\n
  i = 0, s = "one"
  i = 1, s = "two"
  i = 2, s = "three"
  i = 3, s = "five"
  i = 4, s = "eight"
  Reversed Array:
   "eight", "five", "three", "two", "one"}}
 
  chnset(show,"display-output")

endin

instr Short

  start:i init 0
  for freq in [200 ... 2000, 100] do
    schedule(PlaySine,start,5-start,freq)
    start += 1/8
  od
  schedule(ShowShortCode,0,1)

endin

instr PlaySine

  env:a = transeg(.1,p3,-3,0)
  outall(poscil:a(env,p4))

endin

instr ShowShortCode

  code:S = {{This for-loop uses the short form of the genarray opcode:
  
  [start ... end, increment]
  
It iterates over an array of numbers, starting at 200, ending at 2000, in steps of 100.
In each loop one instance of the instrument PlaySine is called, with the array element as frequency (p4 in the instrument call). This results in 20 sines with frequency ratios 2:3:4:5 ...
  
instr Short

  start:i init 0
  for freq in [200 ... 2000, 100] do
    schedule(PlaySine,start,5-start,freq)
    start += 1/8
  od

endin

instr PlaySine

  env:a = transeg(1/20,p3,-3,0)
  outall(poscil:a(env,p4))

endin}}
chnset(code,"display-output")

endin


</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>262</x>
 <y>102</y>
 <width>1082</width>
 <height>806</height>
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
  <text>i-loop simple</text>
  <image>/</image>
  <eventLine>i "I_Loop_Simple" 0 0</eventLine>
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
  <label>The basic syntax of the for-loop in Csound 7 is:
  
  for var in array do
    ...
  od

If not specified, the variable will be of the same type as the array.
In this example, the variable 'num' will be i-rate as the array is i-rate.
 
  for num in [1,2,3,5,8] do
    print(num)
  od

returns:

  num = 1.000
  num = 2.000
  num = 3.000
  num = 5.000
  num = 8.000</label>
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
  <text>i-loop with counter</text>
  <image>/</image>
  <eventLine>i "I_Loop_With_Counter" 0 0</eventLine>
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
  <text>string loop with counter</text>
  <image>/</image>
  <eventLine>i "S_Loop_With_Counter" 0 1</eventLine>
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
  <text>short form for arrays</text>
  <image>/</image>
  <eventLine>i "Short" 0 0</eventLine>
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
  <label>What's New in Csound 7: For-Loop</label>
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

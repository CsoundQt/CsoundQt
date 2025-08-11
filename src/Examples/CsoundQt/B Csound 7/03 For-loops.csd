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
  show:S = {{for num in [1,2,3,5,8] do
               print(num)
             od\nreturns:\n\n}}
  chnset(show,"display-output")
  for num in [1,2,3,5,8] do
    print(num)
    show:S = strcat(show,sprintf("   num = %d\n",num))
  od
  chnset(show,"display-output")

endin

instr I_Loop_With_Counter
  
  // the same but with loop counter 
  show:S = "for num,i in [1,2,3,5,8] do\n"
  chnset(show,"display-output")
  for num,i in [1,2,3,5,8] do
    print(num,i)
    show:S = strcat(show,sprintf("   num = %d, i = %d\n",num,i))
  od
  chnset(show,"display-output")

endin

instr S_Loop_With_Counter
  
  // the same but with loop counter 
  show:S = {{for s,i in ["one","two","three","five","eight"] do
               puts(s,1)
             od\n\nreturns:\n\n}}
  chnset(show,"display-output")
  for s,i in ["one","two","three","five","eight"] do
    puts(s,1)
    show:S = strcat(show,sprintf("   s = '%s', i = %d\n",s,i))
  od
  chnset(show,"display-output")

endin


</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>544</x>
 <y>212</y>
 <width>805</width>
 <height>551</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
 <bsbObject type="BSBButton" version="2">
  <objectName>button0</objectName>
  <x>16</x>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>16</x>
  <y>14</y>
  <width>687</width>
  <height>41</height>
  <uuid>{321802e3-d5a0-407d-a4e1-df59e780d96b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Push buttons to trigger the instruments and watch the output.</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
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
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>display-output</objectName>
  <x>304</x>
  <y>61</y>
  <width>400</width>
  <height>380</height>
  <uuid>{dca2180d-3708-4a41-8865-eee375f49ef0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>for s,i in ["one","two","three","five","eight"] do
               puts(s,1)
             od
returns:

   s = 'one', i = 0
   s = 'two', i = 1
   s = 'three', i = 2
   s = 'five', i = 3
   s = 'eight', i = 4
</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
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
  <y>108</y>
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
  <y>158</y>
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
  <eventLine>i "S_Loop_With_Counter" 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>16</fontsize>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

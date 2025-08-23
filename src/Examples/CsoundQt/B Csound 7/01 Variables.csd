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
seed(0)

/* CSOUND 7 — What's New 1: VARIABLES
   ==================================
   
   Variables can now have any name except opcode names and other constants.
   The type of a variable is declared explicitely then.
   Global variables are declared via the @global signifier.
*/

// written by joachim heintz 2025


chn_S("display-output",2)

instr Old

  iFreq = p4
  iDb = p5
  
  kGliss = randomi:k(iFreq*0.9,iFreq*1.1,3,3)
  aSound = vco2(ampdb(iDb),kGliss)
  outall(linenr:a(aSound,.1,.1,.01))
  schedule(ShowOld,0,1)

endin

instr ShowOld
  
mess:S = {{Before Csound 7 we had to start a variable name with i,k,a,S to signify the type of this variable as i-rate, k-rate, a-rate or string.
This is a typical example:

instr Old

  iFreq = p4
  iDb = p5
  
  kGliss = randomi:k(iFreq*0.9,iFreq*1.1,3,3)
  aSound = vco2(ampdb(iDb),kGliss)
  outall(linenr:a(aSound,.1,.1,.01))

endin}}
  chnset(mess,"display-output")

endin

instr New

  freq:i = p4
  dB:i = p5
  
  glissando:k = randomi(freq*0.9,freq*1.1,3,3)
  sound:a = vco2(ampdb(dB),glissando)
  outall(linenr(sound,.1,.1,.01))
  schedule(ShowNew,0,1)
  
endin

instr ShowNew

  mess:S = {{In Csound 7 we can use any name and signify the type as :i, :k etc.
This is the same example as before in this way of writing:

instr New

  freq:i = p4
  dB:i = p5
  
  glissando:k = randomi(freq*0.9,freq*1.1,3,3)
  sound:a = vco2(ampdb(dB),glissando)
  outall(linenr(sound,.1,.1,.01))
  
endin

Note that we do not write randomi:k here as usually the new parser will choose the appropriate version of the randomi opcode. It is recommended though for doubtful cases.}}
  chnset(mess,"display-output")

endin

instr Globals

  dry@global:a init 0
  dry += diskin:a("fox.wav") / 3
  dry += pinkish(.05)
  schedule(GlobalsReverb,0,p3+3)
  schedule(ShowGlobals,0,1)

endin

instr GlobalsReverb

  wet:a = reverb2(dry,2,.5)
  outall(dry/5+wet/2)
  dry = 0

endin

instr ShowGlobals

mess:S = {{Before Csound 7 global variables started with the 'g' character, like 'gkFreq' or 'gaReverb'. In Csound 7 we use the '@global' specifier. This is a typical example which sends the global audio 'dry' to another instrument for reverberation.

instr Globals

  dry@global:a init 0
  dry += diskin:a("fox.wav") / 3
  dry += pinkish(.05)
  schedule(GlobalsReverb,0,p3+3)
  schedule(ShowGlobals,0,1)

endin

instr GlobalsReverb

  wet:a = reverb2(dry,2,.5)
  outall(dry/5+wet/2)
  dry = 0

endin}}
chnset(mess,"display-output")

endin

instr Conflicts

  // this name is ok
  dB:i = p4
  
  // this name is not possible because it is used by the db() converter
  ;db:i = p4
  
mess:S = {{We cannot use any variable name which is used by an opcode as its name. We can, for instance, use 'dB' but not 'db' as it is an opcode name. If we do so ...

instr DoNotUseOpcodeNames

  db:i = p4

endin

... Csound will not compile but throw an error:

> error:  db:i type mismatch for variable db:OpcodeDef
> Parsing failed due to 1 semantic error!}}

  chnset(mess,"display-output")

endin


</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>411</x>
 <y>98</y>
 <width>1103</width>
 <height>795</height>
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
  <text>old way</text>
  <image>/</image>
  <eventLine>i "Old" 0 3 400 -10</eventLine>
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
  <label>What's New in Csound 7: Variable Declaration</label>
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>display-output</objectName>
  <x>304</x>
  <y>61</y>
  <width>753</width>
  <height>652</height>
  <uuid>{dca2180d-3708-4a41-8865-eee375f49ef0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>In Csound 7 we can use any name and signify the type as :i, :k etc.
This is the same example as before in this way of writing:

instr New

  freq:i = p4
  dB:i = p5
  
  glissando:k = randomi(freq*0.9,freq*1.1,3,3)
  sound:a = vco2(ampdb(dB),glissando)
  outall(linenr(sound,.1,.1,.01))
  
endin

Note that we do not write randomi:k here as usually the new parser will choose the appropriate version of the randomi opcode. It is recommended though for doubtful cases.</label>
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
  <text>new way</text>
  <image>/</image>
  <eventLine>i "New" 0 3 400 -10</eventLine>
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
  <text>globals</text>
  <image>/</image>
  <eventLine>i "Globals" 0 3</eventLine>
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
  <text>name conflicts</text>
  <image>/</image>
  <eventLine>i "Conflicts" 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>16</fontsize>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

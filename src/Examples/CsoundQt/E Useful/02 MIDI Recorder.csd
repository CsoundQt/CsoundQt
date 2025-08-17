<CsoundSynthesizer>
<CsOptions>
-m128
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

/***** MIDI RECORDER *****/
// Records MIDI note events

; after an examle by Jacob Joaquin 2010
; rewritten by joachim heintz 2025

// array to store triplets of time, notenum, velocity
Arr@global:k[] init 100000

// pointer in the array
RecPointer@global:k init 0

// recording time
RecTime@global:k init 0

// guide all midi events to instr GetMidi
massign(0,"GetMidi")

// channels 
chn_S("midi-received",2)
chn_k("rec-is-on",2)
chn_k("playback-progress",2)


instr Init
  chnset("","midi-received")
endin
schedule(Init,0,.1)

instr GetMidi

  // get midi events
  s:k,ch:k,d1:k,d2:k = midiin()
  
  // get note-on or -off messages
  if (s == 128) || (s == 144) then
  
    // note-on 
    if (s == 144) && (d2 > 0) then
      // call the MidiSound instrument with note number as instance
      schedulek(sprintfk("MidiSound.%03d",d1),0,-1,d1,d2)
      // send info to gui
      chnset(sprintfk("%-10s%-12d%-10d%.3f","ON",d1,d2,RecTime),"midi-received")
      
    // otherwise turn off the instance by sending a negative p1
    else
      // only for gui display
      if (s == 128) then
        chnset(sprintfk("%-10s%-12d%-10d%.3f","OFF",d1,d2,RecTime),"midi-received")
      else
        chnset(sprintfk("%-10s%-12d%-10d%.3f","ON",d1,d2,RecTime),"midi-received")
      endif
      // set d2 to zero for writing in array as note-on with zero velocity
      d2 = 0
      schedulek(sprintfk("-MidiSound.%03d",d1),0,-1,d1,d2)
    endif
        
    // write the data into the array
    Arr[RecPointer] = RecTime
    Arr[RecPointer+1] = d1
    Arr[RecPointer+2] = d2
  
    // advance rec pointer
    RecPointer += 3
    
  endif 
  
endin
schedule(GetMidi,0,-1)

instr Record

  RecTime += 1/kr

endin

instr Play

  readIndx:k init 0
  localTime:k init 0
  nextTime:k = Arr[readIndx]
  
  if ((readIndx < RecPointer) && localTime >= nextTime) then

    note_number:k = Arr[readIndx+1]
    velocity:k = Arr[readIndx+2]
    
    // for positive verlocity call the MidiSound instrument with note number as instance
    if (velocity > 0) then
      schedulek(sprintfk("MidiSound.%03d",note_number),0,-1,note_number,velocity)
    // otherwise turn off
    else
      schedulek(sprintfk("-MidiSound.%03d",note_number),0,-1,note_number,velocity)
    endif
    
    // increase the read pointer
    readIndx += 3
    
  endif
  
  localTime += 1/kr
  
  // stop any sound in case this instrument is turned off
  if (release() == 1) then
    turnoff2(MidiSound,0,1)
  endif

endin

instr MidiSound

  note:i = p4
  amp:i = p5/127
  sound:a = poscil(amp*1.5,mtof(note))+poscil(amp/4,mtof:k(note+randomi:k(11.85,12.15,20,3)))
  outall(linenr:a(sound/2,.1,.1,.01))

endin



</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>397</x>
 <y>197</y>
 <width>677</width>
 <height>476</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
 <bsbObject type="BSBButton" version="2">
  <objectName>startstoprec</objectName>
  <x>110</x>
  <y>145</y>
  <width>115</width>
  <height>34</height>
  <uuid>{cd8ea423-1ea9-4078-a02f-7b6930e66ab1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Start / Stop</text>
  <image>/</image>
  <eventLine>i "Record" 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>pauseresumerec</objectName>
  <x>238</x>
  <y>145</y>
  <width>142</width>
  <height>34</height>
  <uuid>{c41c2c66-7d63-4857-bc57-362615e45156}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Pause / Resume</text>
  <image>/</image>
  <eventLine>i "PauseRecord" 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>145</y>
  <width>80</width>
  <height>34</height>
  <uuid>{2146fb06-7c6e-436d-b494-c138e649c7e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>RECORD</label>
  <alignment>right</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>startstopplay</objectName>
  <x>110</x>
  <y>190</y>
  <width>115</width>
  <height>34</height>
  <uuid>{590ad5a2-5f3d-4cb6-9c60-029771123239}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Start / Stop</text>
  <image>/</image>
  <eventLine>i "Play" 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>true</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>pauseresumeplay</objectName>
  <x>238</x>
  <y>190</y>
  <width>146</width>
  <height>34</height>
  <uuid>{5cef303f-4117-46ce-9b27-d4b173b72b60}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Pause / Resume</text>
  <image>/</image>
  <eventLine>i "PausePlay" 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>190</y>
  <width>80</width>
  <height>34</height>
  <uuid>{8ee76e2b-cc3e-4909-9f7c-202b0209c924}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>PLAY</label>
  <alignment>right</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>55</y>
  <width>658</width>
  <height>77</height>
  <uuid>{80ffc85b-15be-41c8-95cb-080a092e55d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>This example can record incoming MIDI notes to memory, and play them back with a simple sound. It can also save the content to a csd file.</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>10</y>
  <width>656</width>
  <height>43</height>
  <uuid>{ff0c0b4b-6f94-41a8-b4c1-5852a7ef2e35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>MIDI RECORDER</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>32</fontsize>
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
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>midi-received</objectName>
  <x>10</x>
  <y>318</y>
  <width>648</width>
  <height>32</height>
  <uuid>{bb63bcab-72f4-450b-abc9-e5e8490ed18b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>OFF       90          64        29.883</label>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>8</x>
  <y>281</y>
  <width>647</width>
  <height>34</height>
  <uuid>{6e441c1f-0cc4-47c4-abb7-9866ed2c2039}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Event     Note number Velocity  Record time</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
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
  <bordermode>false</bordermode>
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>rec-is-on</objectName>
  <x>395</x>
  <y>145</y>
  <width>48</width>
  <height>34</height>
  <uuid>{e5618b19-49a3-48f1-8ecc-75670fbf7c69}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>rec-is-on</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>224</r>
   <g>27</g>
   <b>36</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>30</r>
   <g>30</g>
   <b>30</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>playback-progress</objectName>
  <x>395</x>
  <y>190</y>
  <width>270</width>
  <height>34</height>
  <uuid>{db695565-f1b9-4061-804b-75a2ba85f220}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>rec-is-on</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>30</r>
   <g>30</g>
   <b>30</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

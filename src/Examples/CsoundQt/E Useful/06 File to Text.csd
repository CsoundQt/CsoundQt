<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 1 ;necessary for this solution
nchnls = 1
0dbfs = 1

; By Andres Cabrera 2009
; and joachim heintz 2025 (version for csound 7)


instr Main

  ; Receive the file names from the text boxes
  infile:S = invalue("_Browse1")
  outfile:S = invalue("_Browse2")
  
  ; Check duration and sample rate
  infile_len:i = filelen(infile)
  infile_sr:i = filesr(infile)
  
  ; Receive decimation value and type
  decimation:i = invalue("decimation")
  type:i = invalue("type")
  
  ; Start and end
  start:i = invalue("start") / 1000
  end:i = invalue:i("end")/1000
  end = (end > infile_len) ? infile_len : end
  p3 = end - start
  
  ; Clear result display
  outvalue("result","")
    
  ; Now do all in one k-cycle
  count_samples:k init 0
  while (count_samples < p3*sr) do
    
    ; Read file beginning with start time
    stream_all:a[] = diskin(infile,1,start)
  
    ; only use first channel and convert to k-rate
    stream:k = k(stream_all[0])
    
    ; set initial values for analysis
    accum:k init 0
    counter:k init 0
    print_counter:k init 0
    
    // if peak
    if (type == 0) then
    
      // on the run ...
      if (counter < decimation) then
      
        if (abs(stream) > abs(accum)) then
          accum = stream
        endif
        counter += 1
        
      // ... reaching decimation value
      else
        fprintks(outfile,"%f\n",accum)
        print_counter += 1
        counter = 0
        accum = 0
      endif
      
    // if average
    else
    
      // on the run ...
      if (counter < decimation) then
        accum += abs(stream)
        counter += 1
        
      // ... reaching decimation value
      else
        fprintks(outfile,"%f\n",accum/counter)
        print_counter += 1
        counter = 0
        accum = 0
      endif
    
    endif
  
    // increment counting 
    count_samples += 1
      
  od
  
  // print result to widget
  outvalue("result",sprintfk("Written %d values to %s%s!",print_counter,pwd(),outfile))
  
  // stop csound
  event("e",0,0)

endin
schedule(Main,0,1)


</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>767</x>
 <y>212</y>
 <width>581</width>
 <height>405</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>138</r>
  <g>157</g>
  <b>162</b>
 </bgcolor>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>decimation</objectName>
  <x>95</x>
  <y>265</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5985ba7b-3a4f-42f8-b0bd-1396aeef44ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1000</value>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse1</objectName>
  <x>100</x>
  <y>195</y>
  <width>357</width>
  <height>30</height>
  <uuid>{8ccac1d4-3d0f-4b78-ac22-54a0e0737f9e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>fox.wav</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse1</objectName>
  <x>456</x>
  <y>193</y>
  <width>100</width>
  <height>30</height>
  <uuid>{d2185fce-b4fa-4050-ab3f-423836a05f50}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>fox.wav</stringvalue>
  <text>Browse</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Play</objectName>
  <x>425</x>
  <y>265</y>
  <width>137</width>
  <height>100</height>
  <uuid>{a1dc4742-c982-44ec-835e-f768af82eaf7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Run</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>20</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>198</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3528a3f8-9966-435b-b433-fc9954eeebfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>File to load</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>12</fontsize>
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
  <x>10</x>
  <y>265</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8dce1321-3b31-448a-a9d7-d297b8bfd079}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Decimation</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>start</objectName>
  <x>95</x>
  <y>300</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7e459bdb-9dbc-480d-bbe5-b01b7fbd0098}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>300</y>
  <width>86</width>
  <height>27</height>
  <uuid>{31fab7b1-bca8-4c5c-ae61-99d3d49c68c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Start time (ms)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>end</objectName>
  <x>95</x>
  <y>335</y>
  <width>80</width>
  <height>25</height>
  <uuid>{34f55718-74e5-468a-b2b4-166af109c4fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1100</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>335</y>
  <width>86</width>
  <height>25</height>
  <uuid>{7c13cdf3-8d2e-4a7f-a3ca-a40e9b94a71f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>End time (ms)</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
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
 <bsbObject type="BSBDropdown" version="2">
  <objectName>type</objectName>
  <x>275</x>
  <y>265</y>
  <width>122</width>
  <height>30</height>
  <uuid>{6ce4ec10-ce8a-42d4-8af3-9afda3c83a2a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>peak</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>average</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName/>
  <x>10</x>
  <y>0</y>
  <width>554</width>
  <height>192</height>
  <uuid>{459873e4-6315-4d0e-b3ec-c11a4eeb684d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>
This csd file writes the values from an audio file to a text file, from the selected starting time to the selected end time, in blocks of size determined by the decimation value. If decimation is 100, this means that 100 audio samples will write a single value to the text file.
You can select peak to store the sample with greatest absolute value or average to store the average of the set.
To use, select file to process using the Browse button, then press the run button and wait for the message reporting the result.</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>17</r>
   <g>16</g>
   <b>15</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse2</objectName>
  <x>460</x>
  <y>230</y>
  <width>100</width>
  <height>30</height>
  <uuid>{74549d53-e04d-4ded-a29b-44c94f9a4b98}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>fox.txt</stringvalue>
  <text>Browse</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>235</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ea8af674-e3ae-4137-9e01-57526b64613f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Destination file</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>12</fontsize>
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
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse2</objectName>
  <x>96</x>
  <y>232</y>
  <width>363</width>
  <height>29</height>
  <uuid>{39827a32-cd39-4b5a-8da5-ef292e89d626}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>fox.txt</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>190</x>
  <y>265</y>
  <width>85</width>
  <height>30</height>
  <uuid>{018b532c-6f60-4be6-8abf-3ee1c2b64023}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Mode</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
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
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>result</objectName>
  <x>183</x>
  <y>298</y>
  <width>239</width>
  <height>64</height>
  <uuid>{d0805183-08d8-4fcf-99d4-ede3296593dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>17</r>
   <g>16</g>
   <b>15</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

<CsoundSynthesizer>
<CsOptions>
-n -m0 ; Don't write audio file to disk and don't write messages
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 1
nchnls = 1
0dbfs = 1

gihandle init 0

; By Andres Cabrera 2009

instr 1
; Receive the name from the text boxes
Sfilename invalue "_Browse1"
Sfilename2 invalue "_Browse2"
; Check duration and sample rate
ilen filelen Sfilename

; Load the audio file to f-table 50
ftfree 50, 0
Sline sprintf {{f 50 0 0 1 "%s" 0 0 1}}, Sfilename
scoreline_i Sline
;outvalue "fb", "Loading file..."

;receive decimation value
kdec invalue "decimation"
; Turn on instrument that clears progress bar
event_i "i", 97, 0, 1
; Turn on processing instrument for approprate time
event_i "i", 98, 5, ilen / i(kdec)
prints Sfilename2
gihandle fiopen Sfilename2, 0 ; open text file for writing
; When finished, quit
event_i "i", 100, (ilen/ i(kdec)) + 6, 1
endin

instr 97 ;clear progress bar
outvalue "fb", 0
endin

instr 98 ;traverse the file
kdec invalue "decimation"
kstart invalue "start"
kend invalue "end"
ktype invalue "type"
kindex init 0
kaccum init 0
ilen = nsamp(50)

; Convert time in ms to number of audio samples
kstart = kstart * sr /1000
kend = kend * sr /1000

loopstart:
kindex = kindex + 1
if ((kindex + kstart >= ilen) || (kindex + kstart > kend)) then
	turnoff
endif
kvalue tab kindex + kstart, 50
if (ktype == 0) then ; if peak
	if (kaccum < abs(kvalue)) then
		kaccum = abs(kvalue)
	endif
elseif (ktype == 1) then ; if average
	kaccum = kaccum + kvalue
endif

; Check if kindex is a multiple of kdec
krem = kindex%kdec
if krem != 0 kgoto loopstart ; do loop

if (ktype == 1) then ; if average divide by number of elements
	kaccum = kaccum / kdec
endif

event "i", 99, 0, 1, kaccum
kaccum = 0

outvalue "fb", kindex/(kend-kstart)
endin

instr 99  ;write one value
fouti gihandle, 0, 0, p4
turnoff
endin

instr 100  ;print end message
ficlose gihandle
exitnow
endin


</CsInstruments>
<CsScore>
f 50 0 2 2 0
i 1 0 6

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>577</x>
 <y>195</y>
 <width>585</width>
 <height>492</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background" >
  <r>138</r>
  <g>157</g>
  <b>162</b>
 </bgcolor>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>decimation</objectName>
  <x>95</x>
  <y>316</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5985ba7b-3a4f-42f8-b0bd-1396aeef44ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>1000</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>_Browse1</objectName>
  <x>11</x>
  <y>227</y>
  <width>445</width>
  <height>26</height>
  <uuid>{8ccac1d4-3d0f-4b78-ac22-54a0e0737f9e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>/home/andres/Downloads/ahh.wav</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Browse1</objectName>
  <x>458</x>
  <y>225</y>
  <width>100</width>
  <height>30</height>
  <uuid>{d2185fce-b4fa-4050-ab3f-423836a05f50}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/andres/Downloads/ahh.wav</stringvalue>
  <text>Browse</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Play</objectName>
  <x>188</x>
  <y>354</y>
  <width>375</width>
  <height>61</height>
  <uuid>{a1dc4742-c982-44ec-835e-f768af82eaf7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Run</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>10</x>
  <y>198</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3528a3f8-9966-435b-b433-fc9954eeebfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>File to load</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>12</x>
  <y>316</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8dce1321-3b31-448a-a9d7-d297b8bfd079}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Decimation</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>start</objectName>
  <x>95</x>
  <y>350</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7e459bdb-9dbc-480d-bbe5-b01b7fbd0098}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>12</x>
  <y>350</y>
  <width>86</width>
  <height>27</height>
  <uuid>{31fab7b1-bca8-4c5c-ae61-99d3d49c68c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Start time (ms)</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>end</objectName>
  <x>95</x>
  <y>387</y>
  <width>80</width>
  <height>25</height>
  <uuid>{34f55718-74e5-468a-b2b4-166af109c4fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>1000</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>12</x>
  <y>387</y>
  <width>86</width>
  <height>25</height>
  <uuid>{7c13cdf3-8d2e-4a7f-a3ca-a40e9b94a71f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>End time (ms)</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>type</objectName>
  <x>186</x>
  <y>318</y>
  <width>122</width>
  <height>30</height>
  <uuid>{6ce4ec10-ce8a-42d4-8af3-9afda3c83a2a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
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
  <selectedIndex>1</selectedIndex>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>fb</objectName>
  <x>316</x>
  <y>323</y>
  <width>245</width>
  <height>22</height>
  <uuid>{e5b1e9a9-dccd-48fc-9aed-b507661a9285}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>vert12</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.68181800</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0" >false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay" >
  <objectName/>
  <x>10</x>
  <y>0</y>
  <width>554</width>
  <height>192</height>
  <uuid>{459873e4-6315-4d0e-b3ec-c11a4eeb684d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>
This csd file writes the values from an audio file to a text file, from the selected starting time to the selected end time, in blocks of size determined by the decimation value. If decimation is 100, this means that 100 audio samples will write a single value to the text file.
You can select peak to store the sample with greatest absolute value or average to store the average of the set.
To use, select file to process using the Browse button, then press the render button and wait for the progress bar to go completely green.</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>17</r>
   <g>16</g>
   <b>15</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Browse2</objectName>
  <x>460</x>
  <y>283</y>
  <width>100</width>
  <height>30</height>
  <uuid>{74549d53-e04d-4ded-a29b-44c94f9a4b98}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/andres/Downloads/ahh.wav</stringvalue>
  <text>Browse</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>12</x>
  <y>256</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ea8af674-e3ae-4137-9e01-57526b64613f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Destination file</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>_Browse2</objectName>
  <x>13</x>
  <y>285</y>
  <width>445</width>
  <height>26</height>
  <uuid>{39827a32-cd39-4b5a-8da5-ef292e89d626}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>/home/andres/Downloads/ahh.txt</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <objectName/>
 <x>577</x>
 <y>195</y>
 <width>585</width>
 <height>492</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 577 195 585 492
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {35466, 40349, 41634}
ioText {95, 316} {80, 25} editnum 1000.000000 1.000000 "decimation" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 1000.000000
ioText {11, 227} {445, 26} edit 0.000000 0.00100 "_Browse1"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder /home/andres/Downloads/ahh.wav
ioButton {458, 225} {100, 30} value 1.000000 "_Browse1" "Browse" "/" 
ioButton {188, 354} {375, 61} value 1.000000 "_Play" "Run" "/" 
ioText {10, 198} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder File to load
ioText {12, 316} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Decimation
ioText {95, 350} {80, 25} editnum 0.000000 1.000000 "start" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 0.000000
ioText {12, 350} {86, 27} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Start time (ms)
ioText {95, 387} {80, 25} editnum 1000.000000 1.000000 "end" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 1000.000000
ioText {12, 387} {86, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 10 {0, 0, 0} {58880, 56576, 54528} nobackground noborder End time (ms)
ioMenu {186, 318} {122, 30} 1 303 "peak,average" type
ioMeter {316, 323} {245, 22} {0, 59904, 0} "fb" 0.000000 "vert12" 0.681818 fill 1 0 mouse
ioText {10, 0} {554, 192} display 0.000000 0.00100 "" center "DejaVu Sans" 14 {65280, 43520, 0} {4352, 4096, 3840} nobackground noborder Â¬This csd file writes the values from an audio file to a text file, from the selected starting time to the selected end time, in blocks of size determined by the decimation value. If decimation is 100, this means that 100 audio samples will write a single value to the text file.Â¬You can select peak to store the sample with greatest absolute value or average to store the average of the set.Â¬To use, select file to process using the Browse button, then press the render button and wait for the progress bar to go completely green.
ioButton {460, 283} {100, 30} value 1.000000 "_Browse2" "Browse" "/" 
ioText {12, 256} {80, 25} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Destination file
ioText {13, 285} {445, 26} edit 0.000000 0.00100 "_Browse2"  "DejaVu Sans" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder /home/andres/Downloads/ahh.txt
</MacGUI>

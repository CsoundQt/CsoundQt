<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1
; Based on manual example by schwaheed

massign         0, 0  ; disable triggering of notes
pgmassign       0, 0

instr 1  ;Generate MIDI note
	ktime timeinsts
	noteon 1, 60, 100
	if (ktime > p3/2) then
		reinit endnote
		turnoff
	endif
	goto end
endnote:
	noteoff 1, 60, 100
end:
endin

instr   130

knotelength    init    0
knoteontime    init    0

kstatus, kchan, kdata1, kdata2                  midiin

if (kstatus == 128) then
	knoteofftime    times
	knotelength = (knoteofftime - knoteontime)*1000
	Stext sprintfk "Note Off: chan = %d note#  = %d velocity = %d length = %d", kchan, kdata1,kdata2, knotelength
	outvalue "note", Stext

elseif (kstatus == 144) then
	if (kdata2 == 0) then
		knoteofftime    times
		knotelength = (knoteofftime - knoteontime)*1000
printk2 knotelength
		Stext sprintfk "Note On: chan = %d note#  = %d velocity = %d length = %d", kchan, kdata1, kdata2, knotelength
	else
		Stext sprintfk "Note On: chan = %d note#  = %d velocity = %d", kchan, kdata1, kdata2
		knoteontime    times
	endif
	outvalue "note", Stext

elseif (kstatus == 160) then
	printks "kstatus= %d, kchan = %d, \\tkdata1 = %d, kdata2 = %d \\tPolyphonic Aftertouch\\n", 0, kstatus, kchan, kdata1, kdata2

elseif (kstatus == 176) then
	Stext sprintfk "%d",  kdata1
	outvalue "cc", Stext
	Stext sprintfk "%d",  kdata2
	outvalue "ccvalue", Stext
	Stext sprintfk "%d",  kchan
	outvalue "channel", Stext

elseif (kstatus == 192) then
	printks "kstatus= %d, kchan = %d, \\tkdata1 = %d, kdata2 = %d \\tProgram Change\\n", 0, kstatus, kchan, kdata1, kdata2

elseif (kstatus == 208) then
	printks  "kstatus= %d, kchan = %d, \\tkdata1 = %d, kdata2 = %d \\tChannel Aftertouch\\n", 0, kstatus, kchan, kdata1, kdata2

elseif (kstatus == 224) then
	printks "kstatus= %d, kchan = %d, \\t ( data1 , kdata2 ) = ( %d, %d )\\tPitch Bend\\n", 0, kstatus, kchan, kdata1, kdata2
endif

kcontinuous invalue "continuous"
if (kcontinuous == 1) then
	ktrigger metro 1
	schedkwhen  ktrigger, 0.2, 2, 1, 0, 0.5
endif

endin


</CsInstruments>
<CsScore>

i130 0 3600
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>387</width>
 <height>245</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>0</r>
  <g>162</g>
  <b>207</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>44</y>
  <width>382</width>
  <height>82</height>
  <uuid>{a622c79b-7121-4536-a2e0-b015e89d9ce8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Note events:</label>
  <alignment>left</alignment>
  <font>Courier 10 Pitch</font>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>129</y>
  <width>184</width>
  <height>116</height>
  <uuid>{f06fb4fb-fa71-4a65-b1f9-5059aa8f3f98}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Control Change:</label>
  <alignment>left</alignment>
  <font>Courier 10 Pitch</font>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>cc</objectName>
  <x>130</x>
  <y>159</y>
  <width>40</width>
  <height>25</height>
  <uuid>{7d5482f8-90ac-4c15-85e9-6686099dea99}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ccvalue</objectName>
  <x>130</x>
  <y>184</y>
  <width>40</width>
  <height>25</height>
  <uuid>{49f26ebe-4789-4aa7-a303-0fd7a0758ca5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>240</r>
   <g>220</g>
   <b>229</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>channel</objectName>
  <x>130</x>
  <y>209</y>
  <width>40</width>
  <height>25</height>
  <uuid>{b69d20a4-4a3a-43b9-be8d-365f892654e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>220</r>
   <g>217</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>button1</objectName>
  <x>201</x>
  <y>133</y>
  <width>179</width>
  <height>26</height>
  <uuid>{e610428b-9613-492f-981a-ec823dddd59f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Generate note</text>
  <image>/</image>
  <eventLine>i1 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>continuous</objectName>
  <x>205</x>
  <y>171</y>
  <width>20</width>
  <height>20</height>
  <uuid>{3d9b96f9-6f0f-4dde-b950-a21cd70da655}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>223</x>
  <y>166</y>
  <width>164</width>
  <height>29</height>
  <uuid>{bda319e2-b5c7-4c0d-bb0c-d18a8fd6ead6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Generate continuously</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>4</x>
  <y>162</y>
  <width>125</width>
  <height>24</height>
  <uuid>{c59e3dc3-2170-4a7e-a86c-98a87c617b34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Controller number CC#</label>
  <alignment>right</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>19</x>
  <y>187</y>
  <width>110</width>
  <height>25</height>
  <uuid>{3eebf83b-458e-4146-b6b0-24785b1ed43b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Value</label>
  <alignment>right</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>33</x>
  <y>211</y>
  <width>96</width>
  <height>25</height>
  <uuid>{36be481e-3963-438c-8e92-ea9f9cc7f0cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Channel</label>
  <alignment>right</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName>note</objectName>
  <x>4</x>
  <y>67</y>
  <width>381</width>
  <height>53</height>
  <uuid>{a8853b05-75b5-401d-b391-04e2eb716b5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Note On: chan = 0 note#  = 0 velocity = 0</label>
  <alignment>left</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>5</x>
  <y>7</y>
  <width>382</width>
  <height>32</height>
  <uuid>{2b23d88f-41e4-4238-9dbd-cdfbb0a91c65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>MIDI I/O</label>
  <alignment>center</alignment>
  <font>DejaVu Sans Mono</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 329 376 406 285
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {0, 41634, 53199}
ioText {4, 44} {382, 82} label 0.000000 0.00100 "" left "Courier 10 Pitch" 12 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Note events:
ioText {4, 129} {184, 116} label 0.000000 0.00100 "" left "Courier 10 Pitch" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Control Change:
ioText {130, 159} {40, 25} display 0.000000 0.00100 "cc" left "DejaVu Sans" 14 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0
ioText {130, 184} {40, 25} display 0.000000 0.00100 "ccvalue" left "DejaVu Sans" 14 {0, 0, 0} {61440, 56320, 58624} nobackground noborder 0
ioText {130, 209} {40, 25} display 0.000000 0.00100 "channel" left "DejaVu Sans" 14 {0, 0, 0} {56320, 55552, 65280} nobackground noborder 0
ioButton {201, 133} {179, 26} event 1.000000 "button1" "Generate note" "/" i1 0 1
ioCheckbox {205, 171} {20, 20} off continuous
ioText {223, 166} {164, 29} label 0.000000 0.00100 "" left "DejaVu Sans" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Generate continuously
ioText {4, 162} {125, 24} label 0.000000 0.00100 "" right "DejaVu Sans" 10 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Controller number CC#
ioText {19, 187} {110, 25} label 0.000000 0.00100 "" right "DejaVu Sans" 10 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Value
ioText {33, 211} {96, 25} label 0.000000 0.00100 "" right "DejaVu Sans" 10 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Channel
ioText {4, 67} {381, 53} label 0.000000 0.00100 "note" left "DejaVu Sans" 18 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Note On: chan = 0 note#  = 0 velocity = 0
ioText {5, 7} {382, 32} label 0.000000 0.00100 "" center "DejaVu Sans Mono" 22 {0, 0, 0} {65280, 65280, 65280} nobackground noborder MIDI I/O
</MacGUI>

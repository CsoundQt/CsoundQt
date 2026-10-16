; Written by Iain McCurdy, 2010

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 16     ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


; Chromatic scale - 12 items - negative table size permits the use of non-zero table size
giTable ftgen 0, 0, -12, -2, 8.00, 8.01, 8.02, 8.03, 8.04, 8.05, 8.06, 8.07, 8.08, 8.09, 8.10, 8.11
gisine  ftgen 0, 0, 4096, 10, 1  ; A sine wave


instr 1                       ; Shuffle table contents
  iNumItems = ftlen(giTable)  ; Derive the number of items in the function table
  ; Table of index values (+1) - should correspond to the number of items in the original
  ; table
  iIndices       ftgen 0, 0, -12, -2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
  iIndicesBuffer ftgen 0, 0, -12, -2, 0  ; Buffer table for jumbled up indices
  iTableBuffer   ftgen 0, 0, -12, -2, 0  ; Buffer table initially consisting of zeroes
  kcount init 1                          ; Initialise counter

begin:                          ; Label
  kfn random 0, iNumItems       ; Random table item index
  kfn = int(kfn)                ; Convert to integer (this step is not actually required)
  krandval table kfn, iIndices  ; Read the value at the randomly chosen index location
  ; Check if randomly chosen item has already been chosen and inserted into new table
  kcheckcount = 1  ; Counter used throughout checking process

checkbegin:  ; Label - start of checking process
  ; Read value from table according to current checkcount cycle
  kcheckval table kcheckcount-1, iIndicesBuffer
  ; If value already exists, redo the randomization process
  if (kcheckval = krandval) kgoto begin
  kcheckcount = kcheckcount + 1  ; Increment check counter
  ; Until all values have been tested repeat check for next value
  if (kcheckcount<kcount) kgoto checkbegin
  tablew krandval, kcount-1, iIndicesBuffer  ; Once value has been verified write to table
  kcount = kcount + 1                        ; Increment main counter
  if (kcount <= iNumItems) goto begin        ; Until table is filled repeat cycle

  ; Create new table in the buffer table according to new arrangement of indices
  kcount = 1  ; Set counter to '1'

begin2:                                 ; Beginning of loop label
  kndx table kcount-1, iIndicesBuffer   ; Read index value from table of indices buffer
  kval table kndx-1, giTable            ; Read item value at current index location
  tablew kval, kcount-1, iTableBuffer   ; Write read item into table buffer
  kcount = kcount + 1                   ; Increment counter
  if (kcount <= iNumItems) goto begin2  ; Until table is completely written repeat cycle

  tablecopy giTable, iTableBuffer  ; Replace original table with buffer (shuffled) table
  event "i", 2, 0, 0.1             ; Print table values
  turnoff                          ; When done, turn off this instrument
endin

instr 2                       ; Print table values to command line and boxes
  iNumItems = ftlen(giTable)  ; Derive the number of items in the function table
  prints "\\n"                ; Newline
  icount init 1               ; Initialize counter

BEGIN:                          ; Label
  ival table icount-1, giTable  ; Read value from table
  print ival                    ; Print read value
  icount = icount + 1           ; Increment counter
  ; Check if we are at the last value of table, if not, repeat print task
  if icount <= iNumItems goto BEGIN

  ; GUI update
  ; Create a macro to reduce code repetition
  #define FLPRINT(N)
  #
  ipch$N table $N-1, giTable  ; Read pitch values from table
  outvalue "Item$N", ipch$N   ; Write pitch values to text boxes
  #
  ; Execute macro multiple times
  $FLPRINT(1)
  $FLPRINT(2)
  $FLPRINT(3)
  $FLPRINT(4)
  $FLPRINT(5)
  $FLPRINT(6)
  $FLPRINT(7)
  $FLPRINT(8)
  $FLPRINT(9)
  $FLPRINT(10)
  $FLPRINT(11)
  $FLPRINT(12)

  turnoff  ; Turn this instrument off
endin

instr 3                       ; Trigger notes in sound generating instrument
  iNumItems = ftlen(giTable)  ; Derive the number of items in the function table
  icount init 1
  igap   init 0.2
  iwhen  init 0

PLAYBEGIN:
  ; Read pitch (pch format) from table according to where we are in the sequence
  ipch table icount-1, giTable
  event_i "i", 4, iwhen, 0.6, ipch  ; Create a note event to be played by instr 3
  iwhen = iwhen + igap              ; Create the time the next note will be played
  ; Gap between notes increases as we progress result in a rallentando (slowing down) as
  ; the sequence is played
  igap   = igap * 1.05
  icount = icount + 1
  ; Check if we are at the last value of table, if not, repeat print task
  if icount <= iNumItems goto PLAYBEGIN

  turnoff  ; Turn this instrument off
endin

instr 4                 ; Sound generating instrument
  aenv line 0.2, p3, 0  ; Create an amplitude envelope
  ; Generate an audio signal (pitch received from instr 2 via p4)
  a1 oscili aenv, cpspch(p4), gisine
  outs a1, a1  ; Send audio to outputs
endin

instr 5                                ; Perform retrograde
  iTableBuffer ftgen 0, 0, -12, -2, 0  ; Buffer table initially consisting of zeroes
  iNumItems = ftlen(giTable)           ; Derive the number of items in the function table
  ; Buffer table initially consisting of zeroes
  iTableBuffer ftgen 0, 0, -iNumItems, -2, 0
  kcount init 1  ; Initialise counter

begin:  ; Label
  kval table iNumItems - kcount, giTable
  tablew kval, kcount-1, iTableBuffer
  kcount = kcount + 1                  ; Increment main counter
  if (kcount <= iNumItems) goto begin  ; Until table is filled repeat cycle

  tablecopy giTable, iTableBuffer  ; Replace original table with buffer (shuffled) table
  event "i", 2, 0, 0.1             ; Print table values
  turnoff                          ; When done, turn off this instrument
endin
</CsInstruments>
<CsScore>
i 2 0 0.001
f 0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>707</x>
 <y>277</y>
 <width>834</width>
 <height>389</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>830</width>
  <height>387</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Shuffle Table Contents</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="background">
   <r>28</r>
   <g>33</g>
   <b>62</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b4918</objectName>
  <x>221</x>
  <y>42</y>
  <width>120</width>
  <height>30</height>
  <uuid>{55273d97-d39a-441c-8da6-87ea139493b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Shuffle</text>
  <image>/</image>
  <eventLine>i 1 0 0.1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
  <flatStyle>true</flatStyle>
  <color>
   <r>203</r>
   <g>206</g>
   <b>255</b>
  </color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1</x>
  <y>82</y>
  <width>69</width>
  <height>30</height>
  <uuid>{5cde19f3-b356-4945-9c8b-43dd67c604dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Items:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item1</objectName>
  <x>70</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{073ad371-9227-46fa-a005-ac10a210db79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.010</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>7</x>
  <y>141</y>
  <width>822</width>
  <height>245</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This example shuffles the contents of a function table in a fashion similar to shuffling a deck of cards. The table's contents in this example are the notes of a chromatic scale in pch format. Each time the 'Shuffle' button is clicked the order of these twelve items is changed. The new table is printed to the terminal and to the display boxes and can be played as a note row by clicking 'Play'. Table shuffling is achieved by generating a random number to be used as a table index. The value at this table index is read. Values are written into a buffer table but before this is done a checking procedure is executed that checks whether this value has already been chosen (this ensures that each item occurs in the new table only once). Once a value has been accepted and written into the buffer table. The process is repeated to find the next value for the buffer table. To carry out the entire process a number of k-rate loops are employed with counter varibles being used to check when the various iterative procedures are complete. To allow the use of items of the same value in the table the process is actually carried out on a table of indices (1, 2, 3...) so that the checking procedure described above can still be carried out. A buffer table of the new arrangement of items is created from this table of jumbled indices and finally written over the original table. As an additional feature the user can perform a retrograde on the table's contents which reverses their order.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item2</objectName>
  <x>130</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1c7548d5-44d5-4f66-899b-e6cdbee7808a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.040</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item3</objectName>
  <x>190</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0091d7b0-d91e-4d1f-9729-a96612841508}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.020</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item4</objectName>
  <x>250</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{538ce482-2100-4467-81d6-475e81c614a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.100</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item5</objectName>
  <x>310</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{850e956b-d5e3-4551-b9f2-6a49c59996e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.070</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item6</objectName>
  <x>370</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9095fb4d-a1f0-4c04-afd1-918857f5a163}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.090</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item7</objectName>
  <x>430</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7dc921c9-4410-4063-95ce-524870d15c01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.110</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item8</objectName>
  <x>490</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e0252740-6bed-46a0-9c35-5b01091bbcbb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.050</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item9</objectName>
  <x>549</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d73e14d2-c9ee-4edd-b45f-ff77dbcbd33f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item10</objectName>
  <x>609</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8eaf0662-173e-44ec-8e9e-fabc5fcec6e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.080</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item11</objectName>
  <x>669</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bdea0e8f-05c5-410b-9c44-cf2cce219735}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.030</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>Item12</objectName>
  <x>729</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a89842bb-482c-4739-8fa9-067021b6555d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.060</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b2538</objectName>
  <x>344</x>
  <y>42</y>
  <width>120</width>
  <height>30</height>
  <uuid>{1e59b306-95dc-4794-971f-317b107c22bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Retrograde</text>
  <image>/</image>
  <eventLine>i 5 0 0.1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
  <flatStyle>true</flatStyle>
  <color>
   <r>203</r>
   <g>206</g>
   <b>255</b>
  </color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>b6390</objectName>
  <x>467</x>
  <y>42</y>
  <width>120</width>
  <height>30</height>
  <uuid>{7a957253-a2ff-4e19-a6f5-f58e166dfcd7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine>i 3 0 0.1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
  <flatStyle>true</flatStyle>
  <color>
   <r>203</r>
   <g>206</g>
   <b>255</b>
  </color>
  <pressedColor>#9a9cc1</pressedColor>
  <borderColor>#9a9cc1</borderColor>
  <textColor>#202020</textColor>
  <pressedTextColor/>
  <borderWidth>2</borderWidth>
  <borderRadius>5</borderRadius>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>70</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3c66970d-2b76-4403-8782-b86055c3fa53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>130</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{27242e29-5816-4789-b845-8fc1be9dac45}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>190</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1412f652-df14-4c1a-97ed-ab9c5cb7f574}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>250</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9812161d-faed-4110-89da-0af03d8846e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4
</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>310</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{43f3b1df-f1de-41df-b371-7bf52ca4daa9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>370</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{248cebae-09e5-4597-ba15-c0a2b7860884}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>430</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4295e75d-84bd-4fb0-8328-be292aaf11c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>490</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{22f9ca83-afe5-4f81-b314-1ef894a8625d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>549</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4666b475-bc99-405a-af39-dbb7c1f93259}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>9</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>608</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a9cdd246-ffd5-4966-9cfd-a3ce3d1de5e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>669</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c5e342cd-b658-4e1c-9fc1-59de569db6b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>11</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>729</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0fae269e-209e-4dbd-9dee-c0c419fc0f41}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>12</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

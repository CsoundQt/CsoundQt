; Written by Iain McCurdy, 2008

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

; Notes on modifications from original csd:
; Add table for exp slider


; my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr     = 44100  ; Sample rate
ksmps  = 1      ; Number of audio samples in each control cycle
nchnls = 2      ; Number of channels (2=stereo)
0dbfs  = 1      ; Maximum amplitude regardless of bit depth


gidata ftgen 0, 0, 4, -2, 0
; 0=Binary non-zero=text - this defines the data type in the file saved to subsequently
; loaded from disk
giDataTypeFlag = 1
gisine ftgen 0, 0, 1024, 10, 1                ; Sine wave
giexp  ftgen 0, 0, 1024, 19, .5, .5, 270, .5  ; Exponential curve

; Table for exp slider
giExp1 ftgen 0, 0, 129, -25, 0, 1.0, 128, 5000.0
giExp3 ftgen 0, 0, 129, -25, 0, 50.0, 128, 5000.0


instr 10  ; GUI
  ktrig metro 10
  if (ktrig == 1) then
    gkSlider1 invalue "Slider1"
    gkSlider11 tablei gkSlider1, giExp1, 1
    gkSlider2 invalue "Slider2"
    gkSlider3 invalue "Slider3"
    gkSlider33 tablei gkSlider3, giExp3, 1
  endif
endin

instr 1                            ; Save data
  tableiw i(gkSlider1), 0, gidata  ; Slider data is written to the function table
  tableiw i(gkSlider2), 1, gidata  ; Slider data is written to the function table
  tableiw i(gkSlider3), 2, gidata  ; Slider data is written to the function table
  ; Function table is saved as a text file (file extension could be anything or nothing
  ; but making it a text file makes it easy to open and examine and possibly alter - for
  ; this, data type flag should be non-zero)
  ftsave "Data.txt", giDataTypeFlag, gidata
endin

instr 2                                      ; Load data
  ftload "Data.txt", giDataTypeFlag, gidata  ; Load file data.txt to function table gidata
  iSlider1 table 0, gidata                   ; Read data item from table
  outvalue "Slider1", iSlider1               ; Send data to the appropriate slider
  iSlider2 table 1, gidata                   ; Read data item from table
  outvalue "Slider2", iSlider2               ; Send data to the appropriate slider
  iSlider3 table 2, gidata                   ; Read data item from table
  outvalue "Slider3", iSlider3               ; Send data to the appropriate slider
endin

instr 3  ; Sound is produced by the fof opcode:
  ; Asig fof gkamp | kfund | kform | gkoct | gkband | gkris | gkdur | gkdec | iolaps |
  ; ifna | ifnb | itotdur
  asig fof 0.2, gkSlider11, gkSlider33, gkSlider2, 50, .003, .1, .007, 500, gisine, giexp, 3600
  outs asig, asig
endin
</CsInstruments>
<CsScore>
i 10 0 3600  ; GUI
i 3 0 3600
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
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
  <width>790</width>
  <height>321</height>
  <uuid>{049f4dd4-ff71-4d6d-9157-43c84efad8a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ftsave, ftload</label>
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
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Slider2</objectName>
  <x>159</x>
  <y>62</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e5fa660d-82a5-412a-a76a-500a0632ee0c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>4.00000000</maximum>
  <value>0.38400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Slider1</objectName>
  <x>159</x>
  <y>36</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3911e6c3-0337-45b0-81d8-e63c67cae1f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.65399998</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>Slider3</objectName>
  <x>159</x>
  <y>88</y>
  <width>500</width>
  <height>27</height>
  <uuid>{efb2995a-4ef2-403a-b994-9661bc9f673e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.46399999</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>114</y>
  <width>785</width>
  <height>208</height>
  <uuid>{d53e476a-429b-46b1-8781-cc346c263b62}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ftsave and ftload allow the contents of function tables to be saved to and loaded from files stored on the computer's hard disk. There could be many practical uses for this function. In this example I am using ftsave and ftload to store the locations of sliders (and therefore the variables they output). When the 'Save' button is pressed the values from the three sliders are first stored into a function table and then that function table is stored as a file on the hard disk which in this example I have named 'data.txt'. When the 'Load' button is pressed the reverse procedure is carried out - the file 'data.txt' is loaded into a function table, relevant values are read from the table and then sent to the sliders. The advantage that this method of storing presets might have over the method using QuteCsound embedded presets is that the user has control over which valuators to store in the preset file. When using ftsave and ftload we can save the data as binary data or as text. It doesn't really matter which we choose except that we need to be consistant with the choice we make for ftsave and for ftload. Choosing 'text' makes the file more readable in a text editor. The audio is a simple FOF sound.</label>
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
 <bsbObject type="BSBButton" version="2">
  <objectName>b5204</objectName>
  <x>19</x>
  <y>63</y>
  <width>60</width>
  <height>24</height>
  <uuid>{a20ec77f-2565-41d5-9d36-c2e9fe243e3d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Save</text>
  <image>/</image>
  <eventLine>i 1 0 0.01</eventLine>
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
  <objectName>b7826</objectName>
  <x>86</x>
  <y>63</y>
  <width>60</width>
  <height>24</height>
  <uuid>{48393902-ffd6-43f6-abac-f72a0cd66ee1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Load</text>
  <image>/</image>
  <eventLine>i 2 0 0.01</eventLine>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

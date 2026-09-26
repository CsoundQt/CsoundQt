<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

/*
Waveform widget example.

The widget draws the samples of a Csound f-table.
  - Send the table number to its table channel ("waveTable") to select what to
    display. Send a negative value to redraw the current table.
  - The cursor position (in samples) is read/written through the cursor channel
    ("waveCursor"): set it with chnset/outvalue, read it with chnget. Clicking in
    the widget moves the cursor and updates the channel.
  - Clicking sets the cursor; Ctrl+drag pans the view; the mouse wheel zooms
    in/out around the mouse and Shift+wheel scrolls.
  - The waveform is kept after the performance stops, so it can still be
    inspected and zoomed.

The example table is a stereo soundfile (gen 1), so the widget is told that the
table is interleaved with 2 channels. Channels are drawn stacked, one lane per
channel, sharing the time axis but with a separate amplitude axis each; set
Channels in the widget properties (or leave it at 0 to auto-detect with
ftchnls()).
*/

giWave ftgen 0, 0, 0, 1, "/home/em/Lib/snd/samples/speech/voiceover.flac", 0, 0, 0

instr 1
  ; Tell the widget that the table is interleaved (stereo), select it and put
  ; the cursor at 1/4 of it.
  ; outvalue "waveTable/channels", ftchnls(giWave)
  chnset giWave, "waveTable"
  chnset ftlen(giWave) / 4, "waveCursor"
  turnoff
endin

instr 2
  ; Read back the cursor set by the user in the widget.
  kpos chnget "waveCursor"
  if metro(2) == 1 then
    printks "cursor = %.0f samples (%.1f%% of the table)\n", 0,
            kpos, kpos / ftlen(giWave) * 100
  endif
endin

instr 10
  itab = giWave
  
  kspeed = chnget("speed")
  kamp = 1.0
  
  imod = 1 ; loop
  iend = nsamp(itab) / ftsr(itab)
  
_reset:
  ipos chnget "waveCursor"
  kpos init ipos
  
  asigs[] loscilx kamp, kspeed, itab, 4, 1, ipos, imod, ipos, iend
  
  kcursor chnget "waveCursor"
  if abs(kcursor - kpos) > ksmps*kspeed*100 then
    reinit _reset
  endif
  
  kpos += ksmps * kspeed
  
  if metro:k(30) == 1 then
    chnset kpos, "waveCursor"
  endif
  out asigs
endin

schedule 1, 1, 1

</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>









<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>820</width>
 <height>498</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>16</x>
  <y>10</y>
  <width>400</width>
  <height>38</height>
  <uuid>{6f2b2b1e-0001-4a1a-9a10-000000000001}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Waveform Widget</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>67</r>
   <g>67</g>
   <b>67</b>
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
 <bsbObject type="BSBWaveform" version="2">
  <objectName>waveTable</objectName>
  <x>20</x>
  <y>56</y>
  <width>800</width>
  <height>240</height>
  <uuid>{6f2b2b1e-0002-4a1a-9a10-000000000002}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>101</value>
  <objectName2>waveCursor</objectName2>
  <cursor>2737512</cursor>
  <color>
   <r>80</r>
   <g>200</g>
   <b>255</b>
  </color>
  <bgcolor>
   <r>24</r>
   <g>24</g>
   <b>24</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
  <cursorcolor>
   <r>255</r>
   <g>150</g>
   <b>0</b>
  </cursorcolor>
  <showGrid>false</showGrid>
  <showAxes>true</showAxes>
  <autoRange>true</autoRange>
  <channels>0</channels>
  <range>1.000000</range>
  <zoom>1.000000</zoom>
  <offset>0</offset>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>20</x>
  <y>310</y>
  <width>660</width>
  <height>100</height>
  <uuid>{6f2b2b1e-0003-4a1a-9a10-000000000003}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Wheel = zoom, Shift+Wheel = scroll, Ctrl+drag = pan, click = set cursor.
The table to display is set with chnset/outvalue on the "waveTable"
channel; the cursor is set/read on the "waveCursor" channel and by clicking.
For interleaved (e.g. stereo soundfile) tables set Channels to the
number of channels (0 = auto); channels are stacked in separate lanes.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>200</x>
  <y>486</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3fe7d589-56e6-4e1d-b83b-71b1ec7731bc}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>speed</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>88</r>
   <g>88</g>
   <b>88</b>
  </color>
  <bgcolor mode="nobackground">
   <r>49</r>
   <g>54</g>
   <b>59</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>speed</objectName>
  <x>201</x>
  <y>418</y>
  <width>80</width>
  <height>80</height>
  <uuid>{0b2db20b-536c-4814-9953-153944b006ae}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.10000000</minimum>
  <maximum>5.00000000</maximum>
  <value>0.63214000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#f57c00</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>play</objectName>
  <x>75</x>
  <y>446</y>
  <width>100</width>
  <height>30</height>
  <uuid>{f8d0095d-f980-424a-aded-e5707096f251}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>play/stop</text>
  <image>/</image>
  <eventLine>i 10 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>true</flatStyle>
  <color>
   <r>33</r>
   <g>66</g>
   <b>49</b>
  </color>
  <pressedColor>#7eaf94</pressedColor>
  <borderColor>#5c9375</borderColor>
  <textColor>#ffffff</textColor>
  <pressedTextColor>#e2e2e2</pressedTextColor>
  <borderWidth>2</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

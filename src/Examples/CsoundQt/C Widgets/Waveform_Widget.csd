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
  - Mouse wheel zooms in/out around the mouse, Shift+wheel scrolls, and dragging
    the mouse pans the view.

The example table is a stereo soundfile (gen 1), so the widget is told that the
table is interleaved with 2 channels. Channels are drawn overlaid with distinct
colours; set Channels in the widget properties (or send "<table channel>/channels"
from Csound, e.g. with ftchnls) to match the table.
*/

giWave ftgen 0, 0, 0, 1, "../../SourceMaterials/ClassicalGuitar.wav", 0, 0, 0

instr 1
  ; Tell the widget that the table is interleaved (stereo), select it and put
  ; the cursor at 1/4 of it.
  outvalue "waveTable/channels", ftchnls(giWave)
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

schedule 1, 1, 1
schedule 2, 1, 3600

</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>



<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>700</width>
 <height>430</height>
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
  <width>660</width>
  <height>240</height>
  <uuid>{6f2b2b1e-0002-4a1a-9a10-000000000002}</uuid>
  <widgetName/>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>101</value>
  <objectName2>waveCursor</objectName2>
  <cursor>257714</cursor>
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
  <channels>2</channels>
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
  <label>Wheel = zoom, Shift+Wheel = scroll, drag = pan, click = set cursor.
The table to display is set with chnset/outvalue on the "waveTable"
channel; the cursor is set/read on the "waveCursor" channel and by clicking.
For interleaved (e.g. stereo soundfile) tables set Channels to the
number of channels; channels are drawn overlaid with distinct colours.</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

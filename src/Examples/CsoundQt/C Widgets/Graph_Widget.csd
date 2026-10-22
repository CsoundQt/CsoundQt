<CsoundSynthesizer>
<CsOptions>
-odac 
</CsOptions>
<CsInstruments>

/*
Graph Widget

Graph Widgets can display tables, audio signals and fft analysis. The currently 
visible table can be changed by sending values on the widget's channel. 
Positive values change the table by index and negative values change the 
table by table number. The displayed table can also be changed using the 
menu on the upper left corner. 
Graph widgets can also show the spectrum from signals using the dispfft opcode, 
or time varying signals (a-rate and k-rate) using the display opcode. 
In spectrum mode, clicking near a peak will detect and display the frequency
of the highest peak near the mouse. If a peak channel was set (see below), this 
value will also be sent to that named channel.


Keyboard Shortcuts:

C: toggle table information (only in table mode)
F: freeze graph (only in spectrum mode)
G: toggle grid
H: help, show a dialog with this information
S: toggle selector menu
Z: toggle scrollbars
+/-: zoom in / out 


Methods

The graph is controlled from Csound with "methods". A method is called like a 
property, through outvalue "<graphid>/<method>", <argument>, but it is applied 
immediately and is never stored in the csd file. 

findfft <signal:str>      Show the spectrum (dispfft) curve matching <signal>.
findaudio <signal:str>    Show the waveform (display) curve matching <signal>.
findtable <tabnum:int>    Show the f-table with the given table number.
freeze <status:int>       Freeze (1) or unfreeze (0) a spectrum display.
peakchannel <chan:str>    Channel the detected peak frequency is written to. 
                          The peak is reported when the user clicks on a 
                          spectrum graph.

A numeric value sent on the graph's channel also selects a table: positive 
values address it by index, negative values by table number.
*/

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

gisin1 = ftgen(0, 0, 1024, 10, 1)
gisin2 = ftgen(0, 0, 1024, 10, 1, 0.5, 0.333)
gisin3 = ftgen(0, 0, 1024, 10, 1, 0, 0.333, 0, 0.25, 0, 0.166)
gisqr  = ftgen(0, 0, 1024, 7, 1, 512, 1, 0, -1, 512, -1)
gisaw  = ftgen(0, 0, 1024, 7, 1, 1024, -1)

instr Oscil

  itables[] = fillarray(gisin1, gisin2, gisin3, gisqr, gisaw)
  kindex = init(-1)
  kindex = chnget("tabindex")
  kindex = limit:k(kindex, 0, lenarray(itables)-1)
  ktab = itables[kindex]
  kfreq = chnget("freq")
  asig = oscilikt(0.2, kfreq, ktab)
  asig *= 0.1
  outch 1, asig, 2, asig

  dispfft asig, 0.05, 4096

  adisp = asig*5
  display adisp, 0.01

  if timeinstk() == 1 || changed(kindex) == 1 then
    ; A numeric value sent to the graph widget sets it to display the graph
    ; at that index. In this case, the graph is only enabled for tables,
    ; so that the index corresponds to the index of the itables array:
    ; outvalue "graph1", kindex
    ; The table number can be selected directly with the findtable method:
    outvalue "graph1/findtable", ktab
    ; ... or as a negative number sent on the graph's channel:
    ; outvalue "graph1", -ktab
    chnset(ktab, "plot1")
  endif

endin

instr SetupGraphs
  ; The desired graph is selected with methods:

  outvalue "graph2/findfft", "asig"
  outvalue "graph3/findaudio", "adisp"

  ; A spectrum graph (graph2) can be frozen and its detected peak sent
  ; to a named channel:
  ; outvalue "graph2/freeze", 1        ; 1 = freeze, 0 = unfreeze
  ; outvalue "graph2/peakchannel", "peak"

  ; outvalue "plot1", gisin1
  turnoff
endin

; If started too early, the table display will fail
schedule "Oscil", 0.3, -1

; setup the display graphs. Notice that we need to schedule this in the
; future since audio and fft graphs start existing when the first
; display is ready, which in the case of fft graphs is after the first
; window has been filled (delay = winsize/sr) and in the case of audio
; signals is the period itself

schedule "SetupGraphs", 0.5, 1

</CsInstruments>
<CsScore>
f0 3600
</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>730</width>
 <height>739</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>212</r>
  <g>221</g>
  <b>230</b>
 </bgcolor>
 <bsbObject type="BSBGraph" version="2">
  <objectName>graph1</objectName>
  <x>5</x>
  <y>65</y>
  <width>360</width>
  <height>189</height>
  <uuid>{ec9057d4-b17b-4c85-b694-0dec1a12500a}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>true</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>true</showScrollbars>
  <enableTables>true</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>tabindex</objectName>
  <x>90</x>
  <y>262</y>
  <width>50</width>
  <height>40</height>
  <uuid>{12cab531-987e-41ac-9262-d5f71c064805}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <color>
   <r>85</r>
   <g>0</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>218</r>
   <g>218</g>
   <b>218</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>4</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>267</y>
  <width>85</width>
  <height>30</height>
  <uuid>{d70336af-31c0-46c6-8288-9113647dfccf}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Table Index</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBGraph" version="2">
  <objectName>graph2</objectName>
  <x>5</x>
  <y>350</y>
  <width>570</width>
  <height>189</height>
  <uuid>{23c327bd-bf0d-492b-90dd-e6536e96ae62}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>0</value>
  <objectName2/>
  <zoomx>4.00000000</zoomx>
  <zoomx>4.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>true</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>false</showScrollbars>
  <enableTables>false</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject type="BSBGraph" version="2">
  <objectName>graph3</objectName>
  <x>5</x>
  <y>560</y>
  <width>570</width>
  <height>189</height>
  <uuid>{43a72640-7329-4222-abdb-bbd4584d49c0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>false</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>true</showScrollbars>
  <enableTables>true</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>freq</objectName>
  <x>210</x>
  <y>255</y>
  <width>55</width>
  <height>55</height>
  <uuid>{e273f498-ec83-4aa1-bc8a-5dbde9a50fcf}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>20.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <exponent>1.00000000</exponent>
  <value>743.73000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#4a2600</textcolor>
  <border>1</border>
  <borderColor>#4a2600</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>145</x>
  <y>267</y>
  <width>64</width>
  <height>30</height>
  <uuid>{e0e7e340-f91d-4b1a-83f7-99afd9b06fec}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Freq</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>6</x>
  <y>1</y>
  <width>202</width>
  <height>45</height>
  <uuid>{9084758a-d369-4258-a038-c3887349a499}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Graph Widget</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>28</fontsize>
  <precision>0</precision>
  <padding>2</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBTableDisplay" version="2">
  <objectName>plot1</objectName>
  <x>370</x>
  <y>65</y>
  <width>360</width>
  <height>189</height>
  <uuid>{ccc0ad50-1250-4166-987c-eb32de8a9566}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <color>
   <r>255</r>
   <g>193</g>
   <b>3</b>
  </color>
  <range>0.00</range>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>42</y>
  <width>247</width>
  <height>24</height>
  <uuid>{895a45e4-944d-4121-b5ed-d012a62b8893}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Graph Widget can display STATIC tables</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <precision>3</precision>
  <padding>2</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>370</x>
  <y>41</y>
  <width>247</width>
  <height>24</height>
  <uuid>{ec8cdf60-0106-4db3-8ca6-49dc35779522}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Table Plot widget would show changes in a table</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <precision>3</precision>
  <padding>2</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>4</x>
  <y>310</y>
  <width>303</width>
  <height>38</height>
  <uuid>{9a77618a-96c8-4a63-b6a7-74e9af0b3ee2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Spectrum graph widget, driven by dispfft
Click on a peak to display its frequency</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>5</x>
  <y>540</y>
  <width>238</width>
  <height>23</height>
  <uuid>{95516290-ec6d-42db-aea9-418260ff1003}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Signal graph widget, driven by display opcode</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>11</fontsize>
  <precision>3</precision>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

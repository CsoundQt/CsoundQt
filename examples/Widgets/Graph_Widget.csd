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
table by table number. The displayed table can also be changed using the 
menu on the upper left corner. 
Graph widgets can also show the spectrum from signals using the dispfft opcode, 
or time varying signals (a-rate and k-rate) using the display opcode. 
In spectrum mode, clicking near a peak will detect and display the frequency
of the highest peak near the mouse. If @getPeak was set, this value will also 
be output to the given named channel


Keyboard Shortcuts:

C: toggle table information (only in table mode)
F: freeze graph (only in spectrum mode)
G: toggle grid
H: help, show a dialog with this information
S: toggle selector menu
Z: toggle scrollbars
+/-: zoom in / out 


String commands:

@set <index:int>    Sets the index graph to be displayed, similar to `outvalue "graphid", index`
@find fft   <signal:str>
@find audio <signal:str>
@find table <tablenumber:int>
@freeze <status:int>  1 - freeze the display, 0 - unfreeze
@getPeak <chan:str>   The peak frequency is output to the given named channel. The peak 
                      is output whenever the user clicks on a spectrum graph
                      NB: see Examples/Useful/SpectrumAnalyzer for an example of this
                      feature 

*/

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

gisin1 ftgen 0, 0, 1024, 10, 1
gisin2 ftgen 0, 0, 1024, 10, 1, 0.5, 0.333
gisin3 ftgen 0, 0, 1024, 10, 1, 0, 0.333, 0, 0.25
gisqr  ftgen 0, 0, 1024, 7, 1, 512, 1, 0, -1, 512, -1
gisaw  ftgen 0, 0, 1024, 7, 1, 1024, -1

instr Oscil
	itables[] fillarray gisin1, gisin2, gisin3, gisqr, gisaw 
	kindex invalue "tabindex"
	kindex = limit:k(kindex, 0, lenarray(itables)-1)
	ktab = itables[kindex]
	kfreq invalue "freq"
	asig oscilikt 0.2, kfreq, ktab
	asig *= 0.1
	outch 1, asig, 2, asig
	
	dispfft asig, 0.05, 4096
	
	adisp = asig*5
	display adisp, 0.01
	
	if changed(kindex) == 1 then
		; A numeric value sent to the graph widget sets it to display graph 
		; at that index. In this case, the graph is only enabled for tables,
		; so that the index corresponds to the index of the itables array
		; outvalue "graph1", kindex
		; Another possibility is to the the table number directly via the
		; @find command:
		outvalue "graph1", sprintfk("@find table %d", ktab)
	endif
	
endin

instr SetupGraphs
	; It is possible to select the desired graph through the @find string command
	outvalue "graph2", "@find fft asig"
	outvalue "graph3", "@find audio adisp"
	
	; To select a table by number: 
	; outvalue "graph1", sprintf("@find table %d", itabnum) 
	turnoff
endin

schedule "Oscil", 0, -1

; setup the display graphs. Notice that we need to schedule this in the
; future since audio and fft graphs start existing when the first
; display is ready, which in the case of fft graphs is after the first
; window has been filled (delay = winsize/sr) and in the case of audio
; signals is the period itself

schedule "SetupGraphs", 0.3, 1

</CsInstruments>
<CsScore>
f0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject type="BSBGraph" version="2">
  <objectName>graph1</objectName>
  <x>15</x>
  <y>55</y>
  <width>458</width>
  <height>189</height>
  <uuid>{ec9057d4-b17b-4c85-b694-0dec1a12500a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>1</value>
  <objectName2/>
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
  <x>120</x>
  <y>245</y>
  <width>50</width>
  <height>40</height>
  <uuid>{12cab531-987e-41ac-9262-d5f71c064805}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>85</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>4</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>250</y>
  <width>105</width>
  <height>32</height>
  <uuid>{d70336af-31c0-46c6-8288-9113647dfccf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Table Index</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
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
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBGraph" version="2">
  <objectName>graph2</objectName>
  <x>15</x>
  <y>305</y>
  <width>458</width>
  <height>189</height>
  <uuid>{23c327bd-bf0d-492b-90dd-e6536e96ae62}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>5</value>
  <objectName2/>
  <zoomx>4.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>false</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>false</showScrollbars>
  <enableTables>false</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject type="BSBGraph" version="2">
  <objectName>graph3</objectName>
  <x>15</x>
  <y>520</y>
  <width>458</width>
  <height>189</height>
  <uuid>{43a72640-7329-4222-abdb-bbd4584d49c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>6</value>
  <objectName2/>
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
  <x>495</x>
  <y>55</y>
  <width>80</width>
  <height>80</height>
  <uuid>{e273f498-ec83-4aa1-bc8a-5dbde9a50fcf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>20.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>307.63000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#000000</textcolor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>505</x>
  <y>130</y>
  <width>64</width>
  <height>30</height>
  <uuid>{e0e7e340-f91d-4b1a-83f7-99afd9b06fec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Freq</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
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
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>15</x>
  <y>5</y>
  <width>174</width>
  <height>40</height>
  <uuid>{9084758a-d369-4258-a038-c3887349a499}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Graph Widget</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>28</fontsize>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

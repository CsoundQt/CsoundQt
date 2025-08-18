<CsoundSynthesizer>
<CsOptions>
-odac 
--messagelevel=134
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 4
0dbfs = 1
A4 = 442

chn_k "peak", 1   ; Channel to get peak information from graph

gi_fftSizes[] fillarray 2048, 4096, 8192, 16384
gk_fftSize init 4096
gk_peakFreq init 0
gk_peakGain init 0

gi_refreshRates[] fillarray 10,12,15,18,20,24,30
gk_refreshRate init 20


instr PlayPeak
	; play the detected peak frequency
	kamp = ampdb(gk_peakGain)
	apeak oscili kamp, sc_lag(gk_peakFreq, 0.1)
	apeak *= linsegr:a(0, 0.1, 1, 0.1, 0)
	outch 1, apeak
endin

instr Spectrum
	k0 invalue "ch1"
	k1 invalue "ch2"
	k2 invalue "ch3"
	k3 invalue "ch4"
	kfftSizeIndex invalue "fftsize"
	kplayPeak     invalue "playpeak"
	kfilterlow    invalue "filterlow"
	kinGain       invalue "ingain"
	gk_peakGain   invalue "peakgain"
	krefreshRateIdx invalue "refreshrateidx"
	
	; We need to use chnget to receive the peak information
	kpeak chnget "peak"
	khasPeak = kpeak > 0 ? 1:0
	gk_peakFreq samphold kpeak, khasPeak
	
	if kplayPeak == 1 && changed(khasPeak) == 1 then
		if khasPeak == 1 then
			schedulek("PlayPeak", 0, -1)
		else
			turnoff2("PlayPeak", 0, 1)
		endif
	endif
	
	kfftSize = gi_fftSizes[kfftSizeIndex]
	krefreshRate = gi_refreshRates[krefreshRateIdx]
	
	if kfftSize != gk_fftSize || krefreshRate != gk_refreshRate then 
		gk_fftSize = kfftSize
		gk_refreshRate = krefreshRate
		reinit dispReset
	endif 
	
	a0 inch 1
	a1 inch 2
	a2 init 0
	a3 init 0
	a0 *= k0
	a1 *= k1
	if nchnls > 2 then
		a2 inch 3
		a2 *= k2
		if nchnls > 3 then
			a3 inch 4
			a3 *= k3
		endif
	endif
	
	amix = sum(a0, a1, a2, a3)
	amix *= ampdb(kinGain)
	 
	; filter low frequencies from spectrum
	if kfilterlow == 1 then
		aspectrum pareq amix, 30, 0, 0.05, 1
	else
		aspectrum = amix
	endif
	
	denorm aspectrum
	
dispReset:
	iperiod = 1/i(gk_refreshRate)
	print iperiod
	dispfft aspectrum, iperiod, i(gk_fftSize)
	
endin

instr PostInit
	; this needs to run at a point where the fft curve already 
	; exists, which, depending on gk_fftSize, is, at the latest,
	; 16384 / sr (16384 / 44100 = 0.37...)
	outvalue "spectrum", "@find fft aspectrum"
	outvalue "spectrum", "@getPeak peak"
	turnoff
endin


schedule "Spectrum", 0, -1
schedule "PostInit", 16384/sr + 0.01, -1

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>










<MacGUI>
ioView background {5654, 5654, 5654}
ioGraph {10, 70} {1000, 500} table 0.000000 2.000000 spectrum
ioCheckbox {10, 580} {30, 30} on ch1
ioCheckbox {40, 580} {30, 30} off ch2
ioCheckbox {70, 580} {30, 30} off ch3
ioCheckbox {100, 580} {30, 30} off ch4
ioMenu {150, 580} {80, 30} 2 303 "2048,4096,8192,16384" fftsize
ioText {30, 550} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Channels
ioText {145, 550} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61696, 61696, 61696} {65024, 65024, 64768} nobackground noborder FFT Size
ioCheckbox {460, 580} {30, 30} on playpeak
ioText {435, 550} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Play peak
ioKnob {585, 575} {56, 54} 24.000000 -24.000000 0.010000 0.000000 ingain
ioText {505, 530} {80, 25} label 0.000000 0.00100 "" right "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Input Gain (dB)
ioKnob {720, 575} {56, 54} 0.000000 -80.000000 0.010000 -23.704000 peakgain
ioText {640, 530} {80, 25} label 0.000000 0.00100 "" right "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Peak Gain (dB)
ioText {340, 550} {100, 26} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Filter low freqs
ioCheckbox {375, 580} {30, 30} on filterlow
ioMenu {250, 580} {80, 30} 4 303 "10,12,15,18,20,24,30" refreshrateidx
ioText {250, 550} {84, 25} label 0.000000 0.00100 "" center "Arial" 13 {61696, 61696, 61696} {65024, 65024, 64768} nobackground noborder Refresh Rate
ioText {794, 519} {196, 45} label 0.000000 0.00100 "" left "Liberation Sans" 13 {61184, 61184, 61184} {12288, 13568, 14848} nobackground noborder Press mouse in spectrum display to show nearest  peak
</MacGUI>


<MacGUI>
ioView background {5654, 5654, 5654}
ioGraph {10, 80} {1000, 500} table 0.000000 2.000000 spectrum
ioCheckbox {10, 590} {30, 30} on ch1
ioCheckbox {40, 590} {30, 30} off ch2
ioCheckbox {70, 590} {30, 30} off ch3
ioCheckbox {100, 590} {30, 30} off ch4
ioMenu {150, 590} {80, 30} 2 303 "2048,4096,8192,16384" fftsize
ioText {30, 610} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Channels
ioText {145, 610} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61696, 61696, 61696} {65024, 65024, 64768} nobackground noborder FFT Size
ioCheckbox {460, 590} {30, 30} on playpeak
ioText {435, 610} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Play peak
ioKnob {585, 585} {56, 54} 24.000000 -24.000000 0.010000 0.000000 ingain
ioText {505, 590} {80, 25} label 0.000000 0.00100 "" right "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Input Gain (dB)
ioKnob {720, 585} {56, 54} 0.000000 -80.000000 0.010000 -23.704000 peakgain
ioText {640, 590} {80, 25} label 0.000000 0.00100 "" right "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Peak Gain (dB)
ioText {340, 610} {100, 26} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Filter low freqs
ioCheckbox {375, 590} {30, 30} on filterlow
ioMenu {250, 590} {80, 30} 4 303 "10,12,15,18,20,24,30" refreshrateidx
ioText {250, 610} {84, 25} label 0.000000 0.00100 "" center "Arial" 13 {61696, 61696, 61696} {65024, 65024, 64768} nobackground noborder Refresh Rate
ioText {795, 580} {196, 45} label 0.000000 0.00100 "" left "Liberation Sans" 13 {61184, 61184, 61184} {12288, 13568, 14848} nobackground noborder Press mouse in spectrum display to show nearest  peak
ioText {10, 10} {999, 70} label 0.000000 0.00100 "" center "Liberation Sans" 24 {61184, 61184, 61184} {12288, 13568, 14848} nobackground noborder Spectrum Analyzer¬Spectral Analysis of Live Input (up to four input channels)
</MacGUI>


<MacGUI>
ioView background {5654, 5654, 5654}
ioGraph {10, 80} {1000, 500} table 0.000000 2.000000 spectrum
ioCheckbox {10, 590} {30, 30} on ch1
ioCheckbox {40, 590} {30, 30} off ch2
ioCheckbox {70, 590} {30, 30} off ch3
ioCheckbox {100, 590} {30, 30} off ch4
ioMenu {150, 590} {80, 30} 2 303 "2048,4096,8192,16384" fftsize
ioText {30, 620} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Channels
ioText {145, 620} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61696, 61696, 61696} {65024, 65024, 64768} nobackground noborder FFT Size
ioCheckbox {460, 590} {30, 30} on playpeak
ioText {435, 620} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Play peak
ioKnob {585, 585} {56, 54} 24.000000 -24.000000 0.010000 0.000000 ingain
ioText {505, 600} {80, 25} label 0.000000 0.00100 "" right "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Input Gain (dB)
ioKnob {720, 585} {56, 54} 0.000000 -80.000000 0.010000 -23.704000 peakgain
ioText {640, 600} {80, 25} label 0.000000 0.00100 "" right "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Peak Gain (dB)
ioText {340, 620} {100, 26} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Filter low freqs
ioCheckbox {375, 590} {30, 30} on filterlow
ioMenu {250, 590} {80, 30} 4 303 "10,12,15,18,20,24,30" refreshrateidx
ioText {250, 620} {84, 25} label 0.000000 0.00100 "" center "Arial" 13 {61696, 61696, 61696} {65024, 65024, 64768} nobackground noborder Refresh Rate
ioText {795, 590} {196, 45} label 0.000000 0.00100 "" left "Liberation Sans" 13 {61184, 61184, 61184} {12288, 13568, 14848} nobackground noborder Press mouse in spectrum display to show nearest  peak
ioText {10, 10} {999, 70} label 0.000000 0.00100 "" center "Liberation Sans" 24 {61184, 61184, 61184} {12288, 13568, 14848} nobackground noborder Spectrum Analyzer¬Spectral Analysis of Live Input (up to four input channels)
</MacGUI>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>625</x>
 <y>177</y>
 <width>1051</width>
 <height>691</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>22</r>
  <g>22</g>
  <b>22</b>
 </bgcolor>
 <bsbObject type="BSBGraph" version="2">
  <objectName>spectrum</objectName>
  <x>10</x>
  <y>80</y>
  <width>1000</width>
  <height>500</height>
  <uuid>{ae3dee92-fc91-44c4-9b0f-b8656a7eb4f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>Spectrum - Press mouse to show/play peak</description>
  <value>0</value>
  <objectName2/>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>false</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>false</showTableInfo>
  <showScrollbars>false</showScrollbars>
  <enableTables>false</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>ch1</objectName>
  <x>10</x>
  <y>590</y>
  <width>30</width>
  <height>30</height>
  <uuid>{5aae7b7e-875a-492f-89cb-dbb779039dbe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>Enable Channel 1</description>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>ch2</objectName>
  <x>40</x>
  <y>590</y>
  <width>30</width>
  <height>30</height>
  <uuid>{00c02e40-ab30-4c76-8737-0f1c375df75a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>Enable Channel 2</description>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>ch3</objectName>
  <x>70</x>
  <y>590</y>
  <width>30</width>
  <height>30</height>
  <uuid>{cb2805f4-c9ec-4a28-ba5c-459a2e3cec59}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>Enable Channel 3</description>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>ch4</objectName>
  <x>100</x>
  <y>590</y>
  <width>30</width>
  <height>30</height>
  <uuid>{2192eed2-7818-45d5-8593-200cb766966c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>Enable Channel 4</description>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>fftsize</objectName>
  <x>150</x>
  <y>590</y>
  <width>80</width>
  <height>30</height>
  <uuid>{e3a55dea-950a-4c43-a7ef-50f107379f17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description>FFT size</description>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>2048</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4096</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8192</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16384</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>30</x>
  <y>620</y>
  <width>80</width>
  <height>25</height>
  <uuid>{342a2cbb-91b5-413b-9de1-aa82f1d74a0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Channels</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
  <precision>3</precision>
  <color>
   <r>239</r>
   <g>240</g>
   <b>241</b>
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
  <x>145</x>
  <y>620</y>
  <width>80</width>
  <height>25</height>
  <uuid>{09805d02-0ae6-4f4c-9c39-6b7e61fb1356}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>FFT Size</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>241</g>
   <b>241</b>
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
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>playpeak</objectName>
  <x>460</x>
  <y>590</y>
  <width>30</width>
  <height>30</height>
  <uuid>{f8803c6a-6fba-459f-a113-0e33c0ff19d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description>Play the peak frequency when the mouse is pressed</description>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>435</x>
  <y>620</y>
  <width>80</width>
  <height>25</height>
  <uuid>{67e8666d-183c-491d-b465-61d7a1a218d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Play peak</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
  <precision>3</precision>
  <color>
   <r>239</r>
   <g>240</g>
   <b>241</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>ingain</objectName>
  <x>585</x>
  <y>585</y>
  <width>56</width>
  <height>54</height>
  <uuid>{ce2ca6ad-fa91-4b89-a2eb-7c092f529f22}</uuid>
  <visible>true</visible>
  <midichan>1</midichan>
  <midicc>7</midicc>
  <description>Input Gain (dB)</description>
  <minimum>-24.00000000</minimum>
  <maximum>24.00000000</maximum>
  <value>0.00000000</value>
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
  <borderColor>#000000</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>true</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>505</x>
  <y>600</y>
  <width>80</width>
  <height>25</height>
  <uuid>{8e80da70-b7b1-4f2d-935c-3e78f2730099}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Input Gain (dB)</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
  <precision>3</precision>
  <color>
   <r>239</r>
   <g>240</g>
   <b>241</b>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>peakgain</objectName>
  <x>720</x>
  <y>585</y>
  <width>56</width>
  <height>54</height>
  <uuid>{5951dec6-0e29-4eed-a7c9-3438955fabc4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description>Input Gain (dB)</description>
  <minimum>-80.00000000</minimum>
  <maximum>0.00000000</maximum>
  <value>-23.70400000</value>
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
  <integerMode>true</integerMode>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>640</x>
  <y>600</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b1e91595-3134-4b62-943e-17e7f17b2058}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Peak Gain (dB)</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
  <precision>3</precision>
  <color>
   <r>239</r>
   <g>240</g>
   <b>241</b>
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
  <x>340</x>
  <y>620</y>
  <width>100</width>
  <height>26</height>
  <uuid>{d9b44e66-bfec-4a49-ba48-e52e29d1e889}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Filter low freqs</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
  <precision>3</precision>
  <color>
   <r>239</r>
   <g>240</g>
   <b>241</b>
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
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>filterlow</objectName>
  <x>375</x>
  <y>590</y>
  <width>30</width>
  <height>30</height>
  <uuid>{761ac268-c49b-4473-a0df-c045ea9fdaa4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description>Filter low frequencies</description>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>refreshrateidx</objectName>
  <x>250</x>
  <y>590</y>
  <width>80</width>
  <height>30</height>
  <uuid>{6aab35af-5577-4c32-a245-d69c50b0dfcd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description>Refresh Rate</description>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>10</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>4</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>250</x>
  <y>620</y>
  <width>84</width>
  <height>25</height>
  <uuid>{432a9bd1-1587-40a7-a618-e256a453b4e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Refresh Rate</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
  <precision>3</precision>
  <color>
   <r>241</r>
   <g>241</g>
   <b>241</b>
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
  <x>795</x>
  <y>590</y>
  <width>196</width>
  <height>45</height>
  <uuid>{13da7982-27d8-46ae-a425-3aecf9e1c34c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Press mouse in spectrum display to show nearest  peak</label>
  <alignment>left</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>13</fontsize>
  <precision>3</precision>
  <color>
   <r>239</r>
   <g>239</g>
   <b>239</b>
  </color>
  <bgcolor mode="background">
   <r>48</r>
   <g>53</g>
   <b>58</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>10</y>
  <width>999</width>
  <height>70</height>
  <uuid>{272ab196-d807-4b5f-a506-2f391cf651f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Spectrum Analyzer
Spectral Analysis of Live Input (up to four input channels)</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>239</r>
   <g>239</g>
   <b>239</b>
  </color>
  <bgcolor mode="background">
   <r>48</r>
   <g>53</g>
   <b>58</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView background {5654, 5654, 5654}
ioGraph {10, 80} {1000, 500} table 0.000000 2.000000 spectrum
ioCheckbox {10, 590} {30, 30} on ch1
ioCheckbox {40, 590} {30, 30} off ch2
ioCheckbox {70, 590} {30, 30} off ch3
ioCheckbox {100, 590} {30, 30} off ch4
ioMenu {150, 590} {80, 30} 2 303 "2048,4096,8192,16384" fftsize
ioText {30, 620} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Channels
ioText {145, 620} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61696, 61696, 61696} {65024, 65024, 64768} nobackground noborder FFT Size
ioCheckbox {460, 590} {30, 30} on playpeak
ioText {435, 620} {80, 25} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Play peak
ioKnob {585, 585} {56, 54} 24.000000 -24.000000 0.010000 0.000000 ingain
ioText {505, 600} {80, 25} label 0.000000 0.00100 "" right "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Input Gain (dB)
ioKnob {720, 585} {56, 54} 0.000000 -80.000000 0.010000 -23.704000 peakgain
ioText {640, 600} {80, 25} label 0.000000 0.00100 "" right "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Peak Gain (dB)
ioText {340, 620} {100, 26} label 0.000000 0.00100 "" center "Arial" 13 {61184, 61440, 61696} {65024, 65024, 64768} nobackground noborder Filter low freqs
ioCheckbox {375, 590} {30, 30} on filterlow
ioMenu {250, 590} {80, 30} 4 303 "10,12,15,18,20,24,30" refreshrateidx
ioText {250, 620} {84, 25} label 0.000000 0.00100 "" center "Arial" 13 {61696, 61696, 61696} {65024, 65024, 64768} nobackground noborder Refresh Rate
ioText {795, 590} {196, 45} label 0.000000 0.00100 "" left "Liberation Sans" 13 {61184, 61184, 61184} {12288, 13568, 14848} nobackground noborder Press mouse in spectrum display to show nearest  peak
ioText {10, 10} {999, 70} label 0.000000 0.00100 "" center "Liberation Sans" 24 {61184, 61184, 61184} {12288, 13568, 14848} nobackground noborder Spectrum Analyzer¬Spectral Analysis of Live Input (up to four input channels)
</MacGUI>

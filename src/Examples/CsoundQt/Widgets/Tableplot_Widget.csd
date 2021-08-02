<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

/*
This is the example file for the Table Plot Widget

This widget allows to visualize the contents of a table in 
real-time. To set the table number to plot send the table 
number to its channel. To update the plot just send -1 and
the last set table will be updated. 

The widget also accepts string values. The table can be set 
via "@set tablenumber" and it can be updated via "@update"

*/

;; Create two empty tables
gi1 ftgen 0, 0, 1024, 2, 0
gi2 ftgen 0, 0,  512, 2, 0   

instr 1
	;; Here we just set the table number for each plot
	;; The table number can be either set via a number...
	outvalue "plot1", p4
	;; or via the command "@set"
	outvalue "plot2", sprintf("@set %d", p5)
	
	;; Schedule the tables to be switched in 5 seconds
	schedule 1, 5, -1, p5, p4
	turnoff
endin

instr 2
	;; Here we modify the tables
	ilen = ftlen(gi1)
	
	;; We fill a table with an aplitude varying sine wave
	kamp = linlin(oscil:k(1, 0.1), 1, 8, -1, 1)
	; kamp linseg 0.5, 4, 10, 4, 0.5
	kval oscil kamp, 10
	kidx = timeinstk() % ilen
	tablew kval, kidx, gi1
	
	;; The second table is filled with realtime audio input
	aidx phasor sr/ftlen(gi2)
	tablew inch(1), aidx, gi2, 1 
	
	if metro(24) == 1 then
		;; the "k" is necessary to make outvalue a k-time opcode
		;; the -1 sent at k-time will update the current table
		outvalue "plot1", k(-1)
		outvalue "plot2", "@update"
	endif
endin

schedule 1, 0, -1, gi1, gi2
schedule 2, 0.001, 3600

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>435</width>
 <height>149</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject type="BSBTableDisplay" version="2">
  <objectName>plot2</objectName>
  <x>370</x>
  <y>74</y>
  <width>360</width>
  <height>220</height>
  <uuid>{0c6062cd-26ee-44ec-8b8c-2e57adfd1916}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <color>
   <r>255</r>
   <g>193</g>
   <b>3</b>
  </color>
  <range>0.00</range>
 </bsbObject>
 <bsbObject type="BSBTableDisplay" version="2">
  <objectName>plot1</objectName>
  <x>8</x>
  <y>74</y>
  <width>360</width>
  <height>220</height>
  <uuid>{de99af7a-d3d5-4e8f-a18a-86c66ec2481b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <color>
   <r>255</r>
   <g>153</g>
   <b>0</b>
  </color>
  <range>0.00</range>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>7</x>
  <y>11</y>
  <width>271</width>
  <height>56</height>
  <uuid>{cb8cacc9-7f4f-4465-af4f-b8c31fca1acb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Table Plot Widget</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>36</fontsize>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>11</x>
  <y>354</y>
  <width>360</width>
  <height>114</height>
  <uuid>{ce9539a1-5f6f-4a93-8e67-2e45899088cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This widget allows to visualize the contents of a table in real-time. To set the table number to plot send the table number to its channel. To update the plot just send -1 and the last set table will be updated. 

The widget also accepts string values. The table can be set via "@set tablenumber" and it can be updated via "@update"
</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
  <precision>3</precision>
  <color>
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </color>
  <bgcolor mode="nobackground">
   <r>68</r>
   <g>68</g>
   <b>68</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>11</x>
  <y>320</y>
  <width>121</width>
  <height>38</height>
  <uuid>{c9cdfd2b-7f5d-48bf-91c5-c6172252fdc4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Description</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

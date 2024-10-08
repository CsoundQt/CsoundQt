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
This is the example file for the Table Plot Widget

This widget allows to visualize the contents of a table in 
real-time. To set the table number to plot send the table 
number to its channel. To update the plot just send -1 and
the last set table will be updated. 

The widget also accepts string values. The table can be set 
via "@set tablenumber" and it can be updated via "@update"

*/

; Create two empty tables
gi1 ftgen 0, 0, 1024, 2, 0
gi2 ftgen 0, 0,  512, 2, 0  

chn_k "plot1", "w" 
chn_k "plot2", "w"

instr 1
	ktab1 init gi1
	ktab2 init gi2
	
	; switch tables every five seconds
	if metro(1/2) == 1 then
		ktab1, ktab2 = ktab2, ktab1
	endif
	
	; Modify the tables
	ilen = ftlen(gi1)
	
	; We fill a table with an aplitude varying sine wave at k-rate
	kamp = linlin(oscil:k(1, 0.1), 1, 8, -1, 1)
	kval oscil kamp, 15
	kidx = timeinstk() % ilen
	tablew kval, kidx, gi1
	
	; The second table is filled with realtime audio input
	aidx phasor sr/ftlen(gi2)
	tablew inch(1)*2, aidx, gi2, 1 
	
	; Update rate of the plots. NB: the widget update rate in
	; CsoundQt is limited to 30 fps, so any update faster than
	; than will have no effect other than time aliasing
	ktrig metro 24
	
	chnset ktrig == 1 ? -1 : ktab1, "plot1"
	chnset ktrig == 1 ? -1 : ktab2, "plot2"
	
endin

schedule 1, 0.1, 3600, gi1, gi2

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
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
 <bsbObject version="2" type="BSBTableDisplay">
  <objectName>plot2</objectName>
  <x>370</x>
  <y>74</y>
  <width>360</width>
  <height>220</height>
  <uuid>{0c6062cd-26ee-44ec-8b8c-2e57adfd1916}</uuid>
  <visible>true</visible>
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
 <bsbObject version="2" type="BSBTableDisplay">
  <objectName>plot1</objectName>
  <x>8</x>
  <y>74</y>
  <width>360</width>
  <height>220</height>
  <uuid>{de99af7a-d3d5-4e8f-a18a-86c66ec2481b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <color>
   <r>255</r>
   <g>153</g>
   <b>0</b>
  </color>
  <range>0.00</range>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>11</y>
  <width>271</width>
  <height>56</height>
  <uuid>{cb8cacc9-7f4f-4465-af4f-b8c31fca1acb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>360</y>
  <width>460</width>
  <height>127</height>
  <uuid>{ce9539a1-5f6f-4a93-8e67-2e45899088cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>This widget allows to visualize the contents of a table in real-time. To set the table number to plot send the table number to its channel. To update the plot just send -1 and the last set table will be updated. 

The widget also accepts string values. The table can be set with 'outvalue "@set &lt;tablenumber>"' and it can be updated via 'outvalue "@update"'
</label>
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
   <r>68</r>
   <g>68</g>
   <b>68</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>11</x>
  <y>320</y>
  <width>121</width>
  <height>38</height>
  <uuid>{c9cdfd2b-7f5d-48bf-91c5-c6172252fdc4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Description</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
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

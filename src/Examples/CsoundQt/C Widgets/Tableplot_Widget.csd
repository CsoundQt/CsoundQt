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
gi1 = ftgen(0, 0, 1024, 2, 0)
gi2 = ftgen(0, 0, 512, 2, 0)


chn_k "plot1", "w"
chn_k "plot2", "w"

instr 10
  ktab1 = init(gi1)
  ktab2 = init(gi2)

  ; switch tables every five seconds
  if metro(1/2) == 1 then
    ktab1, ktab2 = ktab2, ktab1
  endif

  ; Modify the tables
  ilen = ftlen(gi1)

  ; We fill a table with an aplitude varying sine wave at k-rate
  kamp = linlin(oscil:k(1, 0.1), 1, 8, -1, 1)
  kval = oscil(kamp, 15)
  kidx = timeinstk() % ilen
  tablew kval, kidx, gi1

  ; The second table is filled with realtime audio input
  aidx = phasor(sr/ftlen(gi2))
  tablew inch(1)*2, aidx, gi2, 1

  ; Update rate of the plots. NB: the widget update rate in
  ; CsoundQt is limited to 30 fps, so any update faster than
  ; than will have no effect
  ktrig = metro(30)

  chnset ktrig == 1 ? -1 : ktab1, "plot1"
  chnset ktrig == 1 ? -1 : ktab2, "plot2"

endin

instr 20
  if eventcycles() == 0 then
    chnset gi1, "plot3"
    outvalue "plot3/setmaxrange", 10
    outvalue "plot3/setminrange", -10
    outvalue "plot3/samplerate", kr
    chnset gi2, "plot4"
    outvalue "plot4/setmaxrange", 2
    outvalue "plot4/setminrange", -2
    outvalue "plot4/samplerate", sr  
  endif
  
  if metro(30) == 1 then
    outvalue "plot3/update", k(1)
    outvalue "plot4/update", k(1)
  endif
  
endin

schedule 10, 0, 100
schedule 20, 0, 100

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>




































































<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>730</width>
 <height>662</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">#f0f0f0</bgcolor>
 <bsbObject type="BSBTableDisplay" version="2">
  <objectName>plot2</objectName>
  <x>370</x>
  <y>139</y>
  <width>360</width>
  <height>220</height>
  <uuid>{0c6062cd-26ee-44ec-8b8c-2e57adfd1916}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <foreground>#ffc103</foreground>
  <background>#181818</background>
  <gridcolor>#48a0a0a0</gridcolor>
  <samplerate>1</samplerate>
  <range>0.00</range>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>7</x>
  <y>11</y>
  <width>271</width>
  <height>56</height>
  <uuid>{cb8cacc9-7f4f-4465-af4f-b8c31fca1acb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Table Plot Widget</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>36</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#434343</color>
  <bgcolor mode="nobackground">#ffffff</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>7</x>
  <y>71</y>
  <width>488</width>
  <height>61</height>
  <uuid>{ce9539a1-5f6f-4a93-8e67-2e45899088cb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>This widget allows to visualize the contents of a table in real-time. To set the table number to plot send the table number to its channel. To update the plot just send -1 and the last set table will be updated. 

</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#343434</color>
  <bgcolor mode="nobackground">#444444</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBTableDisplay" version="2">
  <objectName>plot3</objectName>
  <x>10</x>
  <y>546</y>
  <width>360</width>
  <height>220</height>
  <uuid>{2d733211-e9d5-4e84-9995-0d0cad55b228}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <foreground>#ffc103</foreground>
  <background>#181818</background>
  <gridcolor>#48a0a0a0</gridcolor>
  <samplerate>750</samplerate>
  <range>0.00</range>
 </bsbObject>
 <bsbObject type="BSBTableDisplay" version="2">
  <objectName>plot4</objectName>
  <x>378</x>
  <y>545</y>
  <width>360</width>
  <height>220</height>
  <uuid>{64ef48e6-e480-4140-99be-f360365148d6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <foreground>#00aaff</foreground>
  <background>#1d002b</background>
  <gridcolor>#ff464600</gridcolor>
  <samplerate>48000</samplerate>
  <range>0.00</range>
 </bsbObject>
 <bsbObject type="BSBTableDisplay" version="2">
  <objectName>plot1</objectName>
  <x>8</x>
  <y>139</y>
  <width>360</width>
  <height>220</height>
  <uuid>{de99af7a-d3d5-4e8f-a18a-86c66ec2481b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <foreground>#ff9900</foreground>
  <background>#181818</background>
  <gridcolor>#48a0a0a0</gridcolor>
  <samplerate>1</samplerate>
  <range>0.00</range>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>7</x>
  <y>370</y>
  <width>492</width>
  <height>160</height>
  <uuid>{7373ad53-744a-4f3a-81bc-6cc116e4c11d}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Table plots can be configured in many ways (background, foreground and grid colors, samplerate, range). The samplerate can be set as 0, then, if the table was read from a soundfile (gen1), the sr of the file will be used for the x axes. 

Tableplots also define useful methods:

1. update: outvalue("&lt;channel>/update, k(1)) to update the plot
2. setmaxrange, setminrange:  outvalue("&lt;channel>/setmaxrange", 2.) to set the upper y range to 2
3. samplerate: outvalue("&lt;channel>/samplerate, ...) to set the samplerate of the plot. </label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
  <color>#343434</color>
  <bgcolor mode="nobackground">#444444</bgcolor>
  <bordercolor>#000000</bordercolor>
  <bordermode>false</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

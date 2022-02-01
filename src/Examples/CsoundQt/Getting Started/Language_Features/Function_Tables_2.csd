/*Getting started.. Function-Tables

It is also possible to create and fill an f-table from within the orchestra. In this case, the 'ftgen' opcode is used.

Filling an f-table directly from within the orchestra looks like this:
giMyNumbers ftgen 12, 0, -7, -2, 1, 2, 3, 4, 5, 6, 7
Here the f-table No. 12 has the size 7 and is filled with this list of numbers: [1, 2, 3, 4, 5, 6, 7]


gir ftgen ifn, itime, isize, igen, iarga [, iargb ] [...] 
gir     - the number of the table created. Global variables can be read independent from the current instrument, useful here
ifn     - is the number of the F-Table, and will be your later keycode to read it out
	    If ifn is zero, the number is assigned automatically and the value placed in gir.
itime   - says when this becomes calculated
isize   - sets the size of the table
igen    - the number of the GEN ROUTINE
iaga..b - arguments used by the GEN ROUTINES to calculate the numbers

*/
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

giSine ftgen 1, 0, 4096, 10, 1		;a sinewave will be generated and stored into Table No. 1
giAdd7Sine ftgen 2, 0, 4096, 10, 1, 1, 1, 1, 1, 1, 1, 1	;a sinewave and 6 harmonics
giNoise ftgen 3, 0, 4096, 21, 1		; White Noise
giMyNumbers ftgen	 0, 0, -3, -2, 1, 2, 3 ; [1, 2, 3] - becomes automatically table number 4


instr 1
iLength = ftlen(giMyNumbers)
iMyNumber tab_i (p2%(iLength)), giMyNumbers
aEnv madsr 0.1, 0.1, 1, 0.3
aWavetablePlayer oscili p4, cpspch(p5), (iMyNumber)
outs aWavetablePlayer*aEnv, aWavetablePlayer*aEnv
endin

</CsInstruments>

<CsScore>
;ins strt dur  amp  freq  		table-number
t 0 220

i 1 1 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0 
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0
i 1 + 0.5 0.3 10.0

e
</CsScore>

</CsoundSynthesizer>
; written by Alex Hofmann (Mar. 2010) - Incontri HMT-Hannover 

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1013</x>
 <y>279</y>
 <width>563</width>
 <height>397</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBGraph">
  <objectName/>
  <x>7</x>
  <y>61</y>
  <width>395</width>
  <height>120</height>
  <uuid>{f9ccbabd-c362-420e-b6da-27cecbe668f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>auto</modex>
  <modey>auto</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>6</x>
  <y>223</y>
  <width>400</width>
  <height>158</height>
  <uuid>{ed41ad63-73be-4960-b6fe-183b565ce956}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>5</y>
  <width>396</width>
  <height>58</height>
  <uuid>{912fe89d-708b-44c9-b6f5-537c335d210f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>In this graph, one can see the result of the  generated F-Table values.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>193</y>
  <width>398</width>
  <height>31</height>
  <uuid>{28be8cb0-7e8b-49fd-b163-95402e5aef94}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>The output-waveform..</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="320" y="218" width="596" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

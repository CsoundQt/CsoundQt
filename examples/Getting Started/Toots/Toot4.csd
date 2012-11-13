<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; Adapted from Richard Boulanger's toots
sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 4
	iamp = ampdbfs(p4)         ; convert dB FS to linear amp
	iscale = iamp * .333       ; scale the amp at initialization
	inote = cpspch(p5)         ; convert octave.pitch to cps
	
	k1 linen iscale, p6, p3, p7  ; p4=amp
	
	a3 oscil k1, inote*.996, 1   ; p5=freq
	a2 oscil k1, inote*1.004, 1  ; p6=attack time
	a1 oscil k1, inote, 1        ; p7=release time
	
	a1 = a1+a2+a3
	outs a1, a1

endin
</CsInstruments>
<CsScore>
; number  time   size  GEN  p1
f   1         0       4096	10	 1	; use GEN10 to compute a sine wave

;ins strt dur  amp   freq      attack    release
i4   0    1    -20   8.04      0.1       0.7

i4   1    1    -15   8.02      0.07      0.6

i4   2    1    -20   8.00      0.05      0.5

i4   3    1    -30   8.02      0.05      0.4

i4   4    1    -15   8.04      0.1       0.5

i4   5    1    -10   8.04      0.05      0.5

i4   6    2    -10   8.04      0.03      1.
e ; indicates the end of the score
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>514</x>
 <y>322</y>
 <width>413</width>
 <height>431</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>7</r>
  <g>95</g>
  <b>162</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>12</y>
  <width>100</width>
  <height>29</height>
  <uuid>{a6fa6d02-14cc-4f0c-b2c3-5e3da73375d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Toot 4</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>43</y>
  <width>365</width>
  <height>114</height>
  <uuid>{80a23d3c-a09d-4c5a-a02f-838a51099125}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Next we'll animate the basic sound by mixing it with two slightly de-tuned copies of itself. We'll employ Csound's cpspch value converter which will allow us to specify the pitches by octave and pitch-class rather than by frequency, and we'll use the ampdbfs converter to specify loudness in dB FS rather than linearly.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>50</x>
  <y>276</y>
  <width>292</width>
  <height>96</height>
  <uuid>{2075a23a-bf65-471c-a1c4-f675ed4b806c}</uuid>
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
  <x>14</x>
  <y>162</y>
  <width>365</width>
  <height>102</height>
  <uuid>{94118d9a-d6aa-485c-81ac-b5148a74545b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Since we are adding the outputs of three oscillators, each with the same amplitude envelope, we'll scale the amplitude before we mix them. Both iscale and inote are arbitrary names to make the design a bit easier to read. Each is an i-rate variable, evaluated when the instrument is initialized.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

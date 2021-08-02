<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; Adapted from Richard Boulanger's toots
sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

instr 5
	irel = 0.01                  ; set vibrato release time
	idel1 = p3 * p10             ; calculate initial delay (% of dur)
	isus = p3 - (idel1 + irel)   ; calculate remaining duration
	
	iamp = ampdbfs(p4)
	iscale = iamp * .333                                   ; p4=amp
	inote = cpspch(p5)                                     ; p5=freq
	
	k3        linseg    0, idel1, p9, isus, p9, irel, 0    ; p6=attack time
	k2        oscil     k3, p8, 1                          ; p7=release time
	k1        linen     iscale, p6, p3, p7                 ; p8=vib rate
	
	a3        oscil     k1, inote*.995+k2, 1               ; p9=vib depth
	a2        oscil     k1, inote*1.005+k2, 1              ; p10=vib delay (0-1)
	a1        oscil     k1, inote+k2, 1
	
	outs a1+a2+a3, a1+a2+a3

endin
</CsInstruments>
<CsScore>
; number  time   size  GEN  p1
f   1         0       4096	10	 1	; use GEN10 to compute a sine wave

;ins strt dur  amp  freq      atk  rel  vibrt     vbdpt     vbdel
i5   0    3    -10   10.00     0.1  0.7  7         6         .4

i5   4    3    -10   10.02     1    0.2  6         6         .4

i5   8    4    -10   10.04     2    1    5         6         .4
e ; indicates the end of the score
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>502</x>
 <y>269</y>
 <width>413</width>
 <height>440</height>
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
  <uuid>{48c50f90-782c-4085-bddf-6438c45c0604}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Toot 5</label>
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
  <uuid>{3f95e491-29da-4b7d-825e-67cf89ef4eff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>To add some delayed vibrato to our chorusing instrument we use another oscillator for the vibrato and a line segment generator, linseg, as a means of controlling the delay. linseg is a k-rate or a-rate signal generator which traces a series of straight line segments between any number of specified points.</label>
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
  <uuid>{c62f9a7e-a132-4302-94ce-7f92a94c6052}</uuid>
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
  <uuid>{7825fe0b-8a41-49ec-a392-c9ec0123c9ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Since we intend to use this to slowly scale the amount of signal coming from our vibrato oscillator, we'll choose the k-rate version. The i-rate variables: ia, ib, ic, etc., are the values for the points. The i-rate variables: idur1, idur2, idur3, etc., set the duration, in seconds, between segments.</label>
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

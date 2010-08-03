<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; by Sean Costello, August 23-26, 1999
; GUI and some additions by Josep M Comajuncosas, July 2001
; QuteCsound version by Andres Cabrera 2010

sr = 44100
ksmps = 128
nchnls = 1
0dbfs = 1

gasig2 init 0	; global variable to send pulse waves to ensemble section
ga2 init 0	; global variable to send output of ensemble to reverb


instr 1	; Used to generate simple sawtooth-like waveforms

ifreq  cpsmidi
print ifreq
iharms=(sr*.4) / ifreq	; Limits number of harmonics in bandlimited
			; pulse waveform

asig	gbuzz	1, ifreq, iharms, 1, .9, 2
kenv 	madsr	1, 0,1,1.5

aout = kenv * asig * .45
; The output of instr 19 is sent to the "ensemble" chorusing
; section. None of the dry signal will be heard in the output.
gasig2 = gasig2 + aout

endin


instr 22	; Ensemble section. Takes static sawtooth waves,
		; and produces an animated flanged/chorused/vibratoed
		; output. The phase shifter follows the output
		; of the ensemble.

kVcf1 invalue "Vfc1"
kVcf2 invalue "Vfc2"
kLfoWave invalue "LfoWave"
kLfoDepth invalue "LfoDepth"
kLfoFreq invalue "LfoFreq"
kPhFreq invalue "PhFreq"
kPhFdbk invalue "PhFdbk"
kPhQ invalue "PhQ"
kPhStages invalue "PhStages"
kPhSep invalue "PhSep"

ivib = p4 * .00025	; Determines amount of pitch change/vibrato/
		; chorusing. A value of 1 gives moderately thick 
		; chorusing, without excessive vibrato. Vary this 
		; according to taste.

;LFOs
ktimea	oscil	4, 0.33, 1
ktimeb	oscil	4, 0.33, 1, .333
ktimec	oscil	4, 0.33, 1, .667

ktimed	oscil	1, 5.5, 1
ktimee	oscil	1, 5.5, 1, .333
ktimef	oscil	1, 5.5, 1, .667


ktime1 = (ktimea + ktimed) * ivib
ktime2 = (ktimeb + ktimee) * ivib
ktime3 = (ktimec + ktimef) * ivib

;Chorus
adummy	delayr	.030
asig1	deltap3	ktime1 + .012
asig2	deltap3	ktime2 + .012
asig3 	deltap3	ktime3 + .012
	delayw	gasig2

aVcfIn = (asig1 + asig2 + asig3) * .33

;Vcf
klow limit 1-kVcf2,0,1
kband mirror kVcf2,0,1
khigh limit kVcf2-1,0,1

alow, ahigh, aband	svfilter	aVcfIn, kVcf1, 10
aPhaserIn mac klow,alow,kband,aband,khigh,ahigh

;Lfo
lfo:
ilfowave = 10+i(kLfoWave)
klfofrq	oscil	kLfoDepth, kLfoFreq, ilfowave,-1
rigoto end
;rireturn
igoto skip0
if ilfowave == kLfoWave kgoto skip0
reinit lfo

skip0:
kmod	= kPhFreq*(1+klfofrq)
kmod limit kmod,20,sr/4

;Phaser
phaser:
istages = i(kPhStages)

aphs	phaser2 aPhaserIn, kmod, kPhQ, istages, 2, kPhSep, kPhFdbk
	aout2=(aPhaserIn + aphs) * .5

rireturn
igoto skip1
if istages == kPhStages kgoto skip1
reinit phaser
skip1:
	
ga2 = ga2 + .37 * aout2

kRevWet invalue "RevWet"
out	aout2*(1-kRevWet)

gasig2 = 0
end:
endin


instr 99	; Simple implementation of Feedback Delay Network (FDN)
		; reverb, as described by John Stautner and Miller 
		; Puckette, "Designing Multi-Channel Reverberators," 

kRevSize invalue "RevSize"
kRevCutoff invalue "RevCutoff"
kRevWet invalue "RevWet"

atap	multitap ga2, 0.00043, 0.0215, 0.00268, 0.0298, 0.00485, 0.0572, 0.00595, 0.0708, 0.00741, 0.0797, 0.0142, 0.134, 0.0217, 0.181, 0.0272, 0.192, 0.0379, 0.346, 0.0841, 0.504

aRvb_Free nreverb	tanh(.5*ga2), kRevSize, kRevCutoff, 0, 8, 71, 4, 72

out 6000*((tanh(.5*aRvb_Free) + atap)*kRevWet)

ga2 = 0

endin

</CsInstruments>
<CsScore>

f1 0 32768 10 1		; Sine wave for delay line modulation
f2 0 8192 9 1 1 .25		; Cosine wave for gbuzz

;several shapes for the lfo
f10 0 32768 10 1;sine
f11 0 32768 7 0 15360 1 2048 -1 15360 0;saw up
f12 0 32768 7 0 15360 -1 2048 1 15360 0;saw down
f13 0 32768 7 0 8192 1 8192 0 8192 -1 8192 0;triangle

; freeverb time constants, as direct (negative) sample, with arbitrary gains
f71 0 16   -2  -1116 -1188 -1277 -1356 -1422 -1491 -1557 -1617  0.8  0.79  0.78  0.77  0.76  0.75  0.74  0.73  
f72 0 16   -2  -556 -441 -341 -225 0.7  0.72  0.74  0.76

; Global instrument for ensemble/phaser effect. p4 sets amount
; of pitch change in chorusing.
f0 3600
i22 0 3600 .9

; Global instrument for reverb.
i99 0 3600 .93 1.2 1 7000 1

e
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>802</x>
 <y>195</y>
 <width>417</width>
 <height>351</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>5</x>
  <y>123</y>
  <width>197</width>
  <height>183</height>
  <uuid>{accac81c-0549-4f39-89bd-f30ebc1cabe5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Phaser</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>15</y>
  <width>225</width>
  <height>102</height>
  <uuid>{87b86b69-2ccf-49f8-a740-12da6b43bbc1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>LFO</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>238</x>
  <y>15</y>
  <width>159</width>
  <height>102</height>
  <uuid>{5fc6ec37-76f4-4ed4-bd1b-61859b587c8f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Hard Freeverb</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>LfoWave</objectName>
  <x>14</x>
  <y>70</y>
  <width>112</width>
  <height>24</height>
  <uuid>{3dd45672-e874-4f17-af99-0d7f46ee1043}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Sine</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Saw Down</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Saw Up</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Triangle</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>180</x>
  <y>83</y>
  <width>41</width>
  <height>24</height>
  <uuid>{726f5238-9d67-4c2a-a3e1-56b428488266}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Depth</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>135</x>
  <y>83</y>
  <width>41</width>
  <height>24</height>
  <uuid>{c91e5dc1-52a8-4f32-989e-58a3fb112d44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Freq</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>LfoDepth</objectName>
  <x>178</x>
  <y>37</y>
  <width>40</width>
  <height>43</height>
  <uuid>{55d4da74-c0fa-4bea-abe5-ae64d7232af5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>LfoFreq</objectName>
  <x>135</x>
  <y>37</y>
  <width>40</width>
  <height>43</height>
  <uuid>{2c434385-4be7-4f8f-bef3-0e0b3892bfad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00100000</minimum>
  <maximum>20.00000000</maximum>
  <value>9.00055000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>342</x>
  <y>83</y>
  <width>41</width>
  <height>24</height>
  <uuid>{fc151be8-3cbc-433e-b501-19855883065e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Color</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>297</x>
  <y>83</y>
  <width>41</width>
  <height>24</height>
  <uuid>{9100d64e-fe82-4c38-b24e-881d33134bb2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Size</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>257</x>
  <y>83</y>
  <width>41</width>
  <height>24</height>
  <uuid>{52b7f52b-ea05-4ba3-9913-037b8357bc12}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>d/w</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>RevCutoff</objectName>
  <x>340</x>
  <y>37</y>
  <width>40</width>
  <height>43</height>
  <uuid>{c4e6f6b1-59cf-4eb6-8d93-4aa0c46f6ca3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.53000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>RevSize</objectName>
  <x>295</x>
  <y>37</y>
  <width>40</width>
  <height>43</height>
  <uuid>{874550d5-aa2c-4eaa-b0fd-0aec3075a0c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.05000000</minimum>
  <maximum>5.00000000</maximum>
  <value>1.98050000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>RevWet</objectName>
  <x>252</x>
  <y>37</y>
  <width>40</width>
  <height>43</height>
  <uuid>{d5658549-3527-409e-a69c-eb98c38a8092}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.48000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>60</x>
  <y>263</y>
  <width>41</width>
  <height>24</height>
  <uuid>{35c15a8b-a512-4d9e-b7c5-57e566276fc7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Order</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>128</x>
  <y>269</y>
  <width>41</width>
  <height>24</height>
  <uuid>{ccc15056-4707-4134-8c7f-0c92e81b4fbf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Sep</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>126</x>
  <y>202</y>
  <width>41</width>
  <height>24</height>
  <uuid>{153be116-2470-4657-bc01-f125c50262ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Q</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>83</x>
  <y>202</y>
  <width>41</width>
  <height>24</height>
  <uuid>{4b078edb-bad8-400f-8f3f-b7773ae24415}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Fdbk</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <x>35</x>
  <y>202</y>
  <width>41</width>
  <height>24</height>
  <uuid>{059d7a58-e93e-4f19-bbc1-39c3c883b98f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Freq</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>PhStages</objectName>
  <x>62</x>
  <y>241</y>
  <width>37</width>
  <height>24</height>
  <uuid>{95465008-7833-49b2-a298-3991593482bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>18</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>8.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>16.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PhSep</objectName>
  <x>129</x>
  <y>227</y>
  <width>40</width>
  <height>43</height>
  <uuid>{d2011f69-e261-4299-a5a5-aa2cd78f210f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.25000000</minimum>
  <maximum>4.00000000</maximum>
  <value>1.97500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PhQ</objectName>
  <x>126</x>
  <y>156</y>
  <width>40</width>
  <height>43</height>
  <uuid>{83b17987-41d6-4f70-9c25-6943e9f35d59}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.25000000</minimum>
  <maximum>4.00000000</maximum>
  <value>2.42500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PhFdbk</objectName>
  <x>81</x>
  <y>156</y>
  <width>40</width>
  <height>43</height>
  <uuid>{c67fe76f-be50-46fa-8e13-21164d40b28f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-0.99000000</minimum>
  <maximum>0.95000000</maximum>
  <value>0.48440000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>PhFreq</objectName>
  <x>38</x>
  <y>156</y>
  <width>40</width>
  <height>43</height>
  <uuid>{7781cd16-eaab-49e7-bf6f-95f7f9981766}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>200.00000000</minimum>
  <maximum>8000.00000000</maximum>
  <value>5348.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>209</x>
  <y>123</y>
  <width>190</width>
  <height>183</height>
  <uuid>{49e3af03-7eca-401a-9592-aaa23125258a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Phaser</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>Vcf1</objectName>
  <x>232</x>
  <y>147</y>
  <width>145</width>
  <height>150</height>
  <uuid>{54d46c69-3b11-4f33-934f-e487e18fb8d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>Vcf2</objectName2>
  <xMin>100.00000000</xMin>
  <xMax>10000.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>2.00000000</yMax>
  <xValue>4060.00000000</xValue>
  <yValue>1.21333333</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>85</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>47</y>
  <width>41</width>
  <height>24</height>
  <uuid>{c97db846-5e62-45a4-b830-22a562d3695c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Shape</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
<MacGUI>
ioView background {0, 0, 0}
ioText {5, 123} {197, 183} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Phaser
ioText {6, 15} {225, 102} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder LFO
ioText {238, 15} {159, 102} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Hard Freeverb
ioMenu {14, 70} {112, 24} 1 303 "Sine,Saw Down,Saw Up,Triangle" LfoWave
ioText {180, 83} {41, 24} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Depth
ioText {135, 83} {41, 24} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Freq
ioKnob {178, 37} {40, 43} 1.000000 0.000000 0.010000 0.500000 LfoDepth
ioKnob {135, 37} {40, 43} 20.000000 0.001000 0.010000 9.000550 LfoFreq
ioText {342, 83} {41, 24} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Color
ioText {297, 83} {41, 24} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Size
ioText {257, 83} {41, 24} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder d/w
ioKnob {340, 37} {40, 43} 1.000000 0.000000 0.010000 0.530000 RevCutoff
ioKnob {295, 37} {40, 43} 5.000000 0.050000 0.010000 1.980500 RevSize
ioKnob {252, 37} {40, 43} 1.000000 0.000000 0.010000 0.480000 RevWet
ioText {60, 263} {41, 24} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Order
ioText {128, 269} {41, 24} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Sep
ioText {126, 202} {41, 24} label 0.000000 0.00100 "" center "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Q
ioText {83, 202} {41, 24} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Fdbk
ioText {35, 202} {41, 24} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Freq
ioText {62, 241} {37, 24} scroll 8.000000 1.000000 "PhStages" left "Arial" 18 {0, 0, 0} {65280, 65280, 65280} background noborder 
ioKnob {129, 227} {40, 43} 4.000000 0.250000 0.010000 1.975000 PhSep
ioKnob {126, 156} {40, 43} 4.000000 0.250000 0.010000 2.425000 PhQ
ioKnob {81, 156} {40, 43} 0.950000 -0.990000 0.010000 0.484400 PhFdbk
ioKnob {38, 156} {40, 43} 8000.000000 200.000000 0.010000 5348.000000 PhFreq
ioText {209, 123} {190, 183} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Phaser
ioMeter {232, 147} {145, 150} {65280, 21760, 0} "Vcf1" 4060.000000 "Vcf2" 1.213333 crosshair 1 0 mouse
ioText {14, 47} {41, 24} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {63232, 62720, 61952} nobackground noborder Shape
</MacGUI>

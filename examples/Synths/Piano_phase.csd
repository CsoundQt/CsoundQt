; Written by Aaron Krister Johnson, 2009 based on code by Ian McCurdy, 2006

; Ported to CsoundQt by René, January 2011
; Tested on Ubuntu 10.04 with csound-double cvs January 2011 (previous version have a bug in madsr opcode) and CsoundQt svn rev 800

;my flags on Ubuntu: -dm0 -odac:plughw -b1024 -B2048 -+rtaudio=alsa -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr		= 44100
ksmps	= 128
nchnls	= 2

				massign	0, 2		;all midi to instrument 2

instr	1		;gui
	gkndxatt		invalue	"Index1_Attack"		; init	.002
	gkndxdec		invalue	"Index1_Decay"			; init	5
	gkndxslev		invalue	"Index1_Sustain"		; init	0
	gkndxrel		invalue	"Index1_Release"		; init	.1
	gkndxatt2		invalue	"Index2_Attack"		; init	.002
	gkndxdec2		invalue	"Index2_Decay"			; init	5
	gkndxslev2	invalue	"Index2_Sustain"		; init	0
	gkndxrel2		invalue	"Index2_Release"		; init	.1
	gkampatt		invalue	"Amp_Attack"			; init	.002
	gkampdec		invalue	"Amp_Decay"			; init	6
	gkampslev		invalue	"Amp_Sustain"			; init	0
	gkamprel		invalue	"Amp_Release"			; init	.1
	gkcutoff		invalue	"Filter_Cutoff"		; init	6000
	gkreson		invalue	"Filter_Reso"			; init	1
	gkpan		invalue	"Pan"				; init	.5
	gkchorus		invalue	"Chorus"				; init	.333
	gkvol		invalue	"Volume"				; init	1
	gkmodratio	invalue	"Mod_ratio1"			; init	1
	gkmodratio2	invalue	"Mod_ratio2"			; init	2
	gkindex		invalue	"Mod_index1"			; init	3
	gkindex2		invalue	"Mod_index2"			; init	2
endin

instr	2	;FM (PM)
	icps			cpsmidi
	iamp			ampmidi	1

	i1div2pi		=		0.1592
	ipanR		=		i(gkpan)
	ipanL		=		1-ipanR

	kvol			=		20000*gkvol
	kpeakdev		=		iamp * gkindex * i1div2pi
	kpeakdev2		=		iamp * gkindex2 * i1div2pi

	;ENVELOPES
	kndxenv 		madsr 	i(gkndxatt), i(gkndxdec), i(gkndxslev) + .0000001, i(gkndxrel)
	kndxenv2 		madsr 	i(gkndxatt2), i(gkndxdec2), i(gkndxslev2) + .0000001, i(gkndxrel2)
	kampenv 		madsr 	i(gkampatt), i(gkampdec), i(gkampslev) + .0000001, i(gkamprel)

	;STEREO "CHORUS" ENRICHMENT USING JITTER
	kjitL		jitter	i(gkchorus)*3, 2, 5.3
	kjitR		jitter	i(gkchorus)*3, 1.5, 5

	;MODULATORS
	aModulator	oscil	kpeakdev * kndxenv, icps * gkmodratio, 1
	aModulator2	oscil	kpeakdev2 * kndxenv2 , icps * gkmodratio2, 1
	aCarrierL		phasor	icps + kjitL
	aCarrierR		phasor	icps + kjitR
	aCarrierL		table	aCarrierL + aModulator + aModulator2, 1, 1, 0, 1
	aCarrierR		table	aCarrierR + aModulator + aModulator2, 1, 1, 0, 1
	aSigL		=		aCarrierL * iamp * kampenv
	aSigR		=		aCarrierR * iamp * kampenv

	aFilterL		bqrez	aSigL, gkcutoff, gkreson
	aFilterR		bqrez	aSigR, gkcutoff, gkreson
	aFilterL		balance	aFilterL, aSigL
	aFilterR		balance	aFilterR, aSigR
				outs		aFilterL * kvol * ipanL, aFilterR * kvol * ipanR
endin


instr	3		;init
	outvalue	"_SetPresetIndex", 0	;call preset 0
endin
</CsInstruments>
<CsScore>
f 1 0 65537 10 1

i 1 0 3600	;gui
i 3 1 0		;init
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>206</x>
 <y>182</y>
 <width>762</width>
 <height>357</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>115</r>
  <g>57</g>
  <b>0</b>
 </bgcolor>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Index1_Attack</objectName>
  <x>9</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{911b84a9-9d4c-47f8-afb2-73a92dafe2e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>8.00000000</maximum>
  <value>0.00200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Index1_Attack</objectName>
  <x>9</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{a5d4c849-c12d-4e5a-8d5d-045323befbb2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.002</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{6b68cc2d-5a27-4bb2-8294-dd807cadb857}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <x>69</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{cbd82665-31ad-48a3-aba5-f9fd4e8fae6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Index1_Decay</objectName>
  <x>69</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{cbceed7f-0b37-4f62-b2a7-220715ec2f1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Index1_Decay</objectName>
  <x>69</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{7d3bf49e-7f20-407f-b9a4-99e2fc15392c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>15.00000000</maximum>
  <value>5.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>129</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{e6534b2f-b17d-48c8-bde3-8537286a946b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sustain</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Index1_Sustain</objectName>
  <x>129</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{a983e860-c424-411d-bca5-59897e532f6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Index1_Sustain</objectName>
  <x>129</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{0517db1e-e2a9-4e21-b131-5237a32eaa84}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>189</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{3dc3998c-57d2-4d36-81d3-e08c689275ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Index1_Release</objectName>
  <x>189</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{50cefbf4-8496-4375-834d-09fb831197ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Index1_Release</objectName>
  <x>189</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{642a7b5c-0b16-4551-afd2-d3a781a77c3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>15.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>55</x>
  <y>50</y>
  <width>150</width>
  <height>25</height>
  <uuid>{f686f455-5aaa-49fd-a571-cde60bfc3872}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Index 1 Envelope</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <x>162</x>
  <y>2</y>
  <width>460</width>
  <height>38</height>
  <uuid>{7e8a6ff4-5d75-4728-a908-e01319f81f17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Two phase Modulators with envelopes</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>10</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>307</x>
  <y>50</y>
  <width>150</width>
  <height>25</height>
  <uuid>{9f4dcfc6-d937-4c05-9073-d30c9b94b4f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Index 2 Envelope</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <objectName>Index2_Release</objectName>
  <x>441</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{91ea6619-d03f-438c-b70f-a87cfb94dca8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>15.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Index2_Release</objectName>
  <x>441</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{e8d72b75-8bdd-4ab3-84c5-2ad86caa0c99}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>441</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{a586a41a-3899-439e-886d-06e6c8384382}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <objectName>Index2_Sustain</objectName>
  <x>381</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{d5b27309-17be-4c40-94d4-bcb8a7c4ad4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Index2_Sustain</objectName>
  <x>381</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{92cb2604-5353-4eeb-b9d7-e6ae62bb4818}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>381</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{02684d8b-1e21-4151-8942-1473138f3f9f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sustain</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <objectName>Index2_Decay</objectName>
  <x>321</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{d62880df-b7b3-45d1-93eb-eb7b92b27c53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>15.00000000</maximum>
  <value>5.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Index2_Decay</objectName>
  <x>321</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{4b715a02-4450-4a6c-a9a9-cb0b799d29d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>321</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{2c1f61b4-0501-490f-9d4e-683120c04e5c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <x>261</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{cd663376-2b91-47d7-beae-3dc7a197f36a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Index2_Attack</objectName>
  <x>261</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{91205d89-e687-48e0-9f98-eef3d48d3e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.002</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Index2_Attack</objectName>
  <x>261</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{e4bf7cef-6d2c-4a47-8feb-f4a9521925b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>8.00000000</maximum>
  <value>0.00200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>560</x>
  <y>50</y>
  <width>150</width>
  <height>25</height>
  <uuid>{c1cc1d68-f38b-45f4-a172-01a875b1db38}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Amp Envelope</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <objectName>Amp_Release</objectName>
  <x>694</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{2de5d575-ae6b-4222-a405-8cf855ca4540}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>15.00000000</maximum>
  <value>0.10000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amp_Release</objectName>
  <x>694</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{ba833a58-cf55-40c8-ab76-23f2ccd0851d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.100</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>694</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{8561dc11-8894-4ffe-869e-6d377242bdcb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <objectName>Amp_Sustain</objectName>
  <x>634</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{b7e65561-152f-49ba-8648-d736a189ecf1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amp_Sustain</objectName>
  <x>634</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{07bc3bc9-a4f0-4430-bb4f-042b712113e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>634</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{3666178b-6c5f-4166-b887-8f1abb7d6f1e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Sustain</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <objectName>Amp_Decay</objectName>
  <x>574</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{117d83a7-a0c6-4f6e-8dbe-ea57190fdfce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>15.00000000</maximum>
  <value>6.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amp_Decay</objectName>
  <x>574</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{727311df-702e-484b-8bcc-ce01e34a8ecb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>574</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{3f0e5ab2-195f-421e-8384-ab0233a37897}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <x>514</x>
  <y>135</y>
  <width>60</width>
  <height>25</height>
  <uuid>{e8aded63-c7e3-4ed6-86c2-1711e18ec8e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Amp_Attack</objectName>
  <x>514</x>
  <y>156</y>
  <width>60</width>
  <height>25</height>
  <uuid>{6cf763f2-ac03-4ca4-a54c-a12f86818785}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.002</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Amp_Attack</objectName>
  <x>514</x>
  <y>80</y>
  <width>60</width>
  <height>60</height>
  <uuid>{d5774b21-06c7-4596-b1ff-ec2c7cefbd09}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00100000</minimum>
  <maximum>8.00000000</maximum>
  <value>0.00200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>261</x>
  <y>74</y>
  <width>240</width>
  <height>2</height>
  <uuid>{216349dc-8199-4b97-8726-efa51e366b5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>New Label</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>514</x>
  <y>74</y>
  <width>240</width>
  <height>2</height>
  <uuid>{abbe067d-7d44-4497-b795-afbaa2fc4e46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>New Label</label>
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
   <g>170</g>
   <b>0</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>74</y>
  <width>240</width>
  <height>2</height>
  <uuid>{51f609fc-d85d-4fd3-93ac-70fa4f2c1d52}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>New Label</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Filter_Cutoff</objectName>
  <x>381</x>
  <y>187</y>
  <width>60</width>
  <height>60</height>
  <uuid>{7a5e84b3-d6b9-41ed-86e6-430837e87446}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>100.00000000</minimum>
  <maximum>8000.00000000</maximum>
  <value>6000.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Filter_Cutoff</objectName>
  <x>381</x>
  <y>262</y>
  <width>60</width>
  <height>25</height>
  <uuid>{52b4801c-4f5f-4079-a340-5c6f999b031a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6000.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>376</x>
  <y>242</y>
  <width>70</width>
  <height>25</height>
  <uuid>{1586121c-542b-4144-a452-dd4943ac15c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Filter Cutoff</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <x>438</x>
  <y>242</y>
  <width>70</width>
  <height>25</height>
  <uuid>{2c9e9b18-6fe9-4096-bdb8-83fa94effd0e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Filter Reso</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Filter_Reso</objectName>
  <x>441</x>
  <y>262</y>
  <width>60</width>
  <height>25</height>
  <uuid>{3dcc8136-2128-46c2-a421-4f60a71e0a27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Filter_Reso</objectName>
  <x>441</x>
  <y>187</y>
  <width>60</width>
  <height>60</height>
  <uuid>{2ae12c59-ee34-4824-8e24-d2d559fe7210}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>1.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>513</x>
  <y>242</y>
  <width>60</width>
  <height>25</height>
  <uuid>{91b0fe27-5919-44f7-af73-02b24853ccac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pan</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Pan</objectName>
  <x>515</x>
  <y>262</y>
  <width>60</width>
  <height>25</height>
  <uuid>{4c135605-eba5-498c-bda1-a8c7d1e114b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.500</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Pan</objectName>
  <x>515</x>
  <y>187</y>
  <width>60</width>
  <height>60</height>
  <uuid>{6fd29d18-2365-4e34-ad60-90651072c64e}</uuid>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>574</x>
  <y>242</y>
  <width>60</width>
  <height>25</height>
  <uuid>{4ebc3645-81a6-4746-b456-a8d6e3c335e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chorus</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Chorus</objectName>
  <x>575</x>
  <y>262</y>
  <width>60</width>
  <height>25</height>
  <uuid>{f6908231-9775-4518-861a-82e1e79aa2c7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.333</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Chorus</objectName>
  <x>575</x>
  <y>187</y>
  <width>60</width>
  <height>60</height>
  <uuid>{3132eb42-d99e-43e9-9957-22c978ba67a9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.33300000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Mod_ratio1</objectName>
  <x>80</x>
  <y>208</y>
  <width>80</width>
  <height>30</height>
  <uuid>{405f1d03-2d6a-4e08-97aa-76e293f20365}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>0.005</minimum>
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>0</x>
  <y>210</y>
  <width>80</width>
  <height>30</height>
  <uuid>{c786fcb1-b6c1-4791-aae2-a61d52ce4522}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mod ratio 1</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <x>0</x>
  <y>246</y>
  <width>80</width>
  <height>30</height>
  <uuid>{ffb2aada-7789-4921-bca3-0d387e02b975}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mod index 1</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Mod_index1</objectName>
  <x>80</x>
  <y>244</y>
  <width>80</width>
  <height>30</height>
  <uuid>{b6126384-8ca2-4857-8e58-f6cf1639ce03}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>0.005</minimum>
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Mod_index2</objectName>
  <x>255</x>
  <y>245</y>
  <width>80</width>
  <height>30</height>
  <uuid>{cbba6841-eb63-48f5-99d3-bd099d39def4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>0.005</minimum>
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>175</x>
  <y>246</y>
  <width>80</width>
  <height>30</height>
  <uuid>{67fdeb64-4bef-432d-aed8-b1ff29b88655}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mod index 2</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
  <x>175</x>
  <y>210</y>
  <width>80</width>
  <height>30</height>
  <uuid>{9e37c330-d2f9-40b9-a334-c78719f4a371}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mod ratio 2</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Mod_ratio2</objectName>
  <x>255</x>
  <y>209</y>
  <width>80</width>
  <height>30</height>
  <uuid>{418766be-98a2-414b-a199-0b726040b63d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>0.005</minimum>
  <maximum>20</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>Volume</objectName>
  <x>693</x>
  <y>187</y>
  <width>60</width>
  <height>60</height>
  <uuid>{2bda857d-4de6-40eb-8db7-698052bd6bfa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Volume</objectName>
  <x>693</x>
  <y>262</y>
  <width>60</width>
  <height>25</height>
  <uuid>{ee9b59e3-ed41-4770-9936-b2659d531349}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>691</x>
  <y>242</y>
  <width>60</width>
  <height>25</height>
  <uuid>{afcf8893-b629-4c34-a82f-aaf46d0a2d72}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Volume</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>170</g>
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
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>6</x>
  <y>295</y>
  <width>748</width>
  <height>50</height>
  <uuid>{076a9f0e-162d-4c3d-91c7-05091e2c7425}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="Init" number="0" >
<value id="{911b84a9-9d4c-47f8-afb2-73a92dafe2e0}" mode="1" >0.00200000</value>
<value id="{a5d4c849-c12d-4e5a-8d5d-045323befbb2}" mode="1" >0.00200000</value>
<value id="{a5d4c849-c12d-4e5a-8d5d-045323befbb2}" mode="4" >0.002</value>
<value id="{cbceed7f-0b37-4f62-b2a7-220715ec2f1f}" mode="1" >5.00000000</value>
<value id="{cbceed7f-0b37-4f62-b2a7-220715ec2f1f}" mode="4" >5.000</value>
<value id="{7d3bf49e-7f20-407f-b9a4-99e2fc15392c}" mode="1" >5.00000000</value>
<value id="{a983e860-c424-411d-bca5-59897e532f6f}" mode="1" >0.00000000</value>
<value id="{a983e860-c424-411d-bca5-59897e532f6f}" mode="4" >0.000</value>
<value id="{0517db1e-e2a9-4e21-b131-5237a32eaa84}" mode="1" >0.00000000</value>
<value id="{50cefbf4-8496-4375-834d-09fb831197ab}" mode="1" >0.10000000</value>
<value id="{50cefbf4-8496-4375-834d-09fb831197ab}" mode="4" >0.100</value>
<value id="{642a7b5c-0b16-4551-afd2-d3a781a77c3b}" mode="1" >0.10000000</value>
<value id="{91ea6619-d03f-438c-b70f-a87cfb94dca8}" mode="1" >0.10000000</value>
<value id="{e8d72b75-8bdd-4ab3-84c5-2ad86caa0c99}" mode="1" >0.10000000</value>
<value id="{e8d72b75-8bdd-4ab3-84c5-2ad86caa0c99}" mode="4" >0.100</value>
<value id="{d5b27309-17be-4c40-94d4-bcb8a7c4ad4f}" mode="1" >0.00000000</value>
<value id="{92cb2604-5353-4eeb-b9d7-e6ae62bb4818}" mode="1" >0.00000000</value>
<value id="{92cb2604-5353-4eeb-b9d7-e6ae62bb4818}" mode="4" >0.000</value>
<value id="{d62880df-b7b3-45d1-93eb-eb7b92b27c53}" mode="1" >5.00000000</value>
<value id="{4b715a02-4450-4a6c-a9a9-cb0b799d29d0}" mode="1" >5.00000000</value>
<value id="{4b715a02-4450-4a6c-a9a9-cb0b799d29d0}" mode="4" >5.000</value>
<value id="{91205d89-e687-48e0-9f98-eef3d48d3e9b}" mode="1" >0.00200000</value>
<value id="{91205d89-e687-48e0-9f98-eef3d48d3e9b}" mode="4" >0.002</value>
<value id="{e4bf7cef-6d2c-4a47-8feb-f4a9521925b8}" mode="1" >0.00200000</value>
<value id="{2de5d575-ae6b-4222-a405-8cf855ca4540}" mode="1" >0.10000000</value>
<value id="{ba833a58-cf55-40c8-ab76-23f2ccd0851d}" mode="1" >0.10000000</value>
<value id="{ba833a58-cf55-40c8-ab76-23f2ccd0851d}" mode="4" >0.100</value>
<value id="{b7e65561-152f-49ba-8648-d736a189ecf1}" mode="1" >0.00000000</value>
<value id="{07bc3bc9-a4f0-4430-bb4f-042b712113e3}" mode="1" >0.00000000</value>
<value id="{07bc3bc9-a4f0-4430-bb4f-042b712113e3}" mode="4" >0.000</value>
<value id="{117d83a7-a0c6-4f6e-8dbe-ea57190fdfce}" mode="1" >6.00000000</value>
<value id="{727311df-702e-484b-8bcc-ce01e34a8ecb}" mode="1" >6.00000000</value>
<value id="{727311df-702e-484b-8bcc-ce01e34a8ecb}" mode="4" >6.000</value>
<value id="{6cf763f2-ac03-4ca4-a54c-a12f86818785}" mode="1" >0.00200000</value>
<value id="{6cf763f2-ac03-4ca4-a54c-a12f86818785}" mode="4" >0.002</value>
<value id="{d5774b21-06c7-4596-b1ff-ec2c7cefbd09}" mode="1" >0.00200000</value>
<value id="{7a5e84b3-d6b9-41ed-86e6-430837e87446}" mode="1" >6000.00000000</value>
<value id="{52b4801c-4f5f-4079-a340-5c6f999b031a}" mode="1" >6000.00000000</value>
<value id="{52b4801c-4f5f-4079-a340-5c6f999b031a}" mode="4" >6000.000</value>
<value id="{3dcc8136-2128-46c2-a421-4f60a71e0a27}" mode="1" >1.00000000</value>
<value id="{3dcc8136-2128-46c2-a421-4f60a71e0a27}" mode="4" >1.000</value>
<value id="{2ae12c59-ee34-4824-8e24-d2d559fe7210}" mode="1" >1.00000000</value>
<value id="{4c135605-eba5-498c-bda1-a8c7d1e114b9}" mode="1" >0.50000000</value>
<value id="{4c135605-eba5-498c-bda1-a8c7d1e114b9}" mode="4" >0.500</value>
<value id="{6fd29d18-2365-4e34-ad60-90651072c64e}" mode="1" >0.50000000</value>
<value id="{f6908231-9775-4518-861a-82e1e79aa2c7}" mode="1" >0.33300000</value>
<value id="{f6908231-9775-4518-861a-82e1e79aa2c7}" mode="4" >0.333</value>
<value id="{3132eb42-d99e-43e9-9957-22c978ba67a9}" mode="1" >0.33300000</value>
<value id="{405f1d03-2d6a-4e08-97aa-76e293f20365}" mode="1" >1.00000000</value>
<value id="{b6126384-8ca2-4857-8e58-f6cf1639ce03}" mode="1" >3.00000000</value>
<value id="{cbba6841-eb63-48f5-99d3-bd099d39def4}" mode="1" >2.00000000</value>
<value id="{418766be-98a2-414b-a199-0b726040b63d}" mode="1" >2.00000000</value>
<value id="{2bda857d-4de6-40eb-8db7-698052bd6bfa}" mode="1" >1.00000000</value>
<value id="{ee9b59e3-ed41-4770-9936-b2659d531349}" mode="1" >1.00000000</value>
<value id="{ee9b59e3-ed41-4770-9936-b2659d531349}" mode="4" >1.000</value>
</preset>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 72 179 400 200
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView background {29555, 14649, 0}
ioKnob {9, 80} {60, 60} 8.000000 0.001000 0.010000 0.002000 Index1_Attack
ioText {9, 156} {60, 25} display 0.002000 0.00100 "Index1_Attack" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 0.002
ioText {9, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Attack
ioText {69, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Decay
ioText {69, 156} {60, 25} display 5.000000 0.00100 "Index1_Decay" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 5.000
ioKnob {69, 80} {60, 60} 15.000000 0.000000 0.010000 5.000000 Index1_Decay
ioText {129, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Sustain
ioText {129, 156} {60, 25} display 0.000000 0.00100 "Index1_Sustain" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 0.000
ioKnob {129, 80} {60, 60} 1.000000 0.000000 0.010000 0.000000 Index1_Sustain
ioText {189, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Release
ioText {189, 156} {60, 25} display 0.100000 0.00100 "Index1_Release" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 0.100
ioKnob {189, 80} {60, 60} 15.000000 0.000000 0.010000 0.100000 Index1_Release
ioText {55, 50} {150, 25} label 0.000000 0.00100 "" center "Liberation Sans" 14 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Index 1 Envelope
ioText {162, 2} {460, 38} label 0.000000 0.00100 "" center "Liberation Sans" 24 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Two phase Modulators with envelopes
ioText {307, 50} {150, 25} label 0.000000 0.00100 "" center "Liberation Sans" 14 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Index 2 Envelope
ioKnob {441, 80} {60, 60} 15.000000 0.000000 0.010000 0.100000 Index2_Release
ioText {441, 156} {60, 25} display 0.100000 0.00100 "Index2_Release" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 0.100
ioText {441, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Release
ioKnob {381, 80} {60, 60} 1.000000 0.000000 0.010000 0.000000 Index2_Sustain
ioText {381, 156} {60, 25} display 0.000000 0.00100 "Index2_Sustain" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 0.000
ioText {381, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Sustain
ioKnob {321, 80} {60, 60} 15.000000 0.000000 0.010000 5.000000 Index2_Decay
ioText {321, 156} {60, 25} display 5.000000 0.00100 "Index2_Decay" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 5.000
ioText {321, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Decay
ioText {261, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Attack
ioText {261, 156} {60, 25} display 0.002000 0.00100 "Index2_Attack" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 0.002
ioKnob {261, 80} {60, 60} 8.000000 0.001000 0.010000 0.002000 Index2_Attack
ioText {560, 50} {150, 25} label 0.000000 0.00100 "" center "Liberation Sans" 14 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Amp Envelope
ioKnob {694, 80} {60, 60} 15.000000 0.000000 0.010000 0.100000 Amp_Release
ioText {694, 156} {60, 25} display 0.100000 0.00100 "Amp_Release" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 0.100
ioText {694, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Release
ioKnob {634, 80} {60, 60} 1.000000 0.000000 0.010000 0.000000 Amp_Sustain
ioText {634, 156} {60, 25} display 0.000000 0.00100 "Amp_Sustain" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 0.000
ioText {634, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Sustain
ioKnob {574, 80} {60, 60} 15.000000 0.000000 0.010000 6.000000 Amp_Decay
ioText {574, 156} {60, 25} display 6.000000 0.00100 "Amp_Decay" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 6.000
ioText {574, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Decay
ioText {514, 135} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Attack
ioText {514, 156} {60, 25} display 0.002000 0.00100 "Amp_Attack" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 0.002
ioKnob {514, 80} {60, 60} 8.000000 0.001000 0.010000 0.002000 Amp_Attack
ioText {261, 74} {240, 2} label 0.000000 0.00100 "" left "Liberation Sans" 10 {0, 0, 0} {65280, 43520, 0} nobackground noborder New Label
ioText {514, 74} {240, 2} label 0.000000 0.00100 "" left "Arial" 10 {0, 0, 0} {65280, 43520, 0} nobackground noborder New Label
ioText {10, 74} {240, 2} label 0.000000 0.00100 "" left "Liberation Sans" 10 {0, 0, 0} {65280, 43520, 0} nobackground noborder New Label
ioKnob {381, 187} {60, 60} 8000.000000 100.000000 0.010000 6000.000000 Filter_Cutoff
ioText {381, 262} {60, 25} display 6000.000000 0.00100 "Filter_Cutoff" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 6000.000
ioText {376, 242} {70, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Filter Cutoff
ioText {438, 242} {70, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Filter Reso
ioText {441, 262} {60, 25} display 1.000000 0.00100 "Filter_Reso" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 1.000
ioKnob {441, 187} {60, 60} 100.000000 1.000000 0.010000 1.000000 Filter_Reso
ioText {513, 242} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Pan
ioText {515, 262} {60, 25} display 0.500000 0.00100 "Pan" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 0.500
ioKnob {515, 187} {60, 60} 1.000000 0.000000 0.010000 0.500000 Pan
ioText {574, 242} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Chorus
ioText {575, 262} {60, 25} display 0.333000 0.00100 "Chorus" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 0.333
ioKnob {575, 187} {60, 60} 1.000000 0.000000 0.010000 0.333000 Chorus
ioText {80, 208} {80, 30} editnum 1.000000 0.001000 "Mod_ratio1" center "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 1.000000
ioText {0, 210} {80, 30} label 0.000000 0.00100 "" right "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Mod ratio 1
ioText {0, 246} {80, 30} label 0.000000 0.00100 "" right "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Mod index 1
ioText {80, 244} {80, 30} editnum 3.000000 0.001000 "Mod_index1" center "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 3.000000
ioText {255, 245} {80, 30} editnum 2.000000 0.001000 "Mod_index2" center "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 2.000000
ioText {175, 246} {80, 30} label 0.000000 0.00100 "" right "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Mod index 2
ioText {175, 210} {80, 30} label 0.000000 0.00100 "" right "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Mod ratio 2
ioText {255, 209} {80, 30} editnum 2.000000 0.001000 "Mod_ratio2" center "" 0 {0, 0, 0} {63232, 62720, 61952} nobackground noborder 2.000000
ioKnob {693, 187} {60, 60} 1.000000 0.000000 0.010000 1.000000 Volume
ioText {693, 262} {60, 25} display 1.000000 0.00100 "Volume" center "Liberation Sans" 10 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder 1.000
ioText {691, 242} {60, 25} label 0.000000 0.00100 "" center "Liberation Sans" 12 {65280, 43520, 0} {63232, 62720, 61952} nobackground noborder Volume
ioGraph {6, 295} {748, 50} scope 2.000000 -255 
</MacGUI>

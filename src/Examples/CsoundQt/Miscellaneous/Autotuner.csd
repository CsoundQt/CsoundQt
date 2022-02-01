<CsoundSynthesizer>
<CsOptions>
-b128 -B256
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 1

; By Victor Lazzarini 2010
; From an original idea by Brian Carty
; Adapted for CsoundQt by Andres Cabrera

gktrack_opcode init 0
gktrans_method init 0
gkenable init 0
gklevel init 0
gkinterval1_on init 0
gkinterval1 init 0
gkinterval2 init 0
gkinterval2_on init 0

opcode  PitchShifter, a, akkii
       setksmps  1                   ; kr=sr
asig,kpitch,kfdb,idel,iwin  xin
kdelrate = (kpitch-1)/idel
avdel   phasor -kdelrate               ; 1 to 0
avdel2  phasor -kdelrate, 0.5          ; 1/2 buffer offset
afade  tablei avdel, iwin, 1, 0, 1     ; crossfade windows
afade2 tablei avdel2,iwin, 1, 0, 1
adump  delayr idel
atap1  deltapi avdel*idel           ; variable delay taps
atap2  deltapi avdel2*idel
amix   =   atap1*afade + atap2*afade2  ; fade in/out the delay taps
      delayw  asig+amix*kfdb          ; in+feedback signals
      xout  amix
endop

/**** autotune  ***********************************/
/* aout Autotune asig,ism,ikey,ifn[,imeth]           */
/* asig - input                                                           */
/* ism - smoothing time in secs                            */
/* ikey - key (0 = C,... ,11 = B                                   */
/* ifn - table containing scale pitch classes (7)  */
/* imeth - pitch track method: 0 - pitch (default) */
/*         1 - ptrack, 2 - pitchamdf                              */
/***************************************************/

opcode Autotune, a, aiiik

iwinsize = 1024
ibase = 440
ibasemidi = 69

asig,ism,itrans,ifn,km  xin

if km == 0 then
kfr, kamp pitch asig,0.1,6.00,9.00,0
kfr = cpsoct(kfr)
elseif km == 1 then
kfr, kamp ptrack asig, 1024
else
kfr, kamp pitchamdf asig,130,1040
endif

if (kfr > 20) kgoto ok
kfr = 440
ok:

ktemp = 12 * (log(kfr / ibase) / log(2)) + ibasemidi
ktet = round(ktemp)

kpos init 0
itrans = 2
test:
knote table kpos, ifn     ; get a pitch class from table
ktest = ktet % 12       ;  note mod 12
knote = (knote+itrans) % 12 ; plus transpose interval mod 12
if ktest == knote kgoto next ; test if note matches pitch class + transposition
kpos = kpos + 1           ; increment table pos
if kpos >= 7  kgoto shift ; if more than or pitch class set we need to shift it
kgoto test                ; loop back

shift:
if (ktemp >= ktet) kgoto plus
ktet = ktet - 1
kgoto next
plus:
ktet = ktet + 1

next:
kpos = 0
ktarget = ibase * (2 ^ ((ktet - ibasemidi) / 12))
kratio = ktarget/kfr
kratioport port kratio, ism, ibase

aout PitchShifter asig,kratioport,0,0.1,5

     xout     aout
endop

opcode Autotune2, a, aiiik
ifftsize = 512
iwtype = 1
ibase = 440
ibasemidi = 69
asig,ism,itrans,ifn,km xin
fsig pvsanal    asig, ifftsize, ifftsize / 4, ifftsize, iwtype;

if km == 0 then
kfr, kamp pitch asig,0.1,6.00,9.00,0
kfr = cpsoct(kfr)
elseif km == 1 then
kfr, kamp ptrack asig, 1024
else
kfr, kamp pitchamdf asig,130,1040
endif

if (kfr > 20) kgoto ok
kfr = 440
ok:
ktemp = 12 * (log(kfr / ibase) / log(2)) + ibasemidi
kmidi = round(ktemp)

kpos init 0
itrans = 2
test:
knote table kpos, ifn ; get a pitch class
ktest = kmidi % 12 ; note mod 12
knote = (knote+itrans) % 12

if ktest == knote kgoto next ; test if note matches pitch class + transposition
kpos = kpos + 1 ; increment table pos
if kpos >= 7 kgoto shift ; if more than or pitch class set we need to shift it
kgoto test ; loop back
shift:
if (ktemp >= kmidi) kgoto plus
kmidi = kmidi - 1
kgoto next
plus:
kmidi = kmidi + 1
next:
kpos = 0
ktarget = ibase * (2 ^ ((kmidi - ibasemidi) / 12))

kratio = ktarget/kfr
kratioport port kratio, ism, ibase
fauto pvscale fsig, kratioport ; transpose it (optional param: formants)
aout pvsynth fauto
xout aout

endop

instr 1 ; Values from GUI
gktrack_opcode invalue "track_opcode"
gktrans_method invalue "trans_method"
gkenable invalue "enable"
gklevel invalue "level"
gkinterval1_on invalue "interval1_on"
gkinterval1 invalue "interval1"
gkinterval2 invalue "interval2"
gkinterval2_on invalue "interval2_on"
endin

instr 10 ; Audio I/0

ain inch 1

kinterv1 = 2^(gkinterval1/12)
kinterv2 = 2^(gkinterval2/12)
       
if (gkenable == 1) then
	; First add transposed copies
	if (gkinterval1_on == 1) then
		ain2  PitchShifter ain*0.5,kinterv1,0,0.1,5
	else
		clear ain2
	endif
	if (gkinterval2_on == 1) then
		ain3  PitchShifter ain*0.5,kinterv2,0,0.1,5
	else
		clear ain3
	endif
	; Then autotune them
	if (gktrans_method == 0) then
		aout  Autotune  ain,0.01,p4,p5, gktrack_opcode
		aout2 Autotune  ain2,0.01,p4,p5, gktrack_opcode
		aout3 Autotune  ain3,0.01,p4,p5, gktrack_opcode
	elseif (gktrans_method == 1) then
		aout  Autotune2  ain,0.01,p4,p5, gktrack_opcode
		aout2 Autotune2  ain2,0.01,p4,p5, gktrack_opcode
		aout3 Autotune2  ain3,0.01,p4,p5, gktrack_opcode
	else
		clear aout, aout2, aout3
	endif

	out (aout+aout2+aout3)*0.5*gklevel
else
	out ain*gklevel
endif

endin


</CsInstruments>
<CsScore>

f3 0 8 -2  0 2 4 5 7 9 11 12 ; major mode
f4 0 8 -2  0 2 3 5 7 8 10 12 ; minor mode
f5 0 16384 20 1

i 1 0 -1
;       key mode intvl1 intvl2(semitones)
i10 0 -1 0    3   -5     4  ; C major 6-4 harmonies

; Use this instead for natural minor
;i10 0 -1 0    4   -3     5  ; C minor (natural) 6-3 harmonies

e 3600
</CsScore>
</CsoundSynthesizer>
<CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>808</x>
 <y>350</y>
 <width>403</width>
 <height>354</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>85</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>28</x>
  <y>180</y>
  <width>163</width>
  <height>60</height>
  <uuid>{6f608c97-65f2-42f0-ab21-c4def5d22c3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Transposition Interval 1</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>interval1</objectName>
  <x>98</x>
  <y>206</y>
  <width>51</width>
  <height>26</height>
  <uuid>{2f9e69bd-1122-4669-8462-fb42ab1884c9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <resolution>1.00000000</resolution>
  <minimum>-12</minimum>
  <maximum>12</maximum>
  <randomizable group="0">false</randomizable>
  <value>4</value>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>interval1_on</objectName>
  <x>76</x>
  <y>207</y>
  <width>20</width>
  <height>20</height>
  <uuid>{5e3ac752-c4a9-41ed-9f18-d9c1967f0aee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>29</x>
  <y>244</y>
  <width>132</width>
  <height>28</height>
  <uuid>{72b76ce1-8e70-46a3-91be-59471f9a3b35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Output Level</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>level</objectName>
  <x>35</x>
  <y>265</y>
  <width>323</width>
  <height>28</height>
  <uuid>{fc437687-d391-4e3d-86ef-2e34f89b8295}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.47368421</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>enable</objectName>
  <x>202</x>
  <y>150</y>
  <width>20</width>
  <height>20</height>
  <uuid>{c8c56805-9a3c-426f-bc18-b4f06589d320}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>123</x>
  <y>147</y>
  <width>80</width>
  <height>29</height>
  <uuid>{c91c76ac-68c1-423e-b656-191c9c258dcd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Enable</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Play</objectName>
  <x>228</x>
  <y>18</y>
  <width>100</width>
  <height>30</height>
  <uuid>{37afd7a4-7c53-45e1-a40a-1f9204bb5437}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Start</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>56</x>
  <y>12</y>
  <width>166</width>
  <height>50</height>
  <uuid>{46a66da6-a7cd-44f2-b93f-39863e3b1f95}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Autotuner</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>28</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>3</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>58</x>
  <y>9</y>
  <width>166</width>
  <height>50</height>
  <uuid>{380efbe4-92b3-42c6-a98b-2b38b86ae2b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Autotuner</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>28</fontsize>
  <precision>3</precision>
  <color>
   <r>129</r>
   <g>129</g>
   <b>129</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>4</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>60</x>
  <y>7</y>
  <width>166</width>
  <height>50</height>
  <uuid>{22d03e4e-6d71-4926-8137-9bbbaf150e45}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Autotuner</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>28</fontsize>
  <precision>3</precision>
  <color>
   <r>34</r>
   <g>34</g>
   <b>34</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>4</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>34</x>
  <y>109</y>
  <width>162</width>
  <height>31</height>
  <uuid>{5cf105cc-f7d7-40d5-852d-9da0a0074908}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Transposition method</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>trans_method</objectName>
  <x>197</x>
  <y>108</y>
  <width>158</width>
  <height>31</height>
  <uuid>{4b218834-c47b-4cbf-999a-0f372c7dc6d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>delay line</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>spectral</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>33</x>
  <y>73</y>
  <width>162</width>
  <height>31</height>
  <uuid>{1983037d-7c0c-4259-b041-e068b74478f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Tracking opcode</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDropdown" version="2">
  <objectName>track_opcode</objectName>
  <x>196</x>
  <y>72</y>
  <width>158</width>
  <height>31</height>
  <uuid>{628026ef-23f9-4867-bc27-ca1362aae68f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>pitch</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>ptrack</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>pitchamdf</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>195</x>
  <y>180</y>
  <width>163</width>
  <height>60</height>
  <uuid>{74d5d5df-cc44-47c3-bad8-ec01168c7c6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Transposition Interval 2</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
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
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>interval2</objectName>
  <x>265</x>
  <y>206</y>
  <width>51</width>
  <height>26</height>
  <uuid>{9aee3b1f-c20d-42a2-9f93-20767d82cba7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <resolution>1.00000000</resolution>
  <minimum>-12</minimum>
  <maximum>12</maximum>
  <randomizable group="0">false</randomizable>
  <value>7</value>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>interval2_on</objectName>
  <x>243</x>
  <y>207</y>
  <width>20</width>
  <height>20</height>
  <uuid>{4a6d95d4-34a5-410e-8f93-c05ee7a0797e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

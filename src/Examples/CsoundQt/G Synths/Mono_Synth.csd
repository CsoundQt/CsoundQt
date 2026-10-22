<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; A monophonic legato instrument, playable from a MIDI keyboard.
; By Jim Aikin, based on a method suggested by Victor Lazzarini.

sr     = 44100
ksmps  = 4
nchnls = 2
0dbfs  = 1

alwayson "ToneGenerator"
giSaw ftgen 0, 0, 8192, 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

gkCheck init 0
gkPitch init 260

instr 1  ; activated from MIDI channel 1, tracks the pitch
  gkPitch cpsmidib 2
  gkCheck = 1
endin

instr ToneGenerator

  kon active 1  ; check whether any instances of instr 1 are active

  ; velocity sensing -- only accept a new velocity input if
  ; there's no note overlap (if kon == 1) -- scale the velocity
  ; to a range of 0.2 - 1.0
  kvel init 0
  kstatus, kchan, kdata1, kdata2 midiin
  if kstatus == 144 && kdata2 != 0 && kon == 1 then
    kvel = kdata2 * 0.006 + 0.2
  endif

  katt invalue "att"
  krel invalue "rel"
  ; amplitude control
  kampraw init 0
  if kon != 0 then
    kampraw  = 0.5 * kvel
    kenvramp = katt  ; 50 = fast attack
  else
    kampraw  = 0
    kenvramp = krel  ; 1 = slow release
  endif
  kamp tonek kampraw, kenvramp

  kpitchglide invalue "pitchglide"
  ipitchglide = 4  ; higher numbers cause faster glide
  kpitch tonek gkPitch, kpitchglide

  ; oscillators
  idetune = 0.3
  asig1 oscil kamp, kpitch + idetune, giSaw
  asig2 oscil kamp, kpitch, giSaw
  asig3 oscil kamp, kpitch - idetune, giSaw
  asig = asig1 + asig2 + asig3

  ; if no MIDI keys are pressed, reinit the filter envelope
  if gkCheck == 1 && kon == 0 then
    reinit filtenv
  endif

  ifiltdec1 = 1.5
  ifiltdec2 = 3
filtenv:
  kfilt expseg 500, 0.01, 8000, ifiltdec1, 2000, ifiltdec2, 500, 1, 500
  rireturn

  ; smooth the filter envelope so a reinit won't cause it to jump --
  ; also have the cutoff track the keyboard and velocity
  kfilt tonek (kfilt * (0.6 + kvel * 0.5)) + kpitch, kenvramp

  afilt lpf18 asig, kfilt, 0.3, 0.1

  outs afilt, afilt
endin

</CsInstruments>
<CsScore>

e 3600

</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>198</x>
 <y>290</y>
 <width>352</width>
 <height>212</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>239</r>
  <g>239</g>
  <b>239</b>
 </bgcolor>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>att</objectName>
  <x>60</x>
  <y>49</y>
  <width>20</width>
  <height>100</height>
  <uuid>{d9bc8180-98f8-400a-978c-9bedbbee8c34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>80.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>29</x>
  <y>147</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e887fef3-be7e-47c6-b2d5-ef5761197823}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>rel</objectName>
  <x>117</x>
  <y>49</y>
  <width>20</width>
  <height>100</height>
  <uuid>{1b8f2ec1-d0d8-4f4f-905e-cc302929c6c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>50.00000000</maximum>
  <value>47.06000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>86</x>
  <y>147</y>
  <width>80</width>
  <height>25</height>
  <uuid>{695caaa8-f252-4487-8e9b-97cd19647a41}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Release</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>248</x>
  <y>128</y>
  <width>80</width>
  <height>25</height>
  <uuid>{1602d8a5-715e-4794-9c95-29d8487b60de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Slow</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>247</x>
  <y>49</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c2aa0e27-472b-4b75-ba40-2537fe6d3082}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Fast</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>257</x>
  <y>72</y>
  <width>10</width>
  <height>60</height>
  <uuid>{158e8a3a-a4e1-4bc2-b32e-017d6b7109c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="background">
   <r>52</r>
   <g>52</g>
   <b>52</b>
  </bgcolor>
  <bordercolor>
   <r>158</r>
   <g>158</g>
   <b>158</b>
  </bordercolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>pitchglide</objectName>
  <x>195</x>
  <y>49</y>
  <width>20</width>
  <height>100</height>
  <uuid>{dc0d7428-b329-44e8-afb4-b76a0b5b734c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>1.00000000</minimum>
  <maximum>50.00000000</maximum>
  <value>16.68000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>164</x>
  <y>147</y>
  <width>80</width>
  <height>25</height>
  <uuid>{73ffdd1b-bc20-4c21-8442-35b5c04dba11}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Glide</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>32</r>
   <g>32</g>
   <b>32</b>
  </color>
  <bgcolor mode="nobackground">
   <r>224</r>
   <g>224</g>
   <b>224</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>


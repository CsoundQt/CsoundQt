<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; C I R C L E   M A P   D E M O N S T R A T I O N
; Copyright 2012 by Michael Gogins.
; This software is licesed under the terms of the Library GNU Public License verson 3.
;
; With patience, quite an amazing zoo of sounds can be coaxed from this instrument.
; There are fiddly places where the spinners not the sliders must be used. 
; There are gaps in the coupling parameter space where nothing happens. Be patient!
; 
; This is tricky to get to work because it must run at ksmps=1, but the user interface will 
; then tend to interrupt the audio stream. Try rendering in a separate thread and 
; with a large hardware buffer size.
; 
; Also, note that that font is Courier New 8 point with "tab size" 28.

sr      = 44100
ksmps   = 1
nchnls  = 2
0dbfs   = 10


chn_k "kin_coupling", 1
chn_k "kin_filter_frequency", 1
chn_k "kin_filter_q", 1
chn_k "kin_frequency", 1
chn_k "kin_master_level", 1
chn_k "kin_reverb_feedback", 1
chn_k "kin_reverb_wet", 1
chn_k "kout_amplitude", 2
chn_k "kout_frequency", 2
chn_k "kphase_increment", 2


                                alwayson        "CircleMap"
                        
                                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                ; Circle map (See Essl, daFX 2006)
                                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                instr           CircleMap
isine                           ftgenonce		0, 0, 65536, 10, 1
itwopi                          init			6.283185307179586476925286766559
								print			itwopi
aphase0                         init            0
kin_frequency		            chnget         "kin_frequency"
kin_coupling		            chnget         "kin_coupling"
kphase_increment                =               kin_frequency / sr
aphase                          =               (aphase0 + kphase_increment - (kin_coupling / itwopi) * sin(itwopi * aphase0)) % 1.0
aphase0                         =               aphase
asignal							table			aphase, isine, 1
                                ; Resonant filter.
kin_filter_frequency            chnget         "kin_filter_frequency"
kin_filter_q                    chnget         "kin_filter_q"
asignal                         moogladder      asignal, kin_filter_frequency, kin_filter_q, 1.00
                                ; Reverberation.
kin_reverb_feedback		        chnget         "kin_reverb_feedback"
aleftsignal, arightsignal       reverbsc        asignal, asignal, kin_reverb_feedback, 14000 
kin_reverb_wet		            chnget         "kin_reverb_wet"
kreverb_dry                     =               (1.0 - kin_reverb_wet)
aleftwet                        =               kin_reverb_wet * aleftsignal
arightwet                       =               kin_reverb_wet * arightsignal
aleftdry                        =               kreverb_dry * asignal
arightdry                       =               kreverb_dry * asignal
                                ; Anti-clicking.
anticlick                       linsegr         0.0, 0.1, 1.0, 1000, 1.0, 0.1, 0.0
kin_master_level				chnget         "kin_master_level"
aoutleft                        =               (aleftwet  + aleftdry)  * anticlick * kin_master_level
aoutright                       =               (arightwet + arightdry) * anticlick * kin_master_level
kright			                downsamp		aoutleft
kleft			                downsamp		aoutright
                                ; Display actual frequency and amplitude.
kout_frequency, kout_amplitude  ptrack  aoutleft, 1024
                                outs            aoutleft, aoutright
                                dispfft 		aoutleft, 0.25, 1024
                                chnset  kout_frequency, "kout_frequency"
                                chnset  kout_amplitude, "kout_amplitude"
                                chnset  kphase_increment, "kphase_increment"
                                endin


</CsInstruments>
<CsScore>
f 0 36000
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>708</x>
 <y>53</y>
 <width>443</width>
 <height>415</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>148</r>
  <g>176</g>
  <b>227</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>10</y>
  <width>202</width>
  <height>47</height>
  <uuid>{1f0eaf99-e8f9-4a75-9c84-1ad4490cfe43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Circlemap  frequency</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>157</r>
   <g>226</g>
   <b>227</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>kin_frequency</objectName>
  <x>16</x>
  <y>34</y>
  <width>189</width>
  <height>18</height>
  <uuid>{65b458c4-2f99-476c-9588-484a0a90b679}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>20000.00000000</maximum>
  <value>16084.65608466</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>55</y>
  <width>202</width>
  <height>47</height>
  <uuid>{9d56cb37-d337-4901-98c1-a42b14fb02a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Circlemap coupling</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>157</r>
   <g>226</g>
   <b>227</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>kin_coupling</objectName>
  <x>16</x>
  <y>79</y>
  <width>189</width>
  <height>18</height>
  <uuid>{6b1aaaf1-d192-4471-b43c-205e1c8e3585}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.95560000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>113</y>
  <width>202</width>
  <height>47</height>
  <uuid>{a41d5615-20e3-4091-b2fb-9a9ac9ce37fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Moog filter frequency</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>227</g>
   <b>155</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>kin_filter_frequency</objectName>
  <x>16</x>
  <y>137</y>
  <width>189</width>
  <height>18</height>
  <uuid>{6464132d-f55d-4221-a246-ca2cd929a9d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>15000.00000000</maximum>
  <value>6904.76190476</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>158</y>
  <width>202</width>
  <height>47</height>
  <uuid>{549b856e-c525-4249-85d6-bcdbbbcf01b7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Moog filter Q</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>224</r>
   <g>227</g>
   <b>155</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>kin_filter_q</objectName>
  <x>16</x>
  <y>182</y>
  <width>189</width>
  <height>18</height>
  <uuid>{a6bd0a70-834e-473a-adf4-594a9d0759ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.25000000</maximum>
  <value>0.84656085</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>215</y>
  <width>202</width>
  <height>47</height>
  <uuid>{c4d148b9-60a4-4fec-bcf6-1612052148f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Reverberation feedback</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>222</r>
   <g>189</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>kin_reverb_feedback</objectName>
  <x>16</x>
  <y>239</y>
  <width>189</width>
  <height>18</height>
  <uuid>{dc038ef0-758d-491e-b79f-f84201456979}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.81481481</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>261</y>
  <width>202</width>
  <height>47</height>
  <uuid>{1c2d42b7-973d-43cf-9f6b-30c1d0267f65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Reverberation wet/dry</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>222</r>
   <g>189</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>kin_reverb_wet</objectName>
  <x>16</x>
  <y>285</y>
  <width>189</width>
  <height>18</height>
  <uuid>{bdbb825d-772c-4946-b7ed-57ea0fbcc5f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.78306878</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>318</y>
  <width>202</width>
  <height>56</height>
  <uuid>{9a783fce-6cd6-402d-be8a-da4ab2228075}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Master output level</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>135</r>
   <g>235</g>
   <b>168</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>kin_master_level</objectName>
  <x>16</x>
  <y>342</y>
  <width>189</width>
  <height>18</height>
  <uuid>{01bccb3b-c15f-4faa-ae38-71e434837ff4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>1.85185185</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>kin_coupling</objectName>
  <x>135</x>
  <y>57</y>
  <width>70</width>
  <height>20</height>
  <uuid>{9b5a0792-28f8-45eb-b0c9-a34cdc04be51}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.9556</value>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>kin_frequency</objectName>
  <x>135</x>
  <y>12</y>
  <width>70</width>
  <height>20</height>
  <uuid>{ecea3aa0-7230-4685-a33f-2adea81f8728}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>16084.7</value>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>kin_filter_frequency</objectName>
  <x>135</x>
  <y>116</y>
  <width>70</width>
  <height>20</height>
  <uuid>{f8173d43-38ee-4145-9e81-a11483549005}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>6904.76</value>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>kin_master_level</objectName>
  <x>135</x>
  <y>321</y>
  <width>70</width>
  <height>20</height>
  <uuid>{4a5feede-3b6f-4e02-9bc0-becdf68151eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1.85185</value>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>kin_filter_q</objectName>
  <x>135</x>
  <y>161</y>
  <width>70</width>
  <height>20</height>
  <uuid>{134531d5-d05b-4b9f-b846-14559c16b4e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.846561</value>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>kin_reverb_wet</objectName>
  <x>135</x>
  <y>263</y>
  <width>70</width>
  <height>20</height>
  <uuid>{95e33206-8d0f-4106-afcb-5dc824042e83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.783069</value>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>kin_reverb_feedback</objectName>
  <x>135</x>
  <y>217</y>
  <width>70</width>
  <height>20</height>
  <uuid>{61927369-ebb2-4f48-9d9b-40653cf0c0d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <resolution>0.00010000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.814815</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>210</x>
  <y>10</y>
  <width>200</width>
  <height>92</height>
  <uuid>{993f7eda-9518-4f5c-9951-c75d261519de}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Phase increment</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>195</r>
   <g>235</g>
   <b>195</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>kphase_increment</objectName>
  <x>309</x>
  <y>13</y>
  <width>96</width>
  <height>22</height>
  <uuid>{cb7289db-d623-4e2b-8299-d02fd9cb2d0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.365</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>239</r>
   <g>239</g>
   <b>239</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>210</x>
  <y>318</y>
  <width>203</width>
  <height>29</height>
  <uuid>{669f10e4-ae61-40b2-a7eb-52501f6202b2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Tracked frequency</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>195</r>
   <g>235</g>
   <b>195</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>kout_frequency</objectName>
  <x>309</x>
  <y>321</y>
  <width>100</width>
  <height>20</height>
  <uuid>{0494fdd9-320c-456d-a877-afb100b2e04a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>640.791</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>239</r>
   <g>239</g>
   <b>239</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>210</x>
  <y>345</y>
  <width>203</width>
  <height>29</height>
  <uuid>{f959e4fb-d970-4a53-9c8a-cffaab22d58f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Tracked amplitude</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>195</r>
   <g>235</g>
   <b>195</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>kout_amplitude</objectName>
  <x>309</x>
  <y>348</y>
  <width>100</width>
  <height>20</height>
  <uuid>{b92022d7-b6e9-4793-9ea3-4177d55f1c8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>-28.600</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>239</r>
   <g>239</g>
   <b>239</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBScope" version="2">
  <objectName/>
  <x>218</x>
  <y>113</y>
  <width>192</width>
  <height>195</height>
  <uuid>{401acbc9-235e-47f5-93a4-3a6e13d1f4f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <value>-255.00000000</value>
  <type>lissajou</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

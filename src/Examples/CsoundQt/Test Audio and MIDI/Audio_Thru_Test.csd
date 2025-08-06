<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

/*****SIMPLE LIVE INPUT AND OUTPUT TEST (STEREO)*****/

/*example for CsoundQt
written by joachim heintz
jan 2009 / jun 2018 */

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1; do not change this

//UDO for displaying an audio signal in widgets
opcode CsQtMeter, 0, SSak ;see https://github.com/csudo/csudo/blob/master/csqt/CsQtMeter.csd
 S_chan_sig, S_chan_over, aSig, kTrig	xin
 iDbRange = 60 ;shows 60 dB
 iHoldTim = 1 ;seconds to "hold the red light"
 kOn init 0
 kTim init 0
 kStart init 0
 kEnd init 0
 kMax max_k aSig, kTrig, 1
 if kTrig == 1 then
  chnset (iDbRange + dbfsamp(kMax)) / iDbRange, S_chan_sig
  if kOn == 0 && kMax > 1 then
   kTim = 0
   kEnd = iHoldTim
   chnset k(1), S_chan_over
   kOn = 1
  endif
  if kOn == 1 && kTim > kEnd then
   chnset k(0), S_chan_over
   kOn =	0
  endif
 endif
 kTim += ksmps/sr
endop


//declare software channels
 ;input from widgets
chn_k "OnOff1", 1
chn_k "OnOff2", 1
chn_k "gain_in1", 1
chn_k "gain_in2", 1
chn_k "gain_out1", 1
chn_k "gain_out2", 1

 ;output to widgets
chn_k "ShowOnOff1", 2
chn_k "ShowOnOff2", 2
chn_k "in1_pre", 2
chn_k "in1over_pre", 2
chn_k "in2_pre", 2
chn_k "in2over_pre", 2
chn_k "in1_post", 2
chn_k "in1over_post", 2
chn_k "in2_post", 2
chn_k "in2over_post", 2
chn_k "out1_post", 2
chn_k "out1over_post", 2
chn_k "out2_post", 2
chn_k "out2over_post", 2



instr Audio_Thru

 ain1, ain2 ins ;stereo input
 kTrigDisp metro 10; frequency for refreshing the display

 ;On/Off state and envelope; show if mutet
 kOnOff1 chnget "OnOff1"
 kOnOff2 chnget "OnOff2"
 kenv1 port kOnOff1, .001; no clicks when pressing on or off
 kenv2 port kOnOff2, .001
 kmute1 = (kOnOff1 == 0 ? 1 : 0)
 kmute2 = (kOnOff2 == 0 ? 1 : 0)
 chnset	kmute1, "ShowOnOff1"
 chnset	kmute2, "ShowOnOff2"

 ;show pre fader input
 CsQtMeter "in1_pre", "in1over_pre", ain1, kTrigDisp
 CsQtMeter "in2_pre", "in2over_pre", ain2, kTrigDisp
 
 ;input gain
 kInputGain1 chnget "gain_in1"
 kInputGain2 chnget "gain_in2"
 ain1gain = ain1 * ampdbfs(kInputGain1)
 ain2gain = ain2 * ampdbfs(kInputGain2)

 ;show post fader input
 CsQtMeter "in1_post", "in1over_post", ain1gain, kTrigDisp
 CsQtMeter "in2_post", "in2over_post", ain2gain, kTrigDisp

 ;output gain
 kOutputGain1 chnget "gain_out1"
 kOutputGain2 chnget "gain_out2"
 aout1gain = ain1gain * ampdbfs(kOutputGain1) * kenv1
 aout2gain = ain2gain * ampdbfs(kOutputGain2) * kenv2

 ;show output
 CsQtMeter "out1_post", "out1over_post", aout1gain, kTrigDisp
 CsQtMeter "out2_post", "out2over_post", aout2gain, kTrigDisp

 ;signal output
 out aout1gain, aout2gain

endin


</CsInstruments>
<CsScore>
i "Audio_Thru" 0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>344</x>
 <y>245</y>
 <width>582</width>
 <height>651</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>253</x>
  <y>117</y>
  <width>306</width>
  <height>77</height>
  <uuid>{abbb9622-b3f2-4d9c-9b7c-6aaba67c5395}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This example shows how you can display your inputs and outputs and how you can control the level.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>7</x>
  <y>78</y>
  <width>227</width>
  <height>284</height>
  <uuid>{737b8646-52ac-4cec-a615-b01be9d5d2b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Input</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>22</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>9</x>
  <y>16</y>
  <width>552</width>
  <height>47</height>
  <uuid>{a1344146-bffd-4838-8ac0-55b71aa9d1f0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>AUDIO THRU TEST</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>26</fontsize>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>251</x>
  <y>77</y>
  <width>308</width>
  <height>33</height>
  <uuid>{2049480b-bcf4-4276-811c-4e2b6373d978}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>(Be careful - feedback is likely!)</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>172</g>
   <b>56</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>251</x>
  <y>185</y>
  <width>308</width>
  <height>68</height>
  <uuid>{fa4ee6ae-88ef-4397-be58-61d8c617f6ee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This example connects the inputs of your audio device to its outputs</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>250</x>
  <y>231</y>
  <width>307</width>
  <height>143</height>
  <uuid>{347c7284-0293-4759-a480-3bb703ae762b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>For Live-Input it's very important to adjust the software (-b) and the hardware (-B) buffer size in conjunction with the number of audio samples per control period (ksmps). For this see the page Optimizing Audio i/O Latency in the Csound Manual.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject type="BSBController" version="2">
  <objectName>in1_pre</objectName>
  <x>22</x>
  <y>126</y>
  <width>120</width>
  <height>21</height>
  <uuid>{d856a67b-3e77-4528-9303-cae4d64b252c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>in1_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00892408</xValue>
  <yValue>0.00892408</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in1over_pre</objectName>
  <x>140</x>
  <y>126</y>
  <width>21</width>
  <height>21</height>
  <uuid>{480d34a2-d24f-4420-8411-2e8684756547}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>in1over_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in2_pre</objectName>
  <x>21</x>
  <y>154</y>
  <width>121</width>
  <height>21</height>
  <uuid>{e91a5eb4-49da-40bc-9b98-625002ac9bf0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>in1_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.06345120</xValue>
  <yValue>0.00892408</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in2over_pre</objectName>
  <x>139</x>
  <y>154</y>
  <width>21</width>
  <height>21</height>
  <uuid>{72447319-10f0-4533-b0c2-4f32c3336376}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>in2over_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>162</x>
  <y>126</y>
  <width>58</width>
  <height>51</height>
  <uuid>{abdb9c26-42f1-4923-a1e4-b2f437ffbee3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Pre Fader</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>159</x>
  <y>204</y>
  <width>52</width>
  <height>68</height>
  <uuid>{972b3595-83c5-4bf2-a4ee-07094c1c5b3c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Input Gain (dB)</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
 <bsbObject type="BSBController" version="2">
  <objectName>in1_post</objectName>
  <x>21</x>
  <y>284</y>
  <width>118</width>
  <height>21</height>
  <uuid>{88e4e4a3-05b9-4814-aa91-a9344fce2c77}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>in1_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.01492408</xValue>
  <yValue>0.01492408</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in1over_post</objectName>
  <x>137</x>
  <y>284</y>
  <width>21</width>
  <height>21</height>
  <uuid>{cd6e2ddb-b99b-4d38-8646-bdfda717e2ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>in1over_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in2_post</objectName>
  <x>21</x>
  <y>315</y>
  <width>119</width>
  <height>21</height>
  <uuid>{da5c3bda-c599-49e5-a8b2-2bbaa2f9e8bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>in2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.06945120</xValue>
  <yValue>0.06945120</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>in2over_post</objectName>
  <x>137</x>
  <y>315</y>
  <width>21</width>
  <height>21</height>
  <uuid>{0fe34f0f-8931-4615-9e2e-9059bbdf4673}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>in2over_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>161</x>
  <y>287</y>
  <width>58</width>
  <height>51</height>
  <uuid>{fe84bf3b-ec33-486c-a374-ef00f7245d66}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Post Fader</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
 <bsbObject type="BSBKnob" version="2">
  <objectName>gain_in1</objectName>
  <x>49</x>
  <y>189</y>
  <width>45</width>
  <height>51</height>
  <uuid>{5adadc7e-f13e-4de8-a5c7-8a116a50c7f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-18.00000000</minimum>
  <maximum>18.00000000</maximum>
  <value>0.36000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>gain_in2</objectName>
  <x>93</x>
  <y>189</y>
  <width>45</width>
  <height>51</height>
  <uuid>{c22d2969-084a-4ff4-93a5-813aeffbe554}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-18.00000000</minimum>
  <maximum>18.00000000</maximum>
  <value>0.36000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>gain_in1</objectName>
  <x>49</x>
  <y>238</y>
  <width>34</width>
  <height>28</height>
  <uuid>{7ba45fbe-8aaf-4748-a2e9-e5fa2b7dcec3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>sans</font>
  <fontsize>16</fontsize>
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
  <value>0.36000000</value>
  <resolution>0.10000000</resolution>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>gain_in2</objectName>
  <x>92</x>
  <y>238</y>
  <width>36</width>
  <height>29</height>
  <uuid>{a466cb5e-1159-41d9-a15c-e459def37542}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>sans</font>
  <fontsize>16</fontsize>
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
  <value>0.36000000</value>
  <resolution>0.10000000</resolution>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>6</x>
  <y>365</y>
  <width>548</width>
  <height>233</height>
  <uuid>{79bcdc33-a579-4a2c-a9e3-9df9f46c4f2f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Output</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>22</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>OnOff1</objectName>
  <x>54</x>
  <y>544</y>
  <width>20</width>
  <height>20</height>
  <uuid>{c4e3de5c-f5be-40b7-b799-9aed2be75c3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>107</x>
  <y>552</y>
  <width>87</width>
  <height>30</height>
  <uuid>{38c914f3-bbe7-41ab-8247-81c46b1b727a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>On/Off</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>OnOff2</objectName>
  <x>81</x>
  <y>544</y>
  <width>20</width>
  <height>20</height>
  <uuid>{81e2d951-91d1-4313-be9f-1e931d7b1727}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>ShowOnOff1</objectName>
  <x>54</x>
  <y>569</y>
  <width>20</width>
  <height>19</height>
  <uuid>{10602c65-2ad3-4b07-91ba-41b31e900255}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>1.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>ShowOnOff2</objectName>
  <x>80</x>
  <y>569</y>
  <width>20</width>
  <height>19</height>
  <uuid>{6569e726-edf6-4498-a025-03fc6a375133}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over_pre</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>1.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>111</x>
  <y>421</y>
  <width>68</width>
  <height>69</height>
  <uuid>{b37103cb-189d-4438-bced-7be05f0823f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Output Gain (dB)</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
 <bsbObject type="BSBController" version="2">
  <objectName>out1_post</objectName>
  <x>237</x>
  <y>468</y>
  <width>252</width>
  <height>21</height>
  <uuid>{6bc87aca-c59c-402d-9d69-0f567840a6e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>out1_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-inf</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out1over_post</objectName>
  <x>486</x>
  <y>468</y>
  <width>21</width>
  <height>21</height>
  <uuid>{a8341d8c-9781-45ef-94d5-3fa26267783f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>out1over_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out2_post</objectName>
  <x>237</x>
  <y>495</y>
  <width>252</width>
  <height>21</height>
  <uuid>{44c8609e-c93b-4e59-98b5-2ba5820635a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-inf</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>out2over_post</objectName>
  <x>486</x>
  <y>495</y>
  <width>21</width>
  <height>21</height>
  <uuid>{8ff352c2-0012-4242-a778-b86a396d5881}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>out2over_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>gain_out1</objectName>
  <x>47</x>
  <y>380</y>
  <width>24</width>
  <height>122</height>
  <uuid>{062255ac-dcb1-49bc-9413-4adcbe86f600}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-48.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>-4.22950820</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>gain_out2</objectName>
  <x>81</x>
  <y>380</y>
  <width>24</width>
  <height>122</height>
  <uuid>{0a99dd1a-bd8f-4bba-87c8-9c9943b2f600}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-48.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>-5.70491803</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>gain_out1</objectName>
  <x>40</x>
  <y>504</y>
  <width>34</width>
  <height>28</height>
  <uuid>{10bd7d74-72fb-4b70-814e-fd167ebc1cfd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>sans</font>
  <fontsize>16</fontsize>
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
  <value>-4.22950820</value>
  <resolution>0.10000000</resolution>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject type="BSBScrollNumber" version="2">
  <objectName>gain_out2</objectName>
  <x>77</x>
  <y>503</y>
  <width>36</width>
  <height>29</height>
  <uuid>{44eec99e-f733-4221-9879-43791d00e207}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>sans</font>
  <fontsize>16</fontsize>
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
  <value>-5.70491803</value>
  <resolution>0.10000000</resolution>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

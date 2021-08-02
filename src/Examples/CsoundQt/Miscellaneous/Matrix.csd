/*
cs4dev tutorial apeMatrix

4 x 4 matrix implementation for CsoundQt

by Alessandro Petrolati
www.densitygs.com
© 2015
*/

<CsoundSynthesizer>
<CsOptions>

;-o dac
;-+rtmidi=null
;-+rtaudio=null
;-d
;-+msg_color=0
;--expression-opt
;-M0
;-m0
;-i adc

</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1.0


;define 4 x 4 matrix according to APE_MATRIX.h
#define MATRIX_SIZE #4#

;#define USE_ZAK ##	;use zak system for GET_CHANNEL (faster but less accurate)

;if USE_ZAK is definded, the Matrix connections are lazy, suitable for control (k) signals.
;if USE_ZAK is un-defined the Matrix connections are awake, suitable for audio (a) signals but more CPU expensive.

#ifdef USE_ZAK

	zakinit  $MATRIX_SIZE*2, 1
#else

	gaMixer[] init $MATRIX_SIZE
	gkMatrix[][] init $MATRIX_SIZE, $MATRIX_SIZE
#end


;------------------------------------------------------------
;to make sure the matrix does not receive MIDI 
;------------------------------------------------------------
massign 1,0

;------------------------------------------------------------
;max allocation for matrix connections $MATRIX_SIZE^2 instances
;------------------------------------------------------------
maxalloc 1, ($MATRIX_SIZE*$MATRIX_SIZE)

;-------------------------------------------------
	opcode GET_MIXER_MASTER, a, i
;-------------------------------------------------

iMixerNumber  xin

#ifdef USE_ZAK
iMixerNumber += $MATRIX_SIZE
	aSumOfChannels	zar iMixerNumber
	zacl iMixerNumber, iMixerNumber
#else
aSumOfChannels = 0
kndx = 0

loop:
	if (gkMatrix[iMixerNumber][kndx] > 0) then
		aSumOfChannels += gaMixer[kndx]; * gkMatrix[ichannel][kndx]
	endif

loop_lt kndx, 1, $MATRIX_SIZE, loop
#end

xout aSumOfChannels

	endop

;-------------------------------------------------
	opcode	SCHEDULE_MATRIX_PIN, ii, iik
;-------------------------------------------------
ipinNum, instrNum, ktoggle             xin
	
ichannel = int(ipinNum / $MATRIX_SIZE)
imixer = ipinNum % $MATRIX_SIZE

ip1 = instrNum + (ipinNum * 0.001)

ktrig changed ktoggle

if (ktrig == 1) then

	if (ktoggle == 1) then
#ifdef USE_ZAK
		schedkwhen 1, 0,0,ip1,0,-1, ichannel, imixer
#else
		schedkwhen 1, 0,0,ip1,0,.1, ichannel, imixer, 1
#endif
	else
#ifdef USE_ZAK	
		schedkwhen 1, 0,0,-ip1,0,0, ichannel, imixer
#else
		schedkwhen 1, 0,0,ip1,0,.1, ichannel, imixer, 0
#endif		
	endif
endif

	xout	ichannel, imixer
	endop

;------------------------------------------------------------


;------------------------------------------------------------
;	Output channels Pin index

;0	Oscillator sine
;1 	Oscillator saw
;2 	Reverb
;3 	Flanger
;------------------------------------------------------------

;------------------------------------------------------------
;	Input channels Pin index

;0	Out Left
;1 	Out Right
;2 	Reverb
;3 	Flanger
;------------------------------------------------------------

	
;------------------------------------------------------------
instr 1 ; MATRIX PATCHBOARD
;------------------------------------------------------------

; Y = p4 Channel
; X = p5 Mixer
; p6 = 1 Matrix connected
; p6 = 0 Matrix un-connected

iChannelNumber init p4
iMixerNumber init p5
iMatrixState init p6

#ifdef USE_ZAK
	ain	 zar  iChannelNumber ; from 0 to $MATRIX_SIZE-1
	
	zawm ain, iMixerNumber + $MATRIX_SIZE, 1  ; from $MATRIX_SIZE to ($MATRIX_SIZE*2)-1
#else

	gkMatrix[iMixerNumber][iChannelNumber] = iMatrixState
	turnoff
#end	

endin






;------------------------------------------------------------
;------------------------------------------------------------
;------------------------------------------------------------

;	MODULES IMPLEMENTATION

;------------------------------------------------------------
;------------------------------------------------------------
;------------------------------------------------------------





;------------------------------------------------------------
instr 10 ; OSC 1 Sine
;------------------------------------------------------------

kcps	invalue "sine_freq"
asig oscili 0.5, kcps

;write Signal to Output Channel 0
ioutputChannel init 0

#ifdef USE_ZAK
	zaw asig, ioutputChannel
#else
	gaMixer[ioutputChannel] = asig
#end

endin



;------------------------------------------------------------
instr 11 ; OSC 2 Saw
;------------------------------------------------------------
 
kcps	invalue "saw_freq"
asig vco 0.5, kcps, 1, 0.5, 1

;write Signal to Output Channel 1
ioutputChannel init 1

#ifdef USE_ZAK
	zaw asig, ioutputChannel
#else
	gaMixer[ioutputChannel] = asig	; write Signal in zak 0 (VCO_1 output 1)
#end
endin



;------------------------------------------------------------
instr 12; Reverb
;------------------------------------------------------------

;receive signal from mixer 2
iMixerNumber init 2
aInputSignal = GET_MIXER_MASTER(iMixerNumber)

a1, a2 reverbsc    aInputSignal * 1.8, aInputSignal * -1.8, 0.85, 9000
arev = a1 + a2

; write Signal to Output Channel 2
ioutputChannel init 2

#ifdef USE_ZAK
	zaw arev, ioutputChannel
#else
	gaMixer[ioutputChannel] = arev
#end

endin



;------------------------------------------------------------
instr 13; Flanger
;------------------------------------------------------------

;receive signal from mixer 3
iMixerNumber init 3
aInputSignal = GET_MIXER_MASTER(iMixerNumber)

kcps	invalue "lfo_hz"
adel oscil 0.001, kcps
adel += 0.001
aflg flanger aInputSignal, adel, 0.8
asig clip aflg, 1, 1

;mix flanger with original
asig += aInputSignal     
     
;write Signal to Output Channel 3
ioutputChannel init 3

#ifdef USE_ZAK
	zaw asig, ioutputChannel
#else
	gaMixer[ioutputChannel] = asig
#end
     
endin



;------------------------------------------------------------
instr 14; OUTPUT
;------------------------------------------------------------

;receive signal from mixer 0
inputSignal init 0
aIn_L = GET_MIXER_MASTER(inputSignal)

;receive signal from mixer 1
inputSignal init 1
aIn_R = GET_MIXER_MASTER(inputSignal)

outs aIn_L, aIn_R
endin


;------------------------------------------------------------
instr 99	; Sampling Values fron UI
;------------------------------------------------------------

inst = 1 ;matrix perform instrument

k0 invalue "m0" ;ie. pin 0
k1 invalue "m1" ;i.e. pin 1
k2 invalue "m2"
k3 invalue "m3"

k4 invalue "m4"
k5 invalue "m5"
k6 invalue "m6"
k7 invalue "m7"

k8 invalue "m8"
k9 invalue "m9"
k10 invalue "m10"
k11 invalue "m11"

k12 invalue "m12"
k13 invalue "m13"
k14 invalue "m14"
k15 invalue "m15" ;i.e. pin 15

ichannel, imixer SCHEDULE_MATRIX_PIN 0, inst, k0
ichannel, imixer SCHEDULE_MATRIX_PIN 1, inst, k1
ichannel, imixer SCHEDULE_MATRIX_PIN 2, inst, k2
ichannel, imixer SCHEDULE_MATRIX_PIN 3, inst, k3

ichannel, imixer SCHEDULE_MATRIX_PIN 4, inst, k4
ichannel, imixer SCHEDULE_MATRIX_PIN 5, inst, k5
ichannel, imixer SCHEDULE_MATRIX_PIN 6, inst, k6
ichannel, imixer SCHEDULE_MATRIX_PIN 7, inst, k7

ichannel, imixer SCHEDULE_MATRIX_PIN 8, inst, k8
ichannel, imixer SCHEDULE_MATRIX_PIN 9, inst, k9
ichannel, imixer SCHEDULE_MATRIX_PIN 10, inst, k10
ichannel, imixer SCHEDULE_MATRIX_PIN 11, inst, k11

ichannel, imixer SCHEDULE_MATRIX_PIN 12, inst, k12
ichannel, imixer SCHEDULE_MATRIX_PIN 13, inst, k13
ichannel, imixer SCHEDULE_MATRIX_PIN 14, inst, k14
ichannel, imixer SCHEDULE_MATRIX_PIN 15, inst, k15

endin



</CsInstruments>
<CsScore>
; Table #1, a sine wave.
f 1 0 65536 10 1

i10 0 999999999
i11 0 999999999
i12 0 999999999
i13 0 999999999
i14 0 999999999
i99 0 999999999

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1100</x>
 <y>385</y>
 <width>340</width>
 <height>217</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>143</r>
  <g>153</g>
  <b>179</b>
 </bgcolor>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m0</objectName>
  <x>131</x>
  <y>102</y>
  <width>20</width>
  <height>20</height>
  <uuid>{97519746-14f1-4708-ae0e-578490a77575}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m1</objectName>
  <x>154</x>
  <y>102</y>
  <width>20</width>
  <height>20</height>
  <uuid>{3a2f9210-aa12-4c42-a785-c8165ed32d2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m2</objectName>
  <x>178</x>
  <y>102</y>
  <width>20</width>
  <height>20</height>
  <uuid>{dfb9ee9b-d1bb-4199-aa04-b8e11640dfcd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m3</objectName>
  <x>201</x>
  <y>102</y>
  <width>20</width>
  <height>20</height>
  <uuid>{81ca662a-f9ee-466f-a56a-b9596ee7bdee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m4</objectName>
  <x>131</x>
  <y>125</y>
  <width>20</width>
  <height>20</height>
  <uuid>{f46a40bc-bbc1-4fca-a34c-8a6e7982b2ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m5</objectName>
  <x>154</x>
  <y>125</y>
  <width>20</width>
  <height>20</height>
  <uuid>{6fcb188d-14b1-47a5-9502-60b82d52be39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m6</objectName>
  <x>178</x>
  <y>125</y>
  <width>20</width>
  <height>20</height>
  <uuid>{12fedc78-e356-49b6-a4b3-0da644b79f64}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m7</objectName>
  <x>201</x>
  <y>125</y>
  <width>20</width>
  <height>20</height>
  <uuid>{9d6e77d1-ae7d-46a1-8ed4-14ba370e006a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m8</objectName>
  <x>131</x>
  <y>147</y>
  <width>20</width>
  <height>20</height>
  <uuid>{3db458a7-6cab-4f9e-86e8-70d6602fd246}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m9</objectName>
  <x>154</x>
  <y>147</y>
  <width>20</width>
  <height>20</height>
  <uuid>{aeff11fc-8d8f-4290-bc8e-487d6c58f37f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m10</objectName>
  <x>178</x>
  <y>147</y>
  <width>20</width>
  <height>20</height>
  <uuid>{6db5b392-369a-41b0-9138-a3676fbf34e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m11</objectName>
  <x>201</x>
  <y>147</y>
  <width>20</width>
  <height>20</height>
  <uuid>{789e8edd-3cb6-40b7-8ed9-ae91daca4966}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m12</objectName>
  <x>131</x>
  <y>169</y>
  <width>20</width>
  <height>20</height>
  <uuid>{825a7f2c-ab47-44f7-afa4-d443e3e7f52f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m13</objectName>
  <x>154</x>
  <y>169</y>
  <width>20</width>
  <height>20</height>
  <uuid>{ba3942f2-4d17-488c-ad9c-68689c171531}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m14</objectName>
  <x>178</x>
  <y>169</y>
  <width>20</width>
  <height>20</height>
  <uuid>{020bd63c-1b43-43fd-a1f3-02b5ff27a142}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>m15</objectName>
  <x>201</x>
  <y>169</y>
  <width>20</width>
  <height>20</height>
  <uuid>{fe0c2420-9700-48c1-87d3-3296f4b3dda9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>sine_freq</objectName>
  <x>10</x>
  <y>103</y>
  <width>114</width>
  <height>21</height>
  <uuid>{72e21787-261d-41a5-b6d9-3012f5b19568}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>100.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>1000.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>saw_freq</objectName>
  <x>10</x>
  <y>127</y>
  <width>114</width>
  <height>21</height>
  <uuid>{952a407c-a1c6-4e4f-92b3-3dcfb944e2d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>100.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>100.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>lfo_hz</objectName>
  <x>12</x>
  <y>169</y>
  <width>114</width>
  <height>21</height>
  <uuid>{3cd18244-5653-49ab-9cee-e2b9e51b55c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.20000000</minimum>
  <maximum>10.00000000</maximum>
  <value>0.45789474</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>228</x>
  <y>99</y>
  <width>80</width>
  <height>25</height>
  <uuid>{218baa13-de0c-4260-bbfd-d9ad10e06431}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>sine</label>
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
  <x>228</x>
  <y>124</y>
  <width>80</width>
  <height>25</height>
  <uuid>{7a8de8a3-a5ba-4ce2-8523-b3bb588430a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>saw</label>
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
  <x>228</x>
  <y>149</y>
  <width>80</width>
  <height>25</height>
  <uuid>{2da4708d-6e97-4fbd-88e7-3d6e8ceb2c8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>rev out</label>
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
  <x>228</x>
  <y>170</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ee9181d1-70ab-41f4-90ab-09f438f2522f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>flang out</label>
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
  <x>132</x>
  <y>25</y>
  <width>18</width>
  <height>74</height>
  <uuid>{4b7a6eaf-ffcf-4bb9-9562-c05f28f69ea5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>o
u
t

L</label>
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
  <x>155</x>
  <y>25</y>
  <width>18</width>
  <height>74</height>
  <uuid>{da96ed29-e102-4111-87a6-00161b56423e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>o
u
t

R</label>
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
  <x>178</x>
  <y>25</y>
  <width>20</width>
  <height>74</height>
  <uuid>{3683efb2-b4ab-4b2a-9bba-904d00f794e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>r
e
v

IN</label>
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
  <x>201</x>
  <y>6</y>
  <width>22</width>
  <height>94</height>
  <uuid>{c64aafa3-e5e2-4c03-aacd-a343a6d4d05c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>f
l
a
n
g

IN</label>
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

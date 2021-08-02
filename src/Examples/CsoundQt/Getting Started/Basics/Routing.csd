/* Getting started.. 1.8 Routing
Combining Csound's Opcodes is based on the same signal flow principle you have with most analog synths.

As a first example (instr 1) a raw SAWTOOTH oscillator is directly sent to the computer audio output.
SAW -> Output

In the second instrument (instr 2), the same SAWTOOTH Oscillator will first pass a resonant low pass filter, before the filtered signal goes to the audio output.
SAW -> LP -> Output

The third example (instr 3) shows, how the frequency of the SAW can be modulated by a low frequency sine oscillator (LFO).
LFO ~> SAW -> LP -> Output 

In the last example (instr 4) the same LFO is now used to modulate the filters frequency and not the SAW pitch anymore.
SAW -> LP -> Output
	  ^
	 LFO
*/
 
<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

#define SAWFREQ #150# ;freq in Hz
/*
The expression #define is used for textual replacement, also called macros.
Here it is used to paste the same frequency-value (150) in every instrument. If you want to change the SAW frequency for all instruments at once, just change the #150# to the desired Hz. 
Find out more about macro usage in the Csound Manual: 1. Overview->Syntax of the Orchestra->Macros
direct: OrchMacros (Shift+F1)
*/


instr 1
aSaw oscili 0.2, $SAWFREQ, 1 	;$-sign calls the defined macro
outs aSaw, aSaw
endin

instr 2
aSaw oscili 0.2, $SAWFREQ, 1
aFiltered lowpass2 aSaw, 200, 5
outs aFiltered, aFiltered
endin

instr 3
kSinLFO oscili 50, 3, 2
aSaw oscili 0.2, $SAWFREQ+kSinLFO, 1
aFiltered lowpass2 aSaw, 200, 5
outs aFiltered, aFiltered
endin

instr 4
kSinLFO oscili 50, 3, 2
aSaw oscili 0.2, $SAWFREQ, 1
aFiltered lowpass2 aSaw, 200+kSinLFO, 5
outs aFiltered, aFiltered
endin

</CsInstruments>
; In this example we use the score to play the four different instruments one after the other for 2 seconds, with a one second break inbetween.
<CsScore>
f 1 0 1024 7 -1 1024 1 		;saw-waveform functiontable
f 2 0 1024 10 1 				;sine-waveform functiontable
; instr  start  dur
i1 		0 	2
i2 		3 	2
i3 		6 	2
i4		9	2
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Nov. 2009) - Incontri HMT-Hannover
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
  <r>160</r>
  <g>158</g>
  <b>162</b>
 </bgcolor>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>8</x>
  <y>110</y>
  <width>268</width>
  <height>148</height>
  <uuid>{ee2f60f5-c718-47df-ad36-170aa0c4f1c7}</uuid>
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
  <x>8</x>
  <y>20</y>
  <width>269</width>
  <height>86</height>
  <uuid>{c2f4b44b-da01-4878-83a8-fbfe5cc43a54}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>See how the SAW output-waveform changes, because of the used LP filter and the modulation.</label>
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

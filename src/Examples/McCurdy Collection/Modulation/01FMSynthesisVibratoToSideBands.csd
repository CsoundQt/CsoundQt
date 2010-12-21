;Written by Iain McCurdy, 2006


; Modified for QuteCsound by René, November 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 1		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


gisine	ftgen	0, 0, 129, 10, 1	;A SINE WAVE (INTERPOLATING OSCILLATOR OPCODES ARE USED THEREFORE A SMALL TABLE SIZE (+1) CAN BE USED)


instr 1
	ifreq 	= 	300			;FREQUENCY OF THE CARRIER
	
	;VIBRATO DEPTH - GRADUALLY INCREASES - WHEN VIBRATO FREQUENCY IS HIGH (MORE THAN ABOUT 15 Hz), INCREASES IN VIBRATO DEPTH ARE PERCEIVED AS INCREASES IN THE STRENGTH AND NUMBERS OF THE SIDE BANDS, I.E. SPECTRAL RICHNESS/BRIGHTNESS OF THE TIMBRE
	kVibratoDepth	expseg	.001, (4), 30, (8), 1000, (25), 1000, (8), 3000
	
	;VIBRATO FREQUENCY - GRADUALLY BUILDS, EVENTUALLY WE ARE NO LONGER ABLE TO PERCEIVE THE PITCH FLUCTUATIONS BUT INSTEAD HEAR 'SIDE BANDS'
	kVibratoFreq	expseg	2, (9), 7, (8), 350, (20), 1000, (8), 1000
	
	;THE MODULATOR WAVEFORM IS CREATED
	aVibrato		oscili	kVibratoDepth, kVibratoFreq, gisine
	
	;THE AUDIO OUTPUT OF THE MODULATOR WAVEFORM (aModulator) IS ADDED TO THE FREQUENCY OF THE CARRIER WAVEFORM 
	aSignal		oscili	0.2, ifreq + aVibrato, gisine
	dispfft aSignal, 0.1, 2048
		  		outs 	aSignal, aSignal
	ktrig	  	metro	10	;CREATE A REPEATING TRIGGER SIGNAL
	if ktrig==1 then
			outvalue	 	"Vibrato_Depth", kVibratoDepth				;UPDATE VALUE BOX 'gihVibratoDepth' WITH THE VALUE kVibratoDepth WHENEVER A TRIGGER PULSE IS RECEIVED
			outvalue		"Vibrato_Rate", kVibratoFreq					;UPDATE VALUE BOX 'gihVibratoFreq' WITH THE VALUE kVibratoFreq WHENEVER A TRIGGER PULSE IS RECEIVED
	endif
endin
</CsInstruments>
<CsScore>
f 0	   3600		;DUMMY SCORE EVENT - KEEPS REALTIME PERFORMANCE GOING FOR ONE HOUR
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>214</x>
 <y>227</y>
 <width>1036</width>
 <height>321</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>241</r>
  <g>226</g>
  <b>185</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>515</width>
  <height>300</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>     FM Synthesis: Vibrato to Side Bands</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>5</r>
   <g>27</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>519</x>
  <y>2</y>
  <width>495</width>
  <height>300</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>FM Synthesis: Vibrato to Side Bands</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>5</r>
   <g>27</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>520</x>
  <y>28</y>
  <width>489</width>
  <height>270</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------------------------------------
This example demonstrates the phenomenon of side bands upon which FM (frequency modulation) synthesis relies. A vibrato function is applied to the frequency control of an oscillator. Gradually the amplitude (depth) and the frequency (speed/rate) of the vibrato are increased. The amplitude (depth) of the vibrato moves from a value of .001 to a final value of 3000. These amplitude values will be added to the frequency of the oscillator. The frequency (speed/rate) of the value rises from a value of 2 Hz to a final value of 3000 Hz. At the beginning of the transformation vibrato is heard but as the frequency (speed/rate) of the vibrato increases we lose the ability to perceive individual pitch fluctuations and instead side bands (additional spectral artefacts) emerge. As the frequency of the vibrato function continues to increase the nature of the spectrum of the new sound continually evolves. As the amplitude of the vibrato function increases beyond the stage where we were still able to perceive vibrato the intensity of the sidebands and therefore the brightness of the new timbre increases.</label>
  <alignment>left</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>6</x>
  <y>6</y>
  <width>100</width>
  <height>30</height>
  <uuid>{24979132-c53f-4414-ac6b-6b4f503ecfe8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  Play</text>
  <image>/</image>
  <eventLine>i 1 0 45</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>52</y>
  <width>180</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vibrato Depth</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>92</y>
  <width>180</width>
  <height>30</height>
  <uuid>{027163fb-bbfe-488e-9351-1c1cd9a9d626}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Vibrato Rate (Hz)</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Vibrato_Depth</objectName>
  <x>212</x>
  <y>52</y>
  <width>80</width>
  <height>30</height>
  <uuid>{d0676861-6836-4fab-8f47-512660445182}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1000.000</label>
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
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Vibrato_Rate</objectName>
  <x>212</x>
  <y>92</y>
  <width>80</width>
  <height>30</height>
  <uuid>{a905d977-20bf-462e-8265-d6badf285cbb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>484.907</label>
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
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>9</x>
  <y>131</y>
  <width>259</width>
  <height>159</height>
  <uuid>{57aca026-ed5a-45dd-9e5c-65bad8e2f077}</uuid>
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
 <bsbObject version="2" type="BSBGraph">
  <objectName/>
  <x>271</x>
  <y>131</y>
  <width>238</width>
  <height>160</height>
  <uuid>{30073ad5-99c1-4e7a-ad5a-8d4d43022a67}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>1</value>
  <objectName2/>
  <zoomx>4.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <all>true</all>
 </bsbObject>
</bsbPanel>
<bsbPresets>
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
ioView background {61937, 58082, 47545}
ioText {2, 2} {515, 300} label 0.000000 0.00100 "" center "DejaVu Sans" 18 {65280, 65280, 65280} {1280, 6912, 38400} nobackground noborder      FM Synthesis: Vibrato to Side Bands
ioText {519, 2} {495, 300} label 0.000000 0.00100 "" center "Arial Black" 18 {65280, 65280, 65280} {1280, 6912, 38400} nobackground noborder FM Synthesis: Vibrato to Side Bands
ioText {520, 28} {489, 270} label 0.000000 0.00100 "" left "Arial" 14 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder ------------------------------------------------------------------------------------------------------------------------Â¬This example demonstrates the phenomenon of side bands upon which FM (frequency modulation) synthesis relies. A vibrato function is applied to the frequency control of an oscillator. Gradually the amplitude (depth) and the frequency (speed/rate) of the vibrato are increased. The amplitude (depth) of the vibrato moves from a value of .001 to a final value of 3000. These amplitude values will be added to the frequency of the oscillator. The frequency (speed/rate) of the value rises from a value of 2 Hz to a final value of 3000 Hz. At the beginning of the transformation vibrato is heard but as the frequency (speed/rate) of the vibrato increases we lose the ability to perceive individual pitch fluctuations and instead side bands (additional spectral artefacts) emerge. As the frequency of the vibrato function continues to increase the nature of the spectrum of the new sound continually evolves. As the amplitude of the vibrato function increases beyond the stage where we were still able to perceive vibrato the intensity of the sidebands and therefore the brightness of the new timbre increases.
ioButton {6, 6} {100, 30} event 1.000000 "" "  Play" "/" i 1 0 45
ioText {13, 52} {180, 30} label 0.000000 0.00100 "" right "Arial" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Vibrato Depth
ioText {13, 92} {180, 30} label 0.000000 0.00100 "" right "Arial" 10 {65280, 65280, 65280} {63232, 62720, 61952} nobackground noborder Vibrato Rate (Hz)
ioText {212, 52} {80, 30} display 1000.000000 0.00100 "Vibrato_Depth" left "Arial" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1000.000
ioText {212, 92} {80, 30} display 484.906586 0.00100 "Vibrato_Rate" left "Arial" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 484.907
ioGraph {9, 131} {259, 159} scope 2.000000 -255 
ioGraph {271, 131} {238, 160} table 1.000000 4.000000 
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

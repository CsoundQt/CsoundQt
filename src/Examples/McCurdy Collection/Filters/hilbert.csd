;Written by Iain McCurdy, 2009. 
;Parts of this example are based on the two examples given in the Csound Manual originally written by Sean Costello.


; Modified for QuteCsound by René, October 2010
; Tested on Ubuntu 10.04 with csound-double cvs August 2010 and QuteCsound svn rev 733

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio file


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 1		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE (BECAUSE OF THE USE OF A FEEDBACK LOOP kr MUST EQUAL sr)
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)


gisine		ftgen	1, 0, 131072, 10, 1
giExp10000	ftgen	0, 0, 129, -25, 0, 1.0, 128, 10000.0		;TABLE FOR EXP SLIDER


instr	1	;GUI

	Sfile_new			strcpy		""						;INIT TO EMPTY STRING

	ktrig	metro	10
	if (ktrig == 1)	then
		gkfshift			invalue 	"Frequency_Shift"
		gkfshiftmlt		invalue 	"Frequency_Shift_Multiplier"
		gkingain			invalue 	"Input_Gain"
		kVCOfrq			invalue	"Saw_Freq"
		gkVCOfrq			tablei	kVCOfrq, giExp10000, 1
						outvalue	"Saw_Freq_Value", gkVCOfrq
		gkUpShiftGain		invalue 	"Up-Shift_Gain"
		gkDownShiftGain	invalue 	"Down-Shift_Gain"
		gkFB_Gain			invalue 	"Feedback_Gain"
		gkdwmix			invalue 	"Dry_Wet_Mix"
		gkoutgain			invalue 	"Output_Gain"

		kfshift		=		gkfshift * gkfshiftmlt					;FREQUENCY VALUE IS DERIVED FROM PRODUCT OF 'Frequency Shift' AND 'Frequency Shift Multiplier' SLIDER
		ktrig1		changed	kfshift
		if ktrig1 ==1 then
					outvalue	"Frequency_Shift_Value", kfshift			;VALUE DISPLAY BOX IS UPDATED WHENEVER kshift CHANGES
		endif

		gksoundfile	invalue	"Input"

		gSfile		invalue	"_Browse"
		Sfile_old		strcpyk	Sfile_new
		Sfile_new		strcpyk	gSfile
		gkfile 		strcmpk	Sfile_new, Sfile_old
	endif
endin

instr	2	;HILBERT FILTERING INSTRUMENT
	amix		init		0											;INITIALISE amix SIGNAL (NEEDED FOR FEEDBACK SIGNAL ON INITIAL PASS) 

	kfshift	=		gkfshift * gkfshiftmlt							;FREQUENCY VALUE IS DERIVED FROM PRODUCT OF 'Frequency Shift' AND 'Frequency Shift Multiplier' SLIDER
	
	kporttime	linseg	0, 0.001, 0.05, 1, 0.05							;PORTAMENTO FUNCTION RISES FROM ZERO
	kVCOfrq	portk	gkVCOfrq, kporttime								;PORTAMENTO APPLIED TO VARIABLE
	kfshift	portk	kfshift, kporttime								;PORTAMENTO APPLIED TO VARIABLE
	
	;SOURCE SOUND IS SELECTED
	if	gksoundfile==0	then											;IF BUTTON-BANK VALUE IS 0...
		ain	inch	1												;ain IS LIVE INPUT
		ain	=	ain * gkingain										;LIVE INPUT MULTIPLIED BY INPUT GAIN SLIDER VALUE
	elseif	gksoundfile==1	then										;IF BUTTON-BANK VALUE IS 1...
		kNew_file		changed	gkfile								;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
		if	kNew_file==1	then										;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
			reinit	NEW_FILE										;BEGIN A REINITIALISATION PASS FROM LABEL 'START'
		endif
		NEW_FILE:
		;OUTPUTS 	OPCODE FILE  | SPEED | INSKIP | LOOPING (0=OFF 1=ON)
		ain	diskin2	gSfile, 	 1,       0,       1   					;ain IS SAMPLE FILE
			rireturn												;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
	else
		ain	vco	10000, kVCOfrq, 1, 0.5, gisine						;ain IS SAW WAVEFORM SAMPLE         
	endif                                              		   			;END OF CONDITIONAL BRANCHING
	
	ain			=		ain + (amix * gkFB_Gain)						;ADD FEEDBACK SIGNAL TO INPUT (AMOUNT OF FEEDBACK CONTROLLED BY 'Feedback Gain' SLIDER)
	areal, aimag	hilbert	ain										;HILBERT OPCODE OUTPUTS TWO PHASE SHIFTED SIGNALS, EACH 90 OUT OF PHASE WITH EACH OTHER
	
	;QUADRATURE OSCILLATORS. I.E. 90 OUT OF PHASE WITH RESPECT TO EACH OTHER
	;OUTUTS	OPCODE	AMPLITUDE | FREQ. | FUNCTION_TABLE | INITIAL_PHASE (OPTIONAL;DEFAULTS TO ZERO)
	asin 	oscili       1,    kfshift,     gisine,          0
	acos 	oscili       1,    kfshift,     gisine,          .25
	;RING MODULATE EACH SIGNAL USING THE QUADRATURE OSCILLATORS AS MODULATORS
	amod1		= areal * acos
	amod2		= aimag * asin
	;UPSHIFTING OUTPUT
	aupshift		= (amod1 - amod2)
	;DOWNSHIFTING OUTPUT
	adownshift	= (amod1 + amod2)
	;CREATE A MIX OF THE UPSHIFTING OUTPUT SIGNAL AND THE DOWNSHIFTING OUTPUT SIGNAL. MIX IS CONTROLLED BY FLTK SLIDERS 'Up-Shift Gain' AND 'Down-Shift Gain'
	amix		sum		aupshift * gkUpShiftGain, adownshift * gkDownShiftGain
	;CREATE A DRY/WET MIX
	amix		ntrpol	ain, amix, gkdwmix								;DRY/WET MIX IS CREATED
			outs		amix * gkoutgain, amix * gkoutgain					;SEND AUDIO TO OUTPUT AND SCALE USING THE FLTK SLIDER DERIVED VARIABLE gKoutgain
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 1		0	   3600		;GUI
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>1402</width>
 <height>719</height>
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
  <width>513</width>
  <height>550</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>hilbert</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>517</x>
  <y>2</y>
  <width>588</width>
  <height>550</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>hilbert</label>
  <alignment>center</alignment>
  <font>Arial Black</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>106</r>
   <g>117</g>
   <b>150</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>519</x>
  <y>21</y>
  <width>583</width>
  <height>528</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>------------------------------------------------------------------------------------------------------------------------------------------------
hilbert is an infinite impulse response (IIR) filter that outputs two signals that are in quadrature (i.e. are 90 out of phase with each other). Listened to on their own, these output signals will sound almost unchanged from the original but with further manipulation a variety of effects are possible. Internally the hilbert filter consists of two parallel 6th order allpass filters that induce a phase lag that increases with frequency but the phase difference between the two outputs for any given input frequency is always 90. Hilbert's output can be used to create a frequency shifting effect. A frequency shifter adds a specified number of cycles-per-second to every frequency of an input signal (as opposed to a pitch shifter which *multiplies* every frequency of an input signal by a specified amount). To complete the frequency shifting procedure the two signals are ring-modulated. The modulating waveforms used should also be in quadrature (90 out of phase with each other). The two resulting signals are either summed or one is subtracted from the other. If the signals are summed the resulting side-bands will be above the original frequency, if one has been subtracted from the other the resulting side-bands will be below the original frequency. In this example the gain of these two signals can be independently controlled using the 'Up-Shift Gain' and 'Down-Shift Gain' sliders. If equal gain is applied to both signals the result is the same as a ring-modulation effect. Frequency shift values can be negative. Applying negative values produces the effect of creating side-bands in the opposite direction of the frequency shift. This interface includes a slider which multiplies the frequency shift value by a value within the range 0 to -1. This can be useful for fine-tuning small frequency shift values and switching its polarity. A 'barber-pole' endlessly rising (or falling) phaser effect can be created by mixing the input signal with the output signal (use the 'Dry/Wet Mix' control) with small frequency shift amounts (typically less that 10 Hz). Fine control of the rate of the phaser effect can be executed using the 'Frequency Shift Multiplier' control. The effect can be intensified using the 'Feedback Gain' control which controls how much of the output signal is fed back into the input. Care should be taken when using the feature as dynamic resonances can be created which can overload and damage speakers (and ears!). When using feedback only one of the frequency shifters outputs should be used (controlled using Up/Down Shift Gain controls) and 'Dry/Wet Mix' should be kept at around 0.5. As the frequency shift value flips into the negative domain the phaser sweeps change direction from upwards to downwards. To explore the sonic possibilities of the frequency shifter a variety of source sound inputs are available in this example including the computer's live input.</label>
  <alignment>left</alignment>
  <font>Arial</font>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>8</x>
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
  <text>  ON / OFF</text>
  <image>/</image>
  <eventLine>i 2 0 -1</eventLine>
  <latch>true</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Frequency_Shift_Value</objectName>
  <x>448</x>
  <y>63</y>
  <width>60</width>
  <height>30</height>
  <uuid>{745d6bee-b951-4a03-9fe8-9e10d5ae4556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>147.200</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Frequency_Shift</objectName>
  <x>8</x>
  <y>46</y>
  <width>500</width>
  <height>27</height>
  <uuid>{06814721-6151-4baa-84e2-8f39843b07a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-2000.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <value>400.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>63</y>
  <width>160</width>
  <height>30</height>
  <uuid>{c6d7165c-6730-426f-b293-52b411bc73cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency Shift</label>
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
  <x>8</x>
  <y>101</y>
  <width>160</width>
  <height>30</height>
  <uuid>{f9f4369b-a39e-45aa-ba99-7457a534535f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Frequency Shift Multiplier</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Frequency_Shift_Multiplier</objectName>
  <x>8</x>
  <y>84</y>
  <width>500</width>
  <height>27</height>
  <uuid>{42fe25e5-e98f-4f00-872c-f791822a1b3e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.36800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Frequency_Shift_Multiplier</objectName>
  <x>448</x>
  <y>101</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a8f35453-f236-447d-88d9-1a0b135383b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.368</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <x>6</x>
  <y>130</y>
  <width>505</width>
  <height>185</height>
  <uuid>{667d0f57-0b13-414b-bd42-32d4b46f95e5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Source</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
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
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>192</x>
  <y>139</y>
  <width>118</width>
  <height>30</height>
  <uuid>{2ac8ef53-dfd3-4ca4-a750-fa0c50ba6c89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Live Input</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>File Input</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Saw Gen</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>317</y>
  <width>505</width>
  <height>230</height>
  <uuid>{604fc254-59e0-4cb4-8154-299cb3ce1611}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mixer</label>
  <alignment>left</alignment>
  <font>Arial Black</font>
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
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Saw_Freq_Value</objectName>
  <x>448</x>
  <y>229</y>
  <width>60</width>
  <height>30</height>
  <uuid>{cceeb623-518a-4c05-a5ce-e634fec25b2c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>260.762</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Saw_Freq</objectName>
  <x>8</x>
  <y>212</y>
  <width>500</width>
  <height>27</height>
  <uuid>{a2c20148-99e4-412a-ab24-49b612a4aa96}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.60400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>229</y>
  <width>160</width>
  <height>30</height>
  <uuid>{7ff4db0d-04be-4eae-add2-45ab90918917}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Saw Frequency</label>
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
  <x>8</x>
  <y>191</y>
  <width>160</width>
  <height>30</height>
  <uuid>{6e81737b-66a9-4320-834b-014bd895a502}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input Gain</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Input_Gain</objectName>
  <x>8</x>
  <y>174</y>
  <width>500</width>
  <height>27</height>
  <uuid>{e480ff5a-92f6-4929-8602-8f780dca72b7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Input_Gain</objectName>
  <x>448</x>
  <y>191</y>
  <width>60</width>
  <height>30</height>
  <uuid>{43fbac34-5fb6-4728-906d-e1c20e3e9c21}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
  <x>8</x>
  <y>252</y>
  <width>150</width>
  <height>30</height>
  <uuid>{daf8bc52-99b9-4fd2-bafd-29657d0894b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Audio File</label>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>179</x>
  <y>274</y>
  <width>328</width>
  <height>28</height>
  <uuid>{639e5abc-1c93-41c5-9b24-69c6ba420300}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/moi/Samples/808loopMono.wav</label>
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
   <r>240</r>
   <g>235</g>
   <b>226</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>8</x>
  <y>273</y>
  <width>170</width>
  <height>30</height>
  <uuid>{83e1bb3c-be92-4763-8f5e-ae79e8f07907}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/moi/Samples/808loopMono.wav</stringvalue>
  <text>Browse Mono Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Up-Shift_Gain</objectName>
  <x>448</x>
  <y>356</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4de7125b-4cc8-4769-ac1b-083ee6357f6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.664</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Up-Shift_Gain</objectName>
  <x>8</x>
  <y>339</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3fc19561-9f06-4437-8dce-93fe562391d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.66400000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>356</y>
  <width>160</width>
  <height>30</height>
  <uuid>{c3737a58-87dd-4c87-8bea-5dd299c564ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Up-Shift Gain</label>
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
  <x>8</x>
  <y>394</y>
  <width>160</width>
  <height>30</height>
  <uuid>{af1df008-d89e-4ad8-bee0-617cd03b7600}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Down-Shift Gain</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Down-Shift_Gain</objectName>
  <x>8</x>
  <y>377</y>
  <width>500</width>
  <height>27</height>
  <uuid>{44b12dfc-6d5b-45c2-bf33-caebdb8f48d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.58600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Down-Shift_Gain</objectName>
  <x>448</x>
  <y>394</y>
  <width>60</width>
  <height>30</height>
  <uuid>{325c647b-10e3-4fc2-a844-903b5cda85c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.586</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Feedback_Gain</objectName>
  <x>448</x>
  <y>431</y>
  <width>60</width>
  <height>30</height>
  <uuid>{121dd08e-9cc8-478c-9192-dcb2b42eaf2e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.630</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Feedback_Gain</objectName>
  <x>8</x>
  <y>414</y>
  <width>500</width>
  <height>27</height>
  <uuid>{6a029c00-e55c-477d-938e-a64404a35c06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.63000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>431</y>
  <width>160</width>
  <height>30</height>
  <uuid>{2c370158-b9ae-4648-88ae-04102d440d46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feedback Gain</label>
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
  <x>8</x>
  <y>469</y>
  <width>160</width>
  <height>30</height>
  <uuid>{b6b62fdf-f791-4676-8961-1ce0cf2d57f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dry / Wet Mix</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Dry_Wet_Mix</objectName>
  <x>8</x>
  <y>452</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d39a5fa0-6795-46a9-ae22-d2ab4d76d7a7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Dry_Wet_Mix</objectName>
  <x>448</x>
  <y>469</y>
  <width>60</width>
  <height>30</height>
  <uuid>{38dcbd62-dd0a-4147-9061-6996c626127d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Output_Gain</objectName>
  <x>448</x>
  <y>508</y>
  <width>60</width>
  <height>30</height>
  <uuid>{08958aaf-3a03-4d01-8990-d4ee1c5ba2a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.582</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>9</fontsize>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Output_Gain</objectName>
  <x>8</x>
  <y>491</y>
  <width>500</width>
  <height>27</height>
  <uuid>{d0ebedcf-4750-4c6b-b12b-25b0ef251aca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.58200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>508</y>
  <width>160</width>
  <height>30</height>
  <uuid>{0bd621cc-d881-4df2-a199-7b81a298f23c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Gain</label>
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
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

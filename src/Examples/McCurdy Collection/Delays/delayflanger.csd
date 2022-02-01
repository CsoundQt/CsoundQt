;Written by Iain McCurdy, 2006

;Modified for QuteCsound by René, September 2010, updated Feb 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add table(s) for exp slider
;	Add Browser for audio file and use of FilePlay2 udo, now accept mono or stereo wav files


;my flags on Ubuntu: -iadc -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>
sr		= 44100		;SAMPLE RATE
ksmps	= 32			;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2			;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1			;MAXIMUM SOUND INTENSITY LEVEL REGARDLESS OF BIT DEPTH


gitri		ftgen	0, 0, 131072, 7, 0, 65536, 1, 65536, 0	;POSITIVE DOMAIN TRIANGLE WAVE      
giExp1		ftgen	0, 0, 129, -25, 0, ksmps/sr, 128, 1.0	;TABLE FOR EXP SLIDER
giExp7		ftgen	0, 0, 129, -25, 0, 0.0001, 128, 7.0	;TABLE FOR EXP SLIDER


opcode FilePlay2, aa, Skoo		; Credit to Joachim Heintz
	;gives stereo output regardless your soundfile is mono or stereo
	Sfil, kspeed, iskip, iloop	xin
	ichn		filenchnls	Sfil
	if ichn == 1 then
		aL		diskin2	Sfil, kspeed, iskip, iloop
		aR		=		aL
	else
		aL, aR	diskin2	Sfil, kspeed, iskip, iloop
	endif
		xout		aL, aR
endop


instr	10	;GUI
	ktrig	metro	10
	if (ktrig == 1)	then
		gkingain		invalue	"Live_Input_Gain"
		kdlt			invalue	"Delay_Time"
		gkdlt		tablei	kdlt, giExp1, 1
					outvalue	"Delay_Time_Value", gkdlt				;init 0.0001		
		gkmix		invalue	"Mix"								;init 0.5
		gkfeedamt		invalue	"Feedback_Amount"						;init 0.9
		gkamp		invalue	"Output_Amplitude_Rescaling"				;init 0.4
		gkFlaDepth	invalue 	"Flanger_Modulation_Depth"				;init 0.005
		kFlaRate		invalue	"Flanger_Modulation_Rate"
		gkFlaRate		tablei	kFlaRate, giExp7, 1
					outvalue	"Flanger_Modulation_Rate_Value", gkFlaRate	;init 0.05
		gkinput		invalue	"Input"
		gkmode		invalue	"Mode"

	endif
endin

instr	1	;PLAYS FILE
	if	gkinput==0	then								;IF FILE INPUT IS SELECTED...
		Sfile		invalue	"_Browse1"
		gasigL, gasigR	FilePlay2	Sfile, 1, 0, 1				;GENERATE 2 AUDIO SIGNALS FROM A SOUND FILE (NOTE THE USE OF GLOBAL VARIABLES)		
	else												;OTHERWISE
		asigL, asigR	ins								;TAKE INPUT FROM COMPUTER'S AUDIO INPUT
		gasigL	=	asigL * gkingain					;SCALE USING 'Input Gain' SLIDER
		gasigR	=	asigR * gkingain					;SCALE USING 'Input Gain' SLIDER
	endif											;END OF CONDITIONAL BRANCHING
endin                                                                         
                                                                                              
instr 	2	;FLANGER-DELAY INSTRUMENT                             
	iporttime	=		.1								;PORTAMENTO TIME                                      
	kporttime	linseg	0, .001, iporttime, 1, iporttime		;USE OF AN ENVELOPE VALUE THAT QUICKLY RAMPS UP FROM ZERON TO THE REQUIRED VALUE PREVENTS VARIABLES GLIDING TO THEIR REQUIRED VALUES EACH TIME THE INSTRUMENT IS STARTED
	kdlt		portk	gkdlt, kporttime					;PORTAMENTO IS APPLIED TO THE VARIABLE 'gkdlt'. A NEW VARIABLE 'kdlt' IS CREATED.
	adlt		interp	kdlt								;A NEW A-RATE VARIABLE 'adlt' IS CREATED BY INTERPOLATING THE K-RATE VARIABLE 'kdlt' 
	                                                                                              
	amod		oscili	gkFlaDepth, gkFlaRate, gitri			;OSCILLATOR THAT MAKES USE OF THE POSITIVE DOMAIN ONLY TRIANGLE WAVE IN FUNCTION TABLE 1
	                                                                                              
	adlt		sum		adlt, amod						;STATIC DELAY TIME AND MODULATING DELAY TIME ARE SUMMED
	;REMEMBER THAT THE LENGTH OF THE DELAY BUFFER DEFINED WILL HAVE TO TAKE ACCOUNT OF THE SUMMED MAXIMUM OF THE STATIC DELAY TIME AND MODULATING DELAY TIME

	if	gkmode=0	then                                                                                           
		;;;LEFT CHANNEL DELAY;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		abufferL	delayr	1.2							;CREATE A DELAY BUFFER OF 5 SECONDS DURATION (EQUIVALENT TO THE MAXIMUM DELAY TIME POSSIBLE USING THIS EXAMPLE)
		adelsigL 	deltap3	adlt							;TAP THE DELAY LINE AT gkdlt SECONDS                          
				delayw	gasigL + (adelsigL * gkfeedamt)	;WRITE AUDIO SOURCE AND FEEDBACK SIGNAL INTO THE BEGINNING OF THE BUFFER
		
		;;;RIGHT CHANNEL DELAY;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		                                                                                              
		abufferR	delayr	1.2							;CREATE A DELAY BUFFER OF 5 SECONDS DURATION (EQUIVALENT TO THE MAXIMUM DELAY TIME POSSIBLE USING THIS EXAMPLE)
		adelsigR 	deltap3	adlt							;TAP THE DELAY LINE AT gkdlt SECONDS                          
				delayw	gasigR + (adelsigR * gkfeedamt)	;WRITE AUDIO SOURCE AND FEEDBACK SIGNAL INTO THE BEGINNING OF THE BUFFER
        elseif	gkmode=1	then											
		adelsigL	flanger gasigL, adlt, gkfeedamt , 1.2
		adelsigR	flanger gasigR, adlt, gkfeedamt , 1.2		
	endif                                                                                      
	aL		ntrpol	gasigL, adelsigL, gkmix				;CREATE DRY/WET MIX
	aR		ntrpol	gasigR, adelsigR, gkmix				;CREATE DRY/WET MIX

			outs		aL * gkamp, aR * gkamp				;CREATE A MIX BETWEEN THE WET AND THE DRY SIGNALS AT THE OUTPUT
			clear	gasigL, gasigR						;CLEAR THE GLOBAL AUDIO SEND VARIABLES
endin                                                                         
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 10		0		-1		;GUI
i  2      0         -1		;INSTRUMENT 2 PLAYS A HELD NOTE

f 0	  3600				;'DUMMY' SCORE EVENT KEEPS REALTIME PERFORMANCE GOING FOR 1 HOUR
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>882</width>
 <height>515</height>
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
  <height>470</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Flanger Implementation</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>158</r>
   <g>220</g>
   <b>217</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>5</x>
  <y>5</y>
  <width>123</width>
  <height>33</height>
  <uuid>{487d5181-d838-4cce-9628-317fefc350cb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>   ON / OFF</text>
  <image>/</image>
  <eventLine>i 1 0 -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Live_Input_Gain</objectName>
  <x>8</x>
  <y>47</y>
  <width>500</width>
  <height>27</height>
  <uuid>{de47f47d-bcea-4c1c-ab4b-a323452b1f7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.38600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>64</y>
  <width>120</width>
  <height>30</height>
  <uuid>{0200a063-5db8-4668-bc2d-2d989a083f6e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Live input Gain</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Live_Input_Gain</objectName>
  <x>448</x>
  <y>64</y>
  <width>60</width>
  <height>30</height>
  <uuid>{ab191e3a-430d-4f1d-88aa-9840342cd2d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.386</label>
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
  <x>518</x>
  <y>2</y>
  <width>349</width>
  <height>470</height>
  <uuid>{74928ed2-b701-4668-9a11-74763d317e9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Flanger Implementation</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>158</r>
   <g>220</g>
   <b>217</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>522</x>
  <y>21</y>
  <width>340</width>
  <height>450</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>---------------------------------------------------------------------
A flanger is really just a delay effect where the delay tap is slowly modulated using an LFO (Low Frequency Oscillator). Typically the delay times involved in this system are very short so that rather than being able to hear distinct echoes, the comb filtering effect of very short delays is evident. A feedback loop is essential to creating the sound of a flanger. A flanger derives its name from that fact that when originally implemented using reel-to-reel tape recorders the engineer was required to rub their finger against the flange of the reel of tape with varying pressure in order to create the short varying delay time modulations.
In this example the user can choose between a sound file as input or the computer's live input. A gain control is provided to control the gain of the live input. Csound alos contains an opcode called 'flanger' dedicated to reproducing this effect. At the bottom of the GUI the user can switch between a flanger created from first principles using deltapr deltap3 and deltapw and one created using this dedicated opcode. It will be heard that the results are very similar.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Delay_Time_Value</objectName>
  <x>447</x>
  <y>107</y>
  <width>60</width>
  <height>30</height>
  <uuid>{732b2008-7445-4893-a260-e68561cf8e71}</uuid>
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
  <x>7</x>
  <y>107</y>
  <width>120</width>
  <height>30</height>
  <uuid>{b57ba536-8f28-4986-9bf7-8eb84262d8ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Delay Time (sec)</label>
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
  <objectName>Delay_Time</objectName>
  <x>7</x>
  <y>90</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b8fa76b9-3d04-4156-a2f2-a413d3864da3}</uuid>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Input</objectName>
  <x>119</x>
  <y>375</y>
  <width>120</width>
  <height>30</height>
  <uuid>{9b81a1f2-bcb8-4582-925b-9ae56def3865}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Audio File</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Live Input</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>37</x>
  <y>375</y>
  <width>80</width>
  <height>30</height>
  <uuid>{62eeb695-9b83-42da-81cd-8000c232d9b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Input</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Output_Amplitude_Rescaling</objectName>
  <x>7</x>
  <y>219</y>
  <width>500</width>
  <height>27</height>
  <uuid>{b7e7b8ab-140d-45bf-8c52-607bbf726f46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.79800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>236</y>
  <width>170</width>
  <height>30</height>
  <uuid>{92773515-22ba-4f64-b658-78264fc33aba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Output Amplitude Rescaling</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Output_Amplitude_Rescaling</objectName>
  <x>447</x>
  <y>236</y>
  <width>60</width>
  <height>30</height>
  <uuid>{cd171d26-552e-4958-b526-275d452ec385}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.798</label>
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
  <objectName>Mix</objectName>
  <x>447</x>
  <y>150</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5cd56315-4bac-452e-92eb-a031b288b36f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.840</label>
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
  <x>7</x>
  <y>150</y>
  <width>120</width>
  <height>30</height>
  <uuid>{e2cef5dc-8935-405f-98da-e8a167a68d8a}</uuid>
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
  <objectName>Mix</objectName>
  <x>7</x>
  <y>133</y>
  <width>500</width>
  <height>27</height>
  <uuid>{ac0fd134-af88-448c-8e28-0198f559ba34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.84000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Flanger_Modulation_Depth</objectName>
  <x>447</x>
  <y>279</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c14cc927-5ac1-4f6a-8181-6a50801accaa}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.012</label>
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
  <x>7</x>
  <y>279</y>
  <width>180</width>
  <height>30</height>
  <uuid>{f4b96abf-8cf5-4456-a057-6b785e9c4b8d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Flanger Modulation Depth (sec)</label>
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
  <objectName>Flanger_Modulation_Depth</objectName>
  <x>7</x>
  <y>262</y>
  <width>500</width>
  <height>27</height>
  <uuid>{432d4976-cb71-4373-943b-6378da54ddb5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>0.20000000</maximum>
  <value>0.01200000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>Feedback_Amount</objectName>
  <x>7</x>
  <y>176</y>
  <width>500</width>
  <height>27</height>
  <uuid>{3e2b62e8-f887-4073-8258-caac477a80b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-0.99000000</minimum>
  <maximum>0.99000000</maximum>
  <value>0.78408000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>193</y>
  <width>120</width>
  <height>30</height>
  <uuid>{41296e1f-c3d7-4fef-83aa-c850d5b4e198}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Feedback Amount</label>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Feedback_Amount</objectName>
  <x>447</x>
  <y>193</y>
  <width>60</width>
  <height>30</height>
  <uuid>{5fdf1ae1-cf86-495a-b201-685173b6ff11}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.784</label>
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
  <objectName>Flanger_Modulation_Rate_Value</objectName>
  <x>447</x>
  <y>322</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a0bed878-0b29-4c88-b71f-5f3d2d4fb83d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.097</label>
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
  <x>7</x>
  <y>322</y>
  <width>180</width>
  <height>30</height>
  <uuid>{5bd7d99f-d95b-4a22-9761-42252820286b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Flanger Modulation Rate (hz)</label>
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
  <objectName>Flanger_Modulation_Rate</objectName>
  <x>7</x>
  <y>305</y>
  <width>500</width>
  <height>27</height>
  <uuid>{25c8b61d-77ce-4cdd-97e2-44086cffb042}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.61600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>250</x>
  <y>375</y>
  <width>80</width>
  <height>30</height>
  <uuid>{ad2d2c50-18e7-4e6b-945c-b6b30e9bfd15}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mode</label>
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
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Mode</objectName>
  <x>331</x>
  <y>375</y>
  <width>150</width>
  <height>30</height>
  <uuid>{db32fd7e-a193-4181-8aef-d9644aa64252}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>First Principles</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> Flanger Opcode</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>7</x>
  <y>414</y>
  <width>170</width>
  <height>30</height>
  <uuid>{8e7819e7-bd0a-4771-aff2-69c0d6681cb1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>808loop.wav</stringvalue>
  <text>Browse Audio File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>178</x>
  <y>415</y>
  <width>330</width>
  <height>28</height>
  <uuid>{cfa492d9-d223-43c0-a21e-6af2eb9a6a89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>808loop.wav</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>178</x>
  <y>443</y>
  <width>330</width>
  <height>30</height>
  <uuid>{a63909ac-6fa4-41c8-a84b-ba08e76132ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Restart the instrument after changing the audio file.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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

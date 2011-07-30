;Writen by Iain McCurdy, 2006

; Modified for QuteCsound by René, February 2011
; Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:


;my flags on Ubuntu: -dm0 -odac -+rtaudio=alsa -b1024 -B2048 -+rtmidi=alsa -Ma
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


instr	1

	ktable	invalue	"Tuning_Table"

	icps		cpstmid	1+i(ktable)			;PITCH VALUES ARE READ IN FROM THE MIDI KEYBOARD BUT THEY ARE TRANSFORMED ACCORDING TO THE RULES LAID DOWN IN THE TUNING TABLES     
	iamp		ampmidi	0.2				;KEY VELOCITIES READ IN FROM MIDI KEYBOARD
	
	;PERCUSSIVE-TYPE AMPLITUDE ENVELOPE
	;			     | ATTACK_TIME |   | DECAY_TIME |      | RELEASE_TIME |
	aenv		expsegr	.001,     .01,       1,      5,       .001,       2,         .001	
	asig		oscil	aenv*iamp, icps, 99						;CREATE AN AUDIO SIGNAL USING AS OSCILLATOR BASED ON FUNCTION TABLE 99 
	icfoct	veloc	6,12
	asig		butlp	asig, cpsoct(icfoct)
			outs		asig, asig							;SEND THE AUDIO SIGNAL CREATED BY THE OSCILLATOR TO THE SPEAKERS
endin
</CsInstruments>
<CsScore>
;TUNING TABLES:
;STANDARD
;FN_NUM | INIT_TIME | SIZE | GEN_ROUTINE | NUM_GRADES | REPEAT | BASE_FREQ | BASE_KEY_MIDI | TUNING_RATIOS:-0-|----1----|---2----|----3----|----4----|----5----|----6----|----7----|----8----|----9----|----10----|---11----|-12-|
f  1          0        64        -2            12          2     261.626          60                        1  1.059463 1.1224619 1.1892069 1.2599207 1.33483924 1.414213 1.4983063 1.5874001 1.6817917 1.7817962 1.8877471   2
;QUARTER TONES
;fn_num | init_time | size | gen_routine | num_grades | repeat | base_freq | base_key_midi | tuning_ratios:-0-|----1----|---2----|----3----|----4----|----5----|----6----|----7----|----8----|----9----|----10----|---11----|---12---|---13----|----14---|---15--|---16----|----17---|---18----|---19--|---20----|---21----|---22----|---23---|-24-|
f  2          0        64        -2            24          2     261.626          60                        1  1.0293022 1.059463 1.0905076 1.1224619 1.1553525 1.1892069 1.2240532 1.2599207 1.2968391 1.33483924 1.3739531 1.414213 1.4556525 1.4983063 1.54221 1.5874001 1.6339145 1.6817917 1.73107 1.7817962 1.8340067 1.8877471 1.9430623  2
;STANDARD REVERSED
;fn_num | init_time | size | gen_routine | num_grades | repeat | base_freq | base_key_midi | tuning_ratios:-0-|----1----|---2----|----3----|----4----|----5----|----6----|----7----|----8----|----9----|----10----|---11----|-12-|
f  3          0        64        -2            12         .5     261.626          60                        2 1.8877471 1.7817962 1.6817917 1.5874001 1.4983063 1.414213 1.33483924 1.2599207 1.1892069 1.1224619 1.059463    1                                      
;QUARTER TONES REVERSED
;fn_num | init_time | size | gen_routine | num_grades | repeat | base_freq | base_key_midi | tuning_ratios:-0-|----1----|---2----|----3----|----4----|----5----|----6----|----7----|----8----|----9----|----10----|---11----|---12---|---13----|----14---|---15--|---16----|----17---|---18----|---19--|---20----|---21----|---22----|---23---|-24-|
f  4          0        64        -2            24         .5     261.626          60                        2 1.9430623 1.8877471 1.8340067 1.7817962 1.73107 1.6817917 1.6339145 1.5874001 1.54221 1.4983063 1.4556525 1.414213 1.3739531 1.33483924 1.2968391 1.2599207 1.2240532 1.1892069 1.1553525 1.1224619 1.0905076 1.059463 1.0293022   1
;DECATONIC
;fn_num | init_time | size | gen_routine | num_grades | repeat | base_freq | base_key_midi | tuning_ratios:-0-|----1----|---2----|----3----|----4----|----5----|----6----|----7----|----8----|----9----|----10----|
f  5          0        64        -2            10          2     261.626          60                        1  1.0717734 1.148698 1.2311444 1.3195079 1.4142135 1.5157165 1.6245047 1.7411011 1.8660659      2
;THIRD TONES
;fn_num | init_time | size | gen_routine | num_grades | repeat | base_freq | base_key_midi | tuning_ratios:-0-|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8----|----9----|----10----|---11----|----12---|---13----|----14---|---15---|---16----|----17---|---18----|---19----|---20----|---21----|---22----|---23----|----24----|----25----|----26----|----27----|----28----|----29----|----30----|----31----|----32----|----33----|----34----|----35----|----36----|
f  6          0        64        -2            36          2     261.626          60                        1  1.0194406 1.0392591 1.059463 1.0800596  1.1010566 1.1224618 1.1442831 1.1665286 1.1892067 1.2123255  1.2358939 1.2599204 1.284414  1.3093838 1.334839 1.3607891 1.3872436 1.4142125 1.4417056 1.4697332 1.4983057 1.5274337 1.5571279 1.5873994  1.6182594   1.6497193 1.6817909  1.7144859  1.7478165  1.7817951  1.8164343  1.8517469  1.8877459  1.9244448  1.9618572       2
;JUST INTONATION
;FN_NUM | INIT_TIME | SIZE | GEN_ROUTINE | NUM_GRADES | REPEAT | BASE_FREQ | BASE_KEY_MIDI | TUNING_RATIOS:-0-|----1----|---2----|----3----|----4----|----5----|----6----|----7----|----8----|----9----|----10----|---11----|-12-|
f  7          0        64        -2            12          2     261.626          60                        1  [16/15]   [9/8]      [6/5]    [5/4]     [4/3]     [45/32]    [3/2]    [8/5]     [5/3]      [9/5]      [15/8]   2

f 99 0 2048 10 1 0.5 0.2 .1 .05 .025 .0125 .00625

f 0 3600	;DUMMY SCORE EVENT - PERMITS REALTIME PERFORMANCE FOR 1 HOUR 
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>654</x>
 <y>526</y>
 <width>718</width>
 <height>352</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>170</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>2</y>
  <width>711</width>
  <height>345</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>cpstmid  - alternative tunings for MIDI driven instruments</label>
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
   <r>244</r>
   <g>248</g>
   <b>200</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>21</y>
  <width>700</width>
  <height>272</height>
  <uuid>{d4bdb5ce-87d8-4c8c-9c64-40ec2eed6f5a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>--------------------------------------------------------------------------------------------------------------------------
The opcode 'cpstmid' is used, in place of the usual opcode that would be used for MIDI pitch scanning, to derive alternative tunings. Cpstmid references tuning data stored in a GEN-02 function table to derive pitches. In this function table the user must supply information about the number of grades in the scale (i.e. '12' for equal temperament), the ratio at which the scale repeats (i.e. '2' for equal temperament), base frequency of the scale in hertz (261.626 for middle C) and then the ratios from grade to grade. For example in an equally tempered system each subsequent grade is the product of the previous grade and the 1/12 root of 2 (about 1.05946).
This example offers 7 different tuning systems.
1 - equal temperament
2 - quarter tone scale
3 - equal temperament upside-down
4 - quarter tones upside-down
5 - an octave divided into 10 equal intervals
6 - third tones scale
7 - just intonation</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>291</y>
  <width>336</width>
  <height>49</height>
  <uuid>{b143f42f-2cbc-4532-8df7-4ba643c60b37}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
  <bordermode>border</bordermode>
  <borderradius>5</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Tuning_Table</objectName>
  <x>128</x>
  <y>301</y>
  <width>188</width>
  <height>29</height>
  <uuid>{2c4d74f2-8072-4769-bce7-7b28a632b6ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Standard</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Quarter Tones</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Standard Reversed</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Quarter Tones Reversed</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Decatonic</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Third Tones</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Just Intonation</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>12</x>
  <y>300</y>
  <width>107</width>
  <height>33</height>
  <uuid>{a1ec3ab8-544e-4940-abf9-3c6fa212e12a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tuning Table:</label>
  <alignment>right</alignment>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

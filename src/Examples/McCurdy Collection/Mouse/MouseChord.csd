;Written by Iain McCurdy, 2010

; Modified for QuteCsound by René, January 2011.
; Thanks to Andres CABRERA for the mouse channels names.

; Tested on Ubuntu 10.04 with csound-float 5.13.0 January 2011 and QuteCsound svn rev 805 with "Widgets are an independent window" ON.


/*
Mouse Chord
-----------
This csd was originally written for use by someone who only had the use of a head-mouse for music performance.
If the mouse enters one of the coloured boxes the chord indicated by the Roman numeral is played. 
Continuous dynamic control is possible by moving the mouse within the box: the dynamic is lowest at the edges of each box and highest at the centre of each box.
Dynamics are implemented with a changing tone (low-pass filter) as well as changing amplitude.
The user can choose between three different sounds using the radio buttons within the GUI.
Key and tonality (major/minor) can also be selected from within the GUI.
No clicking is required enabling better timing in performance. The GUI window needs to be in focus for this to work.
The mouse relative position is given by the channels _MouseRelX and _MouseRelY.

If the windows need to be resized, for example to accomodate use on a netbook, it is mandatory to manually update the values of boxes dimensions and positions in the csd file.

Professional head mouse or iris tracking software can be very expensive and requires practice. 
iNavigate is a free option for Mac OS 10.5 if the user wants to experiment with this approach.
*/


;Notes on modifications from original csd:
;	No automatic rescale


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


;DEFINE CHORDS I-VII IN PCH FORMAT FOR MAJOR KEY
gichord1	ftgen	0,0,4,-2,8.00,8.04,8.07,9.00
gichord2	ftgen	0,0,4,-2,8.02,8.05,8.09,9.02
gichord3	ftgen	0,0,4,-2,8.04,8.07,8.11,9.04
gichord4	ftgen	0,0,4,-2,8.00,8.05,8.09,9.00
gichord5	ftgen	0,0,4,-2,7.11,8.02,8.07,8.11
gichord6	ftgen	0,0,4,-2,8.00,8.04,8.09,9.00
gichord7	ftgen	0,0,4,-2,8.02,8.05,8.11,9.02

;DEFINE CHORDS I-VII IN PCH FORMAT FOR MINOR KEY
gichord1m	ftgen	0,0,4,-2,8.00,8.03,8.07,9.00
gichord2m	ftgen	0,0,4,-2,8.02,8.05,8.08,9.02
gichord3m	ftgen	0,0,4,-2,8.03,8.07,8.11,9.03
gichord4m	ftgen	0,0,4,-2,8.05,8.08,8.00,9.05
gichord5m	ftgen	0,0,4,-2,8.07,8.11,8.02,9.07
gichord6m	ftgen	0,0,4,-2,8.08,8.00,8.03,9.08
gichord7m	ftgen	0,0,4,-2,8.02,8.05,8.11,9.02

		zakinit	4,10
gkRvbSze	init		0.85		;Reverb size
gkRvbSnd	init		0.2		;Reverb amount


;UDOS-(USER DEFINED OPCODES)----------------------------------------------------------------------------------------------------------------------------------------------
opcode	reverbsr, aa, aakk								;REVERB UDO (USE OF A UDO FOR REVERB IS TO ALLOW THE SETTING OF A K-RATE INDEPENDENT OF THE GLOBAL K-RATE
				setksmps	1							;CONTROL RATE WITHIN UDO IS 1
	ainsigL, ainsigR, kfblvl, kfco	xin					;NAME INPUT VARIABLES
	arvbL, arvbR	reverbsc 	ainsigL, ainsigR, kfblvl, kfco	;USE reverbsc OPCODE
				xout		arvbL, arvbR					;SEND AUDIO TO CALLER INSTRUMENT
endop												;END OF UDO
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

instr	1
	;Boxes dimensions, square isize x isize
	isize	=	200

	;Boxes positions
	ix1		=	50	;I box
	iy1		=	105

	ix2		=	300	;II box
	iy2		=	105
	
	ix3		=	550	;III box
	iy3		=	105
	
	ix4		=	800	;IV box
	iy4		=	105
	
	ix5		=	174	;V box
	iy5		=	386
	
	ix6		=	424	;VI box
	iy6		=	386
	
	ix7		=	674	;VII box
	iy7		=	386

	krelx	invalue	"_MouseRelX"
	krely	invalue	"_MouseRelY"

	gkoct	invalue	"Octave"
	gkkey	invalue	"Key"
	gkton	invalue	"Ton"

;DEFINE A MACRO FOR DETECTION OF MOUSE WITHIN EACH BOX
#define	CHORD_BOX_DETECT(N)
	#
	kinside$N	init	0
	if (ix$N <= krelx && krelx <= ix$N+isize && iy$N <= krely && krely <= iy$N+isize) then
		kinside$N	= 1
			
		kx$N	= (krelx - ix$N - isize*0.5)/(isize*0.5)		;origin change and scale to -1 to +1, zero at center of the box
		ky$N	= (krely - iy$N - isize*0.5)/(isize*0.5)		;origin change and scale to -1 to +1, zero at center of the box
		
		;MOUSE LOCATION DEFINE A VALUE THAT WILL BE ZERO IF THE MOUSE IS ON THE circle of radius 1, AND RISE EXPONENTIALLY TO A VALUE OF 1 AT THE CENTRE OF THE BOX
		k$N	= 1 - ((((kx$N^2) + (ky$N^2))*0.5)^0.5)	
	else
		kinside$N	= 0
		k$N		= 0									;zero amplitude
	endif

	ktrig$N	changed	kinside$N							;CREATE A TRIGGER (MOMENTARY '1') IF MOUSE ENTERS OR LEAVES THIS BOX
	if	ktrig$N=1	then									;IF MOUSE HAS JUST ENTERED OR LEFT THIS BOX...
		if	kinside$N=1	then							;IF MOUSE HAS JUST ENTERED THIS BOX...
			event	"i", 2, 0, 3600, $N					;PLAY A LONG NOTE INSTRUMENT $N
		elseif	kinside$N=0	then						;OR ELSE IF MOUSE HAS JUST LEFT THIS BOX 
			turnoff2	2, 0, 1							;TURNOFF INSTRUMENT 2 ALLOWING RELEASE STAGES TO BE COMPLETED
		endif										;END OF CONDITIONAL BRANCHING
	endif											;END OF CONDITIONAL BRANCHING

		zkw	k$N^3, $N-1								;WRITE amplitude VALUE TO ZAK VARIABLE
	#

	;EXECUTE MACRO FOR EACH BOX...
	$CHORD_BOX_DETECT(1)
	$CHORD_BOX_DETECT(2)
	$CHORD_BOX_DETECT(3)
	$CHORD_BOX_DETECT(4)
	$CHORD_BOX_DETECT(5)
	$CHORD_BOX_DETECT(6)
	$CHORD_BOX_DETECT(7)
endin

instr	2
	;ipch2	table	1, gichord1 + p4 - 1	;PITCH OF FIRST NOTE OF CHORD
	;ipch3	table	2, gichord1 + p4 - 1	;PITCH OF SECOND NOTE OF CHORD
	;ipch4	table	3, gichord1 + p4 - 1	;PITCH OF THIRD NOTE OF CHORD

	aenv		expsegr	0.001,0.2,1,1,0.001	;AMPLITUDE ENVELOPE
	
	;DEFINE MACRO OF CODE TO PRODUCE EACH NOTE OF THE CHORD
#define	NOTE(N)
	#
	if	i(gkton)=0 then										;IF TONALITY IS 'MAJOR'...
		ipch$N	table	$N-1, gichord1 + p4 - 1					;DEFINE PITCH (PCH FORMAT) FOR THIS NOTE (MAJOR)
	else														;OTHERWISE TONALITY MUST BE MINOR...
		ipch$N	table	$N-1, gichord1m + p4 - 1					;DEFINE PITCH (PCH FORMAT) FOR THIS NOTE (MINOR)
	endif													;END OF CONDITIONAL BRANCHING

	imlt$N	= cpspch(ipch$N + (i(gkkey)*0.01) + i(gkoct))			;CONVERT PCH TO A Hz
	aL$N		vco2	0.3, imlt$N, 12			;CREATE AUDIO SIGNAL USING VCO2 OPCODE (LEFT CHANNEL)
	aR$N		= aL$N						;COPY AUDIO SIGNAL
	#

	;EXECUTE MACRO FOR EACH NOTE
	$NOTE(1)
	$NOTE(2)
	$NOTE(3)
	$NOTE(4)
	
	;SUM (MIX) THE FOUR NOTES
	aL		sum		aL1, aL2, aL3, aL4
	aR		sum		aR1, aR2, aR3, aR4
	
	kamp		zkr		p4 - 1									;READ AMPLITUDE FROM ZAK VARIABLE
	kamp		port		kamp, 0.05								;APPLY PORTAMENTO (TO PREVENT QUANTISATION / ZIPPER NOISE)
	aamp		interp	kamp										;INTERPOLATE TO CREATE AN AUDIO RATE VERSION OF THIS VARIABLE
	
	kcfoct	=		(8*kamp)+6								;DEFINE A FILTER CUTOFF FREQUENCY WHICH IS RELATED TO DISTANCE FROM THE CENTRE OF THE BOX
	
	aL		tone		aL, cpsoct(kcfoct)							;APPLY LOW PASS FILTERING (TONE CONTROL)
	aR		tone		aR, cpsoct(kcfoct)							;APPLY LOW PASS FILTERING (TONE CONTROL)
	
	aL		=		aL * aenv * aamp							;SCALE AUDIO SIGNAL WITH AMPLITIUDE ENVELOPE AND
	aR		=		aR * aenv * aamp
			outs		aL, aR
			zawm		aL * gkRvbSnd, 0							;SEND SOME OF THE AUDIO TO THE REVERB VIA ZAK PATCHING (LEFT CHANNEL) 
			zawm		aR * gkRvbSnd, 1							;SEND SOME OF THE AUDIO TO THE REVERB VIA ZAK PATCHING (RIGHT CHANNEL)
endin

instr	1000	;REVERB
	ainL		zar		0										;READ IN AUDIO FROM ZAK CHANNELS
	ainR		zar		1										;READ IN AUDIO FROM ZAK CHANNELS
			denorm	ainL, ainR								;...DENORMALIZE BOTH CHANNELS OF AUDIO SIGNAL

	arvbL, arvbR	reverbsr	ainL, ainR, gkRvbSze, 10000				;CREATE REVERBERATED SIGNAL (USING UDO DEFINED ABOVE)
				outs		arvbL, arvbR							;SEND AUDIO TO OUTPUTS
				zacl		0,3									;CLEAR ZAK AUDIO CHANNELS
endin
</CsInstruments>
<CsScore>
;INSTR | START | DURATION
i 1		0	   3600	;MOUSE POSITION DETECTION, PLAYS A NOTE FOR 1 HOUR
i 1000	0	   3600	;REVERB
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>572</x>
 <y>319</y>
 <width>1032</width>
 <height>641</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>3</x>
  <y>10</y>
  <width>189</width>
  <height>51</height>
  <uuid>{8696498c-ea5a-4002-80e2-b73942e10bb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mouse Chord</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
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
  <x>50</x>
  <y>105</y>
  <width>200</width>
  <height>200</height>
  <uuid>{1f07ff1d-0a47-40af-9185-de05106ee1af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>I</label>
  <alignment>center</alignment>
  <font>FreeSerif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>100</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Key</objectName>
  <x>201</x>
  <y>15</y>
  <width>80</width>
  <height>30</height>
  <uuid>{2d0597db-5154-49a3-8347-28766bf30a39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>C</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>C#</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>D</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>D#</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>E</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>F</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>F#</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>G</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>G#</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>A</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>A#</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>B</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>Ton</objectName>
  <x>290</x>
  <y>15</y>
  <width>80</width>
  <height>30</height>
  <uuid>{9a9862cb-63a0-4ab9-80f7-b7def897c2eb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Major</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>minor</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>Octave</objectName>
  <x>438</x>
  <y>15</y>
  <width>52</width>
  <height>30</height>
  <uuid>{055c3420-76d2-4887-8639-8aab364c2a29}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
  <resolution>1.00000000</resolution>
  <minimum>-2</minimum>
  <maximum>2</maximum>
  <randomizable group="0">false</randomizable>
  <value>-1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>370</x>
  <y>19</y>
  <width>68</width>
  <height>25</height>
  <uuid>{7d941c8e-e8aa-4692-8a56-4c39d8d95630}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Octave</label>
  <alignment>right</alignment>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>300</x>
  <y>105</y>
  <width>200</width>
  <height>200</height>
  <uuid>{34fa8ca4-1381-41a6-9c23-c3af053b7215}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>II</label>
  <alignment>center</alignment>
  <font>FreeSerif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>100</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>550</x>
  <y>105</y>
  <width>200</width>
  <height>200</height>
  <uuid>{a6c7cb9e-55bc-4384-8825-4e3b3314411b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>III</label>
  <alignment>center</alignment>
  <font>FreeSerif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>100</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>800</x>
  <y>105</y>
  <width>200</width>
  <height>200</height>
  <uuid>{2a7f1479-1b80-41f4-9ddb-27a4970f9b80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>IV</label>
  <alignment>center</alignment>
  <font>FreeSerif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>100</r>
   <g>100</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>174</x>
  <y>386</y>
  <width>200</width>
  <height>200</height>
  <uuid>{f33eb5f2-beb2-4ece-a6cf-b54e26c14a80}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>V</label>
  <alignment>center</alignment>
  <font>FreeSerif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>100</g>
   <b>100</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>424</x>
  <y>386</y>
  <width>200</width>
  <height>200</height>
  <uuid>{906fee86-a6f7-47d0-b181-28bb94de1dd1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VI</label>
  <alignment>center</alignment>
  <font>FreeSerif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>100</r>
   <g>255</g>
   <b>100</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>674</x>
  <y>386</y>
  <width>200</width>
  <height>200</height>
  <uuid>{6d570073-35b4-46f9-8b74-fb055707e525}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VII</label>
  <alignment>center</alignment>
  <font>FreeSerif</font>
  <fontsize>70</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>100</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
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
ioView background {65535, 65535, 65535}
ioText {3, 10} {189, 51} label 0.000000 0.00100 "" center "Liberation Sans" 24 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Mouse Chord
ioText {50, 105} {200, 200} label 0.000000 0.00100 "" center "FreeSerif" 70 {0, 0, 0} {25600, 65280, 65280} nobackground noborder I
ioMenu {201, 15} {80, 30} 0 303 "C,C#,D,D#,E,F,F#,G,G#,A,A#,B" Key
ioMenu {290, 15} {80, 30} 0 303 "Major,minor" Ton
ioText {438, 15} {52, 30} editnum -1.000000 1.000000 "Octave" center "" 0 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -1.000000
ioText {370, 19} {68, 25} label 0.000000 0.00100 "" right "Liberation Sans" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Octave
ioText {300, 105} {200, 200} label 0.000000 0.00100 "" center "FreeSerif" 70 {0, 0, 0} {65280, 25600, 65280} nobackground noborder II
ioText {550, 105} {200, 200} label 0.000000 0.00100 "" center "FreeSerif" 70 {0, 0, 0} {65280, 65280, 25600} nobackground noborder III
ioText {800, 105} {200, 200} label 0.000000 0.00100 "" center "FreeSerif" 70 {0, 0, 0} {25600, 25600, 65280} nobackground noborder IV
ioText {174, 386} {200, 200} label 0.000000 0.00100 "" center "FreeSerif" 70 {0, 0, 0} {65280, 25600, 25600} nobackground noborder V
ioText {424, 386} {200, 200} label 0.000000 0.00100 "" center "FreeSerif" 70 {0, 0, 0} {25600, 65280, 25600} nobackground noborder VI
ioText {674, 386} {200, 200} label 0.000000 0.00100 "" center "FreeSerif" 70 {0, 0, 0} {0, 25600, 65280} nobackground noborder VII
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

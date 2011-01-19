;Written by Iain McCurdy, 2010

; Modified for QuteCsound by René, January 2011.
; Thanks to Andres CABRERA for the mouse channels names.

; Tested on Ubuntu 10.04 with csound-float 5.13.0 January 2011 and QuteCsound svn rev 805 with "Widgets are an independent window" ON.


/*
Mouse Bass
----------
This csd was originally written for use by someone who only had the use of a head-mouse for music performance.
The notes of the chromatic scale are arranged in coloured boxes according to the circle of fifths as this is perhaps the arrangement that is most useful to a bass guitarist.
If the mouse enters one of the boxes the note indicated by its label is played. If the mouse leaves the box the note is stopped (with a short release segment).
No clicking is required enabling better timing in performance. The GUI window needs to be in focus for this to work.
The mouse relative position is given by the channels _MouseRelX and _MouseRelY.
 
If the windows need to be resized, for example to accomodate use on a netbook, it is mandatory to manually update the values of boxes dimensions and positions in the csd file.

Professional head mouse or iris tracking software can be very expensive and requires practice. 
iNavigate is a free option for Mac OS 10.5 if the user wants to experiment with this approach.
*/


;Notes on modifications from original csd:
;	No automatic rescale
;	No use of audio sample


;Depending on your platform and distribution, you might need to enable displays using the --displays command line flag.
;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


instr	1
	;Boxes dimensions
	iwidth	=	100
	iheight	=	100

	;Boxes positions
	ix1		=	350	;C box
	iy1		=	50

	ix2		=	490	;G box
	iy2		=	110

	ix3		=	610	;D box
	iy3		=	220

	ix4		=	650	;A box
	iy4		=	350

	ix5		=	610	;E box
	iy5		=	480

	ix6		=	490	;B box
	iy6		=	600

	ix7		=	350	;Gb box
	iy7		=	650

	ix8		=	220	;Db box
	iy8		=	600

	ix9		=	90	;Ab box
	iy9		=	480

	ix10		=	50	;Eb box
	iy10		=	350

	ix11		=	90	;Bb box
	iy11		=	220

	ix12		=	220	;F box
	iy12		=	110

	krelx	invalue	"_MouseRelX"
	krely	invalue	"_MouseRelY"

;DEFINE A MACRO FOR DETECTION OF MOUSE WITHIN EACH BOX - INPUTS FOR NUMBER AND PITCH (PCH FORMAT)
#define	NOTE_BOX_DETECT(N'PCH)
	#
	kinside$N	init	0
	if (ix$N <= krelx && krelx <= ix$N+iwidth && iy$N <= krely && krely <= iy$N+iheight) then
		kinside$N	= 1
	else
		kinside$N	= 0
	endif

	ktrig$N	changed	kinside$N				;CREATE A TRIGGER (MOMENTARY '1') IF MOUSE ENTERS OR LEAVES THIS BOX
	if	ktrig$N=1	then						;IF MOUSE HAS JUST ENTERED OR LEFT THIS BOX...
		if	kinside$N=1	then				;IF MOUSE HAS JUST ENTERED THIS BOX...
			event	"i", 2, 0, 5, $PCH		;CREATE A 5 SECOND NOTE EVENT FOR INSTR 2. PASS PITCH VIA p4
		elseif	kinside$N=0	then			;OR ELSE IF MOUSE HAS JUST LEFT THIS BOX 
			turnoff2	2, 0, 1				;TURNOFF INSTRUMENT 2
		endif							;END OF CONDITIONAL BRANCHING
	endif								;END OF CONDITIONAL BRANCHING
	#

	;EXECUTE MACRO FOR EACH BOX...
	$NOTE_BOX_DETECT(1'8.00)
	$NOTE_BOX_DETECT(2'7.07)
	$NOTE_BOX_DETECT(3'8.02)
	$NOTE_BOX_DETECT(4'7.09)
	$NOTE_BOX_DETECT(5'8.04)
	$NOTE_BOX_DETECT(6'7.11)
	$NOTE_BOX_DETECT(7'8.06)
	$NOTE_BOX_DETECT(8'8.01)
	$NOTE_BOX_DETECT(9'7.08)
	$NOTE_BOX_DETECT(10'8.03)
	$NOTE_BOX_DETECT(11'7.10)
	$NOTE_BOX_DETECT(12'7.05)
endin

instr	2	;BASS
	aenv	linsegr	1,0.05,0	;AMPLITUDE ENVELOPE (BASICALLY JUST THE RELEASE STAGE)
	
	icps	= cpspch(p4)

	k1	linseg	0.55, .2, 0.2, 0, 0.2
	k2	linseg	4, .2, 2, 0, 2

	a2	oscil	k2, icps/2, 1
	a1	oscil	k1, icps/2*a2, 1
	
		outs		a1*aenv, a1*aenv
endin
</CsInstruments>
<CsScore>
f 1 0 1024 10 1		;sin table

;INSTR | START | DURATION
i 1		0	   3600	;MOUSE POSITION DETECTION, PLAYS A NOTE FOR 1 HOUR
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>645</x>
 <y>158</y>
 <width>789</width>
 <height>773</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>21</x>
  <y>47</y>
  <width>189</width>
  <height>51</height>
  <uuid>{8696498c-ea5a-4002-80e2-b73942e10bb0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mouse Bass</label>
  <alignment>left</alignment>
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
  <x>350</x>
  <y>50</y>
  <width>100</width>
  <height>100</height>
  <uuid>{4ff1845d-670e-4f5a-ad22-f0da34a0c44b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>C</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>490</x>
  <y>110</y>
  <width>100</width>
  <height>100</height>
  <uuid>{b37c8e33-54bb-4f53-83b5-6b83cc09e6ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>G</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>200</g>
   <b>55</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>610</x>
  <y>220</y>
  <width>100</width>
  <height>100</height>
  <uuid>{2fc81349-9dc1-4bd5-894b-ec2bfbd045e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>D</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>200</r>
   <g>255</g>
   <b>200</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>650</x>
  <y>350</y>
  <width>100</width>
  <height>100</height>
  <uuid>{cfab6bf8-f61d-4c40-9e90-ae2ad4825b4b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>A</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
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
  <x>610</x>
  <y>480</y>
  <width>100</width>
  <height>100</height>
  <uuid>{2bdfd76e-2158-46b1-83f9-03daab95bb48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>E</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>105</r>
   <g>200</g>
   <b>55</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>490</x>
  <y>600</y>
  <width>100</width>
  <height>100</height>
  <uuid>{1b83334e-ab1b-4eb0-998c-0bda40dd8478}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>B</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>50</g>
   <b>50</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>350</x>
  <y>650</y>
  <width>100</width>
  <height>100</height>
  <uuid>{fddbed6f-a446-4fbe-89fc-c9c644a5667b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Gb</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
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
  <x>220</x>
  <y>600</y>
  <width>100</width>
  <height>100</height>
  <uuid>{5ddf806c-247b-4151-bcfd-42a82748e7bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Db</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>55</r>
   <g>200</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>90</x>
  <y>480</y>
  <width>100</width>
  <height>100</height>
  <uuid>{f282639e-421b-4715-9c45-99f21b1f84f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Ab</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>200</g>
   <b>55</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>50</x>
  <y>350</y>
  <width>100</width>
  <height>100</height>
  <uuid>{1f07ff1d-0a47-40af-9185-de05106ee1af}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Eb</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
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
  <x>90</x>
  <y>220</y>
  <width>100</width>
  <height>100</height>
  <uuid>{7252cfc2-94e0-4989-8477-03aeb8979ab4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Bb</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>200</g>
   <b>100</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>220</x>
  <y>110</y>
  <width>100</width>
  <height>100</height>
  <uuid>{27944727-f486-4946-9ec7-372383e51123}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>F</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>24</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>150</r>
   <g>0</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_MouseRelX</objectName>
  <x>122</x>
  <y>105</y>
  <width>59</width>
  <height>25</height>
  <uuid>{eac032fa-9eec-4268-81a6-f6eb875d9517}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>_MouseRelY</objectName>
  <x>122</x>
  <y>133</y>
  <width>59</width>
  <height>25</height>
  <uuid>{e527159b-e21a-4f35-b4e3-525b6d4cf7b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>363.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>105</y>
  <width>120</width>
  <height>25</height>
  <uuid>{55616170-a887-428f-ac65-3e612102334f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mouse Relative X</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <x>2</x>
  <y>133</y>
  <width>120</width>
  <height>25</height>
  <uuid>{93bd69f1-40e2-4832-a787-a01f4a9f7de5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Mouse Relative Y</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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

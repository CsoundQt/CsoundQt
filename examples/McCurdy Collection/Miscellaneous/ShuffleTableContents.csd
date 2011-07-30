;Written by Iain McCurdy, 2010

;Modified for QuteCsound by René, February 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)
0dbfs	= 1		;MAXIMUM AMPLITUDE REGARDLESS OF BIT DEPTH


giTable	ftgen	0,0,-12,-2, 8.00, 8.01, 8.02, 8.03, 8.04, 8.05, 8.06, 8.07, 8.08, 8.09, 8.10, 8.11	;CHROMATIC SCALE - 12 ITEMS - NEGATIVE TABLE SIZE PERMITS THE USE OF NON-ZERO TABLE SIZE
gisine	ftgen	0, 0, 4096, 10, 1														;A SINE WAVE


instr	1	;SHUFFLE TABLE CONTENTS
	iNumItems		=		ftlen(giTable)									;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	iIndices		ftgen	0,0,-12,-2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12		;TABLE OF INDEX VALUES (+1) - SHOULD CORRESPOND TO THE NUMBER OF ITEMS IN THE ORIGINAL TABLE
	iIndicesBuffer	ftgen	0,0,-12,-2, 0									;BUFFER TABLE FOR JUMBLED UP INDICES
	iTableBuffer	ftgen	0,0,-12,-2, 0									;BUFFER TABLE INITIALLY CONSISTING OF ZEROES
	kcount 		init 	1											;INITIALISE COUNTER

	begin:															;LABEL
	kfn			random	0,iNumItems									;RANDOM TABLE ITEM INDEX
	kfn			=		int(kfn)										;CONVERT TO INTEGER (THIS STEP IS NOT ACTUALLY REQUIRED)
	krandval		table	kfn, iIndices									;READ THE VALUE AT THE RANDOMLY CHOSEN INDEX LOCATION
	;CHECK IF RANDOMLY CHOSEN ITEM HAS ALREADY BEEN CHOSEN AND INSERTED INTO NEW TABLE
	kcheckcount	=	1												;COUNTER USED THROUGHOUT CHECKING PROCESS

	checkbegin:														;LABEL - START OF CHECKING PROCESS
	kcheckval		table	kcheckcount-1, iIndicesBuffer						;READ VALUE FROM TABLE ACCORDING TO CURRENT checkcount CYCLE 
	if (kcheckval=krandval)	kgoto	begin								;IF VALUE ALREADY EXISTS, REDO THE RANDOMIZATION PROCESS
		kcheckcount	=	kcheckcount + 1								;INCREMENT CHECK COUNTER
	if (kcheckcount<kcount)	kgoto	checkbegin							;UNTIL ALL VALUES HAVE BEEN TESTED REPEAT CHECK FOR NEXT VALUE
			tablew	krandval, kcount-1, iIndicesBuffer						;ONCE VALUE HAS BEEN VERIFIED WRITE TO TABLE 
	kcount	=		kcount + 1										;INCREMENT MAIN COUNTER
	if (kcount <= iNumItems) goto begin									;UNTIL TABLE IS FILLED REPEAT CYCLE
	
	;CREATE NEW TABLE IN THE BUFFER TABLE ACCORDING TO NEW ARRANGEMENT OF INDICES
	kcount	=	1													;SET COUNTER TO '1'

	begin2:															;BEGINNING OF LOOP LABEL
	kndx		table	kcount-1, iIndicesBuffer								;READ INDEX VALUE FROM TABLE OF INDICES BUFFER
	kval		table	kndx-1, giTable									;READ ITEM VALUE AT CURRENT INDEX LOCATION
			tablew	kval, kcount-1, iTableBuffer							;WRITE READ ITEM INTO TABLE BUFFER
	kcount	=		kcount + 1										;INCREMENT COUNTER
	if (kcount <= iNumItems) goto begin2									;UNTIL TABLE IS COMPLETELY WRITTEN REPEAT CYCLE
			
			tablecopy	giTable, iTableBuffer 								;REPLACE ORIGINAL TABLE WITH BUFFER (SHUFFLED) TABLE
			event	"i", 2, 0, 0.1										;PRINT TABLE VALUES
			turnoff													;WHEN DONE, TURN OFF THIS INSTRUMENT
endin

instr	2	;PRINT TABLE VALUES TO COMMAND LINE AND BOXES
	iNumItems	=		ftlen(giTable)										;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
			prints	"\\n"											;NEWLINE
	icount	init		1												;INITIALIZE COUNTER

	BEGIN:															;LABEL
	ival		table	icount-1, giTable       								;READ VALUE FROM TABLE
			print	ival												;PRINT READ VALUE
	icount	=		icount + 1										;INCREMENT COUNTER
	if	icount<=iNumItems	goto	BEGIN									;CHECK IF WE ARE AT THE LAST VALUE OF TABLE, IF NOT, REPEAT PRINT TASK

	;GUI UPDATE
	;CREATE A MACRO TO REDUCE CODE REPETITION
#define	FLPRINT(N)
	#
	ipch$N	table		$N-1, giTable									;READ PITCH VALUES FROM TABLE
			outvalue		"Item$N", ipch$N								;WRITE PITCH VALUES TO TEXT BOXES
	#
	;EXECUTE MACRO MULTIPLE TIMES
	$FLPRINT(1)
	$FLPRINT(2)
	$FLPRINT(3)
	$FLPRINT(4)
	$FLPRINT(5)
	$FLPRINT(6)
	$FLPRINT(7)
	$FLPRINT(8)
	$FLPRINT(9)
	$FLPRINT(10)
	$FLPRINT(11)
	$FLPRINT(12)
	
	turnoff															;TURN THIS INSTRUMENT OFF
endin

instr	3	;TRIGGER NOTES IN SOUND GENERATING INSTRUMENT
	iNumItems	=		ftlen(giTable)										;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	icount	init		1
	igap		init		0.2
	iwhen	init		0	

	PLAYBEGIN:
	ipch		table	icount-1, giTable									;READ PITCH (pch FORMAT) FROM TABLE ACCORDING TO WHERE WE ARE IN THE SEQUENCE
			event_i	"i",4, iwhen, 0.6, ipch								;CREATE A NOTE EVENT TO BE PLAYED BY INSTR 3
	iwhen	=		iwhen + igap										;CREATE THE TIME THE NEXT NOTE WILL BE PLAYED
	igap		=		igap * 1.05										;GAP BETWEEN NOTES INCREASES AS WE PROGRESS RESULT IN A RALLENTANDO (SLOWING DOWN) AS THE SEQUENCE IS PLAYED
	icount	= 		icount + 1
	if icount<=iNumItems goto PLAYBEGIN									;CHECK IF WE ARE AT THE LAST VALUE OF TABLE, IF NOT, REPEAT PRINT TASK

	turnoff															;TURN THIS INSTRUMENT OFF
endin

instr	4	;SOUND GENERATING INSTRUMENT
	aenv		line		0.2, p3, 0										;CREATE AN AMPLITUDE ENVELOPE
	a1		oscili	aenv, cpspch(p4), gisine								;GENERATE AN AUDIO SIGNAL (PITCH RECEIVED FROM INSTR 2 VIA p4)
			outs		a1, a1											;SEND AUDIO TO OUTPUTS
endin

instr	5	;PERFORM RETROGRADE
	iTableBuffer	ftgen	0,0,-12,-2, 0									;BUFFER TABLE INITIALLY CONSISTING OF ZEROES
	iNumItems		=		ftlen(giTable)									;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	iTableBuffer	ftgen	0,0,-iNumItems,-2, 0							;BUFFER TABLE INITIALLY CONSISTING OF ZEROES
	kcount 		init 	1											;INITIALISE COUNTER

	begin:															;LABEL
	kval		table	iNumItems - kcount, giTable
			tablew	kval, kcount-1, iTableBuffer
	kcount	=		kcount + 1										;INCREMENT MAIN COUNTER
	if (kcount <= iNumItems) goto begin									;UNTIL TABLE IS FILLED REPEAT CYCLE
			
			tablecopy	giTable, iTableBuffer 								;REPLACE ORIGINAL TABLE WITH BUFFER (SHUFFLED) TABLE
			event	"i", 2, 0, 0.1										;PRINT TABLE VALUES
			turnoff													;WHEN DONE, TURN OFF THIS INSTRUMENT
endin
</CsInstruments>
<CsScore>
i 2 0    0.001
f 0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>707</x>
 <y>277</y>
 <width>834</width>
 <height>389</height>
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
  <width>830</width>
  <height>387</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Shuffle Table Contents</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>221</x>
  <y>42</y>
  <width>120</width>
  <height>30</height>
  <uuid>{55273d97-d39a-441c-8da6-87ea139493b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Shuffle</text>
  <image>/</image>
  <eventLine>i 1 0 0.1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1</x>
  <y>82</y>
  <width>69</width>
  <height>30</height>
  <uuid>{5cde19f3-b356-4945-9c8b-43dd67c604dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Items:</label>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
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
  <objectName>Item1</objectName>
  <x>70</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{073ad371-9227-46fa-a005-ac10a210db79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.010</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>141</y>
  <width>822</width>
  <height>245</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This example shuffles the contents of a function table in a fashion similar to shuffling a deck of cards. The table's contents in this example are the notes of a chromatic scale in pch format. Each time the 'Shuffle' button is clicked the order of these twelve items is changed. The new table is printed to the terminal and to the display boxes and can be played as a note row by clicking 'Play'. Table shuffling is achieved by generating a random number to be used as a table index. The value at this table index is read. Values are written into a buffer table but before this is done a checking procedure is executed that checks whether this value has already been chosen (this ensures that each item occurs in the new table only once). Once a value has been accepted and written into the buffer table. The process is repeated to find the next value for the buffer table. To carry out the entire process a number of k-rate loops are employed with counter varibles being used to check when the various iterative procedures are complete. To allow the use of items of the same value in the table the process is actually carried out on a table of indices (1, 2, 3...) so that the checking procedure described above can still be carried out. A buffer table of the new arrangement of items is created from this table of jumbled indices and finally written over the original table. As an additional feature the user can perform a retrograde on the table's contents which reverses their order.</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Item2</objectName>
  <x>130</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1c7548d5-44d5-4f66-899b-e6cdbee7808a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.040</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Item3</objectName>
  <x>190</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0091d7b0-d91e-4d1f-9729-a96612841508}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.020</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Item4</objectName>
  <x>250</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{538ce482-2100-4467-81d6-475e81c614a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.100</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Item5</objectName>
  <x>310</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{850e956b-d5e3-4551-b9f2-6a49c59996e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.070</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Item6</objectName>
  <x>370</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9095fb4d-a1f0-4c04-afd1-918857f5a163}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.090</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Item7</objectName>
  <x>430</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{7dc921c9-4410-4063-95ce-524870d15c01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.110</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Item8</objectName>
  <x>490</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{e0252740-6bed-46a0-9c35-5b01091bbcbb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.050</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Item9</objectName>
  <x>549</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{d73e14d2-c9ee-4edd-b45f-ff77dbcbd33f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.000</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Item10</objectName>
  <x>609</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{8eaf0662-173e-44ec-8e9e-fabc5fcec6e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.080</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Item11</objectName>
  <x>669</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{bdea0e8f-05c5-410b-9c44-cf2cce219735}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.030</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>Item12</objectName>
  <x>729</x>
  <y>82</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a89842bb-482c-4739-8fa9-067021b6555d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8.060</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>344</x>
  <y>42</y>
  <width>120</width>
  <height>30</height>
  <uuid>{1e59b306-95dc-4794-971f-317b107c22bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Retrograde</text>
  <image>/</image>
  <eventLine>i 5 0 0.1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>467</x>
  <y>42</y>
  <width>120</width>
  <height>30</height>
  <uuid>{7a957253-a2ff-4e19-a6f5-f58e166dfcd7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine>i 3 0 0.1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>70</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{3c66970d-2b76-4403-8782-b86055c3fa53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>130</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{27242e29-5816-4789-b845-8fc1be9dac45}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>190</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{1412f652-df14-4c1a-97ed-ab9c5cb7f574}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>250</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{9812161d-faed-4110-89da-0af03d8846e2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4
</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>310</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{43f3b1df-f1de-41df-b371-7bf52ca4daa9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>5</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>370</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{248cebae-09e5-4597-ba15-c0a2b7860884}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>6</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>430</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4295e75d-84bd-4fb0-8328-be292aaf11c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>7</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>490</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{22f9ca83-afe5-4f81-b314-1ef894a8625d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>8</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>549</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{4666b475-bc99-405a-af39-dbb7c1f93259}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>9</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>608</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{a9cdd246-ffd5-4966-9cfd-a3ce3d1de5e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>10</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>669</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{c5e342cd-b658-4e1c-9fc1-59de569db6b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>11</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
  <x>729</x>
  <y>112</y>
  <width>60</width>
  <height>30</height>
  <uuid>{0fae269e-209e-4dbd-9dee-c0c419fc0f41}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>12</label>
  <alignment>center</alignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

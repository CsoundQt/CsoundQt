;Written by Iain McCurdy, 2008

;Modified for QuteCsound by René, February 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817
;	AS OF WRITING THE OPCODE 'DATE' NOT WORK PROPERLY WITH CSOUND FLOAT

;Notes on modifications from original csd:


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 16		;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)


instr	1	;AUTO UPDATE - TRIGGERS INSTR 2
	ktrig	metro		10
			schedkwhen	ktrig, 0, 0, 2, 0, 0.01
endin

instr	2	
	idate_secs	date								;READ DATE SINCE 1ST JANUARY 1970 IN SECONDS
				outvalue	"Date", idate_secs			;SEND 'date' READING TO VALUE BOX
	Sdate		dates							;READ DATE SINCE 1ST JANUARY 1970 AS A STRING
				outvalue	"Dates", Sdate				;SEND 'dates' STRING TO TEXT BOX
endin
</CsInstruments>
<CsScore>
f 0 3600

i  2 0 0.01	
</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>73</x>
 <y>204</y>
 <width>495</width>
 <height>269</height>
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
  <width>493</width>
  <height>267</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>date, dates</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>6</x>
  <y>22</y>
  <width>484</width>
  <height>161</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>----------------------------------------------------------------------------------------------------------------------
The 'date' opcode outputs at i-rate the number of seconds since January 1st 1970 (the beginning of the current epoch.)
The 'dates' opcode parses this information to output the same value as a string giving day, month, date, time (hours, minutes and seconds) and year. In the case of 'dates' the user can pass the opcode an explicit number of seconds since
1970 or allow it to read from the computer's system clock.
NB, AS OF WRITING 'DATE' DOES NOT WORK PROPERLY WITH CSOUND FLOAT.</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>9</x>
  <y>190</y>
  <width>110</width>
  <height>30</height>
  <uuid>{119eae69-f0a5-4bdd-bd99-6df3318bc455}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Manual Update</text>
  <image>/</image>
  <eventLine>i 2 0 0.01</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>9</x>
  <y>228</y>
  <width>110</width>
  <height>30</height>
  <uuid>{4e4e20c5-d5a2-471f-8322-323282a5651c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>  Auto Update</text>
  <image>/</image>
  <eventLine>i 1 0  -1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>Dates</objectName>
  <x>205</x>
  <y>225</y>
  <width>150</width>
  <height>29</height>
  <uuid>{cb2d0433-76ef-4261-b714-c7da0feed8a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Thu Mar  3 11:18:51 2011
</label>
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
   <r>240</r>
   <g>235</g>
   <b>226</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>122</x>
  <y>193</y>
  <width>80</width>
  <height>25</height>
  <uuid>{fa906a98-8efd-4449-b7a9-719e70220682}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Date (secs):</label>
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
  <objectName>Date</objectName>
  <x>205</x>
  <y>194</y>
  <width>179</width>
  <height>28</height>
  <uuid>{2a686a57-e646-4353-a8b8-9d32d48997dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1299147520.000</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>132</x>
  <y>227</y>
  <width>70</width>
  <height>25</height>
  <uuid>{e2f36491-ce20-4716-ab07-8c19cc859db7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Date:</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

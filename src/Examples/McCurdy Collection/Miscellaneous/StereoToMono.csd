;Written by Iain McCurdy, 2010

;Modified for QuteCsound by René, February 2011
;Tested on Ubuntu 10.04 with csound-float 5.13.0 and QuteCsound svn rev 817

;Notes on modifications from original csd:
;	Add Browser for audio file and use of FilePlay2a udo


;my flags on Ubuntu: -odac -b1024 -B2048 -+rtaudio=alsa -+rtmidi=null -m0
<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr 		= 44100	;SAMPLE RATE
ksmps 	= 100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls	= 2		;NUMBER OF CHANNELS (2=STEREO)


opcode FilePlay2a, aa, Skoo		; Credit to Joachim Heintz
	;gives stereo output regardless your soundfile is mono or stereo
	Sfil, kspeed, iskip, iloop	xin
	ichn		filenchnls	Sfil
	if ichn == 1 then
		outvalue	"_Browse", "Please select a stereo audio file"
	else
		aL, aR	diskin2	Sfil, kspeed, iskip, iloop
	endif
		xout		aL, aR
endop


instr	1
	gSfile	invalue	"_Browse"

	ilen		filelen	gSfile								;DERIVE LENGTH OF INPUT SOUND FILE
			event_i	"i", 2, 0, ilen						;TRIGGER INSTRUMENT 2
endin
	
instr	2
	asigL, asigR	FilePlay2a	gSfile, 1, 0, 1				;GENERATE 2 AUDIO SIGNALS FROM A STEREO SOUND FILE

	Sfile_Left	strcat		gSfile, "_Left.wav"
	Sfile_Right	strcat		gSfile, "_Right.wav"
				fout			Sfile_Left,  8, asigL			;LEFT CHANNEL IS OUTPUT TO FILE
				fout			Sfile_Right, 8, asigR			;RIGHT CHANNEL IS OUTPUT TO FILE
				outs			asigL, asigR					;REAL TIME AUDIO OUTPUT - USEFUL FOR MONITORING THE PROGRESS OF THE CONVERSION PROCESS
endin
</CsInstruments>
<CsScore>
f 0 3600
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
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
  <width>638</width>
  <height>230</height>
  <uuid>{aa607456-d368-4d59-8497-d16d608404c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label> CONVERT A STEREO FILE TO TWO MONO FILES IN REALTIME </label>
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
  <x>9</x>
  <y>101</y>
  <width>627</width>
  <height>128</height>
  <uuid>{e41f02b8-6ad4-46dc-805c-0b2eeafbd476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>---------------------------------------------------------------------------------------------------------------------------------------------------------
This example takes a stereo file input and writes a 2 mono files, one for each channel, to disk.
The advantage of this method over the offline method is that both channels can be output to separate files in one go. The disadvantage is that it must be done in real-time.
This example could easily be adapted to merge two mono files to a single stereo output. Conversion of files with more than two channels are also possible.</label>
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
  <objectName>_Browse</objectName>
  <x>11</x>
  <y>62</y>
  <width>170</width>
  <height>30</height>
  <uuid>{b9431a61-61f7-432b-bf6f-c47ddc7f9050}</uuid>
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
  <objectName>_Browse</objectName>
  <x>182</x>
  <y>63</y>
  <width>330</width>
  <height>28</height>
  <uuid>{68b5f90b-b78e-4581-b434-232db5f4c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>808loop.wav</label>
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
  <x>11</x>
  <y>41</y>
  <width>150</width>
  <height>30</height>
  <uuid>{936f6eb0-5225-4bd7-a5fe-a49df1c9c5ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Audio File</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName/>
  <x>525</x>
  <y>62</y>
  <width>100</width>
  <height>30</height>
  <uuid>{62b97053-e7ad-4193-99be-3fd837581838}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Convert</text>
  <image>/</image>
  <eventLine>i 1 0 0.01</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="913" y="162" width="655" height="346" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

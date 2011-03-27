<CsoundSynthesizer>
<CsOptions>
-+max_str_len=10000
</CsOptions>
<CsInstruments>

;example by joachim heintz

sr = 44100
ksmps = 16
nchnls = 2
0dbfs = 1

;Make sure that you have NOT checked "Ignore CsOptions" in the Configuration Dialog. 
;Otherwise the extension of the maximal string length (-+max_str_len=10000) will be ignored and your file list will probably be cutted or confused.

		seed		0

  opcode StrayGetEl, ii, Sijj
;returns the startindex and the endindex (= the first space after the element) for ielindex in String. if startindex returns -1, the element has not been found
Stray, ielindx, isepA, isepB xin
;;DEFINE THE SEPERATORS
isep1		=		(isepA == -1 ? 32 : isepA)
isep2		=		(isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
Sep1		sprintf	"%c", isep1
Sep2		sprintf	"%c", isep2
;;INITIALIZE SOME PARAMETERS
ilen		strlen		Stray
istartsel	=		-1; startindex for searched element
iendsel	=		-1; endindex for searched element
iel		=		0; actual number of element while searching
iwarleer	=		1
indx		=		0
 if ilen == 0 igoto end ;don't go into the loop if Stray is empty
loop:
Snext		strsub		Stray, indx, indx+1; next sign
isep1p		strcmp		Snext, Sep1; returns 0 if Snext is sep1
isep2p		strcmp		Snext, Sep2; 0 if Snext is sep2
;;NEXT SIGN IS NOT SEP1 NOR SEP2
if isep1p != 0 && isep2p != 0 then
 if iwarleer == 1 then; first character after a seperator 
  if iel == ielindx then; if searched element index
istartsel	=		indx; set it
iwarleer	=		0
  else 			;if not searched element index
iel		=		iel+1; increase it
iwarleer	=		0; log that it's not a seperator 
  endif 
 endif 
;;NEXT SIGN IS SEP1 OR SEP2
else 
 if istartsel > -1 then; if this is first selector after searched element
iendsel	=		indx; set iendsel
		igoto		end ;break
 else	
iwarleer	=		1
 endif 
endif
		loop_lt	indx, 1, ilen, loop 
end: 		xout		istartsel, iendsel
  endop 

  opcode StrayLen, i, Sjj
;returns the number of elements in Stray. elements are defined by two seperators as ASCII coded characters: isep1 defaults to 32 (= space), isep2 defaults to 9 (= tab). if just one seperator is used, isep2 equals isep1
Stray, isepA, isepB xin
;;DEFINE THE SEPERATORS
isep1		=		(isepA == -1 ? 32 : isepA)
isep2		=		(isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
Sep1		sprintf	"%c", isep1
Sep2		sprintf	"%c", isep2
;;INITIALIZE SOME PARAMETERS
ilen		strlen		Stray
icount		=		0; number of elements
iwarsep	=		1
indx		=		0
 if ilen == 0 igoto end ;don't go into the loop if String is empty
loop:
Snext		strsub		Stray, indx, indx+1; next sign
isep1p		strcmp		Snext, Sep1; returns 0 if Snext is sep1
isep2p		strcmp		Snext, Sep2; 0 if Snext is sep2
 if isep1p == 0 || isep2p == 0 then; if sep1 or sep2
iwarsep	=		1; tell the log so
 else 				; if not 
  if iwarsep == 1 then	; and has been sep1 or sep2 before
icount		=		icount + 1; increase counter
iwarsep	=		0; and tell you are ot sep1 nor sep2 
  endif 
 endif	
		loop_lt	indx, 1, ilen, loop 
end: 		xout		icount
  endop 

  opcode	ShowLED_a, 0, Sakik
;Shows an audio signal in an outvalue channel.
;You can choose to show the value in dB or in raw amplitudes.
;
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;idb: 1 = show in dB, 0 = show in raw amplitudes (both in the range 0-1)
;idbrange: if idb=1: how many db-steps are shown (e.g. if 36 you will not see anything from a signal below -36 dB)
Soutchan, asig, ktrig, idb, kdbrange	xin
kdispval	max_k	asig, ktrig, 1
	if idb != 0 then
kdb 		= 		dbfsamp(kdispval)
kval 		= 		(kdbrange + kdb) / kdbrange
	else
kval		=		kdispval
	endif
	if ktrig == 1 then
		outvalue	Soutchan, kval
	endif
  endop


  opcode ShowOver_a, 0, Sakk
;Shows if the incoming audio signal was more than 1 and stays there for some time
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;khold: time in seconds to "hold the red light"
Soutchan, asig, ktrig, khold	xin
kon		init		0
ktim		times
kstart		init		0
kend		init		0
khold		=		(khold < .01 ? .01 : khold); avoiding too short hold times
kmax		max_k		asig, ktrig, 1
	if kon == 0 && kmax > 1 && ktrig == 1 then
kstart		=		ktim
kend		=		kstart + khold
		outvalue	Soutchan, kmax
kon		=		1
	endif
	if kon == 1 && ktim > kend && ktrig == 1 then
		outvalue	Soutchan, 0
kon		=		0
	endif
  endop

  opcode RandInts_i, i, ii
;random integer between ival1 and ival2 (both included)
ival1, ival2	xin
if ival1 < ival2 then
imin		=		ival1
imax		=		ival2
else
imin		=		ival2
imax		=		ival1
endif
imin		=		(imin < 0 ? imin-0.9999 : imin)
imax		=		(imax < 0 ? imax : imax+0.9999)
ires		random		imin, imax
		xout		int(ires)
  endop
  
  opcode FilePlay2, aa, Skii
;gives stereo output regardless your soundfile is mono or stereo
Sfil, kspeed, iskip, iloop	xin
ichn		filenchnls	Sfil
if ichn == 1 then
aL		diskin2	Sfil, kspeed, iskip, iloop
aR		=		aL
else
aL, aR		diskin2	Sfil, kspeed, iskip, iloop
endif
		xout		aL, aR
  endop

  opcode SelPlay, aa, Si
;selects either mp3in or FilePlay2, depending on the file suffix (mp3 file is expected as .mp3)
Sfil, iskip	xin
ipos		strrindex	Sfil, "."
Suf		strsub		Sfil, ipos
Suf		strlower	Suf
itest		strcmp		Suf, ".mp3"; 0 if mp3 file
 if itest == 0 then
aL, aR		mp3in		Sfil, iskip
 else
aL, aR		FilePlay2	Sfil, 1, iskip, 0
 endif
		xout		aL, aR
  endop
  

instr 1
   ;;get input from GUI
Sfiles		invalue	"_MBrowse"
kpaus		invalue	"paus"
kpaustim	invalue	"paustim"
kpaustimk	=		kpaustim * kr; paustim in k-cycles
kloop		invalue	"loop_play"; 1=loop
krandom	invalue	"random_play"
   ;;give play or pause status
gkplay		init		1
kchange	changed	kpaus
 if kchange == 1 && kpaus == 1 then
gkplay		=		(gkplay == 0 ? 1 : 0)
 endif
   ;;show all files in the GUI and link to a strset number
inumfils	StrayLen	Sfiles, 124
istrsetnum	=		1
Strshow	=		"Files loaded:\n"
showlist:
ist, ien	StrayGetEl	Sfiles, istrsetnum-1, 124
Sel		strsub		Sfiles, ist, ien
		strset		istrsetnum, Sel
Strshownew	sprintf	"%s%d: %s\n", Strshow, istrsetnum, Sel
Strshow	=		Strshownew		
		loop_lt	istrsetnum, 1, inumfils+1, showlist
		outvalue	"showfiles", Strshow
   ;;play files 
kcount		init		-1
ktimk		init		0
newfile:
icount		=		i(kcount)
icount		=		icount + 1
 if i(krandom) == 1 then; first, select one of the files
iwhich		RandInts_i	1, inumfils
 else
iwhich		=		icount+1
 endif
Splay		strget		iwhich; actual filename
ilen		filelen	Splay; get some infos about this file ...
ilenmin	=		int(ilen/60)
ilensec	=		int(ilen%60)
ilenms		=		frac(ilen) * 1000
Showplay	sprintf	"Selected File:\n%d\n '%s'\nDuration %02d:%02d:%03d (min:sec:ms)", \
				iwhich, Splay, ilenmin, ilensec, ilenms
		outvalue	"showplay", Showplay; ... and show it
		event_i	"i", 10, 0, ilen, iwhich, 0, ilen
 
ifilenk	=		ilen * kr; length of file in k-cycles
if gkplay == 0 then; stop the clock if pause button 
ktim		=		ktim
else; if no pause
 if ktimk >= ifilenk+kpaustimk then; if end of file plus pause time
ktimk		=		0; set time to zero
  if krandom == 1 then; go on if random play
kcount		=		-1
  elseif icount == inumfils-1 then; if no random and end has reached
   if kloop == 1 then; go back if loop
kcount		=		-1
   else 
 		turnoff; stop if no loop
   endif
  else ;increase counter if no random and not the last file
kcount		=		icount
  endif
 else
ktimk		=		ktimk+1
 endif		
endif
 if ktimk == 0 && gkplay == 1 then
 		reinit		newfile
 endif

endin

instr 10; plays one file
   ;input
ifil		=		p4
Sfile		strget		ifil; soundfile
iskip		=		p5; skiptime
ilen		=		p6
idbrange	=		48; range in dB shown by the LED's
ipeakhold	=		2; peak hold in seconds
kdb		invalue	"db"; output gain in dB
   ;volume
kmult		=		ampdbfs(kdb)
Sdb_disp	sprintfk	"%+.2f dB", kdb
		outvalue	"db_disp", Sdb_disp
   ;audio signal
aL, aR		SelPlay	Sfile, iskip
aL		=		aL * kmult
aR		=		aR * kmult
		outs 		aL, aR
   ;show audio output
kTrigDisp	metro		10
		ShowLED_a	"outL", aL, kTrigDisp, 1, idbrange
		ShowLED_a	"outR", aR, kTrigDisp, 1, idbrange
		ShowOver_a	"outLover", aL, kTrigDisp, ipeakhold
		ShowOver_a	"outRover", aR, kTrigDisp, ipeakhold
   ;;show remaining time
ktimout	timeinsts	; position in the soundfile in seconds
ktimout	=		ktimout + iskip
ktimrem	=		ilen - ktimout
		outvalue	"timrem", 1-ktimrem/ilen
ktr_min	=		int(ktimrem / 60) 
Smin		sprintfk	"%02d", ktr_min
ktr_sec	=		int(ktimrem % 60)
Ssec		sprintfk	"%02d", ktr_sec
ktr_ms		=		frac(ktimrem) * 1000
Sms		sprintfk	"%03d", ktr_ms
		outvalue	"tr_min", Smin
		outvalue	"tr_sec", Ssec
		outvalue	"tr_ms", Sms
   ;;pause and resume
 if gkplay == 0 then
 		event		"i", 100, 0, -1, ilen, ifil, ktimout
 		turnoff
 endif
endin

instr 100; activated if there is a pause
ifildur	=		p4
ifil		=		p5
Sfile		strget		ifil
iskip		=		p6
irestdur	=		ifildur - iskip
 if gkplay == 1 then
 		event		"i", 10, 0, irestdur, ifil, iskip, ifildur; calls instr 10 back
 		turnoff
 endif

endin

</CsInstruments>
<CsScore>
i 1 0 36000
e
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>296</x>
 <y>52</y>
 <width>621</width>
 <height>686</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBController">
  <objectName>outL</objectName>
  <x>26</x>
  <y>574</y>
  <width>250</width>
  <height>28</height>
  <uuid>{5cb20b0f-2273-489a-9e98-216631459a89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out1_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-0.03186003</xValue>
  <yValue>0.57894700</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>outLover</objectName>
  <x>273</x>
  <y>574</y>
  <width>21</width>
  <height>28</height>
  <uuid>{6862fd14-52ec-4329-8b4e-d9efda34d9d4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>outLover</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>outR</objectName>
  <x>26</x>
  <y>608</y>
  <width>250</width>
  <height>28</height>
  <uuid>{eede1920-fe0c-4e2b-9af5-1eeb07ddf98e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-0.03186003</xValue>
  <yValue>1.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>outRover</objectName>
  <x>273</x>
  <y>608</y>
  <width>21</width>
  <height>28</height>
  <uuid>{d422a8a2-6667-4def-bb13-17d0a3381c40}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>outRover</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>db</objectName>
  <x>320</x>
  <y>609</y>
  <width>269</width>
  <height>30</height>
  <uuid>{a1a8191e-1dd3-4dbe-83b0-7bd516f91b7c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>-18.00000000</minimum>
  <maximum>18.00000000</maximum>
  <value>-5.55390335</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>db_disp</objectName>
  <x>447</x>
  <y>572</y>
  <width>98</width>
  <height>31</height>
  <uuid>{f05a2401-be56-46c9-b44d-6704ebc871a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-8.50 dB</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <x>357</x>
  <y>572</y>
  <width>88</width>
  <height>30</height>
  <uuid>{7bde5c38-b6eb-45b4-9fb6-b68ae16da1e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Volume</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <x>28</x>
  <y>655</y>
  <width>116</width>
  <height>47</height>
  <uuid>{da0c8302-0211-44af-adb7-35db0b9d54a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Time Remaining</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>timrem</objectName>
  <x>150</x>
  <y>663</y>
  <width>292</width>
  <height>37</height>
  <uuid>{62f0976b-9cb8-4f19-b19f-e819a40ffa4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>vert23</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.99997604</xValue>
  <yValue>0.13513500</yValue>
  <type>llif</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>58</r>
   <g>65</g>
   <b>151</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>tr_min</objectName>
  <x>453</x>
  <y>676</y>
  <width>37</width>
  <height>28</height>
  <uuid>{c7eaaf0e-571b-4313-87d1-99fc747442f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>00</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <objectName>tr_sec</objectName>
  <x>500</x>
  <y>676</y>
  <width>35</width>
  <height>29</height>
  <uuid>{97598afc-df27-4a7d-8f70-97de8aabc11e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>00</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <x>488</x>
  <y>676</y>
  <width>14</width>
  <height>27</height>
  <uuid>{5c00b36e-0362-4554-a837-166e103583b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <objectName>tr_ms</objectName>
  <x>546</x>
  <y>677</y>
  <width>44</width>
  <height>28</height>
  <uuid>{82dbfe22-ee79-4a10-960b-7f9385e85d2f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>000</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <x>533</x>
  <y>676</y>
  <width>14</width>
  <height>27</height>
  <uuid>{d4904448-c55a-4fb3-9604-5b2be43a7a99}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
  <x>453</x>
  <y>656</y>
  <width>39</width>
  <height>25</height>
  <uuid>{f75a8604-be7c-470e-8a8e-8f60732898ea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>min</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>499</x>
  <y>656</y>
  <width>39</width>
  <height>25</height>
  <uuid>{a5217f48-4cb0-4312-bb02-b432d224a0b5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>sec</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>548</x>
  <y>656</y>
  <width>39</width>
  <height>25</height>
  <uuid>{a952c3c8-1120-4c60-a2f4-6508ca777176}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>ms</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>23</x>
  <y>12</y>
  <width>546</width>
  <height>35</height>
  <uuid>{56f5d546-9596-431d-bc72-1df82721e5d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>JUKEBOX</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>22</fontsize>
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
  <x>23</x>
  <y>43</y>
  <width>546</width>
  <height>35</height>
  <uuid>{730fd758-a980-425a-83aa-b4189ae8b3c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Let Csound play a list of files</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>paustim</objectName>
  <x>166</x>
  <y>430</y>
  <width>43</width>
  <height>31</height>
  <uuid>{381e4952-cd44-4702-9a61-af843a38667b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <minimum>0</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>25</x>
  <y>430</y>
  <width>142</width>
  <height>32</height>
  <uuid>{87136530-bd70-4e4e-96f8-1e25d64f0d23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Make a pause of</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>207</x>
  <y>430</y>
  <width>323</width>
  <height>31</height>
  <uuid>{dc8ac6dc-8ca3-4bfe-93a5-1b8085663d25}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>seconds before each new file/track</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>random_play</objectName>
  <x>541</x>
  <y>399</y>
  <width>20</width>
  <height>20</height>
  <uuid>{bc4ddf65-040e-472e-bcb7-14cc9948c797}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>425</x>
  <y>394</y>
  <width>117</width>
  <height>29</height>
  <uuid>{fe676d54-cc7f-42a4-a4f7-507bf8d94880}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Random Play</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>showfiles</objectName>
  <x>26</x>
  <y>143</y>
  <width>549</width>
  <height>245</height>
  <uuid>{676a19b4-5671-4f8c-9687-75a4de70fba2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>loop_play</objectName>
  <x>404</x>
  <y>399</y>
  <width>20</width>
  <height>20</height>
  <uuid>{926529c2-1bfb-45a4-8a01-4f14ac52c72e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>328</x>
  <y>394</y>
  <width>77</width>
  <height>29</height>
  <uuid>{61de22f6-f0e1-4b2a-8ccd-274574b24947}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Loop Play</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>25</x>
  <y>394</y>
  <width>78</width>
  <height>29</height>
  <uuid>{161fb4a0-a186-4e82-9e59-e69868368e9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Stop</objectName>
  <x>239</x>
  <y>394</y>
  <width>80</width>
  <height>30</height>
  <uuid>{f2f3ba8e-7bd0-492d-88cb-f01c66486e03}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine>i 1 0 .1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>paus</objectName>
  <x>111</x>
  <y>394</y>
  <width>122</width>
  <height>29</height>
  <uuid>{82718941-23a6-4bc6-a74b-da0f6aa78951}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Pause/Resume</text>
  <image>/</image>
  <eventLine>i 3 0 .1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>showplay</objectName>
  <x>24</x>
  <y>466</y>
  <width>548</width>
  <height>92</height>
  <uuid>{09471f06-8c4d-4ba3-a277-23ff4a38a352}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_MBrowse</objectName>
  <x>24</x>
  <y>84</y>
  <width>448</width>
  <height>29</height>
  <uuid>{dcd7f769-c32b-4cc8-bc82-9848d5b36937}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
   <r>229</r>
   <g>229</g>
   <b>229</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_MBrowse</objectName>
  <x>471</x>
  <y>82</y>
  <width>100</width>
  <height>30</height>
  <uuid>{6d6f3649-5d94-4759-afc8-887cc1872c39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff|/Joachim/Materialien/SamplesKlangbearbeitung/BratscheStereo.aiff|/Joachim/Materialien/SamplesKlangbearbeitung/EineWelleMono.aiff|/Joachim/Materialien/SamplesKlangbearbeitung/EineWelleMono.mp3</stringvalue>
  <text>Select Files</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>24</x>
  <y>115</y>
  <width>548</width>
  <height>26</height>
  <uuid>{0caf8b77-7ebe-4f5d-b5a7-c49ec844c940}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>(MP3 files are possible if filenames end as .mp3 but durations may be wrong)</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
ioView background {43690, 43690, 32639}
ioMeter {26, 574} {250, 28} {0, 59904, 0} "outL" -0.031860 "out1_post" 0.578947 fill 1 0 mouse
ioMeter {273, 574} {21, 28} {50176, 3584, 3072} "outLover" 0.000000 "outLover" 0.000000 fill 1 0 mouse
ioMeter {26, 608} {250, 28} {0, 59904, 0} "outR" -0.031860 "out2_post" 1.000000 fill 1 0 mouse
ioMeter {273, 608} {21, 28} {50176, 3584, 3072} "outRover" 0.000000 "outRover" 0.000000 fill 1 0 mouse
ioSlider {320, 609} {269, 30} -18.000000 18.000000 -5.553903 db
ioText {447, 572} {98, 31} display 0.000000 0.00100 "db_disp" right "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder -8.50 dB
ioText {357, 572} {88, 30} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Volume
ioText {28, 655} {116, 47} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Time Remaining
ioMeter {150, 663} {292, 37} {14848, 16640, 38656} "timrem" 0.999976 "vert23" 0.135135 llif 1 0 mouse
ioText {453, 676} {37, 28} display 0.000000 0.00100 "tr_min" right "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 00
ioText {500, 676} {35, 29} display 0.000000 0.00100 "tr_sec" right "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 00
ioText {488, 676} {14, 27} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder :
ioText {546, 677} {44, 28} display 0.000000 0.00100 "tr_ms" right "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 000
ioText {533, 676} {14, 27} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder :
ioText {453, 656} {39, 25} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder min
ioText {499, 656} {39, 25} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder sec
ioText {548, 656} {39, 25} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder ms
ioText {23, 12} {546, 35} label 0.000000 0.00100 "" center "Lucida Grande" 22 {0, 0, 0} {58624, 58624, 58624} nobackground noborder JUKEBOX
ioText {23, 43} {546, 35} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Let Csound play a list of files
ioText {166, 430} {43, 31} editnum 2.000000 1.000000 "paustim" right "" 0 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 2.000000
ioText {25, 430} {142, 32} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Make a pause of
ioText {207, 430} {323, 31} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder seconds before each new file/track
ioCheckbox {541, 399} {20, 20} off random_play
ioText {456, 396} {96, 31} label 0.000000 0.00100 "" right "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Random Play
ioText {26, 143} {549, 245} display 0.000000 0.00100 "showfiles" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioCheckbox {404, 399} {20, 20} off loop_play
ioText {356, 397} {77, 29} label 0.000000 0.00100 "" right "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Loop Play
ioButton {25, 394} {78, 29} value 1.000000 "_Play" "Play" "/" 
ioButton {239, 394} {80, 30} value 1.000000 "_Stop" "Stop" "/" i 1 0 .1
ioButton {111, 394} {122, 29} value 1.000000 "paus" "Pause/Resume" "/" i 3 0 .1
ioText {24, 466} {548, 92} display 0.000000 0.00100 "showplay" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {24, 84} {448, 29} edit 0.000000 0.00100 "_MBrowse"  "Lucida Grande" 14 {0, 0, 0} {65280, 65280, 65280} falsenoborder 
ioButton {471, 82} {100, 30} value 1.000000 "_MBrowse" "Select Files" "/" 
ioText {24, 115} {548, 26} label 0.000000 0.00100 "" center "DejaVu Sans" 12 {0, 0, 0} {58624, 58624, 58624} nobackground noborder (MP3 files are possible if filenames end as .mp3 but durations may be wrong)
</MacGUI>

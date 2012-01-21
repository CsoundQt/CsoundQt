<CsoundSynthesizer>
<CsOptions>
-+max_str_len=10000
</CsOptions>
<CsInstruments>

;example by joachim heintz

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

;Make sure that you have NOT checked "Ignore CsOptions" in the Configuration Dialog. 
;Otherwise the extension of the maximal string length (-+max_str_len=10000) will be ignored and your file list will probably be cutted or confused.

;Please use Csound 5.16 or higher if you want to use mp3 files, as there are problems in previous versions

		seed		0
			
/*****************************************/		
/*************** FUNCTIONS ***************/		
/*****************************************/		

  opcode StrayGetEl, ii, Sijj
;returns the startindex and the endindex (= the first space after the element) for ielindex in String. if startindex returns -1, the element has not been found
Stray, ielindx, isepA, isepB xin
;;DEFINE THE SEPARATORS
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
 if iwarleer == 1 then; first character after a separator 
  if iel == ielindx then; if searched element index
istartsel	=		indx; set it
iwarleer	=		0
  else 			;if not searched element index
iel		=		iel+1; increase it
iwarleer	=		0; log that it's not a separator 
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
;returns the number of elements in Stray. elements are defined by two separators as ASCII coded characters: isep1 defaults to 32 (= space), isep2 defaults to 9 (= tab). if just one separator is used, isep2 equals isep1
Stray, isepA, isepB xin
;;DEFINE THE SEPARATORS
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
  
  opcode FilSuf, S, So
  ;returns the suffix of a filename or path, optional in lower case 
Sfil,ilow xin
ipos      strrindex Sfil, "."
Suf       strsub    Sfil, ipos+1
 if ilow != 0 then
Suf       strlower  Suf 
 endif
          xout      Suf
  endop  
  
  opcode FilLen, ii, SS
  ;returns the length of the file (usual audio or mp3)
  ;and whether it is a mp3 (imp3=1)
Sfil,Suf  xin
imp3      strcmp	Suf, "mp3"
 if imp3 == 0 then
ilen      mp3len    Sfil
 else
ilen		filelen	Sfil
 endif
          xout      ilen, imp3+1
  endop

  opcode SelPlay, aa, Sii
;selects either mp3in or FilePlay2, depending on the file suffix (imp3=1)
Sfil, iskip, imp3	xin
 if imp3 == 1 then
aL, aR		mp3in		Sfil, iskip
 else
aL, aR		FilePlay2	Sfil, 1, iskip, 0
 endif
		xout		aL, aR
  endop
  
  opcode TabFill, i, ip
  ;creates a function table with inum increasing integers, starting at istart
inum,istart xin
itab      ftgen     0, 0, -inum, -2, 0
indx      =         0
loop:
          tabw_i    istart, indx, itab
istart    =         istart + 1
          loop_lt   indx, 1, inum, loop
          xout      itab
  endop
  
  
  opcode TabPermRand_i, i, i
;permuts randomly the values of the input table and creates an output table for the result
iTabin    xin
itablen   =         ftlen(iTabin)
iTabout   ftgen     0, 0, -itablen, 2, 0 ;create empty output table
iCopy     ftgen     0, 0, -itablen, 2, 0 ;create empty copy of input table
          tableicopy iCopy, iTabin ;write values of iTabin into iCopy
icplen    init      itablen ;number of values in iCopy
indxwt    init      0 ;index of writing in iTabout
loop:
indxrd    random    0, icplen - .0001; random read index in iCopy 
indxrd    =         int(indxrd)
ival      tab_i     indxrd, iCopy; read the value
          tabw_i    ival, indxwt, iTabout; write it to iTabout
 shift:           ;shift values in iCopy larger than indxrd one position to the left
 if indxrd < icplen-1 then ;if indxrd has not been the last table value
ivalshft  tab_i     indxrd+1, iCopy ;take the value to the right ...
          tabw_i    ivalshft, indxrd, iCopy ;... and write it to indxrd position
indxrd    =         indxrd + 1 ;then go to the next position 
          igoto     shift ;return to shift and see if there is anything left to do
 endif
indxwt    =         indxwt + 1 ;increase the index of writing in iTabout
          loop_gt   icplen, 1, 0, loop ;loop as long as there is a value in iCopy
          ftfree    iCopy, 0 ;delete the copy table
          xout      iTabout ;return the number of iTabout
  endop



/*****************************************/		
/************** INSTRUMENTS **************/
/*****************************************/		

instr master
 
 ;;get input from GUI
Sfiles    invalue   "_MBrowse"
kpaus     invalue   "paus"
kpaustim  invalue   "paustim"
kpaustimk =         kpaustim * kr; paustim in k-cycles
kloop     invalue   "loop_play"; 1=loop
krandom   invalue   "random_play"

 ;;return play or pause status
gkplay    init      1
kchange   changed   kpaus
 if kchange == 1 && kpaus == 1 then
gkplay    =         (gkplay == 0 ? 1 : 0)
 endif
 
 ;;show all files in the GUI and link to a strset number
inumfils  StrayLen  Sfiles, 124
istrsetnum =        1
Strshow   =         "Files loaded:\n"
showlist:
ist, ien  StrayGetEl Sfiles, istrsetnum-1, 124
Sel       strsub    Sfiles, ist, ien
          strset    istrsetnum, Sel
Strshownew sprintf  "%s%d: %s\n", Strshow, istrsetnum, Sel
Strshow   =         Strshownew		
          loop_lt   istrsetnum, 1, inumfils+1, showlist
          outvalue  "showfiles", Strshow
  
 ;;prepare list for random play
iRowTab   TabFill   inumfils
iRndTab   TabPermRand_i iRowTab
          
 ;;play files 
kcount    invalue   "firsttrack" ;start with this file number
ktimk     init      0 ;initialize time
irndindx  =         0 ;index for random play
newfile:
icount    =         i(kcount)
  ;select one of the files
 if i(krandom) == 1 then
iwhich    tab_i     irndindx, iRndTab
 else
iwhich    =         icount
 endif
  ;get filename and suffix
Splay     strget    iwhich
Suf       FilSuf    Splay, 1
  ;get length of file
ilen,imp3 FilLen    Splay, Suf
  ;show file infos
ilenmin   =         int(ilen/60)
ilensec   =         int(ilen%60)
ilenms    =         frac(ilen) * 1000
Showplay  sprintf   "Selected File:\n%d\n '%s'\nDuration %02d:%02d:%03d (min:sec:ms)", \
                    iwhich, Splay, ilenmin, ilensec, ilenms
          outvalue  "showplay", Showplay; ... and show it
  ;call subinstrument to play this file
          event_i   "i", "play", 0, ilen, iwhich, 0, ilen, imp3

 ;;control
ifilenk   =         ilen * kr; length of file in k-cycles
  ;stop the clock if pause button has been pressed
  if gkplay == 0 then
ktim      =		ktim
  ;if no pause
  else
    ;if end of file plus pause time has been reached
    if ktimk >= ifilenk+kpaustimk then
ktimk     =         0 ;set time to zero
      ;if random
      if krandom == 1 then
        ;if last file has been played
        if irndindx == inumfils-1 then
          ;reset random index if loop
          if kloop == 1 then
irndindx  =         0
          ;otherwise stop performance
          else	
          turnoff
          endif
        ;for any other file before the last get the next element from iRndTab
        else
irndindx  =          irndindx + 1
        endif
      ;if no random  
      else
        ;if last file has been played
        if icount == inumfils then
          ;go back if loop
          if kloop == 1 then
kcount    =         1
          ;stop if no loop
          else 
          turnoff
          endif
        ;otherwise increase counter
        else
kcount    =         icount+1
        endif 
      endif
    ;if not end of file plus pause, simply increase time counter
    else
ktimk     =         ktimk+1
    endif		
  endif
 
 ;;reinit the 'newfile' block if new file starts
 if ktimk == 0 && gkplay == 1 then
 		reinit		newfile
 endif

endin


instr play ;plays one file

 ;;input
ifil      =         p4
Sfile     strget    ifil ;soundfile
iskip     =         p5 ;skiptime
ilen      =         p6
imp3      =         p7 ;1 = file is mp3
idbrange  =         48 ;range in dB shown by the LED's
ipeakhold =         2 ;peak hold in seconds
kdb       invalue   "db"; output gain in dB

 ;;volume
kmult     =         ampdbfs(kdb)
Sdb_disp  sprintfk  "%+.2f dB", kdb
          outvalue  "db_disp", Sdb_disp
    
 ;;audio signal
aL, aR    SelPlay   Sfile, iskip, imp3
          outs      aL*kmult, aR*kmult
          
 ;;show audio output
kTrigDisp metro     10
          ShowLED_a "outL", aL, kTrigDisp, 1, idbrange
          ShowLED_a "outR", aR, kTrigDisp, 1, idbrange
          ShowOver_a "outLover", aL, kTrigDisp, ipeakhold
          ShowOver_a "outRover", aR, kTrigDisp, ipeakhold
          
 ;;show remaining time
ktimout   timeinsts ;position in the soundfile in seconds
ktimout   =         ktimout + iskip
ktimrem   =         ilen - ktimout
          outvalue  "timrem", 1-ktimrem/ilen
ktr_min   =         int(ktimrem / 60) 
Smin      sprintfk  "%02d", ktr_min
ktr_sec   =         int(ktimrem % 60)
Ssec      sprintfk  "%02d", ktr_sec
ktr_ms    =         frac(ktimrem) * 1000
Sms       sprintfk  "%03d", ktr_ms
          outvalue  "tr_min", Smin
          outvalue  "tr_sec", Ssec
          outvalue  "tr_ms", Sms
          
 ;;pause and resume
 if gkplay == 0 then
          event     "i", "pause", 0, -1, ilen, ifil, ktimout
          turnoff
 endif
endin


instr pause; activated if there is a pause

ifildur   =         p4
ifil      =         p5
Sfile     strget    ifil
iskip     =         p6
irestdur  =         ifildur - iskip
 if gkplay == 1 then
          event     "i", "play", 0, irestdur, ifil, iskip, ifildur; calls instr 10 back
          turnoff
 endif

endin

</CsInstruments>
<CsScore>
i "master" 0 99999
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>302</x>
 <y>62</y>
 <width>590</width>
 <height>705</height>
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
  <xValue>-0.37972087</xValue>
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
  <xValue>-0.39139950</xValue>
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
  <label>-5.55 dB</label>
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
  <xValue>1.00000000</xValue>
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
  <x>528</x>
  <y>426</y>
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
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>352</x>
  <y>432</y>
  <width>174</width>
  <height>25</height>
  <uuid>{87136530-bd70-4e4e-96f8-1e25d64f0d23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Pause between tracks</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <latched>true</latched>
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
  <latched>true</latched>
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
  <midicc>0</midicc>
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
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <midicc>0</midicc>
  <label/>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>242</r>
   <g>241</g>
   <b>240</b>
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
  <stringvalue>/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/wineStereo.aif|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/WhiteNoise.aif|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/SpracheStereo.mp3|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/SpracheMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.ogg</stringvalue>
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
  <label>(MP3 files are possible if filenames end as .mp3)(USE CSOUND 5.16 OR HIGHER!)</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>firsttrack</objectName>
  <x>151</x>
  <y>428</y>
  <width>43</width>
  <height>31</height>
  <uuid>{c516264e-78e2-457a-a802-3c5f3f9bb03f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>24</x>
  <y>428</y>
  <width>130</width>
  <height>29</height>
  <uuid>{bb20ec0c-2c9f-4dbc-804d-cbf659855318}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>100</midicc>
  <label>Start with track</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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

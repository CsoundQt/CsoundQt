<CsoundSynthesizer>
<CsOptions>
-+max_str_len=10000 -n
</CsOptions>
<CsInstruments>

/***Envelope Extractor***/
;example for qutecsound
;joachim heintz mar 2011

sr = 44100
ksmps = 1 ;use ksmps=1 for avoiding roundoff inaccuracies
nchnls = 1
0dbfs = 1


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

  opcode StrayGetNum, i, Sijj
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
end: 		
Snum		strsub		Stray, istartsel, iendsel
inum		strtod		Snum
		xout		inum
  endop 

  opcode FilePlay1, a, Skoo
;gives mono output regardless your soundfile is mono or stereo
;(if stereo, just the first channel is used)
Sfil, kspeed, iskip, iloop	xin
ichn		filenchnls	Sfil
if ichn == 1 then
aout		diskin2	Sfil, kspeed, iskip, iloop
else
aout, ano	diskin2	Sfil, kspeed, iskip, iloop
endif
		xout		aout
  endop


instr 1 ;distribute values and calls instr 2
Sfiles    invalue   "_MBrowse"
Snpoints  invalue   "npoints"
Sftnums   invalue   "ftnums"
gSoutfil  invalue   "_Browse"
inumfils  StrayLen  Sfiles, 124
p3        =         inumfils/10 + 0.1
inumpnts  StrayLen  Snpoints
inumftns  StrayLen  Sftnums
indx      =         0
loop:
ist, ien  StrayGetEl Sfiles, indx, 124
Sfile     strsub    Sfiles, ist, ien
 if inumpnts == 1 then
inpoints  StrayGetNum Snpoints, 0
 else
inpoints  StrayGetNum Snpoints, indx
 endif
 if inumftns == 1 then
iftnum    StrayGetNum Sftnums, 0
 else
iftnum    StrayGetNum Sftnums, indx
 endif
Scall     sprintf   {{i 2 %f .1 "%s" %d %d}}, indx/10, Sfile, inpoints, iftnum
          scoreline_i Scall
          loop_lt   indx, 1, inumfils, loop
endin

instr 2 ;performs analysis and calls instr 3
Sfile     strget    p4
inpoints  =         p5
iftnum    =         p6

ilslash   strrindex Sfile, "/"
Snamsuf   strsub    Sfile, ilslash+1
ilsuf     strrindex Snamsuf, "."
Sname     strsub    Snamsuf, 0, ilsuf

Sformat   sprintf   "gi_%s ftgen %d, 0, -%d, -2", Sname, iftnum, inpoints
          ;fprints   gSoutfil, Sformat

ifilen    filelen   Sfile
ifilkcyc  =         ifilen*sr/ksmps ;number of k-cycles

kcount    init      0
loop:
idt       =         ifilen / inpoints
asig      FilePlay1 Sfile, 1
aenv      follow    asig, idt
kenv      downsamp  aenv
if kcount % round(ifilkcyc/inpoints) == 0 then
Snew      sprintfk  "%s, %f", Sformat, kenv
Sformat   strcpyk   Snew
endif
          loop_lt   kcount, 1, ifilkcyc, loop
gSwrite   strcatk   Sformat, "\n"
          event     "i", 3, 0, .1
          turnoff
endin

instr 3 ;writes resulting tables to file
          fprints   gSoutfil, gSwrite
          printf_i  "Values written to file '%s'\n", 1, gSoutfil
endin

</CsInstruments>
<CsScore>
i 1 0 1
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>61</y>
 <width>198</width>
 <height>138</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_MBrowse</objectName>
  <x>274</x>
  <y>261</y>
  <width>343</width>
  <height>29</height>
  <uuid>{fe1e66fe-4105-4aed-9c04-e06ef3c95aa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheStereo.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/EineWelleMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/Glocke_Ganze1.aiff</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>232</r>
   <g>232</g>
   <b>232</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_MBrowse</objectName>
  <x>621</x>
  <y>260</y>
  <width>100</width>
  <height>30</height>
  <uuid>{7e9d3773-29f5-4906-91f7-3e35e562dfa6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheStereo.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/EineWelleMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/Glocke_Ganze1.aiff</stringvalue>
  <text>Select Files</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>npoints</objectName>
  <x>274</x>
  <y>332</y>
  <width>343</width>
  <height>29</height>
  <uuid>{56ac7a23-6421-41d3-bede-c48a63166f2f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>100</label>
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
   <r>232</r>
   <g>232</g>
   <b>232</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>85</x>
  <y>260</y>
  <width>188</width>
  <height>30</height>
  <uuid>{c0c2d141-f138-41bc-8c76-f59252e79007}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Files to be analyzed</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>34</x>
  <y>326</y>
  <width>239</width>
  <height>43</height>
  <uuid>{59338b2d-457d-4151-9067-70221d3660d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Number of points in the
function tables to be created</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>ftnums</objectName>
  <x>274</x>
  <y>375</y>
  <width>343</width>
  <height>29</height>
  <uuid>{efef5429-8ce4-477c-b240-24a2627c6e99}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>4000 4001 4002 4003</label>
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
   <r>232</r>
   <g>232</g>
   <b>232</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>33</x>
  <y>371</y>
  <width>240</width>
  <height>41</height>
  <uuid>{25982a05-2dd6-489a-9fbc-cc5d94250b4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>identification number of the
function tables to be created</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse</objectName>
  <x>274</x>
  <y>295</y>
  <width>343</width>
  <height>29</height>
  <uuid>{37827e7b-547c-44ee-9ed7-91da451a1bc6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>/home/linux/Desktop/test2.txt</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>232</r>
   <g>232</g>
   <b>232</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse</objectName>
  <x>621</x>
  <y>294</y>
  <width>100</width>
  <height>30</height>
  <uuid>{9a15fa00-1fac-478d-9857-be9b89935695}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Desktop/test2.txt</stringvalue>
  <text>Select File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>32</x>
  <y>295</y>
  <width>241</width>
  <height>29</height>
  <uuid>{5b54c68d-0de1-4915-9029-101af74e6f8d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Text file to be written as result</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>21</x>
  <y>7</y>
  <width>699</width>
  <height>56</height>
  <uuid>{0fe8443c-9a6f-4f4a-9ea3-296c28ad4fb7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>ENVELOPE EXTRACTOR</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>40</fontsize>
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
  <x>20</x>
  <y>69</y>
  <width>700</width>
  <height>187</height>
  <uuid>{f02e3ae5-27d7-4d40-b5c2-242497d54eba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>This instrument analyses the envelope(s) of one or more given sample(s) and returns the result as function tables in this format:
gi_'filename' ftgen 'ftnum', 0, 'points', -2, val1, val2, ...
The number of points gives the resolution of your analysis. If the duration of your sample is two seconds, and you write a table of size 100 points, you will get the mean amplitude for each 2/100 = 0.02 seconds.
Select one or some sound files for analyzing, and a text file for writing the result to. Enter the desired number of points for the analysis, and the identification number of the table (for both either one number which is applied to all input files, or one number for each file).</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>_Render</objectName>
  <x>621</x>
  <y>331</y>
  <width>100</width>
  <height>74</height>
  <uuid>{fa20b460-4974-43cd-9729-9bde68d583db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Desktop/test2.txt</stringvalue>
  <text>Analyse
and write
to textfile!</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
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
WindowBounds: 0 61 198 138
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView background {43690, 43690, 32639}
ioText {274, 261} {343, 29} edit 0.000000 0.00100 "_MBrowse"  "DejaVu Sans" 14 {0, 0, 0} {61952, 61696, 61440} falsenoborder /home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheStereo.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/EineWelleMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/Glocke_Ganze1.aiff
ioButton {621, 260} {100, 30} value 1.000000 "_MBrowse" "Select Files" "/" 
ioText {274, 332} {343, 29} edit 0.000000 0.00100 "npoints"  "Arial" 14 {0, 0, 0} {61952, 61696, 61440} falsenoborder 100
ioText {87, 244} {188, 30} label 0.000000 0.00100 "" right "Arial" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Files to be analyzed
ioText {36, 310} {239, 43} label 0.000000 0.00100 "" right "Arial" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Number of points in theÂ¬function tables to be created
ioText {274, 375} {343, 29} edit 0.000000 0.00100 "ftnums"  "Arial" 14 {0, 0, 0} {61952, 61696, 61440} falsenoborder 4000 4001 4002 4003
ioText {35, 355} {240, 41} label 0.000000 0.00100 "" right "Arial" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder identification number of theÂ¬function tables to be created
ioText {274, 295} {343, 29} edit 0.000000 0.00100 "_Browse"  "Arial" 14 {0, 0, 0} {61952, 61696, 61440} falsenoborder /home/linux/Desktop/test2.txt
ioButton {621, 294} {100, 30} value 1.000000 "_Browse" "Select File" "/" 
ioText {34, 279} {241, 29} label 0.000000 0.00100 "" right "Arial" 14 {0, 0, 0} {59392, 59392, 59392} nobackground noborder Text file to be written as result
ioText {21, 7} {699, 56} label 0.000000 0.00100 "" center "Arial" 40 {0, 0, 0} {59392, 59392, 59392} nobackground noborder ENVELOPE EXTRACTOR
ioText {20, 69} {699, 169} label 0.000000 0.00100 "" left "Arial" 16 {0, 0, 0} {59392, 59392, 59392} nobackground noborder This instrument analyses the envelope(s) of one or more given sample(s) and returns the result as function tables in this format:Â¬gi_'filename' ftgen 'ftnum', 0, 'points', -2, val1, val2, ...Â¬The number of points gives the resolution of your analysis. If the duration of your sample is two seconds, and you write a table of size 100 points, you will get the mean amplitude for each 2/100 = 0.02 seconds.Â¬Select one or some sound files for analyzing, and a text file for writing the result to. Enter the desired number of points for the analysis, and the identification number of the table (for both either one number which is applied to all input files, or one number for each file).
ioButton {621, 331} {100, 74} value 1.000000 "_Render" "AnalyseÂ¬and writeÂ¬to textfile!" "/" 
</MacGUI>

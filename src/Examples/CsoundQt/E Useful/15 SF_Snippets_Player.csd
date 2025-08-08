<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>

/*Soundfile Snippets Player
joachim heintz, may 2011*/

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1


;;ascii numbers for key shortcuts (32=space, 112='p', 110='n')
gikeynxt  =         32 ;next sound
gikeyls   =         112 ;next sound one less
gikeymr   =         110 ;next sound one in advance 

;declare string channel
chn_S     "_MBrowse", 1

  opcode StrayGetEl, ii, Sijj
;returns the startindex and the endindex (= the first space after the element) for ielindex in String. if startindex returns -1, the element has not been found
Stray, ielindx, isepA, isepB xin
;DEFINE THE SEPARATORS
isep1     =         (isepA == -1 ? 32 : isepA)
isep2     =         (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
Sep1      sprintf   "%c", isep1
Sep2      sprintf   "%c", isep2
;INITIALIZE SOME PARAMETERS
ilen      strlen    Stray
istartsel =         -1; startindex for searched element
iendsel   =         -1; endindex for searched element
iel       =         0; actual number of element while searching
iwarleer  =         1
indx      =         0
 if ilen == 0 igoto end ;don't go into the loop if Stray is empty
loop:
Snext     strsub    Stray, indx, indx+1; next sign
isep1p    strcmp    Snext, Sep1; returns 0 if Snext is sep1
isep2p    strcmp    Snext, Sep2; 0 if Snext is sep2
;NEXT SIGN IS NOT SEP1 NOR SEP2
if isep1p != 0 && isep2p != 0 then
 if iwarleer == 1 then; first character after a separator 
  if iel == ielindx then; if searched element index
istartsel =         indx; set it
iwarleer  =         0
  else 			;if not searched element index
iel       =         iel+1; increase it
iwarleer  =         0; log that it's not a separator 
  endif 
 endif 
;NEXT SIGN IS SEP1 OR SEP2
else 
 if istartsel > -1 then; if this is first selector after searched element
iendsel   =         indx; set iendsel
          igoto     end ;break
 else	
iwarleer  =         1
 endif 
endif
          loop_lt   indx, 1, ilen, loop 
end:      xout      istartsel, iendsel
  endop 

  opcode StrayLen, i, Sjj
;returns the number of elements in Stray. elements are defined by two separators as ASCII coded characters: isep1 defaults to 32 (= space), isep2 defaults to 9 (= tab). if just one separator is used, isep2 equals isep1
Stray, isepA, isepB xin
;DEFINE THE SEPARATORS
isep1     =         (isepA == -1 ? 32 : isepA)
isep2     =         (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
Sep1      sprintf   "%c", isep1
Sep2      sprintf   "%c", isep2
;INITIALIZE SOME PARAMETERS
ilen      strlen    Stray
icount    =         0; number of elements
iwarsep   =         1
indx      =         0
 if ilen == 0 igoto end ;don't go into the loop if String is empty
loop:
Snext     strsub    Stray, indx, indx+1; next sign
isep1p    strcmp    Snext, Sep1; returns 0 if Snext is sep1
isep2p    strcmp    Snext, Sep2; 0 if Snext is sep2
 if isep1p == 0 || isep2p == 0 then; if sep1 or sep2
iwarsep   =         1; tell the log so
 else 				; if not 
  if iwarsep == 1 then	; and has been sep1 or sep2 before
icount    =         icount + 1; increase counter
iwarsep   =         0; and tell you are ot sep1 nor sep2 
  endif 
 endif	
          loop_lt   indx, 1, ilen, loop 
end:      xout      icount
  endop 

  opcode	ShowLED_a, 0, Sakkk
;shows an audiosignal in an outvalue channel, in dB or raw amplitudes
;Soutchan: string as name of the outvalue channel
;asig: audio signal to be shown
;kdispfreq: refresh frequency of the display (Hz)
;kdb: 1 = show as db, 0 = show as raw amplitudes (both in the range 0-1)
;kdbrange: if idb=1: which dB range is shown
Soutchan, asig, ktrig, kdb, kdbrange	xin
kdispval	max_k	asig, ktrig, 1
	if kdb != 0 then
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
;shows if asig has been larger than 1 and stays khold seconds
;Soutchan: string as name of the outvalue channel
;kdispfreq: refresh frequency of the display (Hz)
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
  
  opcode Once, k, kpo
;returns kin only if it equals icomp (default == 1) and if kin has been changed compared to the previous k-cycle. otherwise i0 (default 0) is returned
kin, icomp, i0 xin
knew      changed   kin
 if (knew == 1) && (kin == icomp) then
kout      =         icomp
 else
kout      =         i0
 endif
          xout      kout
  endop
  
  opcode FilePlay2, aa, Skoo
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

  opcode KeyOnce, kk, kkk
;returns '1' just in the k-cycle a certain key has been pressed (kdown) or released (kup)
key, kd, kascii    xin ;sensekey output and ascii code of the key (e.g. 32 for space)
knew      changed   key
kdown     =         (key == kascii && knew == 1 && kd == 1 ? 1 : 0)
kup       =         (key == kascii && knew == 1 && kd == 0 ? 1 : 0)
          xout      kdown, kup
  endop

instr 1
          turnon    99
Sfiles    chnget    "_MBrowse" ;selection of sound files
gkgaindb  chnget    "gaindb"
knext     chnget    "next"
knextfil  chnget    "nextfil" ;number of soundfile
knextfil  =         (knextfil == 0 ? 1 : knextfil)

;;connecting the soundfiles with strset numbers
inumfils  StrayLen  Sfiles, 124 ;how many files (separated by '|') to load
iload     =         0
  load:
ist, ien  StrayGetEl Sfiles, iload, 124
Sfil      strsub     Sfiles, ist, ien
          strset     iload+1, Sfil
          loop_lt    iload, 1, inumfils, load
          
;;set value for next file with keys one up or down
key, kd   sensekey   
keyls,k0  KeyOnce    key, kd, gikeyls
keymr,k0  KeyOnce    key, kd, gikeymr
 if keyls == 1 then
knextfil  =          knextfil-1
          outvalue   "nextfil", knextfil
 elseif keymr == 1 then
knextfil  =          knextfil+1
          outvalue   "nextfil", knextfil
 endif

;;triggering next sound
 ;with the button widget
kplnxt    Once       knext
 ;or with key 
keynxt,k0 KeyOnce    key, kd, gikeynxt
 
 if kplnxt == 1 || keynxt == 1 then 
  if knextfil <= inumfils then 
          outvalue   "nextfil", knextfil+1
          event      "i", 10, 0, 1, knextfil
  else ;file is not valid
          event      "i", 9, 0, 1, knextfil, inumfils
  endif
 endif

endin

instr 9 ;error because required strset number is larger than number of files
ifil      =          p4
inumfils  =          p5
Smess     sprintf    "Can't play file number %d!\nJust %d files are in the pool.", ifil, inumfils
          outvalue   "messages", Smess
endin

instr 10
ifilnr    =          p4
Sfil      strget     ifilnr
ifilen    filelen    Sfil
p3        =          ifilen
aL, aR    FilePlay2  Sfil, 1
          outs       aL*ampdb(gkgaindb), aR*ampdb(gkgaindb)
;show messages
ilslash   strrindex  Sfil, "/"
Sname     strsub     Sfil, ilslash+1
Smess     sprintf    "Playing file number %d:\n'%s'.", ifilnr, Sname
ktim      timeinstk
 if ktim == 1 then
          outvalue   "messages", Smess
 endif
endin

instr 99; show output
aL, aR    monitor
kTrigDisp metro    10
          ShowLED_a "outL", aL, kTrigDisp, 1, 50
          ShowLED_a "outR", aR, kTrigDisp, 1, 50
          ShowOver_a "outLover", aL/0dbfs, kTrigDisp, 1
          ShowOver_a "outRover", aR/0dbfs, kTrigDisp, 1
endin
</CsInstruments>
<CsScore> 
i 1 0 10000
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>458</x>
 <y>159</y>
 <width>497</width>
 <height>351</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>205</r>
  <g>255</g>
  <b>123</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_MBrowse</objectName>
  <x>11</x>
  <y>135</y>
  <width>149</width>
  <height>26</height>
  <uuid>{fe1e66fe-4105-4aed-9c04-e06ef3c95aa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>fox.wav|bell.aiff|808loop.wav</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>239</r>
   <g>239</g>
   <b>239</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_MBrowse</objectName>
  <x>161</x>
  <y>134</y>
  <width>100</width>
  <height>30</height>
  <uuid>{7e9d3773-29f5-4906-91f7-3e35e562dfa6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>fox.wav|bell.aiff|808loop.wav</stringvalue>
  <text>Select Files</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>next</objectName>
  <x>12</x>
  <y>197</y>
  <width>100</width>
  <height>30</height>
  <uuid>{1ab2a0e3-3615-4cab-9b3f-effdbd3da26d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheStereo.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/EineWelleMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/Glocke_Ganze1.aiff</stringvalue>
  <text>NEXT!</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>messages</objectName>
  <x>193</x>
  <y>171</y>
  <width>249</width>
  <height>57</height>
  <uuid>{daf328dd-4a90-4fed-8bb3-ba3b230a754d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Playing file number 3:
'808loop.wav'.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>outL</objectName>
  <x>11</x>
  <y>239</y>
  <width>225</width>
  <height>20</height>
  <uuid>{56692e84-8339-4713-bedf-b81a5d5dea6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>outL</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-inf</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>outLover</objectName>
  <x>230</x>
  <y>239</y>
  <width>25</width>
  <height>20</height>
  <uuid>{9dbc1525-61ed-4dcc-aeb3-650eb87744db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
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
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>outR</objectName>
  <x>11</x>
  <y>265</y>
  <width>225</width>
  <height>20</height>
  <uuid>{09a3dabb-c32b-4652-b07c-a5149e90b11b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>outR</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-inf</xValue>
  <yValue>-inf</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>outRover</objectName>
  <x>230</x>
  <y>265</y>
  <width>25</width>
  <height>20</height>
  <uuid>{d515ef65-7c19-46c4-a888-c5cbc4e5653c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
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
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>nextfil</objectName>
  <x>124</x>
  <y>199</y>
  <width>56</width>
  <height>26</height>
  <uuid>{ac0aae3d-803d-499c-a8dd-bd503c9def5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>11</x>
  <y>169</y>
  <width>100</width>
  <height>25</height>
  <uuid>{7e8b7689-f681-44e6-ad82-c0ccd86f4ea1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Play next file</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>123</x>
  <y>170</y>
  <width>63</width>
  <height>26</height>
  <uuid>{c3147df5-ed47-4cd3-a1a8-b419afa071ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Next file</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>9</y>
  <width>431</width>
  <height>39</height>
  <uuid>{2a56f609-3f3a-49a2-8ef2-04e1041ed49f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>SOUNDFILE SNIPPETS PLAYER</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>26</fontsize>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>53</y>
  <width>434</width>
  <height>71</height>
  <uuid>{73bb9833-135d-4658-bc89-61ff0302aeba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Load the sound snippets. Press START. Push the NEXT! button or the space bar (make sure the focus is in this panel). You can reset the number of the next file by typing in the spin box, or by the 'p'/'n' keys.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>269</x>
  <y>134</y>
  <width>100</width>
  <height>30</height>
  <uuid>{afd840d0-f92a-47d4-877b-ac69d46ca429}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheStereo.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/EineWelleMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/Glocke_Ganze1.aiff</stringvalue>
  <text>START</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Stop</objectName>
  <x>379</x>
  <y>134</y>
  <width>63</width>
  <height>30</height>
  <uuid>{3af0308a-0d13-49ac-afc0-b3e33b2168b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/BratscheStereo.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/EineWelleMono.aiff|/home/linux/Joachim/Materialien/SamplesKlangbearbeitung/Glocke_Ganze1.aiff</stringvalue>
  <text>STOP</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>gaindb</objectName>
  <x>267</x>
  <y>263</y>
  <width>176</width>
  <height>24</height>
  <uuid>{4d42ff3b-ba28-463f-aaf0-ef8905f4facc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>-2.04545455</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>267</x>
  <y>236</y>
  <width>45</width>
  <height>26</height>
  <uuid>{eccfbfa8-ba49-4ac2-94c3-9d70d1db6028}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Gain</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>397</x>
  <y>235</y>
  <width>45</width>
  <height>26</height>
  <uuid>{8b5b92dc-f58e-406e-8262-b117e1a70803}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>dB</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>gaindb</objectName>
  <x>314</x>
  <y>236</y>
  <width>80</width>
  <height>25</height>
  <uuid>{126c55f6-ba72-4d42-a3f5-7bf36e0a8269}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>-2.045</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

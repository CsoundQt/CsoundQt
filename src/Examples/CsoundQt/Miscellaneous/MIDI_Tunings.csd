<CsoundSynthesizer>
<CsOptions>
-m128
</CsOptions>
<CsInstruments>
ksmps =   128 
nchnls =  2 
0dbfs =   1 


;============================================================================;
;============================================================================;
;                    PLAYING SCALES WITH A MIDI KEYBOARD                     ;
;============================================================================;
;                  by Joachim Heintz and Richard Boulanger                   ;
;                              2010 / 2012 / 2014                            ;
;                             Version for Csound6                            ;
;============================================================================;
;============================================================================;



;============================================================================;
;                   SOME GLOBAL VARIABLES AND ASSIGNMENTS                    ;
;============================================================================;


giScales[][] init   30, 100 ;two-dimensional array to hold the values
giScaleLens[] init  30 ;how many values in one scale
giSine    ftgen     0, 0, 8192, 10, 1 
giSaw     ftgen     0, 0, 8192, 10, 1, 1/2, 1/3, 1/4, 1/5, 1/6, 1/7, 1/8, 1/9 
giSquare  ftgen     0, 0, 8192, 10, 1, 0, 1/3, 0, 1/5, 0, 1/7, 0, 1/9, 0, 1/11 
          massign   0, "play"; send all midi noteon/noteoff events to instr 'play' 



;============================================================================;
;                             OPCODE DEFINITIONS                             ;
;============================================================================;

  opcode FreqByEqScale, i, iiii
;;frequency calculation for one step of an equal tempered scale. the unit for the scale can be an octave, a duodecim, or whatever
;iref_freq:	reference frequency
;iumult:	unit multiplier (2 = octave, 3 = Bohlen-Pierce scale, 5 = stockhausen scale in Studie2)
;istepspu:	steps per unit (12 for semitones, 13 for complete Bohlen-Pierce scale, 25 for studie2 scale)
;istep:	selected step (0 = reference frequency, 1 = one step higher, -1 = one step lower)
iref_freq, iumult, istepspu, istep xin 
ifreq     =         iref_freq * (iumult ^ (istep / istepspu)) 
          xout      ifreq 
  endop

  opcode FreqByCentArr, i, iii
  ;frequency calculation of a step of a scale which is defined by a list of cent values
;refers to the which index of giScales: array with the number of cent values per unit multiplier (usually 2 = octave)
;its first value is the unit multiplier iumult
;the second value must be 0 and matches iref_freq, if istep == 0
;iref_freq:	reference frequency (= for istep == 0)
;istep:	selected step (0 = reference frequency, 1 = one step higher, -1 = one step lower)
iwhich, iref_freq, istep xin 
iumult    =         giScales[iwhich][0]
iarrlen   =         giScaleLens[iwhich] - 1
ipos      =         floor(istep/iarrlen) ;"octave" position 
ibasfreq  =         (iumult ^ ipos) * iref_freq; base freq of istep 
icentindx =         istep % iarrlen + 1 ;position of the appropriate centvalue ... 
icentindx =         (icentindx < 1 ? (iarrlen + icentindx) : icentindx); ... in the array 
icent     =         giScales[iwhich][icentindx] ; get cent value 
ifreq     =         ibasfreq * cent(icent); get frequency 
          xout      ifreq 
  endop

  opcode FreqByRatioArr, i, iii
  ;frequency calculation of a step in a scale which is defined by a list of proportions
;refers to the which index of giScales:	array with the number of proportions per unit multiplier (usually 2 = octave)
;its first value is the unit multiplier iumult (2 = octave, 3 = duodecime or whatever)
;the second value must be 1 and matches iref_freq, if istep == 0
;iref_freq:	reference frequency (= for istep == 0)
;istep:	selected step (0 = reference frequency, 1 = one step higher, -1 = one step lower)
iwhich, iref_freq, istep xin 
iumult    =         giScales[iwhich][0]
iarrlen   =         giScaleLens[iwhich] - 1
ipos      =         floor(istep/iarrlen); "octave" position 
ibasfreq  =         (iumult ^ ipos) * iref_freq; base freq of istep 
ipropindx =         istep % iarrlen + 1; position of the appropriate proportion ... 
ipropindx =         (ipropindx < 1 ? (iarrlen + ipropindx) : ipropindx); ... in the array 
iprop     =         giScales[iwhich][ipropindx] ; get proportion 
ifreq     =         ibasfreq * iprop; get frequency 
          xout      ifreq 
  endop

  opcode FreqByECRArr, i, iii
  ;frequency calculation by either equal steps, cent list, or ratio list. the first value in the array gives the unit multiplier of the scale (e.g. 2 = octave or 3 = perfect 12th). the methods are distinguished by the second value in iarr:
;if the second value is 0, the array is considered to be a centlist
;if the second value is 1, the arry is considered to be a list of proportions
;else the second value is read as the number of equal tempered steps in the unit multiplier (e.g. 12 gives the usual keyboard tuning with a ratio of 12th root by 2 for each step when the first table value is 2)
iwhich, iref_freq, istep xin ;iwhich = index in giScales and giScaleLens
ifirst    =         giScales[iwhich][0] ; unit multiplier 
isecond   =         giScales[iwhich][1] ; 0=centlist, 1=ratios, else=equal tempered 
if isecond == 0 then
ifreq FreqByCentArr iwhich, iref_freq, istep 
elseif isecond == 1 then
ifreq FreqByRatioArr iwhich, iref_freq, istep 
          else 
ifreq FreqByEqScale iref_freq, ifirst, isecond, istep 
endif
          xout      ifreq 
  endop

  opcode MidiNoteIn, kkk, 0
  ;returns channel, key and velocity from a MIDI Note-On event. if no note-on event is received, -1 is returned for all three output values
keventin, kchanin, knotin, kvelin midiin 
if keventin == 144 then
kchan     =         kchanin 
knot      =         knotin 
kvel      =         kvelin 
          else 
kchan     =         -1 
knot      =         -1 
kvel      =         -1 
endif
          xout      kchan, knot, kvel 
  endop

  opcode IsOp, i, So
  ;returns 1 for (, 2 for +, 3 for -, 4 for *, 5 for /, 6 for %, 7 for ^
  ;0 for anything else
String, indx xin
Str strsub String, indx, indx+1
if strcmp(Str, "(") == 0 then
iRes = 1
elseif strcmp(Str, "+") == 0 then
iRes = 2
elseif strcmp(Str, "-") == 0 then
iRes = 3
elseif strcmp(Str, "*") == 0 then
iRes = 4
elseif strcmp(Str, "/") == 0 then
iRes = 5
elseif strcmp(Str, "%") == 0 then
iRes = 6
elseif strcmp(Str, "^") == 0 then
iRes = 7
else
iRes = 0
endif
xout iRes  
  endop

  opcode IsNum, i, So
  ;returns 1 if Schar is a number or point, 0 elsewhere
Schar, ipos xin
iNum strchar Schar, ipos
if iNum == 46 || (iNum > 47 && iNum < 58) then
iRes = 1
else
iRes = 0
endif
xout iRes
  endop
 
  opcode IsNoth, i, So
  ;returns 1 if Schar is a space or tab, 0 elsewhere
Schar, ipos xin
iNum strchar Schar, ipos
if iNum == 32 || iNum == 9 then
iRes = 1
else
iRes = 0
endif
xout iRes
  endop

  opcode StrExpr, i, S
Str xin
indx = 0
;printf_i "'%s'\n", 1, Str

;look after each character
until indx == strlen(Str) do

 ;do nothing if part of a number or a space
 if IsNum(Str, indx) == 1 || IsNoth(Str, indx) == 1 then
indx += 1

 ;if '(', look for the ')' and evaluate
 elseif IsOp(Str, indx) == 1 then
   ;position of second parenthesis
iPosPar2 strindex Str, ")"
   ;is there an operator after 
iSubIndx = iPosPar2
iIsOp2 = 0
   until iIsOp2 > 0 || iSubIndx == strlen(Str) do
iIsOp2 IsOp Str, iSubIndx
iSubIndx += 1
   enduntil 
   ;substring inside this parenthesis
S1 strsub Str, indx+1, iPosPar2
   ;if this is the end of the string, simply evaluate this section
   if iIsOp2 == 0 then
iNum StrExpr S1
igoto end
   else
   ;if there is an operator after this parenthesis, evaluate both strings
S2 strsub Str, iPosPar2+2
     if iIsOp2 == 2 then
iNum = StrExpr(S1) + StrExpr(S2)
igoto end
     elseif iIsOp2 == 3 then
iNum = StrExpr(S1) - StrExpr(S2)
igoto end    
     elseif iIsOp2 == 4 then
iNum = StrExpr(S1) * StrExpr(S2)
igoto end    
     elseif iIsOp2 == 5 then
iNum = StrExpr(S1) / StrExpr(S2)
igoto end    
     elseif iIsOp2 == 6 then
iNum = StrExpr(S1) % StrExpr(S2)
igoto end    
     else
iNum = StrExpr(S1) ^ StrExpr(S2)
igoto end    
     endif
     
   endif
 
 ;if operator, recursion with this operator
 else
S1 strsub Str, 0, indx
S2 strsub Str, indx+1
   if IsOp(Str, indx) == 2 then
iNum = StrExpr(S1) + StrExpr(S2)
igoto end
   elseif IsOp(Str, indx) == 3 then
iNum = StrExpr(S1) - StrExpr(S2)
igoto end
   elseif IsOp(Str, indx) == 4 then
iNum = StrExpr(S1) * StrExpr(S2)
igoto end
   elseif IsOp(Str, indx) == 5 then
iNum = StrExpr(S1) / StrExpr(S2)
igoto end
   elseif IsOp(Str, indx) == 6 then
iNum = StrExpr(S1) % StrExpr(S2)
igoto end
   else
iNum = StrExpr(S1) ^ StrExpr(S2)
igoto end
   endif
 endif
 
enduntil

iNum strtod Str
end: xout iNum  
  endop

  opcode StrayLen, i, Sjj
;returns the number of elements in Stray. elements are defined by two seperators as ASCII coded characters: isep1 defaults to 32 (= space), isep2 defaults to 9 (= tab). if just one seperator is used, isep2 equals isep1
Stray, isepA, isepB xin
;;DEFINE THE SEPERATORS
isep1     =         (isepA == -1 ? 32 : isepA)
isep2     =         (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
Sep1      sprintf   "%c", isep1
Sep2      sprintf   "%c", isep2
;;INITIALIZE SOME PARAMETERS
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

  opcode SToScaleArr, 0, Sijj
  ;fill a numerical string into iwhere first dimension of giScales
  ;and its length into iwhere of giScaleLens
Stray, iwhere, isepA, isepB xin
;;DEFINE THE SEPERATORS
isep1     =         (isepA == -1 ? 32 : isepA)
isep2     =         (isepA == -1 && isepB == -1 ? 9 : (isepB == -1 ? isep1 : isepB))
Sep1      sprintf   "%c", isep1
Sep2      sprintf   "%c", isep2
;;WRITE ARRAY LENGTH
iarrlen   StrayLen  Stray, isep1, isep2
giScaleLens[iwhere] = iarrlen
;;INITIALIZE SOME PARAMETERS
ilen      strlen    Stray
istartsel =         -1; startindex for searched element
iel       =         -1; number of element in Stray and ift
iwarleer  =         1; is this the start of a new element
indx      =         0 ;character index
inewel    =         0 ;new element to find
;;LOOP
 if ilen == 0 igoto end ;don't go into the loop if Stray is empty
loop:
Schar     strsub    Stray, indx, indx+1; this character
isep1p    strcmp    Schar, Sep1; returns 0 if Schar is sep1
isep2p    strcmp    Schar, Sep2; 0 if Schar is sep2
is_sep    =         (isep1p == 0 || isep2p == 0 ? 1 : 0) ;1 if Schar is a seperator
 ;END OF STRING AND NO SEPARATORS BEFORE?
 if indx == ilen && iwarleer == 0 then
Sel       strsub    Stray, istartsel, -1
inewel    =         1
 ;FIRST CHARACTER OF AN ELEMENT?
 elseif is_sep == 0 && iwarleer == 1 then
istartsel =         indx ;if so, set startindex
iwarleer  =         0 ;reset info about previous separator 
iel       =         iel+1 ;increment element count
 ;FIRST SEPERATOR AFTER AN ELEMENT?
 elseif iwarleer == 0 && is_sep == 1 then
Sel       strsub    Stray, istartsel, indx ;get element
inewel    =         1 ;tell about
iwarleer  =         1 ;reset info about previous separator
 endif
 ;WRITE THE ELEMENT TO THE ARRAY
 if inewel == 1 then
inum      StrExpr   Sel ;convert expression to number
giScales[iwhere][iel] = inum
 endif
inewel    =         0
          loop_le   indx, 1, ilen, loop 
end:
  endop 
  
  opcode ShowLED_a, 0, Sakkk
 ;Shows an audio signal in an outvalue channel. You can choose to show the value in dB or in raw amplitudes.
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;kdb: 1 = show in dB, 0 = show in raw amplitudes (both in the range 0-1)
;kdbrange: if idb=1: how many db-steps are shown (e.g. if 36 you will not see anything from a signal below -36 dB)
Soutchan, asig, kdispfreq, kdb, kdbrange xin 
kdispval  max_k     asig, kdispfreq, 1 
	if kdb != 0 then
kdb       =         dbfsamp(kdispval) 
kval      =         (kdbrange + kdb) / kdbrange 
          else 
kval      =         kdispval 
	endif
          outvalue  Soutchan, kval 
  endop

  opcode ShowOver_a, 0, Sakk
 ;Shows if the incoming audio signal was more than 1 and stays there for some time
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;khold: time in seconds to "hold the red light"
Soutchan, asig, kdispfreq, khold xin 
kon       init      0 
ktim      times 
kstart    init      0 
kend      init      0 
khold     =         (khold < .01 ? .01 : khold); avoiding too short hold times 
kmax      max_k     asig, kdispfreq, 1 
	if kon == 0 && kmax > 1 then
kstart    =         ktim 
kend      =         kstart + khold 
          outvalue  Soutchan, kmax 
kon       =         1 
	endif
	if kon == 1 && ktim > kend then
          outvalue  Soutchan, 0 
kon       =         0 
	endif
  endop




;============================================================================;
;                                 INSTRUMENTS                                ;
;============================================================================;

  instr init
;;INITIALIZE FUNCTION TABLES
          event_i   "i", "refresh", 0, 1 
;;INITIALIZE MENUS AND MESSAGES
          outvalue  "equal_tmprd", 0 
          outvalue  "various", 0 
          outvalue  "bohlen-pierce", 0 
          outvalue  "midi_event", "" 
;;INITIALIZE SOME GLOBAL VALUES
gkscale   init      1 
gkreftone init      69 
gktunfreq init      440 
gksound   init      0 
;;SHOW VALUES OF FIRST SCALE
          event_i   "i", "show", 0, 1 
;;TURN ON MASTER AND REVERB INSTRUMENT
          event_i   "i", "master", 0, 99999 
          event_i   "i", "reverb", 0, 99999 
          turnoff 
  endin


  instr master

;reduce rate to query widgets for saving cpu power
ktrig     metro     5 
  if ktrig == 1 then

;;GENERAL VALUES 
gkreftone invalue   "reftone"; any midi note number 
gktunfreq invalue   "tunfreq"; any frequency for it 
gksound   invalue   "sound"; select sound by menu 

;;SELECT SCALE BY MENU IF CHANGED 
kscale1   invalue   "equal_tmprd" 
kscale2   invalue   "various" 
kscale3   invalue   "bohlen-pierce" 
kscact1   changed   kscale1 
kscact2   changed   kscale2 
kscact3   changed   kscale3 
gkscale   =         (kscact1==1 ? kscale1+1 : (kscact2==1 ? kscale2+11 : (kscact3==1 ? kscale3+21 : gkscale))); set gkscale to new menu value if change 
;;SHOW SELECTED SCALE TYPE AND OTHER INFOS
 if kscact1 == 1 || kscact2 == 1 || kscact3 == 1 then
          event     "i", "show", 0, 1 
 endif
 
;;REFRESH ARRAYS IF A SCALE HAS BEEN CHANGED
knew      invalue   "new" 
kchange   changed   knew 
 if knew == 1 && kchange == 1 then
          event     "i", "refresh", 0, 1 
 endif

;;READ USER INPUT FOR SELECTING SCALES BY MIDI
gkgm1_scl invalue   "gm1_scale" 
gkgm1_key invalue   "gm1_key" 
gkgm1_chn invalue   "gm1_chn" 
gkgm2_scl invalue   "gm2_scale" 
gkgm2_key invalue   "gm2_key" 
gkgm2_chn invalue   "gm2_chn" 
gkgm3_scl invalue   "gm3_scale" 
gkgm3_key invalue   "gm3_key" 
gkgm3_chn invalue   "gm3_chn" 
gkgm4_scl invalue   "gm4_scale" 
gkgm4_key invalue   "gm4_key" 
gkgm4_chn invalue   "gm4_chn" 
gkgm5_scl invalue   "gm5_scale" 
gkgm5_key invalue   "gm5_key" 
gkgm5_chn invalue   "gm5_chn" 
gkgm6_scl invalue   "gm6_scale" 
gkgm6_key invalue   "gm6_key" 
gkgm6_chn invalue   "gm6_chn" 
gkgm7_scl invalue   "gm7_scale" 
gkgm7_key invalue   "gm7_key" 
gkgm7_chn invalue   "gm7_chn" 
gkgm8_scl invalue   "gm8_scale" 
gkgm8_key invalue   "gm8_key" 
gkgm8_chn invalue   "gm8_chn" 

 endif ;end of cpu saving ...
  endin


  instr refresh; building and refreshing function tables containing scale values
;;BUILDING ARRAYS LINE EDIT WIDGETS
;(ugly code, but invalue seems not to be reliable in a loop)
Scale1    invalue    "scale1"
Scale2    invalue    "scale2"
Scale3    invalue    "scale3"
Scale4    invalue    "scale4"
Scale5    invalue    "scale5"
Scale6    invalue    "scale6"
Scale7    invalue    "scale7"
Scale8    invalue    "scale8"
Scale9    invalue    "scale9"
Scale10   invalue    "scale10"
Scale11   invalue    "scale11"
Scale12   invalue    "scale12"
Scale13   invalue    "scale13"
Scale14   invalue    "scale14"
Scale15   invalue    "scale15"
Scale16   invalue    "scale16"
Scale17   invalue    "scale17"
Scale18   invalue    "scale18"
Scale19   invalue    "scale19"
Scale20   invalue    "scale20"
Scale21   invalue    "scale21"
Scale22   invalue    "scale22"
Scale23   invalue    "scale23"
Scale24   invalue    "scale24"
Scale25   invalue    "scale25"
Scale26   invalue    "scale26"
Scale27   invalue    "scale27"
Scale28   invalue    "scale28"
Scale29   invalue    "scale29"
Scale30   invalue    "scale30"
SToScaleArr Scale1, 0
SToScaleArr Scale2, 1
SToScaleArr Scale3, 2
SToScaleArr Scale4, 3
SToScaleArr Scale5, 4
SToScaleArr Scale6, 5
SToScaleArr Scale7, 6
SToScaleArr Scale8, 7
SToScaleArr Scale9, 8
SToScaleArr Scale10, 9
SToScaleArr Scale11, 10
SToScaleArr Scale12, 11
SToScaleArr Scale13, 12
SToScaleArr Scale14, 13
SToScaleArr Scale15, 14
SToScaleArr Scale16, 15
SToScaleArr Scale17, 16
SToScaleArr Scale18, 17
SToScaleArr Scale19, 18
SToScaleArr Scale20, 19
SToScaleArr Scale21, 20
SToScaleArr Scale22, 21
SToScaleArr Scale23, 22
SToScaleArr Scale24, 23
SToScaleArr Scale25, 24
SToScaleArr Scale26, 25
SToScaleArr Scale27, 26
SToScaleArr Scale28, 27
SToScaleArr Scale29, 28
SToScaleArr Scale30, 29
          turnoff 
  endin

  
  instr show; show scale info and set menu if changed

;currently (may 2014) there is an issue in sending long strings via outvalue
;so only short info is being sent

  ;EQUAL TEMPERED
 if i(gkscale) == 1 then	;halftone
Sinfo     sprintf   "1 Halftone\n12 steps per octave with a ratio of 12th root of 2 = %f...", 2^(1/12) 
;Sinfo = "Scale 1 selected"
          outvalue  "equal_tmprd", 0 
 elseif i(gkscale) == 2 then	;thirdtone
Sinfo     sprintf   "2 Thirdtone\n18 steps per octave with a ratio of 18th root of 2 = %f...", 2^(1/18) 
;Sinfo = "Scale 2 selected"
          outvalue  "equal_tmprd", 1 
 elseif i(gkscale) == 3 then	;quartertone
;Sinfo = "Scale 3 selected"
Sinfo     sprintf   "3 Quartertone\n24 steps per octave with a ratio of 24th root of 2 = %f...", 2^(1/24) 
          outvalue  "equal_tmprd", 2 
 elseif i(gkscale) == 4 then	;fifthtone
;Sinfo = "Scale 4 selected"
Sinfo     sprintf   "4 Fifthtone\n30 steps per octave with a ratio of 30th root of 2 = %f...", 2^(1/30) 
          outvalue  "equal_tmprd", 3 
 elseif i(gkscale) == 5 then	;sixthtone
;Sinfo = "Scale 5 selected"
Sinfo     sprintf   "5 Sixthtone\n36 steps per octave with a ratio of 36th root of 2 = %f...", 2^(1/36) 
          outvalue  "equal_tmprd", 4 
 elseif i(gkscale) == 6 then	;eighttone
;Sinfo = "Scale 6 selected"
Sinfo     sprintf   "6 Eighttone\n48 steps per octave with a ratio of 48th root of 2 = %f...", 2^(1/48) 
          outvalue  "equal_tmprd", 5 
 elseif i(gkscale) == 7 then	;twelfsttone
;Sinfo = "Scale 7 selected"
Sinfo     sprintf   "7 Twelfsttone\n72 steps per octave with a ratio of 72th root of 2 = %f...", 2^(1/72) 
          outvalue  "equal_tmprd", 6 
 elseif i(gkscale) == 8 then	;sixteenthtone
;Sinfo = "Scale 8 selected"
Sinfo     sprintf   "8 Sixteenthtone\n96 steps per octave with a ratio of 96th root of 2 = %f...", 2^(1/96) 
          outvalue  "equal_tmprd", 7 
 elseif i(gkscale) == 9 then	;stockhausen scale in "studie ii"
;Sinfo = "Scale 9 selected"
Sinfo     sprintf   "9 Stockhausen Scale in 'Studie II'\n25 steps per 1:5 with a ratio of 25th root of 5 = %f...", 5^(1/25) 
          outvalue  "equal_tmprd", 8 
 elseif i(gkscale) == 10 then	;user defined
;Sinfo = "Scale 10 selected"
Sinfo     sprintf   "%s", "10 User defined\nYou can add your own description in the code at instr 4" 
          outvalue  "equal_tmprd", 9 
 ;VARIOUS TEMPERED
 elseif i(gkscale) == 11 then		;pythagorean
;Sinfo = "Scale 11 selected"
Sinfo     sprintf   "%s", "11 Pythagorean chromatic scale (14th century) with ratios\n1, 2187/2048, 9/8, 32/27, 81/64, 4/3, 729/512, 3/2, 6561/4096, 27/16, 16/9, 243/128\n(after Klaus Lang, Auf Wohlklangswellen durch der Toene Meer, Graz 1999, BEM 10, p. 41)" 
          outvalue  "various", 0 
 elseif i(gkscale) == 12 then	;zarlino / meantone
;Sinfo = "Scale 12 selected"
Sinfo     sprintf   "%s", "12 Meantone temperature after Zarlino 1571 with cent values\n0, 76, 193, 310, 386, 503, 579, 697, 773, 890, 1007, 1083\n(after Klaus Lang, Auf Wohlklangswellen durch der Toene Meer, Graz 1999, BEM 10, p. 68)" 
          outvalue  "various", 1 
 elseif i(gkscale) == 13 then	;werckmeister III
;Sinfo = "Scale 13 selected"
Sinfo     sprintf   "%s", "13 Werckmeister III temperature (1691) with cent values\n0, 90, 192, 294, 390, 498, 588, 696, 792, 888, 996, 1092\n(after Klaus Lang, Auf Wohlklangswellen durch der Toene Meer, Graz 1999, BEM 10, p. 97)" 
          outvalue  "various", 2 
 elseif i(gkscale) == 14 then	;kirnberger II
;Sinfo = "Scale 14 selected"
Sinfo     sprintf   "%s", "14 Kirnberger II temperature (1771) with cent values\n0, 90, 204, 294, 386, 498, 590, 702, 792, 895, 996, 1088\n(after Klaus Lang, Auf Wohlklangswellen durch der Toene Meer, Graz 1999, BEM 10, p. 100)" 
          outvalue  "various", 3 
 elseif i(gkscale) == 15 then	;sruti I
;Sinfo = "Scale 15 selected"
Sinfo     sprintf   "%s", "15 Sruti I:\n22 steps per octave in indian classical music with cent values \n0, 90, 112, 182, 204, 294, 316, 386, 408, 498, 520, 590, 610, 702, 792, 814, 884, 906, 996, 1018, 1088, 1110\n(after P. Sambamoorthy, South Indian, Music, Book IV, Second Edition, Madras 1954, pp 95-97)" 
          outvalue  "various", 4 
 elseif i(gkscale) == 16 then	;sruti II
;Sinfo = "Scale 16 selected"
Sinfo     sprintf   "%s", "16 Sruti II:\n22 steps per octave in indian clssical music with cent values\n0 68, 135, 200, 263, 325, 385, 444, 501, 557, 612, 666, 719, 771, 822, 872, 921, 969, 1017, 1064, 1110, 1155\n(after Narsing R. Eswara, Tonal Foundations of Indian Music, 2007, Appendix A.4)" 
          outvalue  "various", 5 
 elseif i(gkscale) == 17 then	;user defined
;Sinfo = "Scale 17 selected"
Sinfo     sprintf   "%s", "17 User defined\nYou can add your own description in the code at instr 4" 
          outvalue  "various", 6 
 elseif i(gkscale) == 18 then	;user defined
;Sinfo = "Scale 18 selected"
Sinfo     sprintf   "%s", "18 User defined\nYou can add your own description in the code at instr 4" 
          outvalue  "various", 7 
 elseif i(gkscale) == 19 then	;user defined
;Sinfo = "Scale 19 selected"
Sinfo     sprintf   "%s", "19 User defined\nYou can add your own description in the code at instr 4" 
          outvalue  "various", 8 
 elseif i(gkscale) == 20 then	;user defined
;Sinfo = "Scale 20 selected"
Sinfo     sprintf   "%s", "20 User defined\nYou can add your own description in the code at instr 4" 
          outvalue  "various", 9 
 ;BOHLEN-PIERCE
 elseif i(gkscale) == 21 then	;equal tempered (13 steps)
;Sinfo = "Scale 21 selected"
Sinfo     sprintf   "21 Bohlen-Pierce Equal Tempered:\n13 steps per 3:1 (duodecima) with a ratio of 13th root of 3 = %f...", 3^(1/13) 
          outvalue  "bohlen-pierce", 0 
 elseif i(gkscale) == 22 then	;ratios (13 steps)
;Sinfo = "Scale 22 selected"
Sinfo     sprintf   "%s", "22 Bohlen-Pierce Ratios:\n13 steps per 3:1 (duodecima) with ratios 1, 27/25, 25/21, 9/7, 7/5, 75/49, 5/3, 9/5, 49/25, 15/7, 7/3, 63/25, 25/9" 
          outvalue  "bohlen-pierce", 1 
 elseif i(gkscale) == 23 then	;Dur I (9 steps)
;Sinfo = "Scale 23 selected"
Sinfo     sprintf   "%s", "23 Bohlen-Pierce Dur I Mode:\n9 steps per 3:1 (duodecima) with ratios 1, 27/25, 9/7, 7/5, 5/3, 9/5, 49/25, 7/3, 63/25" 
          outvalue  "bohlen-pierce", 2 
 elseif i(gkscale) == 24 then	;Dur II (9 steps)
;Sinfo = "Scale 24 selected"
Sinfo     sprintf   "%s", "24 Bohlen-Pierce Dur II Mode:\n9 steps per 3:1 (duodecima) with ratios 1, 25/21, 9/7, 7/5, 5/3, 9/5, 15/7, 7/3, 63/25" 
          outvalue  "bohlen-pierce", 3 
 elseif i(gkscale) == 25 then	;Moll I (9 steps)
;Sinfo = "Scale 25 selected"
Sinfo     sprintf   "%s", "25 Bohlen-Pierce Moll I Mode (Delta):\n9 steps per 3:1 (duodecima) with ratios 1, 25/21, 9/7, 75/49, 5/3, 9/5, 15/7, 7/3, 25/9" 
          outvalue  "bohlen-pierce", 4 
 elseif i(gkscale) == 26 then	;Moll II (9 steps)
;Sinfo = "Scale 26 selected"
Sinfo     sprintf   "%s", "26 Bohlen-Pierce Moll II Mode (Pierce):\n9 steps per 3:1 (duodecima) with ratios 1, 27/25, 9/7, 7/5, 5/3, 9/5, 15/7, 7/3, 25/9" 
          outvalue  "bohlen-pierce", 5 
 elseif i(gkscale) == 27 then	;Gamma (9 steps)
;Sinfo = "Scale 27 selected"
Sinfo     sprintf   "%s", "27 Bohlen-Pierce Gamma Mode:\n9 steps per 3:1 (duodecima) with ratios 1, 27/25, 9/7, 7/5, 5/3, 9/5, 49/25, 7/3, 25/9" 
          outvalue  "bohlen-pierce", 6 
 elseif i(gkscale) == 28 then	;Harmonic (9 steps)
;Sinfo = "Scale 28 selected"
Sinfo     sprintf   "%s", "28 Bohlen-Pierce Harmonic Mode:\n9 steps per 3:1 (duodecima) with ratios 1, 27/25, 9/7, 7/5, 5/3, 9/5, 15/7, 7/3, 63/25" 
          outvalue  "bohlen-pierce", 7 
 elseif i(gkscale) == 29 then	;Lambda (9 steps)
;Sinfo = "Scale 29 selected"
Sinfo     sprintf   "%s", "29 Bohlen-Pierce Lambda Mode:\n9 steps per 3:1 (duodecima) with ratios 1, 25/21, 9/7, 7/5, 5/3, 9/5, 15/7, 7/3, 25/9" 
          outvalue  "bohlen-pierce", 8 
 elseif i(gkscale) == 30 then	;user defined
;Sinfo = "Scale 30 selected"
Sinfo     sprintf   "%s", "30 User defined\nYou can add your own description in the code at instr 4" 
          outvalue  "bohlen-pierce", 9 
 endif
          outvalue  "scsel1", (i(gkscale) < 11 ? 1 : 0) 
          outvalue  "scsel2", (i(gkscale) > 10 && i(gkscale) < 21 ? 1 : 0) 
          outvalue  "scsel3", (i(gkscale) > 20 ? 1 : 0) 
          outvalue  "info", Sinfo 
          turnoff 
  endin


  instr show_mid_event
ikey      =         p4 
ivel      =         p5 
ichn      =         p6 
Smidi_event sprintf "Key = %d\nVelocity = %d\nChannel = %d\n", ikey, ivel, ichn 
          outvalue  "midi_event", Smidi_event 
          turnoff 
  endin
  
  

  instr show_output 
;;SHOW OUTPUT OUT THE CURRENT EVENT 
ikey      =         p4 
ifreq     =         p5 
Skey      sprintf   "%d", ikey 
          outvalue  "key", Skey; key pressed 
icent     =         (log(ifreq / i(gktunfreq)) * 1200) / log(2) 
Scent     sprintf   "%.1f", icent 
          outvalue  "cent", Scent; cent difference in relation to the reference frequency 
          outvalue  "freq", ifreq 
inormfreq =         cpsmidinn(ikey); usual freq of the pressed key 
          outvalue  "normfreq", inormfreq 
icentdiff =         1200 * (log(ifreq/inormfreq) / log(2)); centdifference ifreq to inormfreq 
Scentdiff sprintf   "%.1f", icentdiff 
          outvalue  "centdiff", Scentdiff 
          turnoff 
  endin 

  instr play; playing one note

;;INPUT
ikey      notnum 
ivel      veloc 
ichn      midichn 
          event_i   "i", "show_mid_event", 0, 1, ikey, ivel, ichn ;show values 
          
;;IS THIS A NOTE TO SELECT A SCALE (= NOT TO BE PLAYED)?
 if ikey == i(gkgm1_key) && ichn == i(gkgm1_chn) then
gkscale   =         gkgm1_scl+1; set gkscale to the new value 
          event_i   "i", "show", 0, 1 
 elseif ikey == i(gkgm2_key) && ichn == i(gkgm2_chn) then
gkscale   =         gkgm2_scl+1 
          event_i   "i", "show", 0, 1 
 elseif ikey == i(gkgm3_key) && ichn == i(gkgm3_chn) then
gkscale   =         gkgm3_scl+1 
          event_i   "i", "show", 0, 1 
 elseif ikey == i(gkgm4_key) && ichn == i(gkgm4_chn) then
gkscale   =         gkgm4_scl+1 
          event_i   "i", "show", 0, 1 
 elseif ikey == i(gkgm5_key) && ichn == i(gkgm5_chn) then
gkscale   =         gkgm5_scl+1 
          event_i   "i", "show", 0, 1 
 elseif ikey == i(gkgm6_key) && ichn == i(gkgm6_chn) then
gkscale   =         gkgm6_scl+1 
          event_i   "i", "show", 0, 1 
 elseif ikey == i(gkgm7_key) && ichn == i(gkgm7_chn) then
gkscale   =         gkgm7_scl+1 
          event_i   "i", "show", 0, 1 
 elseif ikey == i(gkgm8_key) && ichn == i(gkgm8_chn) then
gkscale   =         gkgm8_scl+1 
          event_i   "i", "show", 0, 1 
          
          else 
;;PLAY THE USUAL NOTE
ivel      =         ivel/127 
ireftone  =         i(gkreftone) 
itunfreq  =         i(gktunfreq) 
iscale    =         i(gkscale); 1-30 
istep     =         ikey - ireftone; how many steps (keys) higher or lower than the reftone 
ifreq     FreqByECRArr iscale-1, itunfreq, istep; calculation of the frequency 

;;SELECT OUTPUT SOUND
  if gksound == 0 then; sine
anote     poscil    ivel, ifreq, giSine 
  elseif gksound == 1 then; saw
anote     poscil    ivel, ifreq, giSaw 
  elseif gksound == 2 then; square
anote     poscil    ivel, ifreq, giSquare 
  elseif gksound == 3 then; square vco2
anote     vco2      ivel, ifreq, 10 
  elseif gksound == 4 then; pluck
anote     pluck     ivel, ifreq, ifreq, 0, 1 
  endif
aenv      linsegr   0, .1, 1, p3-0.1, 1, .1, 0 
aout      =         anote * aenv; calculate sound 
gadry     init      0
gadry     =         gadry + aout; add to global audio signal 

;;CALL SUBINSTRUMENT TO SHOW OUTPUT
          event_i   "i", "show_output", 0, 1, ikey, ifreq 
          
 endif

  endin


  instr reverb; global reverb and display
  
;;GUI INPUT
kwdmix    invalue   "wdmix";(between 0=dry und 1=reverberating) 
kroomsize invalue   "roomsize"; 0-1 (for freeverb) 
khfdamp   invalue   "hfdamp"; attenuation of high frequencies (0-1) (for freeverb) 
kvol      invalue   "vol" ;volume slider 
kvol      port      kvol, .1 ;smooth changes 
;;REVERB AND AUDIO OUTPUT
awetL, awetR freeverb gadry, gadry, kroomsize, khfdamp 
aoutL     =         (1-kwdmix) * gadry + (kwdmix * awetL) 
aoutR     =         (1-kwdmix) * gadry + (kwdmix * awetR) 
aoutL     =         aoutL * kvol 
aoutR     =         aoutR * kvol 
          outs      aoutL, aoutR 
;;SEND TO GUI
kTrigDisp metro     10 
          ShowLED_a "outL", aoutL, kTrigDisp, 1, 50 
          ShowLED_a "outR", aoutR, kTrigDisp, 1, 50 
          ShowOver_a "outLover", aoutL/0dbfs, kTrigDisp, 1 
          ShowOver_a "outRover", aoutR/0dbfs, kTrigDisp, 1 
		
;;RESET GLOBAL AUDIO
gadry     =         0 

  endin
</CsInstruments>
<CsScore>
i "init" 0 1
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>49</x>
 <y>9</y>
 <width>1290</width>
 <height>754</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>190</r>
  <g>188</g>
  <b>143</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1010</x>
  <y>17</y>
  <width>374</width>
  <height>773</height>
  <uuid>{9f76fd32-ca50-46b5-940d-820fe800928e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Scale Pool</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>key</objectName>
  <x>846</x>
  <y>595</y>
  <width>62</width>
  <height>27</height>
  <uuid>{3bc52c98-448f-4f87-bb44-571bbd00aa08}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>57</label>
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
  <x>391</x>
  <y>595</y>
  <width>457</width>
  <height>28</height>
  <uuid>{58bf0432-9be8-42aa-a453-521fd719a63f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Key Pressed</label>
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
  <objectName>cent</objectName>
  <x>847</x>
  <y>623</y>
  <width>82</width>
  <height>27</height>
  <uuid>{47ed2c50-ebe4-4161-a4bd-b856a958806e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-312.0</label>
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
  <x>307</x>
  <y>623</y>
  <width>539</width>
  <height>27</height>
  <uuid>{6844d514-7a40-42a6-ab39-8a807fdea606}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Cent Difference in Relation to the Reference Frequency</label>
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
  <objectName>freq</objectName>
  <x>847</x>
  <y>649</y>
  <width>82</width>
  <height>27</height>
  <uuid>{7975f04a-23ae-4886-9391-3e348e3d82ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>218.478</label>
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
  <x>306</x>
  <y>649</y>
  <width>542</width>
  <height>29</height>
  <uuid>{c91d9759-0b82-4717-9621-a4d4cf004e1e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Frequency of this Key</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>753</x>
  <y>45</y>
  <width>252</width>
  <height>26</height>
  <uuid>{0a533a2f-56e9-45c3-b5c5-87962ec7dcf2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>jh &amp;&amp; rb 2010/2012/2014</label>
  <alignment>right</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>normfreq</objectName>
  <x>847</x>
  <y>675</y>
  <width>82</width>
  <height>28</height>
  <uuid>{88acc66e-3cfe-43ee-be10-59666b1b2e28}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>220.000</label>
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
  <x>307</x>
  <y>675</y>
  <width>541</width>
  <height>29</height>
  <uuid>{28b05a3e-f445-486e-9945-664136d7b390}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Usual Frequency of this Key</label>
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
  <objectName>centdiff</objectName>
  <x>847</x>
  <y>701</y>
  <width>82</width>
  <height>30</height>
  <uuid>{bb3b02d4-0dfd-44fc-8d2c-a9dd3925a597}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-12.0</label>
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
  <x>307</x>
  <y>701</y>
  <width>541</width>
  <height>31</height>
  <uuid>{3f7fe471-d23f-4472-a3eb-de1edd3334c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Cent Difference Real Frequency to Usual Frequency</label>
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
  <objectName>info</objectName>
  <x>276</x>
  <y>476</y>
  <width>710</width>
  <height>109</height>
  <uuid>{b6a1d2d0-6f91-4261-9e77-d46b08bc421c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>13 Werckmeister III temperature (1691) with cent values
0, 90, 192, 294, 390, 498, 588, 696, 792, 888, 996, 1092
(after Klaus Lang, Auf Wohlklangswellen durch der Toene Meer, Graz 1999, BEM 10, p. 97)</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>237</r>
   <g>169</g>
   <b>107</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>466</x>
  <y>45</y>
  <width>91</width>
  <height>27</height>
  <uuid>{7e1ef5ca-2594-48c8-abef-8c52de3f2ad9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>START</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Stop</objectName>
  <x>580</x>
  <y>45</y>
  <width>91</width>
  <height>27</height>
  <uuid>{48ac72cc-9099-4bd7-8736-446ab91b48e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>STOP</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>vol</objectName>
  <x>314</x>
  <y>769</y>
  <width>250</width>
  <height>28</height>
  <uuid>{ac58723d-0e06-4f05-bd62-b9647a2947b0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.54800000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>349</x>
  <y>740</y>
  <width>97</width>
  <height>27</height>
  <uuid>{687143f9-ea96-4984-8e67-5597ffa3f81d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Volume</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>outL</objectName>
  <x>579</x>
  <y>745</y>
  <width>336</width>
  <height>22</height>
  <uuid>{56692e84-8339-4713-bedf-b81a5d5dea6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out1_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-4.57804129</xValue>
  <yValue>0.36363600</yValue>
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
  <x>913</x>
  <y>745</y>
  <width>27</width>
  <height>22</height>
  <uuid>{9dbc1525-61ed-4dcc-aeb3-650eb87744db}</uuid>
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
  <x>579</x>
  <y>771</y>
  <width>336</width>
  <height>22</height>
  <uuid>{09a3dabb-c32b-4652-b07c-a5149e90b11b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>-4.69263388</xValue>
  <yValue>0.52631600</yValue>
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
  <x>913</x>
  <y>771</y>
  <width>27</width>
  <height>22</height>
  <uuid>{d515ef65-7c19-46c4-a888-c5cbc4e5653c}</uuid>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>vol</objectName>
  <x>444</x>
  <y>740</y>
  <width>98</width>
  <height>27</height>
  <uuid>{7e4a0ff0-63bb-41fe-a64c-41c8dc65828b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.5480</label>
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
  <x>447</x>
  <y>7</y>
  <width>449</width>
  <height>38</height>
  <uuid>{460c390f-19ce-46a2-ae4e-2ca424395160}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>PLAYING SCALES WITH A MIDI KEYBOARD</label>
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
  <x>430</x>
  <y>71</y>
  <width>576</width>
  <height>38</height>
  <uuid>{321ab18e-c680-4bd3-81ae-696ef1e02fe2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>This CSD was designed to let you play virtually any scale with a standard MIDI keyboard. </label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>431</x>
  <y>108</y>
  <width>158</width>
  <height>25</height>
  <uuid>{1f650c2a-caaa-45d1-8405-66a7b7ab147a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>PLAYING</label>
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
  <x>431</x>
  <y>131</y>
  <width>578</width>
  <height>78</height>
  <uuid>{c6919d13-0dde-4b29-8628-3e8f74241f42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Just connect your MIDI keyboard (see the Configuration panel to select the MIDI input). Press START, select a scale from one of the menus on the left, and select a sound. If you wish, you can associate and trigger up to 8 scales with specific MIDI keys thereby allowing for fast switching and easy comparison.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>431</x>
  <y>207</y>
  <width>466</width>
  <height>27</height>
  <uuid>{36e69f68-86a5-436a-a774-0d64767cd5f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>ADDING USER DEFINED or NEW SCALES</label>
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
  <x>431</x>
  <y>233</y>
  <width>583</width>
  <height>155</height>
  <uuid>{41ba012c-7cc4-4060-a02e-05afaf5762b7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>In the Scale Pool at the right you find a number of predefined scales. You can add any scale in the "User Defined" slots (10,17,18,19,20,30), or you can change or replace any of the scales in the following way:
Type in the FIRST VALUE as the UNIT MULTIPLIER (2 = octave, 3 = perfect 12th, etc.).
The SECOND VALUE lets you choose between three cases:
1) if you type 0 you are giving a list of CENT values;
2) if you type 1 you are giving a list of PROPORTIONS;
3) any other value indicates an Equal Tempered Scale and gives as the second value the number of steps per Unit Multiplier.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>431</x>
  <y>387</y>
  <width>584</width>
  <height>78</height>
  <uuid>{bf72fd7e-bb12-4d4f-acb9-d21ac8b8c3e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>NOTE: When you select a BP mode, it consists of 9 pitches (a unique subset of the 13 BP chromatic tones) and it is played on a MIDI keyboard chromatically starting from the REFERENCE KEY.  The 10th pitch is the "tritave" - a pure perfect 12th (an octave plus 5th) or a 3:1 frequency ratio.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>3</x>
  <y>33</y>
  <width>422</width>
  <height>217</height>
  <uuid>{8fee01a4-6aff-4a18-b9d3-682fd8b62927}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
   <r>222</r>
   <g>143</g>
   <b>206</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>sound</objectName>
  <x>201</x>
  <y>220</y>
  <width>165</width>
  <height>25</height>
  <uuid>{fcbc67a7-51c0-4ca5-94e3-98229024c81a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>sine</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>saw</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>square</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>square vco2</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>pluck</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>4</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>43</x>
  <y>216</y>
  <width>160</width>
  <height>31</height>
  <uuid>{89a47f25-152d-40af-a3a2-0d2499bbdbc2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Select Sound</label>
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
 <bsbObject version="2" type="BSBController">
  <objectName>scsel1</objectName>
  <x>23</x>
  <y>189</y>
  <width>104</width>
  <height>23</height>
  <uuid>{fa1d2e5d-12c8-4900-af8a-b5a4feebf74f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>vert34</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.43478300</yValue>
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
  <objectName>scsel2</objectName>
  <x>154</x>
  <y>189</y>
  <width>104</width>
  <height>23</height>
  <uuid>{39ac622a-56e3-4d32-a2e9-b8f85dbec7b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>vert34</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>1.00000000</xValue>
  <yValue>0.43478300</yValue>
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
  <objectName>scsel3</objectName>
  <x>285</x>
  <y>189</y>
  <width>104</width>
  <height>23</height>
  <uuid>{5b35e488-40f1-4be1-9dc2-079192003890}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>vert34</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.43478300</yValue>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>tunfreq</objectName>
  <x>313</x>
  <y>44</y>
  <width>107</width>
  <height>26</height>
  <uuid>{c014f205-06aa-45df-be4c-8b8bb3583229}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
  <resolution>0.00000100</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>261.625</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>206</x>
  <y>44</y>
  <width>108</width>
  <height>28</height>
  <uuid>{a9440b0b-595c-4c9b-b112-b55b7cd728bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Related Pitch</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>227</x>
  <y>65</y>
  <width>72</width>
  <height>25</height>
  <uuid>{04c0e64a-16bb-4ddb-b286-62d57f752e34}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>(Hertz)</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>equal_tmprd</objectName>
  <x>12</x>
  <y>167</y>
  <width>126</width>
  <height>24</height>
  <uuid>{5ee933a0-615a-4995-b661-f16a24a14150}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>1 Halftones</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2 Thirdtones</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3 Quartertones</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4 Fifthtones</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>5 Sixthtones</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>6 Eighttones</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>7 Twelfthtones</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8 Sixteenthtones</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>9 Stockhausen Studie II</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10 UserDefined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>5</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>93</y>
  <width>393</width>
  <height>30</height>
  <uuid>{8cc05c0f-ad73-46ae-ace2-556caad97763}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Select Scale By Menu</label>
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
  <objectName>reftone</objectName>
  <x>136</x>
  <y>44</y>
  <width>62</width>
  <height>26</height>
  <uuid>{d62aecdf-74ab-43d1-a501-549e1973297c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <minimum>0</minimum>
  <maximum>127</maximum>
  <randomizable group="0">false</randomizable>
  <value>60</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>44</y>
  <width>130</width>
  <height>28</height>
  <uuid>{88e4e2ee-f553-4356-8ea4-554dfc18d3d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Reference Key</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>8</x>
  <y>67</y>
  <width>129</width>
  <height>27</height>
  <uuid>{d80338cb-8182-4796-a1ae-8a922f0d03cf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>(Midi-Number)</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>15</x>
  <y>120</y>
  <width>121</width>
  <height>47</height>
  <uuid>{2b882335-a79a-4ce8-b5c7-15e51e2a2c4b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Equal Tempered
(1-10)</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>various</objectName>
  <x>141</x>
  <y>167</y>
  <width>132</width>
  <height>24</height>
  <uuid>{64462832-bfe5-491c-8b85-6c00f2062b17}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>11 Pythagorean</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12 Zarlino 1/4 Comma</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13 Werckmeister III</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14 Kirnberger II</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15 Indian Sruti I</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16 Indian Sruti II</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17 User Defined</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18 User Defined</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19 User Defined</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20 User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>148</x>
  <y>120</y>
  <width>121</width>
  <height>47</height>
  <uuid>{79d233f5-b289-442a-a78f-bc2a90c32392}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Various
(11-20)</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>bohlen-pierce</objectName>
  <x>275</x>
  <y>167</y>
  <width>136</width>
  <height>24</height>
  <uuid>{dd3f6092-bad8-4ae1-8e90-044dab957c1d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>21 Equal Tempered</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22 Ratios</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23 Dur I Mode</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24 Dur II Mode</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25 Moll I (Delta) Mode</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26 Moll II (Pierce) Mode</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27 Gamma Mode</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28 Harmonic Mode</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29 Lambda Mode</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30 User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>278</x>
  <y>120</y>
  <width>121</width>
  <height>47</height>
  <uuid>{6d2e6268-a18a-4196-b14c-eb4a6afada8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Bohlen-Pierce
(21-30)</label>
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
  <x>4</x>
  <y>256</y>
  <width>261</width>
  <height>311</height>
  <uuid>{50c3bfda-28ab-4c5a-82c0-14459384a68a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
   <r>222</r>
   <g>143</g>
   <b>206</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>gm1_scale</objectName>
  <x>10</x>
  <y>323</y>
  <width>108</width>
  <height>25</height>
  <uuid>{94cd0db6-ab80-4318-ada1-489baaa49a6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>1 Halftones</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2 Thirdtones</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3 Quartertones</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4 Fifthtones</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>5 Sixthtones</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>6 Eighttones</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>7 Twelfthtones</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8 Sixteenthtones</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>9 Stockhausen Studie II</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10 User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11 Pythagorean</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12 Zarlino 1/4 Comma</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13 Werckmeister III</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14 Kirnberger II</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15 Indian Sruti I</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16 Indian Sruti II</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17 User Defined</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18 User Defined</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19 User Defined</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20 User Defined</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21 BP Equal Tempered</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22 BP Ratios</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23 BP Dur I Mode</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24 BP Dur II Mode</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25 BP Moll I (Delta) Mode</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26 BP Moll II (Pierce) Mode</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27 BP Gamma Mode</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28 BP Harmonic Mode</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29 BP Lambda Mode</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30 User Defined</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm1_key</objectName>
  <x>124</x>
  <y>323</y>
  <width>61</width>
  <height>25</height>
  <uuid>{4edbfe44-aa5a-4cb1-811e-817d739605e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <minimum>0</minimum>
  <maximum>127</maximum>
  <randomizable group="0">false</randomizable>
  <value>36</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm1_chn</objectName>
  <x>188</x>
  <y>323</y>
  <width>61</width>
  <height>25</height>
  <uuid>{7a93960a-e5d8-4940-b320-4212e941ed6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>18</x>
  <y>293</y>
  <width>83</width>
  <height>27</height>
  <uuid>{34ddb657-9510-4824-b955-89185b1d6a71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Scale</label>
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
  <x>125</x>
  <y>293</y>
  <width>50</width>
  <height>27</height>
  <uuid>{391a889d-de9b-4019-af3b-ae4ab68fb663}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Key</label>
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
  <x>181</x>
  <y>293</y>
  <width>73</width>
  <height>27</height>
  <uuid>{b056127d-4963-413f-9b90-f3df8811af4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Channel</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>gm2_scale</objectName>
  <x>10</x>
  <y>354</y>
  <width>108</width>
  <height>25</height>
  <uuid>{a4ae0f35-4e5a-4480-b043-89f1256211cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>1 Halftones</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2 Thirdtones</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3 Quartertones</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4 Fifthtones</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>5 Sixthtones</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>6 Eighttones</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>7 Twelfthtones</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8 Sixteenthtones</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>9 Stockhausen Studie II</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10 User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11 Pythagorean</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12 Zarlino 1/4 Comma</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13 Werckmeister III</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14 Kirnberger II</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15 Indian Sruti I</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16 Indian Sruti II</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17 User Defined</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18 User Defined</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19 User Defined</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20 User Defined</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21 BP Equal Tempered</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22 BP Ratios</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23 BP Dur I Mode</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24 BP Dur II Mode</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25 BP Moll I (Delta) Mode</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26 BP Moll II (Pierce) Mode</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27 BP Gamma Mode</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28 BP Harmonic Mode</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29 BP Lambda Mode</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30 User Defined</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>11</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm2_key</objectName>
  <x>124</x>
  <y>354</y>
  <width>61</width>
  <height>25</height>
  <uuid>{048b8812-0d96-4035-b4bb-9000b1786f02}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <minimum>0</minimum>
  <maximum>127</maximum>
  <randomizable group="0">false</randomizable>
  <value>37</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm2_chn</objectName>
  <x>188</x>
  <y>354</y>
  <width>61</width>
  <height>25</height>
  <uuid>{31698544-6623-484c-99d2-14945339d4c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>gm3_scale</objectName>
  <x>10</x>
  <y>382</y>
  <width>108</width>
  <height>25</height>
  <uuid>{ebc0eda5-bfae-4055-b3c1-4c45d8c0df99}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>1 Halftones</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2 Thirdtones</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3 Quartertones</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4 Fifthtones</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>5 Sixthtones</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>6 Eighttones</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>7 Twelfthtones</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8 Sixteenthtones</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>9 Stockhausen Studie II</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10 User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11 Pythagorean</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12 Zarlino 1/4 Comma</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13 Werckmeister III</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14 Kirnberger II</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15 Indian Sruti I</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16 Indian Sruti II</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17 User Defined</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18 User Defined</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19 User Defined</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20 User Defined</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21 BP Equal Tempered</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22 BP Ratios</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23 BP Dur I Mode</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24 BP Dur II Mode</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25 BP Moll I Mode</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26 BP Moll II Mode</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27 BP Gamma Mode</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28 BP Harmonic Mode</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29 BP Lambda Mode</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30 User Defined</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>20</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm3_key</objectName>
  <x>124</x>
  <y>382</y>
  <width>61</width>
  <height>25</height>
  <uuid>{7d8605f3-241c-4e8e-8e8d-df51359091ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <minimum>0</minimum>
  <maximum>127</maximum>
  <randomizable group="0">false</randomizable>
  <value>38</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm3_chn</objectName>
  <x>188</x>
  <y>382</y>
  <width>61</width>
  <height>25</height>
  <uuid>{8ac519ad-9dfa-44f3-82a4-a55c607e29c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>gm4_scale</objectName>
  <x>10</x>
  <y>413</y>
  <width>108</width>
  <height>25</height>
  <uuid>{3a87415d-126b-4a43-80dd-cb5f8f076713}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>1 Halftones</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2 Thirdtones</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3 Quartertones</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4 Fifthtones</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>5 Sixthtones</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>6 Eighttones</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>7 Twelfthtones</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8 Sixteenthtones</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>9 Stockhausen Studie II</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10 User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11 Pythagorean</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12 Zarlino 1/4 Comma</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13 Werckmeister III</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14 Kirnberger II</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15 Indian Sruti I</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16 Indian Sruti II</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17 User Defined</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18 User Defined</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19 User Defined</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20 User Defined</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21 BP Equal Tempered</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22 BP Ratios</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23 BP Dur I Mode</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24 BP Dur II Mode</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25 BP Moll I (Delta) Mode</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26 BP Moll II (Pierce) Mode</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27 BP Gamma Mode</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28 BP Harmonic Mode</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29 BP Lambda Mode</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30 User Defined</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm4_key</objectName>
  <x>124</x>
  <y>413</y>
  <width>61</width>
  <height>25</height>
  <uuid>{316bb9bd-fb55-4852-b227-dad4cd7794b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <minimum>0</minimum>
  <maximum>127</maximum>
  <randomizable group="0">false</randomizable>
  <value>40</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm4_chn</objectName>
  <x>188</x>
  <y>413</y>
  <width>61</width>
  <height>25</height>
  <uuid>{1807bde7-43ce-4994-b20c-ade301dbfc88}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>gm5_scale</objectName>
  <x>10</x>
  <y>441</y>
  <width>108</width>
  <height>25</height>
  <uuid>{274ebd83-0d72-4a70-ad7b-8473364c9392}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>1 Halftones</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2 Thirdtones</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3 Quartertones</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4 Fifthtones</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>5 Sixthtones</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>6 Eighttones</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>7 Twelfthtones</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8 Sixteenthtones</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>9 Stockhausen Studie II</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10 User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11 Pythagorean</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12 Zarlino 1/4 Comma</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13 Werckmeister III</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14 Kirnberger II</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15 Indian Sruti I</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16 Indian Sruti II</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17 User Defined</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18 User Defined</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19 User Defined</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20 User Defined</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21 BP Equal Tempered</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22 BP Ratios</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23 BP Dur I Mode</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24 BP Dur II Mode</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25 BP Moll I Mode</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26 BP Moll II Mode</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27 BP Gamma Mode</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28 BP Harmonic Mode</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29 BP Lambda Mode</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30 User Defined</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>25</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm5_key</objectName>
  <x>124</x>
  <y>441</y>
  <width>61</width>
  <height>25</height>
  <uuid>{67a7e03e-f0ad-4092-b182-7361c1b7bd78}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <minimum>0</minimum>
  <maximum>127</maximum>
  <randomizable group="0">false</randomizable>
  <value>41</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm5_chn</objectName>
  <x>188</x>
  <y>441</y>
  <width>61</width>
  <height>25</height>
  <uuid>{f146f09c-4288-4042-8561-6e27cb9e4eff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>gm6_scale</objectName>
  <x>10</x>
  <y>472</y>
  <width>108</width>
  <height>25</height>
  <uuid>{d34a9233-6773-44c6-b327-2b93b34f9aa7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>1 Halftones</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2 Thirdtones</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3 Quartertones</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4 Fifthtones</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>5 Sixthtones</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>6 Eighttones</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>7 Twelfthtones</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8 Sixteenthtones</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>9 Stockhausen Studie II</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10 User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11 Pythagorean</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12 Zarlino 1/4 Comma</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13 Werckmeister III</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14 Kirnberger II</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15 Indian Sruti I</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16 Indian Sruti II</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17 User Defined</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18 User Defined</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19 User Defined</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20 User Defined</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21 BP Equal Tempered</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22 BP Ratios</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23 BP Dur I Mode</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24 BP Dur II Mode</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25 BP Moll I (Delta) Mode</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26 BP Moll II (Pierce) Mode</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27 BP Gamma Mode</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28 BP Harmonic Mode</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29 BP Lambda Mode</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30 User Defined</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>10</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm6_key</objectName>
  <x>124</x>
  <y>472</y>
  <width>61</width>
  <height>25</height>
  <uuid>{654afdbe-6baf-4630-baf9-583b50e9e93f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <minimum>0</minimum>
  <maximum>127</maximum>
  <randomizable group="0">false</randomizable>
  <value>43</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm6_chn</objectName>
  <x>188</x>
  <y>472</y>
  <width>61</width>
  <height>25</height>
  <uuid>{370d1312-dc97-4f4b-91c9-fd439ad33c63}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>gm7_scale</objectName>
  <x>10</x>
  <y>500</y>
  <width>108</width>
  <height>25</height>
  <uuid>{551dd85c-08f1-4aee-90c3-03ce89cdeae1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>1 Halftones</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2 Thirdtones</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3 Quartertones</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4 Fifthtones</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>5 Sixthtones</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>6 Eighttones</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>7 Twelfthtones</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8 Sixteenthtones</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>9 Stockhausen Studie II</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10 User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11 Pythagorean</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12 Zarlino 1/4 Comma</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13 Werckmeister III</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14 Kirnberger II</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15 Indian Sruti I</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16 Indian Sruti II</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17 User Defined</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18 User Defined</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19 User Defined</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20 User Defined</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21 BP Equal Tempered</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22 BP Ratios</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23 BP Dur I Mode</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24 BP Dur II Mode</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25 BP Moll I (Delta) Mode</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26 BP Moll II (Pierce) Mode</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27 BP Gamma Mode</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28 BP Harmonic Mode</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29 BP Lambda Mode</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30 User Defined</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>12</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm7_key</objectName>
  <x>124</x>
  <y>500</y>
  <width>61</width>
  <height>25</height>
  <uuid>{2c4c42b0-7616-4e5a-acb9-1fd5bfb6378c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <minimum>0</minimum>
  <maximum>127</maximum>
  <randomizable group="0">false</randomizable>
  <value>45</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm7_chn</objectName>
  <x>188</x>
  <y>500</y>
  <width>61</width>
  <height>25</height>
  <uuid>{0784db53-0760-4631-a367-64f2eb53dabf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>gm8_scale</objectName>
  <x>10</x>
  <y>531</y>
  <width>108</width>
  <height>25</height>
  <uuid>{b9e13efc-7de6-4c27-94b5-35d922782236}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>1 Halftones</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2 Thirdtones</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>3 Quartertones</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>4 Fifthtones</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>5 Sixthtones</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>6 Eighttones</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>7 Twelfthtones</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>8 Sixteenthtones</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>9 Stockhausen Studie II</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>10 User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>11 Pythagorean</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>12 Zarlino 1/4 Comma</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>13 Werckmeister III</name>
    <value>12</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>14 Kirnberger II</name>
    <value>13</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>15 Indian Sruti I</name>
    <value>14</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>16 Indian Sruti II</name>
    <value>15</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>17 User Defined</name>
    <value>16</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>18 User Defined</name>
    <value>17</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>19 User Defined</name>
    <value>18</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>20 User Defined</name>
    <value>19</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>21 BP Equal Tempered</name>
    <value>20</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>22 BP Ratios</name>
    <value>21</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>23 BP Dur I Mode</name>
    <value>22</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>24 BP Dur II Mode</name>
    <value>23</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>25 BP Moll I (Delta) Mode</name>
    <value>24</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>26 BP Moll II (Pierce) Mode</name>
    <value>25</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>27 BP Gamma Mode</name>
    <value>26</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>28 BP Harmonic Mode</name>
    <value>27</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>29 BP Lambda Mode</name>
    <value>28</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>30 User Defined</name>
    <value>29</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>4</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm8_key</objectName>
  <x>124</x>
  <y>531</y>
  <width>61</width>
  <height>25</height>
  <uuid>{7f6a41d8-2c24-4e30-a513-a0c8576a9673}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <minimum>0</minimum>
  <maximum>127</maximum>
  <randomizable group="0">false</randomizable>
  <value>47</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>gm8_chn</objectName>
  <x>188</x>
  <y>531</y>
  <width>61</width>
  <height>25</height>
  <uuid>{74754e99-71ea-4e0b-a34b-ad9ae57445a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
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
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>263</y>
  <width>252</width>
  <height>31</height>
  <uuid>{61aaff8a-e262-49a0-b834-8e124e9340e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Select Scale By MIDI Keys</label>
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
  <x>2</x>
  <y>597</y>
  <width>261</width>
  <height>201</height>
  <uuid>{764f7fce-c3ca-4869-a1f4-90a5bd098426}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Reverb (freeverb)</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>wdmix</objectName>
  <x>52</x>
  <y>642</y>
  <width>160</width>
  <height>28</height>
  <uuid>{05f629ba-fed7-41ac-9efd-f1614cf08fa9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.43125000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>3</x>
  <y>643</y>
  <width>49</width>
  <height>25</height>
  <uuid>{e522ff72-282b-4b83-948a-952b9d2b7664}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Dry</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>212</x>
  <y>644</y>
  <width>48</width>
  <height>25</height>
  <uuid>{a556f13f-b772-4baf-8d29-b4d955f36bda}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Wet</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>73</x>
  <y>619</y>
  <width>109</width>
  <height>24</height>
  <uuid>{2b72ce0e-23e3-4903-a4be-3d1c03bf14f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Mix</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>roomsize</objectName>
  <x>51</x>
  <y>694</y>
  <width>161</width>
  <height>30</height>
  <uuid>{c92bd11e-57a8-4b00-a2f0-5172e2382e8f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.42857143</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1</x>
  <y>696</y>
  <width>50</width>
  <height>25</height>
  <uuid>{f955e85e-6c4d-4908-9710-c3d6559a5408}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Small</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>210</x>
  <y>696</y>
  <width>52</width>
  <height>24</height>
  <uuid>{aadcb08e-dfaf-47c2-b913-19bd09dd0e5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Large</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>72</x>
  <y>670</y>
  <width>110</width>
  <height>24</height>
  <uuid>{094b23b0-6d2a-4f79-b03f-8a7473b41956}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Room Size</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>hfdamp</objectName>
  <x>46</x>
  <y>753</y>
  <width>160</width>
  <height>31</height>
  <uuid>{6f8db5c1-b0b6-4740-ae4c-b32b0d6b2b9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.36875000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>2</x>
  <y>756</y>
  <width>44</width>
  <height>26</height>
  <uuid>{615df0d8-51da-4a6f-82dd-6360b33f98ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>No</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>204</x>
  <y>757</y>
  <width>59</width>
  <height>25</height>
  <uuid>{2bfde5cc-dc42-4add-a9ec-1346575f5f53}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Yes</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>40</x>
  <y>723</y>
  <width>175</width>
  <height>30</height>
  <uuid>{c8577a79-24bc-4075-8d88-d66383ea66ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>High Frequency Attenuation</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale1</objectName>
  <x>1156</x>
  <y>51</y>
  <width>220</width>
  <height>24</height>
  <uuid>{41924a59-97b1-43bc-8481-d36acf53cc47}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 12</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>50</y>
  <width>138</width>
  <height>26</height>
  <uuid>{47e38419-62ba-460b-a267-7cf6da2f961e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1 Halftones</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale2</objectName>
  <x>1156</x>
  <y>75</y>
  <width>220</width>
  <height>24</height>
  <uuid>{148c7136-1bf7-4c90-839e-2a2687c7773f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 18</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>75</y>
  <width>138</width>
  <height>26</height>
  <uuid>{ca945a81-40a8-49e4-b4ce-f3c440c2b42f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 Thirdtones</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale3</objectName>
  <x>1156</x>
  <y>99</y>
  <width>220</width>
  <height>24</height>
  <uuid>{b4667509-0101-4453-8b9b-fe8920cbcf93}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 24</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>99</y>
  <width>138</width>
  <height>26</height>
  <uuid>{726509f4-50ff-4564-9e2a-b1c786b962f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 Quartertones</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale4</objectName>
  <x>1156</x>
  <y>124</y>
  <width>220</width>
  <height>24</height>
  <uuid>{3a86087a-c910-4e2d-8aa8-06078cbd63b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 30</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>124</y>
  <width>138</width>
  <height>26</height>
  <uuid>{0025791b-f77a-439a-b39e-7c9ff252c8b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4 Fifthtones</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale5</objectName>
  <x>1156</x>
  <y>148</y>
  <width>220</width>
  <height>24</height>
  <uuid>{5db08c35-cf97-4111-8f52-fb05460e4e0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 36</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>148</y>
  <width>138</width>
  <height>26</height>
  <uuid>{a31c3cf5-4e7d-4314-8700-fbf3badf98c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>5 Sixthtones</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale6</objectName>
  <x>1156</x>
  <y>173</y>
  <width>220</width>
  <height>24</height>
  <uuid>{4127e44d-5013-4b66-95f1-d0c0a42fd1bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 48</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>173</y>
  <width>138</width>
  <height>26</height>
  <uuid>{cfb79d3e-2555-43a6-af4c-9289b9673791}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>6 Eighttones</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale7</objectName>
  <x>1156</x>
  <y>197</y>
  <width>220</width>
  <height>24</height>
  <uuid>{bf4933e2-13b2-4c42-a4a8-e40cb672cb81}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 72</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>197</y>
  <width>138</width>
  <height>26</height>
  <uuid>{5d94d8ff-6383-4486-9dca-41d0c51deab0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>7 Twelfthtones</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale8</objectName>
  <x>1156</x>
  <y>222</y>
  <width>220</width>
  <height>24</height>
  <uuid>{1af2b968-3f9d-4b8a-895d-ce312149c3b3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 96</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>222</y>
  <width>138</width>
  <height>26</height>
  <uuid>{a1abea1c-f33e-4dd9-9c64-677f4b8cfddc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>8 Sixteenthtones</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale9</objectName>
  <x>1156</x>
  <y>245</y>
  <width>220</width>
  <height>24</height>
  <uuid>{5db50544-26b2-47b2-b93e-6b028c94b79d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>5 25</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>245</y>
  <width>138</width>
  <height>26</height>
  <uuid>{a43bea2e-a2ee-4004-ac9e-002877d3c6ed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>9 Stockhausen Studie II</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale10</objectName>
  <x>1156</x>
  <y>270</y>
  <width>220</width>
  <height>24</height>
  <uuid>{166d0f00-2be7-413d-93f9-f24f6e03aed6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 0 76 193 310 386 503 579 697 773 890 1007 1083</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>270</y>
  <width>138</width>
  <height>26</height>
  <uuid>{0ff548f1-c6b9-42e2-a499-e16f8849045f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>10 User Defined</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale11</objectName>
  <x>1156</x>
  <y>294</y>
  <width>220</width>
  <height>24</height>
  <uuid>{b5593333-b902-4ce2-b4fa-5f516ea3ff23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 1 2187/2048 9/8 32/27 81/64 4/3 729/512 3/2 6561/4096 27/16 16/9 243/128</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>294</y>
  <width>138</width>
  <height>26</height>
  <uuid>{a423fbc0-cc68-4629-85aa-8f481b3139f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>11 Pythagorean</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale12</objectName>
  <x>1156</x>
  <y>319</y>
  <width>220</width>
  <height>24</height>
  <uuid>{ead660d7-fc87-4ee7-a4b9-072d057c2aa4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 0 76 193 310 386 503 579 697 773 890 1007 1083</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>319</y>
  <width>138</width>
  <height>26</height>
  <uuid>{2cf5d943-5bcf-4661-b338-b9721e7c8917}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>12 Zarlino 1/4 Comma</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale13</objectName>
  <x>1156</x>
  <y>343</y>
  <width>220</width>
  <height>24</height>
  <uuid>{3a058ccc-fa3d-407e-9bc7-8245f6b0965a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 0 90 192 294 390 498 588 696 792 888 996 1092</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>343</y>
  <width>138</width>
  <height>26</height>
  <uuid>{e5546b76-099b-47b8-a13e-5ba6a491495b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>13 Werckmeister III</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale14</objectName>
  <x>1156</x>
  <y>368</y>
  <width>220</width>
  <height>24</height>
  <uuid>{8ae1ce39-54d9-406a-8ebd-caf9510bcac6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 0 90 204 294 386 498 590 702 792 895 996 1088</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>368</y>
  <width>138</width>
  <height>26</height>
  <uuid>{e2aaccf0-a0d3-4dbd-a237-019cf77d605c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>14 Kirnberger II</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale15</objectName>
  <x>1156</x>
  <y>392</y>
  <width>220</width>
  <height>24</height>
  <uuid>{9c571518-20fb-4b2f-a3d3-91248bcad372}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 0 90 112 182 204 294 316 386 408 498 520 590 610 702 792 814 884 906 996 1018 1088 1110</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>392</y>
  <width>138</width>
  <height>26</height>
  <uuid>{afd9fdfe-7be2-40c3-9421-3e22df9c8c8e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>15 Indian Sruti I</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale16</objectName>
  <x>1156</x>
  <y>417</y>
  <width>220</width>
  <height>24</height>
  <uuid>{4cea0667-fa01-4b06-9009-34485bfe62a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>2 0 68 135 200 263 325 385 444 501 557 612 666 719 771 822 872 921 969 1017 1064 1110 1155</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>417</y>
  <width>138</width>
  <height>26</height>
  <uuid>{12c5d630-064d-4b8a-89b6-cb167158fb41}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>16 Indian Sruti II</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale17</objectName>
  <x>1156</x>
  <y>440</y>
  <width>220</width>
  <height>24</height>
  <uuid>{da80b6f0-7db6-4c30-b796-0bb35da95d0d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 1 2^1/12 2^1/11 2^1/10 2^1/9 2^1/8 2^1/7 2^1/6 2^1/5 2^1/4 2^1/3 2^1/2 </label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>440</y>
  <width>138</width>
  <height>26</height>
  <uuid>{d4445e61-4c3d-4dc8-a198-e3c2ac272655}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>17 User Defined</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale18</objectName>
  <x>1156</x>
  <y>465</y>
  <width>220</width>
  <height>24</height>
  <uuid>{bf20c58c-cda9-4281-9d33-dfe23868ead1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 13</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>465</y>
  <width>138</width>
  <height>26</height>
  <uuid>{328ce731-1a06-48ee-921c-93e55971f145}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>18 User Defined</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale19</objectName>
  <x>1156</x>
  <y>489</y>
  <width>220</width>
  <height>24</height>
  <uuid>{83143afb-dfdc-4d2b-9992-c88ce0f6a2dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 12</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>489</y>
  <width>138</width>
  <height>26</height>
  <uuid>{5ac37219-6934-4896-8ef6-f586e712a2f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>19 User Defined</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale20</objectName>
  <x>1156</x>
  <y>514</y>
  <width>220</width>
  <height>24</height>
  <uuid>{20e8cf37-0ac9-4450-8dd4-b70c5a6aaeb6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 12</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>514</y>
  <width>138</width>
  <height>26</height>
  <uuid>{42d0d5df-6975-4cd5-809d-e3560fb76be6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>20 User Defined</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale21</objectName>
  <x>1156</x>
  <y>538</y>
  <width>220</width>
  <height>24</height>
  <uuid>{0a8fe8ca-3efe-4f22-a7ad-999b94cb4178}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 13</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>538</y>
  <width>138</width>
  <height>26</height>
  <uuid>{29d5a91d-ed88-4bb5-9fcf-2f5ab99477c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>21 BP Equal Tempered</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale22</objectName>
  <x>1156</x>
  <y>563</y>
  <width>220</width>
  <height>24</height>
  <uuid>{264738ea-cb2b-4cc5-be17-ac17ea7f337e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 27/25 25/21 9/7 7/5 75/49 5/3 9/5 49/25 15/7 7/3 63/25 25/9</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>563</y>
  <width>138</width>
  <height>26</height>
  <uuid>{9af90ad2-5c07-43f9-87b8-5a711a9096e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>22 BP Ratios</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale23</objectName>
  <x>1156</x>
  <y>586</y>
  <width>220</width>
  <height>24</height>
  <uuid>{d0a3b549-3434-449b-949e-36e0d509ffff}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 27/25 9/7 7/5 5/3 9/5 49/25 7/3 63/25</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>586</y>
  <width>138</width>
  <height>26</height>
  <uuid>{2ad8b869-ec31-45a3-8767-f44237a1d126}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>23 BP Dur I Mode</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale24</objectName>
  <x>1156</x>
  <y>611</y>
  <width>220</width>
  <height>24</height>
  <uuid>{fa85f026-2fc3-4e31-90fb-16f0f53136ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 25/21 9/7 7/5 5/3 9/5 15/7 7/3 63/25</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>611</y>
  <width>138</width>
  <height>26</height>
  <uuid>{af80d63e-d5eb-4adb-982c-4b00237e6160}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>24 BP Dur II Mode</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale25</objectName>
  <x>1156</x>
  <y>635</y>
  <width>220</width>
  <height>24</height>
  <uuid>{43124faa-e689-4af2-b29f-cdf06b58e766}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 25/21 9/7 75/49 5/3 9/5 15/7 7/3 25/9</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>635</y>
  <width>138</width>
  <height>26</height>
  <uuid>{bd925631-99bd-42d0-8134-b2d27f0e380b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>25 BP Moll I (Pierce) Mode </label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale26</objectName>
  <x>1156</x>
  <y>660</y>
  <width>220</width>
  <height>24</height>
  <uuid>{f5dabc23-5f3c-465a-a0d5-ee9ce9955943}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 27/25 9/7 7/5 5/3 9/5 15/7 7/3 25/9</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>660</y>
  <width>138</width>
  <height>26</height>
  <uuid>{7cf4bea9-f231-4db8-bf51-81bf6fa24d06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>26 BP Moll II (Delta) Mode</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale27</objectName>
  <x>1156</x>
  <y>684</y>
  <width>220</width>
  <height>24</height>
  <uuid>{3d8a2466-18ca-48e3-94d8-e349a7814f97}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 27/25 9/7 7/5 5/3 9/5 49/25 7/3 25/9</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>684</y>
  <width>138</width>
  <height>26</height>
  <uuid>{675ca19b-cf4f-46c8-ab64-b606dea3a710}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>27 BP Gamma Mode</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale28</objectName>
  <x>1156</x>
  <y>709</y>
  <width>220</width>
  <height>24</height>
  <uuid>{3768fb29-0b74-4640-b7f3-c45c95d3fb1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 27/25 9/7 7/5 5/3 9/5 15/7 7/3 63/25</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>709</y>
  <width>138</width>
  <height>26</height>
  <uuid>{c2485292-109a-4afd-bf12-667a05984b7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>28 BP Harmonic Mode</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale29</objectName>
  <x>1156</x>
  <y>733</y>
  <width>220</width>
  <height>24</height>
  <uuid>{644240e6-34ce-44c0-afe9-5c5733c98ef7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 25/21 9/7 7/5 5/3 9/5 15/7 7/3 25/9</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>733</y>
  <width>138</width>
  <height>26</height>
  <uuid>{e3d2642a-6c5b-425e-9b42-83ba92498712}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>29 BP Lambda Mode</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>scale30</objectName>
  <x>1156</x>
  <y>758</y>
  <width>220</width>
  <height>24</height>
  <uuid>{699ad52a-6334-4c81-85ed-b0c0c62dff8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3 13</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1018</x>
  <y>758</y>
  <width>138</width>
  <height>26</height>
  <uuid>{cb60f824-d334-4897-b678-8600ac4a0ede}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>30 User Defined</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>267</x>
  <y>375</y>
  <width>162</width>
  <height>93</height>
  <uuid>{30bb34d6-d258-4378-bd08-c2a4a8cd442d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>270</x>
  <y>378</y>
  <width>156</width>
  <height>59</height>
  <uuid>{834120d4-1a7f-401e-8671-9257529f95cc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Push here if you changed scales while Csound is running</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>new</objectName>
  <x>297</x>
  <y>436</y>
  <width>100</width>
  <height>30</height>
  <uuid>{4c65b8b1-6b84-49b5-9b41-86f4796e4005}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>New Values!</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>268</x>
  <y>257</y>
  <width>161</width>
  <height>111</height>
  <uuid>{6494ec80-5dcf-4335-ba2d-99aa2e2f31cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>277</x>
  <y>265</y>
  <width>137</width>
  <height>25</height>
  <uuid>{39a0c8be-fb8f-4a5e-9c79-f8694e516142}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Current MIDI Event</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>midi_event</objectName>
  <x>278</x>
  <y>288</y>
  <width>137</width>
  <height>71</height>
  <uuid>{b0139093-9747-4da9-aaf1-848c9c3b7589}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Key = 57
Velocity = 101
Channel = 1
</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
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
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="664" y="320" width="655" height="346" visible="true" loopStart="0" loopEnd="0">i "play" 0 1 60 
i "play" 1 1 62 
i "play" 2 1 64 
i "play" 3 1 65 
i "play" 4 1 67 </EventPanel>

<CsoundSynthesizer>
<CsOptions>
-odac -m0
</CsOptions>
<CsInstruments>
ksmps = 16
nchnls = 2
0dbfs = 1

;============================================================================;
;============================================================================;
;============================================================================;
;                  KARLHEINZ STOCKHAUSEN: STUDIE II (1954)                   ;
;============================================================================;
;============================================================================;
;                  GENERATED IN CSOUND BY JOACHIM HEINTZ                     ;
;                         VERSION 1, NOVEMBER 2009                           ;
;============================================================================;
;============================================================================;
;============================================================================;

;This version is not to execute Stockhausen's "Studie II" which can be easily;
;done by transcribing the original score. This is the generation of all      ;
;musical events in real time and from these basic principles:                ;
;1) the series 3 - 5 - 1 - 4 - 2, and                                        ;
;2) a number of decisions and "methods" (i.e. defined rules or processes) on ;
;different levels, to derive from the original series firstly expanded series;
;or squares of numbers, then a preliminary set of frequencies, durations     ;
;and amplitudes, and finally the musical events of the five parts of the     ;
;"Studie".                                                                   ;
;                                                                            ;
;If something follows a defined rule, it is also programmable.               ;
;Nevertheless, retracing the compositional process by programming reveals the;
;richly imaginative variety Stockhausen applied in "Studie II" and how       ;
;strongly the choice of a process was influenced by his musical intuitions.  ;
;His continuous attendance to the emerging and willingness to react with and ;
;within the original methods and procedures is the powerful message driven   ;
;home by this excercise.                                                     ;
;                                                                            ;
;This piece of work would not have been possible without the comprehensive   ;
;analysis by Heinz Silberhorn (Die Reihentechnik in Stockhausens Studie II,  ;
;Rohrdorfer Musikverlag 1980). Few white spaces are left; first and foremost ;
;the question for the envelopes. I am convinced that at least the            ;
;envelopes in parts 1 to 4 are derived from the series. In parts 2 and 4     ;
;the series of five are visible (see below). I hope that the means of these  ;
;derivations will be found and added to a later version.                     ;
;                                                                            ;
;In this first version I have not labelled, where Stockhausen's (mostly      ;
;small) deviations from the series were assumed and where these were omitted.;
;This will be part of later versions, which will give the user the choice    ;
;to either play the strictly serial or Stockhausen's version. There are a    ;
;number of addiotional ideas for later versions and corrections, suggestions ;
;and criticism (to jh at joachimheintz.de) are appreciated.                  ;
;                                                                            ;
;                                                                            ;
;     joachim heintz, 15.11.09                                               ;
;                                                                            ;
;                                               (for QuteCsound: TabWidth 70);



;============================================================================;
;============================================================================;
; CONTENTS                                                                   ;
;============================================================================;
; I. OPCODE-DEFINITIONS                                                      ;
;    A. GENERAL FUNCTIONS                                                    ;
;    B. MORE SPECIFIC METHODS FOR STOCKHAUSEN'S STUDIE II (SS2_...)          ;
;       1. ON THE GENERATION OF SERIES                                       ;
;       2. ON THE BASIC TABLES                                               ;
;       3. GENERATION OF TABLES OF ONE PARAMETER WITHIN ONE PART             ;
;       4. SPECIFIC PROCEDURES FOR CERTAIN PARTS                             ;
;       5. GENERATION OF STARTING TIMES                                      ;
;       6. AMPLITUDES AND ENVELOPES                                          ;
;       7. TRIGGERING THE EVENTS                                             ;
; II. GENERATION OF THE STRUCTURES AND SOUNDS                                ;
;    A. THE SERIES AND NUMBER SQUARES                                        ;
;    B. BASIC TABLES FOR FREQUENCIES, DURATIONS AND INTENSITIES              ;
;    C. EVENTS OF THE PARTS                                                  ;
;       1. PART 1                                                            ;
;       2. PART 2                                                            ;
;       3. PART 3                                                            ;
;       4. PART 4                                                            ;
;       5. PART 5                                                            ;
;       6. CODA                                                              ;
;       7. CALCULATION OF TOTAL DURATION AND SOUND OUTPUT                    ;
;       8. INSTRUMENT FOR GENERATING A SOUNDMIX/EVENT                        ;
;============================================================================;
;============================================================================;


;============================================================================;
;============================================================================;
;============================================================================;
; I. OPCODE-DEFINITIONS                                                      ;
;============================================================================;
;============================================================================;
;============================================================================;


;============================================================================;
;============================================================================;
;    A. GENERAL FUNCTIONS                                                    ;
;============================================================================;
;============================================================================;

  opcode TabCopyGroupIn_i, 0, iiiii
;to transfer a set of values from one table (array, list) to another. arguments:
;source table, first read index, number of read indices, target table, first write index 
isrc, istrtindx, ihowmany, idest, istrtwrite xin
ireadindx	=		istrtindx
loop:
ival		tab_i		ireadindx, isrc
		tabw_i		ival, istrtwrite, idest
istrtwrite	=		istrtwrite + 1
		loop_lt	ireadindx, 1, istrtindx+ihowmany, loop
  endop

  opcode TabMkPartCp_i, i, iiio
;copies ihowmany values starting at index istrtindx from source table isrc into
;a new table (starting with index istrtwrite with 0 as default) and returns
;its denomination icop
isrc, istrtindx, ihowmany, istrtwrite xin
icop		ftgen		0, 0, -(ihowmany + istrtwrite), -2, 0
ireadindx	=		istrtindx
loop:
ival		tab_i		ireadindx, isrc
		tabw_i		ival, istrtwrite, icop
istrtwrite	=		istrtwrite + 1
		loop_lt	ireadindx, 1, istrtindx+ihowmany, loop
		xout		icop
  endop

  opcode TabMkCp_i, i, i
;creates a new table icop as copy of isrc and returns its denomination
isrc		xin
isrclen	=		ftlen(isrc)
icop		ftgen		0, 0, -isrclen, -2, 0
		tableicopy	icop, isrc
		xout		icop
  endop

  opcode TabMultRecurs_i, i, iii
;sets istart to index 0 of a newly created table ift. multiplies the following values recursively with imult until isize is reached and returns ift
isize, istart, imult xin
ift		ftgen		0, 0, -isize, -2, 0
indx		=		0
loop:
ival		=		istart * (imult ^ indx)
		tabw_i		ival, indx, ift
		loop_lt	indx, 1, isize, loop
		xout		ift
  endop

  opcode TabMkNewByHop_i, i, ii
;creates a new table by hopping with step width ihop through ift. Returns iftres
ift, ihop	xin
ihowmany	=		ftlen(ift)
iftres		ftgen		0, 0, -ihowmany, -2, 0
indx		=		0
loop:
iread		=		indx * ihop
iread		=		(iread >= ihowmany ? iread % ihowmany : iread)
ival		tab_i		iread, ift
		tabw_i		ival, indx, iftres
		loop_lt	indx, 1, ihowmany, loop
		xout		iftres
  endop

  opcode TabMkTbFrmGrpMx_i, i, ii
;creates a new table containing the maxima from sets of indices in iftsrc, which are declared by iftgrp and returns the denomination iftout
iftsrc, iftgrp xin
iftout		ftgen		0, 0, -ftlen(iftgrp), -2, 0
indxiftgrp	=		0
indxabs	=		0
loop1:
indxels	=		0
igrplen	tab_i		indxiftgrp, iftgrp
icomval	tab_i		indxabs, iftsrc; comparison to first value of every set
loop2:
ival		tab_i		indxabs, iftsrc
icomval	=		(ival > icomval ? ival : icomval)
indxabs	=		indxabs + 1
		loop_lt	indxels, 1, igrplen, loop2
		tabw_i		icomval, indxiftgrp, iftout
		loop_lt	indxiftgrp, 1, ftlen(iftgrp), loop1
		xout		iftout
  endop

  opcode TabRvrs_i, i, i
;returns a copy of iftin in reverse order as iftout
iftin	 	xin
iftlen		=		ftlen(iftin)
iftout		ftgen		0, 0, -iftlen, -2, 0
		tableicopy	iftout, iftin
indx		=		0
loop:
iread		tab_i		indx, iftin
		tabw_i		iread, iftlen-indx-1, iftout
		loop_lt	indx, 1, iftlen, loop
		xout		iftout
  endop

  opcode TabValIn, i, ii
;finds whether any of the values in a table itable is equal to ivalsuch
;returns the index of the identical value or -1 if no equal value is found 
ivalsuch, itable 	xin
ilen		=	ftlen(itable)
indx		init	0
loop:
ival		tab_i	indx, itable
iresult	=	(ival == ivalsuch ? indx : -1)
indx		=	indx + 1
if iresult == -1 && indx < ilen igoto loop
		xout	iresult
  endop

  opcode TableAppend2_i, i, iii
;attaches ift2 and ift3 to ift1 and returns resulting table ift
ift1, ift2, ift3	xin
ilen1		=		ftlen(ift1)
ilen2		=		ftlen(ift2)
ilen3		=		ftlen(ift3)
ilen		=		ilen1+ilen2+ilen3
ift		ftgen		0, 0, -ilen, -2, 0
indxread	=		0
indxwrite	=		0
loop1:
ival		tab_i		indxread, ift1
		tabw_i		ival, indxwrite, ift
indxwrite	=		indxwrite + 1
		loop_lt	indxread, 1, ilen1, loop1
indxread	=		0
loop2:
ival		tab_i		indxread, ift2
		tabw_i		ival, indxwrite, ift
indxwrite	=		indxwrite + 1
		loop_lt	indxread, 1, ilen2, loop2
indxread	=		0
loop3:
ival		tab_i		indxread, ift3
		tabw_i		ival, indxwrite, ift
indxwrite	=		indxwrite + 1
		loop_lt	indxread, 1, ilen3, loop3
		xout		ift
  endop

  opcode TableDumpSimp, 0, iio
;simply prints the contents of a table
ifn, iprec, ippr   xin; table, decimal places, parameters per line (maximum = 32, default = 10)
ippr		=		(ippr == 0 ? 10 : ippr)
iend		=		ftlen(ifn)
indx		=		0
Sformat	sprintf	"%%.%d f\t", iprec
Sdump		=		""
loop:
ival		tab_i		indx, ifn
Snew		sprintf	Sformat, ival
Sdump		strcat		Sdump, Snew
indx		=		indx + 1
imod		=		indx % ippr
	if imod == 0 then
		puts		Sdump, 1
Sdump		=		""
	endif
	if indx < iend igoto loop
		puts		Sdump, 1
  endop

  opcode TableDumpSimpS, 0, iiSo
;simply prints the content of a table with an extra string as 'introduction'
ifn, iprec, String, ippr   xin;  table, decimal places, string, parameter per line (maximum = 32, default = 10)
ippr		=		(ippr == 0 ? 10 : ippr)
iend		=		ftlen(ifn)
indx		=		0
		puts		String, 1
Sformat	sprintf	"%%.%d f\t", iprec
Sdump		=		""
loop:
ival		tab_i		indx, ifn
Snew		sprintf	Sformat, ival
Sdump		strcat		Sdump, Snew
indx		=		indx + 1
imod		=		indx % ippr
	if imod == 0 then
		puts		Sdump, 1
Sdump		=		""
	endif
	if indx < iend igoto loop
		puts		Sdump, 1
  endop

  opcode	ShowLED_a, 0, Sakkk
;zeigt ein audiosignal in einem outvalue-kanal, in dB oder reinen amplituden
;Soutchan: string als name des outvalue-kanals
;asig: audio signal das angezeigt werden soll
;kdispfreq: erneuerungsfrequenz der anzeige (Hz)
;idb: 1 = in dB anzeigen, 0 = in reinen amplitudes anzei (beides im bereich 0-1)
;idbrange: wenn idb=1: wie viele dB-schritte werden angezeigt (zb wenn idbrange=36 sieht man nichts von einem signal unterhalb von -36 dB)
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
;zeigt wenn asig größer als 1 war und bleibt khold sekunden auf dieser anzeige
;Soutchan: string als name des outvalue-kanals
;kdispfreq: erneuerungsfrequenz der anzeige (Hz)
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




;============================================================================;
;============================================================================;
;    B. MORE SPECIFIC METHODS FOR STOCKHAUSEN'S STUDIE II (SS2_...)          ;
;============================================================================;
;============================================================================;


;============================================================================;
;       1. ON THE GENERATION OF SERIES                                       ;
;============================================================================;

  opcode SS2_TP1Val, i, iiii
;calculates a new value from ival and the transposition interval interv, within the scope of iminval and imaxval
ival, interv, iminval, imaxval xin
ivalneu	=		ival + interv
ires		=		(ivalneu > imaxval ? ivalneu - imaxval : (ivalneu < iminval ? ivalneu + imaxval : ivalneu))
		xout		ires
  endop

  opcode SS2_Transp, i, iiii
;transposes "intervallfolge" (series of intervals) of a series to a given initial value
ift, iminval, imaxval, itransval xin; series, minimal and maximal value, and value to transpose to
ifttrans	TabMkCp_i	ift
iftlen		=		ftlen(ift)
indx		=		0
loop:
ival		tab_i		indx, ift
indxnext	=		(indx + 1 < iftlen ? indx + 1 : (indx + 1) - iftlen)
ivalnext	tab_i		indxnext, ift
interv		=		ivalnext - ival
ires		SS2_TP1Val	itransval, interv, iminval, imaxval
		tabw_i		itransval, indx, ifttrans	
itransval	=		ires
		loop_lt	indx, 1, iftlen, loop
		xout		ifttrans
  endop

  opcode SS2_Transp_R, i, i
;transpose a series by using single values with a stepwidth ihop as initial value of a new line (if ihop = 1 the lines of the series 3-5-1-4-2 start with the same numbers; if ihop = 2 the lines start with 3-1-2-5-4, etc), and consecutively writes everything 
ift		xin; a series with five values
ires		ftgen		0, 0, -(ftlen(ift) ^ 2), -2, 0
indx		=		0
loop:
itransval	tab_i		indx, ift
iftres		SS2_Transp	ift, 1, 5, itransval
		TabCopyGroupIn_i iftres, 0, ftlen(ift), ires, indx * 5
		loop_lt	indx, 1, ftlen(ift), loop
		xout		ires
  endop

  opcode SS2_Hop1, i, iii
;creates beginning of lines for R2-R5 from lines of R1 using given stepwidths
ift, istart, ihop xin
idest		ftgen		0, 0, -5, -2, 0
		TabCopyGroupIn_i ift, istart, 5, idest, 0
ifttransvals	TabMkNewByHop_i idest, ihop
		ftfree		idest, 0
		xout		ifttransvals
  endop

  opcode SS2_Hop2, i, ii
;analyses the distance between the elements of ifn2 in ifn1 and returns the distances as a new table 
ifn1, ifn2	xin
iftreslen	=		ftlen(ifn2) - 1
ifnabst	ftgen		0, 0, -iftreslen, -2, 0
indx		=		0
loop:
ival1		tab_i		indx, ifn2; next value in ifn2
indx1		TabValIn	ival1, ifn1; which index does this value hold in ifn1
ival2		tab_i		indx+1, ifn2; next value in ifn2
indx2		TabValIn	ival2, ifn1; which index does this value hold in ifn1
iabst		=		indx2 - indx1
iabst		=		(iabst < 0 ? iabst + 5 : iabst)
		tabw_i		iabst, indx, ifnabst
		loop_lt	indx, 1, iftreslen, loop
		xout		ifnabst
  endop

  opcode SS2_Hop3, i, iii
;creates a new series of five from a series, a series of distances and an initial element
ifn, ifnabst, istartval xin
ilen		=		ftlen(ifn)
iftres		ftgen		0, 0, -ilen, -2, 0
		tabw_i		istartval, 0, iftres
indx		=		0
ival		=		istartval
indxifn	TabValIn	ival, ifn
loop:
iabst		tab_i		indx, ifnabst
indxnext	=		indxifn + iabst
indxnext	=		(indxnext >= ilen ? indxnext % ilen : indxnext)
ival		tab_i		indxnext, ifn
		tabw_i		ival, indx+1, iftres
indxifn	=		indxnext
		loop_lt	indx, 1, ilen, loop
		xout		iftres
  endop

  opcode SS2_HopAbst, i, i
;returns the distances of the elements in line 2-5 to the elements in line 1 of a number square
iftquadr	xin
ifterste	TabMkPartCp_i iftquadr, 0, 5; first line
iftzeil	ftgen		0, 0, -5, -2, 0
iftres		ftgen		0, 0, -16, -2, 0
indx		=		5
iwrite		=		0
loop:
		TabCopyGroupIn_i iftquadr, indx, 5, iftzeil, 0; lines 2-5 while looping
iftabst	SS2_Hop2	ifterste, iftzeil
		TabCopyGroupIn_i iftabst, 0, 4, iftres, iwrite
iwrite		=		iwrite + 4
		loop_lt	indx, 5, ftlen(iftquadr), loop
		xout		iftres
  endop

  opcode SS2_Hop, i, iiii
;creates a new number square from another number square, a named line by a starting index in ift, the stepwidth and the list of distances. Returns the denominator of the new number suare
ift, istart, ihop, iftabst xin; first number square, start index of line, stepwidth, list of distances
iftkopf	ftgen		0, 0, -5, -2, 0
		TabCopyGroupIn_i ift, istart, 5, iftkopf, 0; line from ift as topline of the new square
ifttransvals	SS2_Hop1	ift, istart, ihop; beginnings of lines for the new square from the topline
iftres		ftgen		0, 0, -25, -2, 0; list of results
		TabCopyGroupIn_i iftkopf, 0, 5, iftres, 0; using iftkopf as initial element
indx		=		1
loop:
istartval	tab_i		indx, ifttransvals; beginning of a new line
iabstzeil	TabMkPartCp_i iftabst, (indx - 1) * 4, 4; line from list of distances
iftneuzeil	SS2_Hop3	iftkopf, iabstzeil, istartval; whole new line
		TabCopyGroupIn_i iftneuzeil, 0, 5, iftres, indx * 5
		loop_lt	indx, 1, 5,loop
		xout		iftres
  endop

  opcode SS2_Umk, i, i
;reverses a series in interval-like way (1->5, 2->4, 4->2, 5->1)
iftreihe	xin
iftumkehr	TabMkCp_i	iftreihe
indx		=		0
loop:
ival		tab_i		indx, iftreihe
		tabw_i		6 - ival, indx, iftumkehr
		loop_lt	indx, 1, ftlen(iftreihe), loop
		xout		iftumkehr
  endop



;============================================================================;
;       2. ON THE BASIC TABLES                                                 ;
;============================================================================;

  opcode SS2_IndxAusGSS, i, iii
;returns the index for a table from the values of set, column and position
;eg for 1-1-1: index=0, for 2-1-1: index=25, etc.
igrup, ispalt, istel xin
igrupval	=		(igrup - 1) * 5
ispstval	=		ispalt * (istel - 1)
indx		=		igrupval + ispstval
		xout		indx
  endop

  opcode SS2_FreqsAusGTSS, iiiii, iiiii
;returns the 5 frequencies of a soundmix for a given set-transposition-column-position 
ifreqtab, igrup, itrans, ispalt, istel xin
igrup		=		igrup + itrans - 1
indx		SS2_IndxAusGSS igrup, ispalt, istel
ifreq1		tab_i		indx, ifreqtab
ifreq2		tab_i		indx + ispalt, ifreqtab
ifreq3		tab_i		indx + (2*ispalt), ifreqtab
ifreq4		tab_i		indx + (3*ispalt), ifreqtab
ifreq5		tab_i		indx + (4*ispalt), ifreqtab
		xout		ifreq1, ifreq2, ifreq3, ifreq4, ifreq5 
  endop

  opcode SS2_ValsAusGTSS, i, iiiii
;returns the intensity or duration for a given set-transposition-column-postion
ivaltab, igrup, itrans, ispalt, istel xin
igrup		=		igrup + itrans - 1
indx		SS2_IndxAusGSS igrup, ispalt, istel
ival		tab_i		indx, ivaltab
		xout		ival 
  endop

  opcode SS2_MkGlob_dB_Tab, i, ii
;fills a table with values from istart to imin in steps of -1, and backwards, once imin is reached
istart, imin xin
ilen		=		(abs(imin-istart) * 2) + 1
iftres		ftgen		0, 0, -ilen, -2, 0
indx		=		0
incr		=		0
loop:
ival		=		istart + incr
		tabw_i		ival, indx, iftres
if (indx < (ilen/2 - 1)) then
incr		=		incr - 1
else
incr		=		incr + 1
endif
		loop_lt	indx, 1, ilen, loop
		xout		iftres
  endop



;============================================================================;
;       3. GENERATIONS OF TABLES FOR ONE PARAMETER WITHIN ONE PART           ;
;============================================================================;

  opcode SS2_MkParamTab_Meth1, i, iiiiiiiii
;the first method to generate a table of parameters for one part: a constant value for the transposition, set and column move by iftcount, one value per note for position.
;if a table of frequencies is generated, it contains 5 values for each tone; one value each for durations or intensities
;iftbas = table of frequencies, durations or amplitudes as general repertoire
;iftcount = ftable declaring the numbers of repetitions for every type
;iftgrup = ftable declaring the (untransposed) sets
;itrans = transposition"interval"
;iftspalt = ftable declaring columns
;iftstel1-3 are ftables declaring the positions (changing at every tone, the others stay the same for one type)
;ifreqjn = 0= table of durations or amplitudes, 1=table of frequencies
iftbas, iftcount, iftgrup, itrans, iftspalt, iftstel1, iftstel2, iftstel3, ifreqjn xin
iftstel	TableAppend2_i iftstel1, iftstel2, iftstel3
if ifreqjn == 0 then
iftout		ftgen		0, 0, -ftlen(iftstel), -2, 0; table of durations or dbs
else
iftout		ftgen		0, 0, -(ftlen(iftstel) * 5), -2, 0; table for frequencies
endif
indxcount	=		0
indxtonabs	=		0
seq:
icount		tab_i		indxcount, iftcount
igrup		tab_i		indxcount, iftgrup
ispalt		tab_i		indxcount, iftspalt
indxton	=		0
ton:
istel		tab_i		indxtonabs, iftstel
if ifreqjn == 0 then
ival   	SS2_ValsAusGTSS iftbas, igrup, itrans, ispalt, istel
		tabw_i		ival, indxtonabs, iftout
else
ifq1, ifq2, ifq3, ifq4, ifq5   SS2_FreqsAusGTSS iftbas, igrup, itrans, ispalt, istel
		tabw_i		ifq1, indxtonabs * 5, iftout
		tabw_i		ifq2, indxtonabs * 5 + 1, iftout
		tabw_i		ifq3, indxtonabs * 5 + 2, iftout
		tabw_i		ifq4, indxtonabs * 5 + 3, iftout
		tabw_i		ifq5, indxtonabs * 5 + 4, iftout
endif
indxtonabs	=		indxtonabs + 1
		loop_lt	indxton, 1, icount, ton
		loop_lt	indxcount, 1, ftlen(iftcount), seq
		xout		iftout
  endop

  opcode SS2_MkParamTab_Meth2, i, iiiiiiii
;the second method to generate a table of parameters for one part:
;1. set changes from tone to tone (the same series are used as for generating the positions)
;2. the transposition changes by one value per sequence
;for everything else see method 1
iftbas, iftcount, ifttrans, iftspalt, iftstel1, iftstel2, iftstel3, ifreqjn xin
iftstel	TableAppend2_i iftstel1, iftstel2, iftstel3
if ifreqjn == 0 then
iftout		ftgen		0, 0, -ftlen(iftstel), -2, 0; table of durations or dbs
else
iftout		ftgen		0, 0, -(ftlen(iftstel) * 5), -2, 0; table of frequencies
endif
indxcount	=		0
indxtonabs	=		0
seq:
icount		tab_i		indxcount, iftcount
ispalt		tab_i		indxcount, iftspalt
itrans		tab_i		indxcount, ifttrans
indxton	=		0
ton:
istel		tab_i		indxtonabs, iftstel
igrup		=		istel
if ifreqjn == 0 then
ival   	SS2_ValsAusGTSS iftbas, igrup, itrans, ispalt, istel
		tabw_i		ival, indxtonabs, iftout
else
ifq1, ifq2, ifq3, ifq4, ifq5   SS2_FreqsAusGTSS iftbas, igrup, itrans, ispalt, istel
		tabw_i		ifq1, indxtonabs * 5, iftout
		tabw_i		ifq2, indxtonabs * 5 + 1, iftout
		tabw_i		ifq3, indxtonabs * 5 + 2, iftout
		tabw_i		ifq4, indxtonabs * 5 + 3, iftout
		tabw_i		ifq5, indxtonabs * 5 + 4, iftout
endif
indxtonabs	=		indxtonabs + 1
		loop_lt	indxton, 1, icount, ton
		loop_lt	indxcount, 1, ftlen(iftcount), seq
		xout		iftout
  endop


;============================================================================;
;       4. SPECIFIC PROCEDURES FOR CERTAIN PARTS                             ;
;============================================================================;

  opcode SS2_Freqtab_5, i, iiiiiiiii
;;same as in part 3 and 4, but in certain sequences a set is replaced by a 2 (the procedure is otherwise unchanged). these sequences are denominated by the sets of five irpl5a and irpl5b. The first number of a series points to a position in the first set of sequences (between 1 and 5), the second to a position in the second set of sequences, and so on for both the series.
;in the very last sequence (set 5, sequence 5) the column is set to 3
ift_Freqs, iftcount, ifttrans, iftspalt, iftstel1, iftstel2, iftstel3, iftrpl1, iftrpl2 xin
iftstel	TableAppend2_i iftstel1, iftstel2, iftstel3
iftfreqs	ftgen		0, 0, -(ftlen(iftstel) * 5), -2, 0
indxseqgrp	=		0
indxtonabs	=		0
seqgrp:
indxseq	=		0
irplseq1	tab_i		indxseqgrp, iftrpl1
irplseq2	tab_i		indxseqgrp, iftrpl2
seq:
indxcount	=		(indxseqgrp * 5) + indxseq
icount		tab_i		indxcount, iftcount
if indxseqgrp == 4 && indxseq == 4 then; at the last time
ispalt		=		3; set column to 3
else
ispalt		tab_i		indxcount, iftspalt
endif
itrans		tab_i		indxcount, ifttrans
indxton	=		0
ton:
istel		tab_i		indxtonabs, iftstel
if indxseq+1 == irplseq1 || indxseq+1 == irplseq2 then; if sequence to be changed
igrup		=		2; set set to 2
else
igrup		=		istel; otherwise set set to position
endif
ifq1, ifq2, ifq3, ifq4, ifq5   SS2_FreqsAusGTSS ift_Freqs, igrup, itrans, ispalt, istel
		tabw_i		ifq1, indxtonabs * 5, iftfreqs
		tabw_i		ifq2, indxtonabs * 5 + 1, iftfreqs
		tabw_i		ifq3, indxtonabs * 5 + 2, iftfreqs
		tabw_i		ifq4, indxtonabs * 5 + 3, iftfreqs
		tabw_i		ifq5, indxtonabs * 5 + 4, iftfreqs
indxtonabs	=		indxtonabs + 1
		loop_lt	indxton, 1, icount, ton
		loop_lt	indxseq, 1, 5, seq
		loop_lt	indxseqgrp, 1, 5, seqgrp
		xout		iftfreqs; contains all frequencies of this part in five-pack-like manner
  endop

  opcode SS2_durs2, i, iii
iftdur, iftcount, iftenv xin; original table of durations, table with number of elements per sequence, table of envelopes for each sequence (1-5, see opcode SS2_dbs_2)
iftout		ftgen		0, 0, -ftlen(iftdur), -2, 0
indxseq	        =		0
indxnotabs	=		0
seq:
indxnote	=		0
iduraccum	=		0
indxabsseq	=		indxnotabs; absolute index in iftdur at the beginning of a sequence
icount		tab_i		indxseq, iftcount
ienv		tab_i		indxseq, iftenv
note:
if ienv == 1 || ienv == 2 then; common start: first duration normal, all others are added up
idurnorm	tab_i		indxnotabs, iftdur; durations from normal table
idur		=		idurnorm + iduraccum; real duration = sum of preceding durations of this sequence plus idurnorm
iduraccum	=		idur; this is the next value for the assembled durations
		tabw_i		idur, indxnotabs, iftout; write durations to iftout
else; common end: last duration normal, all others are added up reversely
indxback	=		indxabsseq + icount - indxnote - 1; counting down
idurnorm	tab_i		indxback, iftdur; duration from normal table
idur		=		idurnorm + iduraccum; real duration = sum of preceding durations of this sequence plus idurnorm
iduraccum	=		idur; this is the next value for the assembled durations
		tabw_i		idur, indxback, iftout; write durations to iftout
endif
indxnotabs	=		indxnotabs + 1
		loop_lt	indxnote, 1, icount, note
		loop_lt	indxseq, 1, ftlen(iftcount), seq
		xout		iftout
  endop

  opcode SS2_durs4, i, iii
iftdur, iftcount, iftenv xin; original table of durations, table of number of elements per sequence, table of envelopes for each sequence (1-5, see opcode SS2_dbs_4)
iftout		ftgen		0, 0, -ftlen(iftdur), -2, 0
indxseq	        =		0
indxnotabs	=		0
seq:
indxnote	=		0
iduraccum	=		0
indxabsseq	=		indxnotabs; absolute index in iftdur at the beginning of a sequence
icount		tab_i		indxseq, iftcount
ienv		tab_i		indxseq, iftenv
note:
if ienv == 1 || ienv == 2 || ienv == 5 then; common start: first duration normal, all others are added up
idurnorm	tab_i		indxnotabs, iftdur; durations from normal table
idur		=		idurnorm + iduraccum; reale dauer = sum of preceding durations of this sequence plus idurnorm
iduraccum	=		idur; this is the next value for the assembled durations
		tabw_i		idur, indxnotabs, iftout; write durations to iftout
else; common end: last duration normal, all others are added up reversely
indxback	=		indxabsseq + icount - indxnote - 1; counts backwards
idurnorm	tab_i		indxback, iftdur; durations from normal table
idur		=		idurnorm + iduraccum; reale dauer = sum of preceding durations of this sequence plus idurnorm
iduraccum	=		idur; this is the next value for the assembled durations
		tabw_i		idur, indxback, iftout; write durations to iftout
endif
indxnotabs	=		indxnotabs + 1
		loop_lt	indxnote, 1, icount, note
		loop_lt	indxseq, 1, ftlen(iftcount), seq
		xout		iftout
  endop

  opcode SS2_durs5, i, iiii
;changes durations within chords by the usual principle (common start: first duration unchanged, the other durations are added up; common end: last duration unchanged, the other durations are added up backwards)
iftdur, ifttyps, iftcount, iftenv xin; original table of durations, table with types for part 5 (1-3), table of numbers of elements per sequence, table of envelopes for each sequence (1-6, see instr 1)
iftout		ftgen		0, 0, -ftlen(iftdur), -2, 0
indxseq	=		0
indxnotabs	=		0
indxenv	=		0
seq:
indxnote	=		0
iduraccum	=		0
indxabsseq	=		indxnotabs; absolute index in iftdur at the start of a sequence
icount		tab_i		indxseq, iftcount
ityp		tab_i		indxseq, ifttyps
note:
if ityp == 2 then; if chord:
ienv		tab_i		indxenv, iftenv
 if ienv == 1 || ienv == 2 || ienv == 5 then; common start: first duration normal, all others add up
idurnorm	tab_i		indxnotabs, iftdur; duration from normal table
idur		=		idurnorm + iduraccum; real duration = sum of preceding durations in this sequence plus idurnorm
iduraccum	=		idur; this is the next value for the assembled durations
		tabw_i		idur, indxnotabs, iftout; write duration to iftout
 else; common end: last duration normal, all others are added up reversely
indxback	=		indxabsseq + icount - indxnote - 1; counts backwards
idurnorm	tab_i		indxback, iftdur; duration from normal table
idur		=		idurnorm + iduraccum; real duration = sum of preceding durations in this sequence plus idurnorm
iduraccum	=		idur; this is the next value for the assembled durations
		tabw_i		idur, indxback, iftout; write duration to iftout
 endif
else; else write duration from normal table to iftout
idur		tab_i		indxnotabs, iftdur
		tabw_i		idur, indxnotabs, iftout
endif
indxnotabs	=		indxnotabs + 1
		loop_lt	indxnote, 1, icount, note
indxenv	=		(ityp == 2 ? indxenv+1 : indxenv); indxenv up if value was used
		loop_lt	indxseq, 1, ftlen(iftcount), seq
		xout		iftout
  endop


;============================================================================;
;       5. GENERATION OF STARTING TIMES                                      ;
;============================================================================;

  opcode SS2_Starts_part, i, iiiiiiiii
;first index is istartabs (absolute startingpoint in cm), then the 24 following startingpoints of the sequences
;starting point is passed down to the next part as index 25 (26th value) 
ift_Durs, iftcount, iftgrup, itrans, iftspalt, iftstel1, iftstel2, iftstel3, istartabs xin
iftstel	TableAppend2_i iftstel1, iftstel2, iftstel3
iftstarts	ftgen		0, 0, -(ftlen(iftcount)+1), -2, istartabs
indxcount	=		0
indxtonabs	=		0
seq:
icount		tab_i		indxcount, iftcount
igrup		tab_i		indxcount, iftgrup
ispalt		tab_i		indxcount, iftspalt
indxton	=		0
idurabs	=		0
ton:
istel		tab_i		indxtonabs, iftstel
idur   	SS2_ValsAusGTSS ift_Durs, igrup, itrans, ispalt, istel
indxtonabs	=		indxtonabs + 1
idurabs	=		idurabs + idur; dauer einer 1-5 ton gruppe in cm
		loop_lt	indxton, 1, icount, ton
istartabs	=		istartabs + idurabs
		tabw_i		istartabs, indxcount+1, iftstarts
		loop_lt	indxcount, 1, ftlen(iftcount), seq
		xout		iftstarts
  endop

  opcode SS2_Starts_3, i, iiiiiiiii
;first index is istartabs (absolute startingpoint in cm), then the following 74 startingpoints of the notes
;the startingpoint of the next part is passed down as index 75 (ie. 76th value)
ift_Durs, iftcount, iftgrup, itrans, iftspalt, iftstel1, iftstel2, iftstel3, istartabs xin
iftstel	TableAppend2_i iftstel1, iftstel2, iftstel3
iftstarts	ftgen		0, 0, -(ftlen(iftstel)+1), -2, istartabs
indxcount	=		0
indxtonabs	=		0
seq:
icount		tab_i		indxcount, iftcount
igrup		tab_i		indxcount, iftgrup
ispalt		tab_i		indxcount, iftspalt
indxton	        =		0
ton:
istel		tab_i		indxtonabs, iftstel
idur   	SS2_ValsAusGTSS ift_Durs, igrup, itrans, ispalt, istel
istartabs	=		istartabs + idur
		tabw_i		istartabs, indxtonabs+1, iftstarts
indxtonabs	=		indxtonabs + 1
		loop_lt	indxton, 1, icount, ton
		loop_lt	indxcount, 1, ftlen(iftcount), seq
		xout		iftstarts
  endop

  opcode SS2_Starts_5, i, iiiiii
;generates the startingpoints. indx 75 (position 76) makes the start of coda
iftstarts5a, iftcount, ifttyps, iftdurs, iftenvtyp2, istartabs xin; preliminary starting points, notes per sequence, types of sequences (1-3), durations, types of envelopes for chords (typ=2) (1-6), start of this point (cm)
iftout		ftgen		0, 0, -(ftlen(iftstarts5a) + 1), -2, istartabs
iftmxgrpdrs	TabMkTbFrmGrpMx_i iftdurs, iftcount; table with the maximal durations of each sequence
indxseq	=		0
indxtonabs	=		0
indxenv	=		0; read index in iftenvtyp2 (has as many positions as there are typ2-sequenzes)
seq:
icount		tab_i		indxseq, iftcount
indxton	=		0
ityp		tab_i		indxseq, ifttyps
istartseq	=		istartabs; absolute starting time for this sequence
idurshift	=		0
imaxdur	tab_i		indxseq, iftmxgrpdrs
ienv		tab_i		indxenv, iftenvtyp2
ton:
istartdiff3	tab_i		indxtonabs, iftstarts5a
istartabs	=		istartabs + istartdiff3; starting time if all is direct from iftstarts5a (typ=3)
if ityp == 1 && indxton < icount-1 then; typ1: concatenating the notes of one sequence
idur1		tab_i		indxtonabs, iftdurs
idurshift	=		idurshift + idur1
istart1	=		istartseq + idurshift
		tabw_i		istart1, indxtonabs+1, iftout; value for the next note after the duration of this note
elseif ityp == 2 then; typ2: chords
 if (ienv == 1 || ienv == 2 || ienv == 5) && (indxton < icount-1) then; for common starts
istart2	=		istartseq
 else; else starting point as difference to the maximum duration of the sequence
idur2		tab_i		indxtonabs, iftdurs
istart2	=		istartseq + (imaxdur - idur2)
 endif
		tabw_i		istart2, indxtonabs, iftout; value for this note from this calculation
		tabw_i		istartabs, indxtonabs+1, iftout; value for the next note from normal table
else; typ=3: isolated events, or last note from a typ=1 sequence
		tabw_i		istartabs, indxtonabs+1, iftout
endif
indxtonabs	=		indxtonabs + 1
		loop_lt	indxton, 1, icount, ton
indxenv	=		(ityp == 2 ? indxenv+1 : indxenv); indxenv up if value was used
		loop_lt	indxseq, 1, ftlen(iftstarts5a), seq
		xout		iftout
  endop


;============================================================================;
;       6. AMPLITUDES AND ENVELOPES                                          ;
;============================================================================;

  opcode SS2_dbs_1, ii, iiiii
;assuming that the envelopes in part one follow these rules:
;a) crescendi are executed isolated as a principle, so they begin at -40 dB 
;b) diminuendi are executed isolated (so they end at -40 dB) if either
;  - they are superseded by a crescendo
;  - or the next note is louder (otherwise a conjunction would cause a cresc)
;  - or the current note is the last of a sequence
;c) otherwise the end value of the diminuendi is the starting value of the next note
iftdb, iftenv, indxnotabs, indxnote, icount xin
idb		tab_i		indxnotabs, iftdb
idbnext	tab_i		indxnotabs+1, iftdb
ienv		tab_i		indxnotabs, iftenv
ienvnext	tab_i		indxnotabs+1, iftenv
if ienv == 1 then; execute crescendo isolated (starting from -40 db)
idb1		=		-40
idb2		=		idb
elseif ienvnext == 1 || indxnote == icount-1 || idbnext > idb then; execute dim isolated (falling to -40 db)
idb1		=		idb
idb2		=		-40
else ;if dim is followed by dim and not the last note: dim to starting value of next dim
idb1		=		idb
idb2		=		idbnext
endif
		xout		idb1, idb2
  endop

  opcode SS2_dbs_2, ii, iiii
idb, ienv, imaxdur, idur xin; db value for this note, type of envelope (1-5), duration of longest note of this sequence, duration of this note
;;possible types of envelopes (ienv)
; 1 = common start, diminuendo, truncation of the shorter notes before -40 dB because of common point of intersection ("fluchtpunkt")
; 2 = common start, crescendo of single tones
; 3 = common end, diminuendo of single tones
; 4 = common end, crescendo, start of shorter notes over -40 dB because of common point of intersection ("fluchtpunkt")
; 5 = common end, crescendo of single tones
if ienv == 2 || ienv == 5 then; simple cresc for the duration of the note
idb1		=		-40
idb2		=		idb
elseif ienv == 3 then; simple dim
idb1		=		idb
idb2		=		-40
elseif ienv == 1 then; dim, but shorter notes do not go down to -40 dB
idb1		=		idb
irel		=		idur / imaxdur
idbdiff	=		idb1 + 35; how much db between the maximum and -35 as endpoint (because the score only holds space for 5 db between -30 and -40)
idb2		=		idb1 - (irel * idbdiff)
idb2		=		(idb2 <= -35 ? -40 : idb2); set to real minimum if necessary
elseif ienv == 4 then; cresc, but start is more or less stronger than -40 db
idb2		=		idb
irel		=		idur / imaxdur
idbdiff	=		idb2 + 35; how much db between the maximum und -35 as startingpoint (see above for scaling)
idb1		=		idb2 - (irel * idbdiff)
idb1		=		(idb1 <= -35 ? -40 : idb1); set to real minimum if necessary
endif
		xout		idb1, idb2
  endop

  opcode SS2_dbtab_3, i, iiiiiii
;the procedure is the same as for the frequencies (see above, opcode SS2_Freqtabs_3), but this time only one value per note is generated
ift_Intens, iftcount, ifttrans, iftspalt, iftstel1, iftstel2, iftstel3 xin
iftstel	TableAppend2_i iftstel1, iftstel2, iftstel3
iftdbs		ftgen		0, 0, -ftlen(iftstel), -2, 0
indxcount	=		0
indxtonabs	=		0
seq:
icount		tab_i		indxcount, iftcount
ispalt		tab_i		indxcount, iftspalt
itrans		tab_i		indxcount, ifttrans
indxton	=		0
ton:
istel		tab_i		indxtonabs, iftstel
igrup		=		istel
idb		SS2_ValsAusGTSS ift_Intens, igrup, itrans, ispalt, istel
		tabw_i		idb, indxtonabs, iftdbs
indxtonabs	=		indxtonabs + 1
		loop_lt	indxton, 1, icount, ton
		loop_lt	indxcount, 1, ftlen(iftcount), seq
		xout		iftdbs
  endop

  opcode SS2_dbtab_4, i, iiiiiiiii
;only the shortest note of a sequence is assigned its usual duration from the table of intensities; the others have the value of their position subtracted from this db-value and the result is set as reference value for the following sequence  
ift_Intens, iftcount, iftgrup, itrans, iftspalt, iftstel1, iftstel2, iftstel3, iftenv xin
iftstel	TableAppend2_i iftstel1, iftstel2, iftstel3
iftdbs		ftgen		0, 0, -ftlen(iftstel), -2, 0
indxcount	=		0
indxtonabs	=		0
seq:
icount		tab_i		indxcount, iftcount
ispalt		tab_i		indxcount, iftspalt
igrup		tab_i		indxcount, iftgrup
ienv		tab_i		indxcount, iftenv
indxton	=		0
idbref		=		0; db-reference value (is overwritten)
indxabsseq	=		indxtonabs; absolute index in iftstel at the start of a sequence
ton:
if ienv == 1 || ienv == 2 || ienv == 5 then; common start: 
istel		tab_i		indxtonabs, iftstel; normal count of position
 if indxton == 0 then; for the first time
idb		SS2_ValsAusGTSS ift_Intens, igrup, itrans, ispalt, istel; get db-value from table
idbref		=		idb; set as reference
 else; all others
idb		=		idbref - istel; subtract their position in db
idbref		=		idb; and set new reference to the result
 endif
		tabw_i		idb, indxtonabs, iftdbs; and write new reference to iftdbs
else; common end:
indxback	=		indxabsseq + icount - indxton - 1; backwards counter
istel		tab_i		indxback, iftstel; starting with last note of a sequence, then the second-last etc.
 if indxton == 0 then; for the first time
idb		SS2_ValsAusGTSS ift_Intens, igrup, itrans, ispalt, istel; get db-value from table
idbref		=		idb; set as reference
 else; alle anderen 
idb		=		idbref - istel; subtract their position in db
idbref		=		idb; and set new reference to the result
 endif
		tabw_i		idb, indxback, iftdbs; and write it from end to start into the positions of this sequence
endif
indxtonabs	=		indxtonabs + 1
		loop_lt	indxton, 1, icount, ton
		loop_lt	indxcount, 1, ftlen(iftcount), seq
		xout		iftdbs
  endop

  opcode SS2_dbtab_5b, i, ii
;corrects the values in iftdbs_5a as assigned by iftkorr
iftdbs_5a, iftkorr xin
iftout		TabMkCp_i	iftdbs_5a
indx		=		0
indxkorr	=		0
loop:
iwhich		tab_i		indxkorr, iftkorr
if iwhich == indx then
ikorrval	tab_i		indxkorr+1, iftkorr
		tabw_i		ikorrval, indx, iftout
indxkorr	=		indxkorr + 2
endif
		loop_lt	indx, 1, ftlen(iftdbs_5a), loop
		xout		iftout
  endop

  opcode SS2_dbs_4, ii, iiii
idb, ienv, imaxdur, idur xin; db value for this note, type of envelope (1-5), duration of the longest note of this sequence, duration of this note
;;possible types of envelopes (ienv)
; 1 = common start, diminuendo, truncation of the shorter notes before -40 dB because of common point of intersection ("fluchtpunkt")
; 2 = common start, crescendo of single tones
; 3 = common end, diminuendo of single tones
; 4 = common end, crescendo, start of shorter notes over -40 dB because of common point of intersection ("fluchtpunkt")
; 5 = common end, crescendo of single tones
if ienv == 2 then; simple cresc for duration of this note
idb1		=		-40
idb2		=		idb
elseif ienv == 3 || ienv == 5 then; simple dim
idb1		=		idb
idb2		=		-40
elseif ienv == 1 then; dim but shorter notes do not fall to -40 dB
idb1		=		idb
irel		=		idur / imaxdur
idbdiff	=		idb1 + 35; how much db between the maximum and -35 as endpoint (because the score only holds space for 5 db between -30 and -40)
idb2		=		idb1 - (irel * idbdiff)
idb2		=		(idb2 <= -35 ? -40 : idb2); set to real minimum if necessary
elseif ienv == 4 then; cresc but start more or less stronger than -40 db
idb2		=		idb
irel		=		idur / imaxdur
idbdiff	=		idb2 + 35; how much db between the maximum and -35 as starting point (see above for scaling)
idb1		=		idb2 - (irel * idbdiff)
idb1		=		(idb1 <= -35 ? -40 : idb1); set to real minimum if necessary
endif
		xout		idb1, idb2
  endop

  opcode SS2_dbs_5, i, iiiiii
iftdb, iftcount, ifttyp, iftenv1, iftenv2, iftdur xin; table with db maxima for one note, table of number of notes for one sequence, type of note (1-3), envelopes for type 1 (1-2), envelopes for type 2 (1-6), durations
;output is a table with the pattern db1, db2, db1, db2, ... (two values per note)
iftout		ftgen		0, 0, -(ftlen(iftdb) * 2), -2, 0
iftmxgrpdrs	TabMkTbFrmGrpMx_i iftdur, iftcount; table of maximal durations in each sequence
indxnotabs	=		0
indxseq	=		0
indxenv1	=		0; reading index in envelopes for type 1 (one per note)
indxenv2	=		0; reading index in envelopes for type 2 (one per sequence)
seq:
indxnot	=		0
icrescalign	=		0; to see if a cresc of type1 does not start with the final value of the preceding dim
icount		tab_i		indxseq, iftcount
imaxdur	tab_i		indxseq, iftmxgrpdrs
ityp		tab_i		indxseq, ifttyp
ienv2		tab_i		indxenv2, iftenv2
note:
idb		tab_i		indxnotabs, iftdb
idur		tab_i		indxnotabs, iftdur

if ityp == 3 then; ISOLATED SINGLE TONES
idb1		=		idb
idb2		=		-40
		tabw_i		idb1, indxnotabs * 2, iftout
		tabw_i		idb2, (indxnotabs * 2) + 1, iftout

elseif ityp == 2 then; CHORDS
 if ienv2 == 2 || ienv2 == 6 then; simple cresc for the duration of the tone
idb1		=		-40
idb2		=		idb
 elseif ienv2 == 3 || ienv2 == 5 then; simple dim
idb1		=		idb
idb2		=		-40
 elseif ienv2 == 1 then; dim but shorter tones do not fall to -40 dB
idb1		=		idb
irel		=		idur / imaxdur
idbdiff	=		idb1 + 35; how much db between the maximum and -35 as endpoint (because the score only holds space for 5 db between -30 and -40)
idb2		=		idb1 - (irel * idbdiff)
idb2		=		(idb2 <= -35 ? -40 : idb2); set to real minimum if necessary
 elseif ienv2 == 4 then; cresc but starting more or less stronger than -40 db
idb2		=		idb
irel		=		idur / imaxdur
idbdiff	=		idb2 + 35; how much db between the maximum and -35 as starting point (see above for scaling)
idb1		=		idb2 - (irel * idbdiff)
idb1		=		(idb1 <= -35 ? -40 : idb1); set to real miminum if necessary
 endif
		tabw_i		idb1, indxnotabs * 2, iftout
		tabw_i		idb2, (indxnotabs * 2) + 1, iftout

elseif ityp == 1 then; LINKED NOTES
ienv1		tab_i		indxenv1, iftenv1
idbnext	tab_i		indxnotabs + 1, iftdb; next db-value from the table
ienvnext	tab_i		indxenv1 + 1, iftenv1; next value for envelope (cresc or dim)
 if ienv1 == 1 then; crescendo 
  if icrescalign == 0 then; if not linked to preceding note
idb1		=		-40; execute isolated (starting from -40 db)
idb2		=		idb
  else; if linked (icrescalign == 1)
idbprev	tab_i		(indxnotabs * 2) - 1, iftout; get preceding db2 from table
idb1		=		idbprev
idb2		=		idb
icrescalign	=		0; delete information on linkage
  endif
 elseif ienv1 == 2 then; diminuendo
  if (indxnot == icount - 1) || (ienvnext == 2 && idbnext > idb) || (ienvnext == 1 && idbnext < idb) || (ienvnext == 1 && idb < -21) then; if (1) last note of a sequence, or (2) following dim and db-value thereof greater than this db-value, or (3) following cresc and db-value thereof smaller than this db-value, or (4) following cresc and current db-value is -22 or smaller: dim until -40 db
idb1		=		idb
idb2		=		-40
  else; 
   if ienvnext == 1 then; if linked cresc back to -25 db (two positions: 3.3 and 4.4)
idb1		=		idb
idb2		=		-25
icrescalign	=		1; set label for next note
   else ; otherwise dim to starting value of next note
idb1		=		idb
idb2		=		idbnext
icrescalign	=		1; set label for next note
   endif
  endif
 endif
		tabw_i		idb1, indxnotabs * 2, iftout
		tabw_i		idb2, (indxnotabs * 2) + 1, iftout
endif

indxnotabs	=		indxnotabs + 1
indxenv1	=		(ityp == 1 ? indxenv1+1 : indxenv1); indices for iftenv1 and iftenv 2 ...
		loop_lt	indxnot, 1, icount, note
indxenv2	=		(ityp == 2 ? indxenv2+1 : indxenv2); ... progressing once one  was used
		loop_lt	indxseq, 1, ftlen(iftcount), seq

		xout		iftout
  endop


;============================================================================;
;       7. TRIGGERING THE EVENTS                                             ;
;============================================================================;

  opcode SS2_TrigEvents_1, 0, iiiiiiii
;triggers the events of part 1 and prints them if iprintjn=1
iftstarts, iftcounts, iftfreqs, iftdurs, iftdb, iftenv, isubinstr, iprintjn xin
indxseq	=		0
indxnotabs	=		0
seq:
indxnote	=		0
idurshift	tab_i		indxseq, iftstarts
icount		tab_i		indxseq, iftcounts
istartseq	tab_i		indxseq, iftstarts
note:
ifq1		tab_i		indxnotabs * 5, iftfreqs
ifq2		tab_i		indxnotabs * 5 + 1, iftfreqs
ifq3		tab_i		indxnotabs * 5 + 2, iftfreqs
ifq4		tab_i		indxnotabs * 5 + 3, iftfreqs
ifq5		tab_i		indxnotabs * 5 + 4, iftfreqs
idur		tab_i		indxnotabs, iftdurs
idb1, idb2	SS2_dbs_1	iftdb, iftenv, indxnotabs, indxnote, icount
		event_i	"i", isubinstr, idurshift/76.2, idur/76.2, ifq1, ifq2, ifq3, ifq4, ifq5, idb1, idb2
if iprintjn == 1 then
		prints		"%d.%d.%d.%d%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.2f%t%t%.0f%t%.0f%n", 1, int(indxseq/5) + 1, (indxseq%5) + 1, indxnote + 1, idurshift, idurshift/76.2, idur, idur/76.2, ifq1, ifq5, idb1, idb2
endif
idurshift	=		idurshift + idur
indxnotabs	=		indxnotabs + 1
		loop_lt	indxnote, 1, icount, note
		loop_lt	indxseq, 1, ftlen(iftcounts), seq
  endop

  opcode SS2_TrigEvents_2, 0, iiiiiiii
;triggers the events of part 2 and prints them if iprintjn=1
iftstarts, iftcounts, iftfreqs, iftdurs, iftdb, iftenv, isubinstr, iprintjn xin
iftmxgrpdrs	TabMkTbFrmGrpMx_i iftdurs, iftcounts; table of maximal durations for each sequence
indxseq	=		0
indxnotabs	=		0
seq:
indxnote	=		0
icount		tab_i		indxseq, iftcounts
istartseq	tab_i		indxseq, iftstarts
ienv		tab_i		indxseq, iftenv
imaxdur	tab_i		indxseq, iftmxgrpdrs
note:
ifq1		tab_i		indxnotabs * 5, iftfreqs
ifq2		tab_i		indxnotabs * 5 + 1, iftfreqs
ifq3		tab_i		indxnotabs * 5 + 2, iftfreqs
ifq4		tab_i		indxnotabs * 5 + 3, iftfreqs
ifq5		tab_i		indxnotabs * 5 + 4, iftfreqs
idur		tab_i		indxnotabs, iftdurs
idb		tab_i		indxnotabs, iftdb
idb1, idb2	SS2_dbs_2	idb, ienv, imaxdur, idur
if ienv == 1 || ienv == 2 then; for common start
istart		=		istartseq
else; else starting point as difference to maximal duration of the sequence
istart		=		istartseq + (imaxdur - idur)
endif
		event_i	"i", isubinstr, istart/76.2, idur/76.2, ifq1, ifq2, ifq3, ifq4, ifq5, idb1, idb2
if iprintjn == 1 then
		prints		"%d.%d.%d.%d%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.2f%t%t%.0f%t%.0f%n", 2, int(indxseq/5) + 1, (indxseq%5) + 1, indxnote + 1, istart, istart/76.2, idur, idur/76.2, ifq1, ifq5, idb1, idb2
endif
indxnotabs	=		indxnotabs + 1
		loop_lt	indxnote, 1, icount, note
		loop_lt	indxseq, 1, ftlen(iftcounts), seq
  endop

  opcode SS2_TrigEvents_3, 0, iiiiiii
;triggers the events of part 3 and prints them if iprintjn=1
iftstarts, iftcounts, iftfreqs, iftdurs, iftdb, isubinstr, iprintjn xin
indxseq	        =		0
indxnotabs	=		0
seq: ;double loop only for the printout; everything else runs note by note
indxnote	=		0
icount		tab_i		indxseq, iftcounts
note:
ifq1		tab_i		indxnotabs * 5, iftfreqs
ifq2		tab_i		indxnotabs * 5 + 1, iftfreqs
ifq3		tab_i		indxnotabs * 5 + 2, iftfreqs
ifq4		tab_i		indxnotabs * 5 + 3, iftfreqs
ifq5		tab_i		indxnotabs * 5 + 4, iftfreqs
idur		tab_i		indxnotabs, iftdurs
idb1		tab_i		indxnotabs, iftdb
idb2		=		-40
istart		tab_i		indxnotabs, iftstarts
		event_i	"i", isubinstr, istart/76.2, idur/76.2, ifq1, ifq2, ifq3, ifq4, ifq5, idb1, idb2
if iprintjn == 1 then
		prints		"%d.%d.%d.%d%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.2f%t%t%.0f%t%.0f%n", 3, int(indxseq/5) + 1, (indxseq%5) + 1, indxnote + 1, istart, istart/76.2, idur, idur/76.2, ifq1, ifq5, idb1, idb2
endif
indxnotabs	=		indxnotabs + 1
		loop_lt	indxnote, 1, icount, note
		loop_lt	indxseq, 1, ftlen(iftcounts), seq
  endop

  opcode SS2_TrigEvents_4, 0, iiiiiiii
;triggers the events of part 4 and prints them if iprintjn=1
iftstarts, iftcounts, iftfreqs, iftdurs, iftdb, iftenv, isubinstr, iprintjn xin
iftmxgrpdrs	TabMkTbFrmGrpMx_i iftdurs, iftcounts; table of maximal durations of each sequence
indxseq	=		0
indxnotabs	=		0
seq:
indxnote	=		0
icount		tab_i		indxseq, iftcounts
istartseq	tab_i		indxseq, iftstarts
ienv		tab_i		indxseq, iftenv
imaxdur	tab_i		indxseq, iftmxgrpdrs
note:
ifq1		tab_i		indxnotabs * 5, iftfreqs
ifq2		tab_i		indxnotabs * 5 + 1, iftfreqs
ifq3		tab_i		indxnotabs * 5 + 2, iftfreqs
ifq4		tab_i		indxnotabs * 5 + 3, iftfreqs
ifq5		tab_i		indxnotabs * 5 + 4, iftfreqs
idur		tab_i		indxnotabs, iftdurs
idb		tab_i		indxnotabs, iftdb
idb1, idb2	SS2_dbs_4	idb, ienv, imaxdur, idur
if ienv == 1 || ienv == 2 || ienv == 5 then; for common starts
istart		=		istartseq
else; else starting point as difference to maximal duration of the sequence
istart		=		istartseq + (imaxdur - idur)
endif
		event_i	"i", isubinstr, istart/76.2, idur/76.2, ifq1, ifq2, ifq3, ifq4, ifq5, idb1, idb2
if iprintjn == 1 then
		prints		"%d.%d.%d.%d%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.2f%t%t%.0f%t%.0f%n", 4, int(indxseq/5) + 1, (indxseq%5) + 1, indxnote + 1, istart, istart/76.2, idur, idur/76.2, ifq1, ifq5, idb1, idb2
endif
indxnotabs	=		indxnotabs + 1
		loop_lt	indxnote, 1, icount, note
		loop_lt	indxseq, 1, ftlen(iftcounts), seq
  endop

  opcode SS2_TrigEvents_5, 0, iiiiiii
;triggers events of part 5 and prints them if iprintjn=1
iftstarts, iftfreqs, iftdurs, iftdbs, iftcount, isubinstr, iprintjn xin
indxnotabs	=		0
indxseq	=		0
seq:
indxnote	=		0
icount		tab_i		indxseq, iftcount
note:
istart		tab_i		indxnotabs, iftstarts
ifq1		tab_i		indxnotabs * 5, iftfreqs
ifq2		tab_i		indxnotabs * 5 + 1, iftfreqs
ifq3		tab_i		indxnotabs * 5 + 2, iftfreqs
ifq4		tab_i		indxnotabs * 5 + 3, iftfreqs
ifq5		tab_i		indxnotabs * 5 + 4, iftfreqs
idur		tab_i		indxnotabs, iftdurs
idb1		tab_i		indxnotabs * 2, iftdbs
idb2		tab_i		indxnotabs * 2 + 1, iftdbs
		event_i	"i", isubinstr, istart/76.2, idur/76.2, ifq1, ifq2, ifq3, ifq4, ifq5, idb1, idb2
if iprintjn == 1 then
		prints		"%d.%d.%d.%d%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.2f%t%t%.0f%t%.0f%n", 5, int(indxseq/5) + 1, (indxseq%5) + 1, indxnote + 1, istart, istart/76.2, idur, idur/76.2, ifq1, ifq5, idb1, idb2
endif
indxnotabs	=		indxnotabs + 1
		loop_lt	indxnote, 1, icount, note
		loop_lt	indxseq, 1, ftlen(iftcount), seq
  endop

  opcode SS2_TrigEvents_Coda, i, iiiiiii
;triggers the events for the cods and prints them if iprintjn=1
iftdur, iftfreq, iftdbs, iftser, istart, isubinstr, iprintjn xin
indx		=		0
loop:
iserval	tab_i		indx, iftser
ifq1, ifq2, ifq3, ifq4, ifq5 SS2_FreqsAusGTSS iftfreq, 1, 1, 1, iserval
idur		SS2_ValsAusGTSS iftdur, 1, 1, 5, iserval
idb		SS2_ValsAusGTSS iftdbs, 1, 2, 1, iserval
;envelopes
if iserval > 3 then; series has 4 or 5: crescendo
 if idb < -8 then; of course this is half a joke, but
idb1		=		-30; the first cresc starts at -30 db
 else
idb1		=		-40; in contrast, the second at -40
 endif
idb2		=		idb
else; diminuendo
 if idb < -6 then; see above for the joke...
idb2		=		-30
 else
idb2		=		-40
 endif
idb1		=		idb
endif
		event_i	"i", isubinstr, istart/76.2, idur/76.2, ifq1, ifq2, ifq3, ifq4, ifq5, idb1, idb2
if iprintjn == 1 then
		prints		"Coda.%d%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.3f%t%t%.2f%t%t%.2f%t%t%.0f%t%.0f%n",  indx+1, istart, istart/76.2, idur, idur/76.2, ifq1, ifq5, idb1, idb2
endif
istart		=		istart + idur
		loop_lt	indx, 1, ftlen(iftser), loop
		xout		istart; time after the end of the last event
  endop


;============================================================================;
;============================================================================;
;============================================================================;
; II. GENERATION OF THE STRUCTURES AND SOUNDS                                ;
;============================================================================;
;============================================================================;
;============================================================================;

instr 1
;;GUI-INPUT AND GENERAL SETTINGS
isubinstr	=		10; instrument executing the sounds
kprintlines	invalue	"printlines"; whether each note should be printed with its values (0=nein, 1=ja)
iprintlines	=		i(kprintlines)
kwdmix		invalue	"wdmix";(between 0=dry und 1=reverberating)
kroomsize	invalue	"roomsize"; 0-1 (for freeverb)
khfdamp	invalue	"hfdamp"; attenuation of high frequencies (0-1) (für freeverb)
kshowdb	invalue	"showdb"; 0=raw amplitudes, 1=db as display in the widgets
kdbrange	invalue	"dbrange"; if kshowdb==1: which db range


;============================================================================;
;============================================================================;
;    A. THE SERIES AND NUMBER SQUARES                                        ;
;============================================================================;
;============================================================================;
iReihe		ftgen		0, 0, -5, -2, 3, 5, 1, 4, 2; initially given
ifzwaf		=		5 ^ (1/25); 25th root of 5
ift_R1		SS2_Transp_R	iReihe; generates R1, the first number square from the basic series
ift_Abst_R1	SS2_HopAbst	ift_R1; distances of the elements from line 2-5 in R1 to the elements of line 1
ift_R2		SS2_Hop	ift_R1, 5, 2, ift_Abst_R1; number square R2 
ift_R3		SS2_Hop	ift_R1, 10, 3, ift_Abst_R1; number square R3
ift_R4		SS2_Hop	ift_R1, 15, 4, ift_Abst_R1; number square R4
ift_R5		SS2_Hop	ift_R1, 20, 5, ift_Abst_R1; number square R5 
ift_U1		SS2_Umk	ift_R1; inversion of R1
ift_U2		SS2_Umk	ift_R2; inversion of R2
ift_U3		SS2_Umk	ift_R3; inversion of R3
ift_U4		SS2_Umk	ift_R4; inversion of R4
ift_U5		SS2_Umk	ift_R5; inversion of R5
		prints		"%n%nGENERATING NUMBER SQUARES:%n%n"
		TableDumpSimpS ift_R1, 0, "\nR1:", 5
		TableDumpSimpS ift_R2, 0, "R2:", 5
		TableDumpSimpS ift_R3, 0, "R3:", 5
		TableDumpSimpS ift_R4, 0, "R4:", 5
		TableDumpSimpS ift_R5, 0, "R5:", 5
		TableDumpSimpS ift_U1, 0, "U1:", 5
		TableDumpSimpS ift_U2, 0, "U2:", 5
		TableDumpSimpS ift_U3, 0, "U3:", 5
		TableDumpSimpS ift_U4, 0, "U4:", 5
		TableDumpSimpS ift_U5, 0, "U5:", 5


;============================================================================;
;============================================================================;
;    B. BASIC TABLES FOR FREQUENCIES, DURATIONS, INTENSITIES                 ;
;============================================================================;
;============================================================================;

;81 frequencies on the basis of 100 hz with the ratio 5^(1/25)
ift_Freqs	TabMultRecurs_i 81, 100, ifzwaf
;durations on the basis of 2.5 cm (0.039 sec) in the same proportion
ift_Durs	TabMultRecurs_i 61, 2.5, ifzwaf; durations in centimeters (1 sec = 76.2 cm)
ift_Durs	TabRvrs_i	ift_Durs; reverse order
;intensitäties oscillating between -30 and 0 
ift_Intens	SS2_MkGlob_dB_Tab 0, -30
		prints		"%n%nGENERATING TABLES OF MATERIAL:%n%n"
		TableDumpSimpS ift_Freqs, 0, "\nFREQUENCIES (Hz):", 5
		TableDumpSimpS ift_Durs, 2, "\nDURATIONS (cm):", 5
		TableDumpSimpS ift_Intens, 0, "\nINTENSITIES (dB):", 5



;============================================================================;
;============================================================================;
;    C. EVENTS OF THE PARTS                                                  ;
;============================================================================;
;============================================================================;

;I will use the following terms, borrowed from Silberhorn's terminology:     ;
;a) 5 sinustones make up one SOUND ("KLANG") or one SOUNDMIX                 ;
;("KLANGMISCHUNG"). Every soundmix that occurs during the piece is termed    ;
;   EVENT ("EREIGNIS"), TONE ("TON") or NOTE                                 ;
;b) 1-5 notes make up a SEQUENCE ("SEQUENZ").                                ;
;c) 5 sequences form a SET ("GRUPPE") or SET OF SEQUENCES ("SEQUENZGRUPPE"). ;
;d) 5 sets make up one PART ("TEIL").                                        ;
;e) 5 parts, and the coda, form the whole piece.                             ;



;============================================================================;
;       1. PART 1                                                            ;
;============================================================================;

;;an envelope for each note in this part (1=crescendo, 2=diminuendo)
iftenv_1	ftgen		0, 0, -75, -2,   	2, 1,   1, 2, 2, 1,   2, 2, 2, 1, 2,   2, 2, 1,   2,\
							2, 1,   1, 2, 2,   2,   1, 2, 1, 2,   2, 1, 2, 1, 2,\
							1, 2,   1, 2, 2,   1, 2, 2, 2,   2, 1, 2, 2, 2,   1,\
							2, 2,   2,   2, 1, 2, 2,   1, 2, 2,   1, 2, 2, 1, 2,\
							1, 2,   2,   2, 1, 2, 1, 2,   2, 2, 1, 2,   1, 2, 2
istart_1	=		0; absolute starting time of this part
iftcounts_1	=		ift_R5; R5 defines the number of elements in each sequence
iftfreqs_1	SS2_MkParamTab_Meth1 ift_Freqs, iftcounts_1, ift_R1, 3, ift_R2, ift_R1, ift_R2, ift_R3, 1; list of all frequences
iftdurs_1	SS2_MkParamTab_Meth1 ift_Durs, iftcounts_1, ift_R3, 1, ift_R4, ift_R3, ift_R4, ift_R5, 0; list of durations
iftdb_1	SS2_MkParamTab_Meth1 ift_Intens, iftcounts_1, ift_R2, 5, ift_R3, ift_R2, ift_R3, ift_R4, 0; list of intensities
iftstarts_1	SS2_Starts_part ift_Durs, iftcounts_1, ift_R4, 1, ift_U5, ift_R4, ift_R5, ift_R1, istart_1; starting times (one per sequence)
		prints "%n%n"
;		TableDumpSimp iftfreqs_1, 0, 5
;		TableDumpSimp iftdurs_1, 0, 5
;		TableDumpSimp iftdb_1, 0, 5
;		TableDumpSimp iftstarts_1, 1, 5

		prints		"%n%nGENERATING LIST OF EVENTS PART 1 (Events as Part.Set.Sequence.Note):%n%n"
		prints		"Event%t%tStart (cm)%tStart (sec)%tDuration (cm)%tDuration (sec)%tFreqInf (Hz)%tFreqSup (Hz)%tdB1%tdB2%n"
		SS2_TrigEvents_1 iftstarts_1, iftcounts_1, iftfreqs_1, iftdurs_1, iftdb_1, iftenv_1, isubinstr, iprintlines



;============================================================================;
;      2. PART 2                                                             ;
;============================================================================;

;;TABLE OF POSSIBLE ENVELOPES IN PART 2:
; 1 = common start, diminuendo, truncation of shorter notes before -40 dB because of common point of intersection ("fluchtpunkt")
; 2 = gemeinsamer beginn, crescendo of single tones
; 3 = gemeinsames ende, diminuendo of single tones
; 4 = common end, crescendo, start of shorter tones above -40 dB because of common point of intersection ("fluchtpunkt")
; 5 = common end, crescendo of single tones
iftenv_2	ftgen		0, 0, -25, -2,	1, 2, 4, 3, 5,\
							1, 4, 3, 5, 2,\
							1, 4, 5, 2, 3,\
							4, 3, 1, 5, 2,\
							3, 1, 4, 5, 2
istart_2	tab_i		ftlen(iftstarts_1) - 1, iftstarts_1; absolute starting time of this part
iftcounts_2	=		ift_R1; R1 defines the number of elements in each sequence
iftfreqs_2	SS2_MkParamTab_Meth1 ift_Freqs, iftcounts_2, ift_R2, 5, ift_R3, ift_R4, ift_R5, ift_R1, 1; list of all frequencies
iftdurnorm_2	SS2_MkParamTab_Meth1 ift_Durs, iftcounts_2, ift_R4, 3, ift_R5, ift_R1, ift_R2, ift_R3, 0; list of "underlying" durations
iftdurs_2	SS2_durs2	iftdurnorm_2, iftcounts_2, iftenv_2; list of modified durations (see above in opcode SS2_durs2)
iftdb_2	SS2_MkParamTab_Meth1 ift_Intens, iftcounts_2, ift_R3, 2, ift_R4, ift_R5, ift_R1, ift_R2, 0; list of intensities
iftstarts_2	SS2_Starts_part ift_Durs, iftcounts_2, ift_R5, 3, ift_U1, ift_R2, ift_R3, ift_R4, istart_2; starting times (1 per seq)
		prints "%n%n"
;		TableDumpSimp iftfreqs_2, 0, 5
;		TableDumpSimp iftdurs_2, 2, 5
;		TableDumpSimp iftdb_2, 0, 5
;		TableDumpSimp iftstarts_2, 1, 5
		prints		"%n%nGENERATING LIST OF EVENTS PART 2 (Events as Part.Set.Sequence.Note):%n%n"
		prints		"Event%t%tStart (cm)%tStart (sec)%tDuration (cm)%tDuration (sec)%tFreqInf (Hz)%tFreqSup (Hz)%tdB1%tdB2%n"
		SS2_TrigEvents_2 iftstarts_2, iftcounts_2, iftfreqs_2, iftdurs_2, iftdb_2, iftenv_2, isubinstr, iprintlines


;============================================================================;
;      3. PART 3                                                             ;
;============================================================================;

istart_3	tab_i		ftlen(iftstarts_2) - 1, iftstarts_2; absolute starting point of this part
iftcounts_3	=		ift_R2; R2 defines the number of elements in each sequence
iftfreqs_3	SS2_MkParamTab_Meth2 ift_Freqs, iftcounts_3, ift_R3, ift_R4, ift_R2, ift_R3, ift_R4, 1; list of all frequencies
iftdurs_3	SS2_MkParamTab_Meth1 ift_Durs, iftcounts_3, ift_R5, 4, ift_R1, ift_R4, ift_R5, ift_R1, 0; list of durations
iftdb_3	SS2_MkParamTab_Meth2 ift_Intens, iftcounts_3, ift_R4, ift_R5, ift_R4, ift_R5, ift_R1, 0; list of intensities
iftstarts_3	SS2_Starts_3 ift_Durs, iftcounts_3, ift_R1, 4, ift_U2, ift_R5, ift_R1, ift_R2, istart_3; starting points (one per note)
;		prints "%n%n"
;		TableDumpSimp iftfreqs_3, 0, 5
;		TableDumpSimp iftdurs_3, 2, 5
;		TableDumpSimp iftdb_3, 0, 5
;		TableDumpSimp iftstarts_3, 1, 5
		prints		"%n%nGENERATING LIST OF EVENTS PART 3 (Events as Part.Set.Sequence.Note):%n%n"
		prints		"Event%t%tStart (cm)%tStart (sec)%tDuration (cm)%tDuration (sec)%tFreqInf (Hz)%tFreqSup (Hz)%tdB1%tdB2%n"
		SS2_TrigEvents_3 iftstarts_3, iftcounts_3, iftfreqs_3, iftdurs_3, iftdb_3, isubinstr, iprintlines


;============================================================================;
;      4. PART 4                                                             ;
;============================================================================;

;;TABLE OF POSSIBLE ENVELOPES IN PART 4:
; 1 = common start, diminuendo, truncation of shorter notes before -40 dB because of common point of intersection ("fluchtpunkt")
; 2 = common start, crescendo of single tones
; 3 = common end, diminuendo of single tones
; 4 = common end, crescendo, start of shorter tones above -40 dB because of common point of intersection ("fluchtpunkt")
; 5 = common start, diminuendo of single tones (this is the only difference to the types used in part 2)
iftenv_4	ftgen		0, 0, -25, -2,	2, 5, 4, 3, 1,\
							2, 1, 5, 4, 3,\
							2, 3, 1, 4, 5,\
							2, 5, 1, 3, 4,\
							2, 3, 5, 1, 4


istart_4	tab_i		ftlen(iftstarts_3) - 1, iftstarts_3; absolute starting point of this part
iftcounts_4	=		ift_R3; R3 defines the number of element in a sequence
iftfreqs_4	SS2_MkParamTab_Meth2 ift_Freqs, iftcounts_4, ift_R4, ift_R5, ift_R5, ift_R1, ift_R2, 1; list of all frequencies
iftdurnorm_4	SS2_MkParamTab_Meth1 ift_Durs, iftcounts_4, ift_R1, 2, ift_R2, ift_R2, ift_R3, ift_R4, 0; list of "underlying" durations
iftdurs_4	SS2_durs4	iftdurnorm_4, iftcounts_4, iftenv_4; list of modified durations (see above in opcode SS2_durs2)
iftdb_4	SS2_dbtab_4	ift_Intens, iftcounts_4, ift_R5, 1, ift_R1, ift_R1, ift_R2, ift_R3, iftenv_4; list of intensities
iftstarts_4	SS2_Starts_part ift_Durs, iftcounts_4, ift_R2, 2, ift_U3, ift_R3, ift_R4, ift_R5, istart_4; starting times (1 per seq)
;		prints "%n%n"
;		TableDumpSimp iftfreqs_4, 0, 5
;		TableDumpSimp iftdurs_4, 2, 5
;		TableDumpSimp iftdb_4, 0, 5
;		TableDumpSimp iftstarts_4, 1, 5
		prints		"%n%nGENERATING LIST OF EVENTS PART 4 (Events as Part.Set.Sequence.Note):%n%n"
		prints		"Event%t%tStart (cm)%tStart (sec)%tDuration (cm)%tDuration (sec)%tFreqInf (Hz)%tFreqSup (Hz)%tdB1%tdB2%n"
		SS2_TrigEvents_4 iftstarts_4, iftcounts_4, iftfreqs_4, iftdurs_4, iftdb_4, iftenv_4, isubinstr, iprintlines



;============================================================================;
;      5. PART 5                                                             ;
;============================================================================;

;;ABSOLUTE STARTING TIME (in cm)
istart_5	tab_i		ftlen(iftstarts_4) - 1, iftstarts_4
;;NOTES PER SEQUENCE
iftcounts_5	=		ift_R4; R4 defines the number of elements in a sequence

;;TYPES OF EVENTS
;1 = as in part 1 (single tones conjugated), 2 = as in part 2 and 4 (chords starting or beginning collectively), 3 = as in part 3 (single isolated notes)
ifteventtyps_5	ftgen		0, 0, -25, -2, 	3, 1, 2, 1, 2,\
								2, 3, 2, 1, 1,\
								2, 3, 1, 2, 1,\
								2, 2, 3, 1, 1,\
								2, 2, 1, 1, 3

;;ENVELOPES
;A) FOR EVENTS OF TYPE 1 (several consecutive notes, each with its own envelope)
;in total, there are 10 sequences of type 1; seperated by newline here (1=cresc, 2=dim)
iftenv_5_typ1	ftgen		0, 0, -30, -2, 	2,\
								1, 2, 2, 1, 2,\
								2, 2, 1, 2,\
								2,\
								1, 2, 1,\
								1, 2,\
								1, 2, 2, 1,\
								2, 1, 2,\
								2, 2, 2, 2, 2,\
								1, 2

;B) FOR EVENTS OF TYPE 2 (chords) (this time all kinds of envelops, i.e. 6)
; 1 = common start, diminuendo, truncation of shorter tones before -40 dB because of common point of intersection ("fluchtpunkt")
; 2 = common start, crescendo of single tones
; 3 = common end, diminuendo of single tones
; 4 = common end, crescendo, start of shorter notes greater than -40 dB because of common point of intersection ("fluchtpunkt")
; 5 = common start, diminuendo of single tones
; 6 = common end, crescendo of single tones
;in total, there are 10 sequences of type 2 (see above ifteventtyps_5: two in each set of sequences)
iftenv_5_typ2	ftgen		0, 0, -10, -2, 	5, 6, 3, 2, 1, 4, 2, 3, 2, 3

;;FREQUENCIES  
;applying the same methods as in part 3 and 4, it should be like this:
;(iftfreqs_5	SS2_Freqtab_3 ift_Freqs, iftcounts_5, ift_R5, ift_R1, ift_R3, ift_R4, ift_R5)
;but in some sequences a (untransposed) set is replaced by a 2.
;these sequences can be represented as two series of five (positions in a set of sequences respectively):
irpl5a		ftgen		0, 0, -5, -2, 1, 4, 2, 5, 3; this gives a good impression...
irpl5b		ftgen		0, 0, -5, -2, 2, 2, 5, 3, 5; but this is not indeed a proper series =(
;so this becomes:
iftfreqs_5	SS2_Freqtab_5 ift_Freqs, iftcounts_5, ift_R5, ift_R1, ift_R3, ift_R4, ift_R5, irpl5a, irpl5b

;;DURATIONS
;basic table of durations
iftdurs_5a	SS2_MkParamTab_Meth2 ift_Durs, iftcounts_5, ift_R2, ift_R3, ift_R5, ift_R1, ift_R2, 0
;change of durations in chords (same as for parts 2 and 4)
iftdurs_5	SS2_durs5	iftdurs_5a, ifteventtyps_5, iftcounts_5, iftenv_5_typ2

;;STARTS
iftstarts_5a	SS2_MkParamTab_Meth2 ift_Durs, iftcounts_5, ift_R3, ift_U4, ift_R1, ift_R2, ift_R3, 0
iftstarts_5	SS2_Starts_5	iftstarts_5a, iftcounts_5, ifteventtyps_5, iftdurs_5, iftenv_5_typ2, istart_5

;;AMPLITUDES
iftdbs_5a	SS2_MkParamTab_Meth2 ift_Intens, iftcounts_5, ift_R1, ift_R2, ift_R4, ift_R5, ift_R1, 0
;there are so many deviations from this presumptive basis that for the time being only a list of deviation makes sense: pairs of index-to-be-replaced and value-of-this-position
;(the list could be considerably shortened by applying even more rules - next time....)
iftkorrdbs_5	ftgen		0, 0, -92, -2,\
 					0, -22,  1, -18,  2, -17,  3, -15,\
					 6, -18,\
					 7, -26,  8, -27,  9, -30,  10, -29,  11, -28,\
					 12, -21,  13, -18,\
					19, -30,\
					 21, -22,  22, -29,  23, -18,\
					 25, -4,\
					31, -12,  32, -13,  33, -17,  34, -4,\
					 36, -21,  38, -10,\
					 39, -30,  40, -29,  41, -27,\
					46, -23,\
					 47, -15,\
					 48, -24,  50, -13,\
					 53, -21,  54, -9,  55, -21,  56, -13,\
					 59, -7,\
					61, -14,  62, -11,  63, -7,  64, -5,\
					 66, -11,  67, -13,  68, -18,  69, -21,\
					 70, -29,  71, -23,\
					 73, -19
iftdbs_5b	SS2_dbtab_5b	iftdbs_5a, iftkorrdbs_5
iftdbs_5	SS2_dbs_5	iftdbs_5b, iftcounts_5, ifteventtyps_5, iftenv_5_typ1, iftenv_5_typ2, iftdurs_5

;;TRIGGERING EVENTS
		prints		"%n%nGENERATING LIST OF EVENTS PART 5 (Events as Part.Set.Sequence.Note):%n%n"
		prints		"Event%t%tStart (cm)%tStart (sec)%tDuration (cm)%tDuration (sec)%tFreqInf (Hz)%tFreqSup (Hz)%tdB1%tdB2%n"
		SS2_TrigEvents_5 iftstarts_5, iftfreqs_5, iftdurs_5, iftdbs_5, iftcounts_5, isubinstr, iprintlines

;		TableDumpSimp iftfreqs_5, 0, 5
;		TableDumpSimp iftdurs_5, 2, 5
;		TableDumpSimp iftstarts_5a, 1, 5
;		TableDumpSimp iftstarts_5, 1, 5
;		TableDumpSimp iftdbs_5b, 0, 5
;		TableDumpSimp iftdbs_5, 0, 10



;============================================================================;
;      6. CODA                                                               ;
;============================================================================;

istart_coda	tab_i		ftlen(iftstarts_5) - 1, iftstarts_5
		prints		"%n%nGENERATING LIST OF EVENTS CODA (Events as Part.Set.Sequence.Note):%n%n"
		prints		"Event%t%tStart (cm)%tStart (sec)%tDuration (cm)%tDuration (sec)%tFreqInf (Hz)%tFreqSup (Hz)%tdB1%tdB2%n"
iend		SS2_TrigEvents_Coda ift_Durs, ift_Freqs, ift_Intens, iReihe, istart_coda, isubinstr, iprintlines


;============================================================================;
;      7. CALCULATION OF TOTAL DURATION AND SOUND OUTPUT                     ;
;============================================================================;

;; calculate net total duration plus maximum reverb time
p3		=		(iend / 76.2) + 5
;; receive dry signal from instr 10 and mix with reverb
gadryL		init		0
gadryR		init		0
awetL, awetR	freeverb	gadryL, gadryR, kroomsize, khfdamp
aoutL		=		(1-kwdmix) * gadryL + (kwdmix * awetL)
aoutR		=		(1-kwdmix) * gadryR + (kwdmix * awetR)
		outs		aoutL, aoutR
;; send to GUI
kTrigDisp	metro		10
		ShowLED_a	"outL", aoutL, kTrigDisp, kshowdb, kdbrange
		ShowLED_a	"outR", aoutR, kTrigDisp, kshowdb, kdbrange
		ShowOver_a	"outLover", aoutL, kTrigDisp, 2
		ShowOver_a	"outRover", aoutR, kTrigDisp, 2
;; reset global audio
gadryL		=		0	
gadryR		=		0
endin


;============================================================================;
;      8. INSTRUMENT FOR GENERATING A SOUNDMIX/EVENT                         ;
;============================================================================;

instr 10
ifreq1		=		p4
ifreq2		=		p5
ifreq3		=		p6
ifreq4		=		p7
ifreq5		=		p8
idb1		=		p9; -dB at the start
idb2		=		p10; -dB at the end
kpanwidth	invalue	"panwidth"; 0=mono, 1=broad stereo panning (low=left, high=right)
kampcorr	invalue	"vol"; volume multiplier(to adjust according to wet-dry-mix)
adb		linseg		idb1, p3, idb2
aenv		linen		ampdb(adb), .01, p3, .01
a1		oscili		aenv*kampcorr, ifreq1, 1
a2		oscili		aenv*kampcorr, ifreq2, 1
a3		oscili		aenv*kampcorr, ifreq3, 1
a4		oscili		aenv*kampcorr, ifreq4, 1
a5		oscili		aenv*kampcorr, ifreq5, 1
aout		sum		a1, a2, a3, a4, a5
;stereo-panning
irel = (log(ifreq1/100) / log(5)) * 25; resulting values between 0=lowest und 60=highest frequency
ipan = irel / 60; 0-1
kpan = (ipan * kpanwidth) + (1 - kpanwidth) / 2; spread around 0.5 as centre depending on kpanwidth
aL, aR		pan2		aout, kpan
gadryL		=		gadryL+aL
gadryR		=		gadryR+aR
endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1; sinus
i 1 0 1; p3 is computed internally
e
</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 333 38 434 733
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>
<MacGUI>
ioView nobackground {59624, 59624, 59624}
ioText {34, 102} {365, 249} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border Reverb (freeverb)
ioText {34, 380} {365, 180} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border Panning and Volume
ioSlider {41, 523} {250, 29} 0.000000 0.500000 0.200000 vol
ioText {165, 491} {97, 32} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Volume
ioMeter {38, 574} {336, 22} {0, 59904, 0} "out1_post" 0.363636 "outL" 0.000000 fill 1 0 mouse
ioMeter {372, 574} {27, 22} {50176, 3584, 3072} "outLover" 0.000000 "outLover" 0.000000 fill 1 0 mouse
ioMeter {38, 601} {336, 22} {0, 59904, 0} "out2_post" 0.526316 "outR" 0.000000 fill 1 0 mouse
ioMeter {372, 601} {27, 22} {50176, 3584, 3072} "outRover" 0.000000 "outRover" 0.000000 fill 1 0 mouse
ioSlider {136, 161} {160, 31} 0.000000 1.000000 0.443750 wdmix
ioText {38, 160} {97, 32} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dry
ioText {298, 161} {97, 31} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet
ioText {158, 132} {110, 29} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Mix
ioSlider {138, 227} {160, 31} 0.000000 1.000000 0.525000 roomsize
ioText {40, 226} {97, 32} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Small
ioText {300, 227} {97, 31} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Large
ioText {156, 193} {110, 30} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Room Size
ioSlider {138, 295} {160, 31} 0.000000 1.000000 0.456250 hfdamp
ioText {40, 294} {97, 32} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder No
ioText {300, 295} {97, 31} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Yes
ioText {41, 261} {352, 31} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder High Frequency Attenuation
ioSlider {160, 444} {132, 32} 0.000000 1.000000 1.000000 panwidth
ioText {37, 445} {122, 32} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Narrow (Mono)
ioText {294, 445} {97, 31} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Broad
ioText {38, 412} {352, 31} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Stereo Panning
ioText {291, 522} {98, 31} display 0.000000 0.00100 "vol" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.2000
ioText {34, 14} {366, 78} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder KARLHEINZ STOCKHAUSEN: STUDIE IIÂ¬generated in Csound by Joachim HeintzÂ¬Version 1, November 2009
ioCheckbox {40, 675} {20, 20} on printlines
ioText {64, 671} {352, 31} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Print all Events in Output Console
ioText {319, 631} {80, 25} editnum 40.000000 0.100000 "dbrange" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 40.000000
ioText {240, 630} {80, 26} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder dB-Range
ioText {37, 632} {91, 25} label 0.000000 0.00100 "" left "Helvetica" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Show as
ioMenu {127, 631} {109, 26} 1 303 "Amplitudes,dB" showdb
</MacGUI>


<CsoundSynthesizer>
<CsOptions>
-odac -Ma -b128 -B512 --midi-key=4 --midi-velocity-amp=5 -m0 -+max_str_len=1000
</CsOptions>
<CsInstruments>
ksmps = 64
nchnls = 2

;============================================================================;
;                    PLAYING SCALES WITH A MIDI KEYBOARD                     ;
;============================================================================;
;                  by Joachim Heintz and Richard Boulanger                   ;
;                             January 2010                                   ;
;============================================================================;


;;SOME GLOBAL VARIABLES AND ASSIGNMENTS

giSine		ftgen		0, 0, 8192, 10, 1
giSaw		ftgen		0, 0, 8192, 10, 1, 1/2, 1/3, 1/4, 1/5, 1/6, 1/7, 1/8, 1/9
giSquare	ftgen		0, 0, 8192, 10, 1, 0, 1/3, 0, 1/5, 0, 1/7, 0, 1/9, 0, 1/11
		massign 	0, 10; send all midi noteon/noteoff events to instr 10
gkscale	init		1
gkreftone	init		69
gktunfreq	init		440
gksound	init		0
		turnon		1
		turnon		2
		turnon		3
		turnon		4
		turnon		100


;;OPCODE DEFINITIONS

  opcode FreqByEqScale, i, iiii
;;frequency calculation for one step of an equal tempered scale. the unit for the scale can be an octave, a duodecim, or whatever
;iref_freq:	reference frequency
;iumult:	unit multiplier (2 = octave, 3 = Bohlen-Pierce scale, 5 = stockhausen scale in Studie2)
;istepspu:	steps per unit (12 for semitones, 13 for complete Bohlen-Pierce scale, 25 for studie2 scale)
;istep:	selected step (0 = reference frequency, 1 = one step higher, -1 = one step lower)
iref_freq, iumult, istepspu, istep xin
ifreq		=		iref_freq * (iumult ^ (istep / istepspu))
		xout		ifreq
  endop

  opcode FreqByCentTab, i, iiii
;;frequency calculation of a step of a scale which is defined by a list of cent values
;iftcent:	function table with the number of cent values per unit multiplier (usually 2 = octave)
	;the first value must be 0 and matches iref_freq, if istep == 0
	;the size of the table must be equal to the number of cent values in it (use -size and -2 as GEN)
;iref_freq:	reference frequency (= for istep == 0)
;iumult:	unit multiplier (2 = octave, 3 = duodecime or whatever)
;istep:	selected step (0 = reference frequency, 1 = one step higher, -1 = one step lower)
iftcent, iref_freq, iumult, istep xin
itablen	=		ftlen(iftcent)
ipos 		=		floor(istep/itablen); "octave" position
ibasfreq	=		(iumult ^ ipos) * iref_freq; base freq of istep
icentindx	=		istep % itablen; position of the appropriate centvalue ...
icentindx	=		(icentindx < 0 ? (itablen + icentindx) : icentindx); ... in the table
icent		tab_i		icentindx, iftcent; get cent value
ifreq		=		ibasfreq * cent(icent); get frequency
		xout		ifreq
  endop

  opcode FreqByRatioTab, i, iiii
;;frequency calculation of a step of a scale which is defined by a list of proportions
;iftprops:	function table with the number of proportions per unit multiplier (usually 2 = octave)
	;the first value must be 1 and matches iref_freq, if istep == 0
	;the size of the table must be equal to the number of proportions in it (use -size and -2 as GEN)
;iref_freq:	reference frequency (= for istep == 0)
;iumult:	unit multiplier (2 = octave, 3 = duodecime or whatever)
;istep:	selected step (0 = reference frequency, 1 = one step higher, -1 = one step lower)
iftprops, iref_freq, iumult, istep xin
itablen	=		ftlen(iftprops)
ipos 		=		floor(istep/itablen); "octave" position
ibasfreq	=		(iumult ^ ipos) * iref_freq; base freq of istep
ipropindx	=		istep % itablen; position of the appropriate proportion ...
ipropindx	=		(ipropindx < 0 ? (itablen + ipropindx) : ipropindx); ... in the table
iprop		tab_i		ipropindx, iftprops; get proportion
ifreq		=		ibasfreq * iprop; get frequency
		xout		ifreq
  endop

  opcode TabMkPartCp_i, i, iiio
;copies ihowmany values starting from index istrtindx in isrc to a new function table (starting at index istrtwrite which defaults to 0) and returns its number
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

  opcode FreqByECRTab, i, iii
;frequency calculation by either equal steps, cent list, or ratio list. the first value in ift gives the unit multiplier of the scale (e.g. 2 = octave or 3 = perfect 12th). the methods are distinguished by the second value in ift:
;if the second value is 0, ift is considered to be a centlist
;if the second value is 1, ift is considered to be a list of proportions
;else the second value is read as the number of equal tempered steps in the unit multiplier (e.g. 12 gives the usual keyboard tuning with a ratio of 12th root by 2 for each step when the first table value is 2)
ift, iref_freq, istep xin
ifirst		tab_i		0, ift; unit multiplier
isecond	tab_i		1, ift; 0=centlist, 1=ratios, else=equal tempered
if isecond == 0 then
iftcent	TabMkPartCp_i ift, 1, ftlen(ift)-1
ifreq		FreqByCentTab iftcent, iref_freq, ifirst, istep
elseif isecond == 1 then
iftratios	TabMkPartCp_i ift, 1, ftlen(ift)-1
ifreq		FreqByRatioTab iftratios, iref_freq, ifirst, istep
else
ifreq		FreqByEqScale iref_freq, ifirst, isecond, istep
endif
		xout		ifreq
  endop

  opcode MidiNoteIn, kkk, 0
;returns channel, key an velocity from a MIDI Note-On event. if no note-on event is received, -1 is returned for all three output values
keventin, kchanin, knotin, kvelin midiin
if keventin == 144 then
kchan		=		kchanin
knot		=		knotin
kvel		=		kvelin
else
kchan		=		-1
knot		=		-1
kvel		=		-1
endif
		xout		kchan, knot, kvel
  endop

  opcode StrRatToF, i, S
;converts a string containing a ratio to a float number; e.g. "1/2" returns 0.5
Srat		xin
idiv		strindex	Srat, "/"
Snum		strsub		Srat, 0, idiv; numerator
Sdenom		strsub		Srat, idiv+1;demoninator
inum		strtod		Snum
idenom		strtod		Sdenom
ifloat		=		inum / idenom
		xout		ifloat
  endop

  opcode StrNumsRToFT, i, So
;transforms a string of numbers which are separated by one space to a function table containing these numbers and allows also ratios as "4/3". if no number for the ftable is given, ftgen is called with ifn=0
String, iftno xin
  ;first loop: check how many spaces are in String
Scpy 		strcpy 	String
ihowmany 	= 		-1
loop1:
ispace		strindex 	Scpy, " "
Scpy 		strsub 	Scpy, ispace+1
ihowmany 	= 		ihowmany + 1
 if ispace > -1 igoto loop1
  ;second loop: write the by spaces separated substrings as numbers in iftout
iftout 	ftgen 		iftno, 0, -(ihowmany+1), -2, 0
indx		=		0
Scpy 		strcpy 	String; go back to the original string
loop2:
inext 		strindex 	Scpy, " "; position of next space
Snum		strsub		Scpy, 0, inext; number as string
irat		strindex	Snum, "/"; -1 if there is no /
if irat == -1 then
inum		strtod		Snum; number as simple transformation
else
inum		StrRatToF	Snum; number as ratio transformation
endif
		tabw_i 	inum, indx, iftout; write it to iftout
Scpy 		strsub 	Scpy, inext+1; take the next part
indx		=		indx + 1; increase write index
 if inext > -1 igoto loop2
		xout		iftout
  endop

  opcode ShowLED_a, 0, Sakkk
;Shows an audio signal in an outvalue channel. You can choose to show the value in dB or in raw amplitudes.
;;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;kdb: 1 = show in dB, 0 = show in raw amplitudes (both in the range 0-1)
;kdbrange: if idb=1: how many db-steps are shown (e.g. if 36 you will not see anything from a signal below -36 dB)
Soutchan, asig, kdispfreq, kdb, kdbrange	xin
kdispval	max_k	asig, kdispfreq, 1
	if kdb != 0 then
kdb 		= 		dbfsamp(kdispval)
kval 		= 		(kdbrange + kdb) / kdbrange
	else
kval		=		kdispval
	endif
			outvalue	Soutchan, kval
  endop

  opcode ShowOver_a, 0, Sakk
;Shows if the incoming audio signal was more than 1 and stays there for some time
;;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;khold: time in seconds to "hold the red light"
Soutchan, asig, kdispfreq, khold	xin
kon		init		0
ktim		times
kstart		init		0
kend		init		0
khold		=		(khold < .01 ? .01 : khold); avoiding too short hold times
kmax		max_k		asig, kdispfreq, 1
	if kon == 0 && kmax > 1 then
kstart		=		ktim
kend		=		kstart + khold
		outvalue	Soutchan, kmax
kon		=		1
	endif
	if kon == 1 && ktim > kend then
		outvalue	Soutchan, 0
kon		=		0
	endif
  endop


instr 1; building function tables 1-30 from the line edit widgets
Scale1		invalue		"scale1"
giScale1	StrNumsRToFT		Scale1, 1
Scale2		invalue		"scale2"
giScale2	StrNumsRToFT		Scale2, 2
Scale3		invalue		"scale3"
giScale3	StrNumsRToFT		Scale3, 3
Scale4		invalue		"scale4"
giScale4	StrNumsRToFT		Scale4, 4
Scale5		invalue		"scale5"
giScale5	StrNumsRToFT		Scale5, 5
Scale6		invalue		"scale6"
giScale6	StrNumsRToFT		Scale6, 6
Scale7		invalue		"scale7"
giScale7	StrNumsRToFT		Scale7, 7
Scale8		invalue		"scale8"
giScale8	StrNumsRToFT		Scale8, 8
Scale9		invalue		"scale9"
giScale9	StrNumsRToFT		Scale9, 9
Scale10	invalue		"scale10"
giScale10	StrNumsRToFT		Scale10, 10
Scale11	invalue		"scale11"
giScale11	StrNumsRToFT		Scale11, 11
Scale12	invalue		"scale12"
giScale12	StrNumsRToFT		Scale12, 12
Scale13	invalue		"scale13"
giScale13	StrNumsRToFT		Scale13, 13
Scale14	invalue		"scale14"
giScale14	StrNumsRToFT		Scale14, 14
Scale15	invalue		"scale15"
giScale15	StrNumsRToFT		Scale15, 15
Scale16	invalue		"scale16"
giScale16	StrNumsRToFT		Scale16, 16
Scale17	invalue		"scale17"
giScale17	StrNumsRToFT		Scale17, 17
Scale18	invalue		"scale18"
giScale18	StrNumsRToFT		Scale18, 18
Scale19	invalue		"scale19"
giScale19	StrNumsRToFT		Scale19, 19
Scale20	invalue		"scale20"
giScale20	StrNumsRToFT		Scale20, 20
Scale21	invalue		"scale21"
giScale21	StrNumsRToFT		Scale21, 21
Scale22	invalue		"scale22"
giScale22	StrNumsRToFT		Scale22, 22
Scale23	invalue		"scale23"
giScale23	StrNumsRToFT		Scale23, 23
Scale24	invalue		"scale24"
giScale24	StrNumsRToFT		Scale24, 24
Scale25	invalue		"scale25"
giScale25	StrNumsRToFT		Scale25, 25
Scale26	invalue		"scale26"
giScale26	StrNumsRToFT		Scale26, 26
Scale27	invalue		"scale27"
giScale27	StrNumsRToFT		Scale27, 27
Scale28	invalue		"scale28"
giScale28	StrNumsRToFT		Scale28, 28
Scale29	invalue		"scale29"
giScale29	StrNumsRToFT		Scale29, 29
Scale30	invalue		"scale30"
giScale30	StrNumsRToFT		Scale30, 30
endin


instr 2; select scales by midi
;;GIVE GENERAL INFORMATION ABOUT KEY PRESSED
kstatus, kchanin, kdata1, kdata2  midiin 
if kstatus == 128 then
Status		sprintfk	"%s", "Note Off"
elseif kstatus == 144 then
Status		sprintfk	"%s", "Note On"
elseif kstatus == 160 then
Status		sprintfk	"%s", "Poly Aftertouch"
elseif kstatus == 176 then
Status		sprintfk	"%s", "Control Change"
elseif kstatus == 192 then
Status		sprintfk	"%s", "Program Change"
elseif kstatus == 208 then 
Status 	sprintfk	"%s", "Channel Aftertouch"
elseif kstatus == 224 then
Status		sprintfk	"%s", "Pitch Bend"
endif
if kstatus > 0 then
Smidi_event	sprintfk	"%s\nChannel = %d\nData1 = %d\nData2 = %d", Status, kchanin, kdata1, kdata2
else
Smidi_event	=		""
endif
		outvalue	"midi_event", Smidi_event

;;SELECT SCALES BY MIDI IF DESIRED KEY IS PRESSED
kgm1_scale	invalue	"gm1_scale"
kgm1_key	invalue	"gm1_key"
kgm1_chn	invalue	"gm1_chn"
kgm2_scale	invalue	"gm2_scale"
kgm2_key	invalue	"gm2_key"
kgm2_chn	invalue	"gm2_chn"
kgm3_scale	invalue	"gm3_scale"
kgm3_key	invalue	"gm3_key"
kgm3_chn	invalue	"gm3_chn"
kgm4_scale	invalue	"gm4_scale"
kgm4_key	invalue	"gm4_key"
kgm4_chn	invalue	"gm4_chn"
kgm5_scale	invalue	"gm5_scale"
kgm5_key	invalue	"gm5_key"
kgm5_chn	invalue	"gm5_chn"
kgm6_scale	invalue	"gm6_scale"
kgm6_key	invalue	"gm6_key"
kgm6_chn	invalue	"gm6_chn"
kgm7_scale	invalue	"gm7_scale"
kgm7_key	invalue	"gm7_key"
kgm7_chn	invalue	"gm7_chn"
kgm8_scale	invalue	"gm8_scale"
kgm8_key	invalue	"gm8_key"
kgm8_chn	invalue	"gm8_chn"
kchan, key, k0 MidiNoteIn; get midi channel and key number from the current note-on event
if key == -1 kgoto end; don't do anything if no note-on received
if kchan == kgm1_chn && key == kgm1_key then
kscale		=		kgm1_scale
kchange	=		1
elseif kchan == kgm2_chn && key == kgm2_key then
kscale		=		kgm2_scale
kchange	=		1
elseif kchan == kgm3_chn && key == kgm3_key then
kscale		=		kgm3_scale
kchange	=		1
elseif kchan == kgm4_chn && key == kgm4_key then
kscale		=		kgm4_scale
kchange	=		1
elseif kchan == kgm5_chn && key == kgm5_key then
kscale		=		kgm5_scale
kchange	=		1
elseif kchan == kgm6_chn && key == kgm6_key then
kscale		=		kgm6_scale
kchange	=		1
elseif kchan == kgm7_chn && key == kgm7_key then
kscale		=		kgm7_scale
kchange	=		1
elseif kchan == kgm8_chn && key == kgm8_key then
kscale		=		kgm8_scale
kchange	=		1
else; if key pressed but not one of the defined
kchange	=		0
endif
if kchange == 1 then; if one of the defined keys has been pressed
gkscale	= kscale+1; set gkscale to the new value
endif
end:
endin

instr 3; set general values by widgets and select scale by menu
;;GENERAL VALUES
gkreftone	invalue	"reftone"; any midi note number
gktunfreq	invalue	"tunfreq"; any frequency for it
gksound	invalue	"sound"; select sound by menu
;;SELECT SCALE BY MENU IF CHANGED
kscale1	invalue	"equal_tmprd"
kscale2	invalue	"various"
kscale3	invalue	"bohlen-pierce"
kscactive1	changed	kscale1
kscactive2	changed	kscale2
kscactive3	changed	kscale3
gkscale	=		(kscactive1==1 ? kscale1+1 : (kscactive2==1 ? kscale2+11 : (kscactive3==1 ? kscale3+21 : gkscale))); set gkscale to new menu value if changed
		outvalue	"scsel1", (gkscale < 11 ? 1 : 0)
		outvalue	"scsel2", (gkscale > 10 && gkscale < 21 ? 1 : 0)
		outvalue	"scsel3", (gkscale > 20 ? 1 : 0)
endin

instr 4; show scale info and set menu if changed by MIDI (instr 2)
 ;EQUAL TEMPERED
 if gkscale == 1 then	;halftone
Sinfo		sprintfk	"1 Halftone\n12 steps per octave with a ratio of 12th root of 2 = %f...", 2^(1/12)
		outvalue	"equal_tmprd", 0
 elseif gkscale == 2 then	;thirdtone
Sinfo		sprintfk	"2 Thirdtone\n18 steps per octave with a ratio of 18th root of 2 = %f...", 2^(1/18)
		outvalue	"equal_tmprd", 1
 elseif gkscale == 3 then	;quartertone
Sinfo		sprintfk	"3 Quartertone\n24 steps per octave with a ratio of 24th root of 2 = %f...", 2^(1/24)
		outvalue	"equal_tmprd", 2
 elseif gkscale == 4 then	;fifthtone
Sinfo		sprintfk	"4 Fifthtone\n30 steps per octave with a ratio of 30th root of 2 = %f...", 2^(1/30)
		outvalue	"equal_tmprd", 3
 elseif gkscale == 5 then	;sixthtone
Sinfo		sprintfk	"5 Sixthtone\n36 steps per octave with a ratio of 36th root of 2 = %f...", 2^(1/36)
		outvalue	"equal_tmprd", 4
 elseif gkscale == 6 then	;eighttone
Sinfo		sprintfk	"6 Eighttone\n48 steps per octave with a ratio of 48th root of 2 = %f...", 2^(1/48)
		outvalue	"equal_tmprd", 5
 elseif gkscale == 7 then	;twelfsttone
Sinfo		sprintfk	"7 Twelfsttone\n72 steps per octave with a ratio of 72th root of 2 = %f...", 2^(1/72)
		outvalue	"equal_tmprd", 6
 elseif gkscale == 8 then	;sixteenthtone
Sinfo		sprintfk	"8 Sixteenthtone\n96 steps per octave with a ratio of 96th root of 2 = %f...", 2^(1/96)
		outvalue	"equal_tmprd", 7
 elseif gkscale == 9 then	;stockhausen scale in "studie ii"
Sinfo		sprintfk	"9 Stockhausen Scale in 'Studie II'\n25 steps per 1:5 with a ratio of 25th root of 5 = %f...", 5^(1/25)
		outvalue	"equal_tmprd", 8
 elseif gkscale == 10 then	;user defined
Sinfo		sprintfk	"%s", "10 User defined\nYou can add your own description in the code at instr 4"
		outvalue	"equal_tmprd", 9
 ;VARIOUS TEMPERED
 elseif gkscale == 11 then		;pythagorean
Sinfo		sprintfk	"%s", "11 Pythagorean chromatic scale (14th century) with ratios\n1, 2187/2048, 9/8, 32/27, 81/64, 4/3, 729/512, 3/2, 6561/4096, 27/16, 16/9, 243/128\n(after Klaus Lang, Auf Wohlklangswellen durch der Toene Meer, Graz 1999, BEM 10, p. 41)"
		outvalue	"various", 0
 elseif gkscale == 12 then	;zarlino / meantone
Sinfo		sprintfk	"%s", "12 Meantone temperature after Zarlino 1571 with cent values\n0, 76, 193, 310, 386, 503, 579, 697, 773, 890, 1007, 1083\n(after Klaus Lang, Auf Wohlklangswellen durch der Toene Meer, Graz 1999, BEM 10, p. 68)"
		outvalue	"various", 1
 elseif gkscale == 13 then	;werckmeister III
Sinfo		sprintfk	"%s", "13 Werckmeister III temperature (1691) with cent values\n0, 90, 192, 294, 390, 498, 588, 696, 792, 888, 996, 1092\n(after Klaus Lang, Auf Wohlklangswellen durch der Toene Meer, Graz 1999, BEM 10, p. 97)"
		outvalue	"various", 2
 elseif gkscale == 14 then	;kirnberger II
Sinfo		sprintfk	"%s", "14 Kirnberger II temperature (1771) with cent values\n0, 90, 204, 294, 386, 498, 590, 702, 792, 895, 996, 1088\n(after Klaus Lang, Auf Wohlklangswellen durch der Toene Meer, Graz 1999, BEM 10, p. 100)"
		outvalue	"various", 3
 elseif gkscale == 15 then	;sruti I
Sinfo		sprintfk	"%s", "15 Sruti I:\n22 steps per octave in indian classical music with cent values \n0, 90, 112, 182, 204, 294, 316, 386, 408, 498, 520, 590, 610, 702, 792, 814, 884, 906, 996, 1018, 1088, 1110\n(after P. Sambamoorthy, South Indian, Music, Book IV, Second Edition, Madras 1954, pp 95-97)"
		outvalue	"various", 4
 elseif gkscale == 16 then	;sruti II
Sinfo		sprintfk	"%s", "16 Sruti II:\n22 steps per octave in indian clssical music with cent values\n0, 68.6, 135.3, 200.21, 263.46, 325.13, 385.33, 444.13, 501.62, 557.85, 612.91, 666.85, 719.73, 771.6, 822.5, 872.48, 921.59, 969.86, 1017.33, 1064.04, 1110.01, 1155.28\n(after Narsing R. Eswara, Tonal Foundations of Indian Music, 2007, Appendix A.4)"
		outvalue	"various", 5
 elseif gkscale == 17 then	;user defined
Sinfo		sprintfk	"%s", "17 User defined\nYou can add your own description in the code at instr 4"
		outvalue	"various", 6
 elseif gkscale == 18 then	;user defined
Sinfo		sprintfk	"%s", "18 User defined\nYou can add your own description in the code at instr 4"
		outvalue	"various", 7
 elseif gkscale == 19 then	;user defined
Sinfo		sprintfk	"%s", "19 User defined\nYou can add your own description in the code at instr 4"
		outvalue	"various", 8
 elseif gkscale == 20 then	;user defined
Sinfo		sprintfk	"%s", "20 User defined\nYou can add your own description in the code at instr 4"
		outvalue	"various", 9
 ;BOHLEN-PIERCE
 elseif gkscale == 21 then	;equal tempered (13 steps)
Sinfo		sprintfk	"21 Bohlen-Pierce Equal Tempered:\n13 steps per 3:1 (duodecima) with a ratio of 13th root of 3 = %f...", 3^(1/13)
		outvalue	"bohlen-pierce", 0
 elseif gkscale == 22 then	;ratios (13 steps)
Sinfo		sprintfk	"%s", "22 Bohlen-Pierce Ratios:\n13 steps per 3:1 (duodecima) with ratios 1, 27/25, 25/21, 9/7, 7/5, 75/49, 5/3, 9/5, 49/25, 15/7, 7/3, 63/25, 25/9"
		outvalue	"bohlen-pierce", 1
 elseif gkscale == 23 then	;Dur I (9 steps)
Sinfo		sprintfk	"%s", "23 Bohlen-Pierce Dur I Mode:\n9 steps per 3:1 (duodecima) with ratios 1, 27/25, 9/7, 7/5, 5/3, 9/5, 49/25, 7/3, 63/25"
		outvalue	"bohlen-pierce", 2
 elseif gkscale == 24 then	;Dur II (9 steps)
Sinfo		sprintfk	"%s", "24 Bohlen-Pierce Dur II Mode:\n9 steps per 3:1 (duodecima) with ratios 1, 25/21, 9/7, 7/5, 5/3, 9/5, 15/7, 7/3, 63/25"
		outvalue	"bohlen-pierce", 3
 elseif gkscale == 25 then	;Moll I (9 steps)
Sinfo		sprintfk	"%s", "25 Bohlen-Pierce Moll I Mode (Delta):\n9 steps per 3:1 (duodecima) with ratios 1, 25/21, 9/7, 75/49, 5/3, 9/5, 15/7, 7/3, 25/9"
		outvalue	"bohlen-pierce", 4
 elseif gkscale == 26 then	;Moll II (9 steps)
Sinfo		sprintfk	"%s", "26 Bohlen-Pierce Moll II Mode (Pierce):\n9 steps per 3:1 (duodecima) with ratios 1, 27/25, 9/7, 7/5, 5/3, 9/5, 15/7, 7/3, 25/9"
		outvalue	"bohlen-pierce", 5
 elseif gkscale == 27 then	;Gamma (9 steps)
Sinfo		sprintfk	"%s", "27 Bohlen-Pierce Gamma Mode:\n9 steps per 3:1 (duodecima) with ratios 1, 27/25, 9/7, 7/5, 5/3, 9/5, 49/25, 7/3, 25/9"
		outvalue	"bohlen-pierce", 6
 elseif gkscale == 28 then	;Harmonic (9 steps)
Sinfo		sprintfk	"%s", "28 Bohlen-Pierce Harmonic Mode:\n9 steps per 3:1 (duodecima) with ratios 1, 27/25, 9/7, 7/5, 5/3, 9/5, 15/7, 7/3, 63/25"
		outvalue	"bohlen-pierce", 7
 elseif gkscale == 29 then	;Lambda (9 steps)
Sinfo		sprintfk	"%s", "29 Bohlen-Pierce Lambda Mode:\n9 steps per 3:1 (duodecima) with ratios 1, 25/21, 9/7, 7/5, 5/3, 9/5, 15/7, 7/3, 25/9"
		outvalue	"bohlen-pierce", 8
 elseif gkscale == 30 then	;user defined
Sinfo		sprintfk	"%s", "30 User defined\nYou can add your own description in the code at instr 4"
		outvalue	"bohlen-pierce", 9
 endif
		outvalue	"info", Sinfo
endin

instr 10; playing one note
;;INPUT
ikey		=		p4
ivel		=		p5
ireftone	=		i(gkreftone)
itunfreq	=		i(gktunfreq)
iscale		=		i(gkscale); 1-30
istep		=		ikey - ireftone; how many steps (keys) higher or lower than the reftone
ifreq		FreqByECRTab	iscale, itunfreq, istep; calculation of the frequency
;;SELECT OUTPUT SOUND
if gksound == 0 then; sine
anote		oscil3		ivel, ifreq, giSine
elseif gksound == 1 then; saw
;anote		vco2		ivel, ifreq, 10
anote		oscil3		ivel, ifreq, giSaw
elseif gksound == 2 then; square
anote		oscil3		ivel, ifreq, giSquare
elseif gksound == 3 then; square vco2
anote		vco2		ivel, ifreq, 10
elseif gksound == 4 then; waveguide clarinet
 kstiff = -0.3
  iatt = 0.1
  idetk = 0.1
  kngain = 0.2
  kvibf = 5.735
  kvamp = 0.01
  anote wgclar ivel, ifreq, kstiff, iatt, idetk, kngain, kvibf, kvamp, giSine
elseif gksound == 5 then; pluck
anote		pluck		ivel, ifreq, ifreq, 0, 1
endif
aenv		linsegr	0, .1, 1, p3-0.1, 1, .1, 0
aout		=		anote * aenv; calculate sound
gadryL		init		0
gadryR		init		0
gadryL		=		gadryL + aout; add to global audio signal
gadryR		=		gadryR + aout	
;;SHOW OUTPUT
Skey		sprintf	"%d", ikey
		outvalue	"key", Skey; key pressed
icent		=		(log(ifreq / i(gktunfreq)) * 1200) / log(2)
Scent		sprintf	"%.1f", icent
		outvalue	"cent", Scent; cent difference in relation to the reference frequency
		outvalue	"freq", ifreq
inormfreq	=		cpsmidinn(p4); usual freq of the pressed key
		outvalue	"normfreq", inormfreq
icentdiff	=		1200 * (log(ifreq/inormfreq) / log(2)); centdifference ifreq to inormfreq
Scentdiff	sprintf	"%.1f", icentdiff
		outvalue	"centdiff", Scentdiff
endin


instr 100; global reverb and display
;;GUI INPUT
kwdmix		invalue	"wdmix";(between 0=dry und 1=reverberating)
kroomsize	invalue	"roomsize"; 0-1 (for freeverb)
khfdamp	invalue	"hfdamp"; attenuation of high frequencies (0-1) (for freeverb)
;;REVERB AND AUDIO OUTPUT
awetL, awetR	freeverb	gadryL, gadryR, kroomsize, khfdamp
aoutL		=		(1-kwdmix) * gadryL + (kwdmix * awetL)
aoutR		=		(1-kwdmix) * gadryR + (kwdmix * awetR)
		outs		aoutL, aoutR
;; send to GUI
kTrigDisp	metro		10
		ShowLED_a	"outL", aoutL, kTrigDisp, 1, 50
		ShowLED_a	"outR", aoutR, kTrigDisp, 1, 50
		ShowOver_a	"outLover", aoutL/0dbfs, kTrigDisp, 1
		ShowOver_a	"outRover", aoutR/0dbfs, kTrigDisp, 1
;; reset global audio
gadryL		=		0	
gadryR		=		0
endin

</CsInstruments>
<CsScore>
e 36000
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>25</y>
 <width>1280</width>
 <height>750</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background" >
  <r>169</r>
  <g>171</g>
  <b>128</b>
 </bgcolor>
 <bsbObject version="2" type="BSBDisplay" >
  <objectName>key</objectName>
  <x>806</x>
  <y>595</y>
  <width>62</width>
  <height>27</height>
  <uuid>{5e6414e6-b884-4d95-8f6d-fe0fa8a4ae85}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>56</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>349</x>
  <y>595</y>
  <width>457</width>
  <height>28</height>
  <uuid>{764ad5f0-aea6-4e5a-978e-544bbfe6cf8f}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>-1684371923</x>
  <y>-1632653318</y>
  <width>227</width>
  <height>25</height>
  <uuid>{8bd25f52-af70-4c62-a08a-d5268a79364a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Cent Deviation</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay" >
  <objectName>cent</objectName>
  <x>807</x>
  <y>623</y>
  <width>82</width>
  <height>27</height>
  <uuid>{71f76305-3674-4be2-81c0-84d68dbd4c2b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-585.2</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>267</x>
  <y>623</y>
  <width>539</width>
  <height>27</height>
  <uuid>{f742c31a-6b42-4ab7-afc2-28160bc8055f}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay" >
  <objectName>freq</objectName>
  <x>807</x>
  <y>649</y>
  <width>82</width>
  <height>27</height>
  <uuid>{8e0b983f-27e5-488c-bc43-1d5182553f2f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>186.5833</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>266</x>
  <y>649</y>
  <width>542</width>
  <height>29</height>
  <uuid>{f4692440-ef66-4ec7-9334-95ca2ad863eb}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>4</x>
  <y>35</y>
  <width>422</width>
  <height>214</height>
  <uuid>{5c34e084-0047-4892-beb5-ac457a72dc50}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>222</r>
   <g>143</g>
   <b>206</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay" >
  <objectName>cent</objectName>
  <x>-610629723</x>
  <y>-1632653302</y>
  <width>80</width>
  <height>25</height>
  <uuid>{932c6c8c-4309-4ad3-a00e-0b2da3eda272}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-585.2</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>-610629955</x>
  <y>-1632653304</y>
  <width>227</width>
  <height>25</height>
  <uuid>{2a73a077-48a7-4c58-bbb9-24bb13d073a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Cent Deviation</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>sound</objectName>
  <x>201</x>
  <y>215</y>
  <width>165</width>
  <height>25</height>
  <uuid>{9f367f80-6519-4d53-ac68-4da2f34b0054}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
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
    <name>waveguide-clarinet</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>pluck</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>5</selectedIndex>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>43</x>
  <y>211</y>
  <width>160</width>
  <height>31</height>
  <uuid>{826b3a7e-89d2-401e-aafa-5934a939700e}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>742</x>
  <y>57</y>
  <width>131</width>
  <height>24</height>
  <uuid>{20843a64-5c42-408d-8a70-228b5732e44a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>jh &amp;&amp; rb 1/2010</label>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay" >
  <objectName>normfreq</objectName>
  <x>807</x>
  <y>675</y>
  <width>82</width>
  <height>28</height>
  <uuid>{a9f212bf-3c55-4c3f-be16-14305a721761}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>207.6465</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>267</x>
  <y>675</y>
  <width>541</width>
  <height>29</height>
  <uuid>{5ad5843a-2ef2-4aa1-914b-7344ccef816e}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay" >
  <objectName>centdiff</objectName>
  <x>807</x>
  <y>701</y>
  <width>82</width>
  <height>30</height>
  <uuid>{a2f18b1d-ec7d-450f-adb3-2da9033daabe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>-185.2</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>267</x>
  <y>701</y>
  <width>541</width>
  <height>31</height>
  <uuid>{cdfd41ca-df55-4e29-9517-fc2610bb5732}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>scsel1</objectName>
  <x>23</x>
  <y>184</y>
  <width>104</width>
  <height>23</height>
  <uuid>{2b36073e-1a56-4ac1-ab71-5496405c74a8}</uuid>
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
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0" >false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>scsel2</objectName>
  <x>154</x>
  <y>184</y>
  <width>104</width>
  <height>23</height>
  <uuid>{b5b15996-6f58-494d-acf7-9b879ede8ee5}</uuid>
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
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0" >false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>scsel3</objectName>
  <x>285</x>
  <y>184</y>
  <width>104</width>
  <height>23</height>
  <uuid>{3c7eec88-4dae-49ce-affd-88ea6f9adcfb}</uuid>
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
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0" >false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>tunfreq</objectName>
  <x>314</x>
  <y>50</y>
  <width>107</width>
  <height>26</height>
  <uuid>{89faabe5-e0a9-464c-a913-05b7b5a07b33}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>0.00000100</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>261.625</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>206</x>
  <y>44</y>
  <width>108</width>
  <height>28</height>
  <uuid>{0c9ea21e-0613-4a6e-acf2-7e94adb124f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Related Pitch</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>227</x>
  <y>65</y>
  <width>72</width>
  <height>25</height>
  <uuid>{fe651ebc-40b4-4b94-a38c-2c8250436da3}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>equal_tmprd</objectName>
  <x>12</x>
  <y>162</y>
  <width>126</width>
  <height>24</height>
  <uuid>{8d5a88e6-cad0-40f1-98f9-0c7fd66fa9a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Halftones</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Thirdtones</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Quartertones</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Fifthtones</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sixthtones</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Eighttones</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Twelfthtones</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sixteenthtones</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Stockhausen Studie II</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>UserDefined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>10</x>
  <y>93</y>
  <width>393</width>
  <height>30</height>
  <uuid>{82ff91df-8ca6-4b6a-ae88-cab12e04ce98}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>reftone</objectName>
  <x>129</x>
  <y>50</y>
  <width>68</width>
  <height>26</height>
  <uuid>{6c9b0785-1ef2-4db6-a7b5-ec90878ea278}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>60</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>12</x>
  <y>44</y>
  <width>117</width>
  <height>27</height>
  <uuid>{435beed4-c96d-4421-9f2f-ba8acb34c3d2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Reference Key</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>29</x>
  <y>64</y>
  <width>87</width>
  <height>25</height>
  <uuid>{941b7e61-8548-4cf2-8fca-1aad1fdb72c7}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>15</x>
  <y>120</y>
  <width>122</width>
  <height>43</height>
  <uuid>{a77f14df-fbb5-4016-8c99-b9cd640ecdec}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>various</objectName>
  <x>145</x>
  <y>162</y>
  <width>126</width>
  <height>24</height>
  <uuid>{a9ba539d-805e-4719-85d8-36b2b9167836}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Pythagorean</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Zarlino 1/4 Comma</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Werckmeister III</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Kirnberger II</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Indian Sruti I</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Indian Sruti II</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>User Defined</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>User Defined</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>User Defined</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>3</selectedIndex>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>148</x>
  <y>120</y>
  <width>122</width>
  <height>43</height>
  <uuid>{5310ed05-27eb-4572-88f6-b9b7f6d9065e}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>bohlen-pierce</objectName>
  <x>275</x>
  <y>162</y>
  <width>126</width>
  <height>24</height>
  <uuid>{8f48e71f-9e80-4058-be8c-33fb3202dbca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Equal Tempered</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Ratios</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Dur I Mode</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Dur II Mode</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Moll I (Delta) Mode</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Moll II (Pierce) Mode</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Gamma Mode</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Harmonic Mode</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Lambda Mode</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>User Defined</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>5</selectedIndex>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>278</x>
  <y>120</y>
  <width>122</width>
  <height>43</height>
  <uuid>{a60c5a0c-4e3d-46b6-aa66-6f813ed8f679}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay" >
  <objectName>info</objectName>
  <x>273</x>
  <y>487</y>
  <width>639</width>
  <height>103</height>
  <uuid>{e29ba28c-55bd-4918-ae82-d65e28620fe6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>26 Bohlen-Pierce Moll II Mode (Pierce):
9 steps per 3:1 (duodecima) with ratios 1, 27/25, 9/7, 7/5, 5/3, 9/5, 15/7, 7/3, 25/9</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background" >
   <r>237</r>
   <g>169</g>
   <b>107</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Play</objectName>
  <x>471</x>
  <y>55</y>
  <width>91</width>
  <height>27</height>
  <uuid>{3c1f3c79-7a97-4201-870e-b15fba4dce6f}</uuid>
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
 <bsbObject version="2" type="BSBButton" >
  <objectName>_Stop</objectName>
  <x>585</x>
  <y>55</y>
  <width>91</width>
  <height>27</height>
  <uuid>{7d69e549-33e0-4dac-8c60-f8aff8fe5345}</uuid>
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
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>268</x>
  <y>458</y>
  <width>652</width>
  <height>275</height>
  <uuid>{ed1a7e90-a4a7-41dc-b20e-5903a582c9ca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>OUTPUT</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider" >
  <objectName>vol</objectName>
  <x>274</x>
  <y>769</y>
  <width>250</width>
  <height>28</height>
  <uuid>{758e187b-b277-4632-8bcd-54bdbe98f201}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.44400000</value>
  <mode>lin</mode>
  <mouseControl act="jump" >continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>309</x>
  <y>740</y>
  <width>97</width>
  <height>27</height>
  <uuid>{ccd1fc56-dfd8-4c5b-828d-2419feb66ff2}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>outL</objectName>
  <x>539</x>
  <y>745</y>
  <width>336</width>
  <height>22</height>
  <uuid>{1cd59f08-62cf-4745-a069-cad158f75f11}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out1_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.36363600</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0" >false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>outLover</objectName>
  <x>873</x>
  <y>745</y>
  <width>27</width>
  <height>22</height>
  <uuid>{ab2ca391-235a-43ee-8bb3-f3c9802ed3a9}</uuid>
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
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0" >false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>outR</objectName>
  <x>539</x>
  <y>771</y>
  <width>336</width>
  <height>22</height>
  <uuid>{8120d993-bdf5-4108-82dc-2a3463dabbc4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.52631600</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0" >false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController" >
  <objectName>outRover</objectName>
  <x>873</x>
  <y>771</y>
  <width>27</width>
  <height>22</height>
  <uuid>{93e44bc6-7a17-46ed-a298-89baaa2c7190}</uuid>
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
  <mouseControl act="press" >jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0" >false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay" >
  <objectName>vol</objectName>
  <x>404</x>
  <y>740</y>
  <width>98</width>
  <height>27</height>
  <uuid>{ec332e82-4cb5-4fcc-a4c6-3aa73b056149}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.4440</label>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>926</x>
  <y>19</y>
  <width>374</width>
  <height>773</height>
  <uuid>{cec5e239-e6be-4f8e-9c6e-cc0bb8f891a1}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>452</x>
  <y>17</y>
  <width>449</width>
  <height>38</height>
  <uuid>{e3e2fdfa-979e-4bea-bcce-c169fe42c528}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>459</x>
  <y>84</y>
  <width>440</width>
  <height>23</height>
  <uuid>{dfb145ef-6bbb-4432-8f53-75daa7d578b4}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>4</x>
  <y>256</y>
  <width>261</width>
  <height>311</height>
  <uuid>{2a09b1e0-1afb-49a9-be96-ba36884e0948}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>222</r>
   <g>143</g>
   <b>206</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>gm1_scale</objectName>
  <x>10</x>
  <y>323</y>
  <width>108</width>
  <height>25</height>
  <uuid>{867963ae-0b3c-4723-8f64-503f3406747c}</uuid>
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
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm1_key</objectName>
  <x>124</x>
  <y>323</y>
  <width>61</width>
  <height>25</height>
  <uuid>{3c53a9d9-5ada-4968-a0c2-c24477f29868}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>36</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm1_chn</objectName>
  <x>188</x>
  <y>323</y>
  <width>61</width>
  <height>25</height>
  <uuid>{3ed411fb-cf2d-46b6-b1d0-4ccfdcccec88}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>18</x>
  <y>293</y>
  <width>83</width>
  <height>27</height>
  <uuid>{54b04f4a-e308-4763-98f7-cac628f1ba27}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>125</x>
  <y>293</y>
  <width>50</width>
  <height>27</height>
  <uuid>{c0aa3d19-b53c-4d4e-8abb-1c1bdd7317c5}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>181</x>
  <y>293</y>
  <width>73</width>
  <height>27</height>
  <uuid>{e8f1fd58-2f12-4c02-98d5-966bb70cc17e}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>gm2_scale</objectName>
  <x>10</x>
  <y>354</y>
  <width>108</width>
  <height>25</height>
  <uuid>{7fb7cb10-cad4-4106-af3c-95af323543f8}</uuid>
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
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm2_key</objectName>
  <x>124</x>
  <y>354</y>
  <width>61</width>
  <height>25</height>
  <uuid>{aade1ce8-c245-4b84-9808-fd5d020bf8c2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>37</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm2_chn</objectName>
  <x>188</x>
  <y>354</y>
  <width>61</width>
  <height>25</height>
  <uuid>{abdb9ba3-0524-4456-b686-9e159a5edac5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>gm3_scale</objectName>
  <x>10</x>
  <y>382</y>
  <width>108</width>
  <height>25</height>
  <uuid>{882d149f-2bae-4648-8b2f-c7c4a6b1b725}</uuid>
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
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm3_key</objectName>
  <x>124</x>
  <y>382</y>
  <width>61</width>
  <height>25</height>
  <uuid>{30e79057-7519-459e-b3b2-d3d19031122d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>38</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm3_chn</objectName>
  <x>188</x>
  <y>382</y>
  <width>61</width>
  <height>25</height>
  <uuid>{2ada44e2-e619-4883-a7ec-c142ffbd42b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>gm4_scale</objectName>
  <x>10</x>
  <y>413</y>
  <width>108</width>
  <height>25</height>
  <uuid>{36909472-1b5f-4efd-bbed-42e553ef5a89}</uuid>
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
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm4_key</objectName>
  <x>124</x>
  <y>413</y>
  <width>61</width>
  <height>25</height>
  <uuid>{788417d6-7415-4a9a-a1ea-ccf62af90658}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>40</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm4_chn</objectName>
  <x>188</x>
  <y>413</y>
  <width>61</width>
  <height>25</height>
  <uuid>{a0de88f8-f863-46d9-a456-9d4cdfd8df11}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>gm5_scale</objectName>
  <x>10</x>
  <y>441</y>
  <width>108</width>
  <height>25</height>
  <uuid>{133be560-63ed-40e9-adc5-aa7b06282d56}</uuid>
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
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm5_key</objectName>
  <x>124</x>
  <y>441</y>
  <width>61</width>
  <height>25</height>
  <uuid>{8f5c50af-1452-4f98-820e-a780f13ef759}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>41</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm5_chn</objectName>
  <x>188</x>
  <y>441</y>
  <width>61</width>
  <height>25</height>
  <uuid>{d8961f25-2faf-4b99-822b-21e82e0f19d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>gm6_scale</objectName>
  <x>10</x>
  <y>472</y>
  <width>108</width>
  <height>25</height>
  <uuid>{de07cc1b-731a-4765-aa40-47f606560251}</uuid>
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
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm6_key</objectName>
  <x>124</x>
  <y>472</y>
  <width>61</width>
  <height>25</height>
  <uuid>{e28a1c8a-5928-471d-92b1-184fff6e19c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>43</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm6_chn</objectName>
  <x>188</x>
  <y>472</y>
  <width>61</width>
  <height>25</height>
  <uuid>{a4a1e982-1067-48ab-b10f-489e5b6e5d42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>gm7_scale</objectName>
  <x>10</x>
  <y>500</y>
  <width>108</width>
  <height>25</height>
  <uuid>{86c24ab3-71e5-4bb4-9508-5d3f970f7888}</uuid>
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
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm7_key</objectName>
  <x>124</x>
  <y>500</y>
  <width>61</width>
  <height>25</height>
  <uuid>{370e80e8-ffa7-49ac-ac9b-7665edc32f55}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>45</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm7_chn</objectName>
  <x>188</x>
  <y>500</y>
  <width>61</width>
  <height>25</height>
  <uuid>{573c0887-f332-4db7-bfd0-acc3d3ac9955}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown" >
  <objectName>gm8_scale</objectName>
  <x>10</x>
  <y>531</y>
  <width>108</width>
  <height>25</height>
  <uuid>{24f48013-3406-4cba-b106-93347a9edb8c}</uuid>
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
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm8_key</objectName>
  <x>124</x>
  <y>531</y>
  <width>61</width>
  <height>25</height>
  <uuid>{21a7beaa-621e-4d7c-84ad-d9624f12ae3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>47</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox" >
  <objectName>gm8_chn</objectName>
  <x>188</x>
  <y>531</y>
  <width>61</width>
  <height>25</height>
  <uuid>{ba4dc687-bc71-403c-947b-90707d3dae48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0" >false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay" >
  <objectName>midi_event</objectName>
  <x>276</x>
  <y>299</y>
  <width>137</width>
  <height>71</height>
  <uuid>{6fd8cf81-4774-4731-9a41-c81f690310a8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>center</alignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>276</x>
  <y>276</y>
  <width>137</width>
  <height>25</height>
  <uuid>{fed7398a-9f96-4e59-aa18-257a35ec0fc4}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>9</x>
  <y>263</y>
  <width>252</width>
  <height>31</height>
  <uuid>{87959b31-23c2-4341-b534-30793e4335e4}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>431</x>
  <y>108</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b650b820-d7e1-4d70-8804-2aae9eed2396}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>431</x>
  <y>131</y>
  <width>492</width>
  <height>65</height>
  <uuid>{ead78b9f-7756-4601-8c25-0ceaaa903e95}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>431</x>
  <y>195</y>
  <width>257</width>
  <height>26</height>
  <uuid>{60bd2f0f-6b7f-4fed-8467-7b65748068b2}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>431</x>
  <y>220</y>
  <width>495</width>
  <height>136</height>
  <uuid>{d74afc6f-ca3a-4fc2-92bf-f9684bba873c}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>431</x>
  <y>354</y>
  <width>101</width>
  <height>24</height>
  <uuid>{b9a278db-605e-43f5-b25c-b87436eb16e8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>WARNING</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>431</x>
  <y>377</y>
  <width>501</width>
  <height>25</height>
  <uuid>{c6bf5b08-a03e-4cc0-bc9c-d9e87d7a67b7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Scales must have EXACTLY ONE space between the values and NO space at the beginning or the end.</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale1</objectName>
  <x>1071</x>
  <y>50</y>
  <width>220</width>
  <height>24</height>
  <uuid>{391981ca-b82a-43f9-a70c-e32c21707362}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 12</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>50</y>
  <width>138</width>
  <height>24</height>
  <uuid>{6f17068e-80ee-4551-816a-7fd85e9b2fbf}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale2</objectName>
  <x>1071</x>
  <y>75</y>
  <width>220</width>
  <height>24</height>
  <uuid>{12ce2be0-7c51-4636-b89d-c05a3059eda8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 18</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>75</y>
  <width>138</width>
  <height>24</height>
  <uuid>{c20763e6-ef97-4dd6-94c4-b1a2cbda1ce9}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale3</objectName>
  <x>1071</x>
  <y>99</y>
  <width>220</width>
  <height>24</height>
  <uuid>{368f56e2-b1ff-4d12-ba32-19c721e4be1e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 24</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>99</y>
  <width>138</width>
  <height>24</height>
  <uuid>{6d88d5b4-6745-468d-ab5a-6a2e600297a6}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale4</objectName>
  <x>1071</x>
  <y>124</y>
  <width>220</width>
  <height>24</height>
  <uuid>{502ee456-5221-46c0-83e9-c7b6715a3d83}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 30</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>124</y>
  <width>138</width>
  <height>24</height>
  <uuid>{5b46c05f-72c6-4bcc-bbc3-35de7bd3e0c4}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale5</objectName>
  <x>1071</x>
  <y>148</y>
  <width>220</width>
  <height>24</height>
  <uuid>{4771c781-6964-4dac-a7ed-8a6a5ef9a8f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 36</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>148</y>
  <width>138</width>
  <height>24</height>
  <uuid>{311f8a0b-94a7-45e6-b8a8-13913813586d}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale6</objectName>
  <x>1071</x>
  <y>173</y>
  <width>220</width>
  <height>24</height>
  <uuid>{c04fd167-fc36-480e-bb60-331fe3096de1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 48</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>173</y>
  <width>138</width>
  <height>24</height>
  <uuid>{d0e4969d-5735-4929-99b1-d6a1758635a5}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale7</objectName>
  <x>1071</x>
  <y>197</y>
  <width>220</width>
  <height>24</height>
  <uuid>{9a73f4ce-0ac4-483b-9568-a58dbfcccfa5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 72</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>197</y>
  <width>138</width>
  <height>24</height>
  <uuid>{d86a47b9-347d-45dd-917c-24e7cfeddccd}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale8</objectName>
  <x>1071</x>
  <y>222</y>
  <width>220</width>
  <height>24</height>
  <uuid>{71bc0e3a-98f9-4c8e-8926-a86a6e8e026e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 96</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>222</y>
  <width>138</width>
  <height>24</height>
  <uuid>{a16800c6-b64c-4855-95b5-f533a20d9da4}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale9</objectName>
  <x>1071</x>
  <y>245</y>
  <width>220</width>
  <height>24</height>
  <uuid>{9df907f0-ae84-4f42-acb8-f5e62d8791c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>5 25</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>245</y>
  <width>138</width>
  <height>24</height>
  <uuid>{41c82ae8-5e2e-48e1-9cf7-15d70caebf42}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale10</objectName>
  <x>1071</x>
  <y>270</y>
  <width>220</width>
  <height>24</height>
  <uuid>{32feb9f6-4ed2-46cb-9353-8b2ff9fea313}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 12</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>270</y>
  <width>138</width>
  <height>24</height>
  <uuid>{0b582503-b172-4be9-99e8-439bea92891d}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale11</objectName>
  <x>1071</x>
  <y>294</y>
  <width>220</width>
  <height>24</height>
  <uuid>{80841211-790e-4557-930b-09ed8f3d8c9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 1 2187/2048 9/8 32/27 81/64 4/3 729/512 3/2 6561/4096 27/16 16/9 243/128</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>294</y>
  <width>138</width>
  <height>24</height>
  <uuid>{0bd857be-3523-4193-8232-51c7d87b6a86}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale12</objectName>
  <x>1071</x>
  <y>319</y>
  <width>220</width>
  <height>24</height>
  <uuid>{9272f3c5-3427-4931-8209-52446c82a7fc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 0 76 193 310 386 503 579 697 773 890 1007 1083</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>319</y>
  <width>138</width>
  <height>24</height>
  <uuid>{0d2c1d7c-6e0f-465d-8b71-129e332c9daa}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale13</objectName>
  <x>1071</x>
  <y>343</y>
  <width>220</width>
  <height>24</height>
  <uuid>{30983c57-86ca-4cdd-b472-4cd6ce103eb2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 0 90 192 294 390 498 588 696 792 888 996 1092</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>343</y>
  <width>138</width>
  <height>24</height>
  <uuid>{9509e664-d8c3-4272-ab4c-6f5e1a736793}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale14</objectName>
  <x>1071</x>
  <y>368</y>
  <width>220</width>
  <height>24</height>
  <uuid>{5eb3dacd-7363-467c-be6a-a13fb0379313}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 0 90 204 294 386 498 590 702 792 895 996 1088</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>368</y>
  <width>138</width>
  <height>24</height>
  <uuid>{656b0c59-018c-4a29-9568-124368032a26}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale15</objectName>
  <x>1071</x>
  <y>392</y>
  <width>220</width>
  <height>24</height>
  <uuid>{5ca8abec-f81f-4868-b514-4d19d1291554}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 0 90 112 182 204 294 316 386 408 498 520 590 610 702 792 814 884 906 996 1018 1088 1110</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>392</y>
  <width>138</width>
  <height>24</height>
  <uuid>{fbebff02-6877-4de0-bf6c-d982baaf2024}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale16</objectName>
  <x>1071</x>
  <y>417</y>
  <width>220</width>
  <height>24</height>
  <uuid>{264c9237-22eb-40f9-af98-fef7ad39fd02}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 0 68.6 135.3 200.21 263.46 325.13 385.33 444.13 501.62 557.85 612.91 666.85 719.73 771.6 822.5 872.48 921.59 969.86 1017.33 1064.04 1110.01 1155.28</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>417</y>
  <width>138</width>
  <height>24</height>
  <uuid>{928c17c3-9550-49d4-9df6-94506e32c2aa}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale17</objectName>
  <x>1071</x>
  <y>440</y>
  <width>220</width>
  <height>24</height>
  <uuid>{734875f6-ed75-4a7d-bf15-78ec80a59f8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 12</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>440</y>
  <width>138</width>
  <height>24</height>
  <uuid>{9efdbdc0-07a6-467c-a6ae-185ba1514033}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale18</objectName>
  <x>1071</x>
  <y>465</y>
  <width>220</width>
  <height>24</height>
  <uuid>{b798352c-6529-4b33-bcaf-be0349af4b35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 12</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>465</y>
  <width>138</width>
  <height>24</height>
  <uuid>{d30655e0-46c4-47e8-8d37-3bcd2fd7f792}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale19</objectName>
  <x>1071</x>
  <y>489</y>
  <width>220</width>
  <height>24</height>
  <uuid>{a2fabf9e-8b35-4580-bb8c-6a46c49c5b23}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 12</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>489</y>
  <width>138</width>
  <height>24</height>
  <uuid>{1c9e42c6-d1b8-4e95-8731-b64db680207b}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale20</objectName>
  <x>1071</x>
  <y>514</y>
  <width>220</width>
  <height>24</height>
  <uuid>{2121ead2-6085-47a7-8fd3-66b96eb70455}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2 12</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>514</y>
  <width>138</width>
  <height>24</height>
  <uuid>{a570e8d8-334f-46dc-8b48-76ff93173d79}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale21</objectName>
  <x>1071</x>
  <y>538</y>
  <width>220</width>
  <height>24</height>
  <uuid>{da12a60c-e9c6-4c04-8fa2-81dd8538b7a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 13</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>538</y>
  <width>138</width>
  <height>24</height>
  <uuid>{537cae3c-ea16-48ed-8c18-2b81e2586bf6}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale22</objectName>
  <x>1071</x>
  <y>563</y>
  <width>220</width>
  <height>24</height>
  <uuid>{b184ce52-3366-48e1-8f1f-9caf0469be4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 27/25 25/21 9/7 7/5 75/49 5/3 9/5 49/25 15/7 7/3 63/25 25/9</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>563</y>
  <width>138</width>
  <height>24</height>
  <uuid>{4852f6d5-785a-4928-804e-b76d810d0438}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale23</objectName>
  <x>1071</x>
  <y>586</y>
  <width>220</width>
  <height>24</height>
  <uuid>{47534a68-3191-409f-a470-6aa8aa9140dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 27/25 9/7 7/5 5/3 9/5 49/25 7/3 63/25</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>586</y>
  <width>138</width>
  <height>24</height>
  <uuid>{61e8204a-6c27-47d4-9c86-f05b0cfa6a5f}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale24</objectName>
  <x>1071</x>
  <y>611</y>
  <width>220</width>
  <height>24</height>
  <uuid>{f73bfed4-f034-415c-a4b7-b3bcf2f2de46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 25/21 9/7 7/5 5/3 9/5 15/7 7/3 63/25</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>611</y>
  <width>138</width>
  <height>24</height>
  <uuid>{3a0395fe-434c-4155-9466-af5ee1dede69}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale25</objectName>
  <x>1071</x>
  <y>635</y>
  <width>220</width>
  <height>24</height>
  <uuid>{d90fcdda-7afd-4593-a219-72dd1bcd9554}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 25/21 9/7 75/49 5/3 9/5 15/7 7/3 25/9</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>635</y>
  <width>138</width>
  <height>24</height>
  <uuid>{a68fb918-7f54-4de9-9e90-9f041d80b930}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale26</objectName>
  <x>1071</x>
  <y>660</y>
  <width>220</width>
  <height>24</height>
  <uuid>{c0a29f80-cd58-4396-b5bb-52f72168dc2d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 27/25 9/7 7/5 5/3 9/5 15/7 7/3 25/9</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>660</y>
  <width>138</width>
  <height>24</height>
  <uuid>{3939f07b-a18d-41da-afae-afd89ca94f69}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale27</objectName>
  <x>1071</x>
  <y>684</y>
  <width>220</width>
  <height>24</height>
  <uuid>{bdcb518a-ea73-4da5-b1be-3573c10b0556}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 27/25 9/7 7/5 5/3 9/5 49/25 7/3 25/9</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>684</y>
  <width>138</width>
  <height>24</height>
  <uuid>{bfd29ccd-3b04-4d8d-bc63-81e1fc16d124}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale28</objectName>
  <x>1071</x>
  <y>709</y>
  <width>220</width>
  <height>24</height>
  <uuid>{9c53cf7e-d939-420a-ac4b-ee3578f75cac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 27/25 9/7 7/5 5/3 9/5 15/7 7/3 63/25</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>709</y>
  <width>138</width>
  <height>24</height>
  <uuid>{c43d2074-c086-4d40-b94f-39a2998bc850}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale29</objectName>
  <x>1071</x>
  <y>733</y>
  <width>220</width>
  <height>24</height>
  <uuid>{e418f6a0-9c5a-4b2a-b97d-3220836a2cec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 1 25/21 9/7 7/5 5/3 9/5 15/7 7/3 25/9</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>733</y>
  <width>138</width>
  <height>24</height>
  <uuid>{0c4fe393-c2a0-495f-9c14-5f1991ce5bb6}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit" >
  <objectName>scale30</objectName>
  <x>1071</x>
  <y>758</y>
  <width>220</width>
  <height>24</height>
  <uuid>{58daadf6-3a40-4f45-af81-eb8edfafc6ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3 13</label>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground" >
   <r>230</r>
   <g>221</g>
   <b>213</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>933</x>
  <y>758</y>
  <width>138</width>
  <height>24</height>
  <uuid>{99a44410-bd9e-460f-9a5e-dd41c1a6dbfa}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>2</x>
  <y>597</y>
  <width>261</width>
  <height>201</height>
  <uuid>{7a6bd644-b51a-40a5-a277-e55a49067a61}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider" >
  <objectName>wdmix</objectName>
  <x>52</x>
  <y>642</y>
  <width>160</width>
  <height>28</height>
  <uuid>{aa56b191-398f-43b1-a8cb-8192c5d2931f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.62500000</value>
  <mode>lin</mode>
  <mouseControl act="jump" >continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>3</x>
  <y>643</y>
  <width>49</width>
  <height>25</height>
  <uuid>{84925a10-12d4-4db2-a882-ef583fb89f59}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>212</x>
  <y>644</y>
  <width>48</width>
  <height>25</height>
  <uuid>{b8068579-ba3e-4ebf-bafe-1c7efb18eb01}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>73</x>
  <y>619</y>
  <width>109</width>
  <height>24</height>
  <uuid>{6f37159e-511c-40ab-94cb-dbd9fc077c40}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider" >
  <objectName>roomsize</objectName>
  <x>51</x>
  <y>694</y>
  <width>161</width>
  <height>30</height>
  <uuid>{789626ee-bf39-4f41-86a0-82f3803f235b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.30434800</value>
  <mode>lin</mode>
  <mouseControl act="jump" >continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>1</x>
  <y>696</y>
  <width>50</width>
  <height>25</height>
  <uuid>{6e25f6f4-7d5e-4fed-bd72-6faa7f336e1d}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>210</x>
  <y>696</y>
  <width>52</width>
  <height>24</height>
  <uuid>{ddcafad5-cfcd-49b8-8155-79dd300499c0}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>72</x>
  <y>670</y>
  <width>110</width>
  <height>24</height>
  <uuid>{f11dd5d6-94c7-4dbf-b798-72938484a053}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider" >
  <objectName>hfdamp</objectName>
  <x>46</x>
  <y>753</y>
  <width>160</width>
  <height>31</height>
  <uuid>{957d63d4-6f07-4e61-9fbd-daa2a83084a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.36875000</value>
  <mode>lin</mode>
  <mouseControl act="jump" >continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0" >false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>2</x>
  <y>756</y>
  <width>44</width>
  <height>26</height>
  <uuid>{23f09fc9-9c45-4853-9768-d0d9883c9822}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>204</x>
  <y>757</y>
  <width>59</width>
  <height>25</height>
  <uuid>{0968c24e-23b4-49a3-977f-6326478a4751}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>40</x>
  <y>723</y>
  <width>175</width>
  <height>30</height>
  <uuid>{6e733013-9c84-4a36-b307-47bec8a485a5}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel" >
  <objectName/>
  <x>431</x>
  <y>400</y>
  <width>497</width>
  <height>51</height>
  <uuid>{5f8b8069-6861-43b0-9c3b-f3c628d230f3}</uuid>
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
  <bgcolor mode="nobackground" >
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <objectName/>
 <x>0</x>
 <y>25</y>
 <width>1280</width>
 <height>750</height>
 <visible>true</visible>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 0 25 1280 750
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>
<MacGUI>
ioView background {43433, 43947, 32896}
ioText {806, 595} {62, 27} display 56.000000 0.00100 "key" left "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 56
ioText {349, 595} {457, 28} label 0.000000 0.00100 "" right "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Key Pressed
ioText {-1684371923, -1632653318} {227, 25} label 0.000000 0.00100 "" right "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Cent Deviation
ioText {807, 623} {82, 27} display -585.200000 0.00100 "cent" left "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder -585.2
ioText {267, 623} {539, 27} label 0.000000 0.00100 "" right "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Cent Difference in Relation to the Reference Frequency
ioText {807, 649} {82, 27} display 186.583300 0.00100 "freq" left "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 186.5833
ioText {266, 649} {542, 29} label 0.000000 0.00100 "" right "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Frequency of this Key
ioText {4, 35} {422, 214} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 
ioText {-610629723, -1632653302} {80, 25} display -585.200000 0.00100 "cent" left "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder -585.2
ioText {-610629955, -1632653304} {227, 25} label 0.000000 0.00100 "" right "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Cent Deviation
ioMenu {201, 215} {165, 25} 5 303 "sine,saw,square,square vco2,waveguide-clarinet,pluck" sound
ioText {43, 211} {160, 31} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Select Sound
ioText {742, 57} {131, 24} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder jh && rb 1/2010
ioText {807, 675} {82, 28} display 207.646500 0.00100 "normfreq" left "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 207.6465
ioText {267, 675} {541, 29} label 0.000000 0.00100 "" right "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Usual Frequency of this Key
ioText {807, 701} {82, 30} display -185.200000 0.00100 "centdiff" left "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder -185.2
ioText {267, 701} {541, 31} label 0.000000 0.00100 "" right "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Cent Difference Real Frequency to Usual Frequency
ioMeter {23, 184} {104, 23} {0, 59904, 0} "scsel1" 0.000000 "vert34" 0.434783 fill 1 0 mouse
ioMeter {154, 184} {104, 23} {0, 59904, 0} "scsel2" 0.000000 "vert34" 0.434783 fill 1 0 mouse
ioMeter {285, 184} {104, 23} {0, 59904, 0} "scsel3" 1.000000 "vert34" 0.434783 fill 1 0 mouse
ioText {314, 50} {107, 26} editnum 261.625000 0.000001 "tunfreq" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 261.625000
ioText {206, 44} {108, 28} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Related Pitch
ioText {227, 65} {72, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder (Hertz)
ioMenu {12, 162} {126, 24} 0 303 "Halftones,Thirdtones,Quartertones,Fifthtones,Sixthtones,Eighttones,Twelfthtones,Sixteenthtones,Stockhausen Studie II,UserDefined" equal_tmprd
ioText {10, 93} {393, 30} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Select Scale By Menu
ioText {129, 50} {68, 26} editnum 60.000000 1.000000 "reftone" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 60.000000
ioText {12, 44} {117, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Reference Key
ioText {29, 64} {87, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder (Midi-Number)
ioText {15, 120} {122, 43} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Equal TemperedÂ¬(1-10)
ioMenu {145, 162} {126, 24} 3 303 "Pythagorean,Zarlino 1/4 Comma,Werckmeister III,Kirnberger II,Indian Sruti I,Indian Sruti II,User Defined,User Defined,User Defined,User Defined" various
ioText {148, 120} {122, 43} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder VariousÂ¬(11-20)
ioMenu {275, 162} {126, 24} 5 303 "Equal Tempered,Ratios,Dur I Mode,Dur II Mode,Moll I (Delta) Mode,Moll II (Pierce) Mode,Gamma Mode,Harmonic Mode,Lambda Mode,User Defined" bohlen-pierce
ioText {278, 120} {122, 43} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Bohlen-PierceÂ¬(21-30)
ioText {273, 487} {639, 103} display 0.000000 0.00100 "info" center "Lucida Grande" 14 {0, 0, 0} {60672, 43264, 27392} nobackground noborder 26 Bohlen-Pierce Moll II Mode (Pierce):Â¬9 steps per 3:1 (duodecima) with ratios 1, 27/25, 9/7, 7/5, 5/3, 9/5, 15/7, 7/3, 25/9
ioButton {471, 55} {91, 27} value 1.000000 "_Play" "START" "/" i1 0 10
ioButton {585, 55} {91, 27} value 1.000000 "_Stop" "STOP" "/" i1 0 10
ioText {268, 458} {652, 275} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58880, 56576, 54528} nobackground noborder OUTPUT
ioSlider {274, 769} {250, 28} 0.000000 1.000000 0.444000 vol
ioText {309, 740} {97, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Volume
ioMeter {539, 745} {336, 22} {0, 59904, 0} "outL" 0.000000 "out1_post" 0.363636 fill 1 0 mouse
ioMeter {873, 745} {27, 22} {50176, 3584, 3072} "outLover" 0.000000 "outLover" 0.000000 fill 1 0 mouse
ioMeter {539, 771} {336, 22} {0, 59904, 0} "outR" 0.000000 "out2_post" 0.526316 fill 1 0 mouse
ioMeter {873, 771} {27, 22} {50176, 3584, 3072} "outRover" 0.000000 "outRover" 0.000000 fill 1 0 mouse
ioText {404, 740} {98, 27} display 0.444000 0.00100 "vol" center "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 0.4440
ioText {926, 19} {374, 773} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Scale Pool
ioText {452, 17} {449, 38} label 0.000000 0.00100 "" center "Lucida Grande" 22 {0, 0, 0} {58880, 56576, 54528} nobackground noborder PLAYING SCALES WITH A MIDI KEYBOARD
ioText {459, 84} {440, 23} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder This CSD was designed to let you play virtually any scale with a standard MIDI keyboard. 
ioText {4, 256} {261, 311} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 
ioMenu {10, 323} {108, 25} 0 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm1_scale
ioText {124, 323} {61, 25} editnum 36.000000 1.000000 "gm1_key" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 36.000000
ioText {188, 323} {61, 25} editnum 2.000000 1.000000 "gm1_chn" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 2.000000
ioText {18, 293} {83, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Scale
ioText {125, 293} {50, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Key
ioText {181, 293} {73, 27} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Channel
ioMenu {10, 354} {108, 25} 11 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm2_scale
ioText {124, 354} {61, 25} editnum 37.000000 1.000000 "gm2_key" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 37.000000
ioText {188, 354} {61, 25} editnum 2.000000 1.000000 "gm2_chn" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 2.000000
ioMenu {10, 382} {108, 25} 20 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I Mode,26 BP Moll II Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm3_scale
ioText {124, 382} {61, 25} editnum 38.000000 1.000000 "gm3_key" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 38.000000
ioText {188, 382} {61, 25} editnum 2.000000 1.000000 "gm3_chn" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 2.000000
ioMenu {10, 413} {108, 25} 2 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm4_scale
ioText {124, 413} {61, 25} editnum 40.000000 1.000000 "gm4_key" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 40.000000
ioText {188, 413} {61, 25} editnum 2.000000 1.000000 "gm4_chn" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 2.000000
ioMenu {10, 441} {108, 25} 25 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I Mode,26 BP Moll II Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm5_scale
ioText {124, 441} {61, 25} editnum 41.000000 1.000000 "gm5_key" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 41.000000
ioText {188, 441} {61, 25} editnum 2.000000 1.000000 "gm5_chn" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 2.000000
ioMenu {10, 472} {108, 25} 10 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm6_scale
ioText {124, 472} {61, 25} editnum 43.000000 1.000000 "gm6_key" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 43.000000
ioText {188, 472} {61, 25} editnum 2.000000 1.000000 "gm6_chn" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 2.000000
ioMenu {10, 500} {108, 25} 12 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm7_scale
ioText {124, 500} {61, 25} editnum 45.000000 1.000000 "gm7_key" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 45.000000
ioText {188, 500} {61, 25} editnum 2.000000 1.000000 "gm7_chn" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 2.000000
ioMenu {10, 531} {108, 25} 4 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm8_scale
ioText {124, 531} {61, 25} editnum 47.000000 1.000000 "gm8_key" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 47.000000
ioText {188, 531} {61, 25} editnum 2.000000 1.000000 "gm8_chn" left "" 0 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 2.000000
ioText {276, 299} {137, 71} display 0.000000 0.00100 "midi_event" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 
ioText {276, 276} {137, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Current MIDI Event
ioText {9, 263} {252, 31} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Select Scale By MIDI Keys
ioText {431, 108} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder PLAYING
ioText {431, 131} {492, 65} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Just connect your MIDI keyboard (see the Configuration panel to select the MIDI input). Press START, select a scale from one of the menus on the left, and select a sound. If you wish, you can associate and trigger up to 8 scales with specific MIDI keys thereby allowing for fast switching and easy comparison.
ioText {431, 195} {257, 26} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder ADDING USER DEFINED or NEW SCALES
ioText {431, 220} {495, 136} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder In the Scale Pool at the right you find a number of predefined scales. You can add any scale in the "User Defined" slots (10,17,18,19,20,30), or you can change or replace any of the scales in the following way:Â¬Type in the FIRST VALUE as the UNIT MULTIPLIER (2 = octave, 3 = perfect 12th, etc.).Â¬The SECOND VALUE lets you choose between three cases:Â¬1) if you type 0 you are giving a list of CENT values;Â¬2) if you type 1 you are giving a list of PROPORTIONS;Â¬3) any other value indicates an Equal Tempered Scale and gives as the second value the number of steps per Unit Multiplier.
ioText {431, 354} {101, 24} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder WARNING
ioText {431, 377} {501, 25} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Scales must have EXACTLY ONE space between the values and NO space at the beginning or the end.
ioText {1071, 50} {220, 24} edit 0.000000 0.00100 "scale1"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 12
ioText {933, 50} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 1 Halftones
ioText {1071, 75} {220, 24} edit 0.000000 0.00100 "scale2"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 18
ioText {933, 75} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 2 Thirdtones
ioText {1071, 99} {220, 24} edit 0.000000 0.00100 "scale3"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 24
ioText {933, 99} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 3 Quartertones
ioText {1071, 124} {220, 24} edit 0.000000 0.00100 "scale4"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 30
ioText {933, 124} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 4 Fifthtones
ioText {1071, 148} {220, 24} edit 0.000000 0.00100 "scale5"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 36
ioText {933, 148} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 5 Sixthtones
ioText {1071, 173} {220, 24} edit 0.000000 0.00100 "scale6"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 48
ioText {933, 173} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 6 Eighttones
ioText {1071, 197} {220, 24} edit 0.000000 0.00100 "scale7"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 72
ioText {933, 197} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 7 Twelfthtones
ioText {1071, 222} {220, 24} edit 0.000000 0.00100 "scale8"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 96
ioText {933, 222} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 8 Sixteenthtones
ioText {1071, 245} {220, 24} edit 0.000000 0.00100 "scale9"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 5 25
ioText {933, 245} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 9 Stockhausen Studie II
ioText {1071, 270} {220, 24} edit 0.000000 0.00100 "scale10"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 12
ioText {933, 270} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 10 User Defined
ioText {1071, 294} {220, 24} edit 0.000000 0.00100 "scale11"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 1 2187/2048 9/8 32/27 81/64 4/3 729/512 3/2 6561/4096 27/16 16/9 243/128
ioText {933, 294} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 11 Pythagorean
ioText {1071, 319} {220, 24} edit 0.000000 0.00100 "scale12"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 0 76 193 310 386 503 579 697 773 890 1007 1083
ioText {933, 319} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 12 Zarlino 1/4 Comma
ioText {1071, 343} {220, 24} edit 0.000000 0.00100 "scale13"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 0 90 192 294 390 498 588 696 792 888 996 1092
ioText {933, 343} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 13 Werckmeister III
ioText {1071, 368} {220, 24} edit 0.000000 0.00100 "scale14"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 0 90 204 294 386 498 590 702 792 895 996 1088
ioText {933, 368} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 14 Kirnberger II
ioText {1071, 392} {220, 24} edit 0.000000 0.00100 "scale15"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 0 90 112 182 204 294 316 386 408 498 520 590 610 702 792 814 884 906 996 1018 1088 1110
ioText {933, 392} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 15 Indian Sruti I
ioText {1071, 417} {220, 24} edit 0.000000 0.00100 "scale16"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 0 68.6 135.3 200.21 263.46 325.13 385.33 444.13 501.62 557.85 612.91 666.85 719.73 771.6 822.5 872.48 921.59 969.86 1017.33 1064.04 1110.01 1155.28
ioText {933, 417} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 16 Indian Sruti II
ioText {1071, 440} {220, 24} edit 0.000000 0.00100 "scale17"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 12
ioText {933, 440} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 17 User Defined
ioText {1071, 465} {220, 24} edit 0.000000 0.00100 "scale18"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 12
ioText {933, 465} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 18 User Defined
ioText {1071, 489} {220, 24} edit 0.000000 0.00100 "scale19"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 12
ioText {933, 489} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 19 User Defined
ioText {1071, 514} {220, 24} edit 0.000000 0.00100 "scale20"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 2 12
ioText {933, 514} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 20 User Defined
ioText {1071, 538} {220, 24} edit 0.000000 0.00100 "scale21"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 3 13
ioText {933, 538} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 21 BP Equal Tempered
ioText {1071, 563} {220, 24} edit 0.000000 0.00100 "scale22"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 3 1 27/25 25/21 9/7 7/5 75/49 5/3 9/5 49/25 15/7 7/3 63/25 25/9
ioText {933, 563} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 22 BP Ratios
ioText {1071, 586} {220, 24} edit 0.000000 0.00100 "scale23"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 3 1 27/25 9/7 7/5 5/3 9/5 49/25 7/3 63/25
ioText {933, 586} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 23 BP Dur I Mode
ioText {1071, 611} {220, 24} edit 0.000000 0.00100 "scale24"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 3 1 25/21 9/7 7/5 5/3 9/5 15/7 7/3 63/25
ioText {933, 611} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 24 BP Dur II Mode
ioText {1071, 635} {220, 24} edit 0.000000 0.00100 "scale25"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 3 1 25/21 9/7 75/49 5/3 9/5 15/7 7/3 25/9
ioText {933, 635} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 25 BP Moll I (Pierce) Mode 
ioText {1071, 660} {220, 24} edit 0.000000 0.00100 "scale26"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 3 1 27/25 9/7 7/5 5/3 9/5 15/7 7/3 25/9
ioText {933, 660} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 26 BP Moll II (Delta) Mode
ioText {1071, 684} {220, 24} edit 0.000000 0.00100 "scale27"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 3 1 27/25 9/7 7/5 5/3 9/5 49/25 7/3 25/9
ioText {933, 684} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 27 BP Gamma Mode
ioText {1071, 709} {220, 24} edit 0.000000 0.00100 "scale28"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 3 1 27/25 9/7 7/5 5/3 9/5 15/7 7/3 63/25
ioText {933, 709} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 28 BP Harmonic Mode
ioText {1071, 733} {220, 24} edit 0.000000 0.00100 "scale29"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 3 1 25/21 9/7 7/5 5/3 9/5 15/7 7/3 25/9
ioText {933, 733} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 29 BP Lambda Mode
ioText {1071, 758} {220, 24} edit 0.000000 0.00100 "scale30"  "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} falsenoborder 3 13
ioText {933, 758} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder 30 User Defined
ioText {2, 597} {261, 201} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Reverb (freeverb)
ioSlider {52, 642} {160, 28} 0.000000 1.000000 0.625000 wdmix
ioText {3, 643} {49, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Dry
ioText {212, 644} {48, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Wet
ioText {73, 619} {109, 24} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Mix
ioSlider {51, 694} {161, 30} 0.000000 1.000000 0.304348 roomsize
ioText {1, 696} {50, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Small
ioText {210, 696} {52, 24} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Large
ioText {72, 670} {110, 24} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Room Size
ioSlider {46, 753} {160, 31} 0.000000 1.000000 0.368750 hfdamp
ioText {2, 756} {44, 26} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder No
ioText {204, 757} {59, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder Yes
ioText {40, 723} {175, 30} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {58880, 56576, 54528} nobackground noborder High Frequency Attenuation
ioText {431, 400} {497, 51} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {58880, 56576, 54528} nobackground noborder NOTE: When you select a BP mode, it consists of 9 pitches (a unique subset of the 13 BP chromatic tones) and it is played on a MIDI keyboard chromatically starting from the REFERENCE KEY.  The 10th pitch is the "tritave" - a pure perfect 12th (an octave plus 5th) or a 3:1 frequency ratio.
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="360" y="248" width="596" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

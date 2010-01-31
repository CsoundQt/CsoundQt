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

<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 86 22 1329 858
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>
<MacGUI>
ioView background {43433, 43947, 32896}
ioText {806, 595} {62, 27} display 0.000000 0.00100 "key" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 56
ioText {349, 595} {457, 28} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Key Pressed
ioText {-1684371923, -1632653318} {227, 25} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Cent Deviation
ioText {807, 623} {82, 27} display 0.000000 0.00100 "cent" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -585.2
ioText {267, 623} {539, 27} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Cent Difference in Relation to the Reference Frequency
ioText {807, 649} {82, 27} display 0.000000 0.00100 "freq" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 186.5833
ioText {266, 649} {542, 29} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Frequency of this Key
ioText {4, 35} {422, 214} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {56832, 36608, 52736} nobackground border 
ioText {-610629723, -1632653302} {80, 25} display 0.000000 0.00100 "cent" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -585.2
ioText {-610629955, -1632653304} {227, 25} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Cent Deviation
ioMenu {201, 215} {165, 25} 5 303 "sine,saw,square,square vco2,waveguide-clarinet,pluck" sound
ioText {43, 211} {160, 31} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Select Sound
ioText {742, 57} {131, 24} label 0.000000 0.00100 "" right "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder jh && rb 1/2010
ioText {807, 675} {82, 28} display 0.000000 0.00100 "normfreq" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 207.6465
ioText {267, 675} {541, 29} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Usual Frequency of this Key
ioText {807, 701} {82, 30} display 0.000000 0.00100 "centdiff" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder -185.2
ioText {267, 701} {541, 31} label 0.000000 0.00100 "" right "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Cent Difference Real Frequency to Usual Frequency
ioMeter {23, 184} {104, 23} {0, 59904, 0} "vert34" 0.000000 "scsel1" 1.000000 fill 1 0 mouse
ioMeter {154, 184} {104, 23} {0, 59904, 0} "vert34" 0.000000 "scsel2" 0.000000 fill 1 0 mouse
ioMeter {285, 184} {104, 23} {0, 59904, 0} "vert34" 0.000000 "scsel3" 0.000000 fill 1 0 mouse
ioText {314, 50} {107, 26} editnum 261.625000 0.000001 "tunfreq" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 261.625000
ioText {206, 44} {108, 28} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Related Pitch
ioText {227, 65} {72, 25} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder (Hertz)
ioMenu {12, 162} {126, 24} 0 303 "Halftones,Thirdtones,Quartertones,Fifthtones,Sixthtones,Eighttones,Twelfthtones,Sixteenthtones,Stockhausen Studie II,UserDefined" equal_tmprd
ioText {10, 93} {393, 30} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Select Scale By Menu
ioText {129, 50} {68, 26} editnum 60.000000 1.000000 "reftone" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 60.000000
ioText {12, 44} {117, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Reference Key
ioText {29, 64} {87, 25} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder (Midi-Number)
ioText {15, 120} {122, 43} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Equal TemperedÂ¬(1-10)
ioMenu {145, 162} {126, 24} 0 303 "Pythagorean,Zarlino 1/4 Comma,Werckmeister III,Kirnberger II,Indian Sruti I,Indian Sruti II,User Defined,User Defined,User Defined,User Defined" various
ioText {148, 120} {122, 43} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder VariousÂ¬(11-20)
ioMenu {275, 162} {126, 24} 0 303 "Equal Tempered,Ratios,Dur I Mode,Dur II Mode,Moll I (Delta) Mode,Moll II (Pierce) Mode,Gamma Mode,Harmonic Mode,Lambda Mode,User Defined" bohlen-pierce
ioText {278, 120} {122, 43} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Bohlen-PierceÂ¬(21-30)
ioText {273, 487} {639, 103} display 0.000000 0.00100 "info" center "Lucida Grande" 12 {0, 0, 0} {60672, 43264, 27392} background noborder 7 TwelfsttoneÂ¬72 steps per octave with a ratio of 72th root of 2 = 1.009673...
ioButton {471, 55} {91, 27} value 1.000000 "_Play" "START" "/" i1 0 10
ioButton {585, 55} {91, 27} value 1.000000 "_Stop" "STOP" "/" i1 0 10
ioText {268, 458} {652, 275} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border OUTPUT
ioSlider {274, 769} {250, 28} 0.000000 1.000000 0.444000 vol
ioText {309, 740} {97, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Volume
ioMeter {539, 745} {336, 22} {0, 59904, 0} "out1_post" 0.363636 "outL" 0.000000 fill 1 0 mouse
ioMeter {873, 745} {27, 22} {50176, 3584, 3072} "outLover" 0.000000 "outLover" 0.000000 fill 1 0 mouse
ioMeter {539, 771} {336, 22} {0, 59904, 0} "out2_post" 0.526316 "outR" 0.000000 fill 1 0 mouse
ioMeter {873, 771} {27, 22} {50176, 3584, 3072} "outRover" 0.000000 "outRover" 0.000000 fill 1 0 mouse
ioText {404, 740} {98, 27} display 0.444000 0.00100 "vol" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 0.4440
ioText {926, 19} {374, 773} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground border Scale Pool
ioText {452, 17} {449, 38} label 0.000000 0.00100 "" center "Lucida Grande" 20 {0, 0, 0} {65280, 65280, 65280} nobackground noborder PLAYING SCALES WITH A MIDI KEYBOARD
ioText {459, 84} {440, 23} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder This CSD was designed to let you play virtually any scale with a standard MIDI keyboard. 
ioText {4, 256} {261, 311} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {56832, 36608, 52736} nobackground border 
ioMenu {10, 323} {108, 25} 0 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm1_scale
ioText {124, 323} {61, 25} editnum 36.000000 1.000000 "gm1_key" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 36.000000
ioText {188, 323} {61, 25} editnum 2.000000 1.000000 "gm1_chn" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioText {18, 293} {83, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Scale
ioText {125, 293} {50, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Key
ioText {181, 293} {73, 27} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Channel
ioMenu {10, 354} {108, 25} 11 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm2_scale
ioText {124, 354} {61, 25} editnum 37.000000 1.000000 "gm2_key" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 37.000000
ioText {188, 354} {61, 25} editnum 2.000000 1.000000 "gm2_chn" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioMenu {10, 382} {108, 25} 20 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I Mode,26 BP Moll II Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm3_scale
ioText {124, 382} {61, 25} editnum 38.000000 1.000000 "gm3_key" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 38.000000
ioText {188, 382} {61, 25} editnum 2.000000 1.000000 "gm3_chn" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioMenu {10, 413} {108, 25} 2 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm4_scale
ioText {124, 413} {61, 25} editnum 40.000000 1.000000 "gm4_key" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 40.000000
ioText {188, 413} {61, 25} editnum 2.000000 1.000000 "gm4_chn" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioMenu {10, 441} {108, 25} 25 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I Mode,26 BP Moll II Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm5_scale
ioText {124, 441} {61, 25} editnum 41.000000 1.000000 "gm5_key" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 41.000000
ioText {188, 441} {61, 25} editnum 2.000000 1.000000 "gm5_chn" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioMenu {10, 472} {108, 25} 10 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm6_scale
ioText {124, 472} {61, 25} editnum 43.000000 1.000000 "gm6_key" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 43.000000
ioText {188, 472} {61, 25} editnum 2.000000 1.000000 "gm6_chn" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioMenu {10, 500} {108, 25} 12 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm7_scale
ioText {124, 500} {61, 25} editnum 45.000000 1.000000 "gm7_key" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 45.000000
ioText {188, 500} {61, 25} editnum 2.000000 1.000000 "gm7_chn" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioMenu {10, 531} {108, 25} 4 303 "1 Halftones,2 Thirdtones,3 Quartertones,4 Fifthtones,5 Sixthtones,6 Eighttones,7 Twelfthtones,8 Sixteenthtones,9 Stockhausen Studie II,10 User Defined,11 Pythagorean,12 Zarlino 1/4 Comma,13 Werckmeister III,14 Kirnberger II,15 Indian Sruti I,16 Indian Sruti II,17 User Defined,18 User Defined,19 User Defined,20 User Defined,21 BP Equal Tempered,22 BP Ratios,23 BP Dur I Mode,24 BP Dur II Mode,25 BP Moll I (Delta) Mode,26 BP Moll II (Pierce) Mode,27 BP Gamma Mode,28 BP Harmonic Mode,29 BP Lambda Mode,30 User Defined" gm8_scale
ioText {124, 531} {61, 25} editnum 47.000000 1.000000 "gm8_key" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 47.000000
ioText {188, 531} {61, 25} editnum 2.000000 1.000000 "gm8_chn" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2.000000
ioText {276, 299} {137, 71} display 0.000000 0.00100 "midi_event" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 
ioText {276, 276} {137, 25} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Current MIDI Event
ioText {9, 263} {252, 31} label 0.000000 0.00100 "" center "Lucida Grande" 16 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Select Scale By MIDI Keys
ioText {431, 108} {80, 25} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder PLAYING
ioText {431, 131} {492, 65} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Just connect your MIDI keyboard (see the Configuration panel to select the MIDI input). Press START, select a scale from one of the menus on the left, and select a sound. If you wish, you can associate and trigger up to 8 scales with specific MIDI keys thereby allowing for fast switching and easy comparison.
ioText {431, 195} {257, 26} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder ADDING USER DEFINED or NEW SCALES
ioText {431, 220} {495, 136} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder In the Scale Pool at the right you find a number of predefined scales. You can add any scale in the "User Defined" slots (10,17,18,19,20,30), or you can change or replace any of the scales in the following way:Â¬Type in the FIRST VALUE as the UNIT MULTIPLIER (2 = octave, 3 = perfect 12th, etc.).Â¬The SECOND VALUE lets you choose between three cases:Â¬1) if you type 0 you are giving a list of CENT values;Â¬2) if you type 1 you are giving a list of PROPORTIONS;Â¬3) any other value indicates an Equal Tempered Scale and gives as the second value the number of steps per Unit Multiplier.
ioText {431, 354} {101, 24} label 0.000000 0.00100 "" left "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground noborder WARNING
ioText {431, 377} {501, 25} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Scales must have EXACTLY ONE space between the values and NO space at the beginning or the end.
ioText {1071, 50} {220, 24} edit 0.000000 0.00100 "scale1" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 12
ioText {933, 50} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 1 Halftones
ioText {1071, 75} {220, 24} edit 0.000000 0.00100 "scale2" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 18
ioText {933, 75} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 Thirdtones
ioText {1071, 99} {220, 24} edit 0.000000 0.00100 "scale3" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 24
ioText {933, 99} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3 Quartertones
ioText {1071, 124} {220, 24} edit 0.000000 0.00100 "scale4" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 30
ioText {933, 124} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 4 Fifthtones
ioText {1071, 148} {220, 24} edit 0.000000 0.00100 "scale5" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 36
ioText {933, 148} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 5 Sixthtones
ioText {1071, 173} {220, 24} edit 0.000000 0.00100 "scale6" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 48
ioText {933, 173} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 6 Eighttones
ioText {1071, 197} {220, 24} edit 0.000000 0.00100 "scale7" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 72
ioText {933, 197} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 7 Twelfthtones
ioText {1071, 222} {220, 24} edit 0.000000 0.00100 "scale8" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 96
ioText {933, 222} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 8 Sixteenthtones
ioText {1071, 245} {220, 24} edit 0.000000 0.00100 "scale9" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 5 25
ioText {933, 245} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 9 Stockhausen Studie II
ioText {1071, 270} {220, 24} edit 0.000000 0.00100 "scale10" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 12
ioText {933, 270} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 10 User Defined
ioText {1071, 294} {220, 24} edit 0.000000 0.00100 "scale11" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 1 2187/2048 9/8 32/27 81/64 4/3 729/512 3/2 6561/4096 27/16 16/9 243/128
ioText {933, 294} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 11 Pythagorean
ioText {1071, 319} {220, 24} edit 0.000000 0.00100 "scale12" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 0 76 193 310 386 503 579 697 773 890 1007 1083
ioText {933, 319} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 12 Zarlino 1/4 Comma
ioText {1071, 343} {220, 24} edit 0.000000 0.00100 "scale13" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 0 90 192 294 390 498 588 696 792 888 996 1092
ioText {933, 343} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 13 Werckmeister III
ioText {1071, 368} {220, 24} edit 0.000000 0.00100 "scale14" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 0 90 204 294 386 498 590 702 792 895 996 1088
ioText {933, 368} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 14 Kirnberger II
ioText {1071, 392} {220, 24} edit 0.000000 0.00100 "scale15" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 0 90 112 182 204 294 316 386 408 498 520 590 610 702 792 814 884 906 996 1018 1088 1110
ioText {933, 392} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 15 Indian Sruti I
ioText {1071, 417} {220, 24} edit 0.000000 0.00100 "scale16" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 0 68.6 135.3 200.21 263.46 325.13 385.33 444.13 501.62 557.85 612.91 666.85 719.73 771.6 822.5 872.48 921.59 969.86 1017.33 1064.04 1110.01 1155.28
ioText {933, 417} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 16 Indian Sruti II
ioText {1071, 440} {220, 24} edit 0.000000 0.00100 "scale17" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 12
ioText {933, 440} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 17 User Defined
ioText {1071, 465} {220, 24} edit 0.000000 0.00100 "scale18" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 12
ioText {933, 465} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 18 User Defined
ioText {1071, 489} {220, 24} edit 0.000000 0.00100 "scale19" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 12
ioText {933, 489} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 19 User Defined
ioText {1071, 514} {220, 24} edit 0.000000 0.00100 "scale20" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 2 12
ioText {933, 514} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 20 User Defined
ioText {1071, 538} {220, 24} edit 0.000000 0.00100 "scale21" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3 13
ioText {933, 538} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 21 BP Equal Tempered
ioText {1071, 563} {220, 24} edit 0.000000 0.00100 "scale22" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3 1 27/25 25/21 9/7 7/5 75/49 5/3 9/5 49/25 15/7 7/3 63/25 25/9
ioText {933, 563} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 22 BP Ratios
ioText {1071, 586} {220, 24} edit 0.000000 0.00100 "scale23" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3 1 27/25 9/7 7/5 5/3 9/5 49/25 7/3 63/25
ioText {933, 586} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 23 BP Dur I Mode
ioText {1071, 611} {220, 24} edit 0.000000 0.00100 "scale24" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3 1 25/21 9/7 7/5 5/3 9/5 15/7 7/3 63/25
ioText {933, 611} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 24 BP Dur II Mode
ioText {1071, 635} {220, 24} edit 0.000000 0.00100 "scale25" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3 1 25/21 9/7 75/49 5/3 9/5 15/7 7/3 25/9
ioText {933, 635} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 25 BP Moll I (Pierce) Mode 
ioText {1071, 660} {220, 24} edit 0.000000 0.00100 "scale26" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3 1 27/25 9/7 7/5 5/3 9/5 15/7 7/3 25/9
ioText {933, 660} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 26 BP Moll II (Delta) Mode
ioText {1071, 684} {220, 24} edit 0.000000 0.00100 "scale27" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3 1 27/25 9/7 7/5 5/3 9/5 49/25 7/3 25/9
ioText {933, 684} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 27 BP Gamma Mode
ioText {1071, 709} {220, 24} edit 0.000000 0.00100 "scale28" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3 1 27/25 9/7 7/5 5/3 9/5 15/7 7/3 63/25
ioText {933, 709} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 28 BP Harmonic Mode
ioText {1071, 733} {220, 24} edit 0.000000 0.00100 "scale29" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3 1 25/21 9/7 7/5 5/3 9/5 15/7 7/3 25/9
ioText {933, 733} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 29 BP Lambda Mode
ioText {1071, 758} {220, 24} edit 0.000000 0.00100 "scale30" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 3 13
ioText {933, 758} {138, 24} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder 30 User Defined
ioText {2, 597} {261, 201} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {65280, 65280, 65280} nobackground border Reverb (freeverb)
ioSlider {52, 642} {160, 28} 0.000000 1.000000 0.625000 wdmix
ioText {3, 643} {49, 25} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Dry
ioText {212, 644} {48, 25} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Wet
ioText {73, 619} {109, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Mix
ioSlider {51, 694} {161, 30} 0.000000 1.000000 0.304348 roomsize
ioText {1, 696} {50, 25} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Small
ioText {210, 696} {52, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Large
ioText {72, 670} {110, 24} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Room Size
ioSlider {46, 753} {160, 31} 0.000000 1.000000 0.368750 hfdamp
ioText {2, 756} {44, 26} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder No
ioText {204, 757} {59, 25} label 0.000000 0.00100 "" center "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder Yes
ioText {40, 723} {175, 30} label 0.000000 0.00100 "" center "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground noborder High Frequency Attenuation
ioText {431, 400} {497, 51} label 0.000000 0.00100 "" left "Lucida Grande" 10 {0, 0, 0} {65280, 65280, 65280} nobackground noborder NOTE: When you select a BP mode, it consists of 9 pitches (a unique subset of the 13 BP chromatic tones) and it is played on a MIDI keyboard chromatically starting from the REFERENCE KEY.  The 10th pitch is the "tritave" - a pure perfect 12th (an octave plus 5th) or a 3:1 frequency ratio.
</MacGUI>

<EventPanel name="" tempo="60.00000000" loop="8.00000000" name="" x="360" y="248" width="596" height="322"> 
 
 
 
 
 
 
 
 
 </EventPanel>
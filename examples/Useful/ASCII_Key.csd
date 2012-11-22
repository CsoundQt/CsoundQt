<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
nchnls = 2
ksmps = 128
0dbfs = 1

;Get the ASCII key number
;Example for CsoundQt
;joachim heintz && andrés cabrera mar 2010 / feb 2011


strset		11, "Thank you!"
strset		12, "My goodness!"
strset		13, "Oh my god!"
strset		14, "Why?"
strset		15, "You did what you must."
strset		21, "is a very meaningful"
strset		22, "is a totally senseless"
strset		23, "is a deeply religious"
strset		24, "is a rather useless"
strset		25, "is a somewhat symbolic"
strset		26, "is nothing more than a"
strset		27, "is obviously a strange"
strset		28, "is an enourmously irrational"

seed			0
gicount	=	0
gimodel	ftgen	0, 0, -21, -2, 1,1,0, .7,2,0, .5,3,0, .3,4,0, .1,5,0, .05,6,0, .02,7,0; partial model


  opcode TypeIn, 0, k
;displays type-in request
konoff		xin 
if konoff == 1 then
ktrig		metro		1
kplease	init		0
 if ktrig == 1 then
kplease	=		kplease + 1
 endif 
 if kplease % 2 == 1 then
		outvalue	"typein1", "TYPE"
 else	
		outvalue	"typein1", ""
 endif 
 if kplease % 2 == 0 then
		outvalue	"typein2", "NOW!"
 else	
		outvalue	"typein2", ""
 endif 
else	
		outvalue	"typein1", ""
		outvalue	"typein2", ""
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

  opcode TabMkCp_i, i, i
;creates a function table icop which is a copy of isrc, and returns its number
isrc		xin
isrclen	=		ftlen(isrc)
icop		ftgen		0, 0, -isrclen, -2, 0
		tableicopy	icop, isrc
		xout		icop
  endop 

  opcode ChangeTable, i, iipo
;copies iftin, changes its value randomly in the range +- iperc percent, and returns it as iftout
;ihop = which is the next element (1=next (= default), 2=the second to come, etc)
;istart = at which index to start (default = 0)
iftin, iperc, ihop, istart	xin 
iftout		TabMkCp_i	iftin
indx		=		istart
loop:
if indx >= ftlen(iftin)-1 igoto end 
ival		tab_i		indx, iftout
irand		random		-iperc, iperc
inew		=		ival + (irand/100) * ival
		tabw_i		inew, indx, iftout
indx		=		indx + ihop
		igoto		loop 
end:		xout		iftout
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
;;GET SPEED AND ESTIMATE THE USER'S AGE
kspeed		invalue	"speed"
kyears 	=		20*kspeed*1.8^kspeed
kmonths	=		10^kspeed % 12
Sage		sprintfk	"Age estimated from your speed selection:\n%d years, %d months, %d days.",  kyears, kmonths, 10^kspeed % 30
		outvalue	"age", Sage
;;TURN ON TYPE-IN DISPLAY PROMPT
konoff		init		1
		TypeIn		konoff

kchr, kkeydown sensekey

;;CALL INSTR 10 IF SOMETHING NEW HAS BEEN TYPED
kdwn, k0	KeyOnce	kchr, kkeydown, kchr
if kchr != 0 && kdwn == 1 then
konoff		=		0
		event		"i", 10, 0.1, kspeed*24, kchr
endif 
endin

instr 2 ;;CLEAR DISPLAYS WHEN NECESSARY

		outvalue	"thanks", ""
		outvalue	"youtyped", ""
		outvalue	"showchar1", ""
		outvalue	"ascii1", ""
		outvalue	"showascii1", ""
		outvalue	"asyouwill", ""
		outvalue	"showchar2", ""
		outvalue	"isavery", ""
		outvalue	"theby", ""
		outvalue	"showascii2", ""
		outvalue	"isatotally", ""
		outvalue	".", ""
		outvalue	"!", ""
		turnoff
endin 

instr 10
		event_i 	"i", 2, 0, .1 ;clear display first
;;GENERATE A NOTE
  ;PITCH AND ENVELOPE
ipch		RandInts_i	0, 45; 46 steps per octave 
ioct		RandInts_i	0, 2; 3 octaves 
ifreq		=		200 * 2^ioct * 2^(ipch/46); lowest pitch = 200 Hz
iupdown	RandInts_i	0, 1; 0 = gliss up, 1 = gliss down 
iglissrel1	RandInts_i	2, 5
iglissrel	=		1/iglissrel1; gliss is 1/2, 1/3, 1/4 or 1/5 higher or lower
iglissfreq	=		(iupdown == 0 ? ifreq + ifreq*iglissrel : ifreq - ifreq*iglissrel)
idur		=		p3 * iglissrel * .2; duration of the tone 
afreq		expseg		ifreq, idur, iglissfreq; frequency with glissando
ivol1		RandInts_i	2, 5
ivol		=		0dbfs/ivol1; volume as 1/2, 1/3, 1/4 or 1/5 0dbfs
aenv		transeg	ivol, idur, -iglissrel, 0, p3-idur, 0, 0; envelope
  ;;FUNCTION TABLE AND REVERB
ipercparts	=		50; how many percent maximum change of partials in gimodel
ipercstrs	=		100; how many percent maximum change of strengths in gimodel
iftparts	ChangeTable	gimodel, ipercparts, 3, 1; change the partial values according to ipercparts
iftstrngs	ChangeTable	iftparts, ipercstrs, 3, 0; change the strenghtes of the partials 
iftsound	ftgen		0, 0, 4096, 34, iftstrngs, 7, 1; calculate the resulting function table
asound		oscili		aenv, afreq, iftsound
iromsiz	random		.5, .9; choose random value for freeverb's roomsize
aL, aR		freeverb 	asound, asound, iromsiz, .5; apply reverb 
		outs		aL, aR	; send sound out 
	

;;GENERATE IMPORTANT INFORMATION FOR THE USER
if gicount == 0 then; at the first time use these values
ithanks	=		11
isavery	=		21
isatotally	=		23
else		; at following times use random choices
ithanks	RandInts_i	11, 15
isavery	RandInts_i	21, 28
isatotally	RandInts_i	21, 28
endif 
gicount	=		gicount + 1; for knowing it's now the second time 
ichr		=		p4; ascii code for actual character
ispeed		=		p3/36; speed 
Schar		sprintf	"%c", ichr; string with the typed character
Sascii		sprintf	"%d", ichr; string with the ascii code

Sthanks	strget		ithanks
Sisavery	strget		isavery
Sisavery	strcat		Sisavery, " character."

Sisatotally	strget		isatotally
 if isatotally == isavery then
Sisatotally	strcat		Sisatotally, " number, too."
 else 
Sisatotally	strcat		Sisatotally, " number."
 endif

;;SHOW SEQUENTIAL OUTPUT 
ishow		=		ispeed/4 ;speed of progression
 ;call i 20 at the different starting times
S1		sprintf  	"i 20 %f 1 1 \"%s\"", ishow, Sthanks
S2		sprintf  	"i 20 %f 1 2 \"\"", ishow*10
S3 		sprintf  	"i 20 %f 1 3 \"%s\"", ishow*20, Schar
S4 		sprintf  	"i 20 %f 1 4 \"\"", ishow*35
S5 		sprintf  	"i 20 %f 1 5 \"\"", ishow*50
S6 		sprintf  	"i 20 %f 1 6 \"%s\"", ishow*60, Sascii
S7 		sprintf  	"i 20 %f 1 7 \"\"", ishow*65
S8 		sprintf  	"i 20 %f 1 8 \"\"", ishow*90
S9 		sprintf  	"i 20 %f 1 9 \"%s\"", ishow*150, Schar
S10 		sprintf  	"i 20 %f 1 10 \"%s\"", ishow*160, Sisavery
S11 		sprintf  	"i 20 %f 1 11 \"\"", ishow*180
S12 		sprintf  	"i 20 %f 1 12 \"%s\"", ishow*210, Sascii
S13 		sprintf  	"i 20 %f 1 13 \"%s\"", ishow*230, Sisatotally
		scoreline_i 	S1
		scoreline_i	S2
		scoreline_i 	S3
		scoreline_i	S4
		scoreline_i 	S5
		scoreline_i 	S6
		scoreline_i 	S7
		scoreline_i 	S8
		scoreline_i 	S9
		scoreline_i 	S10
		scoreline_i 	S11
		scoreline_i 	S12
		scoreline_i 	S13
endin

instr 20 ;send text
ichannel	= 	p4
Stext		=	p5
if ichannel == 1 then
	outvalue "thanks", Stext
elseif ichannel == 2 then
	outvalue "youtyped", "You typed the character"
elseif ichannel == 3 then
	outvalue "showchar1", Stext
elseif ichannel == 4 then
	outvalue ".", "."
elseif ichannel == 5 then
	outvalue "ascii1", "The ASCII code of this character is"
elseif ichannel == 6 then
	outvalue "showascii1", Stext
elseif ichannel == 7 then
	outvalue "!", "!"
elseif ichannel == 8 then
	outvalue "asyouwill", "As you will certainly have heard by the unique tone which is presented here for the first time as the result of long research from all times and cultures at least on earth"
elseif ichannel == 9 then
	outvalue "showchar2", Stext
elseif ichannel == 10 then
	outvalue "isavery", Stext
elseif ichannel == 11 then
	outvalue "theby", "The number, which for many reasons is specially related to this character, "
elseif ichannel == 12 then
	outvalue "showascii2", Stext
elseif ichannel == 13 then
	outvalue "isatotally", Stext
endif
turnoff
endin

</CsInstruments>
<CsScore>
i 2 0 1
i 1 0 36000; spend 10 hours in profund research and listen to the voice of the truth
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>335</x>
 <y>145</y>
 <width>821</width>
 <height>593</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>showascii1</objectName>
  <x>359</x>
  <y>326</y>
  <width>49</width>
  <height>33</height>
  <uuid>{a55e0ce0-8c52-4047-bf13-0b1ba20e7fab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
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
  <objectName>showchar1</objectName>
  <x>359</x>
  <y>288</y>
  <width>31</width>
  <height>30</height>
  <uuid>{8532d68c-d5df-4af5-b42c-112356c3b1c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
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
  <objectName>typein1</objectName>
  <x>119</x>
  <y>184</y>
  <width>102</width>
  <height>49</height>
  <uuid>{46574579-d664-4984-87d8-c253e399baac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>30</fontsize>
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
  <objectName>typein2</objectName>
  <x>223</x>
  <y>183</y>
  <width>103</width>
  <height>49</height>
  <uuid>{87b2b136-82f1-40b7-9039-e8e77395e512}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Lucida Grande</font>
  <fontsize>30</fontsize>
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
  <objectName>thanks</objectName>
  <x>62</x>
  <y>242</y>
  <width>394</width>
  <height>33</height>
  <uuid>{0752771e-37c3-49e2-b666-f2b41a1c5bcf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label/>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>youtyped</objectName>
  <x>79</x>
  <y>290</y>
  <width>275</width>
  <height>30</height>
  <uuid>{69c3c6d8-c4c0-4b64-a861-35735d0fcae0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
  <objectName>asyouwill</objectName>
  <x>65</x>
  <y>374</y>
  <width>391</width>
  <height>76</height>
  <uuid>{027dd6d8-79fe-4004-a52b-9205a9a8d176}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ascii1</objectName>
  <x>82</x>
  <y>328</y>
  <width>275</width>
  <height>30</height>
  <uuid>{1b8bc0dc-fc3c-4f85-b5a0-f041d7b5db79}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
  <objectName>showchar2</objectName>
  <x>96</x>
  <y>451</y>
  <width>38</width>
  <height>30</height>
  <uuid>{3dc69a6f-7567-4667-ad9e-c938ae55d612}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
  <objectName>isavery</objectName>
  <x>137</x>
  <y>453</y>
  <width>275</width>
  <height>30</height>
  <uuid>{78ff5969-7917-4dba-afe9-507d6124be33}</uuid>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>isatotally</objectName>
  <x>139</x>
  <y>546</y>
  <width>275</width>
  <height>30</height>
  <uuid>{2b58f46d-0510-439e-a835-9fed0d30f81e}</uuid>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>theby</objectName>
  <x>66</x>
  <y>492</y>
  <width>382</width>
  <height>47</height>
  <uuid>{ca22476a-8dc2-4288-912f-4cfa3cf1eb6f}</uuid>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>showascii2</objectName>
  <x>78</x>
  <y>544</y>
  <width>59</width>
  <height>33</height>
  <uuid>{a9301c1b-f6c8-4a21-af60-f8ee6557ada2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
  <objectName>.</objectName>
  <x>375</x>
  <y>290</y>
  <width>41</width>
  <height>30</height>
  <uuid>{43373687-936d-468d-9260-f7396ab1061c}</uuid>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>!</objectName>
  <x>393</x>
  <y>328</y>
  <width>41</width>
  <height>30</height>
  <uuid>{81764181-1f22-48a4-9a9a-293419d282b1}</uuid>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>49</x>
  <y>16</y>
  <width>721</width>
  <height>41</height>
  <uuid>{041fe329-d209-4e3d-ad7a-56e9abf09631}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Get the ASCII Code of a Character</label>
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
  <x>48</x>
  <y>55</y>
  <width>722</width>
  <height>58</height>
  <uuid>{6a149d69-516e-49ac-8253-16e048b92ceb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>And learn a lot more about the symbolic function of characters and numbers.
This can be very important for your future life.</label>
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
  <x>47</x>
  <y>112</y>
  <width>724</width>
  <height>48</height>
  <uuid>{98fcf679-a848-4a34-996b-9ce180492cb6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>First, select your personal speed at the slider on the right.
Then, press the Start button.</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>speed</objectName>
  <x>514</x>
  <y>222</y>
  <width>259</width>
  <height>27</height>
  <uuid>{05335d5c-63bc-43c9-80fb-d041d424167b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.10000000</minimum>
  <maximum>2.00000000</maximum>
  <value>0.74555985</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>513</x>
  <y>192</y>
  <width>260</width>
  <height>25</height>
  <uuid>{79ee3261-6f9b-4714-9126-bba72b4d5d3b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Select Your Personal Speed of Messages</label>
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
  <objectName>age</objectName>
  <x>514</x>
  <y>277</y>
  <width>259</width>
  <height>97</height>
  <uuid>{e0e9bba2-2adf-4981-af08-9bd45d2be198}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Age estimated from your speed selection:
23 years, 6 months, 6 days.</label>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>513</x>
  <y>373</y>
  <width>261</width>
  <height>28</height>
  <uuid>{0ad23d88-6832-4d56-8ca4-b3ecac93a75e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Start</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>true</latched>
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
ioText {359, 326} {49, 33} display 0.000000 0.00100 "showascii1" left "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {359, 288} {31, 30} display 0.000000 0.00100 "showchar1" left "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {119, 184} {102, 49} display 0.000000 0.00100 "typein1" right "Lucida Grande" 30 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {223, 183} {103, 49} display 0.000000 0.00100 "typein2" left "Lucida Grande" 30 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {62, 242} {394, 33} display 0.000000 0.00100 "thanks" center "DejaVu Sans" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {79, 290} {275, 30} display 0.000000 0.00100 "youtyped" right "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {65, 374} {391, 76} display 0.000000 0.00100 "asyouwill" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {82, 328} {275, 30} display 0.000000 0.00100 "ascii1" right "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {96, 451} {38, 30} display 0.000000 0.00100 "showchar2" right "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {137, 453} {275, 30} display 0.000000 0.00100 "isavery" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {139, 546} {275, 30} display 0.000000 0.00100 "isatotally" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {66, 492} {382, 47} display 0.000000 0.00100 "theby" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {78, 544} {59, 33} display 0.000000 0.00100 "showascii2" right "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {375, 290} {41, 30} display 0.000000 0.00100 "." left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {393, 328} {41, 30} display 0.000000 0.00100 "!" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {49, 16} {721, 41} label 0.000000 0.00100 "" center "Lucida Grande" 22 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Get the ASCII Code of a Character
ioText {48, 55} {722, 58} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder And learn a lot more about the symbolic function of characters and numbers.Â¬This can be very important for your future life.
ioText {47, 112} {724, 48} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder First, select your personal speed at the slider on the right.Â¬Then, press the Start button.
ioSlider {514, 222} {259, 27} 0.100000 2.000000 0.745560 speed
ioText {513, 192} {260, 25} label 0.000000 0.00100 "" center "Lucida Grande" 12 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Select Your Personal Speed of Messages
ioText {514, 277} {259, 97} display 0.000000 0.00100 "age" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Age estimated from your speed selection:Â¬23 years, 6 months, 6 days.
ioButton {513, 373} {261, 28} value 1.000000 "_Play" "Start" "/" i1 0 10
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="360" y="248" width="596" height="322" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

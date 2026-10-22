<CsoundSynthesizer>
<CsOptions>
-odac -m128
</CsOptions>
<CsInstruments>
nchnls = 2
ksmps  = 64
0dbfs  = 1

; Get the ASCII key number
; Example for CsoundQt
; joachim heintz && andrés cabrera mar 2010 / feb 2011


strset 11, "Thank you!"
strset 12, "My goodness!"
strset 13, "Oh my god!"
strset 14, "Why?"
strset 15, "You did what you must."
strset 21, "is a very meaningful"
strset 22, "is a totally senseless"
strset 23, "is a deeply religious"
strset 24, "is a rather useless"
strset 25, "is a somewhat symbolic"
strset 26, "is nothing more than a"
strset 27, "is obviously a strange"
strset 28, "is an enourmously irrational"

seed 0
gicount = 0
; partial model
gimodel = ftgen(0, 0, 32, -2, 1, 1, 0, .7, 2, 0, .5, 3, 0, .3, 4, 0, .1, 5, 0, .05, 6, 0, .02, 7, 0)


opcode TypeIn(konoff:k):()
  ; displays type-in request
  if konoff == 1 then
    ktrig   = metro(1)
    kplease = init(0)
    if ktrig == 1 then
      kplease = kplease + 1
    endif
    if kplease % 2 == 1 then
      chnset("TYPE", "typein1")
    else
      chnset("", "typein1")
    endif
    if kplease % 2 == 0 then
      chnset("NOW!", "typein2")
    else
      chnset("", "typein2")
    endif
  else
    chnset( "", "typein1")
    chnset( "", "typein2")
  endif
endop

opcode RandInts_i(ival1:i, ival2:i):i
  ; random integer between ival1 and ival2 (both included)
  if ival1 < ival2 then
    imin = ival1
    imax = ival2
  else
    imin = ival2
    imax = ival1
  endif
  imin = (imin < 0 ? imin-0.9999 : imin)
  imax = (imax < 0 ? imax : imax+0.9999)
  ires = random(imin, imax)
  xout int(ires)
endop

opcode TabMkCp_i(isrc:i):i
  ; creates a function table icop which is a copy of isrc, and returns its number
  isrclen = ftlen(isrc)
  icop    = ftgen(0, 0, -isrclen, -2, 0)
  tableicopy icop, isrc
  xout icop
endop

opcode ChangeTable(iftin:i, iperc:i, ihop:p, istart:o):i
  ; copies iftin, changes its value randomly in the range +- iperc percent, 
  ; and returns it
  ; as iftout
  ; ihop = which is the next element (1=next (= default), 2=the second to come, etc)
  ; istart = at which index to start (default = 0)
  iftout = TabMkCp_i(iftin)
  indx   = istart
loop:
  if indx >= ftlen(iftin)-1 igoto end
  ival tab_i indx, iftout
  irand = random(-iperc, iperc)
  inew  = ival + (irand/100) * ival
  tabw_i inew, indx, iftout
  indx = indx + ihop
  igoto loop
end: xout iftout
endop

opcode KeyOnce(key:k, kd:k, kascii:k):(k, k)
  ; returns '1' just in the k-cycle a certain key has been pressed (kdown) or released
  ; (kup)
  ; sensekey output and ascii code of the key (e.g. 32 for space)
  knew  = changed(key)
  kdown = (key == kascii && knew == 1 && kd == 1 ? 1 : 0)
  kup   = (key == kascii && knew == 1 && kd == 0 ? 1 : 0)
  xout kdown, kup
endop


instr 1
  ; ;Get speed and estimate the user's age
  kspeed  = chnget("speed")
  kyears  = 20*kspeed*1.8^kspeed
  kmonths = 10^kspeed % 12
  Sage    = sprintfk("Age estimated from your speed selection:\n%d years, %d months, %d days.", kyears, kmonths, 10^kspeed % 30)
  chnset(Sage, "age")
  ; ;Turn on type-in display prompt
  konoff = init(1)
  TypeIn konoff

  kchr, kkeydown sensekey

  ; ;Call instr 10 if something new has been typed
  kdwn, k0 KeyOnce kchr, kkeydown, kchr
  if kchr != 0 && kdwn == 1 then
    konoff = 0
    event "i", 10, 0.1, kspeed*24, kchr
  endif
endin

instr 2  ; ;Clear displays when necessary

  chnset("", "thanks")
  chnset("", "youtyped")
  chnset("", "showchar1")
  chnset("", "ascii1")
  chnset("", "showascii1")
  chnset("", "asyouwill")
  chnset("", "showchar2")
  chnset("", "isavery")
  chnset("", "theby")
  chnset("", "showascii2")
  chnset("", "isatotally")
  chnset("", ".")
  chnset("", "!")
  turnoff
endin

instr 10
  event_i "i", 2, 0, .1  ; clear display first
  ; ;Generate a note
  ; Pitch and envelope
  ipch = RandInts_i(0, 45)            ; 46 steps per octave
  ioct = RandInts_i(0, 2)             ; 3 octaves
  ifreq = 200 * 2^ioct * 2^(ipch/46)  ; lowest pitch = 200 Hz
  iupdown = RandInts_i(0, 1)          ; 0 = gliss up, 1 = gliss down
  iglissrel1 = RandInts_i(2, 5)
  iglissrel = 1/iglissrel1  ; gliss is 1/2, 1/3, 1/4 or 1/5 higher or lower
  iglissfreq = (iupdown == 0 ? ifreq + ifreq*iglissrel : ifreq - ifreq*iglissrel)
  idur = p3 * iglissrel * .2               ; duration of the tone
  afreq = expseg(ifreq, idur, iglissfreq)  ; frequency with glissando
  ivol1 = RandInts_i(2, 5)
  ; volume as 1/2, 1/3, 1/4 or 1/5 0dbfs
  ivol = 0dbfs/ivol1
  aenv = transeg(ivol, idur, -iglissrel, 0, p3-idur, 0, 0)  ; envelope
  ; ;Function table and reverb
  ipercparts = 50   ; how many percent maximum change of partials in gimodel
  ipercstrs  = 100  ; how many percent maximum change of strengths in gimodel
  ; change the partial values according to ipercparts
  iftparts = ChangeTable(gimodel, ipercparts, 3, 1)
  ; change the strenghtes of the partials
  iftstrngs = ChangeTable(iftparts, ipercstrs, 3, 0)
  ; calculate the resulting function table
  iftsound = ftgen(0, 0, 4096, 34, iftstrngs, 7, 1)
  asound   = oscili(aenv, afreq, iftsound)
  ; choose random value for freeverb's roomsize
  iromsiz = random(.5, .9)
  aL, aR freeverb asound, asound, iromsiz, .5  ; apply reverb
  out(aL, aR)                                  ; send sound out


  ; ;Generate important information for the user
  if gicount == 0 then  ; at the first time use these values
    ithanks    = 11
    isavery    = 21
    isatotally = 23
  else  ; at following times use random choices
    ithanks    = RandInts_i(11, 15)
    isavery    = RandInts_i(21, 28)
    isatotally = RandInts_i(21, 28)
  endif
  gicount = gicount + 1          ; for knowing it's now the second time
  ichr    = p4                   ; ascii code for actual character
  ispeed  = p3/36                ; speed
  Schar   = sprintf("%c", ichr)  ; string with the typed character
  Sascii  = sprintf("%d", ichr)  ; string with the ascii code

  Sthanks  = strget(ithanks)
  Sisavery = strget(isavery)
  Sisavery = strcat(Sisavery, " character.")

  Sisatotally = strget(isatotally)
  if isatotally == isavery then
    Sisatotally = strcat(Sisatotally, " number, too.")
  else
    Sisatotally = strcat(Sisatotally, " number.")
  endif

  ; ;Show sequential output
  ishow = ispeed/4  ; speed of progression
  ; call i 20 at the different starting times
  S1  = sprintf("i 20 %f 1 1 \" %s\"", ishow, Sthanks)
  S2  = sprintf("i 20 %f 1 2 \" \"", ishow*10)
  S3  = sprintf("i 20 %f 1 3 \" %s\"", ishow*20, Schar)
  S4  = sprintf("i 20 %f 1 4 \" \"", ishow*35)
  S5  = sprintf("i 20 %f 1 5 \" \"", ishow*50)
  S6  = sprintf("i 20 %f 1 6 \" %s\"", ishow*60, Sascii)
  S7  = sprintf("i 20 %f 1 7 \" \"", ishow*65)
  S8  = sprintf("i 20 %f 1 8 \" \"", ishow*90)
  S9  = sprintf("i 20 %f 1 9 \" %s\"", ishow*150, Schar)
  S10 = sprintf("i 20 %f 1 10 \" %s\"", ishow*160, Sisavery)
  S11 = sprintf("i 20 %f 1 11 \" \"", ishow*180)
  S12 = sprintf("i 20 %f 1 12 \" %s\"", ishow*210, Sascii)
  S13 = sprintf("i 20 %f 1 13 \" %s\"", ishow*230, Sisatotally)
  scoreline_i S1
  scoreline_i S2
  scoreline_i S3
  scoreline_i S4
  scoreline_i S5
  scoreline_i S6
  scoreline_i S7
  scoreline_i S8
  scoreline_i S9
  scoreline_i S10
  scoreline_i S11
  scoreline_i S12
  scoreline_i S13
endin

instr 20  ; send text
  ichannel = p4
  Stext    = p5
  if ichannel == 1 then
    chnset(Stext, "thanks")
  elseif ichannel == 2 then
    chnset("You typed the character", "youtyped")
  elseif ichannel == 3 then
    chnset(Stext, "showchar1")
  elseif ichannel == 4 then
    chnset(".", ".")
  elseif ichannel == 5 then
    chnset("The ASCII code of this character is", "ascii1")
  elseif ichannel == 6 then
    chnset(Stext, "showascii1")
  elseif ichannel == 7 then
    chnset("!", "!")
  elseif ichannel == 8 then
    chnset("As you will certainly have heard by the unique tone which is presented here for the first time as the result of long research from all times and cultures at least on earth", "asyouwill")
  elseif ichannel == 9 then
    chnset(Stext, "showchar2")
  elseif ichannel == 10 then
    chnset(Stext, "isavery")
  elseif ichannel == 11 then
    chnset("The number, which for many reasons is specially related to this character, ", "theby")
  elseif ichannel == 12 then
    chnset(Stext, "showascii2")
  elseif ichannel == 13 then
    chnset(Stext, "isatotally")
  endif
  turnoff
endin

</CsInstruments>
<CsScore>
i 2 0 1
i 1 0 36000  ; spend 10 hours in profund research and listen to the voice of the truth
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
 <bsbObject type="BSBDisplay" version="2">
  <objectName>showascii1</objectName>
  <x>359</x>
  <y>326</y>
  <width>49</width>
  <height>33</height>
  <uuid>{a55e0ce0-8c52-4047-bf13-0b1ba20e7fab}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>showchar1</objectName>
  <x>359</x>
  <y>288</y>
  <width>31</width>
  <height>30</height>
  <uuid>{8532d68c-d5df-4af5-b42c-112356c3b1c6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label> 3</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>typein1</objectName>
  <x>119</x>
  <y>184</y>
  <width>102</width>
  <height>49</height>
  <uuid>{46574579-d664-4984-87d8-c253e399baac}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>30</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>typein2</objectName>
  <x>223</x>
  <y>183</y>
  <width>103</width>
  <height>49</height>
  <uuid>{87b2b136-82f1-40b7-9039-e8e77395e512}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>30</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>thanks</objectName>
  <x>62</x>
  <y>242</y>
  <width>394</width>
  <height>33</height>
  <uuid>{0752771e-37c3-49e2-b666-f2b41a1c5bcf}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label> My goodness!</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>youtyped</objectName>
  <x>79</x>
  <y>290</y>
  <width>275</width>
  <height>30</height>
  <uuid>{69c3c6d8-c4c0-4b64-a861-35735d0fcae0}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>You typed the character</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>asyouwill</objectName>
  <x>65</x>
  <y>374</y>
  <width>391</width>
  <height>76</height>
  <uuid>{027dd6d8-79fe-4004-a52b-9205a9a8d176}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>As you will certainly have heard by the unique tone which is presented here for the first time as the result of long research from all times and cultures at least on earth</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>ascii1</objectName>
  <x>82</x>
  <y>328</y>
  <width>275</width>
  <height>30</height>
  <uuid>{1b8bc0dc-fc3c-4f85-b5a0-f041d7b5db79}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The ASCII code of this character is</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>showchar2</objectName>
  <x>96</x>
  <y>451</y>
  <width>38</width>
  <height>30</height>
  <uuid>{3dc69a6f-7567-4667-ad9e-c938ae55d612}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>isavery</objectName>
  <x>137</x>
  <y>453</y>
  <width>275</width>
  <height>30</height>
  <uuid>{78ff5969-7917-4dba-afe9-507d6124be33}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>isatotally</objectName>
  <x>139</x>
  <y>546</y>
  <width>275</width>
  <height>30</height>
  <uuid>{2b58f46d-0510-439e-a835-9fed0d30f81e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label> is a rather useless number.</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>theby</objectName>
  <x>66</x>
  <y>492</y>
  <width>382</width>
  <height>47</height>
  <uuid>{ca22476a-8dc2-4288-912f-4cfa3cf1eb6f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>The number, which for many reasons is specially related to this character, </label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>showascii2</objectName>
  <x>78</x>
  <y>544</y>
  <width>59</width>
  <height>33</height>
  <uuid>{a9301c1b-f6c8-4a21-af60-f8ee6557ada2}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label> 117</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>.</objectName>
  <x>375</x>
  <y>290</y>
  <width>41</width>
  <height>30</height>
  <uuid>{43373687-936d-468d-9260-f7396ab1061c}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label/>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>!</objectName>
  <x>393</x>
  <y>328</y>
  <width>41</width>
  <height>30</height>
  <uuid>{81764181-1f22-48a4-9a9a-293419d282b1}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>!</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>49</x>
  <y>16</y>
  <width>721</width>
  <height>41</height>
  <uuid>{041fe329-d209-4e3d-ad7a-56e9abf09631}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Get the ASCII Code of a Character</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>22</fontsize>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>48</x>
  <y>55</y>
  <width>722</width>
  <height>58</height>
  <uuid>{6a149d69-516e-49ac-8253-16e048b92ceb}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>And learn a lot more about the symbolic function of characters and numbers.
This can be very important for your future life.</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>18</fontsize>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>47</x>
  <y>112</y>
  <width>724</width>
  <height>48</height>
  <uuid>{98fcf679-a848-4a34-996b-9ce180492cb6}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>First, select your personal speed at the slider on the right.
Then, press the Start button.</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>speed</objectName>
  <x>514</x>
  <y>222</y>
  <width>259</width>
  <height>27</height>
  <uuid>{05335d5c-63bc-43c9-80fb-d041d424167b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.10000000</minimum>
  <maximum>2.00000000</maximum>
  <value>1.00965251</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>513</x>
  <y>192</y>
  <width>260</width>
  <height>25</height>
  <uuid>{79ee3261-6f9b-4714-9126-bba72b4d5d3b}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Select Your Personal Speed of Messages</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>12</fontsize>
  <padding>5</padding>
  <locked>false</locked>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>age</objectName>
  <x>514</x>
  <y>277</y>
  <width>259</width>
  <height>97</height>
  <uuid>{e0e9bba2-2adf-4981-af08-9bd45d2be198}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Age estimated from your speed selection:
37 years, 10 months, 10 days.</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <padding>5</padding>
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
  <bordercolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bordercolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Play</objectName>
  <x>513</x>
  <y>373</y>
  <width>261</width>
  <height>28</height>
  <uuid>{0ad23d88-6832-4d56-8ca4-b3ecac93a75e}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Start</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
  <flatStyle>false</flatStyle>
  <color>
   <r>12</r>
   <g>12</g>
   <b>12</b>
  </color>
  <pressedColor>#3c3c3c</pressedColor>
  <borderColor>#525252</borderColor>
  <textColor>#dfdfdf</textColor>
  <pressedTextColor/>
  <borderWidth>1</borderWidth>
  <borderRadius>3</borderRadius>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

<CsoundSynthesizer>
<CsOptions>
-odac
-m0
</CsOptions>
<CsInstruments>

/*
 
Dependencies: 
  plugins: klib, else
*/

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

gi_refreshRate = 20

opcode makeCircBuffer, i, i
  idur xin
  ; quantize table length to ksmps
  inumsamples = ceil(sr*idur / ksmps) * ksmps
  itable = ftgen(0, 0, inumsamples, 2, 0)
  iobj = dict_new("str:float", "table", itable, "writePointer", 0, "readPointer", 0, "recDur", 0)
  xout iobj 
endop

instr recCircBuffer
  ibuf, ichan passign 4
  itab = dict_get:i(ibuf, "table")
  itablen = ftlen(itab)
  imaxdur = itablen / sr
  ftset itab, 0
  ktime = timeinsts()
  asig = inch(ichan)
  aindex = accum:a(1) % itablen
  tablew asig, aindex, itab
  
  if lastcycle() == 1 then
    ; stop recording
    dict_set ibuf, "recDur", min(ktime, imaxdur)
    kwritePointer = aindex[ksmps-1]
    dict_set ibuf, "writePointer", kwritePointer
    dict_set ibuf, "readPointer", ktime < imaxdur ? 0 : kwritePointer
  endif
endin

instr playCircBuffer
  ibuf, ispeed, ichan passign 4
  idur    dict_get ibuf, "recDur"
  itab    dict_get ibuf, "table"
  ioffset dict_get ibuf, "readPointer"
  ifade = 0.08
  asig table3 line:a(0, idur/ispeed, idur*sr), itab, 0, ioffset, 1
  asig *= linsegr:a(0, ifade, 1, ifade, 0)
  outch ichan, asig
  if timeinsts() > idur/ispeed - ifade - 2*ksmps/sr then
    turnoff2 p1, 4, 1
  endif
endin

opcode toggleInstr, 0, SkiOOOOOO
  Sname, kgate, idt, kp4, kp5, kp6, kp7, kp8, kp9 xin
  if changed2(kgate) == 0 kgoto skip
  if kgate == 1 then
    schedulek Sname, idt, -1, kp4, kp5, kp6, kp7, kp8, kp9
  else
    turnoff2 Sname, 0, 1
  endif
skip:
endop

instr main
  ; a circular buffer with a max. recording duration of 20 secs
  ibuf = makeCircBuffer(20)
  if timeinstk() == 1 then
    outvalue "plot", sprintf("@set %d",dict_get:i(ibuf, "table"))
  endif
  krec invalue "record"
  kplay = 1 - krec
  
  toggleInstr "recCircBuffer",  krec,  0,    ibuf, 1
  toggleInstr "playCircBuffer", kplay, 0.01, ibuf, /*speed*/ 1, /*outchannel*/ 1
  
  if metro(gi_refreshRate) == 1 then
    outvalue "plot", "@update"
  endif 
endin

schedule "main", 0, -1

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>610</width>
 <height>288</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBButton">
  <objectName>record</objectName>
  <x>12</x>
  <y>12</y>
  <width>80</width>
  <height>80</height>
  <uuid>{b8ffa76d-0f30-4672-a916-b7fd3942830f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>REC</text>
  <image>/</image>
  <eventLine>i1 0 -1</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>30</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBTableDisplay">
  <objectName>plot</objectName>
  <x>12</x>
  <y>97</y>
  <width>598</width>
  <height>191</height>
  <uuid>{773494f8-6777-408a-89a3-0e7ad186ebda}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <color>
   <r>255</r>
   <g>193</g>
   <b>3</b>
  </color>
  <range>1.00</range>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

/* Getting started.. File Output

Now we are going to write an audiofile to hardisk. 
The easiest way, is pressing the red "Record" button in the menu-bar.

But when automating the process (eg. for sound-installations), it is useful 
to trigger the process from Csound and give each recorded file a unique name. 
In this case date and time fits best.

The date information is stored into a stringvariable. This string becomes 
included into the file name. 

Make sure you save this file first to a known location, as the audio file will be created in the same directory as the running file, and if you haven't saved the example, this could be anywhere!

Manipulation of strings, see in manual: -> Opcodes Overview -> Strings ( StringsTop )
*/
<CsoundSynthesizer>
<CsInstruments>
ksmps = 64

instr 1
  ; generate a testtone
  iAmp  = 10000
  kFreq = line(p4, 3, p5)
  asig  = poscil3(iAmp, kFreq, 1)
  out asig
  ; prepare writing the audiofile with it's unique name
  Sdate = dates(-1)  ; Returns date and time as a string but including the weekday
  ; extract useful information from the string
  Stime  = strsub(Sdate, 10, 19)  ; cut the time information
  Shour  = strsub(Stime, 1, 3)
  Smin   = strsub(Stime, 4, 6)
  Ssec   = strsub(Stime, 7, 9)
  Syear  = strsub(Sdate, 19, 24)  ; cut the year information
  Sday   = strsub(Sdate, 8, 10)   ; cut the day information
  Smonth = strsub(Sdate, 4, 7)    ; cut the month information
  ; create a unique filename as stringvariable
  SfileName = sprintf("%s-%s-%s-%s_%s_%s-sweep.aiff", Syear, Smonth, Sday, Shour, Smin, Ssec)
  puts SfileName, 1        ; output the filename to the console for checking
  fout SfileName, 2, asig  ; write the audio-file to disk
endin


</CsInstruments>
<CsScore>
f 1 0 1024 10 1

i 1 0 1 200 500
i 1 3 1 1000 800
i 1 5 1 500 700
e
</CsScore>
</CsoundSynthesizer>
; written by Alex Hofmann (Mar. 2010) - Incontri HMT-Hannover 
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>825</x>
 <y>316</y>
 <width>359</width>
 <height>167</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>137</x>
  <y>55</y>
  <width>80</width>
  <height>25</height>
  <uuid>{31b59d0f-c6d7-4353-b51e-78dec450ad9f}</uuid>
  <widgetName/>
  <visible>true</visible>
  <enabled>true</enabled>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Nothing here...</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>

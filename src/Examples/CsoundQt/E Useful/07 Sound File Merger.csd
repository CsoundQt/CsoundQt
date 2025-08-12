<CsoundSynthesizer>
<CsOptions>
-nm128
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>

/****SOUNDFILE MERGER****
joachim heintz june 2010, aug 2025**/

0dbfs = 1
ksmps = 128 ;if you want to avoid that some samples without sound are added at the end
            ;of the soundfile, use ksmps=1. but this will be slower for large files 

//returns number of Sel in Str
  opcode StrMems, i, SS
Str, Sel   xin 
iSumEls    =          0
iLen       strlen     Str
iIndx      =          0
Sub        strcpy     Str
  until iIndx == iLen do
iPos       strindex   Sub, Sel
   if iPos > -1 then
iSumEls    =          iSumEls+1
Sub        strsub     Sub, iPos+1
iIndx      =          iPos+1
   else
iIndx      =          iLen
   endif
  od
           xout       iSumEls
  endop

// converts _MBrowse output to array
opcode Mbrowse2Array,S[],S
  String xin
  // how many occurrences of | in String
  iNum = StrMems(String,"|")
  // create array for substrings
  Sout[] init iNum+1
  // go through
  istart = 0
  ipos = 0
  indx = 0
  while (ipos >= 0) do
    Substring = strsub(String,istart)
    ipos = strindex(Substring,"|")
    Sname = strsub(Substring,0,ipos)
    Sout[indx] = Sname
    istart += ipos+1
    indx += 1
  od
  xout Sout
endop
  
chn_S("_MBrowse",1)
chn_S("_Browse",1)

instr Main

  // user input
  infiles:S = chnget("_MBrowse") ;filenames, separated by '|'
  
  // convert to array of filenames
  Infiles@global:S[] = Mbrowse2Array(infiles)
 
  // get longest file duration and ensure not to omit samples if ksmps != 1
  file_duration:i init 0
  for i in [0 ... lenarray(Infiles)-1] do
    file_duration = (filelen(Infiles[i]) > file_duration) ? filelen(Infiles[i]) : file_duration
  od
  file_duration = (ksmps == 1) ? file_duration : file_duration + ksmps/sr 

  // create global audio array for the multichannel file
  Outarray@global:a[] init lenarray(Infiles)
    
  // call as many instances of ReadFile as needed
  for i in [0 ... lenarray(Infiles)-1] do
    schedule(ReadFile,0,file_duration,i)
  od
  
  // call instrument to collect the single audio streams and write to disk
  schedule(Collect,0,file_duration)

endin

instr ReadFile

  indx = p4
  Outarray[indx] = diskin:a(Infiles[indx])

endin

instr Collect

  fout(chnget:S("_Browse"),18,Outarray) // change 18 for other output format options
  if release() == 1 then
    printks("File %s with %d channels written to disk!\n",0,chnget:S("_Browse"),lenarray(Infiles))
  endif

endin

</CsInstruments>
<CsScore>
i "Main" 0 .1
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>588</x>
 <y>291</y>
 <width>515</width>
 <height>356</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject type="BSBButton" version="2">
  <objectName>_MBrowse</objectName>
  <x>370</x>
  <y>125</y>
  <width>100</width>
  <height>30</height>
  <uuid>{6d6f3649-5d94-4759-afc8-887cc1872c39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>chn_1.wav|chn_2.wav|chn_3.wav|chn_4.wav|chn_5.wav|chn_6.wav|chn_7.wav</stringvalue>
  <text>Select Files</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_MBrowse</objectName>
  <x>25</x>
  <y>130</y>
  <width>345</width>
  <height>24</height>
  <uuid>{dcd7f769-c32b-4cc8-bc82-9848d5b36937}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>chn_1.wav|chn_2.wav|chn_3.wav|chn_4.wav|chn_5.wav|chn_6.wav|chn_7.wav</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Render</objectName>
  <x>22</x>
  <y>195</y>
  <width>194</width>
  <height>67</height>
  <uuid>{a9b11523-b4f3-419f-8637-88da098e53f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Merge!</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>20</fontsize>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>85</x>
  <y>16</y>
  <width>335</width>
  <height>39</height>
  <uuid>{46df577d-4fc5-4d07-a9cb-08d73733ad30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>SOUNDFILE MERGER</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>24</fontsize>
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
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>20</x>
  <y>60</y>
  <width>445</width>
  <height>60</height>
  <uuid>{e54e17da-3808-49a3-84a6-608f476c3200}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Merges any number of mono files to a multichannel file. </label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>20</fontsize>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse</objectName>
  <x>340</x>
  <y>161</y>
  <width>130</width>
  <height>30</height>
  <uuid>{8e593a62-3225-49f7-b37f-5980f1a6a2e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>merge.wav</stringvalue>
  <text>Select Ouput File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse</objectName>
  <x>23</x>
  <y>164</y>
  <width>315</width>
  <height>25</height>
  <uuid>{afd199cd-e88a-4210-b3e3-8d64c7512872}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>merge.wav</label>
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
   <r>206</r>
   <g>206</g>
   <b>206</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>223</x>
  <y>198</y>
  <width>250</width>
  <height>60</height>
  <uuid>{3dcec24e-7156-4b09-8e27-500884bc65c8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Output format is 24 bit wav.
Change in instrument "Collect" if needed.</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

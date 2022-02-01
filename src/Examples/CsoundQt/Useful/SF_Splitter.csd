<CsoundSynthesizer>
<CsOptions>
-+max_str_len=10000 -n
</CsOptions>
<CsInstruments>

/****SOUNDFILE SPLITTER****
joachim heintz june 2010**/

0dbfs = 1
ksmps = 128; if you want to avoid that some samples without sound are added at the end of the soundfile, use ksmps=1. but this will be slow for large files 
nchnls = 1


instr 1
gSfile		invalue	"_Browse1"
ilen		filelen	gSfile
;as time resolution in csound is bound to ksmps, one control period must be added to avoid omitting samples
p3		=		(ksmps == 1 ? ilen : ilen + ksmps/sr)
inchnls	filenchnls	gSfile
 if inchnls == 2 then
 		event_i	"i", 12, 0, p3
 elseif inchnls == 4 then
 		event_i	"i", 14, 0, p3
 elseif inchnls == 8 then
 		event_i	"i", 18, 0, p3
 else	
 		event_i	"i", 20, 0, .1, inchnls, p3
 endif
endin

instr 12; split stereo file
a1, a2		soundin	gSfile
ibit		filebit	gSfile
ibitform	=		(ibit == 24 ? 8 : (ibit == 32 ? 6 : 4))
iposp		strrindex	gSfile, "."
Spath		strsub		gSfile, 0, iposp; path without suffix
Suff		strsub		gSfile, iposp; suffix
S1		sprintf	"%s_1%s", Spath, Suff
S2		sprintf	"%s_2%s", Spath, Suff
		fout		 S1, ibitform, a1
		fout		 S2, ibitform, a2
endin

instr 14; split quadro file
a1, a2, a3, a4 soundin	gSfile
ibit		filebit	gSfile
ibitform	=		(ibit == 24 ? 8 : (ibit == 32 ? 6 : 4))
iposp		strrindex	gSfile, "."
Spath		strsub		gSfile, 0, iposp; path without suffix
Suff		strsub		gSfile, iposp; suffix
S1		sprintf	"%s_1%s", Spath, Suff
S2		sprintf	"%s_2%s", Spath, Suff
S3		sprintf	"%s_3%s", Spath, Suff
S4		sprintf	"%s_4%s", Spath, Suff
		fout		 S1, ibitform, a1
		fout		 S2, ibitform, a2
		fout		 S3, ibitform, a3
		fout		 S4, ibitform, a4
endin

instr 18; split octo file
a1, a2, a3, a4, a5, a6, a7, a8 soundin gSfile
ibit		filebit	gSfile
ibitform	=		(ibit == 24 ? 8 : (ibit == 32 ? 6 : 4))
iposp		strrindex	gSfile, "."
Spath		strsub		gSfile, 0, iposp; path without suffix
Suff		strsub		gSfile, iposp; suffix
S1		sprintf	"%s_1%s", Spath, Suff
S2		sprintf	"%s_2%s", Spath, Suff
S3		sprintf	"%s_3%s", Spath, Suff
S4		sprintf	"%s_4%s", Spath, Suff
S5		sprintf	"%s_5%s", Spath, Suff
S6		sprintf	"%s_6%s", Spath, Suff
S7		sprintf	"%s_7%s", Spath, Suff
S8		sprintf	"%s_8%s", Spath, Suff
		fout		 S1, ibitform, a1
		fout		 S2, ibitform, a2
		fout		 S3, ibitform, a3
		fout		 S4, ibitform, a4
		fout		 S5, ibitform, a5
		fout		 S6, ibitform, a6
		fout		 S7, ibitform, a7
		fout		 S8, ibitform, a8
endin

instr 20; splits any type of multichannel file. depends on ths system opcode, so it might only work on linux and osx
Sfil		=		gSfile
inchnls	=		p4
ilen		=		p5
ibit		filebit	Sfil
ibitform	=		(ibit == 24 ? 8 : (ibit == 32 ? 6 : 4))
		
;format a .csd file
Scsd1		sprintf	{{
 <CsoundSynthesizer>
 <CsOptions>
 -+max_str_len=10000 -n -i%s
 </CsOptions>
 <CsInstruments>
 0dbfs = 1
 ksmps = %d
 nchnls = %d
  opcode SF_Split, 0, Siii
 Sfile, inchnls, ichn, ibitform xin
 ain		inch		ichn
 iposp		strrindex	Sfile, "."
 Spath		strsub		Sfile, 0, iposp
 Suff		strsub		Sfile, iposp
 Soutnam	sprintf	"%s", Spath, ichn, Suff
		fout		Soutnam, ibitform, ain
 if ichn < inchnls then
		SF_Split	Sfile, inchnls, ichn+1, ibitform
 endif
  endop
 instr 1
		SF_Split	"%s", %d, 1, %d
 endin
 %s
 <CsScore>
 i 1 0 %d
 e
 </CsScore>
 </CsoundSynthesizer>	
		}}, Sfil, ksmps, inchnls, "%s_%d%s", Sfil, inchnls, ibitform, "</CsInstruments>", ilen

;write the file and execute it
Stask		sprintf	{{cat<<EOF>>/tmp/tmp.csd\n%s\nEOF
				/usr/local/bin/csound /tmp/tmp.csd
				rm /tmp/tmp.csd}}, Scsd1
ires		system_i	1, Stask, 1
endin


</CsInstruments>
<CsScore>
i 1 0 1
e
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>524</width>
 <height>263</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Browse1</objectName>
  <x>364</x>
  <y>69</y>
  <width>100</width>
  <height>30</height>
  <uuid>{6d6f3649-5d94-4759-afc8-887cc1872c39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Select File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLineEdit">
  <objectName>_Browse1</objectName>
  <x>17</x>
  <y>72</y>
  <width>345</width>
  <height>24</height>
  <uuid>{dcd7f769-c32b-4cc8-bc82-9848d5b36937}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
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
 <bsbObject version="2" type="BSBButton">
  <objectName>_Render</objectName>
  <x>163</x>
  <y>107</y>
  <width>151</width>
  <height>31</height>
  <uuid>{a9b11523-b4f3-419f-8637-88da098e53f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Split!</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>85</x>
  <y>16</y>
  <width>335</width>
  <height>39</height>
  <uuid>{46df577d-4fc5-4d07-a9cb-08d73733ad30}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>SOUNDFILE SPLITTER</label>
  <alignment>center</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>19</x>
  <y>147</y>
  <width>446</width>
  <height>81</height>
  <uuid>{e54e17da-3808-49a3-84a6-608f476c3200}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Splits any stereo or multichannel soundfile in mono files. Just browse your file and press the Split! button. Find the split files in the same folder as the source file.</label>
  <alignment>center</alignment>
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
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="360" y="248" width="612" height="322" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

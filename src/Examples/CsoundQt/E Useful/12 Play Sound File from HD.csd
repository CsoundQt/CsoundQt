<CsoundSynthesizer>
<CsOptions>
--env:SSDIR+=../../SourceMaterials
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

/*****Play sound file from harddisk with some features*****/
;written by joachim heintz, andres cabrera and victor lazzarini
;mar 2009 / dec 2011 / aug 2025


// software channels
chn_S("_Browse",1)
chn_k("loop",1)
chn_k("skip",1)
chn_k("convertsr",1)
chn_S("message",2)
chn_k("db",1)
chn_k("progressbar",2)
chn_S("hor",2)
chn_S("min",2)
chn_S("sec",2)
chn_S("ms",2)
chn_k("outL",2)
chn_k("outLclip",2)
chn_k("outR",2)
chn_k("outRclip",2)

instr Play

  // GUI input
  file:S = chnget("_Browse")
  loop:i = chnget("loop")
  skip:i = chnget("skip")
  cvrt:i = chnget("convertsr") ;1=yes 0=no
  dB:k = chnget("db")
  
  file_duration:i = filelen(file)
  file_sr:i = filesr(file)
  file_chns:i = filenchnls(file)
  
  // prevent more than one instances to be called (not necessary with latch button, see below)
  instances:i = active("Play")
  if (instances > 1) then
    turnoff2_i("Play",1,0)
  endif
    
  // send a message if the sr of the file doesn't match the sr of the orchestra
  if (file_sr != sr) then
    if (cvrt == 1) then
      warn:S = sprintf("WARNING:\nSamplerate of the file is %d, but samplerate \
        of the orchestra is %d. Samplerate will be converted by changing speed \
        of reading.\n", file_sr, sr)
        ;chnset(warn,"message")
    elseif (cvrt == 0) then
      warn:S = sprintf("WARNING:\nSamplerate of the file is %d, but samplerate \
        of the orchestra is %d. Samplerate will not be converted, so you will \
        have changes in tempo and pitch.\n", file_sr, sr)
        ;chnset(warn,"message")
    else
      warn:S = ""
    endif
  endif
  mess:S = sprintf("FILE INFO:\nLength = %.3f, Samplerate = %d, Channels = %d",file_duration,
    file_sr,file_chns)
    chnset(strcat(warn,mess),"message")
  
  
  aout[] = diskin2(file,1,skip,loop,0,1-cvrt)
  out(aout*ampdb(dB))
  
  // for fun, show progress bar and time
  tsec:k init skip
  	progress:k = (tsec % file_duration)
  	chnset(progress/file_duration,"progressbar")
  	chnset(sprintfk("%02d",int(progress/3600)),"hor")
  	chnset(sprintfk("%02d",int(progress/60)),"min")
  	chnset(sprintfk("%02d",int(progress)),"sec")
  	chnset(sprintfk("%03d",int(frac(progress)*1000)),"ms")
  
  tsec:k += 1/kr

endin

// (actually a latch button could be used to start AND stop.
// but currently (aug 2025) not properly working.)
instr Stop
  turnoff2_i("Play",0,1)
endin


//UDO for displaying an audio signal in widgets
opcode CsQtMeter, 0, SSak ;see https://github.com/csudo/csudo/blob/master/csqt/CsQtMeter.csd
 S_chan_sig, S_chan_clip, aSig, kTrig	xin
 iDbRange = 60 ;shows 60 dB
 iHoldTim = 1 ;seconds to "hold the red light"
 kOn init 0
 kTim init 0
 kStart init 0
 kEnd init 0
 kMax max_k aSig, kTrig, 1
 if kTrig == 1 then
  chnset (iDbRange + dbfsamp(kMax)) / iDbRange, S_chan_sig
  if kOn == 0 && kMax > 1 then
   kTim = 0
   kEnd = iHoldTim
   chnset k(1), S_chan_clip
   kOn = 1
  endif
  if kOn == 1 && kTim > kEnd then
   chnset k(0), S_chan_clip
   kOn =	0
  endif
 endif
 kTim += ksmps/sr
endop

// show the first two output channels (although you can play
// back any number of channels if you change nchnls in the header)
instr Monitor

  aOut[] = monitor()
  display_trigger:k = metro(10)
  CsQtMeter("outL","outLclip",aOut[0],display_trigger)
  CsQtMeter("outR","outRclip",aOut[1],display_trigger)

endin
schedule(Monitor,0,-1)

/*


instr 4
ilen		=		gilen
ilenk		=		ilen * kr; duration of the file in k-cycles
ichn		=		gichn
gkdb		invalue	"db"; gain value in dB
kskip	invalue	"skip"; skiptime in sec
iskip		=		i(kskip)
itimi10k	=		i(gktimi10k) % ilenk; time instr 10 was active in control cycles in respect to the loops
kloop	invalue	"loop"; value 1 if checked
iloop		=		i(kloop)
istart		=		iskip + (itimi10k / kr)

;playing
iplaylen	=		(iloop == 1 ? p3 : ilen)
   
		event_i	"i", 10, 0, iplaylen, istart, ichn, giconvrt

   ;time output
ktimout	=		(gktimi10k / kr + iskip) % ilen; position in the soundfile in seconds
ktimouthor	=		int(ktimout / 3600)
Shor		sprintfk	"%02d", ktimouthor
ktimoutmin	=		int(ktimout / 60)
Smin		sprintfk	"%02d", ktimoutmin
ktimoutsec	=		int(ktimout % 60)
Ssec		sprintfk	"%02d", ktimoutsec
ktimoutms	=		frac(ktimout) * 1000
Sms		sprintfk	"%03d", ktimoutms
		outvalue	"hor", Shor
		outvalue	"min", Smin
		outvalue	"sec", Ssec
		outvalue	"ms", Sms

   ;turnoff if no loop and end of file is reached
  if iloop == 0 && ktimout > ilen then
		event		"i", 1, 0, .1
		turnoff
  endif
endin


instr 10
iskip	=		p4
ichn		=		p5
iconvrt	=		(p6 == 1 ? 0 : 1)
k1 = 1

kdbrange	invalue	"dbrange"  ;dB range for the meters
kpeakhold	invalue	"peakhold"  ;Duration of clip indicator hold in seconds;
	if ichn == 1 then
aL		diskin2	gSfile, 1, iskip, 1, 0, iconvrt
aR		=		aL
	else
printk2  k1
aL, aR	diskin2	gSfile, 1, iskip, 1, 0, iconvrt
	endif

   ;Volume
kmult		=		ampdbfs(gkdb)
Sdb_disp	sprintfk	"%+.2f dB", gkdb
		outvalue	"db_disp", Sdb_disp
aL		=		aL * kmult
aR		=		aR * kmult

   ;show output
kTrigDisp	metro		10
		ShowLED_a		"outL", aL, kTrigDisp, 1, kdbrange
		ShowLED_a		"outR", aR, kTrigDisp, 1, kdbrange
		ShowOver_a	"outLover", aL, kTrigDisp, kpeakhold
		ShowOver_a	"outRover", aR, kTrigDisp, kpeakhold

		outs		aL, aR
gktimi10k	=		gktimi10k + 1; count the time instr 10 was active
endin

*/

</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>








<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>556</width>
 <height>680</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>129</r>
  <g>170</g>
  <b>164</b>
 </bgcolor>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Browse</objectName>
  <x>378</x>
  <y>111</y>
  <width>100</width>
  <height>30</height>
  <uuid>{f8cc5a8e-5d74-4e6a-b0ef-14b3536bee69}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>ClassicalGuitar.wav</stringvalue>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>db</objectName>
  <x>117</x>
  <y>262</y>
  <width>136</width>
  <height>31</height>
  <uuid>{10f84ac4-d6cc-468a-87f8-92cf47247d27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-18.00000000</minimum>
  <maximum>18.00000000</maximum>
  <value>-1.85294118</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName/>
  <x>20</x>
  <y>148</y>
  <width>80</width>
  <height>28</height>
  <uuid>{c0de047a-de03-4e6d-a942-b71b2821460d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Play</text>
  <image>/</image>
  <eventLine>i "Play" 0 999999</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName/>
  <x>221</x>
  <y>148</y>
  <width>80</width>
  <height>28</height>
  <uuid>{539bf852-6d92-4e53-a7ce-a478772c8a44}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine>i "Stop" 0 0</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>skip</objectName>
  <x>21</x>
  <y>216</y>
  <width>87</width>
  <height>25</height>
  <uuid>{d697a9c4-6c99-4f8a-b884-8d537fc7a24b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>12</fontsize>
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
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>_Pause</objectName>
  <x>120</x>
  <y>148</y>
  <width>80</width>
  <height>28</height>
  <uuid>{ae8f2ca0-5960-4a9b-853d-22682c1c7916}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Pause</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>12</fontsize>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>loop</objectName>
  <x>152</x>
  <y>216</y>
  <width>20</width>
  <height>25</height>
  <uuid>{855b6884-ed0d-41cc-9a8d-0f3c0315c598}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>min</objectName>
  <x>344</x>
  <y>345</y>
  <width>35</width>
  <height>32</height>
  <uuid>{e1155724-576d-4aae-8754-ae799eb0c75f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>00</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>0</precision>
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
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>sec</objectName>
  <x>391</x>
  <y>345</y>
  <width>35</width>
  <height>32</height>
  <uuid>{6058c806-9a20-44fa-8bf8-90de2a58b2df}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>03</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>18</fontsize>
  <precision>0</precision>
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
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>379</x>
  <y>345</y>
  <width>14</width>
  <height>32</height>
  <uuid>{e9e4b8b3-f548-4ced-919a-5f6c720396f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>:</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>21</x>
  <y>190</y>
  <width>88</width>
  <height>30</height>
  <uuid>{bd6fb429-6df6-4f5a-8c1c-4f6dc140ba25}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>skiptime</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>130</x>
  <y>190</y>
  <width>59</width>
  <height>30</height>
  <uuid>{7a8c2d5d-63af-4119-a8fe-ef9729ae54d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>loop</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>22</x>
  <y>261</y>
  <width>88</width>
  <height>30</height>
  <uuid>{aa0fbe1b-dc9c-4327-aea7-150a02671a6c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>volume</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>message</objectName>
  <x>25</x>
  <y>485</y>
  <width>463</width>
  <height>136</height>
  <uuid>{060268f7-354f-4607-9414-e03dde72fec9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>WARNING:
Samplerate of the file is 44100, but samplerate         of the orchestra is 48000. Samplerate will be converted by changing speed         of reading.
FILE INFO:
Length = 20.088, Samplerate = 44100, Channels = 2</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>217</r>
   <g>217</g>
   <b>217</b>
  </bgcolor>
  <bordermode>true</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>25</x>
  <y>450</y>
  <width>460</width>
  <height>35</height>
  <uuid>{6f1c335f-3050-4a5f-9064-b548712251e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Messages</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>outL</objectName>
  <x>24</x>
  <y>328</y>
  <width>250</width>
  <height>19</height>
  <uuid>{e53212e6-26b1-4255-8dd1-29982a5f376d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out1_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.82915518</xValue>
  <yValue>0.57894700</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>outLclip</objectName>
  <x>271</x>
  <y>328</y>
  <width>21</width>
  <height>19</height>
  <uuid>{1ac98e63-ff22-42c2-b9b4-211a3387ff55}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>outLclip</objectName2>
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
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>outR</objectName>
  <x>24</x>
  <y>355</y>
  <width>250</width>
  <height>19</height>
  <uuid>{5cbb1b94-11b9-40e7-9138-067e4f80499c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.84721845</xValue>
  <yValue>1.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>outRclip</objectName>
  <x>271</x>
  <y>355</y>
  <width>21</width>
  <height>19</height>
  <uuid>{b7f5355c-78ed-416f-ac68-29ae4c154f8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>outRclip</objectName2>
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
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>convertsr</objectName>
  <x>224</x>
  <y>216</y>
  <width>20</width>
  <height>25</height>
  <uuid>{57f660c3-d691-455f-adc2-8dc2b9ad37dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>202</x>
  <y>190</y>
  <width>62</width>
  <height>30</height>
  <uuid>{3c00cb24-4168-42b6-9712-2c3b164a713f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>convert</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>hor</objectName>
  <x>300</x>
  <y>345</y>
  <width>35</width>
  <height>32</height>
  <uuid>{87ddb84f-bf28-4d96-873e-a0c53debc142}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>00</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>18</fontsize>
  <precision>0</precision>
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
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>ms</objectName>
  <x>437</x>
  <y>345</y>
  <width>44</width>
  <height>32</height>
  <uuid>{8779b080-2fdf-4bbe-bf88-7ae8b8498fa6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>998</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Noto Sans</font>
  <fontsize>18</fontsize>
  <precision>0</precision>
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
  <borderradius>0</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>333</x>
  <y>345</y>
  <width>14</width>
  <height>32</height>
  <uuid>{9984c1e1-e917-4c01-83ab-2abc74e18727}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>:</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>424</x>
  <y>345</y>
  <width>14</width>
  <height>32</height>
  <uuid>{12212202-7a08-49ad-ab9a-a782c1cc583f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>:</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>299</x>
  <y>320</y>
  <width>39</width>
  <height>29</height>
  <uuid>{cb2a8386-7d8a-48dc-9054-c28ee0f3f3a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>hh</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>344</x>
  <y>320</y>
  <width>39</width>
  <height>29</height>
  <uuid>{f0b3453f-2fed-4ad0-9770-5b4f474bb9c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>min</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>390</x>
  <y>320</y>
  <width>39</width>
  <height>29</height>
  <uuid>{072b078f-ff66-412c-acf3-e3d3947ef197}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>sec</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>439</x>
  <y>320</y>
  <width>39</width>
  <height>29</height>
  <uuid>{f1be4380-79a4-40f9-a994-cef2cee3b3c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>ms</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>277</x>
  <y>190</y>
  <width>191</width>
  <height>66</height>
  <uuid>{39ddd5a0-7219-4007-b12b-0c8269b25eab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>(sample rate conversion if the sr of the file doesn't match the sr of the orchestra)</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>49</x>
  <y>18</y>
  <width>398</width>
  <height>43</height>
  <uuid>{b6052bac-c509-4ba4-bcea-1249daef98d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>SOUNDFILE PLAYER</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
  <font>Lucida Grande</font>
  <fontsize>26</fontsize>
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
  <x>48</x>
  <y>60</y>
  <width>398</width>
  <height>43</height>
  <uuid>{45328377-9c80-4d16-b4fa-470ce623a64f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>(playing from hard disk)</label>
  <alignment>center</alignment>
  <valignment>top</valignment>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLineEdit" version="2">
  <objectName>_Browse</objectName>
  <x>19</x>
  <y>113</y>
  <width>351</width>
  <height>23</height>
  <uuid>{e34d9fad-e494-4adc-a38c-41fd0dd4cd22}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>ClassicalGuitar.wav</label>
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
   <r>242</r>
   <g>241</g>
   <b>240</b>
  </bgcolor>
  <background>nobackground</background>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>db</objectName>
  <x>256</x>
  <y>266</y>
  <width>60</width>
  <height>29</height>
  <uuid>{f4444d63-4370-445f-b80f-43c400b463c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>Liberation Sans</font>
  <fontsize>16</fontsize>
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
  <minimum>-100</minimum>
  <maximum>18</maximum>
  <randomizable group="0">false</randomizable>
  <value>-1.85294</value>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>315</x>
  <y>268</y>
  <width>39</width>
  <height>29</height>
  <uuid>{71259b28-fa5e-431e-977a-9cb3ca0c488e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>dB</label>
  <alignment>center</alignment>
  <valignment>center</valignment>
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
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject type="BSBController" version="2">
  <objectName>progressbar</objectName>
  <x>25</x>
  <y>403</y>
  <width>463</width>
  <height>30</height>
  <uuid>{0000f5bd-f63d-4038-8718-ec35cd866db9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>meter35</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.19905496</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00ff00</borderColor>
  <color>
   <r>192</r>
   <g>97</g>
   <b>203</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>30</r>
   <g>30</g>
   <b>30</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>

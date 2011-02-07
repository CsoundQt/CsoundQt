<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;example for qutecsound
;joachim heintz
;2nd version feb 2011

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

;;initialize vbap setup (in total 15 speakers for the different configurations)
;speaker number:   1    2     3  4     5   6     7   8      9    10      11      12    13      14   15
vbaplsinit 2, 15, -45, -22.5, 0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5, -157.5, -135, -112.5, -90, -67.5
;note that the method applied here is not really as it should. 
;it's just used for being able to switch between the different configurations.
;actually, you should have the following setups:
;quadro: vbaplsinit 2, 4, -45, 45, 135, -135
;5.0: vbaplsinit 2, 5, -45, 0, 45, 135, -135
;octo: vbaplsinit 2, 8, -22.5, 22.5, 67.5, 112.5, 157.5, -157.5, -112.5, -67.5

  opcode XYToDegr, kk, kko
;transforms the xy values in the range 0-1 (for instance from a qutecsound controller widget) to degrees (anticlockwise or clockwise) and returns the radius in relation to the middle point
kx, ky, idir xin; idir=0 (default): anticlockwise; any other value = clockwise
ka		=	kx - 0.5
kb		=	ky - 0.5
krad		=	sqrt(ka*ka + kb*kb)
kazi_cos	=	cosinv(kb/krad)
kazi_rad	=	(kx < 0.5 ? kazi_cos : 2*$M_PI-kazi_cos); radians
kazi_degr	=	(kazi_rad / (2*$M_PI)) * 360; degrees anticlockwise
kdegr		=	(idir == 0 ? kazi_degr : 360 - kazi_degr)
		xout	kdegr, krad
  endop
  
  opcode FilePlay1, a, Skii
;gives mono output regardless your soundfile is mono or stereo
;(if stereo, just the first channel is used)
Sfil, kspeed, iskip, iloop	xin
ichn		filenchnls	Sfil
if ichn == 1 then
aout		diskin2	Sfil, kspeed, iskip, iloop
else
aout, ano	diskin2	Sfil, kspeed, iskip, iloop
endif
		xout		aout
  endop

	opcode	ShowLED_a, 0, Sakkk
;Shows an audio signal in an outvalue channel.
;You can choose to show the value in dB or in raw amplitudes.
;
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;kdb: 1 = show in dB, 0 = show in raw amplitudes (both in the range 0-1)
;kdbrange: if kdb=1: how many db-steps are shown (e.g. if 36 you will not see anything from a signal below -36 dB)
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
;Shows if the incoming audio signal was more than 1 and stays there for some time
;Input:
;Soutchan: string with the name of the outvalue channel
;asig: audio signal which is to displayed
;kdispfreq: refresh frequency (Hz)
;khold: time in seconds to "hold the red light"
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



instr 1
;;gui input
kconfig	invalue	"config"
kmethod	invalue	"method"
Sfile		invalue	"_Browse1"
kchn1		invalue	"chn1"
kchn2		invalue	"chn2"
kchn3		invalue	"chn3"
kchn4		invalue	"chn4"
kchn5		invalue	"chn5"
kchn6		invalue	"chn6"
kchn7		invalue	"chn7"
kchn8		invalue	"chn8"
kx		invalue	"x"
ky		invalue	"y"
kloop		invalue	"loop"
kgaindb	invalue	"gaindb"
kinsel		invalue	"inputsel"
kinchan	invalue	"inchan"
kgaindblive	invalue	"gaindblive"
kTrigDisp	metro		10

;;audio signal
 if kinsel == 0 then ;sound file input
ifilvld	filevalid	Sfile
  if ifilvld == 1 then
iloop		=		i(kloop)
asound		FilePlay1	Sfile, 1, 0, iloop
asound		=		asound * ampdb(kgaindb)
  else
  		printf_i	"Can't open '%s'! File ignored.\n", 1, Sfile
  endif
 elseif kinsel == 1 then ;live input
ain		inch		kinchan
asound		=		ain * ampdb(kgaindblive)
		ShowLED_a	"livein", asound, kTrigDisp, 1, 48
		ShowOver_a	"liveinover", asound, kTrigDisp, 1
  else 			;noise / test signal
asound		pinkish	.25
 endif
 
;;show input values
Sdbout		sprintfk	"%+d dB", kgaindb
		outvalue	"dbout", Sdbout
Sdboutlive	sprintfk	"%+d dB", kgaindblive
		outvalue	"dboutlive", Sdboutlive

;;transform xy controller output to angle and radius
kazi, kradius XYToDegr 	kx, ky

;;calculate vbap and route vbap output
 if kmethod == 0 then
kazi		=		360 - kazi
kspread	=		100 - kradius * 150
  if kconfig == 0 then; stereo uses speaker 14 and 7 of vbaplsinit setup
a0,a0,a0,a0,a0,a0,a2,a0,a0,a0,a0,a0,a0,a1,a0,a0 vbap16 asound, kazi, 0, kspread
a3		=		0
a4		=		0
a5		=		0
a6		=		0
a7		=		0
a8		=		0
  elseif kconfig == 1 then; quadro uses speakers 1, 5, 9, 12 of vbaplsinit setup
a1,a0,a0,a0,a2,a0,a0,a0,a3,a0,a0,a4,a0,a0,a0,a0 vbap16 asound, kazi, 0, kspread
a5		=		0
a6		=		0
a7		=		0
a8		=		0
  elseif kconfig == 2 then; 5.0 uses speakers 2, 3, 4, 10, 11 of vbaplsinit setup
a0,a1,a2,a3,a0,a0,a0,a0,a0,a4,a5,a0,a0,a0,a0,a0 vbap16 asound, kazi, 0, kspread
a6		=		0
a7		=		0
a8		=		0
  else				;octo uses speakers 2,4,6,8,10,11,13,15 of vbaplsinit setup
a0,a1,a0,a2,a0,a3,a0,a4,a0,a5,a6,a0,a7,a0,a8,a0 vbap16 asound, kazi, 0, kspread
  endif
 
;;calculate ambisonics and route output
 elseif kmethod == 1 then; first order
aw, ax, ay, az bformenc1 asound, kazi, 0
  if kconfig == 0 then; stereo 
a1, a2		bformdec1	1, aw, ax, ay, az
a3		=		0
a4		=		0
a5		=		0
a6		=		0
a7		=		0
a8		=		0
  elseif kconfig == 1 then; quadro 
a1, a4, a3, a2 bformdec1	2, aw, ax, ay, az
a5		=		0
a6		=		0
a7		=		0
a8		=		0
  elseif kconfig == 2 then; 5.0 
a1, a3, a2, a5, a4 bformdec1 3, aw, ax, ay, az
a6		=		0
a7		=		0
a8		=		0
  elseif kconfig == 3 then; octo 
a1, a8, a7, a6, a5, a4, a3, a2 bformdec1 4, aw, ax, ay, az
  endif
 elseif kmethod == 2 then; second order
aw, ax, ay, az, ar, as, at, au, av bformenc1 asound, kazi, 0
  if kconfig == 0 then; stereo 
a1, a2		bformdec1	1, aw, ax, ay, az, ar, as, at, au, av
a3		=		0
a4		=		0
a5		=		0
a6		=		0
a7		=		0
a8		=		0
  elseif kconfig == 1 then; quadro 
a1, a4, a3, a2 bformdec1	2, aw, ax, ay, az, ar, as, at, au, av
a5		=		0
a6		=		0
a7		=		0
a8		=		0
  elseif kconfig == 2 then; 5.0 
a1, a3, a2, a5, a4 bformdec1 3, aw, ax, ay, az, ar, as, at, au, av
a6		=		0
a7		=		0
a8		=		0
  elseif kconfig == 3 then; octo 
a1, a8, a7, a6, a5, a4, a3, a2 bformdec1 4, aw, ax, ay, az, ar, as, at, au, av
  endif
 elseif kmethod == 3 then; third order
aw, ax, ay, az, ar, as, at, au, av, ak, al, am, an, ao, ap, aq bformenc1 asound, kazi, 0
  if kconfig == 0 then; stereo 
a1, a2		bformdec1	1, aw, ax, ay, az, ar, as, at, au, av, ak, al, am, an, ao, ap, aq
a3		=		0
a4		=		0
a5		=		0
a6		=		0
a7		=		0
a8		=		0
  elseif kconfig == 1 then; quadro 
a1, a4, a3, a2 bformdec1	2, aw, ax, ay, az, ar, as, at, au, av, ak, al, am, an, ao, ap, aq
a5		=		0
a6		=		0
a7		=		0
a8		=		0
  elseif kconfig == 2 then; 5.0 
a1, a3, a2, a5, a4 bformdec1 3, aw, ax, ay, az, ar, as, at, au, av, ak, al, am, an, ao, ap, aq
a6		=		0
a7		=		0
a8		=		0
  elseif kconfig == 3 then; octo 
a1, a8, a7, a6, a5, a4, a3, a2 bformdec1 4, aw, ax, ay, az, ar, as, at, au, av, ak, al, am, an, ao, ap, aq
  endif
 endif

;;send audio out
outch kchn1, a1, kchn2, a2, kchn3, a3, kchn4, a4, kchn5, a5, kchn6, a6, kchn7, a7, kchn8, a8
 
;;show azi and spread
		outvalue	"spr", kspread
		outvalue	"azi", kazi
 
;;show config
 if kconfig == 0 then; stereo
SstL		sprintfk	"%d", 1
SstR		sprintfk	"%d", 2
SFL		sprintfk	"%s", ""
SFR		sprintfk	"%s", ""
SC		sprintfk	"%s", ""
SRR		sprintfk	"%s", ""
SRL		sprintfk	"%s", ""
Socto1		sprintfk	"%s", ""
Socto2		sprintfk	"%s", ""
Socto3		sprintfk	"%s", ""
Socto4		sprintfk	"%s", ""
Socto5		sprintfk	"%s", ""
Socto6		sprintfk	"%s", ""
Socto7		sprintfk	"%s", ""
Socto8		sprintfk	"%s", ""
 elseif kconfig == 1 then; quadro
SFL		sprintfk	"%d", 1
SFR		sprintfk	"%d", 2
SRR		sprintfk	"%d", 3
SRL		sprintfk	"%d", 4
SstL		sprintfk	"%s", ""
SstR		sprintfk	"%s", ""
SC		sprintfk	"%s", ""
Socto1		sprintfk	"%s", ""
Socto2		sprintfk	"%s", ""
Socto3		sprintfk	"%s", ""
Socto4		sprintfk	"%s", ""
Socto5		sprintfk	"%s", ""
Socto6		sprintfk	"%s", ""
Socto7		sprintfk	"%s", ""
Socto8		sprintfk	"%s", ""
 elseif kconfig == 2 then; 5.0 
Socto1		sprintfk	"%d", 1;according to the bformdec1 manual page,
SC		sprintfk	"%d", 2;the
Socto2		sprintfk	"%d", 3;4 speakers in the corners 
Socto5		sprintfk	"%d", 4;are closer to octo
Socto6		sprintfk	"%d", 5;than to quadro position
SstL		sprintfk	"%s", ""
SstR		sprintfk	"%s", ""
SFL		sprintfk	"%s", ""
SFR		sprintfk	"%s", ""
SRR		sprintfk	"%s", ""
SRL		sprintfk	"%s", ""
Socto3		sprintfk	"%s", ""
Socto4		sprintfk	"%s", ""
Socto7		sprintfk	"%s", ""
Socto8		sprintfk	"%s", ""
 elseif kconfig == 3 then; octo 
Socto1		sprintfk	"%d", 1
Socto2		sprintfk	"%d", 2
Socto3		sprintfk	"%d", 3
Socto4		sprintfk	"%d", 4
Socto5		sprintfk	"%d", 5
Socto6		sprintfk	"%d", 6
Socto7		sprintfk	"%d", 7
Socto8		sprintfk	"%d", 8
SstL		sprintfk	"%s", ""
SstR		sprintfk	"%s", ""
SC		sprintfk	"%s", ""
SFL		sprintfk	"%s", ""
SFR		sprintfk	"%s", ""
SRR		sprintfk	"%s", ""
SRL		sprintfk	"%s", ""
 endif
 		outvalue	"stL", SstL
 		outvalue	"stR", SstR
 		outvalue	"FL", SFL
 		outvalue	"FR", SFR
 		outvalue	"RR", SRR
 		outvalue	"RL", SRL
 		outvalue	"C", SC
 		outvalue	"octo1", Socto1
 		outvalue	"octo2", Socto2
 		outvalue	"octo3", Socto3
 		outvalue	"octo4", Socto4
 		outvalue	"octo5", Socto5
 		outvalue	"octo6", Socto6
 		outvalue	"octo7", Socto7
 		outvalue	"octo8", Socto8
 		
;;show audio output
		ShowLED_a	"out1", a1, kTrigDisp, 1, 48
		ShowLED_a	"out2", a2, kTrigDisp, 1, 48
		ShowLED_a	"out3", a3, kTrigDisp, 1, 48
		ShowLED_a	"out4", a4, kTrigDisp, 1, 48
		ShowLED_a	"out5", a5, kTrigDisp, 1, 48
		ShowLED_a	"out6", a6, kTrigDisp, 1, 48
		ShowLED_a	"out7", a7, kTrigDisp, 1, 48
		ShowLED_a	"out8", a8, kTrigDisp, 1, 48
		ShowOver_a	"out1over", a1, kTrigDisp, 2
		ShowOver_a	"out2over", a2, kTrigDisp, 2
		ShowOver_a	"out3over", a3, kTrigDisp, 2
		ShowOver_a	"out4over", a4, kTrigDisp, 2
		ShowOver_a	"out5over", a5, kTrigDisp, 2
		ShowOver_a	"out6over", a6, kTrigDisp, 2
		ShowOver_a	"out7over", a7, kTrigDisp, 2
		ShowOver_a	"out8over", a8, kTrigDisp, 2

endin


</CsInstruments>
<CsScore>
i 1 0 30000
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>425</x>
 <y>52</y>
 <width>745</width>
 <height>646</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>170</r>
  <g>169</g>
  <b>101</b>
 </bgcolor>
 <bsbObject version="2" type="BSBController">
  <objectName>x</objectName>
  <x>36</x>
  <y>115</y>
  <width>258</width>
  <height>258</height>
  <uuid>{5e148229-03df-4141-9486-525624c1fbed}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>y</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.25193798</xValue>
  <yValue>0.72093023</yValue>
  <type>point</type>
  <pointsize>5</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>azi</objectName>
  <x>60</x>
  <y>437</y>
  <width>71</width>
  <height>30</height>
  <uuid>{0577b52b-2045-446c-a5a3-9a617ad871a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>48.311</label>
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
  <objectName>spr</objectName>
  <x>161</x>
  <y>438</y>
  <width>119</width>
  <height>32</height>
  <uuid>{275179fa-a22e-4a00-b0b6-0a5ac7686767}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>0.000</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>60</x>
  <y>409</y>
  <width>72</width>
  <height>29</height>
  <uuid>{1373e8d6-1d04-45fe-bc43-e038ec757e15}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Azimuth</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>161</x>
  <y>410</y>
  <width>120</width>
  <height>30</height>
  <uuid>{18d339a7-88cd-481a-9d44-28444fb95118}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Spread (VBAP)</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>473</x>
  <y>282</y>
  <width>141</width>
  <height>54</height>
  <uuid>{b0d93b81-7919-4c1a-804a-6ec74b229f6b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Speaker
Configuration</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>config</objectName>
  <x>497</x>
  <y>345</y>
  <width>91</width>
  <height>22</height>
  <uuid>{95ca37f2-69fb-4fee-9777-91d96def2e4c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Stereo</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Quadro</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>5.0</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Octo</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>3</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>19</x>
  <y>472</y>
  <width>352</width>
  <height>167</height>
  <uuid>{73269565-546a-49ff-a2ba-8f97b4be21dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>For VBAP, the results given here are not as clean as they are if you use a proper vbaplsinit configuration. See the comment at the orchestra header for more.

Note that for Ambisonics the theoretical minimum for speakers are 4 (1st order), 6 (2nd order) or 8 (3rd order). But sometimes errors may sound good.

The Stereo configuration is more for fun. In general, use pan2 for this case.</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn1</objectName>
  <x>21</x>
  <y>684</y>
  <width>46</width>
  <height>24</height>
  <uuid>{745c8cba-6467-4659-9d40-ec087f7772a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>445</x>
  <y>390</y>
  <width>189</width>
  <height>30</height>
  <uuid>{e2268fc2-cf52-45fa-b654-a8c601f1ccd5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Output </label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn2</objectName>
  <x>75</x>
  <y>685</y>
  <width>46</width>
  <height>24</height>
  <uuid>{19ec1833-8ce6-4442-a859-7279b5e3ddc1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn3</objectName>
  <x>129</x>
  <y>685</y>
  <width>46</width>
  <height>24</height>
  <uuid>{313fcf20-6a83-4d8a-98e2-3add34c94a4a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn4</objectName>
  <x>183</x>
  <y>686</y>
  <width>46</width>
  <height>24</height>
  <uuid>{34e8adc1-1b29-43b9-b3f9-cf7b993af60d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>4</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn5</objectName>
  <x>238</x>
  <y>685</y>
  <width>46</width>
  <height>24</height>
  <uuid>{ec7045f9-c406-454d-8541-f2a07c64cbc4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>5</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn6</objectName>
  <x>292</x>
  <y>686</y>
  <width>46</width>
  <height>24</height>
  <uuid>{9f018654-8404-43c5-a2bb-9c207144bcd6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>6</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn7</objectName>
  <x>346</x>
  <y>686</y>
  <width>46</width>
  <height>24</height>
  <uuid>{8af8cf71-dce7-49c4-be2b-c8ef25dd5990}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>7</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>chn8</objectName>
  <x>400</x>
  <y>687</y>
  <width>46</width>
  <height>24</height>
  <uuid>{35dfa325-e805-4129-b04d-aa970089b9a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Lucida Grande</font>
  <fontsize>14</fontsize>
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
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>386</x>
  <y>473</y>
  <width>27</width>
  <height>138</height>
  <uuid>{6d3da117-7c00-4977-b271-65f92698df9b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out1</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.69032317</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>out1over</objectName>
  <x>386</x>
  <y>455</y>
  <width>27</width>
  <height>22</height>
  <uuid>{2b8b84d7-c4d0-45c8-8cf2-069d20661cf5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>430</x>
  <y>473</y>
  <width>27</width>
  <height>138</height>
  <uuid>{c7fc0494-b7fe-4eb1-a4ae-19655116e59b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out2</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.62558430</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>out2over</objectName>
  <x>430</x>
  <y>455</y>
  <width>27</width>
  <height>22</height>
  <uuid>{4977e06a-977a-4404-91b3-370563d2797a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>474</x>
  <y>473</y>
  <width>27</width>
  <height>138</height>
  <uuid>{28866427-bf18-4553-9205-d47c173af814}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out3</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.47074667</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>out3over</objectName>
  <x>474</x>
  <y>455</y>
  <width>27</width>
  <height>22</height>
  <uuid>{3b428c95-05f1-4011-ab79-e72a94be2347}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>518</x>
  <y>473</y>
  <width>27</width>
  <height>138</height>
  <uuid>{9a7c78fa-7191-4c2c-a205-091a649ad9b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out4</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.05160546</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>out4over</objectName>
  <x>518</x>
  <y>455</y>
  <width>27</width>
  <height>22</height>
  <uuid>{ed5dd815-0ce1-43ec-9c6e-ff66c56a0e67}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>562</x>
  <y>473</y>
  <width>27</width>
  <height>138</height>
  <uuid>{f2bce172-1501-4fc3-b4a6-889209f43db8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out5</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.15710704</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>out5over</objectName>
  <x>562</x>
  <y>455</y>
  <width>27</width>
  <height>22</height>
  <uuid>{4032e775-ab58-4556-9a34-c89b1eb54773}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>606</x>
  <y>473</y>
  <width>27</width>
  <height>138</height>
  <uuid>{81e2d6ae-0827-47ab-a854-5eb0be369ccc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out6</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.50203639</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>out6over</objectName>
  <x>606</x>
  <y>455</y>
  <width>27</width>
  <height>22</height>
  <uuid>{578ae6da-9cc1-4485-84d4-2a27c108e380}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>650</x>
  <y>473</y>
  <width>27</width>
  <height>138</height>
  <uuid>{365eaebd-10f4-4161-9bdb-e4239f98d087}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out7</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.63954848</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>out7over</objectName>
  <x>650</x>
  <y>455</y>
  <width>27</width>
  <height>22</height>
  <uuid>{b80feb90-153f-4b1b-bd55-4a521a27de0b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>hor8</objectName>
  <x>694</x>
  <y>473</y>
  <width>27</width>
  <height>138</height>
  <uuid>{ecf2cc00-2499-4caf-b4e8-2d3870341bd4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>out8</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.59259300</xValue>
  <yValue>0.69447351</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>out8over</objectName>
  <x>694</x>
  <y>455</y>
  <width>27</width>
  <height>22</height>
  <uuid>{68087bf2-5239-4f42-9f96-5d2f98bd1ea9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>in1over</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.63636400</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>333</x>
  <y>282</y>
  <width>128</width>
  <height>53</height>
  <uuid>{98e48abf-89ce-48e5-bbb5-25a6fb9ef873}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Spatialization
Method</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>method</objectName>
  <x>355</x>
  <y>345</y>
  <width>91</width>
  <height>22</height>
  <uuid>{a6540d5f-318c-41e4-97d6-d853181689d1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>VBAP</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Ambi1st</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Ambi2nd</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Ambi3rd</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>FL</objectName>
  <x>23</x>
  <y>79</y>
  <width>25</width>
  <height>33</height>
  <uuid>{2baa3b91-94d6-44fe-b83d-d86b7b331a42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>FR</objectName>
  <x>282</x>
  <y>79</y>
  <width>25</width>
  <height>33</height>
  <uuid>{c27fd2f8-c8e3-4c40-8315-ec135aeb65b8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>RR</objectName>
  <x>286</x>
  <y>376</y>
  <width>25</width>
  <height>33</height>
  <uuid>{639850a5-f39d-413e-8ca0-8dccbd60c62c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>RL</objectName>
  <x>22</x>
  <y>374</y>
  <width>25</width>
  <height>33</height>
  <uuid>{507437ed-cec9-4681-9ea6-20121b0fde0f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>C</objectName>
  <x>148</x>
  <y>80</y>
  <width>25</width>
  <height>33</height>
  <uuid>{30abeef6-7a3d-49eb-85fe-70e1049e6e90}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>octo1</objectName>
  <x>90</x>
  <y>79</y>
  <width>25</width>
  <height>33</height>
  <uuid>{9d9f3f92-27b0-46cc-912b-acb665e487b9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>octo2</objectName>
  <x>208</x>
  <y>80</y>
  <width>25</width>
  <height>33</height>
  <uuid>{c8a7b62e-c4c6-4831-bc72-360ab59f3498}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>octo3</objectName>
  <x>293</x>
  <y>159</y>
  <width>25</width>
  <height>33</height>
  <uuid>{3e3bf62b-ae18-41f9-9e36-d3b2ed4367ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>octo4</objectName>
  <x>294</x>
  <y>277</y>
  <width>25</width>
  <height>33</height>
  <uuid>{a6eaacb0-e827-44d0-a122-c2aab6349912}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>octo6</objectName>
  <x>90</x>
  <y>372</y>
  <width>25</width>
  <height>33</height>
  <uuid>{7c78c72d-d97c-48fa-9bef-bca3a1717fb8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>6</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>octo5</objectName>
  <x>208</x>
  <y>373</y>
  <width>25</width>
  <height>33</height>
  <uuid>{0041afed-f6ad-444c-90c4-3bf7a3649ccb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>5</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>octo8</objectName>
  <x>11</x>
  <y>159</y>
  <width>25</width>
  <height>33</height>
  <uuid>{16ef8121-5396-477b-a814-f9cb020493f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>8</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>octo7</objectName>
  <x>11</x>
  <y>279</y>
  <width>25</width>
  <height>33</height>
  <uuid>{e7be0a3a-37a6-419e-9e5d-af599c68a249}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>7</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <x>459</x>
  <y>686</y>
  <width>72</width>
  <height>29</height>
  <uuid>{deb50516-3eb8-4e8a-a104-9b624c7bec29}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Routing</label>
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
  <x>268</x>
  <y>424</y>
  <width>119</width>
  <height>26</height>
  <uuid>{af14ba94-8301-47b6-ae1a-25b3768524a5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Logical Channel</label>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
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
  <objectName>stL</objectName>
  <x>12</x>
  <y>223</y>
  <width>25</width>
  <height>33</height>
  <uuid>{d9443bce-ee55-4c3f-804c-7bedf8ac269b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <objectName>stR</objectName>
  <x>293</x>
  <y>222</y>
  <width>25</width>
  <height>33</height>
  <uuid>{6804ad44-12a5-4364-a9f6-d1e3fc06dd4f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label/>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>16</fontsize>
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
  <x>384</x>
  <y>422</y>
  <width>34</width>
  <height>30</height>
  <uuid>{4d539943-c6c2-4a79-ab29-9db999c30a28}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>1</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>427</x>
  <y>422</y>
  <width>34</width>
  <height>30</height>
  <uuid>{e7407dce-f3f2-49c6-81fb-1656016f0c29}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>2</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>470</x>
  <y>423</y>
  <width>34</width>
  <height>30</height>
  <uuid>{50ca51fe-aed6-4bcd-a8c4-bfd5a5ec49fe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>3</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>513</x>
  <y>423</y>
  <width>34</width>
  <height>30</height>
  <uuid>{2cebbd48-b449-48b3-b17d-639b903f5eda}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>4</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>556</x>
  <y>423</y>
  <width>34</width>
  <height>30</height>
  <uuid>{1d7f60ff-438c-4ef7-8de0-d7802ec8f995}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>5</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>599</x>
  <y>423</y>
  <width>34</width>
  <height>30</height>
  <uuid>{04fda73d-d74b-4b06-bb47-dd6e1261c224}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>6</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>642</x>
  <y>423</y>
  <width>34</width>
  <height>30</height>
  <uuid>{46c542da-feab-47e6-9075-8ed9fc77a6f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>7</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>686</x>
  <y>424</y>
  <width>34</width>
  <height>30</height>
  <uuid>{3e2117f1-dc8d-48bf-8eb1-8475d7962eca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>8</label>
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
  <objectName>_Browse1</objectName>
  <x>343</x>
  <y>157</y>
  <width>100</width>
  <height>29</height>
  <uuid>{18fd38bd-5934-4738-a82d-8408b5cc9abd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue>/home/linux/Desktop/QC Ex neu/BratscheNormal.wav</stringvalue>
  <text>Open File</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>331</x>
  <y>123</y>
  <width>126</width>
  <height>30</height>
  <uuid>{d8114b3e-dc7b-4380-8df2-b5c0379f610d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Sound Input</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>473</x>
  <y>124</y>
  <width>71</width>
  <height>31</height>
  <uuid>{cba0b23b-cd15-44f8-ba62-edf6eeb17ca0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Loop</label>
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
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>loop</objectName>
  <x>498</x>
  <y>159</y>
  <width>20</width>
  <height>20</height>
  <uuid>{ff28212f-eccf-4328-966d-98b88ec34854}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>550</x>
  <y>124</y>
  <width>71</width>
  <height>31</height>
  <uuid>{6484b456-04b0-461d-b077-8f7bbf7c75db}</uuid>
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
  <objectName>dbout</objectName>
  <x>620</x>
  <y>124</y>
  <width>72</width>
  <height>32</height>
  <uuid>{83a91c31-6833-432e-ba05-32b4eec2c7ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>+0 dB</label>
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
  <x>16</x>
  <y>2</y>
  <width>683</width>
  <height>44</height>
  <uuid>{f3f21629-5cab-4c50-a594-46213a503e87}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>SPATIALIZATION WITH VBAP AND AMBISONICS</label>
  <alignment>center</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>334</x>
  <y>197</y>
  <width>126</width>
  <height>30</height>
  <uuid>{5ace8f0d-bca1-418b-9bf3-2ff075f19f3d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Live Input</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>348</x>
  <y>82</y>
  <width>133</width>
  <height>30</height>
  <uuid>{d9071faa-6667-4dbf-9a97-34cd7235c636}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Input Select</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>inputsel</objectName>
  <x>490</x>
  <y>86</y>
  <width>140</width>
  <height>25</height>
  <uuid>{648ab791-c494-4111-8352-2cb7a3705f13}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Soundfile</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Live</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Noise (-12dB)</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>462</x>
  <y>191</y>
  <width>89</width>
  <height>47</height>
  <uuid>{e3801197-4d32-4f38-9077-2943ab90fd49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Input
Channel</label>
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
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>inchan</objectName>
  <x>482</x>
  <y>237</y>
  <width>60</width>
  <height>27</height>
  <uuid>{3dab6935-ec45-4471-b38e-85c2a6318061}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <minimum>1</minimum>
  <maximum>100</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>gaindb</objectName>
  <x>549</x>
  <y>159</y>
  <width>160</width>
  <height>24</height>
  <uuid>{fccbda71-c3c0-4b0b-9c1f-40769da4cf27}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>0.30000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>550</x>
  <y>197</y>
  <width>71</width>
  <height>31</height>
  <uuid>{b5373098-14ac-47aa-9b91-1de9094d02b5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Gain</label>
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
  <objectName>dboutlive</objectName>
  <x>620</x>
  <y>197</y>
  <width>72</width>
  <height>32</height>
  <uuid>{eba756f6-e9b0-4341-92de-faef657d79d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>+0 dB</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>gaindblive</objectName>
  <x>549</x>
  <y>241</y>
  <width>160</width>
  <height>24</height>
  <uuid>{8d1c283e-0003-4ca0-9f4d-043adc84e8f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>-0.30000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>livein</objectName>
  <x>333</x>
  <y>237</y>
  <width>110</width>
  <height>28</height>
  <uuid>{22384037-3d04-4a0c-8598-e49bca229f74}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>livein</objectName2>
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
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>liveinover</objectName>
  <x>441</x>
  <y>237</y>
  <width>26</width>
  <height>28</height>
  <uuid>{f690eebb-99ce-48fa-be6d-24e677512480}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>liveinover</objectName2>
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
  <color>
   <r>196</r>
   <g>14</g>
   <b>12</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>15</x>
  <y>44</y>
  <width>684</width>
  <height>30</height>
  <uuid>{9bd2bc60-9da3-467a-8332-29c2393791c8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Requires Csound 5.13 or higher because of the filevalid opcode</label>
  <alignment>center</alignment>
  <font>DejaVu Sans</font>
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
ioView background {43690, 43433, 25957}
ioMeter {36, 115} {258, 258} {0, 59904, 0} "x" 0.251938 "y" 0.720930 point 5 0 mouse
ioText {60, 437} {71, 30} display 48.310940 0.00100 "azi" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 48.311
ioText {161, 438} {119, 32} display 0.000000 0.00100 "spr" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 0.000
ioText {60, 409} {72, 29} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Azimuth
ioText {161, 410} {120, 30} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Spread (VBAP)
ioText {473, 282} {141, 54} label 0.000000 0.00100 "" center "DejaVu Sans" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder SpeakerÂ¬Configuration
ioMenu {497, 345} {91, 22} 3 303 "Stereo,Quadro,5.0,Octo" config
ioText {19, 472} {358, 150} label 0.000000 0.00100 "" left "DejaVu Sans" 12 {0, 0, 0} {58624, 58624, 58624} nobackground noborder For VBAP, the results given here are not as clean as they are if you use a proper vbaplsinit configuration. See the comment at the orchestra header for more.Â¬Â¬Note that for Ambisonics the theoretical minimum for speakers are 4 (1st order), 6 (2nd order) or 8 (3rd order). But sometimes errors may sound good.Â¬Â¬The Stereo configuration is more for fun. In general, use pan2 for this case.
ioText {21, 684} {46, 24} editnum 1.000000 1.000000 "chn1" right "" 0 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 1.000000
ioText {133, 498} {189, 30} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Output 
ioText {75, 685} {46, 24} editnum 2.000000 1.000000 "chn2" right "" 0 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 2.000000
ioText {129, 685} {46, 24} editnum 3.000000 1.000000 "chn3" right "" 0 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 3.000000
ioText {183, 686} {46, 24} editnum 4.000000 1.000000 "chn4" right "" 0 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 4.000000
ioText {238, 685} {46, 24} editnum 5.000000 1.000000 "chn5" right "" 0 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 5.000000
ioText {292, 686} {46, 24} editnum 6.000000 1.000000 "chn6" right "" 0 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 6.000000
ioText {346, 686} {46, 24} editnum 7.000000 1.000000 "chn7" right "" 0 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 7.000000
ioText {400, 687} {46, 24} editnum 8.000000 1.000000 "chn8" right "" 0 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 8.000000
ioMeter {386, 473} {27, 138} {0, 59904, 0} "hor8" 0.592593 "out1" 0.690323 fill 1 0 mouse
ioMeter {386, 455} {27, 22} {50176, 3584, 3072} "out1over" 0.000000 "in1over" 0.636364 fill 1 0 mouse
ioMeter {430, 473} {27, 138} {0, 59904, 0} "hor8" 0.592593 "out2" 0.625584 fill 1 0 mouse
ioMeter {430, 455} {27, 22} {50176, 3584, 3072} "out2over" 0.000000 "in1over" 0.636364 fill 1 0 mouse
ioMeter {474, 473} {27, 138} {0, 59904, 0} "hor8" 0.592593 "out3" 0.470747 fill 1 0 mouse
ioMeter {474, 455} {27, 22} {50176, 3584, 3072} "out3over" 0.000000 "in1over" 0.636364 fill 1 0 mouse
ioMeter {518, 473} {27, 138} {0, 59904, 0} "hor8" 0.592593 "out4" 0.051605 fill 1 0 mouse
ioMeter {518, 455} {27, 22} {50176, 3584, 3072} "out4over" 0.000000 "in1over" 0.636364 fill 1 0 mouse
ioMeter {562, 473} {27, 138} {0, 59904, 0} "hor8" 0.592593 "out5" 0.157107 fill 1 0 mouse
ioMeter {562, 455} {27, 22} {50176, 3584, 3072} "out5over" 0.000000 "in1over" 0.636364 fill 1 0 mouse
ioMeter {606, 473} {27, 138} {0, 59904, 0} "hor8" 0.592593 "out6" 0.502036 fill 1 0 mouse
ioMeter {606, 455} {27, 22} {50176, 3584, 3072} "out6over" 0.000000 "in1over" 0.636364 fill 1 0 mouse
ioMeter {650, 473} {27, 138} {0, 59904, 0} "hor8" 0.592593 "out7" 0.639548 fill 1 0 mouse
ioMeter {650, 455} {27, 22} {50176, 3584, 3072} "out7over" 0.000000 "in1over" 0.636364 fill 1 0 mouse
ioMeter {694, 473} {27, 138} {0, 59904, 0} "hor8" 0.592593 "out8" 0.694474 fill 1 0 mouse
ioMeter {694, 455} {27, 22} {50176, 3584, 3072} "out8over" 0.000000 "in1over" 0.636364 fill 1 0 mouse
ioText {333, 282} {128, 53} label 0.000000 0.00100 "" center "DejaVu Sans" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder SpatializationÂ¬Method
ioMenu {355, 345} {91, 22} 1 303 "VBAP,Ambi1st,Ambi2nd,Ambi3rd" method
ioText {23, 79} {25, 33} display 0.000000 0.00100 "FL" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {282, 79} {25, 33} display 0.000000 0.00100 "FR" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {286, 376} {25, 33} display 0.000000 0.00100 "RR" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {22, 374} {25, 33} display 0.000000 0.00100 "RL" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {148, 80} {25, 33} display 0.000000 0.00100 "C" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {90, 79} {25, 33} display 1.000000 0.00100 "octo1" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 1
ioText {214, 80} {25, 33} display 2.000000 0.00100 "octo2" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 2
ioText {293, 159} {25, 33} display 3.000000 0.00100 "octo3" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 3
ioText {294, 277} {25, 33} display 4.000000 0.00100 "octo4" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 4
ioText {84, 372} {25, 33} display 6.000000 0.00100 "octo6" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 6
ioText {208, 373} {25, 33} display 5.000000 0.00100 "octo5" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 5
ioText {11, 159} {25, 33} display 8.000000 0.00100 "octo8" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 8
ioText {11, 279} {25, 33} display 7.000000 0.00100 "octo7" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 7
ioText {459, 686} {72, 29} label 0.000000 0.00100 "" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Routing
ioText {767, 421} {141, 31} label 0.000000 0.00100 "" right "DejaVu Sans" 12 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Logical Channel
ioText {12, 223} {25, 33} display 0.000000 0.00100 "stL" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {293, 222} {25, 33} display 0.000000 0.00100 "stR" left "Arial" 16 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 
ioText {19, 531} {34, 30} label 1.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 1
ioText {72, 531} {34, 30} label 2.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 2
ioText {128, 531} {34, 30} label 3.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 3
ioText {181, 531} {34, 30} label 4.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 4
ioText {234, 531} {34, 30} label 5.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 5
ioText {287, 531} {34, 30} label 6.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 6
ioText {343, 531} {34, 30} label 7.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 7
ioText {396, 531} {34, 30} label 8.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 8
ioButton {343, 157} {100, 29} value 1.000000 "_Browse1" "Open File" "/" 
ioText {331, 123} {126, 30} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Sound Input
ioText {473, 124} {71, 31} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Loop
ioCheckbox {498, 159} {20, 20} on loop
ioText {550, 124} {71, 31} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Volume
ioText {620, 124} {72, 32} display 0.000000 0.00100 "dbout" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder +0 dB
ioText {16, 18} {683, 44} label 0.000000 0.00100 "" center "Lucida Grande" 30 {0, 0, 0} {58624, 58624, 58624} nobackground noborder SPATIALIZATION WITH VBAP AND AMBISONICS
ioText {334, 197} {126, 30} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Live Input
ioText {348, 82} {133, 30} label 0.000000 0.00100 "" center "Lucida Grande" 18 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Input Select
ioMenu {490, 86} {140, 25} 0 303 "Soundfile,Live,Noise (-12dB)" inputsel
ioText {462, 191} {89, 47} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder InputÂ¬Channel
ioText {482, 237} {60, 27} editnum 1.000000 1.000000 "inchan" center "" 0 {0, 0, 0} {58624, 58624, 58624} nobackground noborder 1.000000
ioSlider {549, 159} {160, 24} -12.000000 12.000000 0.300000 gaindb
ioText {550, 197} {71, 31} label 0.000000 0.00100 "" center "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Gain
ioText {620, 197} {72, 32} display 0.000000 0.00100 "dboutlive" left "Lucida Grande" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder +0 dB
ioSlider {549, 241} {160, 24} -12.000000 12.000000 -0.300000 gaindblive
ioMeter {333, 237} {110, 28} {0, 59904, 0} "livein" 0.000000 "livein" 0.000000 fill 1 0 mouse
ioMeter {441, 237} {26, 28} {50176, 3584, 3072} "liveinover" 0.000000 "liveinover" 0.000000 fill 1 0 mouse
ioText {36, 22} {683, 44} label 0.000000 0.00100 "" center "DejaVu Sans" 14 {0, 0, 0} {58624, 58624, 58624} nobackground noborder Requires Csound 5.13 or higher because of the filevalid opcode
</MacGUI>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="256" y="208" width="612" height="322" visible="true" loopStart="0" loopEnd="0">    </EventPanel>

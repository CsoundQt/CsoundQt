<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

/*****LIVE GRANULAR SYNTHESIS*****/
;example for CsoundQt
;written by joachim heintz
;jan 2010 / june 2011
;please send bug reports and suggestions
;to jh at joachimheintz.de

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

giWin1		ftgen		1, 0, 4096, 20, 1, 1		; Hamming
giWin2		ftgen		2, 0, 4096, 20, 2, 1		; von Hann
giWin3		ftgen		3, 0, 4096, 20, 3, 1		; Triangle (Bartlett)
giWin4		ftgen		4, 0, 4096, 20, 4, 1		; Blackman (3-term)
giWin5		ftgen		5, 0, 4096, 20, 5, 1		; Blackman-Harris (4-term)
giWin6		ftgen		6, 0, 4096, 20, 6, 1		; Gauss
giWin7		ftgen		7, 0, 4096, 20, 7, 1, 6		; Kaiser
giWin8		ftgen		8, 0, 4096, 20, 8, 1		; Rectangle
giWin9		ftgen		9, 0, 4096, 20, 9, 1		; Sync
giLiveBuf	ftgen		0, 0, 16384, 2, 0			; buffer for writing and reading live input
giDisttab	ftgen		0, 0, 32768, 7, 0, 32768, 1	; for kdistribution
giCosine	ftgen		0, 0, 8193, 9, 1, 1, 90		; cosine
giMaxGrLen	=		0.1					; maximaum grain length in seconds

  opcode PartikkelSimpB, a, iakkkkkkkiii
/* Simplified Version of the partikkel opcode, with a time pointer input.
ifiltab:	function table to read
apnter:	pointer in the function table (0-1)
kgrainamp:	multiplier of the grain amplitude (the overall amplitude depends also on grainrate and grainsize)
kgrainrate:	number of grains per seconds
kgrainsize:	grain duration in ms
kdist:		0 = periodic (synchronous), 1 = scattered (asynchronous)
kcent:		transposition in cent
kposrand:	random deviation (offset) of the pointer in ms
kcentrand:	random transposition in cents (up and down)
icosintab:	function table with cosine (e.g. giCosine ftgen 0, 0, 8193, 9, 1, 1, 90)
idisttab:	function table with distribution (e.g. giDisttab ftgen 0, 0, 32768, 7, 0, 32768, 1)
iwin:		function table with window shape (e.g. giWin ftgen 0, 0, 4096, 20, 9, 1)
*/

ifiltab, apnter, kgrainamp, kgrainrate, kgrainsize, kdist, kcent, kposrand, kcentrand, icosintab, idisttab, iwin	xin

/*amplitude*/
kamp		= 		kgrainamp * 0dbfs
/*transposition*/
kcentrand	rand 		kcentrand; random transposition
iorig		= 		1 / (ftlen(ifiltab)/sr); original pitch
kwavfreq	= 		iorig * cent(kcent + kcentrand)	
/*pointer*/
kposrand	=		(kposrand/1000) * (sr/ftlen(ifiltab)); random offset converted from ms to phase (0-1)
arndpos	linrand	kposrand; random offset in phase values
asamplepos	=		apnter + arndpos 
/* other parameters */
imax_grains	= 		1000; maximum number of grains per k-period
async		=		0; no sync input
awavfm		=		0; no audio input for fm

aout		partikkel 	kgrainrate, kdist, idisttab, async, 1, iwin, \
				-1, -1, 0, 0, kgrainsize, kamp, -1, \
				kwavfreq, 0, -1, -1, awavfm, \
				-1, -1, icosintab, kgrainrate, 1, \
				1, -1, 0, ifiltab, ifiltab, ifiltab, ifiltab, \
				-1, asamplepos, asamplepos, asamplepos, asamplepos, \
				1, 1, 1, 1, imax_grains
		xout		aout
  endop

  opcode	ShowLED_a, 0, Sakkk
;shows an audiosignal in an outvalue channel, in dB or raw amplitudes
;Soutchan: string as name of the outvalue channel
;asig: audio signal to be shown
;kdispfreq: refresh frequency of the display (Hz)
;kdb: 1 = show as db, 0 = show as raw amplitudes (both in the range 0-1)
;kdbrange: if idb=1: which dB range is shown
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
;shows if asig has been larger than 1 and stays khold seconds
;Soutchan: string as name of the outvalue channel
;kdispfreq: refresh frequency of the display (Hz)
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


instr 1; master instrument
;;get live input and write to buffer (ftable) giLiveBuf
aLiveInPre	inch		1
kingaindb	invalue	"ingaindb"
kLiveInGain	=		ampdb(kingaindb)
aLiveInPost	=		aLiveInPre * kLiveInGain
iphasfreq	=		1 / (ftlen(giLiveBuf) / sr); phasor frequency
kfreeze	invalue	"freeze"; if checked, freeze writing (and reading) of the buffer
kphasfreq	=		(kfreeze == 1 ? 0 : iphasfreq)
awritpnt	phasor		kphasfreq
		tablew		aLiveInPost, awritpnt, giLiveBuf, 1, 0, 1

;;create an instrument for a readpointer which is giMaxGrLen seconds later than the writepointer
		event_i	"i", 2, giMaxGrLen, -1, iphasfreq

;;show live input
gkTrigDisp	metro		10
gkshowdb	invalue	"showdb"
gkdbrange	invalue	"dbrange"
		ShowLED_a	"LiveInPre", aLiveInPre, gkTrigDisp, gkshowdb, gkdbrange
		ShowOver_a	"LiveInPreOver", aLiveInPre, gkTrigDisp, 2
		ShowLED_a	"LiveInPost", aLiveInPost, gkTrigDisp, gkshowdb, gkdbrange
		ShowOver_a	"LiveInPostOver", aLiveInPost, gkTrigDisp, 2

;;select shape of the grain envelope and show it
kwinshape	invalue	"winshape"; 0=Hamming, 1=von Hann, 2=Bartlett, 3=Triangle, 4=Blackman-Harris,
						;5=Gauss, 6=Kaiser, 7=Rectangle, 8=Sync
		event_i	"i", 10, 0, -1, i(kwinshape)+1
		outvalue	"ftab", -(kwinshape+1); graph widget shows selected window shape

;;triggers i 10 at the beginning and whenever the grain envelope has changed
kchanged	changed	kwinshape; sends 1 if the windowshape has changed
 if kchanged == 1 then
		event		"i", -10, 0, -1; turn off previous instance of i10
		event		"i", 10, 0, -1, kwinshape+1; turn on new instance
 endif
endin

instr 2; creates the pointer for reading the buffer giLiveBuf
iphasfreq	=		p4; usual phasor frequency (calculated and sent by instr 1) 
kfreeze	invalue	"freeze"; if checked, freeze reading of the buffer
kphasfreq	=		(kfreeze == 1 ? 0 : iphasfreq); otherwise use kphasfreq
areadpnt	phasor		kphasfreq
		chnset		areadpnt, "readpnt"; sends areadpnt to the channel 'readpnt'
endin

instr 10; performs granular synthesis
;;parameters for the partikkel opcode
iwin		=		p4; shape of the grain window 
ifiltab	=		giLiveBuf; buffer to read
apnt		init		0; initializing the read pointer
kgrainrate	invalue	"grainrate"; grains per second
kgrainsize	invalue	"grainsize"; length of the grains in ms
kcent		invalue	"transp"; pitch transposition in cent
kgraindb	invalue	"outgaindb"; volume
kgrainamp	=		ampdb(kgraindb)
kdist		invalue	"dist"; distribution (0=periodic, 1=scattered)
kposrand	invalue	"posrand"; time position randomness (offset) of the read pointer in ms
kcentrand	invalue	"centrand"; transposition randomness in cents (up and down)
icosintab	=		giCosine; ftable with a cosine waveform
idisttab	=		giDisttab; ftable with values for scattered distribution 
apnt		chnget		"readpnt"; pointer generated 

;;granular synthesis
agrain 	PartikkelSimpB 	ifiltab, apnt, kgrainamp, kgrainrate, kgrainsize,\
					kdist, kcent, kposrand, kcentrand, icosintab, idisttab, iwin
		out		agrain

;;show output
		ShowLED_a	"out", agrain, gkTrigDisp, gkshowdb, gkdbrange
		ShowOver_a	"outover", agrain, gkTrigDisp, 2
endin


</CsInstruments>
<CsScore>
i 1 0 3600
e
</CsScore>
</CsoundSynthesizer>







<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>146</x>
 <y>65</y>
 <width>903</width>
 <height>657</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>236</r>
  <g>236</g>
  <b>236</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>9</x>
  <y>9</y>
  <width>886</width>
  <height>44</height>
  <uuid>{2a56f609-3f3a-49a2-8ef2-04e1041ed49f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>LIVE GRANULAR SYNTHESIS</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>10</x>
  <y>58</y>
  <width>886</width>
  <height>66</height>
  <uuid>{49b99e1e-2b4b-4aef-b413-95171c64b350}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Granulates a (mono) input stream, with optional freezing at a certain point.
If you want to reduce the delay of the granulated output, set giMaxGrLen in the orc header to a lower value (the delay also depends on your -B and -b size).
</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>11</x>
  <y>132</y>
  <width>484</width>
  <height>148</height>
  <uuid>{e39c91d6-a0bd-4681-8dbc-e384493e578c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label> INPUT</label>
  <alignment>left</alignment>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>LiveInPre</objectName>
  <x>120</x>
  <y>164</y>
  <width>336</width>
  <height>22</height>
  <uuid>{7286a833-c0b0-4f55-8ecc-837453106e15}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out1_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.26302832</xValue>
  <yValue>0.73076900</yValue>
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
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>LiveInPreOver</objectName>
  <x>454</x>
  <y>164</y>
  <width>27</width>
  <height>22</height>
  <uuid>{42e31476-6cb3-42b4-a1fd-8f48e76892ac}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>LiveInPost</objectName>
  <x>116</x>
  <y>240</y>
  <width>336</width>
  <height>22</height>
  <uuid>{77fcb44e-b9a2-423d-9764-52f01754d96d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out2_post</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.11348984</xValue>
  <yValue>0.59090900</yValue>
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
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>LiveInPostOver</objectName>
  <x>450</x>
  <y>240</y>
  <width>27</width>
  <height>22</height>
  <uuid>{3e4c2001-fd4f-4b10-bd75-1766b5d1bbde}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>21</x>
  <y>164</y>
  <width>93</width>
  <height>28</height>
  <uuid>{9dd7688d-d7d4-4863-bbe8-44c1e622f2bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Live in Pre</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>19</x>
  <y>240</y>
  <width>97</width>
  <height>29</height>
  <uuid>{a6c9d0da-7821-4528-b193-9ee9af3d441f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Live in Post</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>20</x>
  <y>202</y>
  <width>93</width>
  <height>31</height>
  <uuid>{bdebe2b5-07c1-4f1f-b7cb-d2f29a26a5f8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Input Gain</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>ingaindb</objectName>
  <x>120</x>
  <y>199</y>
  <width>260</width>
  <height>26</height>
  <uuid>{64de8264-0345-4faf-b16c-4af284a95268}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>-7.47692308</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>518</x>
  <y>131</y>
  <width>380</width>
  <height>215</height>
  <uuid>{e748e0c8-197c-4d4d-b893-9501e50ae02b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label> OUTPUT</label>
  <alignment>left</alignment>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>out</objectName>
  <x>528</x>
  <y>197</y>
  <width>338</width>
  <height>24</height>
  <uuid>{133bd5e9-655f-4ba7-895d-45c9c8e54eb3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <objectName2>out</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.68301880</xValue>
  <yValue>0.68301880</yValue>
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
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>outover</objectName>
  <x>863</x>
  <y>197</y>
  <width>26</width>
  <height>24</height>
  <uuid>{dc5f0c73-a680-4e93-9855-6706fbd5180d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
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
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
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
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>525</x>
  <y>228</y>
  <width>368</width>
  <height>105</height>
  <uuid>{c385ef49-3efa-4ec3-806a-ff883343cb9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
  <triggermode>NoTrigger</triggermode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>11</x>
  <y>354</y>
  <width>882</width>
  <height>281</height>
  <uuid>{f470cb16-0510-44e6-b6e0-c532a68e3409}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>GRANULAR</label>
  <alignment>left</alignment>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>529</x>
  <y>164</y>
  <width>95</width>
  <height>27</height>
  <uuid>{dcc76929-4dec-4912-b228-fcab4a27e75f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Output Gain</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>outgaindb</objectName>
  <x>625</x>
  <y>164</y>
  <width>155</width>
  <height>24</height>
  <uuid>{2735c656-a8f6-429d-acc3-2fe0db7e078a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-12.00000000</minimum>
  <maximum>12.00000000</maximum>
  <value>-2.55483871</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>44</x>
  <y>390</y>
  <width>143</width>
  <height>27</height>
  <uuid>{d7297eb9-b0d9-43c7-a5cb-5c71793c04d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Grains per Second</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>17</x>
  <y>562</y>
  <width>147</width>
  <height>25</height>
  <uuid>{ad4914bd-492d-45c0-bb8c-86e98247e37e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Transposition (Cent)</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>transp</objectName>
  <x>18</x>
  <y>586</y>
  <width>222</width>
  <height>32</height>
  <uuid>{2a0c5abd-8f05-4f19-8c6e-5ceb8d4572dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>-1200.00000000</minimum>
  <maximum>1200.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>34</x>
  <y>481</y>
  <width>101</width>
  <height>25</height>
  <uuid>{078aa6dc-ef57-4db7-949b-c11e729c837a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Grainsize (ms)</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>grainsize</objectName>
  <x>31</x>
  <y>506</y>
  <width>177</width>
  <height>26</height>
  <uuid>{8b59f109-6fc3-4138-bb2e-93113fe13a40}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>1.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>grainrate</objectName>
  <x>21</x>
  <y>418</y>
  <width>252</width>
  <height>25</height>
  <uuid>{5df30f9c-f3dd-4ac9-8088-9cf169cd31f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>1.00000000</minimum>
  <maximum>200.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>374</x>
  <y>394</y>
  <width>143</width>
  <height>27</height>
  <uuid>{cc73b249-baad-47fd-9842-b921037d1a6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Distribution</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>dist</objectName>
  <x>369</x>
  <y>420</y>
  <width>152</width>
  <height>25</height>
  <uuid>{a142fe2c-da20-4aa8-a13b-0432a4cb6352}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>238</x>
  <y>481</y>
  <width>191</width>
  <height>27</height>
  <uuid>{175842e1-79f7-4518-882a-4555834acf3a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Position Randomness (ms)</label>
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
 <bsbObject version="2" type="BSBHSlider">
  <objectName>posrand</objectName>
  <x>239</x>
  <y>509</y>
  <width>265</width>
  <height>29</height>
  <uuid>{bd0a56e7-6873-484a-be88-67c57c0a66f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>1.88679245</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>centrand</objectName>
  <x>275</x>
  <y>589</y>
  <width>306</width>
  <height>28</height>
  <uuid>{d2da0179-913a-4308-8b92-65f69293814b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>100.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>275</x>
  <y>562</y>
  <width>234</width>
  <height>25</height>
  <uuid>{558f5942-1622-49a1-aeac-5faede2c8d51}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Transposition Randomness (Cent)</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>298</x>
  <y>419</y>
  <width>71</width>
  <height>29</height>
  <uuid>{ac7d4a98-e00c-4c47-9bb6-9bf8591999ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>periodic</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>520</x>
  <y>418</y>
  <width>90</width>
  <height>28</height>
  <uuid>{f41b248e-80fb-4cb5-a210-eded60c8c325}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>scattered</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>694</x>
  <y>363</y>
  <width>115</width>
  <height>28</height>
  <uuid>{5d0f4113-a2a8-4f15-872d-d10b174dcf71}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Window Shape</label>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>winshape</objectName>
  <x>682</x>
  <y>414</y>
  <width>140</width>
  <height>26</height>
  <uuid>{35980021-56da-4027-841b-abf660393ab2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>Hamming</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>von Hann</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Triangle</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Blackman</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Blackman-Harris</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Gauss</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Kaiser</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Rectangle</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>Sync</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>8</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName>ftab</objectName>
  <x>620</x>
  <y>476</y>
  <width>256</width>
  <height>145</height>
  <uuid>{dcb84ff3-5289-475e-813f-db94e34bc296}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>auto</modex>
  <modey>auto</modey>
  <showSelector>true</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>true</showScrollbars>
  <enableTables>true</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>667</x>
  <y>451</y>
  <width>168</width>
  <height>27</height>
  <uuid>{2d0fa256-93bd-4690-911d-437222bc7428}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>... and see its shape</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>652</x>
  <y>389</y>
  <width>185</width>
  <height>27</height>
  <uuid>{fbbd39e2-e473-4455-8e7c-a57724ae5010}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Select window function ...</label>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>458</x>
  <y>198</y>
  <width>30</width>
  <height>31</height>
  <uuid>{eecbf48f-983f-4ce5-bdcc-e6b1ae657b20}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>dB</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>ingaindb</objectName>
  <x>380</x>
  <y>200</y>
  <width>76</width>
  <height>27</height>
  <uuid>{a44b45c8-8c22-4c53-9442-75339608f708}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>861</x>
  <y>162</y>
  <width>30</width>
  <height>31</height>
  <uuid>{a5947f34-1e11-490f-bd5d-c543d6e4494e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>dB</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
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
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>outgaindb</objectName>
  <x>781</x>
  <y>163</y>
  <width>76</width>
  <height>27</height>
  <uuid>{52bb78bb-8e63-44a1-a86a-5def867d5311}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>-1e+12</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>grainrate</objectName>
  <x>186</x>
  <y>390</y>
  <width>76</width>
  <height>27</height>
  <uuid>{c8857f63-c4d2-456d-92df-cf078b7c6525}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1000</maximum>
  <randomizable group="0">false</randomizable>
  <value>152</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>freeze</objectName>
  <x>513</x>
  <y>480</y>
  <width>87</width>
  <height>59</height>
  <uuid>{209e708e-b0c9-4794-b610-fec1096126c8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Freeze!</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>grainsize</objectName>
  <x>131</x>
  <y>481</y>
  <width>76</width>
  <height>27</height>
  <uuid>{9047dd54-fb61-4009-9867-802809da63cd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>1000</maximum>
  <randomizable group="0">false</randomizable>
  <value>100</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>posrand</objectName>
  <x>429</x>
  <y>480</y>
  <width>76</width>
  <height>27</height>
  <uuid>{d9780cbd-e79a-4741-b575-2a2a49790067}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>0.00100000</resolution>
  <minimum>0</minimum>
  <maximum>1000</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>transp</objectName>
  <x>164</x>
  <y>562</y>
  <width>76</width>
  <height>27</height>
  <uuid>{20a7f015-fe29-40d1-ac20-589371f9685d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>-10000</minimum>
  <maximum>10000</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>centrand</objectName>
  <x>506</x>
  <y>561</y>
  <width>76</width>
  <height>27</height>
  <uuid>{0cc8b907-1cb3-425d-b6f5-994a39abb647}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>1000</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>dbrange</objectName>
  <x>421</x>
  <y>289</y>
  <width>79</width>
  <height>27</height>
  <uuid>{81528aba-64e8-4dc7-b127-daa1434195a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>left</alignment>
  <font>Noto Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>0.10000000</resolution>
  <minimum>1</minimum>
  <maximum>1e+12</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>334</x>
  <y>288</y>
  <width>90</width>
  <height>29</height>
  <uuid>{cc0e0187-e5c9-4b44-b8c0-28d00d45cb89}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>dB-Range</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Nimbus Sans L</font>
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
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>145</x>
  <y>289</y>
  <width>110</width>
  <height>27</height>
  <uuid>{df57c2f7-4a74-460f-9f7f-b3efb8106306}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Show LED's as</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Nimbus Sans L</font>
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
 <bsbObject version="2" type="BSBDropdown">
  <objectName>showdb</objectName>
  <x>254</x>
  <y>289</y>
  <width>80</width>
  <height>28</height>
  <uuid>{d09ab184-f4b1-4340-8730-e73b870bcf9a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>raw amps</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>dB</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>1</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>inchnl</objectName>
  <x>105</x>
  <y>290</y>
  <width>47</width>
  <height>27</height>
  <uuid>{2fce6993-35f8-4dd7-bedd-f809c0803989}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <alignment>right</alignment>
  <font>DejaVu Sans</font>
  <fontsize>14</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
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
  <x>5</x>
  <y>289</y>
  <width>102</width>
  <height>29</height>
  <uuid>{df02308f-b978-4275-817e-1ad38c5b30d5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Input Channel</label>
  <alignment>right</alignment>
  <valignment>top</valignment>
  <font>Nimbus Sans L</font>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
<EventPanel name="" tempo="60.00000000" loop="8.00000000" x="360" y="248" width="612" height="322" visible="false" loopStart="0" loopEnd="0">    </EventPanel>

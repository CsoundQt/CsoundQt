;-------------------------------------------------------------------------
; Drone Instrument/Sruti Box
; by Dave Seidel <mysterybear.net/>
; with contributions from joachim heintz
; and Andres Cabrera.
;
; Written with Csound 5.12.1 (http://www.csounds.com)
; and CsoundQt 0.6.0 (http://CsoundQt.sourceforge.net/).
;
; To use, open in CsoundQt, make sure the Widgets window
; is open, and click the Start button.  Then use On/Off
; buttons to play or stop the drones.
;
; version 2.7 (09-Oct-2010)
;	- always play primary oscillator for each tone, independent of
;	  harmonic arpeggio or binaural beat output
;	- made all pitch controls (Ratio, 8ve, and Base) changeable in realtime
;	- add option to tune base frequency to conventional (Western) pitches,
;	  using pitch-class or note name 
; version 2.6 (26-Sep-2010)
;	- add level control for Risset effect (now labeled Harmonic Arpeggio);
;	  this allows the use of binaural beating by itself
;	- line up all effects horizontally
;	- use SpinBox for Harmonic Arpeggio Offset and Binaural Beats BPS, for
;	  finer control
;	- normalize level controls to use 0.0-1.0 range
;	- change multiplier for BB level from 5x to 4x, seems to match HA level better
;	- layout tweakage
; version 2.5 (12-Sep-2010)
;	- add precision to the base freq. per David First
; version 2.4 (12-Sep-2010)
;	- bugfix from Mark Van Peteghem in the binauralize UDO
; version 2.3 (10-Sep-2010)
;	- fixes from Andres
; version 2.2 (09-Sep-2010)
;	- binaural beat and reverb controls
;	- make Risset offset realtime
; version 2.1 (06-Sep-2010)
;	- fixed release on turnoff
;	- better "on" indicators fron joachim
;	- added binaural beating effect
; version 2.0 (06-Sep-2010)
;	- rewrite for CsoundQt
;
; Copyright 2005,2010, Dave Seidel. Some rights reserved.
; This work is licensed under a Creative Commons
; Attribution-Noncommercial 3.0 Unported License:
; http://creativecommons.org/licenses/by-nc/3.0/
;-------------------------------------------------------------------------

<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

;-------------------------------------------------------------------------
; globals
;-------------------------------------------------------------------------

sr     = 44100
ksmps  = 128
nchnls = 2
0dbfs  = 1

;-------------------------------------------------------------------------
; global channels
;-------------------------------------------------------------------------

gaL		init	0
gaR		init	0

;-------------------------------------------------------------------------
; waveform tables
;-------------------------------------------------------------------------

giTblSz	init		1048576

; pure sine wave
giFn1	ftgen	1, 0, giTblSz, 10, 1


; sawtooth wave  all partials (through 17) at a strength of 1/harmonic#
giFn2	ftgen	2, 0, giTblSz, 10, 1, .5, .3333, .25, .2, .1667, .1428, .125, .111, .1, .0909, .0833, .077, .0714, .0667, .0625, .0588

; first 13 partials, strength = 1/n + 1/(n-1)
giFn3	ftgen	3, 0, giTblSz, 10, 1, 1.5,  .8333, .58, .45, .367, .31, .268,  .236, .211, .1909, .1742, .1603


; square wave  odd partials (through 19) at a strength of 1/harmonic#
giFn4	ftgen	4, 0, giTblSz, 9,  1,1,0,  3,.3333,0, 5,.2,0,     7,.1428,0, 9,.111,0,  11,.0909,0,  13,.077,0,  15,.0667,0,  17,.0588,0,  19,.0526,0

; odd partials to 19, strength = 1/n, where n is ordinal to the odd set
giFn5	ftgen	5, 0, giTblSz, 9,  1,1,0,  3,.5,0,    5,.3333,0,  7,.25,0,   9,.2,0,    11,.1667,0,  13,.1429,0, 15,.125,0,   17,.1111,0,  19,.1,0


; prime partials to 23, strength = 1/n
giFn6	ftgen	6, 0, giTblSz, 9,  1,1,0,  2,.5,0,  3,.3333,0,  5,.2,0,    7,.143,0,  11,.0909,0,  13,.077,0,   17,.0588,0,  19,.0526,0, 23,.0435,0, 27,.037,0

; primes to 23, strength = 1/n, where n is ordinal to the prime set
giFn7	ftgen	7, 0, giTblSz, 9,  1,1,0,  2,.5,0,  3,.3333,0,  5,.25,0,   7,.20,0,   11,.1667,0,  13,.1429,0,  17,.125,0,   19,.1111,0, 23,.1,0,    27,.0909,0


; partials in the Fibonacci series to 89, strength = 1/n
giFn8	ftgen	8, 0, giTblSz, 9,  1,1,0,   2,.5,0,   3,.3333,0,  5,.2,0,   8,.125,0,  13,.0769,0,  21,.0476,0,  34,.0294,0,  55,.0182,0,  89,.0112,0, 144,.0069,0

; fibs to 89, strength = 1/n, where n is ordinal to the fib set
giFn9	ftgen	9, 0, giTblSz, 9,  1,1,0,   2,.5,0,   3,.3333,0,  5,.25,0,  8,.2,0,    13,.1667,0,  21,.1429,0,  34,.125,0,   55,.1111,0,  89,.1,0,   144,.0909,0


; David First's "asymptotic sawtooth wave"
giFn10	ftgen	10, 0, giTblSz, 9,  1,1,0,   1.732050807568877,.5773502691896259,0,   2.449489742783178,.408248290463863,0,   3.162277660168379,.3162277660168379,0,   3.872983346207417,.2581988897471611,0,   4.58257569495584,.2182178902359924,0,   5.291502622129182,.1889822365046136,0, 6,.1666666666666667,0,   6.70820393249937,.1490711984999859,0,   7.416198487095663,.1348399724926484,0,   8.124038404635961,.1230914909793327,0,   9.539392014169456,.1048284836721918,0,  10.2469507659596,.0975900072948533,0,  10.95445115010332,.0912870929175277,0,   11.6619037896906,.0857492925712544,0

;-------------------------------------------------------------------------
; basic offset value for Risset effect
;-------------------------------------------------------------------------

giofs   	init		.01

;-------------------------------------------------------------------------
; multipler for binaural beat level
;-------------------------------------------------------------------------

gibblvl	init    	4

;-------------------------------------------------------------------------
; FFT size for pvsanal
;-------------------------------------------------------------------------

gifftsz	init		2048

;-------------------------------------------------------------------------
; initialize globals for values from UI
;-------------------------------------------------------------------------

gktbl	init		0
gkbase	init		0

;---------------------------------------------------------------------------
; orchestra macros
;---------------------------------------------------------------------------

; base pitch in specified octave above base
#define BOCT(B'O) #$B.*(2^($O.))#

;---------------------------------------------------------------------------------------
; panner
;---------------------------------------------------------------------------------------

	opcode pan_equal_power, aa, ak
ain, kpan	xin
kangl	= 	1.57079633 * (kpan + 0.5)
		xout	ain * sin(kangl), ain * cos(kangl)
	endop

;---------------------------------------------------------------------------
; make binaural beats
;---------------------------------------------------------------------------

	opcode binauralize, aa, akk

ain,kcent,kdiff	xin

; determine pitches
kp1		=		kcent + (kdiff/2)
kp2		=		kcent - (kdiff/2)
krat1	=		kp1 / kcent
krat2	=		kp2 / kcent

; take it apart
fsig		pvsanal	ain, gifftsz, gifftsz/4, gifftsz, 1

; create derived streams
fbinL	pvscale	fsig, krat1, 1
fbinR	pvscale	fsig, krat2, 1

; put it back together
abinL	pvsynth	fbinL
abinR	pvsynth	fbinR

; send it out
		xout	abinL, abinR

	endop
	
;---------------------------------------------------------------------------
; oscillators with optional Risset harmonic arpeggio and binaural beating
;---------------------------------------------------------------------------

	instr 3 ; oscillators

itone	=		p4
iamp		=		ampdb(-15)/9
ipan		=		0.0
itbl		=		i(gktbl)

kgoto kpass
; Send this value only in the init pass
Sdsp_c	sprintf	"disp_on_c%d", itone
		outvalue	Sdsp_c, 1
kpass:

; which tone is being played?
	if (itone == 1) then
knum		invalue	"n_1"
kden		invalue	"d_1"
k8ve1	invalue	"8ve_1"
kbase	=		$BOCT.(gkbase'k8ve1)
	elseif (itone == 2) then
knum		invalue	"n_2"
kden		invalue	"d_2"
k8ve2	invalue	"8ve_2"
kbase	=		$BOCT.(gkbase'k8ve2)
	elseif (itone == 3) then
knum		invalue	"n_3"
kden		invalue	"d_3"
k8ve3	invalue	"8ve_3"
kbase	=		$BOCT.(gkbase'k8ve3)
	elseif (itone == 4) then
knum		invalue	"n_4"
kden		invalue	"d_4"
k8ve4	invalue	"8ve_4"
kbase	=		$BOCT.(gkbase'k8ve4)
	endif

;; determine pitch
kfrac	=		knum/kden
kfreq	=		kbase*kfrac

; set up Risset effect
koff		invalue	"risset_offset"
koff0	=		((kden*2)/knum)*koff		; inversely proportional to ratio
koff1	=		koff0					; oscillator offset for arpeggio
koff2	=		2*koff					; .
koff3	=		3*koff					; .
koff4	=		4*koff					; .

;; envelope
kenv		linenr	iamp, 2, 3, 0.01			; env needs release segment for turnoff2

; generate primary tone
a1		poscil3	kenv, kfreq, itbl

; generate Risset tones
a2		poscil3	kenv, kfreq+koff1, itbl		; nine oscillators with the same envelope
a3		poscil3	kenv, kfreq+koff2, itbl		; and waveform, but slightly different
a4		poscil3	kenv, kfreq+koff3, itbl		; frequencies, create harmonic arpeggio
a5		poscil3	kenv, kfreq+koff4, itbl
a6		poscil3	kenv, kfreq-koff1, itbl
a7		poscil3	kenv, kfreq-koff2, itbl
a8		poscil3	kenv, kfreq-koff3, itbl
a9		poscil3	kenv, kfreq-koff4, itbl

; create simple output (just the primary oscillator)
a1L, a1R	pan_equal_power	a1, ipan

;; create Risset output
krismix	invalue	"risset_mix"
aout		sum		a2, a3, a4, a5, a6, a7, a8, a9
a2L,a2R	pan_equal_power	aout*krismix, ipan

;; create binaural beating output
kbbmix	invalue	"bb_mix"
kbbrate	invalue	"bb_rate"
a3L,a3R	binauralize	a1*(kbbmix*gibblvl), kfreq, kbbrate

; combine and send to global output channels
gaL		=		gaL+a1L+a2L+a3L
gaR		=		gaR+a1R+a2R+a3R

	endin
	
;-------------------------------------------------------------------------
; turn off a tone
;-------------------------------------------------------------------------

	instr 4

itone	=	p4

Sdsp_c	sprintf	"disp_on_c%d", itone
		outvalue	Sdsp_c, 0

	if (itone == 1) then
		turnoff2	3.1, 4, 1
	elseif (itone == 2) then
		turnoff2	3.2, 4, 1
	elseif (itone == 3) then
		turnoff2	3.3, 4, 1
	elseif (itone == 4) then
		turnoff2	3.4, 4, 1
	endif

	endin

;-------------------------------------------------------------------------
; stop everything and quit
;-------------------------------------------------------------------------

	instr 5
	
		turnoff2	1, 0, 0
		turnoff2	3.1, 4, 1
		turnoff2	3.2, 4, 1
		turnoff2	3.3, 4, 1
		turnoff2	3.4, 4, 1
		outvalue	"disp_on_c1", 0
		outvalue	"disp_on_c2", 0
		outvalue	"disp_on_c3", 0
		outvalue	"disp_on_c4", 0
		exitnow

	endin

;---------------------------------------------------------------------------
; get/set base pitch and waveform
;---------------------------------------------------------------------------

	instr 98

; base pitch
knotes	invalue	"cb_use_notes"
	if (knotes == 0) then
	; tuning by cycles per second
kbase0	invalue	"base_freq"
koct		=		octcps(kbase0)
kpch		=		pchoct(koct)
kpch_i	=		int(kpch)
kpch_f	=		frac(kpch)
;		outvalue	"base_pch_int", kpch_i
;		outvalue	"base_pch_frac", kpch_f
	else
	; tuning by pitch-class
kpch_i	invalue	"base_pch_int"
kpch_f	invalue	"base_pch_frac"
kbase0	=		cpspch(kpch_i+(kpch_f/100))
		outvalue	"base_freq", kbase0
	endif
gkbase	=		kbase0

; waveform
ktbl		invalue	"menu_waveform"
gktbl	=		ktbl+1

	endin
;---------------------------------------------------------------------------
; global output instrument with optional reverb
;---------------------------------------------------------------------------

	instr 99
	
kfb		invalue	"reverb_feedback"
		outvalue	"feedback_display", kfb
kwet		invalue	"reverb_level"

aL, aR	reverbsc	gaL, gaR, kfb, p4, sr/1.5, p5, 0
aoutL 	=		(gaL * kwet) + (aL * (1 - kwet))
aoutR 	=		(gaR * kwet) + (aR * (1 - kwet))
		outs		gaL+aoutL, gaR+aoutR
gaL		=	0
gaR		=	0
	
	endin

</CsInstruments>
<CsScore>

;---------------------------------------------------------------------------
; score
;---------------------------------------------------------------------------

; start reading UI values
i98 0 36000

; start output
i99 1 36000 4000 .2

e

</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>375</x>
 <y>143</y>
 <width>642</width>
 <height>563</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>85</r>
  <g>170</g>
  <b>127</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>60</y>
  <width>55</width>
  <height>25</height>
  <uuid>{e207fe11-0cdd-444e-930d-29bf13c11fb2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Drone 1</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>n_1</objectName>
  <x>70</x>
  <y>60</y>
  <width>48</width>
  <height>25</height>
  <uuid>{69bad91e-0026-4238-862e-12c143685397}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <maximum>2048</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>118</x>
  <y>60</y>
  <width>11</width>
  <height>25</height>
  <uuid>{dac04e90-40e6-4165-b183-03b8f10511e3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>d_1</objectName>
  <x>129</x>
  <y>60</y>
  <width>48</width>
  <height>25</height>
  <uuid>{ef99bd92-1c6f-45f9-a32a-303c366b3332}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <maximum>2048</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>d_2</objectName>
  <x>129</x>
  <y>90</y>
  <width>48</width>
  <height>25</height>
  <uuid>{aabc2b30-dc79-43af-88df-b977177aa58e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <maximum>2048</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>118</x>
  <y>90</y>
  <width>11</width>
  <height>25</height>
  <uuid>{c3be46e9-f371-406a-ac25-0e0e07ac5c5f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>n_2</objectName>
  <x>70</x>
  <y>90</y>
  <width>48</width>
  <height>25</height>
  <uuid>{c32d5493-922d-4709-9f5a-56985fbb0475}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <maximum>2048</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>90</y>
  <width>55</width>
  <height>25</height>
  <uuid>{e92844b5-0073-4da6-8d9b-991e8b0b0499}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Drone 2</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>d_3</objectName>
  <x>129</x>
  <y>120</y>
  <width>48</width>
  <height>25</height>
  <uuid>{af1ed01f-25bf-4565-85f8-0448d63214d8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <maximum>2048</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>118</x>
  <y>120</y>
  <width>11</width>
  <height>25</height>
  <uuid>{07939aa1-6316-462f-8be9-976d94429e3a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>n_3</objectName>
  <x>70</x>
  <y>120</y>
  <width>48</width>
  <height>25</height>
  <uuid>{8e26cac5-5faa-410e-b2c2-1342978a5366}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <maximum>2048</maximum>
  <randomizable group="0">false</randomizable>
  <value>4</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>120</y>
  <width>55</width>
  <height>25</height>
  <uuid>{4df54217-074b-4984-b37d-2f9c0bfeadcc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Drone 3</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <x>7</x>
  <y>150</y>
  <width>55</width>
  <height>25</height>
  <uuid>{0ee4b373-0ead-405e-8333-c73008d4fd11}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Drone 4</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>n_4</objectName>
  <x>70</x>
  <y>150</y>
  <width>48</width>
  <height>25</height>
  <uuid>{09f87a96-555a-445a-82bd-478afb7abfb5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <maximum>2048</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>118</x>
  <y>150</y>
  <width>11</width>
  <height>25</height>
  <uuid>{f216eb31-db8e-4ec4-be43-5c9f0c1aa2a0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>:</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>d_4</objectName>
  <x>129</x>
  <y>150</y>
  <width>48</width>
  <height>25</height>
  <uuid>{756d7d97-b16b-4877-a1a2-1a4f05a4753f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <maximum>2048</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>_Play</objectName>
  <x>69</x>
  <y>524</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2f45e5ba-8d31-47a1-abfd-284ee246c74d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Start</text>
  <image>/</image>
  <eventLine>i 3 0 -1</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>btn_stop</objectName>
  <x>176</x>
  <y>524</y>
  <width>100</width>
  <height>30</height>
  <uuid>{8cfc7c9f-c14b-4e0a-969e-8c73d0e76eca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Stop</text>
  <image>/</image>
  <eventLine>i5 0 1</eventLine>
  <latch>false</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>base_freq</objectName>
  <x>71</x>
  <y>195</y>
  <width>120</width>
  <height>25</height>
  <uuid>{983d831d-92f7-4f17-9b74-9dab7db7059f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
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
  <minimum>1</minimum>
  <maximum>20000</maximum>
  <randomizable group="0">false</randomizable>
  <value>97.9933</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>196</y>
  <width>65</width>
  <height>25</height>
  <uuid>{3505dfd5-a0ec-404f-8e71-ec9c3e53e7a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Base (Hz)</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>menu_waveform</objectName>
  <x>69</x>
  <y>239</y>
  <width>114</width>
  <height>30</height>
  <uuid>{5a9958a4-4a24-4c2e-8a93-9c900fc8b294}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>  Sine</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>  Saw 1</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>  Saw 2</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>  Square 1</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>  Square 2</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>  Prime 1</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>  Prime 2</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>  Fib 1</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>  Fib 2</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>  Asymptotic Saw</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>4</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>242</y>
  <width>55</width>
  <height>25</height>
  <uuid>{d2a792b5-5a54-4a15-894b-ff3ddf0d8dbf}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Wave</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <x>389</x>
  <y>355</y>
  <width>67</width>
  <height>25</height>
  <uuid>{2438c973-bcba-42b8-88c3-7adcaed53eb1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Feedback</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>8ve_1</objectName>
  <x>205</x>
  <y>60</y>
  <width>35</width>
  <height>25</height>
  <uuid>{c398c0c6-f76b-464f-a86c-51e15765a9dd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <minimum>-6</minimum>
  <maximum>6</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>8ve_2</objectName>
  <x>205</x>
  <y>90</y>
  <width>35</width>
  <height>25</height>
  <uuid>{051c6d7f-a070-42a6-8a8e-710d1439c9f5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <minimum>-6</minimum>
  <maximum>6</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>8ve_3</objectName>
  <x>205</x>
  <y>120</y>
  <width>35</width>
  <height>25</height>
  <uuid>{4e4f3e61-cb8d-49bd-94e4-92f77b8dda9f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <minimum>-6</minimum>
  <maximum>6</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>8ve_4</objectName>
  <x>205</x>
  <y>150</y>
  <width>35</width>
  <height>25</height>
  <uuid>{7185c5c5-613c-4002-ad91-7d7351bf3e43}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
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
  <minimum>-6</minimum>
  <maximum>6</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>99</x>
  <y>31</y>
  <width>50</width>
  <height>25</height>
  <uuid>{32c98c25-6b0c-44ae-8aab-66b7991a0c3c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Ratio</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <x>205</x>
  <y>31</y>
  <width>35</width>
  <height>25</height>
  <uuid>{b6aa167a-e0fb-495a-82bf-45a5ef1fabee}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>8ve</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <x>206</x>
  <y>435</y>
  <width>60</width>
  <height>25</height>
  <uuid>{f0263ce2-9501-41a2-b3ab-203447d7ec93}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>BPS</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <x>215</x>
  <y>356</y>
  <width>70</width>
  <height>25</height>
  <uuid>{4e5e56dd-ef75-421b-9168-48c7a3c2f396}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Level</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
 <bsbObject version="2" type="BSBKnob">
  <objectName>bb_mix</objectName>
  <x>283</x>
  <y>324</y>
  <width>80</width>
  <height>80</height>
  <uuid>{0764d8d5-22a9-489d-8ae5-4e19e0567038}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.55000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>reverb_feedback</objectName>
  <x>456</x>
  <y>324</y>
  <width>80</width>
  <height>80</height>
  <uuid>{77d49f7c-db91-404a-bede-14601a37da3d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.93000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>68</x>
  <y>292</y>
  <width>130</width>
  <height>30</height>
  <uuid>{f20e492d-a935-480f-b37f-8bce3552de37}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Harmonic Arpeggio</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>395</x>
  <y>435</y>
  <width>42</width>
  <height>26</height>
  <uuid>{69b5965f-ef1f-449f-9e76-0f2c7ba86ae5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Wet</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>feedback_display</objectName>
  <x>456</x>
  <y>404</y>
  <width>80</width>
  <height>25</height>
  <uuid>{bbaf98ce-16fe-4bea-82db-1aa7909b40bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
  <color>
   <r>0</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <value>0.93000001</value>
  <resolution>0.00100000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>bb_mix</objectName>
  <x>283</x>
  <y>404</y>
  <width>80</width>
  <height>25</height>
  <uuid>{78afa9a1-f836-4547-8d80-81486db02073}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
  <color>
   <r>0</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <value>0.55000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>5.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>reverb_level</objectName>
  <x>434</x>
  <y>435</y>
  <width>120</width>
  <height>25</height>
  <uuid>{4e72262c-67a7-4b25-b963-2cbae66d3ebd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.51666667</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>554</x>
  <y>435</y>
  <width>46</width>
  <height>27</height>
  <uuid>{f703a53a-5a85-4f19-8c0d-6d391fde0794}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Dry</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>bb_rate</objectName>
  <x>264</x>
  <y>435</y>
  <width>120</width>
  <height>25</height>
  <uuid>{5973dd8b-43a5-4e78-9fa9-19ff5ea90107}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>50.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>risset_offset</objectName>
  <x>80</x>
  <y>435</y>
  <width>130</width>
  <height>25</height>
  <uuid>{5d4975a8-7006-449c-8c23-6d3b3dfa80f7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.87692308</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>268</x>
  <y>292</y>
  <width>102</width>
  <height>30</height>
  <uuid>{72bb78eb-c17b-444d-ab8c-458b1edf0e7d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Binaural Beats</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>465</x>
  <y>292</y>
  <width>60</width>
  <height>30</height>
  <uuid>{53253bed-f55d-4864-ab60-d4b0906df846}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Reverb</label>
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
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>2</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>70</x>
  <y>3</y>
  <width>270</width>
  <height>25</height>
  <uuid>{6c37ef1c-719c-4f0b-915d-c8bb75376e39}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Sruti/Drone Box 2.7 - Dave Seidel &lt;mysterybear.net/></label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>11</fontsize>
  <precision>3</precision>
  <color>
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>risset_offset</objectName>
  <x>99</x>
  <y>460</y>
  <width>90</width>
  <height>25</height>
  <uuid>{f82caad1-7fd6-447a-98af-1416902075f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <resolution>0.01000000</resolution>
  <minimum>0</minimum>
  <maximum>1</maximum>
  <randomizable group="0">false</randomizable>
  <value>0.876923</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>bb_rate</objectName>
  <x>278</x>
  <y>460</y>
  <width>95</width>
  <height>25</height>
  <uuid>{e8c0a39e-2286-4754-bcd1-e6799ba36fa2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <minimum>0</minimum>
  <maximum>50</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>21</x>
  <y>435</y>
  <width>60</width>
  <height>25</height>
  <uuid>{8e757ace-4ed5-4de8-b95f-c9fcba0f68d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Offset</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>risset_mix</objectName>
  <x>96</x>
  <y>404</y>
  <width>80</width>
  <height>25</height>
  <uuid>{50511459-bbcd-4f22-8b93-4eb9cea421d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
  <color>
   <r>0</r>
   <g>255</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <value>0.53000000</value>
  <resolution>0.01000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>3</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>risset_mix</objectName>
  <x>96</x>
  <y>324</y>
  <width>80</width>
  <height>80</height>
  <uuid>{0740fcea-a7ec-4b55-b483-daf2f0f87e40}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.53000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>28</x>
  <y>357</y>
  <width>70</width>
  <height>25</height>
  <uuid>{3ab28aff-4bce-4d36-ba26-65c92ebe6b8e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Level</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>base_pch_int</objectName>
  <x>278</x>
  <y>195</y>
  <width>40</width>
  <height>25</height>
  <uuid>{f234e643-9206-45d2-90cc-21903a1a0b08}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <resolution>1.00000000</resolution>
  <minimum>4</minimum>
  <maximum>9</maximum>
  <randomizable group="0">false</randomizable>
  <value>6</value>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>base_pch_frac</objectName>
  <x>327</x>
  <y>195</y>
  <width>40</width>
  <height>25</height>
  <uuid>{53ac49f4-196e-48d5-817c-dac614e8d692}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
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
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>11</maximum>
  <randomizable group="0">false</randomizable>
  <value>7</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>base_pch_frac</objectName>
  <x>373</x>
  <y>195</y>
  <width>59</width>
  <height>25</height>
  <uuid>{0f0d344d-e4ed-48c9-a710-9b2e2d5533c4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name> C</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> C#</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> D</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> D#</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> E</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> F</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> F#</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> G</name>
    <value>7</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> G#</name>
    <value>8</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> A</name>
    <value>9</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> A#</name>
    <value>10</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name> B</name>
    <value>11</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>7</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>cb_use_notes</objectName>
  <x>253</x>
  <y>198</y>
  <width>20</width>
  <height>20</height>
  <uuid>{e14b7297-ea7c-42dd-9a08-e62468e528ad}</uuid>
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
  <x>188</x>
  <y>195</y>
  <width>67</width>
  <height>25</height>
  <uuid>{05a8ce7a-1422-45f1-846a-93ef4493186f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Notes</label>
  <alignment>right</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <x>316</x>
  <y>195</y>
  <width>11</width>
  <height>25</height>
  <uuid>{1e42d19e-eb6d-48ef-a29a-3392d8b898c3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>.</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>13</fontsize>
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
  <objectName>btn_on3</objectName>
  <x>302</x>
  <y>120</y>
  <width>82</width>
  <height>26</height>
  <uuid>{2dcc0403-16c4-45e2-9427-3b5b46f1e84b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On</text>
  <image>/</image>
  <eventLine>i 3.3 0 -1 3</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>btn_on4</objectName>
  <x>302</x>
  <y>150</y>
  <width>82</width>
  <height>26</height>
  <uuid>{92247f2b-7cb0-4ba8-bc03-03361e1a10bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On</text>
  <image>/</image>
  <eventLine>i 3.4 0 -1 4</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>btn_on2</objectName>
  <x>302</x>
  <y>90</y>
  <width>82</width>
  <height>26</height>
  <uuid>{11e96f5c-80dd-4079-b41d-d64a0a0eeaf4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On</text>
  <image>/</image>
  <eventLine>i 3.2 0 -1 2</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>btn_on1</objectName>
  <x>302</x>
  <y>60</y>
  <width>82</width>
  <height>26</height>
  <uuid>{0597468a-539e-46ff-ac9e-d27938ee4929}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On</text>
  <image>/</image>
  <eventLine>i 3.1 0 -1 1</eventLine>
  <latch>true</latch>
  <latched>false</latched>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="magic (not lmy)" number="0" >
<value id="{69bad91e-0026-4238-862e-12c143685397}" mode="1" >4.00000000</value>
<value id="{ef99bd92-1c6f-45f9-a32a-303c366b3332}" mode="1" >3.00000000</value>
<value id="{aabc2b30-dc79-43af-88df-b977177aa58e}" mode="1" >2.00000000</value>
<value id="{c32d5493-922d-4709-9f5a-56985fbb0475}" mode="1" >3.00000000</value>
<value id="{af1ed01f-25bf-4565-85f8-0448d63214d8}" mode="1" >8.00000000</value>
<value id="{8e26cac5-5faa-410e-b2c2-1342978a5366}" mode="1" >9.00000000</value>
<value id="{09f87a96-555a-445a-82bd-478afb7abfb5}" mode="1" >6.00000000</value>
<value id="{756d7d97-b16b-4877-a1a2-1a4f05a4753f}" mode="1" >5.00000000</value>
<value id="{2f45e5ba-8d31-47a1-abfd-284ee246c74d}" mode="4" >0</value>
<value id="{8cfc7c9f-c14b-4e0a-969e-8c73d0e76eca}" mode="4" >0</value>
<value id="{983d831d-92f7-4f17-9b74-9dab7db7059f}" mode="1" >60.00000000</value>
<value id="{5a9958a4-4a24-4c2e-8a93-9c900fc8b294}" mode="1" >5.00000000</value>
<value id="{c398c0c6-f76b-464f-a86c-51e15765a9dd}" mode="1" >2.00000000</value>
<value id="{051c6d7f-a070-42a6-8a8e-710d1439c9f5}" mode="1" >1.00000000</value>
<value id="{4e4f3e61-cb8d-49bd-94e4-92f77b8dda9f}" mode="1" >2.00000000</value>
<value id="{7185c5c5-613c-4002-ad91-7d7351bf3e43}" mode="1" >1.00000000</value>
<value id="{0597468a-539e-46ff-ac9e-d27938ee4929}" mode="4" >0</value>
<value id="{11e96f5c-80dd-4079-b41d-d64a0a0eeaf4}" mode="4" >0</value>
<value id="{92247f2b-7cb0-4ba8-bc03-03361e1a10bd}" mode="4" >0</value>
<value id="{2dcc0403-16c4-45e2-9427-3b5b46f1e84b}" mode="4" >0</value>
<value id="{08fb344f-e380-40a0-abd0-26225f0d1532}" mode="4" >0</value>
<value id="{c5b5e85b-86f3-45db-abf9-2399bda7e100}" mode="4" >0</value>
<value id="{f0946452-bea5-454b-876c-ec1571771c49}" mode="4" >0</value>
<value id="{c5a7748a-5eda-4033-9d22-aba27d00482a}" mode="4" >0</value>
<value id="{0764d8d5-22a9-489d-8ae5-4e19e0567038}" mode="1" >2.54999995</value>
<value id="{bd87c226-5077-4660-84e1-f4dafbfff356}" mode="1" >0.00000000</value>
<value id="{bd87c226-5077-4660-84e1-f4dafbfff356}" mode="2" >0.00000000</value>
<value id="{ab7d8f5b-2b2a-462c-8199-050ead18ba84}" mode="1" >0.00000000</value>
<value id="{ab7d8f5b-2b2a-462c-8199-050ead18ba84}" mode="2" >0.00000000</value>
<value id="{137d21e6-b6a2-4f9c-8495-111e5d44117e}" mode="1" >0.00000000</value>
<value id="{137d21e6-b6a2-4f9c-8495-111e5d44117e}" mode="2" >0.00000000</value>
<value id="{e4e782ae-e528-42d0-a9f3-57081bddbc78}" mode="1" >0.00000000</value>
<value id="{e4e782ae-e528-42d0-a9f3-57081bddbc78}" mode="2" >0.00000000</value>
<value id="{77d49f7c-db91-404a-bede-14601a37da3d}" mode="1" >0.86000001</value>
<value id="{bbaf98ce-16fe-4bea-82db-1aa7909b40bd}" mode="1" >0.86000001</value>
<value id="{78afa9a1-f836-4547-8d80-81486db02073}" mode="1" >1.25000000</value>
<value id="{4e72262c-67a7-4b25-b963-2cbae66d3ebd}" mode="1" >0.52499998</value>
<value id="{5973dd8b-43a5-4e78-9fa9-19ff5ea90107}" mode="1" >3.33333325</value>
<value id="{c4670c9c-b87f-421c-948a-dba5ad97fd56}" mode="1" >3.33333325</value>
<value id="{5d4975a8-7006-449c-8c23-6d3b3dfa80f7}" mode="1" >0.01000000</value>
<value id="{0c9e4c5b-29a1-4ebc-8a93-5dcfe792139d}" mode="1" >0.01000000</value>
</preset>
<preset name="magic2 (not lmy)" number="1" >
<value id="{69bad91e-0026-4238-862e-12c143685397}" mode="1" >4.00000000</value>
<value id="{ef99bd92-1c6f-45f9-a32a-303c366b3332}" mode="1" >3.00000000</value>
<value id="{aabc2b30-dc79-43af-88df-b977177aa58e}" mode="1" >2.00000000</value>
<value id="{c32d5493-922d-4709-9f5a-56985fbb0475}" mode="1" >3.00000000</value>
<value id="{af1ed01f-25bf-4565-85f8-0448d63214d8}" mode="1" >8.00000000</value>
<value id="{8e26cac5-5faa-410e-b2c2-1342978a5366}" mode="1" >9.00000000</value>
<value id="{09f87a96-555a-445a-82bd-478afb7abfb5}" mode="1" >6.00000000</value>
<value id="{756d7d97-b16b-4877-a1a2-1a4f05a4753f}" mode="1" >5.00000000</value>
<value id="{2f45e5ba-8d31-47a1-abfd-284ee246c74d}" mode="4" >0</value>
<value id="{8cfc7c9f-c14b-4e0a-969e-8c73d0e76eca}" mode="4" >0</value>
<value id="{983d831d-92f7-4f17-9b74-9dab7db7059f}" mode="1" >60.00000000</value>
<value id="{5a9958a4-4a24-4c2e-8a93-9c900fc8b294}" mode="1" >7.00000000</value>
<value id="{6e17afd2-2660-4517-809c-b8fccf81954e}" mode="1" >1.00000000</value>
<value id="{83621e9a-ebdd-48e3-9c0a-5119a5b774ff}" mode="1" >1.00000000</value>
<value id="{c398c0c6-f76b-464f-a86c-51e15765a9dd}" mode="1" >2.00000000</value>
<value id="{051c6d7f-a070-42a6-8a8e-710d1439c9f5}" mode="1" >1.00000000</value>
<value id="{4e4f3e61-cb8d-49bd-94e4-92f77b8dda9f}" mode="1" >2.00000000</value>
<value id="{7185c5c5-613c-4002-ad91-7d7351bf3e43}" mode="1" >1.00000000</value>
<value id="{0597468a-539e-46ff-ac9e-d27938ee4929}" mode="4" >0</value>
<value id="{11e96f5c-80dd-4079-b41d-d64a0a0eeaf4}" mode="4" >0</value>
<value id="{92247f2b-7cb0-4ba8-bc03-03361e1a10bd}" mode="4" >0</value>
<value id="{2dcc0403-16c4-45e2-9427-3b5b46f1e84b}" mode="4" >0</value>
<value id="{08fb344f-e380-40a0-abd0-26225f0d1532}" mode="4" >0</value>
<value id="{c5b5e85b-86f3-45db-abf9-2399bda7e100}" mode="4" >0</value>
<value id="{f0946452-bea5-454b-876c-ec1571771c49}" mode="4" >0</value>
<value id="{c5a7748a-5eda-4033-9d22-aba27d00482a}" mode="4" >0</value>
<value id="{861629eb-54a7-4279-a1d6-bc80092e5de8}" mode="1" >0.00000000</value>
<value id="{861629eb-54a7-4279-a1d6-bc80092e5de8}" mode="4" >+</value>
<value id="{2e26c27e-6482-4c37-8af3-8311086124d2}" mode="1" >0.00000000</value>
<value id="{2e26c27e-6482-4c37-8af3-8311086124d2}" mode="4" >+</value>
<value id="{83b48281-b5e8-4069-885b-fb91b7001e50}" mode="1" >0.00000000</value>
<value id="{83b48281-b5e8-4069-885b-fb91b7001e50}" mode="4" >+</value>
<value id="{e536df3b-c63a-4442-a900-b896234ff6ce}" mode="1" >0.00000000</value>
<value id="{e536df3b-c63a-4442-a900-b896234ff6ce}" mode="4" >+</value>
<value id="{022a7091-793d-43a7-a49e-a31f8b76c14d}" mode="1" >1.87500000</value>
<value id="{0764d8d5-22a9-489d-8ae5-4e19e0567038}" mode="1" >2.54999995</value>
</preset>
<preset name="faery bells" number="2" >
<value id="{69bad91e-0026-4238-862e-12c143685397}" mode="1" >15.00000000</value>
<value id="{ef99bd92-1c6f-45f9-a32a-303c366b3332}" mode="1" >8.00000000</value>
<value id="{aabc2b30-dc79-43af-88df-b977177aa58e}" mode="1" >15.00000000</value>
<value id="{c32d5493-922d-4709-9f5a-56985fbb0475}" mode="1" >16.00000000</value>
<value id="{af1ed01f-25bf-4565-85f8-0448d63214d8}" mode="1" >1.00000000</value>
<value id="{8e26cac5-5faa-410e-b2c2-1342978a5366}" mode="1" >2.00000000</value>
<value id="{09f87a96-555a-445a-82bd-478afb7abfb5}" mode="1" >1.00000000</value>
<value id="{756d7d97-b16b-4877-a1a2-1a4f05a4753f}" mode="1" >1.00000000</value>
<value id="{2f45e5ba-8d31-47a1-abfd-284ee246c74d}" mode="4" >0</value>
<value id="{8cfc7c9f-c14b-4e0a-969e-8c73d0e76eca}" mode="4" >0</value>
<value id="{983d831d-92f7-4f17-9b74-9dab7db7059f}" mode="1" >60.00000000</value>
<value id="{5a9958a4-4a24-4c2e-8a93-9c900fc8b294}" mode="1" >7.00000000</value>
<value id="{6e17afd2-2660-4517-809c-b8fccf81954e}" mode="1" >1.00000000</value>
<value id="{83621e9a-ebdd-48e3-9c0a-5119a5b774ff}" mode="1" >1.00000000</value>
<value id="{c398c0c6-f76b-464f-a86c-51e15765a9dd}" mode="1" >1.00000000</value>
<value id="{051c6d7f-a070-42a6-8a8e-710d1439c9f5}" mode="1" >2.00000000</value>
<value id="{4e4f3e61-cb8d-49bd-94e4-92f77b8dda9f}" mode="1" >1.00000000</value>
<value id="{7185c5c5-613c-4002-ad91-7d7351bf3e43}" mode="1" >1.00000000</value>
<value id="{0597468a-539e-46ff-ac9e-d27938ee4929}" mode="4" >0</value>
<value id="{11e96f5c-80dd-4079-b41d-d64a0a0eeaf4}" mode="4" >0</value>
<value id="{92247f2b-7cb0-4ba8-bc03-03361e1a10bd}" mode="4" >0</value>
<value id="{2dcc0403-16c4-45e2-9427-3b5b46f1e84b}" mode="4" >0</value>
<value id="{08fb344f-e380-40a0-abd0-26225f0d1532}" mode="4" >0</value>
<value id="{c5b5e85b-86f3-45db-abf9-2399bda7e100}" mode="4" >0</value>
<value id="{f0946452-bea5-454b-876c-ec1571771c49}" mode="4" >0</value>
<value id="{c5a7748a-5eda-4033-9d22-aba27d00482a}" mode="4" >0</value>
<value id="{022a7091-793d-43a7-a49e-a31f8b76c14d}" mode="1" >1.87500000</value>
<value id="{0764d8d5-22a9-489d-8ae5-4e19e0567038}" mode="1" >4.00000000</value>
<value id="{bd87c226-5077-4660-84e1-f4dafbfff356}" mode="1" >1.00000000</value>
<value id="{bd87c226-5077-4660-84e1-f4dafbfff356}" mode="2" >1.00000000</value>
<value id="{ab7d8f5b-2b2a-462c-8199-050ead18ba84}" mode="1" >1.00000000</value>
<value id="{ab7d8f5b-2b2a-462c-8199-050ead18ba84}" mode="2" >1.00000000</value>
<value id="{137d21e6-b6a2-4f9c-8495-111e5d44117e}" mode="1" >1.00000000</value>
<value id="{137d21e6-b6a2-4f9c-8495-111e5d44117e}" mode="2" >1.00000000</value>
<value id="{e4e782ae-e528-42d0-a9f3-57081bddbc78}" mode="1" >1.00000000</value>
<value id="{e4e782ae-e528-42d0-a9f3-57081bddbc78}" mode="2" >1.00000000</value>
</preset>
<preset name="faery bells 2" number="3" >
<value id="{69bad91e-0026-4238-862e-12c143685397}" mode="1" >15.00000000</value>
<value id="{ef99bd92-1c6f-45f9-a32a-303c366b3332}" mode="1" >8.00000000</value>
<value id="{aabc2b30-dc79-43af-88df-b977177aa58e}" mode="1" >15.00000000</value>
<value id="{c32d5493-922d-4709-9f5a-56985fbb0475}" mode="1" >16.00000000</value>
<value id="{af1ed01f-25bf-4565-85f8-0448d63214d8}" mode="1" >1.00000000</value>
<value id="{8e26cac5-5faa-410e-b2c2-1342978a5366}" mode="1" >2.00000000</value>
<value id="{09f87a96-555a-445a-82bd-478afb7abfb5}" mode="1" >3.00000000</value>
<value id="{756d7d97-b16b-4877-a1a2-1a4f05a4753f}" mode="1" >2.00000000</value>
<value id="{2f45e5ba-8d31-47a1-abfd-284ee246c74d}" mode="4" >0</value>
<value id="{8cfc7c9f-c14b-4e0a-969e-8c73d0e76eca}" mode="4" >0</value>
<value id="{983d831d-92f7-4f17-9b74-9dab7db7059f}" mode="1" >60.00000000</value>
<value id="{5a9958a4-4a24-4c2e-8a93-9c900fc8b294}" mode="1" >7.00000000</value>
<value id="{6e17afd2-2660-4517-809c-b8fccf81954e}" mode="1" >1.00000000</value>
<value id="{83621e9a-ebdd-48e3-9c0a-5119a5b774ff}" mode="1" >1.00000000</value>
<value id="{c398c0c6-f76b-464f-a86c-51e15765a9dd}" mode="1" >1.00000000</value>
<value id="{051c6d7f-a070-42a6-8a8e-710d1439c9f5}" mode="1" >2.00000000</value>
<value id="{4e4f3e61-cb8d-49bd-94e4-92f77b8dda9f}" mode="1" >1.00000000</value>
<value id="{7185c5c5-613c-4002-ad91-7d7351bf3e43}" mode="1" >1.00000000</value>
<value id="{0597468a-539e-46ff-ac9e-d27938ee4929}" mode="4" >0</value>
<value id="{11e96f5c-80dd-4079-b41d-d64a0a0eeaf4}" mode="4" >0</value>
<value id="{92247f2b-7cb0-4ba8-bc03-03361e1a10bd}" mode="4" >0</value>
<value id="{2dcc0403-16c4-45e2-9427-3b5b46f1e84b}" mode="4" >0</value>
<value id="{08fb344f-e380-40a0-abd0-26225f0d1532}" mode="4" >0</value>
<value id="{c5b5e85b-86f3-45db-abf9-2399bda7e100}" mode="4" >0</value>
<value id="{f0946452-bea5-454b-876c-ec1571771c49}" mode="4" >0</value>
<value id="{c5a7748a-5eda-4033-9d22-aba27d00482a}" mode="4" >0</value>
<value id="{022a7091-793d-43a7-a49e-a31f8b76c14d}" mode="1" >1.87500000</value>
<value id="{0764d8d5-22a9-489d-8ae5-4e19e0567038}" mode="1" >4.00000000</value>
<value id="{bd87c226-5077-4660-84e1-f4dafbfff356}" mode="1" >1.00000000</value>
<value id="{bd87c226-5077-4660-84e1-f4dafbfff356}" mode="2" >1.00000000</value>
<value id="{ab7d8f5b-2b2a-462c-8199-050ead18ba84}" mode="1" >1.00000000</value>
<value id="{ab7d8f5b-2b2a-462c-8199-050ead18ba84}" mode="2" >1.00000000</value>
<value id="{137d21e6-b6a2-4f9c-8495-111e5d44117e}" mode="1" >1.00000000</value>
<value id="{137d21e6-b6a2-4f9c-8495-111e5d44117e}" mode="2" >1.00000000</value>
<value id="{e4e782ae-e528-42d0-a9f3-57081bddbc78}" mode="1" >1.00000000</value>
<value id="{e4e782ae-e528-42d0-a9f3-57081bddbc78}" mode="2" >1.00000000</value>
</preset>
<preset name="root-fourth-fifth-octave" number="4" >
<value id="{69bad91e-0026-4238-862e-12c143685397}" mode="1" >2.00000000</value>
<value id="{ef99bd92-1c6f-45f9-a32a-303c366b3332}" mode="1" >1.00000000</value>
<value id="{aabc2b30-dc79-43af-88df-b977177aa58e}" mode="1" >2.00000000</value>
<value id="{c32d5493-922d-4709-9f5a-56985fbb0475}" mode="1" >3.00000000</value>
<value id="{af1ed01f-25bf-4565-85f8-0448d63214d8}" mode="1" >3.00000000</value>
<value id="{8e26cac5-5faa-410e-b2c2-1342978a5366}" mode="1" >4.00000000</value>
<value id="{09f87a96-555a-445a-82bd-478afb7abfb5}" mode="1" >1.00000000</value>
<value id="{756d7d97-b16b-4877-a1a2-1a4f05a4753f}" mode="1" >1.00000000</value>
<value id="{2f45e5ba-8d31-47a1-abfd-284ee246c74d}" mode="4" >0</value>
<value id="{8cfc7c9f-c14b-4e0a-969e-8c73d0e76eca}" mode="4" >0</value>
<value id="{983d831d-92f7-4f17-9b74-9dab7db7059f}" mode="1" >60.00000000</value>
<value id="{5a9958a4-4a24-4c2e-8a93-9c900fc8b294}" mode="1" >5.00000000</value>
<value id="{c398c0c6-f76b-464f-a86c-51e15765a9dd}" mode="1" >1.00000000</value>
<value id="{051c6d7f-a070-42a6-8a8e-710d1439c9f5}" mode="1" >1.00000000</value>
<value id="{4e4f3e61-cb8d-49bd-94e4-92f77b8dda9f}" mode="1" >1.00000000</value>
<value id="{7185c5c5-613c-4002-ad91-7d7351bf3e43}" mode="1" >1.00000000</value>
<value id="{0597468a-539e-46ff-ac9e-d27938ee4929}" mode="4" >0</value>
<value id="{11e96f5c-80dd-4079-b41d-d64a0a0eeaf4}" mode="4" >0</value>
<value id="{92247f2b-7cb0-4ba8-bc03-03361e1a10bd}" mode="4" >0</value>
<value id="{2dcc0403-16c4-45e2-9427-3b5b46f1e84b}" mode="4" >0</value>
<value id="{08fb344f-e380-40a0-abd0-26225f0d1532}" mode="4" >0</value>
<value id="{c5b5e85b-86f3-45db-abf9-2399bda7e100}" mode="4" >0</value>
<value id="{f0946452-bea5-454b-876c-ec1571771c49}" mode="4" >0</value>
<value id="{c5a7748a-5eda-4033-9d22-aba27d00482a}" mode="4" >0</value>
<value id="{0764d8d5-22a9-489d-8ae5-4e19e0567038}" mode="1" >2.04999995</value>
<value id="{bd87c226-5077-4660-84e1-f4dafbfff356}" mode="1" >0.00000000</value>
<value id="{bd87c226-5077-4660-84e1-f4dafbfff356}" mode="2" >0.00000000</value>
<value id="{ab7d8f5b-2b2a-462c-8199-050ead18ba84}" mode="1" >0.00000000</value>
<value id="{ab7d8f5b-2b2a-462c-8199-050ead18ba84}" mode="2" >0.00000000</value>
<value id="{137d21e6-b6a2-4f9c-8495-111e5d44117e}" mode="1" >0.00000000</value>
<value id="{137d21e6-b6a2-4f9c-8495-111e5d44117e}" mode="2" >0.00000000</value>
<value id="{e4e782ae-e528-42d0-a9f3-57081bddbc78}" mode="1" >0.00000000</value>
<value id="{e4e782ae-e528-42d0-a9f3-57081bddbc78}" mode="2" >0.00000000</value>
<value id="{77d49f7c-db91-404a-bede-14601a37da3d}" mode="1" >0.86000001</value>
<value id="{bbaf98ce-16fe-4bea-82db-1aa7909b40bd}" mode="1" >0.86000001</value>
<value id="{78afa9a1-f836-4547-8d80-81486db02073}" mode="1" >2.04999995</value>
<value id="{4e72262c-67a7-4b25-b963-2cbae66d3ebd}" mode="1" >0.52499998</value>
<value id="{5973dd8b-43a5-4e78-9fa9-19ff5ea90107}" mode="1" >1.25000000</value>
<value id="{c4670c9c-b87f-421c-948a-dba5ad97fd56}" mode="1" >1.25000000</value>
<value id="{5d4975a8-7006-449c-8c23-6d3b3dfa80f7}" mode="1" >0.01000000</value>
<value id="{0c9e4c5b-29a1-4ebc-8a93-5dcfe792139d}" mode="1" >0.01000000</value>
</preset>
<preset name="root-fifth-seventh-ninth" number="5" >
<value id="{69bad91e-0026-4238-862e-12c143685397}" mode="1" >9.00000000</value>
<value id="{ef99bd92-1c6f-45f9-a32a-303c366b3332}" mode="1" >8.00000000</value>
<value id="{aabc2b30-dc79-43af-88df-b977177aa58e}" mode="1" >4.00000000</value>
<value id="{c32d5493-922d-4709-9f5a-56985fbb0475}" mode="1" >7.00000000</value>
<value id="{af1ed01f-25bf-4565-85f8-0448d63214d8}" mode="1" >2.00000000</value>
<value id="{8e26cac5-5faa-410e-b2c2-1342978a5366}" mode="1" >3.00000000</value>
<value id="{09f87a96-555a-445a-82bd-478afb7abfb5}" mode="1" >1.00000000</value>
<value id="{756d7d97-b16b-4877-a1a2-1a4f05a4753f}" mode="1" >1.00000000</value>
<value id="{2f45e5ba-8d31-47a1-abfd-284ee246c74d}" mode="4" >0</value>
<value id="{8cfc7c9f-c14b-4e0a-969e-8c73d0e76eca}" mode="4" >0</value>
<value id="{983d831d-92f7-4f17-9b74-9dab7db7059f}" mode="1" >60.00000000</value>
<value id="{5a9958a4-4a24-4c2e-8a93-9c900fc8b294}" mode="1" >5.00000000</value>
<value id="{c398c0c6-f76b-464f-a86c-51e15765a9dd}" mode="1" >2.00000000</value>
<value id="{051c6d7f-a070-42a6-8a8e-710d1439c9f5}" mode="1" >1.00000000</value>
<value id="{4e4f3e61-cb8d-49bd-94e4-92f77b8dda9f}" mode="1" >1.00000000</value>
<value id="{7185c5c5-613c-4002-ad91-7d7351bf3e43}" mode="1" >1.00000000</value>
<value id="{0597468a-539e-46ff-ac9e-d27938ee4929}" mode="4" >0</value>
<value id="{11e96f5c-80dd-4079-b41d-d64a0a0eeaf4}" mode="4" >0</value>
<value id="{92247f2b-7cb0-4ba8-bc03-03361e1a10bd}" mode="4" >0</value>
<value id="{2dcc0403-16c4-45e2-9427-3b5b46f1e84b}" mode="4" >0</value>
<value id="{08fb344f-e380-40a0-abd0-26225f0d1532}" mode="4" >0</value>
<value id="{c5b5e85b-86f3-45db-abf9-2399bda7e100}" mode="4" >0</value>
<value id="{f0946452-bea5-454b-876c-ec1571771c49}" mode="4" >0</value>
<value id="{c5a7748a-5eda-4033-9d22-aba27d00482a}" mode="4" >0</value>
<value id="{0764d8d5-22a9-489d-8ae5-4e19e0567038}" mode="1" >1.00000000</value>
<value id="{bd87c226-5077-4660-84e1-f4dafbfff356}" mode="1" >1.00000000</value>
<value id="{bd87c226-5077-4660-84e1-f4dafbfff356}" mode="2" >1.00000000</value>
<value id="{ab7d8f5b-2b2a-462c-8199-050ead18ba84}" mode="1" >1.00000000</value>
<value id="{ab7d8f5b-2b2a-462c-8199-050ead18ba84}" mode="2" >1.00000000</value>
<value id="{137d21e6-b6a2-4f9c-8495-111e5d44117e}" mode="1" >1.00000000</value>
<value id="{137d21e6-b6a2-4f9c-8495-111e5d44117e}" mode="2" >1.00000000</value>
<value id="{e4e782ae-e528-42d0-a9f3-57081bddbc78}" mode="1" >1.00000000</value>
<value id="{e4e782ae-e528-42d0-a9f3-57081bddbc78}" mode="2" >1.00000000</value>
<value id="{77d49f7c-db91-404a-bede-14601a37da3d}" mode="1" >0.86000001</value>
<value id="{bbaf98ce-16fe-4bea-82db-1aa7909b40bd}" mode="1" >0.86000001</value>
<value id="{78afa9a1-f836-4547-8d80-81486db02073}" mode="1" >1.00000000</value>
<value id="{4e72262c-67a7-4b25-b963-2cbae66d3ebd}" mode="1" >0.52499998</value>
<value id="{5973dd8b-43a5-4e78-9fa9-19ff5ea90107}" mode="1" >1.25000000</value>
<value id="{5d4975a8-7006-449c-8c23-6d3b3dfa80f7}" mode="1" >0.02000000</value>
<value id="{f82caad1-7fd6-447a-98af-1416902075f6}" mode="1" >0.02000000</value>
<value id="{e8c0a39e-2286-4754-bcd1-e6799ba36fa2}" mode="1" >0.33333334</value>
<value id="{50511459-bbcd-4f22-8b93-4eb9cea421d9}" mode="1" >1.00000000</value>
<value id="{0740fcea-a7ec-4b55-b483-daf2f0f87e40}" mode="1" >1.00000000</value>
</preset>
</bsbPresets>

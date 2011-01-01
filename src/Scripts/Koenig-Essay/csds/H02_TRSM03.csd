<CsoundSynthesizer>

; Id: H02_TRSM03.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH02_TRSM03.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;====================================
; 286.3 SPRINGERMASCHINE
;====================================
; NOTE
; The functioning principles of the Springermaschine are not given in the score of Essay. The instrument used here
; is a standard transposition SOLA instrument.

	instr 1
itrasp	= p4		; transposition (in semitones)
ifile	= p5

idurw	= .01		; window length (maximum delay)
ifw	= 1/idurw	; window frequency (15.625 Hz)
ist	= 1.059463	; tempered semitone

interv	= ist^(itrasp)		; transposition factor
itraspo	= ifw * (interv-1)*(-1)	; phasor's frequency (negative sign inverts phase for transposing up, positive sign
				; for transpose down)

;	print ifw,interv,itraspo

asig	diskin2 ifile, 1	; signal input

ifrq	= 96000*interv		; anti-aliasing filter
asig	tonex asig , ifrq , 10
asig	tonex asig , ifrq , 10
asig	= asig*1.5

aph1	phasor	itraspo
aph2	phasor	itraspo, .5	; 180° out of phase from aph1

a1	table3 aph1 , 1, 1	; windowing signals
a1	= tanh(a1*5)
a2	table3 aph2 ,1, 1
a2	= tanh(a2*5)

adop1	= (aph1)*idurw		; pointers into delay lines
adop2	= (aph2)*idurw

adel1	delayr .3	
ad1	deltapx adop1,32
	delayw asig

adel2	delayr .3	 
ad2	deltapx adop2,32
	delayw asig

aout1	= ad1*a1		; applying windowing signals to transposed signals
aout2	= ad2*a2		

aout	= aout1+aout2

	out aout
	endin
;====================================

</CsInstruments>
<CsScore>
f1	0	8192	20	7 1 35	; gaussian window

t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			itrasp	ifile
;			[st]	
i1	0	171.5	-48	"H01.wav"

e

</CsScore>
</CsoundSynthesizer>
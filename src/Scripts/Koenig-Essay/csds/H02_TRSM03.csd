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
kr     = 192000
ksmps  = 1
nchnls = 1

;====================================
; 286.2 SPRINGERMASCHINE
;====================================
; NOTE
; The functioning principles of the Springermaschine are not given in the score of Essay. The instrument used here
; is a standard SOLA instrument.

	instr 1
isamp	= 1		; sample's function
iwf	= 2		; window function

iph	= 430870/ftlen(isamp)

aph	poscil3	iph, 1/p3, 3

idur	= .025
kdurR	rand .0001, 2, 1
kdur	= idur + kdurR
kenv	= kdur * .5

adens	= 167

a1	fog .6, adens, 1, aph, 0, 0, kenv, kdur, kenv, 5000, isamp, iwf, p3

	out a1
	endin
;====================================


</CsInstruments>
<CsScore>
f1	0	524288	-1	"H01.wav" 0 0 0 	; sample file (430870 samples)
f2	0	8192	20	7 1 35			; gaussian window
f3	0	32768	27	0 0 32767 1		; pointer



t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

i1	0	2736					; deceleration by 4 octaves
;		171*(2^4)

e

</CsScore>
</CsoundSynthesizer>
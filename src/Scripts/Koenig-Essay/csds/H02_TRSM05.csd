<CsoundSynthesizer>

; Id: H02_TRSM05.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH02_TRSM05.wav
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

iph	= 430866/ftlen(isamp)

aph	poscil3	iph, 1/p3, 3

idur	= .1
kdurR	rand .0001, 2, 1
kdur	= idur + kdurR
kenv	= idur * .5

adens	= 83

a1	fog .6, adens, 1, aph, 0, 0, kenv, idur, kenv, 5000, isamp, iwf, p3

	out a1
	endin
;====================================


</CsInstruments>
<CsScore>
f1	0	524288	-1	"H01.wav" 0 0 0 	; sample file (430866 samples)
f2	0	8192	20	7 1 35			; gaussian window
f3	0	32768	27	0 0 32767 1		; pointer


t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

i1	0	342					; deceleration by 1 octave
;		171*(2^1)
e

</CsScore>
</CsoundSynthesizer>
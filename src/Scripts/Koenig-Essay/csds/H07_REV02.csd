<CsoundSynthesizer>

; Id: H07_REV02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH07_REV02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 284.2 REVERBERATION
;=============================================
	instr 1
iampr	= ampdb(p4)
ifile	= p5

idel	= 5.6 ; 5.6 s * 76.2 = 426.72 cm

a1	diskin2 ifile, 1

ar	nreverb a1, 5, .3

; increasing reverberation only at the end
aenv	expseg .5,  .8, .03,  2  , .5, p3-12.8, .5, 3.952, .03
aenvr	expseg .5, .5,  .25,  2.5 ,  .25,   p3-3 , .5

aout	= (a1*aenv) + (ar*iampr*aenvr)
aout	atonex aout, 10

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			iampr	ifile
i1	0	1749	-2	"H06_TR02.wav"

;durrev= 5*76.2 = 381
; dur = 1368 + durrev
e

</CsScore>
</CsoundSynthesizer>
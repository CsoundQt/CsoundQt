<CsoundSynthesizer>

; Id: H07_REV05.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH07_REV05.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 284.5 REVERBERATION
;=============================================
	instr 1
iampr	= ampdb(p4)
ifile	= p5

a1	diskin2 ifile , 1

ar	nreverb a1, 5, .3

; decreasing and increasing reverberation
aenv	expseg 1, 4, .25, p3-4, .125
aenvr	expseg 1, 1.2, ampdb(-30),  1.4, 1,    p3-2.6, 1

aout	=  (a1*aenv) + (ar*aenvr*iampr)
aout	atonex aout, 10

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;				p4	p5
;				iampr	ifile
i1	0	864.6	 	-10	"H05_RM05.wav"

;durrev= 5*76.2 = 381
; dur = 483.6 + durrev
e

</CsScore>
</CsoundSynthesizer>
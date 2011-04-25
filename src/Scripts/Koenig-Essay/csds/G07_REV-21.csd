<CsoundSynthesizer>

; Id: G07_REV-21.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oG07_REV-21.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 274. REVERBERATION
; see 372.VII
;=============================================
	instr 1
ifile	= p4

a1	diskin2 ifile , 1, 0,1
ga1	= a1

	endin

	instr 2

iampr	= ampdb(p4)

a1	=ga1

ar	nreverb a1, 5, .3

aout	= (a1*.2) + (ar*iampr)
aout	atonex aout, 10

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 5.6*76.2 = 426.72 cm
;				p4
;				ifile
i1	0	12675		"G06_ABSCHNITT-2.wav"
;				iampr
i2	0	13056		-19

;durrev= 5*76.2 = 381
; dur = 12675 + durrev

e

</CsScore>
</CsoundSynthesizer>
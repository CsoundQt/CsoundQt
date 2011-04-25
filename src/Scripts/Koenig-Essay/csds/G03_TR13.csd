<CsoundSynthesizer>

; Id: G03_TR13.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oG03_TR13.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 272.13 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= p4
ifile	= p5

a1	diskin2 ifile, itrasp

	out a1
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			itrasp	ifile
i1	0	1207	1.0758	"G01.wav"	; 53.79/50=1.0758	

e

</CsScore>
</CsoundSynthesizer>
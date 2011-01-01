<CsoundSynthesizer>

; Id: F03_TR02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oF03_TR02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 262.2 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= -p4		; reads backwards
ifile	= p5

iskip	= 18.296

a1	diskin2  ifile, itrasp, iskip

	out a1
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			itrasp	ifile
i1	0	967.44	1	"F02_REVcancer.wav"; 50/50
; riverbero anteriore = 426.72*(1/1)= 426.72
e

</CsScore>
</CsoundSynthesizer>
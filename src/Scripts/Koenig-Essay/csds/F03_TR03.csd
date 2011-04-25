<CsoundSynthesizer>

; Id: F03_TR03.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oF03_TR03.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 262.3 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= -p4		; reads backwards
ifile	= p5

iskip	= 11.496

a1	diskin2  ifile, itrasp, iskip

	out a1
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			itrasp	ifile
i1	0	438	2	"F02_REVcancer.wav"	; 100/50
; pre-reverb = 381*(1/2)=190.5
e

</CsScore>
</CsoundSynthesizer>
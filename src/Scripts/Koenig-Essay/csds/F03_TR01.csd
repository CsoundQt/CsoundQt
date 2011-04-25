<CsoundSynthesizer>

; Id: F03_TR01.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oF03_TR01.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 262.1 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= -p4		; reads backwards
ifile	= p5

iskip	= 11.496

a1	diskin2  ifile, itrasp, iskip

ifrq	= sr*p4			; anti-aliasing filter
a1	tonex a1 , ifrq , 10
a1	tonex a1 , ifrq , 10

	out a1
	endin
;=============================================

</CsInstruments>
<CsScore>

t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			itrasp	ifile
i1	0	3504	.25	"F02_REVcancer.wav"	; 12.5/50
; pre-reverb = 381*(1/.25)= 1524
e

</CsScore>
</CsoundSynthesizer>
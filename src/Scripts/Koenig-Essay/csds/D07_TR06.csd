<CsoundSynthesizer>

; Id: D07_TR06.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oD07_TR06.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 242.6 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= p4
ifile	= p5

a1	diskin2 ifile, itrasp

ifrq	= sr*p4		; anti-aliasing filter
a1	tonex a1 , ifrq , 10
a1	tonex a1 , ifrq , 10

aenv	linseg 1, p3-.01, 1 , .01 , 0

	out a1*aenv
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			itrasp	ifile
i1	0	3526.73	.3535	"D04_REV06.wav"	; 17.675/50
;		+durrev/itrasp

e

</CsScore>
</CsoundSynthesizer>
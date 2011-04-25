<CsoundSynthesizer>

; Id: B03_TR02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oB03_TR02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1


;=============================================
; 222.2 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= p4
iamp	= p5
ifile	= p6

a1	diskin2 ifile, itrasp

ifrq	= sr*p4		; anti-aliasing filter
a1	tonex a1 , ifrq , 10
a1	tonex a1 , ifrq , 10

	out a1*iamp
	endin
;=============================================

</CsInstruments>
<CsScore>

t0	4572			; 76.2 cm/sec. tape speed (durations in cm)

;ORIGINAL MATERIAL B + DISTORTED MATERIAL B

;			p4	p5	p6
;			itrasp	iamp	ifile
i1	0	2052	.125	0.4	"B01.wav"		; 6.25/50
i1	0	2052	.125	0.6	"B02_DIST02.wav"	; 6.25/50

e

</CsScore>
</CsoundSynthesizer>
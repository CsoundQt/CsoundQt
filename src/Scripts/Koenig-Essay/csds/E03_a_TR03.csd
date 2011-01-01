<CsoundSynthesizer>

; Id: E03_a_TR03.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE03_a_TR03.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 252.a.3 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= p4
ifile	= p5

a1	diskin2 ifile, itrasp

ifrq	= 96000*p4		; anti-alias filter
a1	tonex a1 , ifrq , 10
a1	tonex a1 , ifrq , 10

	out a1*1.2
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			itrasp	ifile
i1	0	1796	.25	"E02_a_RM03.wav"	; 12.5/50

e

</CsScore>
</CsoundSynthesizer>
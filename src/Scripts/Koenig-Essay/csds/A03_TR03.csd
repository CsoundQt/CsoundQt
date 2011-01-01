<CsoundSynthesizer>

; Id: A03_TR03.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oA03_TR03.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 212.3 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= p4
ifile	= p5

a1	diskin2 ifile, itrasp

ifrq	= 96000*p4		; anti-aliasing filter
a1	tonex a1 , ifrq , 10
a1	tonex a1 , ifrq , 10

	out a1*1.05
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572	

;			p4	p5
;			itrasp	ifile
i1	0	3078	.125	"A02_RM03.wav"	; 6.25/50

e

</CsScore>
</CsoundSynthesizer>
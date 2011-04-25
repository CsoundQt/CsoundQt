<CsoundSynthesizer>

; Id: D07_TR07.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oD07_TR07.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 242.7 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= p4
ifile	= p5

a1	diskin2 ifile, itrasp

ifrq	= sr*p4		; anti-aliasing filter
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
i1	0	1225	.707	"D03_FILT07.wav"	; 35.35/50

e

</CsScore>
</CsoundSynthesizer>
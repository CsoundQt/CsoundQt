<CsoundSynthesizer>

; Id: C05_ABSCHNITT.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oX_ABSCHNITT_C.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

	
;=============================================
; 331-443 ENTRY DELAYS & SYNCHRONIZATION
;=============================================
	instr 1
iamp	= p4
ifile	= p5

a1	diskin2 ifile, 1

aout	=  a1* iamp

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			iamp	ifile
i1	0	380.6	.8	"C04_ENV01.wav"
i1	233.5	700	.8	"C04_ENV02.wav"	; + 233.5
i1	583.8	400	.8	"C04_ENV03.wav"	; + 350.3
						; PART D: + 155.7
; total length: 739.5
e

</CsScore>
</CsoundSynthesizer>
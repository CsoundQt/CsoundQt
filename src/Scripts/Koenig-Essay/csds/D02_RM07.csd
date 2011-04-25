<CsoundSynthesizer>

; Id: D02_RM02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -oD02_RM07.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;====================================
; 241.7 RING MODULATION
;====================================
	instr 1
ifreq	= p4

ifile	= p5

a1	diskin2 ifile, 1

a2	oscili a1, ifreq, 1	; sinus tone

	out a2
	endin
;====================================

</CsInstruments>
<CsScore>
f1 0 4096 10 1

t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			ifreq	ifile
;			[Hz]
i1	0	865.7	400 	"D01.wav"

e

</CsScore>
</CsoundSynthesizer>
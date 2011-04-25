<CsoundSynthesizer>

; Id: E02_a_RM03.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE02_a_RM03.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;====================================
; 251.a.3 RING MODULATION
;====================================
	instr 1
ifreq	= p4
ibw	= ifreq * .05
ifile	= p5

a1	diskin2 ifile, 1

a2	oscili a1, p4 , 1	; simus tone (S)

aout	= (a1*.4)+(a2*.6)
	out aout
	endin
;====================================

</CsInstruments>
<CsScore>
f1 0 4096 10 1

t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			ifreq	ifile
;			[Hz]
i1	0	449	1600 	"E01_a.wav"

e

</CsScore>
</CsoundSynthesizer>
<CsoundSynthesizer>

; Id: H03_RM01.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH03_RM01.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;====================================
; 281.1 RING MODULATION
;====================================
	instr 1
ifreq	= p4
ifile	= p5

ibw	= ifreq * .05

a1	diskin2 ifile , 1

a2	rand 1, .5 , 1			; filtered noise (N)
afilt	butterbp a2 , ifreq , ibw
afilt	butterbp afilt*10 , ifreq , ibw

arm	= (a1 * afilt * 2.7)

aout	=  arm + (a1 * .5)

	out aout*.85
	endin
;====================================

</CsInstruments>
<CsScore>

t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			ifreq	ifile
;			[Hz]
i1	0	171	800 	"H01.wav"

e

</CsScore>
</CsoundSynthesizer>
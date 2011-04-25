<CsoundSynthesizer>

; Id: G02_RM18.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oG02_RM18.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

gaMod	init 0			; modulating signal

;====================================
; 271.18 RING MODULATION
;====================================

;------------------------------------
	instr 1			; complex modulating signal (sum of sinusoids)
ifreq	= p4

a1	oscili 1 , ifreq, 1

gaMod	= gaMod + a1		; sums-up sinusoids in modulating signal
	endin
;------------------------------------

;------------------------------------
	instr 2
inum	= p4			; number of sinusoids
iamp	= 1 / inum
ifile	= p5

a1	diskin2 ifile , 1	; carrier

aout	=  (gaMod*iamp) * a1 	; RM

	out aout

gaMod	= 0

	endin
;------------------------------------

;====================================

</CsInstruments>
<CsScore>
f1 0 8192 10 1

t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4
;			ifreq
;			[Hz]
i1	0	1298.5	600			; simusoids
i1	0	1298.5	522
i1	0	1298.5	455
i1	0	1298.5	396
;			p4	p5
;			inum	ifile
i2	0	1298.5	4	"G01.wav"	; carrier
e

</CsScore>
</CsoundSynthesizer>
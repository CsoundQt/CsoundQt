<CsoundSynthesizer>

; Id: H05_RM05.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH05_RM05.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1



;====================================
; 281.5 RING MODULATION
;====================================
	instr 1
ifreq	= p4
ifile	= p5

a1	diskin2 ifile , 1

arm	oscili a1, ifreq , 1

aout	= (a1*.5) + (arm*.6)
	out aout*.95
	endin
;====================================

</CsInstruments>
<CsScore>
f1 0 8192 10 1		; sinusoid

t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			ifreq	ifile
;			[Hz]
i1	0	483.6	800 	"H04_TR05.wav"

e

</CsScore>
</CsoundSynthesizer>
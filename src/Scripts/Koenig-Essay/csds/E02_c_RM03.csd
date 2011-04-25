<CsoundSynthesizer>

; Id: E02_c_RM03.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE02_c_RM03.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;====================================
; 251.c.3 RING MODULATION
;====================================
	instr 1
ifreq	= p4
ibw	= ifreq * .01

ifile	= p5

a1	diskin2 ifile, 1
afilto	tonex a1 ,14000,10
afilto	tonex afilto ,14000,10

a2	rand 1, .67 , 1 		; filtered noise (N)
afilt	butterbp a2*4,ifreq , ibw
afilt	butterbp afilt*7 , ifreq , ibw

aout	= (afilto * afilt * .8)+(a1*.8)

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
i1	0	128.1	1600 	"E01_c.wav"

e

</CsScore>
</CsoundSynthesizer>
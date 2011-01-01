<CsoundSynthesizer>

; Id: E02_d_RM01.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE02_d_RM01.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;====================================
; 251.d.1 RING MODULATION
;====================================
	instr 1
ifreq	= p4
ibw	= ifreq * .05

ifile	= p5

a1	diskin2 ifile, 1


kfrq	randi .2 , 20 , .99 , 1		; random filtered impulses (I)
kfrq	= 20 * (1 + kfrq)
a2	mpulse 1, 1/kfrq 
afilt	butterbp a2*24,ifreq , ibw
afilt	butterbp afilt*210 , ifreq , ibw

arm	= afilt * a1

aout	= (arm *.8)+(a1*.8)

	out aout*.8
	endin
;====================================

</CsInstruments>
<CsScore>
f1 0 4096 10 1

t0	4572		; 76.2 cm/sec. tape speed (durations in cm)	

i1	0	128.1	100 	"E01_d.wav"

e

</CsScore>
</CsoundSynthesizer>
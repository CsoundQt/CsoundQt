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
kr     = 192000
ksmps  = 1
nchnls = 1

;====================================
; 251.d.1 RING MODULATION
;====================================
	instr 1
ifreq	= p4
ibw	= ifreq * .05

if1	= ifreq-(ibw/3)
if2	= ifreq+((2*ibw)/3)

ifile	= p5

a1	diskin2 ifile, 1

kfrq	randi .2 , 20 , .99 , 1		; random filtered impulses (I)
kfrq	= 20 * (1 + kfrq)
a2	mpulse 1, 1/kfrq 

afilt	atonex a2 , if1 , 2
afilt	tonex afilt*270 , if2 , 2  
afilt	butterbp afilt*900 , ifreq , ibw*.01

arm	= afilt * a1

aout	= (arm )+(a1*.7)

	out aout*.65
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
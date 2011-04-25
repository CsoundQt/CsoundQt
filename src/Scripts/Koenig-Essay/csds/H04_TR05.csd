<CsoundSynthesizer>

; Id: H04_TR05.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH04_TR05.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

/*
According to Koenig:

In a manuscript on Essay I found the following description:
Three of the five transpositions (2, 3, 5) are preceded by a treatment with the Springermaschine, two times 
for a stretch (without frequency change) of 4 octaves (2, 3), and once for a stretch of one octave. 
It was followed by the "normal" transposition of 2 resp. 3 octaves up and of 35.36/50 down. [...] 
It is important that in transposition 5 ring modulation follows transposition instead of preceding it. 

*/

;=============================================
; 282.5 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= p4
ifile	= p5

a1	diskin2 ifile, itrasp

ifrq	= 96000*itrasp		; anti-aliasing filter
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
i1	0	483.6	.7072	"H02_TRSM05.wav"	; 35.36/50

e

</CsScore>
</CsoundSynthesizer>
<CsoundSynthesizer>

; Id: A05_REV07.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oA05_REV07.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 214.7 REVERBERATION
;=============================================
	instr 1
iampr	= ampdb(p4)
ifile 	= p5

a1	diskin2 ifile, 1

ar	nreverb a1, 5, .3

; increasing reverberation (chiefly at the end)
aenv	expseg 1,   8,  .4,  2, .06, p3-9, .001		; dry signal's envelope
aenvr	expseg .1,  8,  .7,  2, 1, p3-9, 1		; wet signal's envelope
aenvr	= aenvr * iampr

aout	=  a1*aenv +(ar*aenvr)
	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4			
;			iamp	ifile			
;			[dB]
i1	0	1150.5	-12	"A04_FILT07.wav"

; durrev = 5 * 76,2 = 381
; dur = 769.5 + durrev
e

</CsScore>
</CsoundSynthesizer>
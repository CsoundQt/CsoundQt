<CsoundSynthesizer>

; Id: C03_REV02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oC03_REV02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 234.2 REVERBERATION
;=============================================
	instr 1

iampr	= ampdb(p4)

ifile	= p5

a1	diskin2 ifile, 1

ar	nreverb a1, 5, .3

; increasing reverberation (only at the end)
aenv	expseg 1,  2.1,1,	      1, .25,  p3-3.1, .25
aenvr	expseg .02, 2.1,.25, 1, 1,  p3-3.1, 1

aout	=  a1*aenv +(ar*aenvr*iampr)

	out aout*.95
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			iampr	ifile
i1	0	685	-28	"C02_TR02.wav"
;durrev= 5*76.2 = 381
; dur = 304 + durrev
e

</CsScore>
</CsoundSynthesizer>
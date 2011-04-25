<CsoundSynthesizer>

; Id: B04_REV02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oB04_REV02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 224.2 REVERBERATION
;=============================================
	instr 1

iampr	= ampdb(p4)
ifile	= p5

a1	diskin2 ifile, 1

ar	nreverb a1, 5, .3

aout	=  a1*.5 +(ar*iampr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 5.6*76.2 + 3*76.2 = 426.72+228.6=655.32
;			p4	p5
;			iampr	ifile
i1	0	2433	-22	"B03_TR02.wav"
;durrev= 5*76.2 = 381
; dur = 2052 + 381 = 2433
e

</CsScore>
</CsoundSynthesizer>
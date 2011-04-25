<CsoundSynthesizer>

; Id: D04_REV06.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oD04_REV06.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 244.6 REVERBERATION
;=============================================
	instr 1
iampr	= ampdb(p4)

ifile	= p5

a1	diskin2 ifile, 1

ar	nreverb a1, 5, .3

aout	=  a1*.8 +(ar*iampr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			iampr	ifile
i1	0	1246.7	-12	"D03_FILT06.wav"

;durrev= 5*76.2 = 381
; dur = 865.7 + durrev 

e

</CsScore>
</CsoundSynthesizer>
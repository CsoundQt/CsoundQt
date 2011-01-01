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
idel	= 5.6 ; 5.6 s * 76.2 
iampr	= ampdb(89+p4)

ifile	= p5

a1	diskin2 ifile, 1

ar	convolve a1/ 789258 , "IR5s.cv", 1

a1	delay a1 , idel

aout	=  a1*.8 +(ar*iampr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 5.6*76.2 + 3*76.2 = 426.72+228.6=655.32

;			p4	p5
;			iampr	ifile
i1	0	1700	-7	"D03_FILT06.wav"

; dur D03_FILT06=865.7

e

</CsScore>
</CsoundSynthesizer>
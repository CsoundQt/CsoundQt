<CsoundSynthesizer>

; Id: E04_b_REV02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE04_b_REV02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 254.b.2 REVERBERATION
;=============================================
	instr 1
idel	= 5.6 ; 5.6 s * 76.2 
iampr	= ampdb(90+p4)

ifile	= p5

a1	diskin2 ifile, 1

ar	convolve a1/ 3719737 , "IR5s.cv", 1

a1	delay a1 , idel

aout	=  a1*.3 +(ar*iampr)
	
	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)
	
;durerev= 5.6*76.2 + 1*76.2 = 426.72 + 76.2=502.92

;			p4	p5
;			iampr	ifile
i1	0	759.02	-2	"E03_b_TR02.wav"
; dur 56.1
e

</CsScore>
</CsoundSynthesizer>
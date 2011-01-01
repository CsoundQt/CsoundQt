<CsoundSynthesizer>

; Id: G04_REV19-2.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oG04_REV19-2.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 274.19 REVERBERATION
;=============================================
	instr 1
idel	= 5.6 ; 5.6 s * 76.2 
iampr1	= ampdb(90+p4)
iampr2	= ampdb(90+p5)

ifile	= p6

a1	diskin2 ifile, 1

ar	convolve a1/ 5325362 , "IR5s.cv", 1
aenvr	linseg iampr1, idel+20.5, iampr1, 1.5 , iampr2 , p3-idel-22 , iampr2

a1	delay a1 , idel

aout	=  (a1*.45) +(ar*aenvr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 5.6*76.2 = 426.72

;			p4	p5	p6
;			iampr1	iampr2	ifile
;			[dB]	[dB]
i1	0	2754.72	-4 	-90	"G03_TR19-2.wav"

; dur 2328

e

</CsScore>
</CsoundSynthesizer>
<CsoundSynthesizer>

; Id: H05_REV01.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH05_REV01.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 284.1 REVERBERATION
;=============================================
	instr 1
iampr	= ampdb(90+p4)
ifile	= p5

idel	= 5.6 ; 5.6 s * 76.2 

a1	diskin2 ifile , 1

ar	convolve a1/ 1635201 , "IR5s.cv", 1

a1	delay a1 , idel

; decreasing and increasing reverberation
aenvr	expseg 1., idel, 1., 2.2, .2 , 2.2, 1 ,   p3-idel-4.4, 1
aenv	expseg .1, idel, .1, 2.2, 1.3, 2.2, .25,  p3-idel-4.4, 0.0001

aout	=  (a1*aenv) +(ar*aenvr*iampr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 5.6*76.2 + 3*76.2 = 426.72+228.6=655.32

;			p4	p5
;			iampr	ifile
i1	0	1210	1.5	"H04_TR01.wav"

; dur 342

e

</CsScore>
</CsoundSynthesizer>
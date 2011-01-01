<CsoundSynthesizer>

; Id: H05_REV02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH05_REV02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 284.2 REVERBERATION
;=============================================
	instr 1
iampr	= ampdb(90+p4)
ifile	= p5

idel	= 5.61 ; 5.6 s * 76.2 

a1	diskin2 ifile, 1

ar	convolve a1/ 456337 , "IR5s.cv", 1

a1	delay a1, idel

; increasing reverberation only at the end
aenv	expseg .9,  idel+.8, .9,  .3 , .125, p3-idel-1.1, .125
aenvr	expseg .06, idel+.5, .06, .3 , 1,    p3-idel-.8 , 1

aout	=  (a1*aenv) + (ar*iampr*aenvr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 5.6*76.2 + 3*76.2 = 426.72+228.6=655.32

;			p4	p5
;			iampr	ifile
i1	0	892.5	-8	"H04_TR02.wav"

; dur 87.5

e

</CsScore>
</CsoundSynthesizer>
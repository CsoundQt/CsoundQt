<CsoundSynthesizer>

; Id: G04_REV19-1.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oG04_REV19-1.wav
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
iampr	= ampdb(90+p4)

ifile	= p5

a1	diskin2 ifile, 1

ar	convolve a1/ 1943927 , "IR5s.cv", 1

aenvr	linseg iampr, idel+10.5, iampr, .1, iampr-18000, 4, 0, p3-idel-14.6, 0
aenv	linseg 0 ,    idel+10.5, 0,     .1, 1,           p3-idel-10.6, 1

a1	delay a1 , idel


aout	=  (a1*aenv) +(ar*aenvr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 5.6*76.2 = 426.72

;			p4	p5	
;			iampr1	ifile
;			[dB]
i1	0	2754.72	0	"G03_TR19-1.wav"

; dur 2328

e

</CsScore>
</CsoundSynthesizer>
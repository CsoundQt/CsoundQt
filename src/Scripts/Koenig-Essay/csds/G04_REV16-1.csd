<CsoundSynthesizer>

; Id: G04_REV16-1.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oG04_REV16-1.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 274.16 REVERBERATION
;=============================================
	instr 1
idel	= 5.6 ; 5.6 s * 76.2 
iampr	= ampdb(90+p4)

ifile	= p5

a1	diskin2 ifile, 1

ar	convolve a1/ 2520531 , "IR5s.cv", 1
aenvr	linseg iampr, idel+7.5 ,iampr,6 , 0 , p3-idel-13.5 , 0
aenv	linseg 0,     idel+8.5 , .3  ,5 , 1 , p3-idel-13.5 , 1

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
i1	0	2103.07	-1	"G03_TR16-1.wav"

; dur 1676.35

e

</CsScore>
</CsoundSynthesizer>
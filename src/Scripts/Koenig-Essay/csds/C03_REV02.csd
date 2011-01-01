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
idel	= 5.6 ; 5.6 s * 76.2 
iampr	= ampdb(90+p4)

ifile	= p5

a1	diskin2 ifile, 1

ar	convolve a1/ 5076694, "IR5s.cv", 1

a1	delay a1 , idel

; increasing reverberation (only at the end)
aenv	expseg 1,  idel+2.1,1,	      1, .25,  p3-idel-3.1, .25
aenvr	expseg .01,idel,.02, 2.1,.25, 1, 1.2,  p3-idel-3.1, 1.2

aout	=  a1*aenv +(ar*aenvr*iampr)

	out aout*.95
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 5.6*76.2 + 3*76.2 = 426.72+228.6=655.32

;			p4	p5
;			iampr	ifile
i1	0	1200	-6	"C02_TR02.wav"

; dur C02_TR02=304

e

</CsScore>
</CsoundSynthesizer>
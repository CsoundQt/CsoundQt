<CsoundSynthesizer>

; Id: F02_REV.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oF02_REV.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 264.1-4 REVERBERATION
;=============================================
	instr 1
idel	= 5.6 ; 5.6 s * 76.2 
iampr	= ampdb(90+p4)

ifile	= p5

a1	diskin2 ifile, 1

ar	convolve a1/ 1799893 , "IR5s.cv", 1

a1	delay a1 , idel

aout	=  (ar*iampr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 2*(5.6*76.2) = 426.72*2=853.44

;			p4	p5
;			iampr	ifile
i1	0	967.44	0	"F01.wav"

; dur F01=114

e

</CsScore>
</CsoundSynthesizer>
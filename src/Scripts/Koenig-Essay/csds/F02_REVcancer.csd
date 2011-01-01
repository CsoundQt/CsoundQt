<CsoundSynthesizer>

; Id: F02_REVcancer.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oF02_REVcancer.wav
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
iskip	= 12.696
iampr	= ampdb(90+p4)

ifile	= p5

a1	diskin2 ifile, -1 , iskip		; reads backwards from the end of the file

ar	convolve a1/ 3028758 , "IR5s.cv", 1

a1	delay a1 , idel

aout	=  a1*.3 +(ar*iampr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 2*(5.6*76.2) = 426.72*2=853.44
;		F02_REV01+426.72	(durata effettiva: p3-idel=1394.16-426.72=967.44)

;			p4	p5
;			iampr	ifile
i1	0	1394.16	0	"F02_REV.wav"

; dur F01=114

e

</CsScore>
</CsoundSynthesizer>
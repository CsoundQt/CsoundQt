<CsoundSynthesizer>

; Id: H05_REV04.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH05_REV04.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 284.4 REVERBERATION
;=============================================

; backwards reverberation

	instr 1
ifile	= p4

a1	diskin2 ifile , -1, 0,1
ga1	= a1
	endin

	instr 2
iampr	= ampdb(90+p4)

idel	= 5.6 ; 5.6 s * 76.2 

a1	= ga1

ar	convolve a1/ 2051189 , "IR5s.cv", 1

a1	delay a1 , idel

aenv	expseg .8,   idel, .8,   2, 0.01, p3-idel-2, 0.01
aenvr	expseg .25,  idel, .25,  2, 1,     p3-idel-2, 1

aout	=  (a1*aenv) +(ar*aenvr*iampr)

	out aout
ga1	= 0
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 5.6*76.2 + 3*76.2 = 426.72+228.6=655.32

;			p4
;			ifile
i1	0	171	"H01.wav"
;			p4	
;			iampr	
i2	0	1024.42	0

; dur 171

e

</CsScore>
</CsoundSynthesizer>
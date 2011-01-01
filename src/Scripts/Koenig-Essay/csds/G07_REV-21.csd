<CsoundSynthesizer>

; Id: G07_REV-21.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oG07_REV-21.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 274. REVERBERATION
; see 372.VII
;=============================================
	instr 1
ifile	= p4

a1	diskin2 ifile , -1, 0,1
ga1	= a1
;	out a1
	endin

	instr 2
idel	= 5.6 ; 5.6 s * 76.2 
iampr	= ampdb(90+p4)

a1	=ga1

ar	convolve a1/ 1498699 , "IR5s.cv", 1

a1	delay a1, idel 
aenv	linseg .5, 90, .5, 15, 0, p3-105, 0

aout	= (a1*.4) + (ar*iampr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
f1 0 4096 10 1
t0	4572	
;durerev= 5.6*76.2 = 426.72
;				p4
;				ifile
i1	0	13101.72	"G06_ABSCHNITT-2.wav"
;				iampr
i2	0	13954.96	-1

; dur 12674.8

e

</CsScore>
</CsoundSynthesizer>
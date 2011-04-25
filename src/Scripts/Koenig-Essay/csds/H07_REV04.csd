<CsoundSynthesizer>

; Id: H07_REV04.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oH07_REV04.wav
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

a1	diskin2 ifile , -1, p3
ga1	= a1
	endin

	instr 2
iampr	= ampdb(p4)

a1	= ga1

ar	nreverb a1, 5, .3

aenv	expseg 1,   2, 0.1, p3-2, 0.1
aenvr	expseg .25,  .5, 1,   p3-2, 1

aout	=  (a1*aenv) +(ar*aenvr*iampr)

	out aout
ga1	= 0
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4
;			ifile
i1	0	171	"H01.wav"
;			p4	
;			iampr	
i2	0	552	-18

;durrev= 5*76.2 = 381
; dur = 171 + durrev
e

</CsScore>
</CsoundSynthesizer>
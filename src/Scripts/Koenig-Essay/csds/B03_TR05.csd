<CsoundSynthesizer>

; Id: B03_TR05.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oB03_TR05.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1


;=============================================
; 222.5 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= p4
ifile	= p5

a1	diskin2 ifile, itrasp

	out a1
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572			; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			itrasp	ifile
i1	0	168.7	1.52	"B01.wav"	; 76/50

e

</CsScore>
</CsoundSynthesizer>
<CsoundSynthesizer>

; Id: D07_TR09b.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oD07_TR09b.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 242.9 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= p4
ifile	= p5

idel	= 5.6

a1	diskin2 ifile, itrasp, idel

aenv	linseg 1, p3-.01, 1 , .01 , 0

	out a1*aenv
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			itrasp	ifile
i1	0	1265.6	1	"D04_REV09.wav"	; 50/50


</CsScore>
</CsoundSynthesizer>
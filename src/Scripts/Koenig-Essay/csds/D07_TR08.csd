<CsoundSynthesizer>

; Id: D07_TR08.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oD07_TR08.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 242.8 TRANSPOSITION (RESAMPLING)
;=============================================
	instr 1
itrasp	= p4
ifile	= p5

a1	diskin2 ifile, itrasp, 5.6

aenv	linseg 1, p3-.01, 1 , .01 , 0

	out a1*aenv
	endin
;=============================================



</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5
;			itrasp	ifile
i1	0	316.4	4	"D04_REV08.wav"	; 200/50

e

</CsScore>
</CsoundSynthesizer>
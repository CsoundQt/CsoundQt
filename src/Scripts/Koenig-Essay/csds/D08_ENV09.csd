<CsoundSynthesizer>

; Id: D08_ENV09.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oD08_ENV09.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 245.9 INTENSITY CURVES
;=============================================
	instr 1
idur	= p3
ifile1	= p4
ifile2	= p5

a1	diskin2  ifile1, 1
a2	diskin2  ifile2, 1

att	linen 1 , .01 , p3 , .01

aout	=  (a1*.75)+(a2*.5) * att

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)	

;			p4		p5	
;			ifile1		ifile2
i1	0	1265.6	"D07_TR09a.wav"	"D07_TR09b.wav"

e

</CsScore>
</CsoundSynthesizer>
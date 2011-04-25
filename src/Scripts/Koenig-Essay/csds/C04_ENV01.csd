<CsoundSynthesizer>

; Id: C04_ENV01.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oC04_ENV01.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 235.1 INTENSITY CURVES
;=============================================
	instr 1
iamp	= ampdb(p4)

ifile	= p5

a1	diskin2  ifile, 1

att	linen iamp , .01 , p3 , .01
aout	=  a1 * att

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)	

;			p4	p5	
;			iamp1	ifile
;			[dB]	
i1	0	533	-9	"C03_REV01.wav"	


e

</CsScore>
</CsoundSynthesizer>
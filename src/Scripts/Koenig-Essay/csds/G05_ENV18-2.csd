<CsoundSynthesizer>

; Id: G05_ENV18-2.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oG05_ENV18-2.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 275.18 INTENSITY CURVES
;=============================================
	instr 1
iamp	= ampdb(90+p4)/ 31020

idur	= p3
ifile	= p5

a1	diskin2  ifile, 1, 5.6

att	linen 1 , .01 , p3 , .01

aout	=  a1*iamp 

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)	

;			p4	p5	
;			iamp1	ifile
;			[dB]	
i1	0	2086	-20	"G04_REV18-2.wav"

e

</CsScore>
</CsoundSynthesizer>
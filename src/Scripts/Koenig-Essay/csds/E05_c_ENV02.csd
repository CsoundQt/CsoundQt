<CsoundSynthesizer>

; Id: E05_c_ENV02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE05_c_ENV02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 255.c.2 INTENSITY CURVES
;=============================================
	instr 1
iamp	= ampdb(p4)

ifile	= p5

a1	diskin2  ifile, 1

aout	=  a1* iamp

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)	

;			p4	p5	
;			iamp1	ifile
;			[dB]	
i1	0	512.4	-25	"E03_c_TR02.wav"

e

</CsScore>
</CsoundSynthesizer>
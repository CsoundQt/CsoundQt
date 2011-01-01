<CsoundSynthesizer>

; Id: E05_d_ENV02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE05_d_ENV02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 255.d.2 INTENSITY CURVES
;=============================================
	instr 1
iamp	= ampdb(90+p4)/ 32761

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
i1	0	32	-15	"E03_d_TR02.wav"

e

</CsScore>
</CsoundSynthesizer>
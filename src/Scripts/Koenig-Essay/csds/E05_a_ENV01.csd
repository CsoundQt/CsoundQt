<CsoundSynthesizer>

; Id: E05_a_ENV01.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE05_a_ENV01.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 255.a.1 INTENSITY CURVES
;=============================================
	instr 1
iamp1	= ampdb(90+p4)/31755
iamp2	= ampdb(90+p5)/31755
iamp3	= ampdb(90+p6)/31755

idur	= p3
ifile	= p7

a1	diskin2  ifile, 1

aenv	expseg iamp1,23,iamp1,.1,iamp2,idur-23.1,iamp3

aout	=  a1*aenv 

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)	

;			p4	p5	p6	p7
;			iamp1	iamp2	iamp3	ifile
;			[dB]	[dB]	[dB]
i1	0	7184	-12 	-15 	-30 	"E03_a_TR01.wav"

e

</CsScore>
</CsoundSynthesizer>
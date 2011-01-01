<CsoundSynthesizer>

; Id: E05_a_ENV04.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE05_a_ENV04.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 255.a.4 INTENSITY CURVES
;=============================================
	instr 1
iamp1	= ampdb(90+p4)/ 31558
iamp2	= ampdb(90+p5)/ 31558

ifile	= p6

a1	diskin2  ifile, 1

aenv	expseg iamp1,5.8,iamp1,p3-5.8,iamp2

aout	=  a1*aenv 

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)	

;			p4	p5	p6
;			iamp1	iamp2	ifile
;			[dB]	[dB]	
i1	0	898	-15 	-30	"E03_a_TR04.wav"

e

</CsScore>
</CsoundSynthesizer>
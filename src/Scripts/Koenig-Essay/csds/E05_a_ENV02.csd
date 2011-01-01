<CsoundSynthesizer>

; Id: E05_a_ENV02.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oE05_a_ENV02.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 255.a.2 INTENSITY CURVES
;=============================================
	instr 1
iamp1	= ampdb(90+p4)/ 31649
iamp2	= ampdb(90+p5)/ 31649
iamp3	= ampdb(90+p6)/ 31649

ifile	= p7

a1	diskin2  ifile, 1

aenv	expseg iamp1,19.8,iamp2,1,iamp2,p3-20.8,iamp3

aout	=  a1*aenv 

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)	

;			p4	p5	p6
;			iamp1	iamp2	iamp3	ifile
;			[dB]	[dB]	[dB]
i1	0	3592	-15 	-10 	-30 	"E03_a_TR02.wav"

e

</CsScore>
</CsoundSynthesizer>
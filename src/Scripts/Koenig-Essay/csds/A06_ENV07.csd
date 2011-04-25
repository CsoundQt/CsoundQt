	<CsoundSynthesizer>

; Id: A06_ENV07.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -oA06_ENV07.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 215.7 INTENSITY CURVES
;=============================================
	instr 1
iamp1	= ampdb(p4)
iamp2	= ampdb(p5)
iamp3	= ampdb(p6)
iamp4	= ampdb(p7)

ifile 	= p8

a1	diskin2 ifile, 1

aenv	expseg iamp1,4,iamp2,3,iamp3,2,iamp4,p3-9,iamp4

aout	=  a1*aenv 
	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5	p6	p7	p8
;			iamp1	iamp2	iamp3	iamp4	ifile
;			[dB]	[dB]	[dB]	[dB]
i1	0	1150.5	-30	-5	-20	0	"A05_REV07.wav"

e

</CsScore>
</CsoundSynthesizer>
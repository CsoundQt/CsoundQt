<CsoundSynthesizer>

; Id: A06_ENV06.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oA06_ENV06.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 215.6 INTENSITY CURVES
;=============================================
	instr 1
iamp1	= ampdb(90+p4)/32768
iamp2	= ampdb(90+p5)/32768
iamp3	= ampdb(90+p6)/32768

ifile 	= p7

a1	diskin2 ifile, 1

aenv	expseg iamp1,8,iamp2,7.5,iamp3,p3-15.5,iamp2

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
i1	0	1539	-12	-28	1.5	"A04_FILT06.wav"

e

</CsScore>
</CsoundSynthesizer>
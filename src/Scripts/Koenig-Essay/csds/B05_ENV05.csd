<CsoundSynthesizer>

; Id: B05_ENV05.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oB05_ENV05.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 225.5 INTENSITY CURVES
;=============================================
	instr 1
iamp1	= ampdb(90+p4)/ 28000
iamp2	= ampdb(90+p5)/ 28000

ifile	= p6

a1	diskin2 ifile, 1 

aenv	expseg iamp1,p3,iamp2

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
i1	0	168.7	-5	-30	"B03_TR05.wav"
e

</CsScore>
</CsoundSynthesizer>
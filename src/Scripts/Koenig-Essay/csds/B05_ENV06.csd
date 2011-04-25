<CsoundSynthesizer>

; Id: B05_ENV06.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oB05_ENV06.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 225.6 INTENSITY CURVES
;=============================================
	instr 1
iamp1	= ampdb(p4)
iamp2	= ampdb(p5)
iamp3	= ampdb(p6)

ifile	= p7

a1	diskin2 ifile, 1

aenv	expseg iamp1,1.5,iamp2,p3-1.5, iamp3

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
i1	0	893.1	-30	0	-30	"B03_TR06.wav"		
e

</CsScore>
</CsoundSynthesizer>
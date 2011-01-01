<CsoundSynthesizer>

; Id: D08_ENV08.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oD08_ENV08.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 245.8 INTENSITY CURVES
;=============================================
	instr 1
iamp1	= ampdb(90+p4)/ 21420
iamp2	= ampdb(90+p5)/ 29211

idur	= p3
ifile	= p6

a1	diskin2  ifile, 1

att	linen .9 , .01 , p3 , .01
aenv	expseg iamp1,1.3,iamp1,.7,iamp2,idur-2,iamp2

aout	=  a1*aenv * att

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)	

;			p4	p5	
;			iamp1	iamp2	ifile
;			[dB]	[dB]
i1	0	316.4	-10 	0	"D07_TR08.wav"

e

</CsScore>
</CsoundSynthesizer>
<CsoundSynthesizer>

; Id: D08_ENV07.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oD08_ENV07.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 245.7 INTENSITY CURVES
;=============================================
	instr 1
iamp1	= ampdb(90+p4)/ 21420
iamp2	= ampdb(90+p5)/ 29211

idur	= p3
ifile	= p6

a1	diskin2  ifile, 1 

att	linen 1 , .01 , p3 , .01
aenv	expseg iamp1,13,iamp1,idur-13,iamp2

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
i1	0	1224	-15 	-40	"D07_TR07.wav"

e

</CsScore>
</CsoundSynthesizer>
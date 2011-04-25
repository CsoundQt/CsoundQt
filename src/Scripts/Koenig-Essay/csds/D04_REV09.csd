<CsoundSynthesizer>

; Id: D04_REV09.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oD04_REV09.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 244.9 REVERBERATION
;=============================================
	instr 1

iamp1	= ampdb(p4)
iamp2	= ampdb(p5)

ifile	= p6

a1	diskin2 ifile, 1

ar	nreverb a1, 5, .3

aenvr	expseg iamp1 , 2 , iamp2 , 2.5 , iamp1 , 2.3, iamp1 , 1.2 , iamp2, 4 ,iamp2

aout	=  a1*.5 + (ar*aenvr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5	p6
;			iamp1	iamp2	ifile
i1	0	1246.7	-31	-18	"D03_FILT09.wav"

;durrev= 5*76.2 = 381
; dur = 865.7 + durrev 
e

</CsScore>
</CsoundSynthesizer>	
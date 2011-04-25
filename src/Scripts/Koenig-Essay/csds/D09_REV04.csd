<CsoundSynthesizer>

; Id: D09_REV04.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)
<CsOptions>
-W -f -oD09_REV04.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1


;=============================================
; 244.4 REVERBERATION
;=============================================
	instr 1
iampr	= ampdb(p4)

ifile	= p5

a1	diskin2 ifile, 1

ar	nreverb a1, 5, .3

aout	=  a1*.7 +(ar*iampr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)
	
;durerev= 5.6*76.2 + 3*76.2 = 426.72+228.6=655.32

;			p4	p5
;			iampr	ifile
i1	0	3844.1	-13	"D06_CUT04.wav"
;		
;durrev= 5*76.2 = 381
; dur = 3463.1 + durrev 

e

</CsScore>
</CsoundSynthesizer>
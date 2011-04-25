<CsoundSynthesizer>

; Id: A05_REV03.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oA05_REV03.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 214.3 REVERBERATION
;=============================================
	instr 1
iampr	= ampdb(p4)
ifile 	= p5

a1	diskin2 ifile, 1

ar	nreverb a1, 5, 0.5

aout	=  a1*.4 +(ar*iampr)
	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5	
;			iampr	ifile			
;			[dB]
i1	0	3459	-16	"A03_TR03.wav"

;durrev= 5*76.2 = 381
; dur = 3078 + durrev
e

</CsScore>
</CsoundSynthesizer>
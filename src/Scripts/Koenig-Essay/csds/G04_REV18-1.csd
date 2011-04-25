<CsoundSynthesizer>

; Id: G04_REV18-1.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oG04_REV18-1.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 274.18 REVERBERATION
;=============================================
	instr 1

iampr	= ampdb(p4)

ifile	= p5

a1	diskin2 ifile, 1

ar	nreverb a1, 5, .3

aenvr	expseg iampr, p3*.4 ,iampr, p3*.4 , .001 , p3*.2 , .001
aenv	expseg .05, p3*.4 , .25  ,p3*.4 , 1 , p3*.2 , 1

aout	=  (a1*aenv) +(ar*aenvr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4	p5	
;			iampr	ifile
;			[dB]	
i1	0	2086.28	-13	"G03_TR18-1.wav"

e

</CsScore>
</CsoundSynthesizer>
<CsoundSynthesizer>

; Id: A05_REV01.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oA05_REV01.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 214.1 REVERBERATION
;=============================================
	instr 1
iampr	= ampdb(p4)				; duration of reverberated file
ifile 	= p5

a1	diskin2 ifile, 1

ar	nreverb a1, 5, 0.5

aenvr	expseg .5 , .7 , .5  , .562 , 1, p3-1.262, 1
aenvr	= aenvr * iampr
aenv	expseg 1,  .9 , 1  , .362 , .85 , p3-1.262 , .85


aout	= a1*aenv + (ar*aenvr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;			p4			
;			iampr	ifile			
;			[dB]
i1	0	477.2	-15	"A04_FILT01.wav" ; 

; durrev = 5 * 76,2 = 381
; dur = 96.2 + durrev
e

</CsScore>
</CsoundSynthesizer>
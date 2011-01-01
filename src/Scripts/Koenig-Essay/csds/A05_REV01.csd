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
idel	= 5.6 			; 5.6 s * 76.2 
iampr	= ampdb(90+p4)

ifile 	= p5

a1	diskin2 ifile, 1

ar	convolve a1/ 2531031, "IR5s.cv", 1	; normalized convolution

a1	delay a1 , idel

aenvr	expseg 1 , idel+1.1 , 1  , .162 , 3 , p3-idel-1.262 , 3

aout	= a1*.9 + (ar*iampr*aenvr)

	out ar*iampr*aenvr
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 5.6*76.2 + 3*76.2 = 426.72+228.6=655.32

;			p4	p5			
;			iamp	ifile			
;			[dB]
i1	0	752	-12	"A04_FILT01.wav" ; 
; dur 96.2
e

</CsScore>
</CsoundSynthesizer>
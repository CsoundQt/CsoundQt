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
idel	= 5.6 ; 5.6 s * 76.2 
iamp1	= ampdb(90+p4)
iamp2	= ampdb(90+p5)

ifile	= p6

a1	diskin2 ifile, 1

ar	convolve a1/ 2483936 , "IR5s.cv", 1

a1	delay a1 , idel

aenvr	expseg iamp1 , idel+.7 , iamp2 , 2.5 , iamp1 , 2.3, iamp1 , 1.2 , iamp2, 4 ,iamp2

aout	=  (ar*aenvr)

	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;durerev= 5.6*76.2 + 3*76.2 = 426.72+228.6=655.32

;			p4	p5	p6
;			iamp1	iamp2	ifile
i1	0	1721.02	-25	-12	"D03_FILT09.wav"
; dur 865.7
e

</CsScore>
</CsoundSynthesizer>	
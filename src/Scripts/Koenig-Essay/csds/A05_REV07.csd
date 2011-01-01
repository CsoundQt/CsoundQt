<CsoundSynthesizer>

; Id: A05_REV07.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oA05_REV07.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 214.7 REVERBERATION
;=============================================
	instr 1
idel	= 5.6 ; 5.6 s * 76.2 
iampr	= ampdb(90+p4)

ifile	= p5

a1	diskin2 ifile, 1

ar	convolve a1/ 2396720 , "IR5s.cv", 1

a1	delay a1 , idel

; increasing reverberation (chiefly at the end)
aenv	expseg 1,   idel, 1,   8,  .75, 2, .06, p3-idel-9, .001		; dry signal's envelope
aenvr	expseg .01, idel, .02,  8, .5,  2,  1.5,p3-idel-9, 1.5		; wet signal's envelope

aout	=  a1*aenv *.9+(ar*aenvr*iampr)
	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>
t0	4572	
;durerev= 5.6*76.2 + 4*76.2 = 426.72+304.8=731.52

;			p4	p5			
;			iamp	ifile			
;			[dB]
i1	0	1850	-2.5	"A04_FILT07.wav"
; dur 769.5
e

</CsScore>
</CsoundSynthesizer>
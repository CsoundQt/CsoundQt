<CsoundSynthesizer>

; Id: G08_ABSCHNITT.CSD mg (2006, rev.2009)
; author: marco gasperini (marcogsp at yahoo dot it)

; G.M. Koenig
; ESSAY (1957)

<CsOptions>
-W -f -oX_ABSCHNITT_G.wav
</CsOptions>

<CsInstruments>

sr     = 192000
kr     = 19200
ksmps  = 10
nchnls = 1

;=============================================
; 372. SYNCHRONIZATION
;=============================================
	instr 1
ifile	= p4

a1	diskin2 ifile , 1
aenv	linseg 1 , 90, 1, 10, 1.2, p3-100, 3.5
aout	=  a1* aenv * 1.2
	out aout
	endin

	instr 2
ifile	= p4

a1	diskin2 ifile , 1, 5.6, 1
;aenv	linseg .2 , 90, .2, 10, .3, p3-100, .45
aout	=  a1* .2
	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>

t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;				p4
;				ifile
i1	0	12674.8 	"G06_ABSCHNITT-1.wav"
i2	0	14381.68 	"G07_REV-22.wav"	
e

</CsScore>
</CsoundSynthesizer>
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
kr     = 192000
ksmps  = 1
nchnls = 1

;=============================================
; 372. SYNCHRONIZATION
;=============================================
	instr 1
ifile	= p4

a1	diskin2 ifile , 1

aout	=  a1 
	out aout
	endin

	instr 2
ifile	= p4

a1	diskin2 ifile , -1, p3

aout	=  a1 
	out aout
	endin
;=============================================

</CsInstruments>
<CsScore>

t0	4572		; 76.2 cm/sec. tape speed (durations in cm)

;				p4
;				ifile
i1	762	12675	 	"G06_ABSCHNITT-1.wav"
i2	0	13437	 	"G07_REV-22.wav"
; G attack -762	
e

</CsScore>
</CsoundSynthesizer>